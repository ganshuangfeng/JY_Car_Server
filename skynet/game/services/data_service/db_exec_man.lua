--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：数据库访问功能
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
require"printfunc"
require "data_func"
local mysql = require "skynet.db.mysql"

local monitor_lib = require "monitor_lib"

local db_sql_stat = require "data_service.db_sql_stat"

require "normal_enum"

local data_common = require "data_service.data_common"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.sql_str_begin = " call exec_sql_begin();"
DATA.sql_str_deal = " call exec_sql_deal();"
DATA.sql_str_end = " call exec_sql_end();"

local LF = base.LocalFunc("db_exec_man")

function LF.gen_sql_dur_info_stmt(_count)
    _count = _count or 5
    return "select statement_index si,dur from exec_sql_info where proc_id=connection_id() order by dur desc limit " .. _count .. ";"
end

local LD = base.LocalData("db_exec_man",{

    -- 辅助的 sql 语句
    sql_aid = {

        -- 普通
        normal = {
            begin = " set @_esi_stat_index = 0;",
            deal = " set @_esi_stat_index = @_esi_stat_index + 1;",
            finish = " ", -- 啥也不做
        },

        -- 需要统计每条语句性能
        stat_perf = {
            begin = " call exec_sql_begin();",
            deal = " call exec_sql_deal();",
            finish = " call exec_sql_end();",
        },
    },

    -- 缓存分组配置（数组，下标作为 分组 id）：
    --    定义每个分组要处理的 表/存储过程/自定义分类名
    -- 配置原则：写入量大的独立占用分组；写入量小的放在一起共享一个分组
    cache_group_cfg = 
    {
        {"player_asset_log"},               -- 1
        {"nor_ddz_nor_race_player_log"},    -- 2
        {"player_task_log"},                -- 3
        {"match_nor_player_log"},           -- 4
        {"freestyle_race_player_log"},      -- 5
        {"freestyle_race_log"},             -- 6
        {"player_prop_log","player_task"},  -- 7
        {"sp_login","sp_logout"},           -- 8
        {"*"},                              -- 9  默认放到这个分组
    },

    -- 缓存分组：group id => {slow=queue,fast=queue}
    -- group id : cache_group_cfg 的 数组下标
    cache_groups = {},

	-- 根据 cache_group_cfg 计算 名字到分组 id 的映射
	-- group name => group id
    name_group_map = {},

	-- 快/慢队列状态数据: 参见 safe_queue_status
	-- slow/fast => status
    queues_status = {},

	-- 分组状态数据： 参见 safe_group_status
	-- group id => status
    group_status = {},

    -- mysql 连接池
    mysql_pool = basefunc.queue.new(),

    -- 使用中的 mysql 连接数量
    mysql_used_count = 0,

    -- 连接池耗尽次数
    mysql_conn_fail_count = 0,
    
	sql_succ_count = 0,
	sql_error_count = 0,
    sql_empty_count = 0,
    
    db_connect_inited = false,

    --------------
    -- 性能统计

    -- 写入耗时 top 排名： {sql=,dur=}
    slow_write_top = {},
    -- 查询耗时 top 排名
    slow_query_top = {},

    -- 最近 执行/查询数量
    current_write_numb = 0,
    current_query_numb = 0,
    -- 最近记录的时间
    current_seg_time = 0,

    -- 最近 n 个时间段内的执行/查询数量： {time=,numb=}
    write_segments_numb = {},
    query_segments_numb = {},

    -- 等待中的 query
    wait_query_count = 0,
    -- 查询中的 query
    querying_count = 0,

    --------------
    -- 性能参数
    array_sql_count = 3000, -- skynet.getcfg  array_sql_count
    cycle_sql_number = 100, -- skynet.getcfg cycle_sql_number
    
    gain_sql_dur_info_stmt = LF.gen_sql_dur_info_stmt(5),
    stat_sql_query_perf = nil, -- skynet.getcfg stat_sql_query_perf 是否统计 查询的性能 
    stat_sql_write_perf = nil, -- skynet.getcfg stat_sql_write_perf 是否统计 写入的性能 

    stat_sql_top_count = 5, -- skynet.getcfg stat_sql_top_count
    stat_segment_count = 10, -- skynet.getcfg stat_segment_count

    --------------

    test_sql_log_files = {}, -- 测试用的sql 写入文件
-- 1 事务内 出错，导致死锁，解决： 出错时 手动提交事务！

    mysql_conn_last_sql = {}, -- 每个 db 链接最近执行的一条语句（调试用）
})


function LF.create_db_connect(_on_connected,...)
	local _param_count = select("#",...)
	local _param = {...}
	mysql.connect({
		host=skynet.getenv("mysql_host"),
		port=tonumber(skynet.getenv("mysql_port")),
		database=skynet.getenv("mysql_dbname"),
		user=skynet.getenv("mysql_user"),
		password=skynet.getenv("mysql_pwd"),
		max_packet_size = 1024 * 1024,
        on_connect = function(db)

			db:query( [[
				set character_set_client='utf8mb4';
				set character_set_connection='utf8mb4';
                set character_set_results='utf8mb4';
                set @db_conn_time0=unix_timestamp(current_timestamp(6));
            ]])
            
            -- 取得连接 id 
            local ret = db:query("select connection_id() conn_id;")
            db.conn_proc_id = ret[1].conn_id

			_on_connected(db,table.unpack(_param,1,_param_count))
		end
	})
end

function LF.write_sql_record(_file_name,_sql)

    LD.test_sql_log_files[_file_name] = LD.test_sql_log_files[_file_name] or io.open("./logs/" .. _file_name .. ".log","a+")
    LD.test_sql_log_files[_file_name]:write("[[" .. _sql .. "]],\n")

end

function LF.flush_sql_record()
    for _,file in pairs(LD.test_sql_log_files) do
        file:flush()
    end
end


-- 从队列中取出语句，拼成一个 语句的数组
function LF.take_sql_array(_queue,_count)

	local sqls = {}
	local sql_ids = {}
	for i=1,_count do			-- 每次最多合并的行数
		local _data = _queue:pop_front()
		if _data and _data.sql then
			sqls[#sqls + 1] = PUBLIC.safe_sql_semicolon(_data.sql)
			sql_ids[#sql_ids + 1] = _data.sql_id
		else
			break
		end
	end

	return sqls,sql_ids
end


function LF.get_queue_status()
    return LD.queues_status
end

function LF.get_waiting_sql_count()
    local ret = 0
    for _group_id,_group in pairs(LD.cache_groups) do
        for _,_d in pairs(_group) do  -- _name = "slow","fast"
            ret = ret + _d:size()
        end
    end

    return ret
end

-- 得到 队列状态的 信息 文本
function LF.get_queue_status_string(_last_sql)
    -- 每个组的 sql 数量加起来
    local _wait_count = {}
    for _group_id,_group in pairs(LD.cache_groups) do
		for _name,_d in pairs(_group) do  -- _name = "slow","fast"
            _wait_count[_name] = (_wait_count[_name] or 0) + _d:size()
        end
    end

    local strs = {}

    strs[#strs+1] = "    sql_succ count:" .. tostring(LD.sql_succ_count)
    strs[#strs+1] = "    sql_empty count:" .. tostring(LD.sql_empty_count)
    strs[#strs+1] = "    sql_fail count:" .. tostring(LD.sql_error_count)
    for _,_name in ipairs(DATA.sql_queue_names) do   -- _name = "slow","fast"
        if _last_sql then
            strs[#strs+1] = string.format("    %s size:%s|%s",_name,tostring(_wait_count[_name]),
                    (LD.queues_status[_name] and tostring(LD.queues_status[_name].last_sql_stmt) or "<empty>"))
        else
            strs[#strs+1] = string.format("    %s size:%s",_name,tostring(_wait_count[_name]))
        end
	end

	return strs
end

-- 得到分组的 状态 描述信息 文本
function LF.get_group_sql_string(_indent)

    local strs = {}

    local _fmt_str = "%" .. tostring(_indent or 5) .. "s group %2d: slow=%5d, fast%6d"

    for _group_id,_cache in ipairs(LD.cache_groups) do
        strs[#strs + 1] = string.format(_fmt_str,"",_group_id,_cache.slow:size(),_cache.fast:size())
    end
    
    return strs
end

function LF.safe_queue_status(_queue_name)
    local _queue = LD.queues_status[_queue_name]

    if not _queue then
        _queue = {

			-- 最近一个 sql id 用于 生成
            last_sql_id = 0,

            -- 已执行的 连续 sql id 的最小id
            serial_sql_min_id = 0,
            
            -- sql id center 状态数据
            last_report_sql_id = 0,
			
			-- 已执行的 sql id 表：低于 serial_sql_min_id 的都已清掉
			-- id => true
			exec_sql_ids = {},

            -- 出错的 sql id
            fail_sql_ids = {},

            -- 最近执行完的 sql 语句
            last_sql_stmt = nil,
        }

        LD.queues_status[_queue_name] = _queue
    end

    return _queue
end

-- 执行完成 sql 时， 维护 serial_sql_min_id （已执行连续 sql id 的最小值）
function LF.on_sql_id_exec(_queue,_sql_id)
	if _sql_id == _queue.serial_sql_min_id + 1 then -- 刚好 补上 第一个 空位

		-- 越过刚补上的空位
		_sql_id = _sql_id + 1

		-- 找下一个 空位
		while (_queue.exec_sql_ids[_sql_id]) do
			_queue.exec_sql_ids[_sql_id] = nil -- 连续区域，则清除记录
			_sql_id = _sql_id + 1
		end
		
		_queue.serial_sql_min_id = _sql_id - 1 -- 记录 连续的 最小的
	else
		_queue.exec_sql_ids[_sql_id] = true
	end
end

function LF.safe_group_status(_group_id)

    local _group = LD.group_status[_group_id]

    if not _group then
        _group = {

            -- 成功的语句条数、耗时（秒）
            sql_succ_count = 0,
            sql_duration = 0,

            -- 正在使用的 mysql conn id ； nil 表示 不在 execute_cache_queue 函数中
            sql_conn_id = nil,

            -- 正在执行的 sql 语句（合并后）； nil 表示 没执行或执行完毕
            cur_sql = nil
        }

        LD.group_status[_group_id] = _group
    end

    return _group
end


-- 执行/查询完成 sql 时， 维护 sql top 表
-- 返回 加入的位置 或 nil
function LF.push_stat_sql_top(_top_table,_sql,_exec_dur)

    local c = #_top_table

    -- 满了
    if c >= LD.stat_sql_top_count then
        if _top_table[c].dur >= _exec_dur then  -- 小于最后一个，丢弃
            return nil
        else
            -- 丢弃最小的
            _top_table[c] = nil
            c = c - 1
        end
    end

    -- 从后 往前找
    for i=c,0,-1 do
        if not _top_table[i] or _top_table[i].dur >= _exec_dur then
            table.insert(_top_table, i+1,{sql=_sql,dur=_exec_dur})
            return i+1
        end

        i = i - 1
    end

    return nil -- 通常 不可能来这里
end

-- 收集 sql 语句执行时间
function LF.gain_sql_exec_dur(_mysql_conn,_sql_array,_start_index)
    local _data = _mysql_conn:query(LD.gain_sql_dur_info_stmt)
    for _,v in ipairs(_data) do
        if not LF.push_stat_sql_top(LD.slow_write_top,_sql_array[_start_index + v.si - 1],v.dur) then
            break -- 未加入，则 后续的 也不用加入
        end
    end
end

-- 得到当前数据库时间： 为了避免溢出，和 @db_conn_time0 计算差值
function LF.get_db_time(_mysql_conn)
    local _data = _mysql_conn:query("select (unix_timestamp(current_timestamp(6))-@db_conn_time0) ts;")
    return _data[1].ts
end

--[[ 执行缓存的分组：每个时钟到来的时候执行
     _queue 的内容参见 push_sql : {sql_id=,sql=}
--]]
function LF.execute_cache_queue(_group_id,_queue_name,_queue,_mysql_conn,_queue_status)

    _queue_name = tostring(_queue_name)

    local _group_status = LF.safe_group_status(_group_id)

    _group_status.sql_conn_id = _mysql_conn.conn_proc_id

    local _cycle_sql_number = LD.cycle_sql_number
    while not _queue:empty() and _cycle_sql_number >= 0 do

		-- 取出 sql 数组： 每次 取 100
		local _array,_ids = LF.take_sql_array(_queue,LD.array_sql_count)
        if #_array == 0 then
            LD.sql_empty_count = LD.sql_empty_count + 1
			break
        end

        local _time0 = os.clock()

		-- 执行 sql 数组
		local _start_index = 1 -- 从 _array 中开始执行的 语句序号
        local _succ_end_index = 0 -- 成功结束 语句
        while #_array >= _start_index do
            
            local _aid = LD.stat_sql_write_perf and LD.sql_aid.stat_perf or LD.sql_aid.normal

            -- 生成，并执行 sql 
            local ok,ret,fail_index
            local sql_s = {
                _aid.begin,
                table.concat(_array,"\n" .. _aid.deal .. "\n",_start_index),
                _aid.deal,
            }
            if skynet.getcfg("mysql_write_trans") then -- 是否采用事务
                table.insert( sql_s,1,"start transaction;")
                table.insert( sql_s,"commit;")
            end
            if LD.stat_sql_write_perf then
                table.insert( sql_s,_aid.finish)
            end

            local sql = table.concat( sql_s, "\n")
            _group_status.cur_sql = sql
            LD.mysql_conn_last_sql[tostring(_mysql_conn.conn_proc_id)] = sql
            local _t1 = os.clock()
            ret = _mysql_conn:query(sql)
            _group_status.cur_sql = nil

            if( ret.errno ) then 
                local cur_index = _mysql_conn:query("select @_esi_stat_index ssidx;") -- 注意： @_esi_stat_index 在存储过程 exec_sql_xx 中
                ok = false
                fail_index = cur_index[1].ssidx + _start_index
            else
                if skynet.getcfg("log_sql_queue") then
                    print("succ sql queue:",os.clock() - _t1,sql)
                end
                ok = true
            end

            LF.gain_sql_exec_dur(_mysql_conn,_array,_start_index)
                    
            -- 处理执行结果
            if ok then
                _succ_end_index = #_array
            else
                _succ_end_index = fail_index - 1

                LD.sql_error_count = LD.sql_error_count + 1
                
                table.insert(_queue_status.fail_sql_ids,_ids[fail_index])

                -- 提交事务： 出错不会自动提交事务，必须 手动提交，否则 导致死锁
                _mysql_conn:query("commit;")

				-- 记录日志
                PUBLIC.record_sql_error(ret,_array[fail_index],_queue_name,_mysql_conn.conn_proc_id)
                
            end

            -- 处理成功语句 id 报告
            for i=_start_index,_succ_end_index do
                LF.on_sql_id_exec(_queue_status,_ids[i])
            end

            -- 记录最近执行完的 sql
            _queue_status.last_sql_stmt = _array[_succ_end_index]

            _group_status.sql_duration = _group_status.sql_duration + (os.clock() - _time0)
            
            -- 处理成功条数
            local _cur_succ_count = _succ_end_index - _start_index + 1
            LD.sql_succ_count = LD.sql_succ_count + _cur_succ_count
            data_common.inc_write_sql(_cur_succ_count)
            LD.current_write_numb = LD.current_write_numb + _cur_succ_count
            _group_status.sql_succ_count = _group_status.sql_succ_count + _cur_succ_count

            if ok then
                _start_index = #_array + 1
            else
				-- 跳过错误语句，继续执行
				_start_index = fail_index + 1
            end
        end
      
        _cycle_sql_number = _cycle_sql_number - 1
    end
    
    _group_status.sql_conn_id = nil
end

-- 说明： 参见函数名
-- 返回值： false 表示退出协程
function LF.call_execute_cache_group(_group_id,_queue_name,_queue_status)

    local _group = LD.cache_groups[_group_id]

    -- 配置中删除，且 sql 执行完毕，则删除分组，退出协程
    if not LD.cache_group_cfg[_group_id] then

        if _group[_queue_name]:empty() then  -- 队列执行完， 删除
            _group[_queue_name] = nil
            if not next(_group) then
                LD.cache_groups[_group_id] = nil -- 自己是最后一个，则 整个分组删除
            end
            return false
        end
    end

    local _queue = _group[_queue_name]
    if not _queue then
        print("call_execute_cache_group error: queue is nil ",_group_id)
        return false
    end

    if _queue:empty() then
        skynet.sleep(1)
        return true -- 没有要执行的，等下次
    end

    -- 循环 直到  拿到有效的连接
    local _mysql_conn 
    for i=1,10 do -- 尝试次数
        _mysql_conn = LF.pop_mysql_conn()
        if not _mysql_conn then
            LD.mysql_conn_fail_count = LD.mysql_conn_fail_count + 1
            skynet.sleep(10)
            return true -- 连接池耗尽，等下次机会
        end

        if LF.check_using_conn(_mysql_conn)  then
            break
        else
            _mysql_conn = nil -- 无效连接，赋空
        end
    end

    if not _mysql_conn then
        LD.mysql_conn_fail_count = LD.mysql_conn_fail_count + 1
        skynet.sleep(10)
        return true -- 都是错误连接，等下次机会
    end

    local ok,_exec_ret = xpcall(LF.execute_cache_queue,basefunc.error_handle,
        _group_id,
        _queue_name,
        _queue,
        _mysql_conn,
        _queue_status
    )

     -- 归还 sql 资源
    LF.push_mysql_conn(_mysql_conn)

    if not ok then
        print("call execute_cache_queue error:",_group_id,_queue_name,_exec_ret)
        skynet.sleep(500) -- 出错，等久点，避免日志爆炸 
    else
        skynet.sleep(1)
    end

    return true
end

function LF.add_one_cache_group(_group_id)

    if LD.cache_groups[_group_id] then
        print("add_one_cache_group error:",_group_id)
        return
    end

    local _group = {}
    LD.cache_groups[_group_id] = _group

    if not next(DATA.sql_queue_names) then
        error("cannt found 'DATA.sql_queue_names' !")
    end

    for _,_queue_name in ipairs(DATA.sql_queue_names) do
        _group[_queue_name] = basefunc.queue.new()
        skynet.fork(function() 

            -- 循环执行，退出协程则 call_execute_cache_group 返回 false
            while LF.call_execute_cache_group(
                _group_id,
                _queue_name,
                LF.safe_queue_status(_queue_name)) do 

            end
        end)
    end
end

--[[ 
    检测新得 cache_group_cfg 配置，加入新的 cache_groups :
        如果 cache_group_cfg 中有，而 cache_groups 没有，则加入
    注意：无需处理 cache_groups 有 ，而 cache_group_cfg 没有的情况
           协程内部监测到 cache_group_cfg 中不存在，则自行 清除 cache_groups 属于自己的项，并退出
--]]
function LF.check_new_cache_groups_cfg()

    -- 补齐不足的 cache_groups
    for i=1,#LD.cache_group_cfg do
        if not LD.cache_groups[i] then
            LF.add_one_cache_group(i) -- 加入分组（包括 执行 sql 的协程）
        end
    end

    -- 构造 name_group_map
    local _nqm = {}
    for _group_id,_names in ipairs(LD.cache_group_cfg) do
        for _,_name in ipairs(_names) do
            _nqm[_name] = _group_id
        end
    end
    LD.name_group_map = _nqm

    LF.flush_sql_record()

    LF.push_segments_numb()    
end

-- 检查一个连接，如果故障则丢弃：扣除 计数  ，且不归还
function LF.check_using_conn(_sql_conn)
    local ok,ret = xpcall(_sql_conn.query,basefunc.error_handle,_sql_conn,"select 5;")
    if ok then

        if ret.errno then
            print(string.format("check mysql conn error: %s\n",basefunc.tostring( ret )))
            _sql_conn:disconnect() -- 丢弃 出问题的连接
            LD.mysql_used_count = LD.mysql_used_count - 1 -- 未归还，则扣除使用中的数量
            return false
        end

        return true
    else
        
        print(string.format("check db conn error: %s\n",basefunc.tostring( ret )))
        return false
    end
end

-- 检查 sql 池，保持连接数量；定期执行sql，保证不因为闲置而短线
function LF.keep_pool_conn_count()

    -- 先检查现有 连接 有效性
    local _back_id = LD.mysql_pool:back_id() -- 记录尾部位置
    while (LD.mysql_pool:front_id() < _back_id) do
        local _mysql = LF.pop_mysql_conn()
        if (LF.check_using_conn(_mysql)) then
            LF.push_mysql_conn(_mysql) -- 归还正常连接
        end
    end

    -- 保证连接数量
    local _free_min = skynet.getcfgi("mysql_free_min_count",20)
    local _all_max = skynet.getcfgi("mysql_max_count",50)
    local _new_count = _free_min - LD.mysql_pool:size()
    _new_count = math.min(_new_count,_all_max - (LD.mysql_used_count + LD.mysql_pool:size()))
    for i=1,_new_count do
        LF.create_db_connect(function(_mysql)
            LD.mysql_pool:push_back(_mysql)

            if not LD.db_connect_inited and LD.mysql_pool:size() >= _free_min then
                LD.db_connect_inited = true

                -- 清空 性能统计 临时表
                _mysql:query(
[[
    delete from exec_sql_info;
    delete from exec_sql_info_batch;
    delete from exec_sql_info_log;
]])
                
                PUBLIC.on_dbconnected()
            end
        end)       
    end
    
end

function LF.report_last_sql_id()
    
    for _queue_name,_status in pairs(LD.queues_status) do

        if _status.serial_sql_min_id > _status.last_report_sql_id then
            skynet.call(DATA.service_config.sql_id_center,"lua","set_last_id",_queue_name,_status.serial_sql_min_id)
            _status.last_report_sql_id = _status.serial_sql_min_id
        end

        if next(_status.fail_sql_ids) then
            skynet.call(DATA.service_config.sql_id_center,"lua","add_fail_ids",_queue_name,_status.fail_sql_ids)
            _status.fail_sql_ids = {}
        end
    end

end


function LF.refresh_config()
    LD.array_sql_count = skynet.getcfgi("array_sql_count") or 100
    LD.cycle_sql_number = skynet.getcfgi("cycle_sql_number") or 10
    LD.stat_sql_top_count = skynet.getcfgi("stat_sql_top_count") or 5
    LD.gain_sql_dur_info_stmt = LF.gen_sql_dur_info_stmt(LD.stat_sql_top_count)
    LD.stat_sql_query_perf = skynet.getcfg("stat_sql_query_perf")
    LD.stat_sql_write_perf = skynet.getcfg("stat_sql_write_perf")
end

function LF.push_segments_numb()
    local _now = os.time()
    table.insert(LD.write_segments_numb,1,{
        time=_now-LD.current_seg_time,
        numb=LD.current_write_numb,
    })
    table.insert(LD.query_segments_numb,1,{
        time=_now-LD.current_seg_time,
        numb=LD.current_query_numb,
    })

    if #LD.write_segments_numb > LD.stat_segment_count then
        LD.write_segments_numb[#LD.write_segments_numb] = nil
    end
    if #LD.query_segments_numb > LD.stat_segment_count then
        LD.query_segments_numb[#LD.query_segments_numb] = nil
    end

    LD.current_seg_time = _now
    LD.current_write_numb = 0
    LD.current_query_numb = 0

end

function LF.init()

	skynet.timer(10,function() LF.check_new_cache_groups_cfg() end,true)

    -- 连接池管理
    skynet.timer(30,function() LF.keep_pool_conn_count() end,true)

    -- 向 sql_id_center 报告 sql id
    skynet.timer(2,function() LF.report_last_sql_id() end)

    -- 刷新配置
    skynet.timer(2,function() LF.refresh_config() end,true)

    
end

function LF.pop_mysql_conn()

    if LD.mysql_pool:front() then
        LD.mysql_used_count = LD.mysql_used_count + 1
    end

    return LD.mysql_pool:pop_front()
end

function LF.push_mysql_conn(_mysql_conn)

    LD.mysql_used_count = LD.mysql_used_count - 1
    
    LD.mysql_pool:push_back(_mysql_conn)
end

-- 加入 sql
-- 返回语句 id
function LF.push_sql(_queue_name,_sql)

	if skynet.getcfg("record_sql_write_str") then
		LF.write_sql_record("sql_write_str_log",_sql)
	end


    if not LD.cache_groups or not LD.cache_groups[1] then
        print("sql exe error:cache_groups is empty!")
        return nil
    end

    local _info = PUBLIC.get_sql_metadata(_sql)
    db_sql_stat.stat_sql(_sql,_info)

    local _group_id = _info.name and LD.name_group_map[_info.name] or LD.name_group_map["*"]
    local _group = _group_id and LD.cache_groups[_group_id] or LD.cache_groups[#LD.cache_groups]
    if not _group then
        print("sql exe error:cache_group is nil!")
        return nil
    end

    -- 取得该分组下的队列
    local _queue = _group[_queue_name]
    if not _queue then
        print("sql exe error,queue is nil:",_queue_name,_info.name,_group_id)
        return nil
    end

    data_common.inc_push_sql()

	-- 产生 该队列名称下的 id
	local _queue_status = LF.safe_queue_status(_queue_name)
	_queue_status.last_sql_id = _queue_status.last_sql_id + 1
    _queue:push_back({
        sql_id = _queue_status.last_sql_id,
        group_name = _info.name,
        sql = _info.sql,
    })

    return _queue_status.last_sql_id
end

-- 插入到队列
-- 参数 _queue_name ： 所加入的队列 "slow" / "fast"
-- 返回 queue_name + 语句id
function CMD.db_exec(_sql,_queue_name)
    _queue_name = _queue_name or "slow"
	return _queue_name,LF.push_sql(_queue_name,_sql)
end

-- 通用数据 查询
function CMD.db_query(_sql)

    -- ！！！废弃:存储过程内部的 select 无法判断！！
    -- if not string.match(_sql,"^%s*[sS][eE][lL][eE][cC][tT]%s+") then
    --     return {
    --         errno=9999,
    --         sqlstate=9999,
    --         err="data_service CMD.db_query only use 'select ...' sql query!!!"
    --     }
    -- end

	if skynet.getcfg("record_sql_query_str") then
		LF.write_sql_record("sql_query_str_log",_sql)
	end

    LD.wait_query_count = LD.wait_query_count + 1
	local _conn
	while not _conn do
		_conn = LF.pop_mysql_conn()
		if not _conn then
			-- return {errno=9999,err="mysql conn pool is empty!"}
			skynet.sleep(10)
		end
    end
    LD.wait_query_count = LD.wait_query_count - 1

    local ret
    LD.querying_count = LD.querying_count + 1
    if LD.stat_sql_query_perf then -- 统计性能数据

        local t1 = LF.get_db_time(_conn)
        ret = _conn:query(_sql)
        local itop = LF.push_stat_sql_top(LD.slow_query_top,_sql,LF.get_db_time(_conn)-t1)

        -- 数据条数
        if itop then
            LD.slow_query_top[itop].row_count = #ret
        end
    else
        ret = _conn:query(_sql)
    end

    LF.push_mysql_conn(_conn)
    LD.current_query_numb = LD.current_query_numb + 1
    LD.querying_count = LD.querying_count - 1
    
    return ret
end

return LF
--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：测试
-- 使用方法：
--  call data_service exe_file "hotfix/fix_data_queue_write.lua"
-- 

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local mysql = require "skynet.db.mysql"
local base = require "base"
require "data_func"

local basefunc = require "basefunc"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC


local _sql_succ_count = 0
local _sql_error_count = 0
local _sql_empty_count = 0

local _sql_statement_counter = "set @sql_statement_index=@sql_statement_index+1;"
local _sql_statement_counter_pat = "set @sql_statement_index=@sql_statement_index%+1;"


DATA.wait_deal_slow_queue = DATA.wait_deal_slow_queue or basefunc.queue.new()

-- 从队列中取出语句，拼成一个 语句的数组
function PUBLIC.take_sql_array(_queue,_count)
	local sqls = {}
	for i=1,_count do			-- 每次最多合并的行数
		local sql = _queue:pop_front()
		if sql then
			sqls[#sqls + 1] = PUBLIC.safe_sql_semicolon(sql) .. _sql_statement_counter
		else
			break
		end
	end

	return sqls
end

local _last_slow_info = ""

function PUBLIC.exec_queue_sql_impl(_queue_name,_count)
	
	local _q_data = DATA.sql_queues[_queue_name]
	
	if not _q_data.db_mysql then
		error(tostring(_queue_name) .. " queue error:not connect!")
    end

    local _start_time = skynet.now()
    local _exec_count = 0
    local _gen_sql_t = 0
    local _exec_sql_t = 0
    local _queue_count = _q_data.sql_queue:size()
	
    while not _q_data.sql_queue:empty() and _count > 0 do

        -- 取出 sql 数组： 每次 取 
        local _t1 = skynet.now()
        local _array = PUBLIC.take_sql_array(_q_data.sql_queue,math.min(skynet.getcfg_2number("array_sql_count") or 500,_count),_queue_name)
		if #_array == 0 then
			_sql_empty_count = _sql_empty_count + 1
			break
		end

        _count = _count - #_array
        
        _gen_sql_t = _gen_sql_t + (skynet.now() - _t1)

		-- 执行 sql 数组
		local _start_index = 1 -- 从 _array 中开始执行的 语句序号
		while #_array >= _start_index do
            _t1 = skynet.now()
            local ok,ret,fail_index = PUBLIC.exec_sql_array(_q_data.db_mysql,_array,_start_index)
            _exec_sql_t = _exec_sql_t + (skynet.now() - _t1)
			if ok then
                _sql_succ_count = _sql_succ_count + #_array
                _exec_count = _exec_count + #_array
				break
			else
				_sql_error_count = _sql_error_count + 1

				-- 记录日志
				PUBLIC.record_sql_error(ret,_array[fail_index],_queue_name)
				
				-- 跳过错误语句，继续执行
				_start_index = fail_index + 1
			end
		end
    end
    

    if "slow" == _queue_name then
        if _exec_count > 0 then
            _last_slow_info = string.format("gen_t=%s,exe_t=%s,all_t=%s,exec count=%s,queue deal=%d",
                tostring(_gen_sql_t),tostring(_exec_sql_t),
                tostring(skynet.now()-_start_time),tostring(_exec_count),tostring(_queue_count-_q_data.sql_queue:size()))
        end
    end

end

function base.CMD.debug_get_status()
	local task_center_service_cache_num = skynet.call( DATA.service_config.task_center_service , "lua" , "get_cache_data_num" )

	local _ret = {
		"fast queue len:" .. DATA.sql_queue_fast:size(),
		"slow queue len:" .. DATA.sql_queue_slow:size(),
		"task_center_service cache_count:" .. task_center_service_cache_num,
		"succ count:" .. _sql_succ_count,
		"err count:" .. _sql_error_count,
        "empty count:" .. _sql_empty_count,
        "last slow exec info:" .. _last_slow_info,
        "wait temp queue len:" .. DATA.wait_deal_slow_queue:size(),
        "wait temp queue dump count:" .. tostring(DATA.wait_deal_dump_count),
	}

	if DATA.sql_queue_fast:front() then
		_ret[#_ret + 1] = "front fast sql:" .. DATA.sql_queue_fast:front()
	end

	if DATA.sql_queue_slow:front() then
		_ret[#_ret + 1] = "front slow sql:" .. DATA.sql_queue_slow:front()
	end

	if DATA.wait_deal_slow_queue:front() then
		_ret[#_ret + 1] = "front wait sql:" .. DATA.wait_deal_slow_queue:front()
	end

	return _ret
end

DATA.wait_deal_dump_count = 0
DATA.can_stop_wait_deal_dump = false

function base.CMD.set_dump_wait_queue_data_stop(_is_stop)
    DATA.can_stop_wait_deal_dump = _is_stop
end

function base.CMD.dump_wait_queue_data()

    if DATA.wait_deal_dump_writing then
        return "前一次操作正在处理：" .. tostring(DATA.wait_deal_dump_count)
    end

    local file_handle,err = io.open("./wait_deal_slow_queue_dump.lua","a")
        
    if not file_handle then
        return "open file err:" .. tostring(err)
    end

    skynet.fork(function()

        DATA.wait_deal_dump_writing = true

        DATA.wait_deal_dump_count = 0

        file_handle:write("return {\n\t[[")

        local _cache_size = skynet.getcfg_2number("dump_wait_cache_size") or 3000
        local _sleep_size = math.floor(skynet.getcfg_2number("dump_wait_sleep_size") or 1000)

        local _str_cache = {}
        local i = 0
        for v in DATA.wait_deal_slow_queue:values() do

            if DATA.can_stop_wait_deal_dump then
                break
            end

            i = i + 1
            if i % _sleep_size == 0 then
                skynet.sleep(1)
                _sleep_size = math.floor(skynet.getcfg_2number("dump_wait_sleep_size") or 1000)
            end

            _str_cache[#_str_cache + 1] = v

            if #_str_cache >= _cache_size then
                file_handle:write(table.concat(_str_cache,"]],\n\t[["))
                DATA.wait_deal_dump_count = DATA.wait_deal_dump_count + #_str_cache
                _str_cache = {}

                -- 刷新下配置
                _cache_size = skynet.getcfg_2number("dump_wait_cache_size") or 3000
            end
        end

        if #_str_cache > 0 then
            file_handle:write(table.concat(_str_cache,"]],\n\t[["))
            DATA.wait_deal_dump_count = DATA.wait_deal_dump_count + #_str_cache
            _str_cache = {}
        end

        file_handle:write("]]\n}")

        file_handle:close()

        DATA.wait_deal_dump_writing = nil
    end)

    return "开始..."
end

return function()

    -- skynet.timeout(200,function()
    --     DATA.wait_deal_slow_queue:push_back("ddddddfffffffffffaaaaaaaa 1111")
    --     DATA.wait_deal_slow_queue:push_back("ddddddfffffffffffaaaaaaaa 2222")
    --     DATA.wait_deal_slow_queue:push_back("ddddddfffffffffffaaaaaaaa 3333")
    --     DATA.wait_deal_slow_queue:push_back("ddddddfffffffffffaaaaaaaa 44444")
    --     for i=1,500000 do
    --         DATA.wait_deal_slow_queue:push_back("ddddddfffffffffffaaaaaaaa 44444" .. i)
    --     end

    --     DATA.sql_queues.slow.sql_queue:push_back("insert into data_test(f1,f2) values('fff','dsfgwqe')")
    --     DATA.sql_queues.slow.sql_queue:push_back("insert into data_test(f1,f2) values('1234','dsfgwqe')")
    --     DATA.sql_queues.slow.sql_queue:push_back("insert into data_test(f1,f2) values('fqafgq','dsfgwqe')")
    --     DATA.sql_queues.slow.sql_queue:push_back("insert into data_test(f1,f2) values('rqvbasdfqw','dsfgwqe')")
    -- end)

    
    return "完成!"

end
--[[
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09

测试结果说明：
    [选项] 表组合  连接数 单次提交数 独立事务 总数据条数  每秒平均成功数  表
           单纯表    1      1000       ×       10w       819          player_asset_log
           单纯表    1      1500       √       10w       2272         player_asset_log
           单纯表    1      2000       √       10w       6666         player_asset_log
           单纯表    1      5000       √       10w       8333         player_asset_log
           单纯表    1     10000       √       10w       7692         player_asset_log
           单纯表    1     10000       √       50w       5102 (第1次) player_asset_log
           单纯表    1     10000       √       50w       4854 (第2次) player_asset_log  说明：可能此数据量才触发 写盘
           单纯表    1      5000       √       50w       2415         player_asset_log  说明：未清数据
           单纯表    1      5000       √       50w       2824         player_asset_log  说明：已清数据
           单纯表    1      5000       √       50w       4237         player_asset_log  说明：等磁盘空闲执行

           单纯表    2      5000       √       10w       8333         player_asset_log  说明：等磁盘空闲执行
                                                                      player_prop_log
           单纯表    2      5000       √       100w      4524        player_asset_log  说明：等磁盘空闲执行
                                                                      player_prop_log
    ===================================================================================
    -- 优化 mysql 配置
    -----------------------------------------------------------------------------------
    [选项] 表组合  连接数 单次提交数 独立事务 总数据条数  每秒平均成功数  表
           单纯表    2      5000       √       100w      10309        player_asset_log
                                                                      player_prop_log
           单纯表    1      5000       √       100w      7751         player_asset_log
           单纯表    2      10000      √       100w      15873        player_asset_log
                                                                      player_prop_log
           混合      1      10000      √       100w      9433        player_asset_log
                                                                      player_prop_log
           混合      2      10000      √       100w      15384        player_asset_log
                                                                      player_prop_log
           单纯表    2      10000      ×       100w      12500        player_asset_log
                                                                      player_prop_log
           单纯表    1      10000      ×       10w       7692         player_asset_log
           单纯表    1      10000      √       10w       8333         player_asset_log
           单纯表    1      1000       √       10w       10000        player_asset_log
           单纯表    1      1000       ×       10w       8333        player_asset_log


    选项说明：
        表组合-单纯表：一个连接只插入一个表，一个表只在一个连接中插入
        表组合-混合表：一个连接中 ， 插入两个表以上的数据
        表组合-共享表：两个连接访问 可能 同一个表
        独立事务：每次提交一个独立事务。否则  系统自动 每条语句一个事务
--]]

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
require"printfunc"
require "data_func"
local mysql = require "skynet.db.mysql"

local monitor_lib = require "monitor_lib"

require "normal_enum"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("db_exec_man_test",{

    start_time = 0,
    end_time = 0,
    write_count = 0,
    is_complete = false,
    start_index = 0,
})

local LF = base.LocalFunc("db_exec_man_test")

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

-- 得到当前数据库时间： 为了避免溢出，和 @db_conn_time0 计算差值
function LF.get_db_time(_mysql_conn)
    local _data = _mysql_conn:query("select (unix_timestamp(current_timestamp(6))-@db_conn_time0) ts;")
    return _data[1].ts
end

-- 生成测试用的 sql
function LF.gen_test_sqls(_count)

    LD.start_index = LD.start_index or 0

    local _sqls = {
        player_asset_log = {},
        player_prop_log = {},
    }

    for i=LD.start_index,LD.start_index + _count - 1 do

        -- player_asset_log
        local _pid = '11' .. (i % 100)
        local _sql = PUBLIC.gen_insert_sql("player_asset_log",{
            id = _pid,
            asset_type = "asset_type_" .. math.random(3243,762583),
            change_value = math.random(3243,762583),
            change_type = "change_type" .. math.random(3243,762583),
            change_id = "change_id" .. math.random(3243,762583),
            current = math.random(3243,762583),
            sync_seq = math.random(3243,762583),
            change_way = "change_way" .. math.random(3243,762583),
            change_way_id = "change_way_id" .. math.random(3243,762583),
        })

        table.insert(_sqls.player_asset_log,_sql)
        -- if i % 2 == 0 then
        --     table.insert(_sqls.player_asset_log,_sql)
        -- else
        --     table.insert(_sqls.player_prop_log,_sql)
        -- end

        -- player_prop_log
        _sql = PUBLIC.gen_insert_sql("player_prop_log",{
            id = _pid,
            prop_type = "prop_type" .. math.random(3243,762583),
            change_value = math.random(3243,762583),
            change_type = "change_type" .. math.random(3243,762583),
            change_id = "change_id" .. math.random(3243,762583),
            current = math.random(3243,762583),
            shop_gold_sync_seq = math.random(3243,762583),
            change_way = "change_way" .. math.random(3243,762583),
            change_way_id = "change_way_id" .. math.random(3243,762583),
        })
        table.insert(_sqls.player_prop_log,_sql)
        -- if i % 2 == 0 then
        --     table.insert(_sqls.player_asset_log,_sql)
        -- else
        --     table.insert(_sqls.player_prop_log,_sql)
        -- end

    end

    LD.start_index = LD.start_index + _count

    return _sqls
end


-- 插入到正式队列
function LF.real_sql_test(_count)
    skynet.timeout(10,function()
        local sqls = LF.gen_test_sqls(_count)
        for i=1,_count do
            if sqls.player_asset_log[i] then
                CMD.db_exec(sqls.player_asset_log[i],math.random(100) < 30 and "fast" or "slow")
            end
            if sqls.player_prop_log[i] then
                CMD.db_exec(sqls.player_prop_log[i],math.random(100) < 30 and "fast" or "slow")
            end
        end
    end)
end

-- 单链接插入
function LF.single_test1(_count)

    local _runing_count = 0
    local function on_exec_end()
        if not LD.is_complete and _runing_count < 1 then
            LD.is_complete = true
            LD.end_time = os.time()

            print("========== 所有 sql write 测试执行完毕 ==============")
        end
    end

    local _is_error = false

    -- 取n条，生成sql
    local function get_sql_str(_sqls,_count)
        if _count == 1 then
            local _s = _sqls[#_sqls]
            _sqls[#_sqls] = nil
            return _s,1
        end

        --local _ret = {"start transaction;"}
        local _ret = {}
        for i=1,_count do
            _ret[#_ret + 1] = _sqls[#_sqls]
            _sqls[#_sqls] = nil
        end
        --_ret[#_ret + 1] = "commit;"

        return table.concat(_ret,"\n") , #_ret -- 2
    end

    local function exec_sqls(_db_conn,_sqls)
        skynet.fork(function()
            _runing_count = _runing_count + 1
            while _sqls[1] do
                if _is_error then
                    return
                end

                local _sql,_count = get_sql_str(_sqls,1000)

                local ret = _db_conn:query(_sql)
                if ret.errno then
                    error(basefunc.tostring(ret))
                end
                LD.write_count = LD.write_count + _count
            end

            _runing_count = _runing_count - 1
            on_exec_end()
        end)
    end

    local sqls = LF.gen_test_sqls(_count)

    LD.start_time = os.time() -- LF.get_db_time(_db_conn)
    LD.write_count = 0
    LD.is_complete = false


    LF.create_db_connect(exec_sqls,sqls.player_asset_log)
    --LF.create_db_connect(exec_sqls,sqls.player_prop_log)

end

function LF.get_profit()

    local _time
    if LD.is_complete then
        _time = LD.end_time - LD.start_time
    else
        _time = os.time() - LD.start_time
    end

    if _time < 1 then
        return {write_count=LD.write_count,time="小于1秒"}
    end

    return {
        time=_time,
        write_count = LD.write_count,
        count_per_sec = LD.write_count/_time,
        is_complete = LD.is_complete,
    }
end

return LF
--
-- Created by lyx
-- User: hare
-- Date: 2018/6/2
-- Time: 20:06
-- 说明：通用函数 或 命令
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
require "data_func"
require"printfunc"

local monitor_lib = require "monitor_lib"

require "normal_enum"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("data_common",{

    -- sql 数量
    last_sql_stat_time = os.time(),
	sql_write_count = 0,
	sql_push_count = 0,

    -- 上次统计总金币量（用于 金币增量统计）
    total_jingbi_last = nil, -- nil 表示未初始化
})

local LF = base.LocalFunc("data_common")

function LF.init()

	skynet.timer(30,function() LF.update_stat_sql_count() end)
    
    skynet.timer(60,function() LF.refresh_total_jingbi() end)
end

function LF.update_stat_sql_count()

    local _diff_t = math.max(1,os.time() - LD.last_sql_stat_time)
    LD.last_sql_stat_time = os.time()

    monitor_lib.add_data("write_sql_count",LD.sql_write_count/_diff_t)
    monitor_lib.add_data("push_sql_count",LD.sql_push_count/_diff_t)

    LD.sql_write_count = 0
    LD.sql_push_count = 0
end

function LF.refresh_total_jingbi()
    
    local ret = PUBLIC.db_query("select sum(jing_bi) jingbi_sum from player_asset where id like '10%'")
    
    if LD.total_jingbi_last then
        monitor_lib.add_data("total_jingbi_change",ret[1].jingbi_sum-LD.total_jingbi_last)
    end

    LD.total_jingbi_last = ret[1].jingbi_sum
    monitor_lib.add_data("total_jingbi_sum",LD.total_jingbi_last)
end

function LF.inc_push_sql(_count) 
    LD.sql_push_count = LD.sql_push_count + (_count or 1)
end
                             
function LF.inc_write_sql(_count) 
    LD.sql_write_count = LD.sql_write_count + (_count or 1)
end

function CMD.get_system_variant(_name)
    return DATA.system_variant[_name]
end

function CMD.set_system_variant(_name,_value)

    if type(DATA.system_variant[_name]) == "number" then
        DATA.system_variant[_name] = tonumber(_value)
    else
        DATA.system_variant[_name] = _value
    end
end

return LF

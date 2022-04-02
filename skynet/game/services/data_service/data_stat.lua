--
-- Created by lyx
-- User: hare
-- Date: 2018/6/2
-- Time: 20:06
-- 说明：数据统计
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

local LD = base.LocalData("data_stat",{

    -- player_asset_stat 表的缓存： player id => 行数据
    asset_stata = {}

})

local LF = base.LocalFunc("data_stat")

function LF.init()
    
    skynet.timer(5,function() LF.write_stat_data() end)

end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
function LF.write_stat_data()
    for k,v in pairs(LD.asset_stata) do
        PUBLIC.db_exec(PUBLIC.safe_insert_sql("player_asset_stat",v,{"dayid","id"},v))
    end

    LD.asset_stata = {}
end

function LF.get_dayid()
    return skynet.get_day_index(nil,14400)
end

function CMD.add_asset_stat(_player_id,_name,_value)
    local _d = LD.asset_stata[_player_id] or {id = _player_id,dayid=LF.get_dayid()}
    LD.asset_stata[_player_id] = _d

    _d[_name] = (_d[_name] or 0) + _value
end


return LF

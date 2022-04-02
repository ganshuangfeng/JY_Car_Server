--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：活动道具结束后要回收和重置数据
--[[
	服务器启动后

	这里会每5分钟检查一次

	获取道具清理配置，如果当时的时间 在活动时间之外 那么就进行数据库执行 清理状态和门票

	即 晚于 end_time

]]

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"

require"printfunc"
require "normal_enum"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = {}

DATA.prop_clear_reset = PROTECT

PROTECT.reset_record = {}

PROTECT.update_lock = false
function PROTECT.clear_update()
    if PROTECT.update_lock then
        return
    end
    PROTECT.update_lock = true
    -- 获取配置
    local cfg = nodefunc.get_global_config("prop_clear_server")
    local ct = os.time()
    if next(cfg) then
        local clear_prop = ""
        for name,_ in pairs(cfg) do
            PROTECT.reset_record[name] = PROTECT.reset_record[name] or {}
            if next(cfg[name]) and name == "player_prop" then
                for k,v in pairs(cfg[name]) do
                    if ct > v.recycle_time and not PROTECT.reset_record[name][v.id] then
                        local _sql = "SELECT id player_id,prop_count num FROM player_prop WHERE prop_type = '" .. v.prop_type .. "' AND prop_count > 0 AND id NOT LIKE 'robot%';"
                        local pd = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)

                        --发给所有玩家
                        for i,d in ipairs(pd) do
                            skynet.send(DATA.service_config.data_service,"lua","change_asset_and_sendMsg",
                                                d.player_id,v.prop_type,
												-d.num or 0,"prop_clear_reset",0)
                            skynet.sleep(1)
                        end
                        clear_prop = v.prop_type .. "&"
                        PROTECT.reset_record[name][v.id] = true
                    end
                end
            elseif next(cfg[name]) and name == "player_ext_status" then
                for k,v in pairs(cfg[name]) do
                    if ct > v.recycle_time and not PROTECT.reset_record[name][v.id] then
                        local _sql = "SELECT player_id,type FROM player_ext_status WHERE type = '" .. v.type .. "';"
                        local pd = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)

                        --发给所有玩家
                        for i,d in ipairs(pd) do
                            skynet.send(DATA.service_config.data_service,"lua","clear_player_ext_data_in_memory", d.player_id, v.type)
                            skynet.sleep(1)
                        end
                        clear_prop = v.type .. "&"
                        PROTECT.reset_record[name][v.id] = true
                        _sql = "DELETE FROM player_ext_status WHERE type = '" .. v.type .. "';"
                        skynet.send(DATA.service_config.data_service,"lua","db_exec",_sql)
                    end
                end
            end
        end
        print( "prop_clear_reset_finish : " .. clear_prop )
    end
    PROTECT.update_lock = false
end

function PROTECT.init()

    -- 延迟等待一下
	skynet.timeout(200,function ()
        skynet.fork(function()
            while true do
                PROTECT.clear_update()
                skynet.sleep(100*300)
            end
        end)
	end)
end

return PROTECT
--
-- Created by lyx
-- User: hare
-- Date: 2018/6/2
-- Time: 20:06
-- 说明：玩家的支付通道配置
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
require "data_func"
require"printfunc"

local monitor_lib = require "monitor_lib"

require "normal_enum"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("player_pay_channel",{

    -- 玩家 支付通道信息： player id => row
    player_channel_config = {},
})

local LF = base.LocalFunc("player_pay_channel")

function LF.init()
    
    local _sql = "select * from player_extend_data where data_class = 'channel_config'"
    local ret = PUBLIC.query_data(_sql)   --skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)  -- 
    if( ret.errno ) then
        error(string.format("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
    end

    for _,v in ipairs(ret) do
        v._data = cjson.decode(v.text_value)
        LD.player_channel_config[v.player_id] = v
    end

end

function CMD.set_player_pay_channels(_player_id,_channels)
    if _channels and next(_channels) then
        LD.player_channel_config[_player_id] = {
            player_id = _player_id,
            data_class = "channel_config",
            text_value = cjson.encode(_channels),
            _data = _channels,
        }

        local _sql = PUBLIC.safe_insert_sql("player_extend_data",LD.player_channel_config[_player_id],{"player_id","data_class"})
        PUBLIC.db_exec(_sql)
    else
        LD.player_channel_config[_player_id] = nil
        PUBLIC.db_exec_va("delete from player_extend_data where player_id = %s;",_player_id)
    end
end
                             
function LF.get_player_pay_channels(_player_id)
    return LD.player_channel_config[_player_id]
end

-- 如果 _player_id 为 nil ，则返回所有
function CMD.get_player_pay_channels(_player_id)
    if _player_id then
        return {
            [_player_id] = LD.player_channel_config[_player_id]
         }
    else 
        return LD.player_channel_config
    end
    
end

return LF

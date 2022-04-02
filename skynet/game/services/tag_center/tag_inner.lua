--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 内部标签数据
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "client.crypt"
-- crypt.hmac64_md5
require "data_func"

local md5 = require "md5"
-- md5.hmacmd5

require "normal_enum"
require "printfunc"

require "common_data_manager_lib"



local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- 标签计算函数（包括类型，类型和 标签 不能重名 ）
PUBLIC.TAG_FUNC = PUBLIC.TAG_FUNC or {}


local LD = base.LocalData("tag_inner",{

    -- 内部标签类型
	tag_types = {},

    -- 内部所有标签
    tag_tags = {},

    last_config_time = 0,
    last_vip_max = 0,
})

local LF = base.LocalFunc("tag_inner")

function LF.refresh_tag_configs()

    --print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx tag inner refresh_tag_configs")

    local _cfg,_last_time = nodefunc.get_global_config("share_invite_config")
    local _vip_max = skynet.getcfg("vip_level_max") or 12

    -- 没改变 则不用更新
    if _last_time == LD.last_config_time and LD.last_vip_max == _vip_max then
        return
    end

    LD.tag_types = 
    {
        type_platform = {},
        type_market_channel = {},
        type_viplevel = {},
        --type2_viplevel = {},
    }
    --print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx tag inner refresh_tag_configs 222:",basefunc.tostring(LD.tag_types))
    LD.tag_tags = {}

    for v,_ in pairs(_cfg.all_platform) do
        table.insert(LD.tag_types.type_platform,"tag_plat_" .. v)
        LD.tag_tags["tag_plat_" .. v] = {type="type_platform"}

        -- 特殊标签：  是否在某个平台拥有账号
        LD.tag_tags["tag_plat_own_" .. v] = {
            tag_func=function(_player_id)
                return PUBLIC.tag_func_plat_own(v,_player_id)
            end
        }
    end
    for v,_ in pairs(_cfg.all_market_channel) do
        table.insert(LD.tag_types.type_market_channel,"tag_chan_" .. v)
        LD.tag_tags["tag_chan_" .. v] = {type="type_market_channel"}
    end
    for i=0,_vip_max do
        table.insert(LD.tag_types.type_viplevel,"tag_vip_" .. i)
        LD.tag_tags["tag_vip_" .. i] = {type="type_viplevel"}
    end    

    -- 精确 匹配的 VIP
    -- for i=0,_vip_max do
    --     table.insert(LD.tag_types.type_viplevel,"tag2_vip_" .. i)
    --     LD.tag_tags["tag2_vip_" .. i] = {type="type2_viplevel"}
    -- end    

    LD.last_vip_max = _vip_max
end

function LF.init()

    skynet.timer(5,function() LF.refresh_tag_configs() end,true)
    
end

-- 得到所有 内部标签类型： type => {tag1,tag2,...}
function PUBLIC.get_inner_tag_types()
    return LD.tag_types
end

-- 得到所有 内部标签： tag => {type=}
function PUBLIC.get_inner_tags()
	return LD.tag_tags
end

----------------------
-- 内部标签 函数。
-- 说明： 如果提供了 类型 函数，则不会再调用 标签函数

function PUBLIC.inner_tag_func(_player_id,_tag)
    local _d = LD.tag_tags[_tag]
    if _d and _d.tag_func then
        return _d.tag_func(_player_id)
    else
        print("PUBLIC.inner_tag_func error,not inner tag or not tag_func:",_tag)
    end
end

-- 特殊标签：是否在相应的平台有账号
function PUBLIC.tag_func_plat_own(_platform,_player_id)

    local _pid = skynet.call(DATA.service_config.verify_service,"lua","player_own_platform",_player_id,_platform)
    if _pid then
        return true
    else
        return false
    end
end

function PUBLIC.TAG_FUNC.type_platform(_player_id)
    --print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx calc type_platform 000:",_player_id)
    local _pt = skynet.call(DATA.service_config.verify_service,"lua","get_platform_by_id",_player_id)
    --print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx calc type_platform:",_player_id,_pt)
    if _pt and _pt ~= "" then
        return "tag_plat_" .. _pt
    else
        return nil
    end
end

function PUBLIC.TAG_FUNC.type_market_channel(_player_id)
    --print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx calc type_market_channel 000:","tag_debug",_player_id)
    local _mt = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register","market_channel")
    --print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx calc type_market_channel:",_player_id,_pt)
    if _mt and _mt ~= "" then
        return "tag_chan_" .. _mt
    else
        return nil
    end
end

function PUBLIC.TAG_FUNC.type_viplevel(_player_id)
    
    local _info = nil

    return "tag_vip_" .. (_info and tonumber(_info.vip_level ) or 0)
end

-- function PUBLIC.TAG_FUNC.type2_viplevel(_player_id)
    
--     local _info = skynet.call( DATA.service_config.new_vip_center_service , "lua" , "query_player_vip_base_info" , _player_id )

--     return "tag2_vip_" .. (_info and tonumber(_info.vip_level ) or 0)
-- end

return LF
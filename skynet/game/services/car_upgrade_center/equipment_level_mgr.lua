--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 装备升级管理器
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

local upcfg_trans_lib = require "upgrade.upcfg_trans_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("equipment_level_mgr",{

    -- 升级配置： 
    --[[
        equipment id => {

            main = {own_type=, quality=,},

            exp_rule = { -- 数组
                {
                    level=n,
                    exp=,
                },
                。。。
            }

            spend = { -- 数组
                {
                    level=n,
                    spend={jing_bi=,...},
                },
                。。。
            },

            base_change = { -- 数组
                {
                    level=n,
                    base_change={jing_bi=,...},
                },
                。。。
            },

            skill = { -- 数组
                {
                    level=n,
                    skill={
                        skill_type=>{type_id=,change_key => change_value}
                    },
                },
                。。。
            },
        }
    --]]
    upgrade_config = {},

    -- 缓存
    upgrade_base_change_cache = {},
    upgrade_spend_cache = {},
    upgrade_skill_cache = {},
    upgrade_exp_rule_cache = {},
})

local LF = base.LocalFunc("equipment_level_mgr")

function LF.init()
    nodefunc.query_global_config("drive_game_equipment_server",basefunc.hotfunc(LF,"refresh_config"))
end

function LF.refresh_config(_config)

    local _exp_rule = upcfg_trans_lib.trans_equipment_exp_rule_cfg(_config.level_exp_rule)

    -- 消耗 基础查找表: base spend id => {jing_bi=,...}
    local _base_spends = upcfg_trans_lib.trans_base_spend_cfg(_config.spend)

    -- spend id => { {level=,spend={jing_bi=,} }, ...}
    local _spends = upcfg_trans_lib.trans_level_spend_cfg(_config.level_spend_rule,_base_spends)

    -- base_change id => { {level=,base_change={hp=,at=,sp=,} },...}
    local _base_change = upcfg_trans_lib.trans_base_change_cfg(_config.base_change_rule)

    -- rule id => { { level=n, skill={ skill_type=>{type_id=,change_key => change_value} },}, ...}
    local _skill = upcfg_trans_lib.trans_skill_change_cfg(_config.level_skill_change)

    -- equipment id => {spend=,base_change=,skill=}
    local _tmp = {}
    for _,v in pairs(_config.main) do
        _tmp[v.id] = {
            main=v,
            exp_rule = v.level_exp_rule and _exp_rule[v.level_exp_rule],
            spend = v.level_spend_rule and _spends[v.level_spend_rule],
            base_change = v.base_change_rule and _base_change[v.base_change_rule],
            skill = v.level_skill_change and _skill[v.level_skill_change],
        }
    end

    LD.upgrade_config = _tmp
    LD.upgrade_base_change_cache = {}
    LD.upgrade_spend_cache = {}
    LD.upgrade_skill_cache = {}
    LD.upgrade_exp_rule_cache = {}
    
end

-- 得到装备 升级到相应等级 需要的经验值
-- 返回： 经验值 
function CMD.get_equipment_level_exp(_equipment_id,_level)
    local _d = LD.upgrade_config[_equipment_id]
    if not _d then
        return nil
    end

    local function _cb() 
        return upcfg_trans_lib.calc_equipment_level_exp(_d.exp_rule,_level) 
    end
    return basefunc.safe_keys_cb(LD.upgrade_exp_rule_cache,_cb,_equipment_id,_level)

end

function LF.get_equipment_cfg(_eqpt_id)
    return LD.upgrade_config[_eqpt_id]
end

-- 得到车在相应等级 累计消耗的财富
--[[
    返回： 
    {
        spend={jing_bi=,...},  -- 从下一级升级到当前 需要的消耗
        spend_sum={jing_bi=,...},  --  升级到当前等级 累计需要的消耗（相对 等级 1）
    }
--]]
function CMD.get_equipment_level_spend(_equipment_id,_level)
    local _d = LD.upgrade_config[_equipment_id]
    if not _d then
        return nil
    end

    local function _cb() 
        return upcfg_trans_lib.calc_up_spend(_d.spend,_level) 
    end
    return basefunc.safe_keys_cb(LD.upgrade_spend_cache,_cb,_equipment_id,_level)

end

-- 得到车在相应等级 累计增加的参数
--[[
    返回： 
    {
        base_change={hp=,...}  -- 从下一级升级到当前 增加的基本参数
        base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
    }
--]]
function CMD.get_equipment_level_base_change(_equipment_id,_level)
    local _d = LD.upgrade_config[_equipment_id]
    if not _d then
        return nil
    end

    local function _cb() 
        return upcfg_trans_lib.calc_level_change(_d.base_change,_level) 
    end
    return basefunc.safe_keys_cb(LD.upgrade_base_change_cache,_cb,_equipment_id,_level)

end



-- 得到装备在相应等级 得到的技能
--[[
    返回： 
    {
           skill = {skill_type=>{type_id=,change_data={change_key => change_value}}},    -- 当前等级的配置
           skill_sum={skill_type=>{type_id=,change_data={change_key => change_value}}},  -- 当前等级 及 之前等级的 累积效果
    }
--]]
function CMD.get_equipment_level_skill_change(_equipment_id,_level)
    local _d = LD.upgrade_config[_equipment_id]
    if not _d then
        return nil
    end

    local function _cb() 
        return upcfg_trans_lib.calc_skill_change(_d.skill,_level) 
    end
    return basefunc.safe_keys_cb(LD.upgrade_skill_cache,_cb,_equipment_id,_level)    
end


return LF
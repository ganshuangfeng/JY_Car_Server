--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 装备升星管理器
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

local LD = base.LocalData("equipment_star_mgr",{

    -- 升级配置： 
    --[[
        equipment id => {

            star_rule = { -- 数组
                {star=,max_level=,equip_need_lv=},
            }

            spend = { -- 数组
                {
                    star=n,
                    spend={jing_bi=,...},
                },
                。。。
            },

            skill = { -- 数组
                {
                    star=n,
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
    upgrade_spend_cache = {},
    upgrade_skill_cache = {},
})

local LF = base.LocalFunc("equipment_star_mgr")

function LF.init()
    nodefunc.query_global_config("drive_game_equipment_server",basefunc.hotfunc(LF,"refresh_config"))
end

function LF.refresh_config(_config)

    -- rule 表 内容： rule id => 数组：{star=,max_level=,equip_need_lv=}
    local _star_rules = {}
    for _,v in ipairs(_config.star_rule) do 
        local _d = basefunc.safe_keys(_star_rules,nil,v.id)
        table.insert(_d,basefunc.deepcopy(v))
    end

    -- 消耗 基础查找表: base spend id => {jing_bi=,...}
    local _base_spends = upcfg_trans_lib.trans_base_spend_cfg(_config.spend)

    -- rule id => { {star=,spend={jing_bi=,} }, ...}
    local _spends = upcfg_trans_lib.trans_level_spend_cfg(_config.star_rule,_base_spends,"star")

    -- rule id => { { star=n, skill={ skill_type=>{type_id=,change_key => change_value} },}, ...}
    local _skill = upcfg_trans_lib.trans_skill_change_cfg(_config.star_skill_change,"star")

    -- equipment id => {spend=,base_change=,skill=}
    local _tmp = {}
    for _,v in pairs(_config.main) do
        _tmp[v.id] = {
            ---- change by wss 之前没得这行
            main=v,
            star_rule = v.star_rule and _star_rules[v.star_rule],
            spend = v.star_rule and _spends[v.star_rule],
            skill = v.star_skill_change and _skill[v.star_skill_change],
        }
    end

    LD.upgrade_config = _tmp

    LD.upgrade_spend_cache = {}
    LD.upgrade_skill_cache = {}
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
    或 nil,code
--]]
function CMD.get_equipment_star_spend(_equipment_id,_star)
    local _d = LD.upgrade_config[_equipment_id]
    if not _d then
        return nil,6405
    end

    local function _cb() 
        return upcfg_trans_lib.calc_up_spend(_d.spend,_star,"star") 
    end
    return basefunc.safe_keys_cb(LD.upgrade_spend_cache,_cb,_equipment_id,_star)

end


-- 得到装备在相应等级 得到的技能
--[[
    返回： 
    {
           skill = {skill_type=>{type_id=,change_key => change_value}},    -- 当前等级的配置
           skill_sum={skill_type=>{type_id=,change_key => change_value}},  -- 当前等级 及 之前等级的 累积效果
    }
--]]
function CMD.get_equipment_star_skill_change(_equipment_id,_star)
    local _d = LD.upgrade_config[_equipment_id]
    if not _d then
        return nil
    end

    local function _cb() 
        return upcfg_trans_lib.calc_skill_change(_d.skill,_star,"star") 
    end
    return basefunc.safe_keys_cb(LD.upgrade_skill_cache,_cb,_equipment_id,_star)    
end


return LF
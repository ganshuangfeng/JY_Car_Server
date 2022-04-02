--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 配置读取 函数库
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


local LD = base.LocalData("upcfg_trans_lib",{

    -- 拷贝数值时，要排除的字段：  name => true
    value_excl_fields = {
        id=true,
        no=true,
        level=true,
    },
})


local LF = base.LocalFunc("upcfg_trans_lib")



-- 转换 装备等级 的 exp_rule 配置为 rule id => { {level=,exp=},...}
function LF.trans_equipment_exp_rule_cfg(_cfg)

    local _base_change = {}
    for _,v in ipairs(_cfg) do
        local _bc = _base_change[v.id] or {}
        _base_change[v.id] = _bc
        
        table.insert(_bc,{
            level = v.level,
            exp = v.exp,
        })
    end

    return _base_change
end

--[[
    得到装备等级 需要的经验值， 没找到 配置 返回 nil
--]]
function LF.calc_equipment_level_exp(_cfg,_level)

    if not _cfg then
        return nil
    end
    local _last_cfg_level = 0
    local _ret = 0
    for _,v in ipairs(_cfg) do

        if _level <= v.level then
            return _ret + v.exp * (_level - _last_cfg_level)
        else
            _ret = _ret + v.exp * (v.level - _last_cfg_level)
        end

        _last_cfg_level = v.level
    end

    return nil

end

-- 转换基础 spend 查找表： base spend id => {jing_bi=,...}
function LF.trans_base_spend_cfg(_cfg)
    local _ret = {}
    for _,v in pairs(_cfg) do
        _ret[v.id] = basefunc.merge(v,nil,nil,LD.value_excl_fields)
    end

    return _ret
end


-- 转换等级 spend 配置为映射： spend id => { {level=,spend={jing_bi=,...} }, ...}
function LF.trans_level_spend_cfg(_cfg,_base_spends,_level_field)

    _level_field = _level_field or "level"

    local _spends = {}

    for _,v in ipairs(_cfg) do

        local _sp = _spends[v.id] or {}
        _spends[v.id] = _sp

        local _level = _sp[#_sp]
        if not _level or _level[_level_field] ~= v[_level_field] then
            table.insert(_sp,{
                [_level_field] = v[_level_field],
                spend = basefunc.copy(_base_spends[v.spend]),
            })
        else
            _level.spend = basefunc.copy(_base_spends[v.spend]) -- 覆盖
        end
    end
    
    return _spends
end


-- 转换 等级 的 base change 配置为 base_change id => { {level=,base_change={hp=,at=,sp=,} },...}
function LF.trans_base_change_cfg(_cfg)

    local _base_change = {}
    for _,v in ipairs(_cfg) do
        local _bc = _base_change[v.id] or {}
        _base_change[v.id] = _bc
        
        table.insert(_bc,{
            level = v.level,
            base_change = basefunc.merge(v,nil,nil,LD.value_excl_fields)
        })
    end

    return _base_change
end

--[[
    得到等级配置 及 相对基础值的累积效果
    返回：
        {
            base_change={hp=,...}  -- 从下一级升级到当前 增加的参数
            base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
        }
--]]
function LF.calc_level_change(_cfg,_level)

    if not _cfg then
        return {}
    end

    local _base_change    -- 参数增加量
    local _base_change_sum = {}   -- 参数总增加量
    --local _last_cfg_level = 1
    local _last_cfg_level = 0
    for _,v in ipairs(_cfg) do

        local _cur_level = v.level
        if _level <= v.level then  -- 到 _level 则停止
            _cur_level = _level
        end

        if type(v.base_change) == "table" then
            for k,v2 in pairs(v.base_change) do -- 累加升级过程 中的增量
                _base_change_sum[k] = (_base_change_sum[k] or 0) + (_cur_level - _last_cfg_level) * v2  -- 注意，配置中值的含义： 升级到当前级别 增加的数值
            end
        end

        _last_cfg_level = _cur_level

        if _level <= v.level then
            _base_change = v.base_change
            break
        end
    end

    return {
        base_change = _base_change,
        base_change_sum = _base_change_sum
    }

end


--[[
    得到等级的消耗配置 及 累积消耗
    返回：
        {
            spend={jing_bi=,...},  -- 从下一级升级到当前 需要的消耗
            spend_sum={jing_bi=,...},  --  升级到当前等级 累计需要的消耗（相对 等级 1）
        }
--]]
function LF.calc_up_spend(_cfg,_level,_level_field)

    if not _cfg then
        return {}
    end

    _level_field = _level_field or "level"

    local _spend_sum = {}   -- 参数总增加量
    local _spend
    --local _last_cfg_level = _level_field == "star" and 0 or 1 -- 升星级 从 0 开始
    local _last_cfg_level = 0
    for _,v in ipairs(_cfg) do

        local _cur_level = v[_level_field]
        if _level <= v[_level_field] then  -- 到 _level 则停止
            _cur_level = _level
        end

        if type(v.spend) == "table" then
            for k,v2 in pairs(v.spend) do -- 累加升级过程 中的增量
                _spend_sum[k] = (_spend_sum[k] or 0) + (_cur_level - _last_cfg_level) * v2  -- 注意，配置中值的含义： 升级到当前级别 增加的数值
            end
        end

        _last_cfg_level = _cur_level
        
        if _level <= v[_level_field] then
            _spend = v.spend
            break
        end
    end

    return {
        spend = _spend,
        spend_sum = _spend_sum,
    }

end

--[[
    转换 技能 升级配置序列 的格式
    返回：
        rule id => {
            {
                level=n,
                skill={
                    skill_type=>{type_id=,change_data={change_key => change_value} }
                },
            },
            。。。数组
        }
--]]
function LF.trans_skill_change_cfg(_cfg,_level_field)

    if not _cfg then
        return {}
    end

    _level_field = _level_field or "level"

    local _ret = {}

    local function _cb()
        return {}
    end
    --dump(_cfg , "xxxx---------------trans_skill_change_cfg:")
    for _,v in ipairs(_cfg) do
        local _d = basefunc.safe_keys_cb(_ret,_cb,v.id)

        local _level = _d[#_d]
        if not _level or _level[_level_field] ~= v[_level_field] then
            table.insert(_d,{
                [_level_field] = v[_level_field],
                skill = v.skill_type and "" ~= basefunc.string.trim(v.skill_type) and {
                    [v.skill_type]={
                        type_id=v.type_id,
                        change_data = v.change_key and "" ~= basefunc.string.trim(v.change_key) and {[v.change_key]=v.change_value} or {},
                    }
                } or {},
            })
        else
            if v.skill_type and "" ~= basefunc.string.trim(v.skill_type) then
                local _skill = _level.skill[v.skill_type]
                if _skill then
                    if _skill.type_id ~= v.type_id then
                        error(string.format("%s skill change config error,skill_type'type_id not match:%s",_level_field,basefunc.tostring(v)))
                    end

                    if v.change_key then
                        _skill.change_data[v.change_key] = v.change_data.change_value
                    end
                else
                    _level.skill[v.skill_type] = {
                        type_id=v.type_id,
                        change_data = v.change_key and {[v.change_key]=v.change_value} or {} ,
                    }
                end
            end
        end
    end

    return _ret
end


--[[
    在技能 _skill_dest 的基础上， 加上 _skill_src
    ★ 特别注意 ★ ： 此函数会改变 _skill_dest 的值
    skill数据结构
        {
            skill_type=>{type_id=,change_data={change_key => change_value} }
        }
--]]
function LF.skill_change_add(_skill_src,_skill_dest,_multi)

    if not _skill_src then
        return _skill_dest
    end

    _multi = _multi or 1

    _skill_dest = _skill_dest or {}
    for _skey,_d in pairs(_skill_src) do
        local _old = _skill_dest[_skey]
        if not _old or _old.type_id ~= _d.type_id then
            _skill_dest[_skey] = basefunc.deepcopy(_d)
        else
            for k,v in pairs(_d.change_data) do
                _old.change_data[k] = (_old.change_data[k] or 0) + v * _multi
            end
        end
    end

    return _skill_dest
end

--[[
    计算 技能 升级 的最终值 和当前 配置
    返回：
       {
           skill = {skill_type=>{type_id=,change_data={change_key => change_value} }},
           skill_sum={skill_type=>{type_id=,change_data={change_key => change_value} }},
       }
--]]
function LF.calc_skill_change(_cfg,_level,_level_field)

    if not _cfg then
        return {}
    end

    _level_field = _level_field or "level"

    local _skill_sum = {}   -- 参数总增加量
    local _skill
    --local _last_cfg_level = _level_field == "star" and 0 or 1 -- 升星级 从 0 开始
    local _last_cfg_level = 0
    for _,v in ipairs(_cfg) do

        local _cur_level = v[_level_field]
        if _level <= v[_level_field] then  -- 到 _level 则停止
            _cur_level = _level
        end

        -- 累加升级过程 中的增量
        LF.skill_change_add(basefunc.deepcopy(v.skill),_skill_sum,_cur_level - _last_cfg_level)

        _last_cfg_level = _cur_level
        
        if _level <= v[_level_field] then
            _skill = v.skill
            break
        end
    end

    return {
        skill = _skill,
        skill_sum = _skill_sum,
    }    

end

-- 查找范围配置中 指定的 值对应的配置行
-- 注意：_cfg 从小到大排序； 范围之间的，使用 上限配置；
-- 没找到 返回 nil
function LF.find_area_cfg(_cfg,_field,_value)
    if not _cfg then
        return nil
    end

    for _,v in ipairs(_cfg) do
        if _value <= v[_field] then
            return v
        end
    end

    return nil
end

-- 计算 回收的经验值
function LF.calc_sold_exp(_rule_cfg,_level,_star)
    if not _rule_cfg then
        return 0
    end

    return (_rule_cfg[1] or 0) + (_rule_cfg[2] or 0)* _level + (_rule_cfg[3] or 0) * _star
end

return LF
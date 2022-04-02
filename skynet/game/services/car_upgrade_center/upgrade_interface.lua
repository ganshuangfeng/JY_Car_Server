--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 外部使用的 相关 接口  封装
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


local LD = base.LocalData("upgrade_interface",{

})

local LF = base.LocalFunc("upgrade_interface")

local equipment_star_mgr = base.LocalFunc("equipment_star_mgr")
local equipment_level_mgr = base.LocalFunc("equipment_level_mgr")
local car_level_mgr = base.LocalFunc("car_level_mgr")
local car_star_mgr = base.LocalFunc("car_star_mgr")

-- 查询 车的 等级数据
function CMD.query_car_level_data(_car_id,_level,_star)

    local _base_change = CMD.get_car_level_base_change(_car_id,_level)
    local _skill_change = CMD.get_car_level_skill_change(_car_id,_level)
    local _star_skill_change = CMD.get_car_star_skill_change(_car_id,_star)

    local _skill_sum = _skill_change and _skill_change.skill_sum
    if _star_skill_change and _star_skill_change.skill_sum then
        _skill_sum = upcfg_trans_lib.skill_change_add(_star_skill_change.skill_sum,_skill_sum)
    end

    return {
        base_change = _base_change and _base_change.base_change,
        base_change_sum = _base_change and _base_change.base_change_sum,
        skill_change = _skill_sum,
    }    
end

--[[ 
    查询车升级信息
    返回：升级数据 或 nil + code
    升级数据： 本次升级需要的消耗： {jing_bi=,...},
--]]
function CMD.query_car_upgrade_info(_car_id,_level,_star)
   local _car_cfg = car_star_mgr.get_car_cfg(_car_id)
   if not _car_cfg then
        return nil,6401
   end

   local _star_rule = _car_cfg.star_rule and upcfg_trans_lib.find_area_cfg(_car_cfg.star_rule,"star",_star)
   if _star_rule and _level > _star_rule.max_level then
        return nil,6402
   end

   local _spend,_code = CMD.get_car_level_spend(_car_id,_level)
   if not _spend then
        return nil,_code
   end

   if not _spend.spend then
        return nil,6402
   end

   return _spend.spend_sum
end

--[[ 
    装备的升级/回收信息
    参数 _up_eqpt , 需要升级的装备信息：
        {
            id=,
            level=,
            star=,
            now_exp=,
        }
    参数 _recycle_eqpts, 回收的装备数组： 
        {
            id=,
            level=,
            star=,
        }

    返回：升级设备信息 + 回收信息
        升级信息：
        {
            now_exp=, 剩余的经验值
            level=, 新的等级
            exp_spend =, 获得经验 消耗的金币
        }
        回收信息：经验值数组
        {
            exp,exp,...
        }
        
--]]
function CMD.query_equipment_upgrade_info(_up_eqpt,_recycle_eqpts)

    local _up_info = {
        now_exp = _up_eqpt.now_exp,
        level = _up_eqpt.level,
        exp_spend = 0,
    }

    local _recycle_info = {}

    -- 计算回收
    if _recycle_eqpts and next(_recycle_eqpts) then
        for i,v in ipairs(_recycle_eqpts) do
            local _eqpt_data = equipment_star_mgr.get_equipment_cfg(v.id)
            if _eqpt_data then
                _recycle_info[i] = upcfg_trans_lib.calc_sold_exp(_eqpt_data.main.sold_exp_rule,v.level,v.star)
                _up_info.now_exp = _up_info.now_exp + _recycle_info[i]
            end
        end
    end

    print("xxxxxxxxxxxxxxxxxxxx query_equipment_upgrade_info:",basefunc.tostring({incexp = _up_info.now_exp-_up_eqpt.now_exp,new_exp = _up_info.now_exp}))

    local _eqpt_data = equipment_star_mgr.get_equipment_cfg(_up_eqpt.id)
    _up_info.exp_spend = math.ceil(_eqpt_data.main.exp_spend * (_up_info.now_exp-_up_eqpt.now_exp))

    -- 计算升级
    while true do
        local _need_exp = CMD.get_equipment_level_exp(_up_eqpt.id,_up_info.level + 1)
        if not _need_exp then
            break -- 到最大经验值了
        end
        if _up_info.now_exp < _need_exp then
            break  -- 经验值不足
        end

        _up_info.level = _up_info.level + 1
        _up_info.now_exp = _up_info.now_exp - _need_exp
    end

    return _up_info,_recycle_info
end

-- 检查 装备上车 是否 符合类型定义
function LF.is_valid_eqpt_load_type(_car_base,_eqpt_data)
    
    dump(_eqpt_data , "xxxx-------------_eqpt_data:")
    local _e_type = _eqpt_data.main.own_type
    if _e_type == "common" then
        return true
    end

    if string.sub(_e_type,1,9) == "car_type_" then
        return string.sub(_e_type,10) == _car_base.type
    elseif string.sub(_e_type,1,7) == "car_id_" then
        return string.sub(_e_type,8) == _car_base.type
    else
        print.car_upgrade("is_valid_eqpt_load_type error,equipment own_type invalid:",_e_type)
        return false
    end
end

--[[ 
    判断 装备是否 能上车
    _car_data :
    {
        car_id=,
        level=,
        equipments= no => id,
    }

    返回 true 或 false,code 或 fase,1,槽位冲突装备no
--]]
function CMD.check_equipment_load(_eqpt_id,_eqpt_level,_car_data)

    local _eqpt_data = equipment_star_mgr.get_equipment_cfg(_eqpt_id)

    -- local _star_rule = upcfg_trans_lib.find_area_cfg(_eqpt_data.star_rule,"star",_eqpt_star)

    -- if _car_data.level < _star_rule.equip_need_lv then
    --     return false,6403   -- 车的等级不足
    -- end

    -- by lyx ： 改为直接判断等级，不 用读配置
    if _eqpt_level > _car_data.level then
        return false,6403   -- 车的等级不足
    end

    -- 检查车类型 匹配
    ---- change by wss
    --local _car_base = car_level_mgr.get_car_base_cfg(_car_data.car_id)
    local _car_base = CMD.get_car_base_cfg(_car_data.car_id)
    if not _car_base then
        return false,6401
    end
    if not LF.is_valid_eqpt_load_type(_car_base,_eqpt_data) then
        return false,6404
    end

    -- 检查槽位
    for _no,_id in pairs(_car_data.equipments) do
        local _tmp = equipment_star_mgr.get_equipment_cfg(_id)
        if _eqpt_data.main.slot == _tmp.main.slot then
            return false,1,_no  -- 槽位被占用
        end
    end

    return true
end

--[[
    批量得到装备的 基础配置信息
    参数 _eqpts_id , 装备 id 映射：eqpt id  => true
    返回 结果 映射： eqpt id => main 表中内容
--]]
function CMD.get_equipments_base_cfg(_eqpts_id)
    local _ret = {}
    for _id,_ in pairs(_eqpts_id) do
        local _tmp = equipment_level_mgr.get_equipment_cfg(_id)
        if _tmp and _tmp.main then
            _ret[_id] = _tmp.main
        end
    end

    return _ret
end



--[[
    批量计算装备的总和效果
    参数 _eqpts , 数组：
    {
        no=, 唯一编号
        id=,
        level=,
        star=,
    }
    返回 
    {
		base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
        skill_change = {   --- 当前，改变的技能的数据
        	[no] = {
				skill_type_1 = { 
	                type_id = xxx , 
	                change_data = { 
	                    key = xx , 
	                    key_2 = xx2 ,
	                } 
	            },
	            ...
        	}
            
        }
    }
--]]
function CMD.get_equipments_change_sum(_eqpts)
    
    local _ret = {
        base_change_sum = {},
        skill_change = {},
    }

    for _,_d in ipairs(_eqpts) do

        local _base_change = CMD.get_equipment_level_base_change(_d.id,_d.level)
        basefunc.add_children(_base_change and _base_change.base_change_sum,_ret.base_change_sum)

        _ret.skill_change[_d.no] = {}

        local _skill_change = CMD.get_equipment_level_skill_change(_d.id,_d.level)
        upcfg_trans_lib.skill_change_add(_skill_change and _skill_change.skill_sum,_ret.skill_change[_d.no])

        _skill_change = CMD.get_equipment_star_skill_change(_d.id,_d.star)
        upcfg_trans_lib.skill_change_add(_skill_change and _skill_change.skill_sum,_ret.skill_change[_d.no])
    end

    return _ret
end


return LF
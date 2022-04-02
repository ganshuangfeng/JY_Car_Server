--
-- Author: lyx
-- Date: 2019/11/28
-- Time: 14:40

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require"printfunc"

local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

local upcfg_trans_lib = require "upgrade.upcfg_trans_lib"

local LD = base.LocalData("car_equipment_lib",{
    
    equipment_data = nil
})

local LF = base.LocalFunc("car_equipment_lib")

local car_base_lib = base.LocalFunc("car_base_lib")

function LF.init()
    LF.safe_load_data()
end

function LF.safe_load_data()
    if not LD.equipment_data then
        LD.equipment_data = skynet.call(DATA.service_config.data_service,"lua","query_equipment_info",DATA.my_id)
    end
end

-- 加一个装备
function LF.add_equipment(_eqp_id)
    local _new_eqp_data = {
        id = _eqp_id,
        player_id = DATA.my_id,
        level = 1,
        star = 0,
        now_exp = 0,
        owner_car_id = 0,
    }

    _new_eqp_data.no = skynet.call(DATA.service_config.data_service,"lua","add_equipment_info",DATA.my_id,_new_eqp_data)

    LD.equipment_data[_new_eqp_data.no] = _new_eqp_data

    return _new_eqp_data
end

function LF.get_equipment_data_base(_car_id,_eqpt_no)
   ---LF.safe_load_data()

    local _eqpts_id = {}
    for _,v in pairs(LD.equipment_data) do
        if (not _car_id or _car_id==v.owner_car_id) and (not _eqpt_no or _eqpt_no==v.no) then
            _eqpts_id[v.id] = true
        end
    end

    local _base_cfg = skynet.call(DATA.service_config.car_upgrade_center,"lua","get_equipments_base_cfg",_eqpts_id)

    local _ret = {}
    for _,v in pairs(LD.equipment_data) do
        if (not _car_id or _car_id==v.owner_car_id) and (not _eqpt_no or _eqpt_no==v.no) then
            _ret[v.no] = basefunc.deepcopy(v)
            local _cfg = _base_cfg[v.id]
            
            _ret[v.no].sold_exp = upcfg_trans_lib.calc_sold_exp(_cfg and _cfg.sold_exp_rule,v.level,v.star)
        end
    end
    
    return _ret
end

function LF.get_all_equipment_data()

    return LF.get_equipment_data_base(nil,nil)
end


function LF.get_car_all_equipment_data(_car_id)

    if not _car_id then
        return {}
    end

    return LF.get_equipment_data_base(_car_id,nil)
end

function LF.get_one_equipment_data(_eqp_no)

    return LF.get_equipment_data_base(nil,_eqp_no)[_eqp_no]
end

function LF.get_car_equipment_change_base(_car_id,_eqpt_no)
    --LF.safe_load_data()

    local _eqpts = {}
    for _,v in pairs(LD.equipment_data) do
        if (not _car_id or _car_id==v.owner_car_id) and (not _eqpt_no or _eqpt_no==v.no) then
            table.insert(_eqpts,{
                no = v.no,
                id = v.id,
                level = v.level,
                star = v.star,
            })
        end
    end
    
    return skynet.call(DATA.service_config.car_upgrade_center,"lua","get_equipments_change_sum",_eqpts)
end

---- add by wss
--- 通过数据来获取 影响数值
function LF.get_car_equipment_change_by_data( _eqpts )
    return skynet.call(DATA.service_config.car_upgrade_center,"lua","get_equipments_change_sum",_eqpts)
end

function LF.get_car_all_equipment_change(_car_id)

    if not _car_id then
        return {}
    end

    return LF.get_car_equipment_change_base(_car_id)
end

--[[
    return {
        base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
        skill_change = {   --- 当前，改变的技能的数据
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
--]]
function LF.get_one_equipment_change(_eqp_no)

    if not _eqp_no then
        return {}
    end
    
    local _ret = LF.get_car_equipment_change_base(nil,_eqp_no)
    
    -- 因为 get_car_equipment_change_base 是可为多个 eqp no 使用的；调整 skill change 中 返回结果的层次
    _ret.skill_change = _ret.skill_change and _ret.skill_change[_eqp_no]

    return _ret
end

function LF.modify_eqpt_data(_eqpt_no,_data)
    --LF.safe_load_data()

    local _d = basefunc.safe_keys(LD.equipment_data,_data,_eqpt_no)
    _d.no = _eqpt_no

    if _data then -- _data 可以 为空， 表示仅保存到数据 库
        basefunc.merge(_data,_d)
    end
    
    skynet.send(DATA.service_config.data_service,"lua","modify_equipment_info",DATA.my_id,{
        [_eqpt_no] = _d
    })

end

-- 升级装备
function LF.equipment_up_level(_eqpt_no,_spend_eqpt_no_list)
    --LF.safe_load_data()

    local _d = LD.equipment_data[_eqpt_no]
    if not _d then
        return { result = 1004 }
    end

    local _up_eqpt = {
        id=_d.id,
        level=_d.level,
        star=_d.star,
        now_exp=_d.now_exp,
    }

    local _recycle_eqpts = {}
    if _spend_eqpt_no_list and next(_spend_eqpt_no_list) then
        for _,v in ipairs(_spend_eqpt_no_list) do
            local _tmp = LD.equipment_data[v]
            if _tmp then
                table.insert(_recycle_eqpts,{
                    id=_tmp.id,
                    level=_tmp.level,
                    star=_tmp.star,
                })
            else
                print.car_upgrade("equipment_up_level error,equipment no not found(player,eqpt id):",DATA.my_id,v)
            end
        end
    end

    dump({_up_eqpt,_recycle_eqpts} , "xxx111=---------------------------equipment_up_level_up_info")
    local _up_info,_recycle_info = skynet.call(DATA.service_config.car_upgrade_center,"lua","query_equipment_upgrade_info",_up_eqpt,_recycle_eqpts)
    dump({_up_info,_recycle_info} , "xxx222=---------------------------equipment_up_level_up_info")
    -- 扣除财富
    if  _up_info.exp_spend > 0 then
        if car_base_lib.try_spend({jing_bi = _up_info.exp_spend},ASSET_CHANGE_TYPE.EQUIPMENT_RECYCLE_SPEND) then
        else
            return {result=6413}
        end
    end

    ---- change by wss 
    --if _up_info.level == _d.level then
    --    return {result=3102}  -- 经验不足
    --end

    if _spend_eqpt_no_list and next(_spend_eqpt_no_list) then
        for _,v in ipairs(_spend_eqpt_no_list) do
            local _tmp = LD.equipment_data[v]
            if _tmp then
                LD.equipment_data[v] = nil
                skynet.send(DATA.service_config.data_service,"lua","del_equipment_info",DATA.my_id,v)
            end
        end
    end

    _d.level = _up_info.level
    _d.now_exp = _up_info.now_exp
    LF.modify_eqpt_data(_eqpt_no)

    return {result=0 , owner_car_id = _d.owner_car_id }

end

-- 升星装备
function LF.equipment_up_star(_eqpt_no)
    --LF.safe_load_data()

    local _d = LD.equipment_data[_eqpt_no]
    if not _d then
        return { result = 6406 }
    end

    local _new_star = (_d.star or 0) + 1
    local _spend,_code = skynet.call(DATA.service_config.car_upgrade_center,"lua","get_equipment_star_spend",_d.id,_new_star)
    if not _spend then
        return { result = _code }
    end

    -- nil 表示 已升级 到最大星
    if not _spend.spend then
        return { result = 6409 }
    end
    
    -- 扣除财富
    if car_base_lib.try_spend(_spend.spend_sum,ASSET_CHANGE_TYPE.EQUIPMENT_UPSTAR_SPEND) then
        _d.star = _new_star
        LF.modify_eqpt_data(_eqpt_no)

        return {result=0 , owner_car_id = _d.owner_car_id }
    else
        return {result=6412}
    end
    
end


-- 装备 上 车
function LF.equipment_load(_eqpt_no,_car_id)
    --LF.safe_load_data()

    local _d = LD.equipment_data[_eqpt_no]
    if not _d then
        return { result = 6406 }
    end

    ---- change by wss
    --if _d.owner_car_id or _d.owner_car_id ~= 0 then
    --- 如果这个装备已经装备了
    if _d.owner_car_id and _d.owner_car_id ~= 0 then
        return { result = 6407 }
    end

    local _d_car = car_base_lib.safe_car_data(_car_id)
    if not _d_car then
        return { result = 6401 }
    end

    local _car_data = {
        car_id = _car_id,
        level = _d_car.level,
        equipments={},
    }
    for _,v in pairs(LD.equipment_data) do
        if v.owner_car_id == _car_id then
            _car_data.equipments[v.no] = v.id
        end
    end

    local _can_load,_code,_confli_no = skynet.call(DATA.service_config.car_upgrade_center,"lua","check_equipment_load", _d.id , _d.level, _car_data)

    if 1 == _code then

        LF.equipment_unload(_confli_no)

    elseif not _can_load then
        
        return { result = _code }
    end

    _d.owner_car_id = _car_id
    LF.modify_eqpt_data(_eqpt_no)

    return {result = 0 , old_eqp_no = _confli_no }    
end

-- 装备 下 车
function LF.equipment_unload(_eqpt_no)
    --LF.safe_load_data()

    local _d = LD.equipment_data[_eqpt_no]
    if not _d then
        return { result = 6406 }
    end

    if not _d.owner_car_id or _d.owner_car_id == 0 then
        return { result = 6408 }
    end

    local old_owner_car_id = _d.owner_car_id

    _d.owner_car_id = 0
    LF.modify_eqpt_data(_eqpt_no)
    
    return {result = 0 , owner_car_id = old_owner_car_id }
end


return LF
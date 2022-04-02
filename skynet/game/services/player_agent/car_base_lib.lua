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

local LD = base.LocalData("car_base_lib",{
    
    -- 车数据
    car_data = nil,

})

local LF = base.LocalFunc("car_base_lib")

----- 碎片合成规则
LD.car_patch_rule = {
    patch_tanke = { need_num = 10 , car_id = 2 , is_hecheng = false } ,
    patch_pingtou = { need_num = 10 , car_id = 3 , is_hecheng = false } ,
    patch_dilei = { need_num = 10 , car_id = 4 , is_hecheng = false } ,
}

LD.msg = {}

---- 当资产改变 ，
function LD.msg.asset_change_msg( _ , asset_type , change_value , final_value )
    local tar_hc_data = LD.car_patch_rule[asset_type]
    if tar_hc_data and final_value >= tar_hc_data.need_num and not tar_hc_data.is_hecheng then
        tar_hc_data.is_hecheng = true

        local car_data = LF.get_car_data( tar_hc_data.car_id )

        if not car_data then
            PUBLIC.add_drive_car( tar_hc_data.car_id )

            local _asset_data={
                {asset_type = asset_type ,value = -tar_hc_data.need_num },
            }
            CMD.change_asset_multi(_asset_data , ASSET_CHANGE_TYPE.PATCH_HC_CAR_SPEND ,0)

        end

    end
end

function LF.init()

    DATA.msg_dispatcher:register( "car_base_lib" , LD.msg )

end

---- 获得所有的车的数据
function LF.get_all_car_data()
    if not LD.car_data then
        LD.car_data = skynet.call(DATA.service_config.data_service,"lua","query_car_info",DATA.my_id)
    end

    if not next(LD.car_data) then
        local ret1 = PUBLIC.add_drive_car(1)
        --local ret2 = PUBLIC.add_drive_car(2)

        print("xxxx--------------get_all_car_data add_drive_car:" , ret1 , ret2 )
    end

    return LD.car_data
end

function LF.get_car_data(_car_id)
    if not LD.car_data then
        LD.car_data = skynet.call(DATA.service_config.data_service,"lua","query_car_info",DATA.my_id)
    end

    return LD.car_data[_car_id]
end


---- 安全得获得一个 车辆数据
function LF.safe_car_data(_car_id)

    local _d = LF.get_car_data(_car_id)

    if _d then
        return _d
    end

    if not basefunc.chk_player_is_real(DATA.my_id) then
        LF.add_car(_car_id)
        return LD.car_data[_car_id]
    end

    if _car_id > 1 then
        return nil,6401
    end

    if not next(LD.car_data) then
        local ret1 = PUBLIC.add_drive_car(1)
        --local ret2 = PUBLIC.add_drive_car(2)

    end

    --LF.add_car(_car_id)

    return LD.car_data[_car_id]
end

-- 加一个车
-- 返回 车数据 或 nil + 错误码
function LF.add_car(_car_id)

    local _d = LF.get_car_data(_car_id)
    if _d then
        return nil,6411
    end

    local _new_car_data = {
        car_id = _car_id,
        player_id = DATA.my_id,
        level = 1,
        star = 0,
    }

    LD.car_data[_new_car_data.car_id] = _new_car_data

    skynet.call(DATA.service_config.data_service,"lua","add_car_info",DATA.my_id,_new_car_data)

    return _new_car_data
end

-- function LF.get_car_cur_level(_car_id)
--     local _d = LF.safe_car_data(_car_id)
--     return _d and _d.level
-- end

-- 得到车的升级信息
-- 参数 _level : 如果省略, 则为车当前的实际等级
--[[ 返回：
    {
        base_change = {hp=,...}  -- 从下一级升级到当前 增加的参数
        base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
        skill_change = {           --- 最终的，改变的技能的数据
            [skill_type_1] = { 
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
function LF.get_car_up_level_change(_car_id)
    local _d = LF.safe_car_data(_car_id)
    if not _d then
        return nil
    end

    return skynet.call(DATA.service_config.car_upgrade_center,"lua","query_car_level_data",_car_id,_d.level,_d.star)
end

--- add by wss 
-- 通过数据来获取车辆影响的数据
function LF.get_car_up_level_change_by_data( _car_id , _car_level , _car_star )
    return skynet.call(DATA.service_config.car_upgrade_center,"lua","query_car_level_data",_car_id, _car_level , _car_star )
end

function LF.modify_car_data(_car_id,_data)
    local _d = LF.safe_car_data(_car_id)
    if not _d then
        return
    end
    
    basefunc.merge(_data,_d)

    skynet.send(DATA.service_config.data_service,"lua","modify_car_info",DATA.my_id,{
        [_car_id] = _d
    })
end

-- 尝试扣除； 成功 返回 true ； 失败 返回 false, 不足的 财富名称
function LF.try_spend(_spend,_change_type,_change_id)

    -- 检查是否充足
    local _change_assets = {}
    for k,v in pairs(_spend) do
        if CMD.query_asset_by_type(k) < v then
            return false,k
        else
            table.insert(_change_assets,{
                asset_type=k,
                value=-v,
            })
        end
    end

    -- 扣除
    CMD.change_asset_multi(_change_assets,ASSET_CHANGE_TYPE.CAR_UPGRADE_SPEND,_change_id or 0)

    return true
end

function LF.car_upgrade(_car_id)
    local _d = LF.safe_car_data(_car_id)
    if not _d then
        return {result=6401}
    end

    local _level = (_d.level or 1) + 1

    local _spend,_code = skynet.call(DATA.service_config.car_upgrade_center,"lua","query_car_upgrade_info",_car_id,_level,_d.star)

    if not _spend then
        return {result=_code}
    end

    -- 扣除财富
    if LF.try_spend(_spend,ASSET_CHANGE_TYPE.CAR_UPGRADE_SPEND) then

        _d.level = _level
        LF.modify_car_data(_car_id)

        return {result=0}
    else
        return {result=2253}
    end
end

-- 升星车辆
function LF.car_up_star(_car_id)
    local _d = LF.safe_car_data(_car_id)
    if not _d then
        return {result=6401}
    end

    local _new_star = (_d.star or 0) + 1
    local _spend,_code = skynet.call(DATA.service_config.car_upgrade_center,"lua","get_car_star_spend",_d.car_id,_new_star)
    if not _spend then
        return { result = _code }
    end

    if not _spend.spend then 
        return {result=6410}
    end
    
    -- 扣除财富
    if LF.try_spend(_spend.spend_sum,ASSET_CHANGE_TYPE.CAR_UPSTAR_SPEND) then

        _d.star = _new_star
        LF.modify_car_data(_car_id)

        return {result=0}
    else
        return {result=2253}
    end
    
end

return LF
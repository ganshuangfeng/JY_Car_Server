--
-- Author: lyx
-- Date: 2018/10/9
-- Time: 15:14
-- 说明：托管 调度器
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require"printfunc"
local nodefunc = require "nodefunc"
require "normal_enum"
require "data_func"

require "common_data_manager_lib"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC


local LD = base.LocalData("tuoguan_schedule_duanwei",{

    -- 托管使用数据
    use_data = nil,

    --[[
        托管资源 分组数组
        {
            using={}  ， 使用中的托管： 托管 player id => 托管数据
            free = {} ,  空闲托管 托管 player id => 托管数据
        },。。。 数组
    --]]
    tg_data_groups = nil,

    group_count = nil,
    group_size = nil,

    -- 托管的序号映射： 托管 player id => 序号
    tg_data_index = {},
})

local LF = base.LocalFunc("tuoguan_schedule_duanwei")

function LF.init()

    LD.use_data = basefunc.server_class.data_manager_cls.new({
        load_data = function(_key) return LF.load_use_data(_key)  end
    },tonumber(skynet.getenv("data_man_cache_size")) or 40000)
    
    
end

function LF.set_tg_user_pool(_tg_user_pool,_group_count,_group_size)

    LD.group_count = _group_count
    LD.group_size = _group_size

    LD.tg_data_groups = {}
    local _tg_pool_i = 0
    for _g=1,_group_count do
        LD.tg_data_groups[_g] = {using={},free={}}
        for _i=1,_group_size do

            _tg_pool_i = _tg_pool_i + 1
            local _ud = _tg_user_pool[_tg_pool_i]
            LD.tg_data_groups[_g].free[_ud.id] = _ud
            LD.tg_data_index[_ud.id] = _tg_pool_i
        end
    end
end

-- 根据总序号，计算 分组序号和 组内序号
function LF.calc_group_index(_global_index)
    if not _global_index then
        return nil,nil
    end

    return math.floor((_global_index+LD.group_size-1)/LD.group_size),((_global_index-1) % LD.group_size) + 1
end

-- 根据玩家 id，得到 分组序号和 组内序号
function LF.get_group_index(_player_id)
    
    return LF.calc_group_index(LD.tg_data_index[_player_id])
end

function LF.recycle_user_data(_user_data)
    local _group,_ = LF.get_group_index(_user_data.id)

    if not _group then
        --print("tuoguan dw LF.recycle_user_data error:",_user_data.id)
        return false
    end

    local _gdata = LD.tg_data_groups[_group]
    if not _gdata then
        print("tuoguan dw LF.recycle_user_data error 22:",basefunc.tostring(_user_data))
        return false
    end

    _gdata.free[_user_data.id] = _user_data
    _gdata.using[_user_data.id] = nil

    return true
end

--[[ 
    创建一个托管实例。
        注意,_game_info 中包含字段： 
            pvp_real_user_id     pvp 对战的 真实玩家 id
--]]
function LF.pop_tuoguan_agent(_game_info)

    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx schedule pop_tuoguan_agent111:",basefunc.tostring(_game_info))

    if not _game_info.pvp_real_user_id then
        return nil
    end

    local _group = LF.get_cur_use_group(_game_info.pvp_real_user_id)

    -- 从当前分组开始，最多尝试 3 组
    for _try_count = 1,3 do

        local _gdata = LD.tg_data_groups[_group]
        if not _gdata then
            print("tuoguan dw LF.pop_tuoguan_agent error 22,not in tg_data_groups :",_group)
            return nil
        end

        -- 循环查找没用过的
        for _,_udata in pairs(_gdata.free) do
            local _gtmp,_itmp = LF.get_group_index(_udata.id)
            --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx schedule pop_tuoguan_agent222:",_udata.id,_gtmp,_itmp)
            if _gtmp ~= _group then
                print("tuoguan dw LF.pop_tuoguan_agent group error 33:",_gtmp ,_group)
            end

            if LF.check_can_use_index(_game_info.pvp_real_user_id,_itmp) then

                -- 先改变状态，避免 create_tuoguan_agent 挂起时重入
                LF.use_cur_group_index(_game_info.pvp_real_user_id,_itmp)
                _gdata.free[_udata.id] = nil
                _gdata.using[_udata.id] = _udata


                local _tg = PUBLIC.create_tuoguan_agent(_udata)
                if not _tg then
                    LF.recycle_user_data(_udata)
                    print("tuoguan dw LF.pop_tuoguan_agent create error 44:",basefunc.tostring(_udata))
                    return nil -- 失败，放弃此次检查
                end
                return _tg -- 成功
            end
        end

        -- 还没找到，尝试下一组
        if _group >= LD.group_count then
            _group = 0
        else
            _group = _group + 1
        end

        print("tuoguan dw LF.pop_tuoguan_agent create error,try next group 55:",basefunc.tostring(_game_info),_try_count)
        LF.set_cur_use_group(_game_info.pvp_real_user_id,_group)
    end

    print("tuoguan dw LF.pop_tuoguan_agent create error,all try fail 66:",basefunc.tostring(_game_info))
    return nil
end

function LF.load_use_data(_user_id)
    local _ret,_err = PUBLIC.db_query_va("select * from tg_use_data where player_id=%s;",_user_id)
    if _err then
        error(_err)
    end

    if _ret[1] then
        return _ret[1]
    else
        return {
            player_id = _user_id,
            cur_group_id = 1,
            use_data = "",
        }
    end
end

-- 将当前组的 某个 index 设为已使用
function LF.use_cur_group_index(_user_id,_index)
    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx use_cur_group_index:",_user_id,_index)
    local _d = LD.use_data:get_data(_user_id)
    if not _d then
        return
    end

    if _index <= string.len(_d.use_data) then
        if string.sub(_d.use_data,_index,_index) == "1" then
            return -- 没有变化，不用修改
        end

        _d.use_data = string.sub(_d.use_data,1,_index) .. "1" .. string.sub(_d.use_data,_index+1,-1)
    else
        _d.use_data = _d.use_data .. string.rep("0",_index - string.len(_d.use_data) - 1) .. "1"
    end

    local _sql = PUBLIC.safe_insert_sql("tg_use_data",_d,"player_id")
    local _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")
    LD.use_data:add_or_update_data(_user_id,_d,_qname,_qid)
end

-- 设置当前 分组
function LF.set_cur_use_group(_user_id,_cur_group_id)

    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx set_cur_use_group:",_user_id,_cur_group_id)

    local _d = LD.use_data:get_data(_user_id)
    if not _d then
        return
    end

    _d.cur_group_id = _cur_group_id
    
    local _sql = PUBLIC.safe_insert_sql("tg_use_data",_d,"player_id")
    local _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")
    LD.use_data:add_or_update_data(_user_id,_d,_qname,_qid)
end

function LF.get_cur_use_group(_user_id)

    local _d = LD.use_data:get_data(_user_id)
    if not _d then
        return 1
    end

    return _d.cur_group_id or 1
end

function LF.check_can_use_index(_user_id,_index)
    local _d = LD.use_data:get_data(_user_id)
    if not _d then
        return true
    end

    if _index > string.len(_d.use_data) then
        return true
    end
    
    return string.sub(_d.use_data,_index,_index) ~= "1"
end

return LF
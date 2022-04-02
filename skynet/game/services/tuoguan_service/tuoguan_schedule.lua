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

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

DATA.tuoguan_schedule_protect = {}
local PROTECTED = DATA.tuoguan_schedule_protect

DATA.tg_schedule_data = DATA.tg_schedule_data or {
    --[[ 
        分类 托管的池，数组：  {config = 配置 , tg_created_pool=准备好的托管agent池 , user_data_pool=用户数据池}
    --]]
   grades_tuoguan_pool = {},

    -- 游戏场次所在的池序号： game_hash => 序号
   game2pool = {},

    -- 托管 id 所在 池序号
   tuoguan_id2pool = {},

   --- 上次配置时间
   config_time = 0,

   --- 缓存的 游戏字符串
   game_id_maps = {},

   ---- 打印一次的开关
   check_tuoguan_pool_start = false,
}
local D = DATA.tg_schedule_data

local LF = base.LocalFunc("tuoguan_schedule")

function PUBLIC.get_model_game_hash(_name,_id)
	local g = D.game_id_maps[_name] or {}
	D.game_id_maps[_name] = g

	local _hash = g[_id] or _name .. "_" .. _id
	g[_id] = _hash

	return _hash
end

----- 根据 配置 ， 传入的是 要分 场次的托管原始 信息
function LF.load_config(_tg_user_pool)
    ---- 载入 托管 的 分类配置表
    local configs = nodefunc.get_global_config("tuoguan_config")

    ---- 分类托管里面一个 分类 没有
    if not configs.tuoguan_games[1] then
        return
    end

    --- 每个 等级的 托管池
    D.grades_tuoguan_pool = {}

    ------ 按不同的 游戏 等级配置 平均分。( 我觉得有问题，有些配置多，有些配置少 )
    local _count_per = math.floor(#_tg_user_pool/#configs.tuoguan_games)

    --- 对每个分类做处理
    for i,_config in ipairs(configs.tuoguan_games) do

        ------ tg_created_pool 是已经创建的 托管 数据  ； user_data_pool 是 可以用来创建的 托管原始数据
        local _pool = {tg_created_pool = {} , user_data_pool = {} }
        D.grades_tuoguan_pool[i] = _pool

        -- 建立场次映射
        for _,_game in ipairs(_config.games) do
            D.game2pool[PUBLIC.get_model_game_hash(_game.model,_game.game_id)] = i
        end

        ---- 类似 ，整个的分类配置
        _pool.config = _config
        
        -- 分配 托管池
        local _i_begin = _count_per*(i-1)+1
        for _i2=_i_begin, _i_begin + _count_per-1 do
            _pool.user_data_pool[#_pool.user_data_pool + 1] = _tg_user_pool[_i2]

            -- login id 映射
            D.tuoguan_id2pool[_tg_user_pool[_i2].id] = i
        end
    end
end


-- 刷新配置
function LF.refresh_config()
    local configs,_time = nodefunc.get_global_config("tuoguan_config")
    if _time == D.config_time then
        return
    end
    D.config_time = _time

    -- 清除映射表
    D.game2pool = {}

    for i,_config in ipairs(configs.tuoguan_games) do

        local _pool = D.grades_tuoguan_pool[i]
  
        for _,_game in ipairs(_config.games) do
            D.game2pool[PUBLIC.get_model_game_hash(_game.model,_game.game_id)] = i
        end

        _pool.config = _config
        
    end

end

-- 确保托管的 钱在给定的范围
function LF.adjust_money(_tg,_money1,_money2)

    local _jing_bi = nodefunc.call(_tg.player_id,"query_asset_by_type",PLAYER_ASSET_TYPES.JING_BI) or 0
    if "CALL_FAIL" == _jing_bi then
        return 
    end

    --print("tuoguan achedule adjust money(player,cur money ,money1,money2):",_tg.player_id,_jing_bi,_money1,_money2)

    _money1 = _money1 or 0
    _money2 = _money2 or 0
    if _jing_bi < _money1 or _jing_bi > _money2 then
        local _inc_value = math.random(_money1,_money2)-_jing_bi
        --print("tuoguan achedule adjust money(money,player ,change):",_jing_bi+_inc_value,_tg.player_id,_inc_value)
        nodefunc.call(_tg.player_id,"change_asset_multi",{{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=_inc_value}},
            ASSET_CHANGE_TYPE.TUOGUAN_ADJUST,"0")
    end
end

-- 确保托管的 钱在给定的范围
function LF.adjust_vip(_tg,_vip1,_vip2)

    if not _vip1 then
        return nil
    end

    _vip2 = _vip2 or _vip1
    
    local _old = skynet.call(DATA.service_config.new_vip_center_service,"lua","query_player_vip_level",_tg.player_id) or 0
    if _old >= _vip1 and _old <= _vip2 then
        if (_tg.vip_adjust_count or 0) > 0 or _old ~= 0 then -- vip0 必须至少调整过 一次
            --print("adjust_vip 111:",_tg,_tg.player_id,_tg.vip_adjust_count,_old)
            return _old,_old
        end
    end

    _tg.vip_adjust_count = (_tg.vip_adjust_count or 0) + 1

    local _new_vip = math.random(_vip1,_vip2)
    print("adjust_vip 222:",_tg,_tg.player_id,_tg.vip_adjust_count,_old,_vip1,_vip2,_new_vip)
    skynet.call(DATA.service_config.new_vip_center_service,"lua","set_vip_level",_tg.player_id,_new_vip)    
    return _old,_new_vip
end

function LF.adjust_tg_agent_status(_tg,_pool,_pool_i)

    -- 确保鲸币 在范围内
    LF.adjust_money(_tg,_pool.config.money[1],_pool.config.money[2])

    -- 调整 vip
    if _pool.config.vip_level then
        local _old_vip,_new_vip = LF.adjust_vip(_tg,_pool.config.vip_level[1],_pool.config.vip_level[2])
        --print("create_tuoguan_agent adust_vip:",_pool_i,_tg.player_id,_pool.config.vip_level[1],_pool.config.vip_level[2],"result:",_old_vip,_new_vip)
    end    
    
end

----- 根据 托管基础数据 创建托管client 并且 修改对应 数据
function LF.create_tuoguan_agent(_pool,_pool_i)
    ---创建时，会从原始数据中，弹出一个，
    local _ud = basefunc.random_pop(_pool.user_data_pool)
    if not _ud then 
        print("schedule LF.create_tuoguan_agent ,pool data use out!")
        return nil
    end

    local _tg = PUBLIC.create_tuoguan_agent(_ud)
    if not _tg then
        print("schedule LF.create_tuoguan_agent,create tuoguan agent failed!")
        return nil -- 失败，放弃此次检查
    end

    LF.adjust_tg_agent_status(_tg,_pool,_pool_i)

    return _tg
end
 
-- 检查 已创托管池 中的 托管数量 ， 时刻保持有一定量的 托管数据
function LF.check_tuoguan_pool_count()

	if skynet.getcfg("forbid_tuoguan_manager") then
		return
	end

    if not D.check_tuoguan_pool_start then
        D.check_tuoguan_pool_start = true
        print("LF.check_tuoguan_pool_count start...")
    end

    LF.refresh_config()

    -- 检查 池中的数量，不足则创建

    local _min_psize = skynet.getcfg("tuoguan_pool_size") or 10
    for _pool_i,_pool in pairs(D.grades_tuoguan_pool) do

        -- 确保缓存 充足
        local _diff = _min_psize - #_pool.tg_created_pool
        for i=1,_diff do
            local _tg = LF.create_tuoguan_agent(_pool,_pool_i)
            if _tg then
                _pool.tg_created_pool[#_pool.tg_created_pool + 1] = _tg
            else
                print("LF.check_tuoguan_pool_count error:",i)
            end
        end
        
    end

end

-- 检查 已创托管池 中 托管的状态 ，并且设置成正确状态
function LF.check_tuoguan_pool_status()
	if skynet.getcfg("forbid_tuoguan_manager") then
		return
	end

    if not D.check_tuoguan_pool_start then
        D.check_tuoguan_pool_start = true
        print("LF.check_tuoguan_pool_count start...")
    end

    for _pool_i,_pool in pairs(D.grades_tuoguan_pool) do

        -- 调整所有的 agent 状态（钱、 vip等级）
        for _,_tg in ipairs(_pool.tg_created_pool) do
            LF.adjust_tg_agent_status(_tg,_pool,_pool_i)
        end
        
    end
end

---- 回收，托管的数据到 原始的 数据中
function PROTECTED.recycle_user_data(_user_data)
    local _pool_i = D.tuoguan_id2pool[_user_data.id]
    if _pool_i then

        local _pool = D.grades_tuoguan_pool[_pool_i]
        _pool.user_data_pool[#_pool.user_data_pool + 1] = _user_data

        print("recycle_user_data schedule :",_user_data.id)

        return true
    else
        return false
    end
end

-- 从池中弹出一个 托管 agent，如果没有，则新创建
function PROTECTED.pop_tuoguan_agent(_game_info)
    
    local _pool_i = D.game2pool[PUBLIC.get_model_game_hash(_game_info.match_name,_game_info.game_id)]
    if _pool_i then
        local _pool = D.grades_tuoguan_pool[_pool_i]
        if not _pool then
            print("schedule pop_tuoguan_agent ,pool is nil :",_game_info.match_name,_game_info.game_id,_pool_i)
            return nil
        end

        -- 从池中取出一个
        local _tg = basefunc.random_pop(_pool.tg_created_pool)
        if _tg then
    		print("schedule pop_tuoguan_agent ,from pool :",_game_info.match_name,_game_info.game_id,_pool_i)
            return _tg
        end

        -- 没有则创建
        _tg = LF.create_tuoguan_agent(_pool,_pool_i)
        if _tg then
            print("schedule pop_tuoguan_agent ,create :",_game_info.match_name,_game_info.game_id,_pool_i)
            return _tg
        else
            print("schedule pop_tuoguan_agent error:",_game_info.match_name,_game_info.game_id,_pool_i)
            return nil
        end
    end

    print("schedule pop_tuoguan_agent error,not found pool:",_game_info.match_name,_game_info.game_id)
    return nil
end

function PROTECTED.set_tg_user_pool(_tg_user_pool,_group_count,_group_size)

    LF.load_config(_tg_user_pool)
    
    ---- 时刻
    skynet.timer(20,function() LF.check_tuoguan_pool_count() end)      
    skynet.timer(25,function() LF.check_tuoguan_pool_status() end)
        
end


function PROTECTED.init(_tg_user_pool)

end



return PROTECTED
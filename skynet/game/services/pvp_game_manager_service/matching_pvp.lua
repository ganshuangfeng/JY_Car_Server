-------- 随机匹配  with  托管
--[[
	逻辑 ，托管和真人报名后 的数据放入，不同的表存起来备用
	
	每隔一定时间，把真人的数据分到对应的匹配池中，去找适合自己的匹配池，如果没找到就自己开一个等待别人来匹配自己。

--]]

local skynet = require "skynet_plus"
local base=require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
require "normal_enum"
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- DATA.matching_random_protect = {}
-- local PROTECT = DATA.matching_random_protect

local LD = base.LocalData("matching_pvp",{


    --[[
        已经报名的 托管池 , player_id => 数据：
        { 
            player_id = , 
            match_time = 报名时间 , 
            match_index = 所在的匹配池的索引 (没有匹配就是nil) 
        }
    --]]
    signuped_tuoguan_pool = {},

    --[[
        已经报名的 真人池 , player_id => 数据：
        { 
            player_id = , 
            match_time = 报名时间 , 
            req_tg_time=上次请求托管的时间,
            tg_user_id=已就位的托管id
            match_index = 所在的匹配池的索引 (没有匹配就是nil) 
        }
    --]]
    signuped_real_player_pool = {},
    
    -- by lyx 2021-6-3 ： 段位赛匹配参数  
    duanwei_match_score_diff = 100,
    duanwei_match_fight_diff = 100,

    ----- 匹配池的 索引
    match_pool_index = 0,
    match_pool_index_max = 90000,

    ----- 匹配池
    matching_pool = {},

    -- 时钟变量
    last_req_tuoguan = 0,
    last_deal_match = 0,

    -- 时间间隔
    req_tuoguan_interval = 3,
    deal_match_interval = 2,
})

local LF = base.LocalFunc("matching_pvp")

---- 报名
function LF.player_signup(_player_id)
	local target_vec = nil

	if basefunc.chk_player_is_real(_player_id) then
		target_vec = LD.signuped_real_player_pool
        --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx player_signup real:",basefunc.tostring({_player_id,DATA.my_id}))
	else
		target_vec = LD.signuped_tuoguan_pool

        local _pi = DATA.all_player_info[_player_id]

        --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx player_signup tuoguan:",basefunc.tostring(_pi))

        if _pi.pvp_real_user_id and LD.signuped_real_player_pool[_pi.pvp_real_user_id] then
            LD.signuped_real_player_pool[_pi.pvp_real_user_id].tg_user_id = _player_id
        end
	end

	target_vec[_player_id] =  {
			player_id = _player_id ,
			match_time = os.time(),
			match_index = nil ,
		}

	return {result = 0}
end

-- by lyx 2021-6-3 ： 供外部模块调用，得到玩家匹配信息
function LF.get_player_matching_info(_player_id)
    if basefunc.chk_player_is_real(_player_id) then
        return LD.signuped_real_player_pool[_player_id]
    else
        return LD.signuped_tuoguan_pool[_player_id]
    end
end

---- 获得 匹配池的 新 索引
function LF.gen_match_pool_index()
	LD.match_pool_index = LD.match_pool_index + 1
	if LD.match_pool_index > LD.match_pool_index_max then
		LD.match_pool_index_max = 1
	end
	return LD.match_pool_index
end

---- 分配玩家到匹配池中
-- modify by lyx 2021-6-3
function LF.dis_player_to_matching_pool(_player_id)
	local match_index = nil

    -- 尝试匹配
    match_index = DATA.duanwei_lib.seatch_matching_pool_player(LD.matching_pool,_player_id,
                LD.duanwei_match_score_diff,LD.duanwei_match_fight_diff)

    -- 尝试失败，参数 扩大 再次尝试
    if not match_index then
        DATA.duanwei_lib.seatch_matching_pool_player(LD.matching_pool,_player_id,
                LD.duanwei_match_score_diff * 2,LD.duanwei_match_fight_diff * 2)
    end

    if match_index then
        table.insert(LD.matching_pool[match_index],_player_id)
    else
        ---- 没有分配成功，就新开一个匹配组    
		local new_pool_id = LF.gen_match_pool_index()
		match_index = new_pool_id
		LD.matching_pool[new_pool_id] = { _player_id }
    end

	return match_index
end

---- 从匹配池中删除
function LF.delete_from_matching_pool( _pool_index , _player_id)
	local pool_data = LD.matching_pool[_pool_index]
	if pool_data then
		for _key,player_id in pairs(pool_data) do
			if _player_id == player_id then
				table.remove( pool_data , _key )

				break
			end
		end
	end
end

---- 处理匹配，
function LF.deal_match()
	
	---- 对每一个没有匹配的 
	for player_id , data in pairs(LD.signuped_real_player_pool) do

        -- 先尝试专用的 托管配对
        local _tg_data = data.tg_user_id and LD.signuped_tuoguan_pool[data.tg_user_id]
        if _tg_data then
            if data.match_index then
                table.insert(LD.matching_pool[data.match_index],data.tg_user_id)
                _tg_data.match_index = data.match_index
            else
                local new_pool_id = LF.gen_match_pool_index()
                LD.matching_pool[new_pool_id] = { 
                    player_id,
                    data.tg_user_id,
                 }
                 _tg_data.match_index = new_pool_id
                 data.match_index = new_pool_id
            end
        end

        -- 尝试真人匹配
		if not data.match_index then
			local matching_pool_id = LF.dis_player_to_matching_pool(player_id)
			data.match_index = matching_pool_id
		end
	end

	------ 遍历已经匹配好的用户，全部送去分发 进房间
	for _id , _player_vec in pairs(LD.matching_pool) do
		if #_player_vec == DATA.seat_count then

			DATA.common_matching.add_distribution_players(_player_vec)

			---- 清掉每个人的数据
			for _,_player_id in pairs(_player_vec) do
				LD.signuped_tuoguan_pool[_player_id] = nil
				LD.signuped_real_player_pool[_player_id] = nil
			end

			LD.matching_pool[_id] = nil
		end
	end

end

function LF.update(_dt)

    local _now = os.time()

	----- 先呼叫 托管
    if _now - LD.last_req_tuoguan >= LD.req_tuoguan_interval then
        LD.last_req_tuoguan = _now
        LF.req_tuoguan_everyone()
    end

	---- 处理匹配
    if _now - LD.last_deal_match >= LD.deal_match_interval then
        LD.last_deal_match = _now
        LF.deal_match()
    end

end

----- 退出游戏
function LF.player_exit_game(_player_id)
	local player_data = nil
	if basefunc.chk_player_is_real(_player_id) then
		player_data = LD.signuped_real_player_pool[_player_id]
	else
		player_data = LD.signuped_tuoguan_pool[_player_id]
	end
	 
	if player_data and player_data.match_index then
		LF.delete_from_matching_pool( player_data.match_index , _player_id )
	end

	LD.signuped_real_player_pool[_player_id] = nil
	LD.signuped_tuoguan_pool[_player_id] = nil

	return {result = 0}
end

---- 为 每个玩家呼叫专用托管
function LF.req_tuoguan_everyone()

    local _now = os.time()
    local _time_out = skynet.getcfgi("req_tg_timeout",5)
    for _uid,_d in pairs(LD.signuped_real_player_pool) do
        if not _d.tg_user_id and (not _d.req_tg_time or _now - _d.req_tg_time > _time_out) then

            local _usinfo = DATA.all_player_info[_uid]

            _d.req_tg_time = _now
            local _game_info = 
            {
                match_name = DATA.game_mode ,
                game_id = DATA.game_id ,
                game_type = DATA.game_type ,
                mgr_id = DATA.my_id,

                
                pvp_real_user_id = _uid,
                fight = _usinfo.fight,
                pvp_score = _usinfo.pvp_score,
                pvp_grade = _usinfo.pvp_grade,
                pvp_level = _usinfo.pvp_level,
            }    

            print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx req_tuoguan_everyone:",basefunc.tostring(_game_info))
            skynet.send( DATA.service_config.tuoguan_service , "lua" , "assign_tuoguan_player" , 1 , _game_info )
        end
    end
end

---- 初始化
function LF.init()
	

end


return LF

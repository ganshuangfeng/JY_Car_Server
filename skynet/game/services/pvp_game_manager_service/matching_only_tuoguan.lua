-------- 最能叫托管来匹配
--[[
	
--]]

local skynet = require "skynet_plus"
local base=require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
require "normal_enum"
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.matching_only_tuoguan_protect = {}
local PROTECT = DATA.matching_only_tuoguan_protect

---- 常备托管数量
PROTECT.min_tuoguan_num = 10

--- 已经报名的 托管池 , key 是 player_id , value 是 { player_id = , match_time = 已经匹配的时间 , tuoguan_cooler = 可以加托管的冷却计数 , match_index = 所在的匹配池的索引 (没有匹配就是nil) }
PROTECT.signuped_tuoguan_pool = {}

---- 已经报名的 真人池 , key 是 player_id , value 是 { player_id = , match_time = 已经匹配的时间 , tuoguan_cooler = 可以加托管的冷却计数 ,  match_index = 所在的匹配池的索引 }
PROTECT.signuped_real_player_pool = {}

----- 处理间隔
PROTECT.deal_delay = 200
PROTECT.deal_delay_count = 0

----- 呼叫托管的间隔
PROTECT.req_tuoguan_delay = 200
PROTECT.req_tuoguan_count = PROTECT.req_tuoguan_delay

----- 强制加一个托管的时间
PROTECT.force_add_tuoguan_match_time = 200
---冷却时间
PROTECT.force_add_tuoguan_match_cool = 100

----- 匹配池的 索引
PROTECT.match_pool_index = 0   --- 
PROTECT.match_pool_index_max = 90000

----- 匹配池
PROTECT.matching_pool = {}

---- 报名
function PROTECT.player_signup(_player_id)
	local target_vec = nil

	if basefunc.chk_player_is_real(_player_id) then
		target_vec = PROTECT.signuped_real_player_pool
	else
		target_vec = PROTECT.signuped_tuoguan_pool
	end



	target_vec[_player_id] =  {
			player_id = _player_id ,
			match_time = 0,
			match_index = nil ,
			tuoguan_cooler = 0 ,
		}

	return {result = 0}
end

---- 获得一个 空闲的托管
function PROTECT.get_free_tuoguan_data()
	for player_id , data in pairs(PROTECT.signuped_tuoguan_pool) do
		if not data.match_index then
			return data
		end
	end
	return nil
end

---- 获得 匹配值的 new 索引
function PROTECT.gen_match_pool_index()
	PROTECT.match_pool_index = PROTECT.match_pool_index + 1
	if PROTECT.match_pool_index > PROTECT.match_pool_index_max then
		PROTECT.match_pool_index_max = 1
	end
	return PROTECT.match_pool_index
end

---- 分配玩家到匹配池中
function PROTECT.dis_player_to_matching_pool(_player_id)
	local is_dis = false
	local match_index = nil

	--[[for _pool_index , pool_data in pairs(PROTECT.matching_pool) do
		if #pool_data < DATA.seat_count then
			------- 检查条件.... 比如战力值 等等。 (这里先直接过)
			is_dis = true
			
			pool_data[#pool_data + 1] = _player_id

			match_index = _pool_index
			break
		end
	end--]]

	---- 没有分配成功，就新开一个匹配组
	if not is_dis then
		local new_pool_id = PROTECT.gen_match_pool_index()
		match_index = new_pool_id
		PROTECT.matching_pool[new_pool_id] = { _player_id }
	end

	return match_index
end

---- 从匹配池中删除
function PROTECT.delete_from_matching_pool( _pool_index , _player_id)
	local pool_data = PROTECT.matching_pool[_pool_index]
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
function PROTECT.deal_match()
	
	---- 对每一个没有匹配的 
	for player_id , data in pairs(PROTECT.signuped_real_player_pool) do

		if not data.match_index then
			------
			local matching_pool_id = PROTECT.dis_player_to_matching_pool(player_id)

			data.match_index = matching_pool_id
		end

		---- 如果 已经匹配咯，并且长时间等待，加一个托管过来
		if data.match_index and data.match_time >= PROTECT.force_add_tuoguan_match_time and data.tuoguan_cooler <= 0 then
			local tuoguan_data = PROTECT.get_free_tuoguan_data()
			if tuoguan_data then
				
				local match_vec = PROTECT.matching_pool[ data.match_index ]

				if match_vec and #match_vec < DATA.seat_count then
					match_vec[#match_vec + 1] = tuoguan_data.player_id

					tuoguan_data.match_index = data.match_index

					data.tuoguan_cooler = PROTECT.force_add_tuoguan_match_cool
				end

			end
		end

	end

	------ 遍历已经匹配好的用户，全部送去分发 进房间
	for _id , _player_vec in pairs(PROTECT.matching_pool) do
		if #_player_vec == DATA.seat_count then
			DATA.common_matching.add_distribution_players(_player_vec)

			---- 清掉每个人的数据
			for _key,_player_id in pairs(_player_vec) do
				PROTECT.signuped_tuoguan_pool[_player_id] = nil
				PROTECT.signuped_real_player_pool[_player_id] = nil
			end

			PROTECT.matching_pool[_id] = nil
		end
	end

end

function PROTECT.update(_dt)
	----- 先呼叫 托管
	PROTECT.req_tuoguan_count = PROTECT.req_tuoguan_count + _dt
	if PROTECT.req_tuoguan_count >= PROTECT.req_tuoguan_delay then
		PROTECT.req_tuoguan_count = 0

		PROTECT.req_tuoguan()
	end

	---- 处理匹配
	PROTECT.deal_delay_count = PROTECT.deal_delay_count + _dt
	if PROTECT.deal_delay_count >= PROTECT.deal_delay then
		PROTECT.deal_delay_count = 0

		PROTECT.deal_match()
	end

	------ 计算 已经在 匹配的时间
	for player_id , data in pairs(PROTECT.signuped_real_player_pool) do
		if data.match_index then
			data.match_time = data.match_time + _dt
			data.tuoguan_cooler = data.tuoguan_cooler - _dt
		end
	end

end

----- 退出游戏
function PROTECT.player_exit_game(_player_id)
	local player_data = nil
	if basefunc.chk_player_is_real(_player_id) then
		player_data = PROTECT.signuped_real_player_pool[_player_id]
	else
		player_data = PROTECT.signuped_tuoguan_pool[_player_id]
	end
	
	---- 如果这里没有，说明已经被分配出去了
	--if not player_data then
	--	{result = 2025 }
	--end

	if player_data and player_data.match_index then
		PROTECT.delete_from_matching_pool( player_data.match_index , _player_id )
	end

	PROTECT.signuped_real_player_pool[_player_id] = nil
	PROTECT.signuped_tuoguan_pool[_player_id] = nil

	return {result = 0}
end

---- 先呼叫托管备用
function PROTECT.req_tuoguan()
	
	local free_tuoguan_num = 0

	for player_id ,data in pairs(PROTECT.signuped_tuoguan_pool) do
		if not data.match_index then
			free_tuoguan_num = free_tuoguan_num + 1
		end
	end

	local need_add = PROTECT.min_tuoguan_num - free_tuoguan_num

	local _game_info = 
	{
		match_name = DATA.game_mode ,
		game_id = DATA.game_id ,
		game_type = DATA.game_type ,
		mgr_id = DATA.my_id,
	}
	
	print("xxx--------------------only_tuoguan matching  req_tuoguan:" , need_add)

	if need_add > 0 then
		skynet.send( DATA.service_config.tuoguan_service , "lua" , "assign_tuoguan_player" , need_add , _game_info )	
	end

end

---- 初始化
function PROTECT.init()
	

end


return PROTECT

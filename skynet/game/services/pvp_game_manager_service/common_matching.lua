
-- 游戏匹配 ， 
--[[
	将 通过匹配规则 匹配好的人 通过一定的分发规则 , 将人分到对应的桌子上
	
--]]
local basefunc = require "basefunc"
require"printfunc"

local skynet = require "skynet_plus"
require "skynet.manager"
local base=require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
require "normal_enum"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LF = base.LocalFunc("common_matching")
local LD = base.LocalData("common_matching",{
	-- 最小桌子数
	min_table_num = 3,
	-- 最多空闲房间数
	max_free_room_num = 2,

	-- 每次最大分配数
	once_max_distribution = 30,

	-- 销毁房间cd 
	destroyRoomCountDownIn = 300,
	-- 销毁 计数
	destroyRoomCountDown = 0,
	---- 分发队列
	distribution_queue = basefunc.queue.new(),
	---- room 自增id
	room_count_id = 0,
	------ 一个房间的桌子数
	room_table_num = nil,

	---- 空闲的桌子
	free_table_room_map = {} ,
	--- 繁忙的桌子
	busy_table_room_map = {} ,
	---- 运行的桌子里的人
	running_game = {} ,
	----所有可用的桌子数
	all_table_count = 0 ,
})

--创建房间id
function LF.create_room_id()
	LD.room_count_id = LD.room_count_id + 1
	return DATA.my_id.."_room_"..LD.room_count_id
end

---- 创建房间
function LF.new_room()
	local room_id = LF.create_room_id()
	if room_id then
		--创建房间
		DATA.game_room_service_type = GAME_TYPE_ROOM[DATA.game_type]
		local ret,state = skynet.call(DATA.service_config.node_service,"lua","create",nil,
						DATA.game_room_service_type,
						room_id, { mgr_id = DATA.my_id, game_mode = DATA.game_mode, game_id = DATA.game_id , map_id = DATA.config.game_rule.map_id })
		if not ret then
			print(string.format("common_matching error:call  state:%s",state))
			return
		end
		if not LD.room_table_num then
			local num = nodefunc.call(room_id,"get_free_table_num")
			if num == "CALL_FAIL" then
				print(string.format("common_matching error:call get_free_table_num room_id:%s",room_id))
				return
			else
				LD.room_table_num = num
			end
		end
		LD.free_table_room_map[room_id] = LD.room_table_num
		LD.all_table_count = LD.all_table_count + LD.room_table_num
	end
end

function LF.new_table(_game_tag)
	local room_id
	for id,v in pairs(LD.free_table_room_map) do
		room_id=id
		break
	end

	---- 没有房间就先创建
	if not room_id then
		LF.new_room()
		for id,v in pairs(LD.free_table_room_map) do
			room_id = id
			break
		end
	end
	if room_id then
		LD.free_table_room_map[room_id] = LD.free_table_room_map[room_id] - 1
		LD.all_table_count = LD.all_table_count - 1
		if LD.free_table_room_map[room_id] == 0 then
			LD.busy_table_room_map[room_id] = LD.free_table_room_map[room_id]
			LD.free_table_room_map[room_id] = nil
		end
		if LD.all_table_count < LD.min_table_num then
			LF.new_room()
		end

		--创建桌子
		local t_num = nodefunc.call(room_id,"new_table",
									{	
										game_type = DATA.game_type,
										game_mode = DATA.game_mode,
										game_id = DATA.game_id
									})
		if t_num=="CALL_FAIL" then
			print(string.format("common_matching error:call new_table room_id:%s",room_id))
			return nil
		end
		return room_id,t_num
	end
	return nil
end

----- 分发队列，让匹配好的人 都进入桌子
function LF.distribution()
	local count=LD.once_max_distribution
	while count>0 do
		if LD.distribution_queue:empty() then
			break
		end

		local players = LD.distribution_queue:pop_front()

		local room_id , t_num = LF.new_table()
		if room_id and t_num then
			LD.running_game[room_id] = LD.running_game[room_id] or {}
			LD.running_game[room_id][t_num] = players
			dump(players,"xxxxxxxxdistributionxxxxxxxxx")
			for i,player_id in ipairs(players) do
				DATA.all_player_info[player_id].status = "gaming"
				DATA.all_player_info[player_id].room = room_id
				DATA.all_player_info[player_id].table = t_num

				nodefunc.send(player_id, DATA.func_name.enter_room_msg , room_id , t_num , i )

			end

			count=count-1
		end
	end
end

---- 销毁房间
function LF.destroyRoom()
	---- 待分发队列 的人数
	local player_num = LD.distribution_queue:size() or 0
	if LD.room_table_num and LD.all_table_count - player_num > LD.room_table_num*LD.max_free_room_num then
		for id,v in pairs(LD.free_table_room_map) do
			if v == LD.room_table_num then
				LD.free_table_room_map[id] = nil
				LD.all_table_count = LD.all_table_count - LD.room_table_num
				nodefunc.send(id,"destroy")
				if LD.all_table_count-player_num <= LD.room_table_num*LD.max_free_room_num then
					break
				end
			end
		end
	end
end


---- 已匹配 添加到 待分配队列中
function LF.add_distribution_players(_players)
	---- 加入分配队列，打上=状态，此时不能 退出
	for i,player_id in ipairs(_players) do
		DATA.all_player_info[player_id].status = "wait_table"
	end

	LD.distribution_queue:push_back(_players)
end

---- 获取 桌子信息
function LF.get_table_info(_room_id , _t_num )
	return LD.running_game[_room_id] and LD.running_game[_room_id][_t_num] or nil
end

---- 一桌完成游戏
function LF.table_finish(_room_id,_t_num )
	print("LF.table_finish!!",_room_id,_t_num)
	---清理
	if _room_id and _t_num and LD.running_game[_room_id] and LD.running_game[_room_id][_t_num] then
		local players = LD.running_game[_room_id][_t_num]
		
		LD.running_game[_room_id][_t_num] = nil
	end

end


-- 归还桌子
function LF.return_table(_room_id,_t_num )

	LD.all_table_count = LD.all_table_count + 1

	if LD.free_table_room_map[_room_id] then
		LD.free_table_room_map[_room_id] = LD.free_table_room_map[_room_id] + 1
	elseif LD.busy_table_room_map[_room_id] then
		LD.busy_table_room_map[_room_id] = LD.busy_table_room_map[_room_id] + 1
		LD.free_table_room_map[_room_id] = LD.busy_table_room_map[_room_id]
		LD.busy_table_room_map[_room_id] = nil
	else
		skynet.fail(string.format("common_matching table_finish error:room_id not exist room_id:%s",_room_id))
		return 
	end

end

function LF.matching_update(dt)
	LF.distribution()
	LD.destroyRoomCountDown = LD.destroyRoomCountDown + dt
	if LD.destroyRoomCountDown >= LD.destroyRoomCountDownIn then
		LD.destroyRoomCountDown = 0
		LF.destroyRoom()
	end
end

function LF.init()
	LD.free_table_room_map = {}
	LD.busy_table_room_map = {}
	LD.running_game = {}
	LD.all_table_count = 0
	
end


return LF

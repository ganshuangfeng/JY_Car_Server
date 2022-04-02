local basefunc = require "basefunc"
local base=require "base"
local skynet = require "skynet_plus"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA
require "driver_room_service.game_scene.driver_map_award_manager"
local driver_map_manager = basefunc.create_hot_class("driver_map_manager")
local C = driver_map_manager

--[[
	
--]]


function C:ctor(_d , _map_cfg)
	self.d=_d
	self.d.single_obj["driver_map_manager"] = self

	--- 配置
	self.map_cfg = _map_cfg

	--- 道路配置
	self.road_cfg = basefunc.deepcopy(_map_cfg.road_cfg_data)
	--- 刷新事件配置
	--self.award_create_event_cfg = basefunc.deepcopy(_map_cfg.road_award_event)

	self:create_map()
end

function C:destroy()
	self.d.single_obj["driver_map_manager"]=nil
end

function C:create_map()
	self.d.map_length = self.map_cfg.map_length
	self.d.map_start_id = self.map_cfg.start_index
	self.d.map_end_id = self.map_cfg.end_index
	self.d.map_game_over_circle = self.map_cfg.game_over_circle

	----- 创建 地图 道路 实体
	if self.road_cfg then
		--dump(self.road_cfg , "xxxxx---------------------------self.road_cfg:")

		for road_id , road_data in pairs(self.road_cfg) do
			repeat
				if road_id > self.d.map_length then
					break
				end

				self.d.map_road[ road_id ] = {
					road_id = road_id ,
					type = DATA.game_status_type.road , 
					road_award_type = road_data.road_award_type  , 
				}

			until true
		end

		----- 创建 地图奖励
		basefunc.hot_class.driver_map_award_manager.new( self.d , self.road_cfg )

	end

end

--------- 获得一个  空白的道路

function C:get_map_road_vec( _selete_type , _select_data )
	local for_select_vec = {}
	local _select_data = _select_data or {}

	if _selete_type == "empty" then
		for road_id , road_data in pairs( self.d.map_road ) do
			--- 本身就是空，或者，是空表
			if not self.d.map_barrier[road_id] or not next(self.d.map_barrier[road_id]) then
				for_select_vec[#for_select_vec + 1] = road_id
			end
		end
	elseif _selete_type == "empty_not_carpos" then
		---- 计算出车的位置 road_id
		local car_road_id_map = {}
		for no , car_data in pairs(self.d.car_info) do
			car_road_id_map[ PUBLIC.get_grid_id_quick(self.d , car_data.pos ) ] = true
		end


		for road_id , road_data in pairs( self.d.map_road ) do
			--- 本身就是空，或者，是空表 ; 并且这个位置
			if (not self.d.map_barrier[road_id] or not next(self.d.map_barrier[road_id]) ) and not car_road_id_map[road_id] then
				for_select_vec[#for_select_vec + 1] = road_id
			end
		end

	elseif _selete_type == "empty_not_carpos_or_enemy_barrier" then
		---- 计算出车的位置 road_id
		local car_road_id_map = {}
		for no , car_data in pairs(self.d.car_info) do
			car_road_id_map[ PUBLIC.get_grid_id_quick(self.d , car_data.pos ) ] = true
		end

		for road_id , road_data in pairs( self.d.map_road ) do
			--- 本身就是空，或者，是空表
			if not car_road_id_map[road_id] then  --- 前提是不能有车，这个位置
				if ( not self.d.map_barrier[road_id] or not next(self.d.map_barrier[road_id]) ) then
					for_select_vec[#for_select_vec + 1] = road_id
				else
					for b_no , b_obj in pairs( self.d.map_barrier[road_id] ) do
						if _select_data.group and _select_data.group ~= b_obj.group then
							for_select_vec[#for_select_vec + 1] = road_id
							break
						end
					end
				end
			end

		end

	elseif _selete_type == "all" then
		for road_id , road_data in pairs( self.d.map_road ) do
			for_select_vec[#for_select_vec + 1] = road_id
		end

		return for_select_vec

	elseif _selete_type == "all_no_4_angle" then
		for road_id , road_data in pairs( self.d.map_road ) do
			for_select_vec[#for_select_vec + 1] = road_id
		end

		return for_select_vec

	elseif _selete_type == "front_and_no_enemy" then
		if not _select_data.is_move_reverse then
			for i = 1 , _select_data.select_num do
				local select_road = _select_data.now_road_id + i 
				local road_id = (select_road > self.d.map_length) and (select_road - self.d.map_length) or select_road
				for_select_vec[#for_select_vec + 1] = road_id
			end
		else
			for i = 1 , _select_data.select_num do
				local select_road = _select_data.now_road_id - i
				local road_id = (select_road <= 0) and (select_road + self.d.map_length) or  select_road
				for_select_vec[#for_select_vec + 1] = road_id
			end
		end
		----- 避免停在相同位置
		local other_cars = PUBLIC.get_game_obj_by_type( self.d , _select_data._car , "other" )
		--dump(other_cars , "xxxx-----------------xxxxxxxxxxxxxx__other_cars ")
		if other_cars and type(other_cars) == "table" then
			local canot_stay_road_id_map = {}
			for key,car_data in ipairs( other_cars ) do
				canot_stay_road_id_map[#canot_stay_road_id_map + 1] = PUBLIC.get_grid_id_quick( self.d, car_data.pos )
				print("66666666666666666,",canot_stay_road_id_map[#canot_stay_road_id_map] )
			end
			for key,data in pairs(for_select_vec) do
				for i,road_id in pairs(canot_stay_road_id_map) do
					if road_id == data then
						table.remove( for_select_vec , key )
					end
				end
			end
		end

		return for_select_vec

	elseif _selete_type == "front" then  ---- 这个方向永远按 默认的正方向算
		--print("999999999999999999,",_select_data.is_move_reverse)
		if not _select_data.is_move_reverse then
			for i = 1 , _select_data.select_num do
				local select_road = _select_data.now_road_id + i
				local road_id = (select_road > self.d.map_length) and (select_road - self.d.map_length) or select_road
				for_select_vec[#for_select_vec + 1] = road_id
			end
		else
			for i = 1 , _select_data.select_num do
				local select_road = _select_data.now_road_id - i
				local road_id = (select_road <= 0) and (select_road + self.d.map_length) or  select_road
				for_select_vec[#for_select_vec + 1] = road_id
			end
		end
		return for_select_vec
	elseif _selete_type == "can_double_award" then
		for road_id , data in pairs( self.d.map_road_award ) do
			if DATA.can_double_award_type_id_to_award_extra_num_name[data.type_id] then
				for_select_vec[#for_select_vec + 1] = road_id
			end
		end

		return for_select_vec
	end

	local tar_vec = {}

	if _select_data.select_num then
		for i = 1,_select_data.select_num do
			if #for_select_vec > 0 then
				local tar_index = math.random(#for_select_vec)
				tar_vec[#tar_vec + 1] = for_select_vec[tar_index]

				table.remove( for_select_vec ,tar_index )
			end
		end
	else
		return for_select_vec
	end

	return tar_vec
end


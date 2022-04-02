--------------------- 技能的 条件判断的 函数库

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA



-------- 判断当前车 的位置 是否是有 敌方 车
function PUBLIC.check_pos_have_enemy(_d , _obj)
	local all_enemy = PUBLIC.get_game_obj_by_type( _d , _obj , "enemy" )
	--dump(all_enemy , "xxx-----------------------------------all_enemy:")
	local my_pos = _obj.pos

	local is_have = false
	if all_enemy and type(all_enemy) == "table" then
		for key,data in pairs(all_enemy) do
			if PUBLIC.get_grid_id_quick(_d , data.pos)  == PUBLIC.get_grid_id_quick(_d , my_pos)  then
				is_have = true
				break
			end
		end
	end

	return is_have
end

------- 判断自己是否停在了 敌人 之前 or 之后
--[[
	_dir 是方向 1是在其前，2是在其后
--]]
function PUBLIC.check_is_in_enemy_range(_d , _obj , _dir , _range_num)

	local all_enemy = PUBLIC.get_game_obj_by_type( _d , _obj , "enemy" )
	--dump(all_enemy , "xxx-----------------------------------all_enemy:")
	----- 我的运动方向，1是正方向
	--local my_move_dir = 1
	--if PUBLIC.get_tag( _obj , "move_reverse" ) then
	--	my_move_dir = -1
	--end

	--local my_pos = PUBLIC.get_grid_id_quick(_d , _obj.pos)

	local is_have = false
	if all_enemy and type(all_enemy) == "table" then
		for key,data in pairs(all_enemy) do
			--local e_pos = PUBLIC.get_grid_id_quick(_d , data.pos)

			--[[local dis = 0

			if _dir == 1 then
				dis = my_pos - e_pos 
			elseif _dir == 2 then
				dis = e_pos - my_pos
			end

			if ( my_move_dir == 1 and ( (dis > 0 and dis <= _range_num) or (dis < 0 and _d.map_length + dis <= _range_num ) ) ) or
				( my_move_dir == -1 and ( (dis < 0 and math.abs(dis) <= _range_num) or (dis > 0 and _d.map_length - dis <= _range_num ) ) ) then

				is_have = true
				break
			end--]]

			if PUBLIC.check_pos_range( _d , _obj.pos , PUBLIC.get_tag( _obj , "move_reverse" ) , data.pos , _dir , _range_num ) then
				is_have = true
				break
			end	

		end
	end

	return is_have
end

---- _dir 是方向 1是在其前，2是在其后
function PUBLIC.check_pos_range( _d , _checker_pos , _checker_move_reverse , _other_pos , _dir , _range_num )
	local dis = 0

	local my_pos = PUBLIC.get_grid_id_quick(_d , _checker_pos )
	local e_pos = PUBLIC.get_grid_id_quick(_d , _other_pos )
	local my_move_dir = _checker_move_reverse and -1 or 1
	print("1111111111111111111111111111111111,",my_move_dir)

	if _dir == 1 then
		dis = my_pos - e_pos 
	elseif _dir == 2 then
		dis = e_pos - my_pos
	end

	if ( my_move_dir == 1 and ( (dis > 0 and dis <= _range_num) or (dis < 0 and _d.map_length + dis <= _range_num ) ) ) or
		( my_move_dir == -1 and ( (dis < 0 and math.abs(dis) <= _range_num) or (dis > 0 and _d.map_length - dis <= _range_num ) ) ) then
		print("555555555555555555555555555555555555555555555555555555555555555555555555")
		return true
	end

	return false
end


------- 判断 当前位置是否有 敌方 路障
function PUBLIC.check_is_have_enemy_luzhang(_d , _car )
	
	if _car then
		local road_id = PUBLIC.get_grid_id_quick( _d , _car.pos) 
		if road_id and _d.map_barrier and _d.map_barrier[road_id] then
			local barrier_vec = _d.map_barrier[road_id]

			for _no , road_barrier in pairs(barrier_vec) do
				if road_barrier.group ~= _car.group then
					-----
					return true
				end
			end
		end
	end

	return false
end

------- 获得两个地图格子的 距离
function PUBLIC.get_map_road_dis(_d , _road_id_1 , _road_id_2)
	local dis = 10000

	if _d and _d.single_obj and _d.single_obj["driver_map_manager"] then
		local map_manager = _d.single_obj["driver_map_manager"]

		local road_1_pos = map_manager.road_cfg[ _road_id_1 ].pos
		local road_2_pos = map_manager.road_cfg[ _road_id_2 ].pos

		dis = math.sqrt( (road_2_pos[1] - road_1_pos[1]) ^ 2 + (road_2_pos[2] - road_1_pos[2]) ^ 2 )

		return dis
	end
	return dis
end

---- 获取两个格子是否同一边
function PUBLIC.get_map_road_same_side(_d , _road_id_1 , _road_id_2)
	local is_same_side = false

	if _d and _d.single_obj and _d.single_obj["driver_map_manager"] then
		local map_manager = _d.single_obj["driver_map_manager"]

		local side_1 = map_manager.road_cfg[ _road_id_1 ].side
		local side_2 = map_manager.road_cfg[ _road_id_2 ].side

		for _side , _v in pairs(side_1) do
			if side_2[_side] then
				is_same_side = true
				break
			end
		end

		--return is_same_side
	end
	return is_same_side
end

---- 

----- 获取 直线 范围格子的敌人 ( _owner 是路面障碍 )
function PUBLIC.get_line_range_enemy_car( _d , _owner , _range)
	if _owner.kind_type ~= DATA.game_kind_type.road_barrier then
		return {}
	end

	local my_group = _owner.group
	local my_road_id = _owner.road_id

	local enemy_car = {}
	for key,car_data in pairs(_d.car_info) do
		if car_data.group ~= my_group then
			local car_road_id = PUBLIC.get_grid_id_quick( _d , car_data.pos )
			local dis = car_road_id - my_road_id

			---- 距离 小于 _range
			if math.abs(dis) <= _range or ( _d.map_length - math.abs(dis)) <= _range then
				enemy_car[#enemy_car + 1] = car_data
			end

			
		end
	end

	return enemy_car
end

------ 检查 地面路障 对应的车 在移动
function PUBLIC.check_is_barrier_car_moving( _d , _barrier )
	local seat_num = _barrier.seat_num
	local is_moving = false

	if _d.car_info then
		for _no , _car_data in pairs(_d.car_info) do
			if _car_data.seat_num == seat_num and _car_data.is_move then
				is_moving = true

				break
			end
		end
	end

	return is_moving
end

----用于 左右范围 判断
function PUBLIC.check_car_is_near_dilei( _d , _trigger_road_id , _dilei_road_id , range)
	print("66666666666666666666666666666666666666666666666666666")
	if _trigger_road_id >= _dilei_road_id and (_trigger_road_id - _dilei_road_id <= range or _dilei_road_id + _d.map_length - _trigger_road_id <= range) then
		return true
	end
	if _trigger_road_id <_dilei_road_id and (_dilei_road_id -_trigger_road_id <= range or _trigger_road_id + _d.map_length - _dilei_road_id <= range) then
		return true
	end
	return false
end

----是否触发障碍判断 ， 用数格子 判断
function PUBLIC.check_car_is_near_range_barrier(_d , _trigger_road_id , _dilei_road_id , range)
	local is_true =false
	if range%2 ~= 0 then  --- 奇数，是对称的
		is_true = PUBLIC.check_car_is_near_dilei(_d , _trigger_road_id , _dilei_road_id , range / 2 )
	else
		if _trigger_road_id >= _dilei_road_id and (_trigger_road_id - _dilei_road_id <= range/2-1 or _dilei_road_id + _d.map_length - _trigger_road_id <= range/2) then
			is_true = true
		end
		if _trigger_road_id <_dilei_road_id and (_dilei_road_id -_trigger_road_id <= range/2 or _trigger_road_id + _d.map_length - _dilei_road_id <= range/2-1) then
			is_true = true
		end
	end
	return is_true
end

---- 检查某个位置 的范围是否有 敌人车


----- 获得某个位置的奖励类型
function PUBLIC.get_map_road_award_type( _d , _pos )
	local award_type = nil
	local _road_id = PUBLIC.get_grid_id_quick(_d , _pos)

	if _d.map_road and _d.map_road[_road_id] then
		award_type = _d.map_road[_road_id].road_award_type
	end
	return award_type
end


function PUBLIC.get_barriers_owner( _map_barrier_vec )             --拿到某个位置障碍的owner
	-- body
	local barriers = {}
	for key , data in pairs(_map_barrier_vec) do
		barriers[#barriers + 1] = data.owner
	end
	return barriers
end
function PUBLIC.get_barriers_id( _map_barrier_vec )                 -- 拿到某个位置障碍的id
	-- body
	local barriers_id = {}
	for key , data in pairs(_map_barrier_vec) do
		barriers_id[#barriers_id + 1] = data.id
	end
	return barriers_id
end

---------- 方向上的距离， 获取一个 road_id 在 另一个 road_id 前方多少格 ， 带方向的
--[[
	_road_id_1 是起点，
	_road_id_2 是终点，

	起点到终点的  方向上的距离
--]]
function PUBLIC.get_road_id_dir_dis( _d , _road_id_1 , _road_id_2 , _is_move_reverse )
	local dis = _road_id_2 - _road_id_1

	if _is_move_reverse then
		dis = -dis
	end

	if dis < 0 then
		dis = _d.map_length + dis
	end

	return dis
end

function PUBLIC.check_is_car_kind_type(_car)
	return _car.kind_type == DATA.game_kind_type.car
end

----- 获得一个车的当前血量的 百分比
function PUBLIC.get_car_hp_percent( _car )
	if _car.kind_type == DATA.game_kind_type.car then
		return _car.hp / DATA.car_prop_lib.get_car_prop( _car , "hp_max" )
	end
	return 0
end

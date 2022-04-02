local basefunc = require "basefunc"
local base = require "base"
local skynet = require "skynet_plus"

local DATA = base.DATA 
local PUBLIC = base.PUBLIC
local CMD = base.CMD

local running_data_statis_lib = require "driver_room_service.game_scene.running_data_statis_lib"
require "driver_room_service.game_scene.game_run_system"

--local drive_move_test_server = require "drive_move_test_server"

DATA.game_get_tuoguan_data_protect = {}
local C = DATA.game_get_tuoguan_data_protect


function PUBLIC.get_raw_data_to_tuoguan(_d)
	local tuoguan_data = {}
	tuoguan_data = C.get_player_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data = C.get_map_length_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data = C.get_can_double_award_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data = C.get_map_award_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data = C.get_map_barrier_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data = C.get_type_id_2_tool_id_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data = C.get_map_cfg_raw_data_to_tuoguan(_d,tuoguan_data)

	--- 小油门的移动步数
	tuoguan_data.small_youmen_move_step = DATA.chehua_skill_type_id_config[38] and DATA.chehua_skill_type_id_config[38].max_value or 6

	return tuoguan_data
end

function C.get_car_no(seat_num,_d)
	for key,data in pairs(_d.car_info) do
		if seat_num == data.seat_num then
			return data
		end
	end
end

function C.get_player_raw_data_to_tuoguan(_d,tuoguan_data)
	for _s,_id in pairs(_d.p_seat_number) do
		local _car_data = C.get_car_no(_s,_d) or {}
		tuoguan_data[_s] = tuoguan_data[_s] or {}
		tuoguan_data[_s].money = _d.p_info[_s].money      --钱

		if _car_data.id == 2 then   --坦克车的话需要拿到他的子弹数和攻击范围
			local skill_id = 1003       --坦克车头技能

			tuoguan_data[_s]["tank_bullet_num"] = _car_data.skill[skill_id].extra_bullet_num
			tuoguan_data[_s]["tank_attack_range"] =  _car_data.skill[skill_id]:get_attack_range()
			tuoguan_data[_s]["tank_max_bullet_num"] = _car_data.skill[skill_id]:get_max_bullet_num()
		end

		tuoguan_data[_s]["car_pos"] = _car_data.pos     --位置
		tuoguan_data[_s]["car_id"] = _car_data.id  --车id 即车类型
		tuoguan_data[_s]["car_hp"] = _car_data.hp      --当前血量
		tuoguan_data[_s]["car_max_hp"] = _car_data.hp_max
		tuoguan_data[_s]["car_extra_move_step"] = _car_data.extra_move_step
		tuoguan_data[_s]["car_base_at"] = _car_data.base_at
		
		tuoguan_data[_s]["car_sp"] = DATA.car_prop_lib.get_car_prop( _car_data , "sp" ) --经过buff处理的sp
		tuoguan_data[_s]["car_at"] = DATA.car_prop_lib.get_car_prop( _car_data , "at" ) --经过buff处理的at
		tuoguan_data[_s]["sp_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "sp_award_extra_num" ) --经过buff处理的sp_award_extra_num
		tuoguan_data[_s]["at_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "at_award_extra_num" ) --经过buff处理的at_award_extra_num
		tuoguan_data[_s]["hp_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "hp_award_extra_num" ) --经过buff处理的hp_award_extra_num

		tuoguan_data[_s]["small_daodan_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "small_daodan_award_extra_num" ) 
		tuoguan_data[_s]["n2o_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "n2o_award_extra_num" ) 
		tuoguan_data[_s]["tool_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "tool_award_extra_num" ) 
		tuoguan_data[_s]["car_award_extra_num"] = DATA.car_prop_lib.get_car_prop( _car_data , "car_award_extra_num" ) 
		
		--- 拿到buff表
		--tuoguan_data[_s]["buff"] = basefunc.deepcopy(_car_data.buff)
		--- 拿到车上的标签表
		tuoguan_data[_s]["tag"] = tuoguan_data[_s]["tag"] or {}
		_car_data.tag = _car_data.tag or {}
		for tag_name,data in pairs(_car_data.tag) do
			tuoguan_data[_s]["tag"][tag_name] = data.value 
		end
		--- 拿到人上的标签表
		_d.p_info[_s].tag = _d.p_info[_s].tag or {}
		for tag_name,data in pairs(_d.p_info[_s].tag) do
			tuoguan_data[_s]["tag"][tag_name] = data.value 
		end

		---拿到道具表  key = type_id , value = { type_id = x , num = x , spend_mp = x }   
		tuoguan_data[_s]["tools"] = {}
		_d.tools_info[_s] = _d.tools_info[_s] or {}
		for id,data in pairs(_d.tools_info[_s]) do
			if data.num > 0 then
				tuoguan_data[_s]["tools"][data.type_id] = tuoguan_data[_s]["tools"][data.type_id] or {}
				tuoguan_data[_s]["tools"][data.type_id]["type_id"] = data.type_id
				tuoguan_data[_s]["tools"][data.type_id]["num"] = data.num
				tuoguan_data[_s]["tools"][data.type_id]["spend_mp"] = data.spend_mp
			end
		end
	end
	return tuoguan_data
end

function C.get_map_length_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data.map_length = _d.map_length
	return tuoguan_data 
end

function C.get_can_double_award_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data.can_double_award = basefunc.deepcopy(_d.can_double_award)
	return tuoguan_data
end

function C.get_map_award_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data.map_award = tuoguan_data.map_award or {}
	--- 拿到地图奖励表   key = road_id  value = type_id
	for road_id,data in pairs(_d.map_road_award) do
		tuoguan_data.map_award[road_id] = { type_id = data.type_id , is_use = false }
	end
	return tuoguan_data
end

function C.get_map_barrier_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data.map_barrier = tuoguan_data.map_barrier or {}
	--- 拿到地图障碍表
	for road_id,data in pairs(_d.map_barrier) do
		tuoguan_data.map_barrier[road_id] = tuoguan_data.map_barrier[road_id] or {}
		for key,_data in pairs(data) do
			tuoguan_data.map_barrier[road_id][key] = tuoguan_data.map_barrier[road_id][key] or {}
			tuoguan_data.map_barrier[road_id][key].id = _data.id
			tuoguan_data.map_barrier[road_id][key].group = _data.group
			tuoguan_data.map_barrier[road_id][key].no = _data.no
			tuoguan_data.map_barrier[road_id][key].road_id = _data.road_id

		end  
	end
	return tuoguan_data
end

function C.get_type_id_2_tool_id_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data.type_id_2_tool_id = tuoguan_data.type_id_2_tool_id or {}
	for id,data in pairs(DATA.game_tools_config) do
		tuoguan_data.type_id_2_tool_id[data.type_id] = id
	end
	return tuoguan_data
end

function C.get_map_cfg_raw_data_to_tuoguan(_d,tuoguan_data)
	tuoguan_data.map_cfg = tuoguan_data.map_cfg or {}
	for road_id,data in pairs(_d.single_obj["driver_map_manager"].road_cfg) do
		tuoguan_data.map_cfg[road_id] = tuoguan_data.map_cfg[road_id] or {}
		tuoguan_data.map_cfg[road_id].pos = data.pos
	end
	return tuoguan_data
end
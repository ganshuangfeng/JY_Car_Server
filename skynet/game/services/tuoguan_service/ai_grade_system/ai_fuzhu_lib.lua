----- ai 辅助函数库
require "normal_enum"
local skynet = require "skynet_plus"
require "skynet.manager"
require"printfunc"
local nodefunc = require "nodefunc"
local base=require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local PROTECT = DATA.ai_grade_system_protect

----- 检查一个 座位数据 对 一个 type_id 获得的次数
function PROTECT.get_map_award_num( _game_data , _type_id )
	local player_data = _game_data[ _game_data.my_seat ]

	local award_num = 1

	local award_extra_num_name = DATA.can_double_award_type_id_to_award_extra_num_name[_type_id] or nil

	if award_extra_num_name then
		award_num = award_num + player_data[ award_extra_num_name ]
	end

	if player_data.tag[ "double_award" ] and DATA.can_double_award[_type_id] then
		award_num = award_num + 1 
	end

	return award_num
end

---- 位置转road_di
function PROTECT.pos_to_road_id( _game_data , pos )
	local map_length = _game_data.map_length

	return ((pos - 1) % map_length) + 1
end

----- 获得某个 地图 位置上的 奖励id
function PROTECT.get_map_award_data( _game_data , _road_id )
	local map_award = _game_data.map_award[_road_id]

	return map_award
end

----- 获得某个位置上是否有路障 , return data or nil
function PROTECT.get_road_enemy_luzhang( _game_data , _road_id )
	local map_barriers = _game_data.map_barrier[_road_id]

	if map_barriers and type(map_barriers) == "table" then
		for no , data in pairs(map_barriers) do
			if data.id == DATA.map_barrier_name_2_id[ "lanjie_luzhang" ] and data.group ~= _game_data.my_seat then
				return data
			end
		end
	end

	return nil
end

----- 删掉一个 路上障碍
function PROTECT.delete_road_barrier( _game_data ,  _barrier_data )
	local map_barriers = _game_data.map_barrier[_barrier_data.road_id]

	if map_barriers then
		map_barriers[_barrier_data.no] = nil
	end

end



function PROTECT.get_two_road_id_dis(_game_data , _road_id_1,_road_id_2)
	local dis =999999
	if _game_data.map_cfg then
		local road_1_pos = _game_data.map_cfg[_road_id_1].pos
		local road_2_pos = _game_data.map_cfg[_road_id_2].pos

		dis = math.sqrt( (road_2_pos[1] - road_1_pos[1]) ^ 2 + (road_2_pos[2] - road_1_pos[2]) ^ 2 )

		return dis
	end
	return dis

end

----- 排序决策数据
function PROTECT.sort_decision_data(_data)
	for i = 1 , #_data - 1 do
		for j = i + 1 , #_data do
			if _data[i].score < _data[j].score then

				_data[i] , _data[j] = _data[j] , _data[i]

			elseif _data[i].score == _data[j].score then
				if math.random(100) < 50 then
					_data[i] , _data[j] = _data[j] , _data[i]
				end
			end
		end
	end

end



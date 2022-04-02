
----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("hushi_tank_nor_attack" )
C.msg_deal = {}

function C:ctor( _config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	self.at_factor = _config.at_factor

	self.fix_at_value = _config.fix_at_value


end

---- 
function C:init()
	---- 监听消息
	PROTECT.add_msg_listener( self.car_id , self , C.msg_deal )

end

function C:destroy()
	PROTECT.delete_msg_listener( self.car_id , self )
end


function C.msg_deal:on_stay_road(_effect_data , _game_data , _type_id , _gl , _other_data)

	--不是坦克车 直接return
	--if self.car_id ~= 2 then--
	--	return
	--end
	local enemy_road_id = PROTECT.pos_to_road_id(_game_data , _game_data[_game_data.enemy_seat].car_pos)
	local attack_circle_radius = _game_data[_game_data.my_seat].tank_attack_range
	local bullet_num = _game_data[_game_data.my_seat].tank_bullet_num

	if not attack_circle_radius or not bullet_num then 
		return 
	end

	print("xxxxxxxxxxxxxxxxxx-------hushi_tank_nor_attack(ai)")
	--重叠直接return
	if _other_data.road_id == enemy_road_id then
		return
	end

	--攻击范围外直接return
	if attack_circle_radius < PROTECT.get_two_road_id_dis(_game_data , _other_data.road_id , enemy_road_id) then
		return
	end

	for i=1 , bullet_num do
		local effect_value = -self.at_factor * _game_data[_game_data.my_seat].car_base_at + self.fix_at_value
		local enemy_car_hp = _game_data[_game_data.enemy_seat].car_hp
		if effect_value + enemy_car_hp < 0 then
			effect_value = -enemy_car_hp
		end

		_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_hp , tar_seat = _game_data.enemy_seat ,  value = effect_value , gl = _gl  }
	end

end

function C.msg_deal:on_move_in_road( _effect_data , _game_data , _gl , _other_data )
	--不是坦克车 直接return
	--if self.car_id ~= 2 then
	--	return
	--end

	if _other_data.road_id == 1 then

		if _game_data[_game_data.my_seat].tank_bullet_num + 1 <= _game_data[_game_data.my_seat].tank_max_bullet_num then
			_game_data[_game_data.my_seat].tank_bullet_num = _game_data[_game_data.my_seat].tank_bullet_num + 1

			_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_tank_bullet_num , tar_seat = _game_data.my_seat ,  value = 1 , gl = _gl  }
		end
	end
end




return C


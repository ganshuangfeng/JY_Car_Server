
----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("falali_nor_attack" )
C.msg_deal = {}

function C:ctor( _config)
	--- 所属的车id
	print("111111")
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	self.at_factor = _config.at_factor

	self.fix_at_value = _config.fix_at_value

	self.gailv_bfb = _config.gailv_bfb


end

---- 
function C:init()
	---- 监听消息
	PROTECT.add_msg_listener( self.car_id , self , C.msg_deal )

end

function C:destroy()
	PROTECT.delete_msg_listener( self.car_id , self )
end


---- 当 移动到这个格子时
function C.msg_deal:on_move_in_road( _effect_data , _game_data , _gl , _other_data )
	print("11111")
	--if self.car_id ~= 1 then
	--	return
	--end

	if PROTECT.pos_to_road_id(_game_data , _game_data[_game_data.enemy_seat].car_pos) ~= _other_data.road_id then
		return
	end
	print("xxxx-------------effect_module_falali_nor_attack____on_move_in_road")

	local my_car_base_at = _game_data[_game_data.my_seat].car_base_at
	local effect_value = -(my_car_base_at * self.at_factor + self.fix_at_value) 

	local enemy_car_hp = _game_data[_game_data.enemy_seat].car_hp
	if effect_value + enemy_car_hp < 0 then
		effect_value = -enemy_car_hp
	end


	_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_hp , tar_seat = _game_data.enemy_seat ,  value = effect_value , gl = _gl * self.gailv_bfb / 100 }
end

return C


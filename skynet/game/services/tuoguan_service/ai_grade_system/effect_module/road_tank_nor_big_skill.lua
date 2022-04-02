
----- 路面大招

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("road_tank_nor_big_skill" )
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


---- 当 获得这个路上奖励
function C.msg_deal:on_stay_road( _effect_data , _game_data , _type_id , _gl , _other_data )
	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end

	local max_bullet_num = _game_data[_game_data.my_seat].tank_max_bullet_num
	_game_data[_game_data.my_seat].tank_bullet_num = max_bullet_num
	local bullet_num = max_bullet_num


	for i=1 , bullet_num do
		local effect_value = -self.at_factor * _game_data[_game_data.my_seat].car_base_at + self.fix_at_value
		local enemy_car_hp = _game_data[_game_data.enemy_seat].car_hp
		if effect_value + enemy_car_hp < 0 then
			effect_value = -enemy_car_hp
		end
		print("asdasdasd",effect_value)

		_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_hp , tar_seat = _game_data.enemy_seat ,  value = effect_value , gl = _gl  }
	end


	
end

---- 当成道具使用时
function C.msg_deal:on_use_tool( _effect_data , _game_data , _type_id , _gl )
	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end

	C.msg_deal.on_stay_road( self , _effect_data , _game_data , _type_id , _gl )

end

---- 当成 选项选择 ， n 选 1 时
function C.msg_deal:on_select_award( _effect_data , _game_data , _type_id , _gl )
	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end
	
	C.msg_deal.on_stay_road( self , _effect_data , _game_data , _type_id , _gl )

end



return C


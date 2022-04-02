
----- 维修工具

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("tool_wxgj" )
C.msg_deal = {}

function C:ctor( _config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	----增加百分比
	self.add_value_bfb = _config.add_value_bfb


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
function C.msg_deal:on_stay_road( _effect_data , _game_data , _type_id , _gl , _other_data)
	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end

	local value_bfb = self.add_value_bfb

	--- 判断 奖励次数
	local award_num = PROTECT.get_map_award_num( _game_data , _type_id )
	print("xxxx-------------effect_module_wxgj_add_hp____on_stay_road")

	local my_car_hp = _game_data[_game_data.my_seat].car_hp
	local my_car_max_hp = _game_data[_game_data.my_seat].car_max_hp

	local effect_value = self.add_value_bfb / 100 * award_num * _game_data[_game_data.my_seat].car_max_hp 

	if effect_value + my_car_hp > my_car_max_hp then
		effect_value = my_car_max_hp - my_car_hp
	end

	_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_hp , tar_seat = _game_data.my_seat ,  value = effect_value , gl = _gl }

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


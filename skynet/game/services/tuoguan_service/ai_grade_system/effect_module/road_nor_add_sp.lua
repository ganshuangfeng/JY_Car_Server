----- 路面加速度

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("road_nor_add_sp" )
C.msg_deal = {}

function C:ctor( _config )
	--- 所属的车id
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	----增加值
	self.add_value = _config.add_value

end

---- 
function C:init()
	---- 监听消息，以车id 为不同的消息通道
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

	local value = self.add_value

	--- 判断 奖励次数
	local award_num = PROTECT.get_map_award_num( _game_data , _type_id )
	print("xxxx-------------effect_module_add_sp____on_stay_road")

	_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_sp , tar_seat = _game_data.my_seat , value = self.add_value * award_num , gl = _gl }

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

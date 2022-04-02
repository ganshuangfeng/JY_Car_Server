
----- 传送器 效果

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("road_transfer" )
C.msg_deal = {}

function C:ctor( _config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	--- 传送数量
	self.transfer_num = _config.transfer_num


end

---- 
function C:init()
	---- 监听消息
	PROTECT.add_msg_listener( self.car_id , self , C.msg_deal )

end

function C:destroy()
	PROTECT.delete_msg_listener( self.car_id , self )
end

---- 当 获得这个路上奖励 , 
function C.msg_deal:on_stay_road( _effect_data , _game_data , _type_id , _gl , _other_data )
	print("xxxx-------------- road_transfer on_stay_road 1" , _type_id , self.type_id)

	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end
	print("xxxx-------------- road_transfer on_stay_road 2")
	local my_data = _game_data[ _game_data.my_seat ]
	local my_car_id = my_data.car_id
	local now_car_pos = my_data.car_pos

	--- 敌人车位置
	local enemy_road_id = PROTECT.pos_to_road_id( _game_data , _game_data[ _game_data.enemy_seat ].car_pos ) 

	local _select_road = {}

	for i = 1 , self.transfer_num do

		local tar_pos = now_car_pos + i
		local tar_road = PROTECT.pos_to_road_id( _game_data , tar_pos )

		---- 如果这个位置没有敌人车
		if tar_road ~= enemy_road_id then
			_select_road[#_select_road + 1] = tar_road
		end

	end

	---- 对前面 n 格做 发停留消息
	local best_op_data = PROTECT.deal_decision_select_road( _game_data , _select_road , { logic_name = "car_select_road_transfer_obj" , } )

	--dump(best_op_data , "xxx----------------road_transfer  best_op_data")

	---- 把返回的最好的操作的，效果数据直接加上
	if best_op_data and best_op_data.effect_data then
		for key,data in pairs( best_op_data.effect_data ) do

			data.gl = data.gl * _gl

			_effect_data[#_effect_data + 1] = data
		end

	end

end

---- 当成道具使用时
function C.msg_deal:on_use_tool( _effect_data , _game_data , _type_id , _gl )
	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end

	C.msg_deal.on_stay_road( self ,  _effect_data , _game_data , _type_id , _gl )

end

---- 当成 选项选择 ， n 选 1 时
function C.msg_deal:on_select_award( _effect_data , _game_data , _type_id , _gl )
	print("xxxx-------------- road_transfer on_select_award ")

	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end
	
	C.msg_deal.on_stay_road( self , _effect_data , _game_data , _type_id , _gl )

end


return C


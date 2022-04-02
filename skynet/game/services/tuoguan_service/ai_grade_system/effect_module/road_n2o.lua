
----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("road_n2o" )
C.msg_deal = {}

function C:ctor( _config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	self.min_value = _config.min_value

	self.max_value = _config.max_value


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
	if _type_id ~= self.type_id or _gl < PROTECT.ignore_gl then
		return 
	end

	print("氮气处理开始")
	--- 判断 奖励次数
	local award_num = PROTECT.get_map_award_num( _game_data , _type_id )
	print("xxxx-------------effect_module_add_sp____on_stay_road")
	self.min_value = self.min_value * award_num
	self.max_value = self.max_value * award_num

	--local op_data = PROTECT.create_one_decision_op_data( _decision_data.name , DATA.player_op_type.big_youmen , nil )
	--table.insert( _decision_data.op_data , op_data )

	-----由于可能会修改 游戏数据，所以会拷贝出来
	_game_data = basefunc.deepcopy( _game_data )

	local my_data = _game_data[ _game_data.my_seat ]
	local my_car_id = my_data.car_id

	---- 移动长度
	local step_len = self.min_value            

	for i=1 , step_len do
		local stay_gl = 0 * _gl
		local move_in_gl = 1 * _gl

		---- 移动 和 停留 概率得 * 总的移动概率
		stay_gl = stay_gl * _game_data.total_move_gl
		move_in_gl = move_in_gl * _game_data.total_move_gl

		---- 如果概率不够，则不移动了
		if move_in_gl <= 0 then
			break
		end
		
		---- 当前位置修改
		my_data.car_pos = my_data.car_pos + 1

		local now_car_pos = my_data.car_pos

		local now_road = PROTECT.pos_to_road_id( _game_data , now_car_pos )

		-----
		local map_award_data = PROTECT.get_map_award_data( _game_data , now_road )

		---- 移动距离的 效果统计
		_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_move_pos , tar_seat = _game_data.my_seat , value = 1 , gl = move_in_gl }

		---- 发出经过消息
		PROTECT.trriger_msg( my_car_id , "on_move_in_road" , _effect_data , _game_data , move_in_gl , { road_id = now_road } )

	end

	local step_long = self.max_value - self.min_value
	for i=1,step_long do
		local stay_gl = 1/step_long
		local move_in_gl = 1 - ( (i - 1) / step_long )

		stay_gl = stay_gl * _gl
		move_in_gl = move_in_gl * _gl

		---- 移动 和 停留 概率得 * 总的移动概率
		stay_gl = stay_gl * _game_data.total_move_gl
		move_in_gl = move_in_gl * _game_data.total_move_gl

		---- 如果概率不够，则不移动了
		if move_in_gl <= 0 then
			break
		end

		---- 当前位置修改
		my_data.car_pos = my_data.car_pos + 1

		local now_car_pos = my_data.car_pos

		local now_road = PROTECT.pos_to_road_id( _game_data , now_car_pos )

		-----
		local map_award_data = PROTECT.get_map_award_data( _game_data , now_road )

		---- 移动距离的 效果统计
		_effect_data[#_effect_data + 1] = { effect = PROTECT.effect_type.add_move_pos , tar_seat = _game_data.my_seat , value = 1 , gl = move_in_gl }

		---- 发出经过消息
		PROTECT.trriger_msg( my_car_id , "on_move_in_road" , _effect_data , _game_data , move_in_gl  , { road_id = now_road } )

		---- 发出停留消息
		if map_award_data and not map_award_data.is_use then

			map_award_data.is_use = true
			PROTECT.trriger_msg( my_car_id , "on_stay_road" , _effect_data , _game_data , map_award_data.type_id , stay_gl , { road_id = now_road } )

		end
	end
	print("氮气处理结束")

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
	---- 如果不是用的 这个type_id，则返回
	if _type_id ~= self.type_id then
		return 
	end
	
	C.msg_deal.on_stay_road( self ,  _effect_data , _game_data , _type_id , _gl )

end




return C


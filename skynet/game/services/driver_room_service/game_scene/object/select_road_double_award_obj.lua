----- 选择道路的 双倍奖励来双倍

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("select_road_double_award_obj" , "object_class_base" )
C.msg_deal = {}

----- type_id 对应的 任务id
C.type_id_2_skill_id = {
	[1] =  2028,    --- 速度
	[2] =  2028,
	[3] =  2027,   --- 攻击
	[4] =  2027,
	[5] =  2029,   --- 回血
	[6] =  2029, 
	[7] =  2031,   --- 小导弹
	[8] =  2031,
	[36] = 2030,   --- 氮气加速
	[37] = 2030, 
	[55] = 2033,   --- 道具箱
	[56] = 2032,   --- 升级包
}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	self.duration_round = _config.duration_round


	self.seat_num = self.owner.seat_num

end

---- 当 obj 创建之后调用
function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	---- 基类处理
	self.super.init(self)

	---- 操作类型
	self.op_type = DATA.player_op_type.select_road
	---- 操作倒计时
	self.op_timeout = DATA.player_op_timeout["select_road"] or 10 

end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	--监听相关操作返回消息
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )

	self.real_select_road_vec = self.d.single_obj["driver_map_manager"]:get_map_road_vec( "can_double_award" ,
								{  }
							)
end

function C:destroy()
	self.is_run_over = true

	PUBLIC.delete_msg_listener( self.d , self )
end



function C:run()
	--XXX获取可以做的操作
	local op_permit = {
		[ self.op_type ] = true ,
	}

	self.op_data = {
		op_type = self.op_type ,
		seat_num = self.seat_num ,
		op_permit = op_permit ,
		for_select_vec = self.real_select_road_vec ,
		op_timeout = self.op_timeout ,


	}

	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , { player_op = self.op_data }  ,  self.father_process_no )

	--改变游戏状态
	---- 设置 玩家 操作类型
	PUBLIC.open_player_op_status(self.d , self.seat_num , self.op_type )

	
	--打包调用发送
	PUBLIC.send_msg_to_agent( self.d , DATA.msg_type.game_progress )
end

function C.msg_deal:player_op_msg(_op_data)
	if _op_data.base_op_type == self.op_type then

		self:destroy()

		dump(self.real_select_road_vec , "xxxx-----------------------self.real_select_road_vec:".. _op_data.select_index )

		local target_road_id = _op_data.select_index

		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				op_arg_1 = target_road_id ,
				seat_num = self.seat_num ,
				op_data = self.op_data , 
			} } , self.father_process_no
		)

		local map_award = self.d.map_road_award[target_road_id]
		local type_id = map_award and map_award.type_id
		local skill_id = C.type_id_2_skill_id[ type_id ]
		if type_id and DATA.can_double_award_type_id_to_award_extra_num_name[type_id] and skill_id then

			PUBLIC.skill_create_factory( self.d , skill_id , { owner = self.owner } , { life_module = { life_type = "round_num" , life_value = self.duration_round } } )
		end


		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d  )
	end
end


return C


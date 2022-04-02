----- 创建 or 使用 道具 obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("create_or_use_tools_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num

	self.tool_id = _config.tool_id

end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)
	
	---- 操作类型
	self.op_type = DATA.player_op_type.select_tool_op
	---- 操作倒计时
	self.op_timeout = DATA.player_op_timeout["select_tool_op"] or 10 

end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	--监听相关操作返回消息
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )
end

function C:destroy()
	self.is_run_over = true

	PUBLIC.delete_msg_listener( self.d , self )
end

function C:run()
	
	local op_permit = {
		[ self.op_type ] = true ,
	}

	self.op_data = {
		op_type = self.op_type ,
		seat_num = self.seat_num ,
		op_permit = op_permit ,
		for_select_vec = {1 , 2} ,
		tool_id = self.tool_id ,
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

		local target_op_id = _op_data.select_index
		print("xxx-----------------player_op_msg__select_skil" , self.seat_num)
		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				op_arg_1 = target_op_id ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)

		----- 创建 并 使用 技能
		if target_op_id == 1 then
			local data = { owner = self.owner , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
				level = 1 , 
				obj_enum = "create_and_use_tools_obj",
				tool_id = self.tool_id ,
			 }

			local run_obj = PUBLIC.create_obj( self.d , data )
			if run_obj then
				---- 加入 运行系统
				self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
			end

		elseif target_op_id == 2 then
			local data = { owner = self.owner , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
				level = 1 , 
				obj_enum = "create_tools_obj",
				tool_id = self.tool_id ,
			 }

			local run_obj = PUBLIC.create_obj( self.d , data )
			if run_obj then
				---- 加入 运行系统
				self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
			end

		end


		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d )

	end
end

return C


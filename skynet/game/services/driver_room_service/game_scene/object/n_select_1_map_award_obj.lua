----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("n_select_1_map_award_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num
	---- 待选库
	self.select_lib = _config.select_lib

	self.select_num = _config.select_num

	self.is_double = _config.is_double
	--- 是否随机
	self.is_random = _config.is_random

	self.real_select_map = {}
	self.real_select_vec = {}
end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )

	---- 基类处理
	self.super.init(self)
	
	---- 操作类型
	self.op_type = DATA.player_op_type.select_map_award
	self.console = DATA.player_op_type.console
	---- 操作倒计时
	self.op_timeout = DATA.player_op_timeout.select_map_award or 10 

	---- 再选n个
	for i=1,self.select_num do
		if self.is_random then
			if #self.select_lib > 0 then
				local random_index = math.random( #self.select_lib )	
				local tar_data = self.select_lib[random_index]

				self.real_select_map[tar_data.type_id] = tar_data
				self.real_select_vec[#self.real_select_vec + 1] = tar_data.type_id

				table.remove( self.select_lib , random_index )
			end
		else
			if #self.select_lib > 0 then
				local random_index = 1
				
				local tar_data = self.select_lib[random_index]

				self.real_select_map[tar_data.type_id] = tar_data
				self.real_select_vec[#self.real_select_vec + 1] = tar_data.type_id

				table.remove( self.select_lib , random_index )
			end
		end
	end

	dump(self.real_select_vec , "xxxx---------------------self.real_select_vec:")
	dump(self.select_lib , "xxxx---------------------self.select_lib:")
end

function C:wake()
	--监听相关操作返回消息
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )
end

function C:destroy()
	self.is_run_over = true

	PUBLIC.delete_msg_listener( self.d , self )
end

function C:run()
	print("xxx--------------player_nor_op_skill__run")
	--XXX获取可以做的操作
	local op_permit = {
		[ self.op_type ] = true ,
		[ self.console ] = true ,
	}

	self.op_data = {
		op_type = self.op_type ,
		seat_num = self.seat_num ,
		op_permit = op_permit ,
		for_select_vec = self.real_select_vec ,
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

	if _op_data.base_op_type == self.console then
		self:destroy()
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)
		PUBLIC.close_player_op_status( self.d )
	end


	if _op_data.base_op_type == self.op_type then

		self:destroy()

		local target_skill_id = _op_data.select_index
		print("xxx-----------------player_op_msg__select_skil" , self.seat_num)
		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				op_arg_1 = target_skill_id ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)

		----- 创建 技能
		if target_skill_id then

			local award_data = self.real_select_map[target_skill_id]

			self.d.single_obj["driver_map_award_manager"]:create_map_award( award_data , self.owner.pos , self.owner , self.is_double)
		end
		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d )
	end
end


return C


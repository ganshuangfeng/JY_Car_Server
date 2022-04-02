
----- 等待 玩家基础操作  的  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA



local C = basefunc.create_hot_class("player_nor_op_obj" , "object_class_base"  )
C.msg_deal = {}

function C:ctor(_d,  _config )
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num

	-----
	--self.big_youmen_skill_id = _config.big_youmen_skill_id
	--self.small_youmen_skill_id = _config.small_youmen_skill_id

	--- 总共的操作 MP 点数
	self.op_mp = 100

	---- 触发ptg 冲撞技能的 技能id
	self.tri_ptg_base_skill_id = 1026

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( { DATA.game_kind_type.player , DATA.game_kind_type.car } )
	---- 基类处理
	self.super.init(self)
	
	---- 操作类型
	self.op_type = DATA.player_op_type.nor_op
	---- 操作倒计时
	self.op_timeout = DATA.player_op_timeout["nor_op"] or 10

	-----
	self.op_car = PUBLIC.get_car_info_by_data( self.d , self.owner )

	self.op_player = PUBLIC.get_player_info_by_data( self.d , self.owner )


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

	------ 判断标签 ，如果是不能操作
	if PUBLIC.get_tag( self.op_player , "is_canot_nor_op" ) then
		self:destroy()
		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d  )

		---- 发出一个 不能操作 的消息
		PUBLIC.trriger_msg( self.d , "player_canot_nor_op" , { seat_num = self.seat_num } )

		return
	end

	--XXX获取可以做的操作
	local op_permit = {
		[ DATA.player_op_type.big_youmen ] = true ,
		[ DATA.player_op_type.small_youmen ] = true ,
		[ DATA.player_op_type.use_tools ] = true ,
	}

	----- 如果是  平头哥 ， 操作的加上  冲撞操作
	if self.op_car.type == "ptg" then
		op_permit[ DATA.player_op_type.ptg_chongzhuang ] = true
	end

	----- 如果是  地雷车， 操作的加上  地雷安装 操作
	if self.op_car.type == "anzhuangche" then
		op_permit[ DATA.player_op_type.dlc_anzhuang ] = true
	end

	------- 强制 操作权限
	if self.d.debug_nor_op_permit and next( self.d.debug_nor_op_permit ) and not basefunc.chk_player_is_real( self.d.p_info[self.seat_num].id )   then
		local _ , data = next( self.d.debug_nor_op_permit )

		op_permit = data

		table.remove( self.d.debug_nor_op_permit , 1 )
	end


	self.op_data = {
			op_type = self.op_type ,
			seat_num = self.seat_num ,
			op_permit = op_permit ,
			op_timeout = self.op_timeout ,
			op_mp = self.op_mp ,
		}

	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , { player_op = self.op_data }  ,  self.father_process_no)



	--改变游戏状态
	---- 设置 玩家 操作类型
	PUBLIC.open_player_op_status(self.d , self.seat_num , self.op_type )

	--打包调用发送
	dump(DATA.msg_type.game_progress , "xxx----------------DATA.msg_type.game_progress:")
	PUBLIC.send_msg_to_agent( self.d , DATA.msg_type.game_progress )

end

----- 检查 op_mp是否已经不能做任何操作了，
function C:check_op_mp_is_over()
	local is_over = true

	---- 是否够 大小油门
	if self.op_mp >= DATA.player_op_spend_mp.big_youmen or self.op_mp >= DATA.player_op_spend_mp.small_youmen then
		is_over = false
		return is_over
	end

	---- 是否可以放 道具
	local tools_data = self.d.tools_info[ self.seat_num ]

	if tools_data then
		for _tool_id , _tool_data in pairs( tools_data ) do
			if self.op_mp >= _tool_data.spend_mp then
				is_over = false
				break
			end
		end
	end

	return is_over
end


--处理玩家操作消息
function C.msg_deal:player_op_msg(_op_data)
	if _op_data.base_op_type == DATA.player_op_type.big_youmen then
		
		if self.op_mp < DATA.player_op_spend_mp.big_youmen then
			return
		end


		self:destroy()

		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = DATA.player_op_type.big_youmen ,
				op_arg_1 = _op_data.select_index ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)
		---- 确定是哪个车
		local moving_car = DATA.game_info_center.get_next_dis_car( self.d , self.seat_num )

		------ 发送玩家 普通操作 结束消息
		PUBLIC.trriger_msg( self.d , "player_nor_op_over" , { seat_num = self.seat_num , op_type = DATA.player_op_type.big_youmen , trigger = moving_car} )
		print("fasongxiaoxil 444444444444444444444444444444444444444444444444444444")

		--[[self.d.game_run_system:create_add_event_data(
			PUBLIC.create_obj( self.d , { obj_enum = "youmen_obj" , type = "big_youmen" , owner = moving_car , father_process_no = process_id }  ) ,
			1 , "next"
		) --]]

		--PUBLIC.run_obj_create_factory(self.d , self.big_youmen_obj_id , { owner = moving_car , father_process_no = process_id })

		PUBLIC.skill_create_factory( self.d , self.op_car.big_youmen_skill_id , { owner = moving_car }  )


		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d  )

	elseif _op_data.base_op_type == DATA.player_op_type.small_youmen then
		if self.op_mp < DATA.player_op_spend_mp.small_youmen then
			return
		end

		self:destroy()

		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = DATA.player_op_type.small_youmen ,
				op_arg_1 = _op_data.select_index ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)

		---- 确定是哪个车
		local moving_car = DATA.game_info_center.get_next_dis_car( self.d , self.seat_num )

		------ 发送玩家 普通操作 结束消息
		PUBLIC.trriger_msg( self.d , "player_nor_op_over" , { seat_num = self.seat_num ,op_type = DATA.player_op_type.small_youmen , trigger = moving_car} )

		--[[self.d.game_run_system:create_add_event_data(
			PUBLIC.create_obj( self.d , { obj_enum = "youmen_obj" , type = "small_youmen" , owner = moving_car , father_process_no = process_id  } ) ,
			1 , "next"
		) --]]
		--PUBLIC.run_obj_create_factory(self.d , self.small_youmen_obj_id , { owner = moving_car , father_process_no = process_id })

		PUBLIC.skill_create_factory( self.d , self.op_car.small_youmen_skill_id , { owner = moving_car }  )

		PUBLIC.close_player_op_status( self.d  )

	elseif _op_data.base_op_type == DATA.player_op_type.use_tools then
		local tools_data = self.d.tools_info[ self.seat_num ][ _op_data.select_index ]

		if tools_data then
			----- 收集数据
			self.d.running_data_statis_lib.add_game_data( self.d , {
				player_action = {
					op_type = DATA.player_op_type.use_tools ,
					op_arg_1 = _op_data.select_index ,
					seat_num = self.seat_num ,
					op_data = self.op_data ,
				} } , self.father_process_no
			)	


			---- 减点数
			self.op_mp = self.op_mp - tools_data.spend_mp

			---- 如果这个道具会结束，就结束
			if tools_data.is_end_op == 1 or self:check_op_mp_is_over() then
				self:destroy()

				------ 发送玩家 普通操作 结束消息
				PUBLIC.trriger_msg( self.d , "player_nor_op_over" , { seat_num = self.seat_num ,op_type = nil , trigger = moving_car} )
			end

			----- 使用道具
			PUBLIC.use_tools( self.d , self.seat_num , _op_data.select_index )
			
			---- 恢复游戏状态
			PUBLIC.close_player_op_status( self.d  )
		end

	elseif _op_data.base_op_type == DATA.player_op_type.ptg_chongzhuang then
		---- 平头哥 触发冲撞技能

		if self.op_mp < DATA.player_op_spend_mp.ptg_chongzhuang then
			return
		end

		self:destroy()

		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = DATA.player_op_type.ptg_chongzhuang ,
				op_arg_1 = _op_data.select_index ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)

		---- 确定是哪个车
		local moving_car = DATA.game_info_center.get_next_dis_car( self.d , self.seat_num )

		------ 发送玩家 普通操作 结束消息
		PUBLIC.trriger_msg( self.d , "player_nor_op_over" , { seat_num = self.seat_num , op_type = DATA.player_op_type.ptg_chongzhuang , trigger = moving_car} )


		---- 技能id  1026 就是用来触发 ptg 冲撞技能的
		PUBLIC.skill_create_factory( self.d , self.tri_ptg_base_skill_id , { owner = moving_car }  )

		PUBLIC.close_player_op_status( self.d  )

	elseif _op_data.base_op_type == DATA.player_op_type.dlc_anzhuang then
		if self.op_mp < DATA.player_op_spend_mp.dlc_anzhuang then
			return
		end

		self:destroy()

		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = DATA.player_op_type.dlc_anzhuang ,
				op_arg_1 = _op_data.select_index ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)

		---- 确定是哪个车
		local moving_car = DATA.game_info_center.get_next_dis_car( self.d , self.seat_num )

		------ 发送玩家 普通操作 结束消息
		PUBLIC.trriger_msg( self.d , "player_nor_op_over" , { seat_num = self.seat_num , op_type = DATA.player_op_type.dlc_anzhuang , trigger = moving_car} )

		

		PUBLIC.close_player_op_status( self.d  )

	end

end





return C
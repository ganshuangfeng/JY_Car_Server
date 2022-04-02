----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_select_road_create_jinting_barrier_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	self.seat_num = self.owner.seat_num
	------
	self.barrier_id = _config.barrier_id
	----- 选择的道路数量
	self.select_road_num = _config.select_road_num
	----- 选择的道路类型
	self.select_road_type = _config.select_road_type

	------ 是否清掉一个敌人的障碍
	self.is_clear_enemy_barrier = _config.is_clear_enemy_barrier


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

	self.award_group = {
		[1] = {1,2} ,
		[2] = {3,4} ,
		[3] = {5,6} ,
		[4] = {7,8} ,
		[5] = {9,10} ,
		[6] = {11,12} ,
		[7] = {14,15} ,
		[8] = {16,17} ,
		[9] = {18,19} ,
		[10] = {24,66} ,
		[11] = {25,67} ,
		[12] = {29,68} ,
		[13] = {34,65} ,
		[14] = {57,58} ,
	}

	self.type_id_to_group = {
		[1] = 1 ,
		[2] = 1 ,
		[3] = 2 ,
		[4] = 2 ,
		[5] = 3 ,
		[6] = 3 ,
		[7] = 4 ,
		[8] = 4 ,
		[9] = 5 ,
		[10] = 5 ,
		[11] = 6 ,
		[12] = 6 ,
		[14] = 7 ,
		[15] = 7 ,
		[16] = 8 ,
		[17] = 8 ,
		[18] = 9 ,
		[19] = 9 ,
		[24] = 10 ,
		[66] = 10 ,
		[25] = 11 ,
		[67] = 11 ,
		[29] = 12 ,
		[68] = 12 ,
		[34] = 13 ,
		[65] = 13 ,
		[57] = 14 ,
		[58] = 14 ,
	}

end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	--监听相关操作返回消息
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )
	
	self.real_select_road_vec = self.d.single_obj["driver_map_manager"]:get_map_road_vec( self.select_road_type ,
						{ now_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos) , select_num = self.select_road_num , group = self.owner.group }  )
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
		---- 创建路障
		local target_road_id = {}
		target_road_id[#target_road_id+1] = _op_data.select_index
		---- 根据road_id 获得 type_id
		if self.d.map_road_award[_op_data.select_index] then
			local type_id = self.d.map_road_award[_op_data.select_index].type_id
			print("111",type_id)

			if self.type_id_to_group[type_id] then
				print("2222222222222222222222222")
				local group = self.type_id_to_group[type_id]
				for key,_type_id in pairs(self.award_group[group]) do
					for road_id,data in pairs(self.d.map_road_award) do
						if _type_id == data.type_id then
							if _op_data.select_index ~= road_id then
								 target_road_id[#target_road_id+1] = road_id
							end
						end
					end
				end
			else
				for road_id,data in pairs(self.d.map_road_award) do
					print("22222222222  ",road_id,data.type_id)
					if type_id == data.type_id then
						print("333333333")
						if _op_data.select_index ~= road_id then
							 target_road_id[#target_road_id+1] = road_id
						end
					end
				end
			end
		end

		for i=1,#target_road_id do

			--- 统计数据
			local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
				player_action = {
					op_type = self.op_type ,
					op_arg_1 = target_road_id[i] ,
					seat_num = self.seat_num ,
					op_data = self.op_data , 
				} } , self.father_process_no
			)

			

			PUBLIC.create_map_barrier( self.d , self.barrier_id , target_road_id[i] , process_id , self.owner , self.is_clear_enemy_barrier )
		end

		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d  )
	end
end
return C


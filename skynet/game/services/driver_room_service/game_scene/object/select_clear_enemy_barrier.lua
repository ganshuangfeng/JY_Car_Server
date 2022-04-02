----- 选择清理 敌人的 地图 障碍

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("select_clear_enemy_barrier" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num
	----- 可以清的障碍列表
	self.barrier_id_map = _config.barrier_ids and basefunc.list_to_map( _config.barrier_ids ) or "all"

end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)

	---- 操作类型
	self.op_type = DATA.player_op_type.select_clear_enemy_barrier
	---- 操作倒计时
	self.op_timeout = DATA.player_op_timeout["select_clear_enemy_barrier"] or 20
end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	---- 监听消息
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )
end

function C:destroy()
	self.is_run_over = true

	PUBLIC.delete_msg_listener( self.d , self )
end

function C:run()
	
	----- 
	local my_group = self.owner.group

	-----敌人的路面障碍
	self.enemy_map_barrier = {}
	self.real_enemy_map_barrier = {}
	self.for_select_vec = {}

	if self.d and self.d.map_barrier then
		for key,vec_data in pairs(self.d.map_barrier) do
			for _no , data in pairs(vec_data) do
				if data.group ~= my_group then
					self.enemy_map_barrier[#self.enemy_map_barrier + 1] = data
				end
			end
		end
	end

	if next(self.enemy_map_barrier) then
		for key,_barrier_data in pairs( self.enemy_map_barrier ) do
			if self.barrier_id_map == "all" or self.barrier_id_map[ _barrier_data.id ] then
				self.for_select_vec[#self.for_select_vec + 1] = _barrier_data.road_id

				self.real_enemy_map_barrier[#self.real_enemy_map_barrier + 1] = _barrier_data
			end
		end
	end

	------
	if next(self.for_select_vec) then
		local op_permit = {
			[ self.op_type ] = true ,
		}

		self.op_data = {
			op_type = self.op_type ,
			seat_num = self.seat_num ,
			op_permit = op_permit ,
			for_select_vec = self.for_select_vec ,
			op_timeout = self.op_timeout ,
		}

		--- 统计数据
		self.d.running_data_statis_lib.add_game_data( self.d , { player_op = self.op_data }  ,  self.father_process_no )

		--改变游戏状态
		---- 设置 玩家 操作类型
		PUBLIC.open_player_op_status(self.d , self.seat_num , self.op_type )

		--打包调用发送
		PUBLIC.send_msg_to_agent( self.d , DATA.msg_type.game_progress )

	else
		self:destroy()
		return
	end


end

function C.msg_deal:player_op_msg(_op_data)
	if _op_data.base_op_type == self.op_type then

		self:destroy()

		local target_road_id = _op_data.select_index
		local owner_car_road_id = PUBLIC.get_grid_id_quick(self.d , self.owner.pos )

		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				op_arg_1 = target_road_id ,
				seat_num = self.seat_num ,
				op_data = self.op_data , 
			} } , self.father_process_no
		)

		---- 清除障碍
		if self.real_enemy_map_barrier and next(self.real_enemy_map_barrier) then
			for key,data in pairs(self.real_enemy_map_barrier) do
				if data.road_id == target_road_id then
					PUBLIC.delete_map_barrier( self.d , data , nil , "select_clear" , self.skill.id )
					
				end
			end
		end

		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d  )
	end
end


return C


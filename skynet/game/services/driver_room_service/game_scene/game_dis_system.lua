----- 游戏主逻辑 调度

local basefunc = require "basefunc"
local base=require "base"
local skynet = require "skynet_plus"
local fsm_table_lib = require "fsm_table_lib"

local fsm_table_lib = require "fsm_table_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local game_dis_system = basefunc.create_hot_class("game_dis_system")
--require "driver_room_service.game_scene.object.gridAward_ctrl_sys"

local C = game_dis_system

--- 监听消息 处理函数表
C.msg_table = {}

function C:ctor(_d)
	self.d = _d

	
	--- 所有的车实体 list ， 这里按顺序存进来
	--self.all_car_list = {}
	--- 先手玩家
	self.first_player_seat = nil


	--- 当前的轮次的 车 的顺序号
	self.cur_work_player_index = nil

	
	
	--- 监听消息
	PUBLIC.add_msg_listener( _d , self , C.msg_table )
end
function C:init()
	
end

function C:destroy()
	
end
---- 处理车子的调度顺序 , 获得 next 的调度车子 ， 返回 要开始的车 实体
function C:calculate_next_workPlayer()

	if not self.cur_work_player_index then
		self.cur_work_player_index = 1
	else
		self.cur_work_player_index = self.cur_work_player_index+1
		if self.cur_work_player_index > self.d.seat_count then
			self.cur_work_player_index = 1
		end
	end

end

----- 强行设置 先手位
function C:force_set_first_player_seat( _seat_num )
	self.first_player_seat = _seat_num
end

----- 确定先手，先随机
function C:calculate_first_workPlayer()

	local rand_seat = math.random( self.d.seat_count )
	if skynet.getcfg("is_open_drive_move_test") then
		rand_seat = 1
	end

	self.first_player_seat = rand_seat

	print("xxx--------------------------calculate_first_workPlayer:" , self.first_player_seat )

	return self.first_player_seat
end

--- 游戏开始
function C:game_begin()
	--创建路边奖励控制系统
	--basefunc.hot_class.gridAward_ctrl_sys.new(self.d) 
	
	--- 发出一个 游戏开始 消息
	PUBLIC.trriger_msg( self.d , "game_begin" )

	-------------------- 处理先手流程
	if not self.first_player_seat then
		self:calculate_first_workPlayer()
	end
	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , {
		status_change = {
			status = DATA.game_status_type.game_begin ,
			seat_num = self.first_player_seat ,
		} }
	)


	--- 调用处理分发 轮次
	self:round_start( self.first_player_seat )

	self.d.game_run_system:game_begin()

end


--- 轮次开始
function C:round_start( _work_player )

	--将刚操作完的玩家的is_attack设为false
	local real_seat_num = self.cur_work_player_index or _work_player
	local old_car = PUBLIC.get_car_info_by_data(self.d , self.d.p_info[real_seat_num])
	if old_car then
		old_car.is_attack = false
	end


	if _work_player then
		self.cur_work_player_index = _work_player
	else
		self:calculate_next_workPlayer()
	end

	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , {
		status_change = {
			status = DATA.game_status_type.round_start ,
			seat_num = self.cur_work_player_index ,
		} }
	)


	---- 发出轮次开始消息

	PUBLIC.trriger_msg( self.d , "round_start_before" , { seat_num = self.cur_work_player_index } )

	PUBLIC.trriger_msg( self.d , "round_start" , { seat_num = self.cur_work_player_index } )

	PUBLIC.trriger_msg( self.d , "round_start_after" , { seat_num = self.cur_work_player_index } )

	print("xxx------------------round_start__orig:" , self.cur_work_player_index )

end

--- 游戏结束
function C:game_over(_win_car , _reason)
	print("xxx-------------game_dis_system__game_over")
	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , {
		status_change = {
			status = DATA.game_status_type.game_over ,
			seat_num = _win_car.seat_num ,          ---- 游戏结束，导致游戏结束的 座位号
			pos = _win_car.pos ,
		} }
	)

	--- 结算
	PUBLIC.settlement(self.d , _win_car.seat_num , _reason)

	--- 游戏结束
	PUBLIC.gameover( self.d , _reason)

	--- 发送 数据
	PUBLIC.send_msg_to_agent( self.d , DATA.msg_type.game_progress )

	
end

-------------------------------------
function C.msg_table.change_game_dis_msg(self)
	self:round_start()
end

---- 监听 位置进入格子
function C.msg_table.position_relation_moveIn_after(self , _arg_table )
	local virtual_circle = _arg_table.trigger.virtual_circle or 0

	if _arg_table.road_id >= ( self.d.map_game_over_circle + virtual_circle ) * self.d.map_length then
		self:game_over( _arg_table.trigger , DATA.game_over_reason.move_over )
	end

end

---- 监听血量改变
function C.msg_table.car_hp_reduce_after( self , _arg_table )
	if _arg_table.be_attacker.hp <= 0 then
		self:game_over( _arg_table.attacker , DATA.game_over_reason.all_hp_zero )
	end
end

function C.msg_table.player_surrender( self , _surrender_seat_num )
	--print("xxxx-------------player_surrender 1")
	local win_seat_num = (_surrender_seat_num == 1) and 2 or 1

	----- 找到 获胜的 车辆
	local player_car = nil
	if self.d and self.d.p_info and self.d.p_info[win_seat_num] then
		local p_info = self.d.p_info[win_seat_num]
		if p_info.car and type(p_info.car) == "table" then

			for car_no , car_obj in pairs(p_info.car) do
				player_car = car_obj
				--print("xxxx-------------player_surrender 2" , player_car)
				break
			end

		end
	end
	
	--print("xxxx-------------player_surrender 3" , player_car)
	if player_car then
		--print("xxxx-------------player_surrender 4" , player_car)
		self:game_over( player_car , DATA.game_over_reason.surrender )
	end
end


return C
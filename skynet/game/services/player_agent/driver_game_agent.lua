
-- 游戏agent

require "normal_enum"
local skynet = require "skynet_plus"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require"printfunc"
local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local CMD = base.CMD
local REQUEST = base.REQUEST

require "ecs.ecs_data_module"

DATA.driver_game_agent_protect = {}
local PROTECT = DATA.driver_game_agent_protect

--[[PROTECT.CMD = {}
PROTECT.REQUEST = {}

local CMD = PROTECT.CMD
local REQUEST = PROTECT.REQUEST--]]

local LF = base.LocalFunc("driver_game_agent")
local LD = base.LocalData("driver_game_agent")

LD.dt = 1
LD.update_timer = nil

---- 新手引导的自动退出的时间
LD.xsyd_auto_quit_time = 60 * 30

function LF.call_room_service(_func_name,...)
	return nodefunc.call(LD.game_data.room_id,_func_name,LD.game_data.t_num,LD.game_data.seat_num,...)
end

function LF.send_room_service(_func_name,...)
	nodefunc.send(LD.game_data.room_id,_func_name,LD.game_data.t_num,LD.game_data.seat_num,...)
end

function LF.add_status_no()
	LD.all_data.status_no = LD.all_data.status_no + 1
end

function LF.update(_dt)
	
	if LD.game_data and LD.game_data.total_game_time then
		LD.game_data.total_game_time = LD.game_data.total_game_time + _dt
		
		--print("xxx---------------add total_game_time :" , LD.game_data.total_game_time , LD.xsyd_auto_quit_time )

		if LD.game_data.total_game_time > LD.xsyd_auto_quit_time and not LD.game_data.is_set_auto_quit and LD.game_data.game_id < 0 and basefunc.chk_player_is_real(DATA.my_id) then
			
			LD.game_data.is_set_auto_quit = true
			print("xxx-------------auto xsyd_auto_quit_time " , DATA.my_id )
			----- 如果大于了自动退出的时间，就 让敌人投降 , 并且 是新手引导
			nodefunc.send(LD.game_data.room_id,"surrender", LD.game_data.t_num , (LD.game_data.seat_num == 1) and 2 or 1 )
			
			if LD.game_data.game_id == -1 then
				--- 强制设置引导的位置
				REQUEST.set_xsyd_pos( { pos = 11 , is_send_client = true } )
			end

		end
	end

	if LD.game_data and LD.game_data.run_time then
		LD.game_data.run_time = LD.game_data.run_time + _dt
	
		----- 如果客户端没有发送，超时 自己处理 播放完动画了
		if not LD.game_data.client_is_finish_movie and LD.game_data.run_time >= LD.game_data.client_max_movie_time then
			print("xxxx----------------------------auto___drive_finish_movie")
			REQUEST.drive_finish_movie(self)
		end
		
		------ 如果播放完动画， 但是 没有操作，自动操作
		if LD.game_data.client_is_finish_movie and LD.game_data.now_player_op_data then
			local is_op_timeover = false

			local op_data = LD.game_data.now_player_op_data
			if op_data.time_out_count then
				op_data.time_out_count = op_data.time_out_count - _dt
				if op_data.time_out_count <= 0 then
					is_op_timeover = true
				end
			end

			------ 自动操作 ， 只有 可以操作de玩家才能 自动操作 , 并且不是 新手引导
			if is_op_timeover and LD.game_data.seat_num == op_data.seat_num and LD.game_data.game_id >= 0 then
				LF.auto_op()
			end

		end
	end

end

function LF.new_game()
	--LD.game_data.table_status = "running"

	LD.game_data.map_id = nil

	---- 距离上一个 过程数据已经过去了多少时间
	LD.game_data.run_time = 0
	---- 上一个完整数据
	LD.game_data.start_data = nil
	---- 当前的 过程数据
	LD.game_data.process_data = nil
	---- 当前的 完整数据
	LD.game_data.end_data = nil

	---- 总共的游戏时间
	LD.game_data.total_game_time = 0
	LD.game_data.is_set_auto_quit = false

	---- 地图上 的 数据
	--LD.game_data.map_data = nil

	---- 当前的 玩家操作数据 状态
	print("xxxx------------------new_game now_player_op_data_=_nil ")
	LD.game_data.now_player_op_data = nil

	---- 每时每刻的 我的玩家数据
	LD.game_data.my_player_data = nil

	---- 客户端是否做完了  表现
	LD.game_data.client_is_finish_movie = false
	----- 客户端 最长的表现时间 ， 超过这个值，服务器这边自动结束表现
	LD.game_data.client_max_movie_time = 30

	------ 预估的 过程动画时间
	LD.game_data.process_movie_time = 0
	----- 过程的
	LD.send_process_num = 0

end


function LF.free()
	if LD.update_timer then
		LD.update_timer:stop()
		LD.update_timer=nil
	end
	LD.all_data = nil
	LD.game_data = nil
end



------- 当匹配完成之后，调到 agent 模式的进入游戏，会调到这里 加入房间。
function LF.join_room(_data)
	local return_data=nodefunc.call(LD.game_data.room_id,"join", LD.game_data.t_num , DATA.my_id , _data)
	if return_data=="CALL_FAIL" or return_data ~= 0 then
		skynet.fail(string.format("join_game_room error:call return %s",tostring(return_data)))
		return false
	end
	return true
end



---- 从上级模块，调过来，当玩家 已经匹配成功，并进入房间，就调这里
function LF.ready()
	local ret = LF.call_room_service("ready")
	return {result = ret.result}
end

--- 投降
function LF.surrender_game()
	local return_data = nodefunc.call(LD.game_data.room_id,"surrender", LD.game_data.t_num , LD.game_data.seat_num )
	if return_data == "CALL_FAIL" or return_data ~= 0 then
		skynet.fail(string.format("surrender_game error:call return %s",tostring(return_data)))
		return return_data
	end
	return 0
end


------------------------------------------------------------------- 玩家 请求 ↓ ------------------------------------

---- 玩家操作 请求
function REQUEST.drive_game_player_op_req(self)
	print("xxxx---------------------drive_game_player_op_req:" , self.op_type , self.op_arg_1)
	local ret = {}
	---- 参数检查
	if not self or not self.op_type or type(self.op_type) ~= "number" then
		ret.result = 1001
		return ret
	end

	ret.op_type = self.op_type
	ret.op_arg_1 = self.op_arg_1


	if not LD.game_data then
		ret.result = 1004
		return ret
	end

	local player_op_data = LD.game_data.now_player_op_data

	if not player_op_data then
		print("xxxx----------------------------no___player_op_data")
		ret.result = 1002
		return ret
	end


		---- 检查 操作，需要检查 时间
	
	if not player_op_data.op_permit or not player_op_data.op_permit[self.op_type] or LD.game_data.seat_num ~= player_op_data.seat_num then
		--dump(player_op_data.op_permit , "xxxx----------------------player_op_data.op_permit:")
		--print("xxx--------------------------drive_game_player_op_req 1003 222" , self.op_type , LD.game_data.seat_num ,  player_op_data.seat_num)
		ret.result = 1003
		--PUBLIC.off_action_lock( "drive_game_player_op_req" )
		return ret
	end


	---- 如果是取消 就直接返回
	if self.op_type == -1 then
		local _result = LF.call_room_service( "agent_request" , "player_op" , self.op_type , self.op_arg_1 )
		--PUBLIC.off_action_lock( "drive_game_player_op_req" )
		ret.result = _result

		return ret
	end

	----- 如果 op 请求带了参数，但是类型不对
	if self.op_arg_1 and type(self.op_arg_1) ~= "number" then
		ret.result = 1001
		return ret
	end

	----- 有待选项，但是没有传选择项
	if player_op_data.for_select_vec and not self.op_arg_1 then
		ret.result = 1001
		return ret
	end

	---- 有选择项，但是不在选择项里面
	if player_op_data.for_select_vec and self.op_arg_1 then
		local is_find = false
		for key,data in pairs( player_op_data.for_select_vec ) do
			if data == self.op_arg_1 then
				is_find = true
				break
			end
		end
		if not is_find then
			ret.result = 1001
			return ret
		end
	end

	--[[if not LD.game_data or not LD.game_data.now_player_op_data then
		ret.result = 1004
		return ret
	end--]]

	------ 如果客户端没有做完表现
	if not LD.game_data.client_is_finish_movie then
		ret.result = 1003
		--print("xxx------------------not client_is_finish_movie---")
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_game_player_op_req" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_game_player_op_req" )


	------ 判断使用道具
	if self.op_type == 7 then
		if not self.op_arg_1 then
			ret.result = 1001
			PUBLIC.off_action_lock( "drive_game_player_op_req" )
			return ret
		end

		---- 如果没有道具数据
		if not LD.game_data.my_player_data or not LD.game_data.my_player_data.tools_map_data or not LD.game_data.my_player_data.tools_map_data[self.op_arg_1] then
			ret.result = 1003
			PUBLIC.off_action_lock( "drive_game_player_op_req" )
			return ret
		end

		local tools_data = LD.game_data.my_player_data.tools_map_data[self.op_arg_1]

		if tools_data.num <= 0 then
			ret.result = 8000
			PUBLIC.off_action_lock( "drive_game_player_op_req" )
			return ret
		end
		---- 点数不足
		if player_op_data.op_mp and player_op_data.op_mp < tools_data.spend_mp then
			ret.result = 8001
			PUBLIC.off_action_lock( "drive_game_player_op_req" )
			return ret
		end

		----- 检查是否能够释放 道具
		local is_can_use = LF.call_room_service( "agent_request" , "check_is_can_use_tool" ,  self.op_arg_1 )
		if not is_can_use then
			ret.result = 8002
			PUBLIC.off_action_lock( "drive_game_player_op_req" )
			return ret
		end

	end



	print("xxxx------------------player_op now_player_op_data_=_nil ")
	LD.game_data.now_player_op_data = nil
	--print("xxxx--------------------------delete__LD.game_data.now_player_op_data")
	local _result = LF.call_room_service( "agent_request" , "player_op" , self.op_type , self.op_arg_1 )
	ret.result = _result
	

	PUBLIC.off_action_lock( "drive_game_player_op_req" )
	
	
	return ret
end


---- 请求 结束 动画表现 ( 在发请求操作之前，一定发一下这个消息 )
function REQUEST.drive_finish_movie(self)
	print("xxx-----------------------drive_finish_movie:")
	local ret = {}

	---- 没有数据
	if not LD.game_data then
		ret.result = 1004
		return ret
	end

	if LD.game_data.client_is_finish_movie then
		ret.result = 0
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_finish_movie" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_finish_movie" )

	----- 判断时间
	if LD.game_data.run_time < LD.game_data.process_movie_time then
		ret.result = 7000
		print("xxx-----------------drive_finish_movie_7000:",LD.game_data.run_time , LD.game_data.process_movie_time)
		PUBLIC.off_action_lock( "drive_finish_movie" )
		return ret
	end

	LD.game_data.client_is_finish_movie = true
	print("xxxx----------------set____client_is_finish_movie____true 1")
	----- 发给其他玩家
	if LD.game_data.end_data and LD.game_data.end_data.players_info and ( not self or not self.dont_to_other ) then
		for key,data in pairs( LD.game_data.end_data.players_info ) do
			if DATA.my_id ~= data.id then
				print("xxx---------------- drive_finish_movie 222 :" ,  data.id , DATA.my_id )
				nodefunc.send( data.id , "drive_finish_movie" )
			end
		end
	end

	ret.result = 0

	PUBLIC.off_action_lock( "drive_finish_movie" )
	return ret
end

function CMD.drive_finish_movie()
	print("xxxx----------CMD___drive_finish_movie")
	REQUEST.drive_finish_movie( { dont_to_other = true } )

	---- 发给客户端一下
	PUBLIC.request_client( "drive_finish_movie_by_other" , {} )
end

function REQUEST.drive_set_movie_time(self)
	local ret = {}
	if not self or not self.time or type(self.time ) ~= "number" then
		ret.result = 1001
		return ret
	end

	---- 没有数据
	if not LD.game_data then
		ret.result = 1004
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_set_movie_time" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_set_movie_time" )
	print("xxxxxx-------------------------drive_set_movie_time:" , self.time)
	LD.game_data.client_max_movie_time = self.time + 15

	----- 发给其他玩家
	if LD.game_data.end_data and LD.game_data.end_data.players_info then
		for key,data in pairs( LD.game_data.end_data.players_info ) do
			if DATA.my_id ~= data.id then
				nodefunc.send( data.id , "drive_set_movie_time" , LD.game_data.client_max_movie_time )
			end
		end
	end


	ret.result = 0

	PUBLIC.off_action_lock( "drive_set_movie_time" )
	return ret
end



----别人设置我的，可能我挂机了
function CMD.drive_set_movie_time( _time )
	local ret = {}
	---- 没有数据
	if not LD.game_data then
		ret.result = 1004
		return ret
	end

	LD.game_data.client_max_movie_time = _time
end

------------------------------------------------------------------- 玩家 请求 ↑ ------------------------------------

------------------------------------------------------------------- 消息 接收 ↓ ------------------------------------
---- 收到房间的消息，自己 或 他人 准备了
function CMD.driver_ready_msg(_seat_num)
	LD.game_data.ready[_seat_num] = 1

	if _seat_num == LD.game_data.seat_num then
		LF.new_game()

		LD.game_data.table_status = "ready"
	end

	LF.add_status_no()
	PUBLIC.request_client("driver_ready_msg",
	{
		status_no = LD.all_data.status_no ,
		seat_num = _seat_num,
	})
end

---- 准备完成
function CMD.driver_ready_ok_msg(_map_id , _end_data )
	LD.game_data.table_status = "ready_ok"

	LD.game_data.map_id = _map_id

	--dump( _end_data , "xxx---------------driver_game_begin:" )
	LD.game_data.start_data = _end_data
	LD.game_data.end_data = _end_data

	--LD.game_data.map_data = _map_data

	----- 告诉上级 模式 代码
	if LD.all_data.mode_agent and LD.all_data.mode_agent.game_ready_ok_msg then
		LD.all_data.mode_agent.game_ready_ok_msg()
	end

	LF.add_status_no()
	PUBLIC.request_client("driver_ready_ok_msg",
	{
		status_no = LD.all_data.status_no ,
		seat_num = LD.game_data.seat_num , 
	})
end

---- 游戏开始
function CMD.driver_game_begin( _end_data )
	LD.game_data.table_status = "running"

	LF.add_status_no()
	PUBLIC.request_client("driver_game_begin_msg",
	{
		status_no = LD.all_data.status_no ,
	})

end
-----
function CMD.driver_gameover_msg(_data)

	LD.game_data.table_status = "game_over"

	----- 告诉上级 模式 代码
	if LD.all_data.mode_agent and LD.all_data.mode_agent.game_gameover_msg then
		LD.all_data.mode_agent.game_gameover_msg(_data)
	end

	LF.add_status_no()
	PUBLIC.request_client("driver_game_over_msg",
				{
					status_no = LD.all_data.status_no,
					status = LD.game_data.table_status,
				})
	
end

function CMD.driver_settlement_msg(_data)
	LD.game_data.table_status = "settlement"

	LD.game_data.settlement_info = _data

    print("xxxxxxxxxxxxxxxxxxx driver_settlement_msg111: ",LD.all_data.mode_agent and LD.all_data.mode_agent.game_settlement_msg)

	----- 告诉上级 模式 代码
	if LD.all_data.mode_agent and LD.all_data.mode_agent.game_settlement_msg then
        print("xxxxxxxxxxxxxxxxxxx driver_settlement_msg222: ",LD.all_data.mode_agent and LD.all_data.mode_agent.game_settlement_msg)
		LD.all_data.mode_agent.game_settlement_msg(_data)
	end


	LF.add_status_no()
	PUBLIC.request_client("drive_game_settlement_msg",
			{
				status_no = LD.all_data.status_no,
				settlement_info = LD.game_data.settlement_info,
			})
	
	
end


----- 自己的 join_room 消息 和 别人的join消息 的回调 ， 从 房间 收到的消息
function CMD.driver_join_msg(_info,_my_join_return)

	if _info and _info.id~=DATA.my_id then
		if LD.all_data.mode_agent and LD.all_data.mode_agent.player_join_msg then
			LD.all_data.mode_agent.player_join_msg(_info)
		end
	else
		--- 我自己加入了，等待匹配
		LD.game_data.table_status = "wait_p"
		--
		LD.game_data.seat_num = _my_join_return.seat_num
		LD.game_data.seat_count = _my_join_return.seat_count

		if LD.all_data.mode_agent and LD.all_data.mode_agent.my_join_return then
			LD.all_data.mode_agent.my_join_return(_my_join_return)
		end
	end
end


function CMD.game_progress_change(_process_data , _process_movie_time , _end_data , _ai_game_data )
	--dump(_process_data , "xxx---------------agent__game_progress_change:")
	---- 上一个完整数据
	LD.game_data.start_data = LD.game_data.end_data or {}
	---- 当前的 过程数据
	LD.game_data.process_data = _process_data
	---- 当前的 完整数据
	LD.game_data.end_data = _end_data

	if LD.game_data.end_data and LD.game_data.end_data.players_info then
		for k , player_info in pairs(LD.game_data.end_data.players_info) do
			if player_info.seat_num == LD.game_data.seat_num then
				LD.game_data.my_player_data = player_info

				break
			end
		end
	end

	--LD.game_data.map_data = _map_data

	---- 服务器预估的 动画时间
	LD.game_data.process_movie_time = _process_movie_time
	LD.game_data.run_time = 0

	LD.send_process_num = LD.send_process_num + 1

	---- 新的状态来了，客户端一定没有做完表现
	if LD.send_process_num == 1 then
		LD.game_data.client_is_finish_movie = true
		print("xxxx----------------set____client_is_finish_movie____true 2")
	else
		LD.game_data.client_is_finish_movie = false
		print("xxxx----------------set____client_is_finish_movie____false 2")
	end
	---- 获取最后一个 op 状态
	if _process_data and next(_process_data) then
		local last_data = _process_data[#_process_data]

		------ 两个号都有，操作数据，
		if last_data.player_op then
			LD.game_data.now_player_op_data = last_data.player_op
			print("xxxx------------------have_LD.game_data.now_player_op_data:")
		end

		----- 赋值 操作倒计时，计时器
		if LD.game_data.now_player_op_data and LD.game_data.now_player_op_data.op_timeout then
			LD.game_data.now_player_op_data.time_out_count = LD.game_data.now_player_op_data.op_timeout
		end

	end

	LF.add_status_no()
	PUBLIC.request_client( "drive_game_process_data_msg" , {
		status_no = LD.all_data.status_no ,
		--- start_data = LD.game_data.start_data,
		process_data = LD.game_data.process_data ,
		end_data = LD.game_data.end_data ,

		ai_game_data = _ai_game_data ,
	})

end

------------------------------------------------------------------- 消息 接收 ↑ ------------------------------------

----- 操作超时，自动操作
function LF.auto_op()
	print("xxx----------------------auto_op:" ,LD.game_data.seat_num )
	local op_data = LD.game_data and LD.game_data.now_player_op_data

	if op_data then
		local op_type = op_data.op_permit and next(op_data.op_permit)

		local _ , selelt_value = nil

		if op_data.for_select_vec then
			_ , selelt_value = next(op_data.for_select_vec)
			print("xxx----------------------auto_op22:", op_type , _ , selelt_value )
		end

		print("xxx--------------auto_op 222" , _ , selelt_value )
		if op_type then
			local ret = REQUEST.drive_game_player_op_req({ op_type = op_type , op_arg_1 = selelt_value })
			print("xxxx---------------auto_op_result:" , ret.result )
		end
	end

end

------- 本游戏的 all_info 数据
function LF.get_status_info()
	local tar_data = {}
	if LD.game_data then

		--tar_data.map_data = LD.game_data.map_data
		tar_data.status = LD.game_data.table_status
	    tar_data.run_time  = math.floor( LD.game_data.run_time )
	    tar_data.start_data = LD.game_data.start_data
	    tar_data.process_data = LD.game_data.process_data
	    tar_data.end_data = LD.game_data.end_data

	    ------ 操作倒计时
	    local op_data = LD.game_data.now_player_op_data
		if op_data and op_data.time_out_count then
			tar_data.op_timeout = math.floor( op_data.time_out_count )
		end

	    ---- 结算数据
	    tar_data.settlement_info = LD.game_data.settlement_info
	    
	end
	return tar_data
end

---- enter_room 时调用
function LF.init_game(_all_data)
	LD.all_data = _all_data
	_all_data.game_data = {}
	LD.game_data = _all_data.game_data

	LD.game_data.game_id = _all_data.room_info.game_id
	LD.game_data.room_id = _all_data.room_info.room_id
	LD.game_data.t_num = _all_data.room_info.t_num

	--- 游戏 桌子 状态
	LD.game_data.table_status = "init"
	--- 总 游戏人数
	LD.game_data.seat_count = 0


	---- 准备的列表
	LD.game_data.ready = {}

	---- 启动timer
	LD.update_timer = skynet.timer( LD.dt , function(...) LF.update( LD.dt ) end )

end

---- 设置下一次游戏  要到的位置
function LF.force_set_move_num( _move_num )
	if not LD.game_data then
		return 1004
	end

	local ret = LF.call_room_service( "agent_request" , "force_set_move_num" , _move_num )
	if ret ~= 0 then
		return ret
	end

	return 0
end

---- 设置 敌人 下一次游戏  要到的位置
function LF.force_set_ememy_move_num( _move_num )
	if not LD.game_data then
		return 1004
	end

	local ret = LF.call_room_service( "agent_request" , "force_set_enemy_move_num" , _move_num )
	if ret ~= 0 then
		return ret
	end

	return 0
end

----- 强制获得道具
function LF.force_get_tool(_tool_id)
	if not LD.game_data then
		return 1004
	end

	local ret = LF.call_room_service( "agent_request" , "force_get_tool" , _tool_id )
	if ret ~= 0 then
		return ret
	end

	return 0
end

---- 强制设置 下一个奖励
function LF.force_set_next_award( _type_id )
	if not LD.game_data then
		return 1004
	end

	local ret = LF.call_room_service( "agent_request" , "force_set_next_award" , _type_id )
	if ret ~= 0 then
		return ret
	end

	return 0
end

---- enter_room 时调用
function LF.init(_all_data)

	----------------------- agent 模块init固有操作 ↓ -----------------
	
	LF.free()

	LF.init_game(_all_data)
	
end


function LF.un_init()
	----------------------- agent 模块un_init固有操作 ↓ -----------------
	--base.un_merge_key_from_base(PROTECT)
	--DATA.freestyle_game_agent_protect = nil
	----------------------- agent 模块un_init固有操作 ↑ -----------------

end



return LF



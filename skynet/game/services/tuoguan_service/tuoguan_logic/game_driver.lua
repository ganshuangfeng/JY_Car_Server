---- 赛车 游戏 的 逻辑

local skynet = require "skynet_plus"
local base = require "base"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

----- 请求配置
require ( "driver_room_service.game_scene.driver_game_cfg_center" )


---- agent 过来的消息
local MSG = DATA.MSG

DATA.game_driver_protect = {}
local C = DATA.game_driver_protect

C.game_data = {

}

---- 延迟  时间
C.op_type_delay = {
	[ DATA.player_op_type.nor_op ] = { 1,3 } ,     --- 1 是普通操作 
	[ DATA.player_op_type.select_road ] = { 2,3 } ,     --- 5 是选择 道路
	[ DATA.player_op_type.select_skill ] = { 2,3 } ,     --- 6 是选择 技能 (暂时废掉)
	[ DATA.player_op_type.select_clear_enemy_barrier ] = {2 , 3} ,    --- 10 选择清理地方障碍

	[ DATA.player_op_type.select_map_award ] = { 3,5 } ,     --- 11 是选择 地图奖励，n选一
}

---- 


function C.new_game()
	C.game_data = {
		game_type = "driver" ,
		seat_num = nil,
		last_process_data = nil ,
		op_data = nil ,

		process_num = 0 ,

		ai_game_data = nil,
	}
end

function C.start_game()
	print("xxxx------------game_driver start_game ")

	C.new_game()

end

function C.destroy()

end

function C.deal_process_data( _process_data )
	if _process_data and type(_process_data) == "table" then
		local last_data = _process_data[#_process_data]

		if last_data and last_data.player_op then
			C.game_data.op_data = last_data.player_op
		end

		
	end
end

----------------------------------------------------------- agent 消息处理 ↓ ------------------------------------------------------------
function MSG.driver_ready_ok_msg(_data)
	C.game_data.seat_num = _data.seat_num

end

--- 收到 agent 发过来的 过程数据
function MSG.drive_game_process_data_msg(_data)

	C.game_data.last_process_data = _data.process_data

	---- 处理
	C.deal_process_data( C.game_data.last_process_data )

	C.game_data.process_num = C.game_data.process_num + 1

	if C.game_data.process_num == 1 then
		MSG.drive_finish_movie_by_other()
	end

	---- ai 游戏数据
	C.ai_game_data = _data.ai_game_data

end

---- 附加一些 ai游戏数据
function C.append_ai_game_data( _ai_seat , _game_data )
	_game_data.my_seat = _ai_seat
	_game_data.enemy_seat = (_ai_seat == 1) and 2 or 1

	_game_data.total_move_gl = 1


	--dump(_game_data,"xxx--------------------tuoguan___ai___game_data")
end

---- 收到 他人的 动画做完的消息，托管自己不会发这个消息
function MSG.drive_finish_movie_by_other(_data)
	local op_data = C.game_data.op_data

	print("xxx--------------------------- drive_finish_movie_by_other 1 :" , DATA.player_id )

	---- 如果是自己操作
	if op_data and op_data.seat_num == C.game_data.seat_num then
		print("xxx--------------------------- drive_finish_movie_by_other 2 :" , DATA.player_id )

		local delay = C.op_type_delay[ op_data.op_type ]
		if not delay then
			return
		end

		print("xxx--------------------------- drive_finish_movie_by_other 3 :" , DATA.player_id )

		delay = math.random(delay[1] , delay[2])

		if op_data.op_type == DATA.player_op_type.nor_op then
			
			print("xxx--------------------------- drive_finish_movie_by_other 4 :" , DATA.player_id )

			skynet.timeout( delay * 100 , function() 

				--PUBLIC.send_to_agent("drive_finish_movie")

				C.append_ai_game_data( C.game_data.seat_num , C.ai_game_data )
				

				local ai_ret = skynet.call( DATA.service_config.tuoguan_service , "lua" , "deal_ai_logic" , C.game_data.game_type , "nor_op" ,  C.ai_game_data )

				if ai_ret and ai_ret.op_type then
					--dump(ai_ret , "xxx----------------use_ai_ret success !")
					PUBLIC.send_to_agent("drive_game_player_op_req" , { op_type = ai_ret.op_type , op_arg_1 = ai_ret.op_arg_1 } )   --- 随机值是 2-3 ，大油门，小油门
				else
					---- 只能选 发过来的 大小油门
					local op_permit_list = {}
					if op_data.op_permit[DATA.player_op_type.big_youmen] then
						op_permit_list[#op_permit_list + 1] = DATA.player_op_type.big_youmen
					end
					if op_data.op_permit[DATA.player_op_type.small_youmen] then
						op_permit_list[#op_permit_list + 1] = DATA.player_op_type.small_youmen
					end

					local r_index = math.random( #op_permit_list )

					PUBLIC.send_to_agent("drive_game_player_op_req" , { op_type = op_permit_list[r_index] } )   --- 随机值是 2-3 ，大油门，小油门
				end

			end )

		elseif op_data.op_type == DATA.player_op_type.select_road or op_data.op_type == DATA.player_op_type.select_skill 
			or op_data.op_type == DATA.player_op_type.select_clear_enemy_barrier or op_data.op_type == DATA.player_op_type.select_map_award then


			skynet.timeout( delay * 100 , function() 

				--PUBLIC.send_to_agent("drive_finish_movie")

				local ai_ret = nil

				C.append_ai_game_data( C.game_data.seat_num , C.ai_game_data )

				if op_data.op_type == DATA.player_op_type.select_map_award then
					ai_ret = skynet.call( DATA.service_config.tuoguan_service , "lua" , "deal_ai_logic" , C.game_data.game_type , "select_map_award" ,  C.ai_game_data , op_data.for_select_vec , op_data )
				elseif op_data.op_type == DATA.player_op_type.select_road then
					ai_ret = skynet.call( DATA.service_config.tuoguan_service , "lua" , "deal_ai_logic" , C.game_data.game_type , "select_road" ,  C.ai_game_data , op_data.for_select_vec , op_data )

				end
				--dump(ai_ret , "xxx--------------------ai_ret__op_type__11:" )
				if ai_ret and ai_ret.op_type then
					--dump(ai_ret , "xxx----------------use_ai_ret success 22!")
					PUBLIC.send_to_agent("drive_game_player_op_req" , { op_type = ai_ret.op_type , op_arg_1 = ai_ret.op_arg_1 } )   --- 随机值是 2-3 ，大油门，小油门
				else

					local select_value = nil
					if op_data.for_select_vec and #op_data.for_select_vec > 0 then
						select_value = op_data.for_select_vec[ math.random( #op_data.for_select_vec ) ]
					end

					PUBLIC.send_to_agent("drive_game_player_op_req" , { op_type = op_data.op_type , op_arg_1 = select_value } )

				end
			end )

		end

	end
end

----------------------------------------------------------- agent 消息处理 ↑ ------------------------------------------------------------

return C
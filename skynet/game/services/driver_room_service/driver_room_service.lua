
-- 游戏房间服务

require "normal_enum"
local skynet = require "skynet_plus"
require "skynet.manager"
require"printfunc"
local nodefunc = require "nodefunc"
local base=require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.msg_tag = nil
--require "driver_room_service.game_scene.skill.skill_base"

local LF = base.LocalFunc("driver_room_service")
local LD = base.LocalData("driver_room_service")

LD.ecs_base_func = require "common.ecs.ecs_func"
LD.ecs_world = require "common.ecs.ecs_world"
LD.ecs_config = require "driver_room_service.game_scene.gs_ecs_config"

--local fsm_logic = require "fsm_logic"
--local fsm_table_lib = require "fsm_table_lib"

DATA.game_info_center = require "driver_room_service.game_scene.game_info_center"
local game_info_center = DATA.game_info_center

----
DATA.car_prop_lib = require "driver_room_service.game_scene.car_prop_lib"

require "driver_room_service.game_scene.object.1_object_class_base"

require "driver_room_service.game_scene.game_dis_system"
require "driver_room_service.game_scene.driver_game_cfg_center"
require "driver_room_service.game_scene.driver_map_manager"
require "driver_room_service.game_scene.game_load_config"
require "driver_room_service.game_scene.fuzhu_func_lib"
require "driver_room_service.game_scene.game_get_tuoguan_data"

require "driver_room_service.game_scene.skill.skill_condition_func_lib"

require "driver_room_service.game_scene.tag_center"

DATA.table_status = {
	wait_p = "wait_p",           --- 等待玩家 
	ready = "ready",             --- 准备，
	running = "running",          --- 运行，
	player_op = "player_op",     --- 玩家操作
	settlement = "settlement",   ---结算
	game_over = "game_over",     --- 游戏结束
}

---- 技能配置
DATA.skill_config = nil

---- 游戏地图配置
DATA.game_map_config = nil

---- 地图奖励 库 ，
DATA.map_road_award_lib = nil

---- 游戏run_obj配置
DATA.game_run_obj_config = nil


----- 游戏 车辆配置 ， 基础的数据
DATA.game_car_config = nil
--- 这个是 策划技能 的配置
DATA.chehua_skill_config = nil
---- 技能id 对应 type_id的 map 表示表
DATA.chehua_skill_id_2_type_id_map = nil
--- type_id 对应的 策划配置
DATA.chehua_skill_type_id_config = nil


---- 地图障碍 配置
DATA.map_barrier_config = nil
---- 动画时间 配置
DATA.game_movie_time_config = nil
---	buff 的配置
DATA.game_buff_config = nil
--- 道具的配置
DATA.game_tools_config = nil

---- work_obj_id 对应 技能id map 表
DATA.work_id_2_skill_id_map = {}

---- buff_id 对应 技能id map 表
DATA.buff_id_2_skill_id_map = {}


---- 准备好 到 开始游戏 的展示时间
LD.ready_for_game_time = 3

---- 调用update的间隔
LD.dt = 1

--房间ID
DATA.my_id = 0

--上级管理者
DATA.mgr_id = 0

--剩余桌子数量
DATA.table_count = 0

DATA.service_config = nil
DATA.node_service = nil

-- 空闲桌子编号列表
DATA.table_list = DATA.table_list or {}
local table_list=DATA.table_list

-- 游戏中的桌子
DATA.game_table = DATA.game_table or {}
local game_table=DATA.game_table

--[[

 状态转换示意图

 普通： LF.game_begin -> fp -> jdz -> jiabei -> cp 循环 -> LF.settlement
 无加倍：   LF.game_begin -> fp -> jdz -> cp 循环 -> LF.settlement
--]]

---- 获得一个空闲的桌子
function LF.employ_table(_t_num)

	if _t_num then
		for i,id in ipairs(table_list) do
			if id == _t_num then
				table.remove(table_list,i)
				DATA.table_count=DATA.table_count-1
				return _t_num
			end
		end
	end

	local _t_number=table_list[#table_list]
	table_list[#table_list]=nil
	if _t_number then
		DATA.table_count=DATA.table_count-1
	end
	return _t_number
end

--- 回收游戏中的桌子到，空闲桌子上
function LF.return_table(_t_number)
	local _d=game_table[_t_number]
	game_table[_t_number]=nil
	table_list[#table_list+1]=_t_number
	DATA.table_count=DATA.table_count+1
end

function LF.new_game(_t_num)
	local _d=game_table[_t_num]
	if not _d then
		return false
	end

	--_d.status = DATA.table_status.wait_p
	PUBLIC.set_game_status(_d , DATA.table_status.wait_p )

	
	--- 游戏 信息数据 中心   _d.game_info_center
	game_info_center.new_game(_d)
	

end

--- 设置 游戏状态
function PUBLIC.set_game_status(_d , _status)
	_d.status = _status
end

---- 设置操作状态
function PUBLIC.open_player_op_status(_d , _seat_num , _status )
	if _d then
		--_d.status = DATA.table_status.player_op
		PUBLIC.set_game_status(_d , DATA.table_status.player_op )

	end
end

---- 设置 操作开关
function PUBLIC.close_player_op_status( _d , _seat_num )

	if _d then
		--_d.status = DATA.table_status.running
		PUBLIC.set_game_status(_d , DATA.table_status.running )

		--- 发送恢复游戏状态消息
		PUBLIC.trriger_msg( _d , "deal_gameRunning" )
		
	end

end

function PUBLIC.add_msg_listener( _d , _obj , _msg_table )
	if _d and _d.msg_dispatcher then
		_d.msg_dispatcher:register( _obj , _msg_table)
	end
end

function PUBLIC.delete_msg_listener( _d , _obj )
	if _d and _d.msg_dispatcher then
		_d.msg_dispatcher:unregister( _obj )
	end
end

function PUBLIC.trriger_msg( _d , _msg_name , ... )
	if _d and _d.msg_dispatcher then
		----- 这个得加入 运行系统中
		local param = table.pack(...) 


		if _d.game_run_system and DATA.need_add_run_system_msg[_msg_name] then
			_d.game_run_system:create_delay_func_obj(function() 
				_d.msg_dispatcher:call( _msg_name , table.unpack(param) )
			end)
		else
			---- 直接触发
			_d.msg_dispatcher:call( _msg_name , ... )
		end
	end
end

---- 给 实体  加 等待状态
--[[function PUBLIC.add_fsm_wait_status( _entity , _status_key , ... )
	local fsm_logic_com = _entity.fsm_logic_com
	if fsm_logic_com then
		fsm_logic_com.fsm_logic:addWaitStatus( fsm_table_lib.createStateData( _status_key , ...  )  )
	end
end--]]

function CMD.join(_t_num , _p_id , _info)
	dump("driver_room_service join")
	local _d = game_table[_t_num]
	--dump(game_table, "driver_room_service join1")
	if not _d or _d.p_count > _d.seat_count or _d.status ~= DATA.table_status.wait_p then
		return 1002
	end

	---- 确定座位号，有传就用传的，没有自己确定
	local _seat_num = _info.seat_num

	if not _seat_num then
		for sn = 1 , _d.seat_count do
			if not _d.p_seat_number[sn] then
				_seat_num = sn
				break
			end
		end
	end

	if not _seat_num then
		return 1000
	end

	---- 附加数据赋值
	_d.player_fujia_data[_seat_num] = _info.car_fujia_data

	dump(_d.player_fujia_data , "xxxx-------------------_d.player_fujia_data:")
	_info.car_fujia_data = nil

	_d.p_seat_number[_seat_num] = _p_id
	_d.p_count = _d.p_count + 1
	_d.p_info[_seat_num] = basefunc.merge(_info , _d.p_info[_seat_num]) 
	_d.p_info[_seat_num].seat_num = _seat_num

	local my_join_return = {
		seat_num = _seat_num,
		p_info = _d.p_info ,
		seat_count = _d.seat_count,
	}

	--通知其他人 xxx 加入房间
	for _,_value in pairs(_d.p_info) do
		if _value.id~=_p_id then
			nodefunc.send(_value.id,"driver_join_msg",_info)
		else
			nodefunc.send(_value.id,"driver_join_msg",nil,my_join_return)
		end
	end

	return 0
end

function LF.load_map_entity(_d)
	local total_map_item_num = 20

	local total_length = 0
	--- 地图id
	_d.map_id = DATA.map_id

	
	---- 创建地图 奖励
	basefunc.hot_class.driver_map_manager.new(_d, basefunc.deepcopy( DATA.game_map_config[ math.abs( _d.map_id ) ] ) )

end

--[[
	主要是 创建地图，格子，车辆相关
--]]

function LF.init_game(_t_num)

	dump(_t_num, "init_game")
	local _d = game_table[_t_num]
	-- 添加一个游戏世界
	--[[_d.ecs_world = basefunc.hot_class.ecs_world.new( _d , LD.ecs_config)

	-- 添加系统
	local systems = _d.ecs_world.ecs_config.systems_list
	if systems then
		for sys_name, data in ipairs(systems) do
			_d.ecs_world:add_system(data.sys_name)
		end
	end--]]

	--local players = {}

	-- 地图配置
	--local raw_map_config = nodefunc.get_global_config("game_map")

	LF.load_map_entity(_d)
	dump( _d.p_seat_number , "xxxx---------------------_d.p_seat_number:" )
	-- 创建各实体
	for _s,_id in pairs(_d.p_seat_number) do
		
		-- 玩家实体
		-- local _player_entity_id , player_entity = _d.ecs_world:add_entity()
		-- _d.ecs_world:add_component(player_entity, "room_com", DATA.my_id, _t_num, _s, _id)
		-- --_d.ecs_world:add_component(player_entity, "game_dis_com" , _s , "")
		-- _d.ecs_world:add_component(player_entity, "player_com" )
		-- _d.ecs_world:add_component(player_entity, "money_com" )

		-- players[#players + 1] = player_entity

		---- 设置 玩家游戏币数
		_d.p_info[_s].money = _d.player_money
		_d.p_info[_s].kind_type = DATA.game_kind_type.player
		_d.p_info[_s].group = _s

		--- 测试相关的
		if skynet.getcfg("is_open_drive_move_test") then
			_d.p_info[_s].money = _s == 1 and 192584 or 53826
			_d.p_info[_s].name = _s == 1 and "我是大魔王" or "秋名山考科三"
		end

		---- 给玩家 创建一个 技能
		PUBLIC.skill_create_factory( _d , 1 , { owner =  _d.p_info[_s] } )

		---- 给人 创建车辆
		if skynet.getcfg("is_open_drive_move_test") then
			PUBLIC.create_car(_d , _s , _s )
		else
			--PUBLIC.create_car(_d , math.random(2) , _s )

			--PUBLIC.create_car(_d , 2 , _s )
			--PUBLIC.create_car(_d , 3 , _s )

			--if _s == 1 then
			--	PUBLIC.create_car(_d , 2 , _s )
			--else
			--	PUBLIC.create_car(_d , math.random(2) , _s )
			--end

			PUBLIC.create_car(_d , _d.p_info[_s].car_id , _s )

			--PUBLIC.create_car(_d , _s == 2 and 3 or 1 , _s )
		end

	end

	--local is_true = PUBLIC.check_car_is_near_range_barrier(_d , PUBLIC.get_grid_id_quick(_d , 58)  , 7 , 5)
	--print("xxx-------------------check_car_is_near_range_barrier:" , is_true )
end



function CMD.ready(_t_num,_seat_num)
	LF.ready(_t_num,_seat_num)

	return {result=0}
end

function LF.ready(_t_num,_seat_num)
	dump(_t_num, "LF.ready1")
	dump(_seat_num, "LF.ready2")

	local _d = game_table[_t_num]
	if not _d.ready[_seat_num] or _d.ready[_seat_num] == 0 then
		_d.ready[_seat_num]=1

		for _s,_id in pairs(_d.p_seat_number) do
			nodefunc.send(_id,"driver_ready_msg",_seat_num)
		end

		_d.p_ready=_d.p_ready+1
		if _d.p_ready==_d.seat_count then
			--_d.status = DATA.table_status.ready
			

			PUBLIC.set_game_status(_d , DATA.table_status.ready )
			LF.init_game(_t_num)	
			
			local now_total_data = game_info_center.get_total_game_data(_d)

			--local total_map_info = game_info_center.get_total_map_info(_d)

			---- 计算先手
			local first_seat = _d.game_dis_system.first_player_seat or _d.game_dis_system:calculate_first_workPlayer()
			local next_seat = first_seat == 1 and 2 or 1
			---- 后手车 设置位置
			if next_seat and _d.p_info[next_seat] and _d.p_info[next_seat].car then
				for car_id,car_obj in pairs( _d.p_info[next_seat].car ) do
					car_obj.pos = 0
				end
			end
			-------------

			for _s,_id in pairs(_d.p_seat_number) do
				nodefunc.send(_id,"driver_ready_ok_msg" , _d.map_id , now_total_data )
			end

			---- ready 状态到 开始游戏状态的 处理
			skynet.timeout( LD.ready_for_game_time * 100 , function()
				--_d.status = DATA.table_status.running
				PUBLIC.set_game_status(_d , DATA.table_status.running )

				
				for _s,_id in pairs(_d.p_seat_number) do
					nodefunc.send(_id,"driver_game_begin" )
				end

				--- 调度系统开始
				_d.game_dis_system:game_begin()
			end )

		end
	end

end

---- 结算
function PUBLIC.settlement(_d , _win_seat_num , _reason)
	_d.settlement_info.win_seat_num = _win_seat_num
	_d.settlement_info.win_reason = _reason

	_d.settlement_info.award = {}
	for _seat_num , player_id in pairs(_d.p_seat_number) do
		if _win_seat_num == _seat_num then
			_d.settlement_info.award[ _seat_num ] = 100
		else
			_d.settlement_info.award[ _seat_num ] = -100
		end
	end

	----- 发给agent
	skynet.timeout( DATA.game_over_time_delay[_reason] , function() 
		for _s,_id in pairs(_d.p_seat_number) do
			nodefunc.send(_id,"driver_settlement_msg" , _d.settlement_info)
		end
	end )
	
end

--结束 通知给玩家
function PUBLIC.gameover(_d , _reason)

	--local _d = game_table[_t_num]
	PUBLIC.set_game_status( _d , DATA.table_status.game_over )

	--通知
	skynet.timeout( DATA.game_over_time_delay[_reason] , function() 
		for _seat_num,_id in pairs(_d.p_seat_number) do
			nodefunc.send(_id,"driver_gameover_msg",{})
		end
	end )

	nodefunc.call(DATA.mgr_id,"table_finish",DATA.my_id,_d.t_num)

	LF.return_table(_d.t_num)

	nodefunc.send(DATA.mgr_id,"return_table",DATA.my_id,_d.t_num)

	----- 写文件
	if skynet.getcfg("is_collect_process_data") then
		local _time_str = os.date("%Y%m%d_%H%M%S")

		local player_str = {}
		for key,data in pairs( _d.p_info ) do
			player_str[#player_str + 1] = data.id
		end
		player_str = table.concat( player_str , "_" )


		basefunc.path.write( string.format( "logs/total_process_data_%s_%s.txt" , player_str , _time_str ) , basefunc.tostring( _d.total_running_data ) )
	end

end

function LF.syn_data_diff_to_agent(_table_id , _data_diff_list)
	--print("xxx-------------syn_data_diff_to_agent:" )
	local _d = DATA.game_table[_table_id]

	for _s,_id in pairs(_d.p_seat_number) do
		nodefunc.send( _id ,"syn_data_diff", _data_diff_list )
	end

end

function LF.update(dt)
	----- 
	
end


function CMD.new_table(_table_config)

	local _t_num = nil

	if _table_config then
		_t_num = _table_config.table_id
	end

	_t_num=LF.employ_table(_t_num)
	if not _t_num then
		return false
	end

	local _d={}

	--- 初始化 桌子 数据
	game_info_center.init_table_info(_d , _t_num , _table_config)

	game_table[_t_num]=_d

	LF.new_game(_t_num)

	return _t_num
end
 

----- 获得房间的 空闲桌子数量
function CMD.get_free_table_num()
	return #table_list
end

----- 销毁房间
function CMD.destroy()
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "on_drive_game_car_and_skill_server_change" , DATA.msg_tag )

   	nodefunc.destroy(DATA.my_id)
	skynet.exit()
end

function CMD.surrender(_t_num , _seat_num )
	local _d = game_table[_t_num]
	if not _d then
		return 1002
	end

	PUBLIC.trriger_msg( _d , "player_surrender" , _seat_num )

	return 0
end

---- 监听消息 ，快捷方式

---------------------------------------------------------------------- 玩家操作相关 ↓ -----------------------------------------------

--- 接收 玩家操作消息 消息
function CMD.agent_request( _t_num, _seat_num , _req_type , ... )
	local _d = game_table[_t_num]

	--[[if _op_type == "youmen_click" then
		--- 数据检查
		if not _d or not _d.ecs_world or _d.status ~= DATA.table_status.runing then
			return 1004
		end

		_d.ecs_world:trriger_msg( "player_click_youmen" , _seat_num , ... )
	end--]]
	
	--- 处理玩家的基础操作 
	local function deal_player_base_op( _base_op_type , _op_arg_1 )
		
		---- 操作了啥就发啥消息出去
		PUBLIC.trriger_msg( _d , "player_op_msg" , { base_op_type = _base_op_type , seat_num = _seat_num , select_index = _op_arg_1 } )

		

		return 0
	end

	-------  强制设置移动数量
	local function force_set_move_num( _move_num )
		_d.debug_move_num = _d.debug_move_num or {}
		_d.debug_move_num[_seat_num] = _move_num

		return 0
	end
	local function force_set_enemy_move_num( _move_num )
		_d.debug_move_num = _d.debug_move_num or {}
		local tar_seat = (_seat_num == 1) and 2 or 1

		_d.debug_move_num[tar_seat] = _move_num

		return 0
	end

	----- 强制获得道具
	local function force_get_tool( _tool_id )
		PUBLIC.create_tools( _d , _seat_num , _tool_id )
		return 0
	end

	local function force_set_next_award( _type_id )
		_d.debug_next_map_award[#_d.debug_next_map_award + 1] = _type_id

		return 0
	end

	----- 检查道具是否能使用
	local function check_is_can_use_tool( _tool_id )
		local is_can = true
		local tool_config = DATA.game_tools_config[_tool_id]
		
		if tool_config and tool_config.use_cond then
			if tool_config.use_cond["hava_enemy_barrier"] then
				local is_find = false
				for road_id , data_vec in pairs( _d.map_barrier ) do
					for no , barrier_data in pairs(data_vec) do
						if barrier_data.group ~= _seat_num then
							is_find = true
							break
						end
					end
					if is_find then
						break
					end
				end
				if not is_find then
					is_can = false
				end
			end
		end

		return is_can
	end


	if _req_type == "player_op" then
		return deal_player_base_op( ... )

	elseif _req_type == "force_set_move_num" then
		return force_set_move_num( ... )
	elseif _req_type == "force_set_enemy_move_num" then
		return force_set_enemy_move_num( ... )
	elseif _req_type == "check_is_can_use_tool" then
		return check_is_can_use_tool(...)
	elseif _req_type == "force_get_tool" then
		return force_get_tool( ... )

	elseif _req_type == "force_set_next_award" then
		return force_set_next_award( ... )
	end


	return 0
end


--- 玩家 信息 状态改变 
function PUBLIC.send_msg_to_agent( _d , _msg_type , ... )
	print( "xxx----------------send_msg_to_agent11:" , _d , _msg_type )
	if _d then
		if _msg_type == DATA.msg_type.game_progress then
			print( "xxx----------------send_msg_to_agent22:" , _d , _msg_type )

			local now_total_data = game_info_center.get_total_game_data(_d)

			--local total_map_info = game_info_center.get_total_map_info(_d)

			--dump(_d.running_data , "xxx----------------------_d.running_data:")

			local tuoguan_data = PUBLIC.get_raw_data_to_tuoguan(_d)
			
			
			---- 给每个 玩家 发送
			for _s,_id in pairs(_d.p_seat_number) do
				local ai_game_data = nil
				if not basefunc.chk_player_is_real(_id) then
					ai_game_data = tuoguan_data
				end

				nodefunc.send( _id ,  "game_progress_change" , _d.running_data , _d.game_process_time , now_total_data , ai_game_data )
			end
			---- 清理
			_d.running_data = {}
			_d.game_process_time = 0

		end
	end

end

---------------------------------------------------------------------- 玩家操作相关 ↑ -----------------------------------------------

function PUBLIC.get_chehua_config()
	DATA.game_car_config = skynet.call( DATA.service_config.driver_cehua_config_center_service , "lua" , "get_game_car_config" )
	--- 这个是 策划技能 的配置
	DATA.chehua_skill_config = skynet.call( DATA.service_config.driver_cehua_config_center_service , "lua" , "get_chehua_skill_config" )

	DATA.chehua_skill_id_2_type_id_map = skynet.call( DATA.service_config.driver_cehua_config_center_service , "lua" , "get_chehua_skill_id_2_type_id_map" )
	--dump(DATA.chehua_skill_id_2_type_id_map  , "xxx--------------------DATA.chehua_skill_id_2_type_id_map :")
	--- type_id 对应的 策划配置
	DATA.chehua_skill_type_id_config = skynet.call( DATA.service_config.driver_cehua_config_center_service , "lua" , "get_chehua_skill_type_id_config" )

	--dump(DATA.chehua_skill_type_id_config  , "xxx--------------------DATA.chehua_skill_type_id_config :")
end

function CMD.on_drive_game_car_and_skill_server_change()
	PUBLIC.get_chehua_config()
end

function CMD.start(_id,_ser_cfg,_config)

	dump("driver_room_service start")
	base.set_hotfix_file("fix_driver_room_service")

	DATA.msg_tag = _id

	DATA.service_config = _ser_cfg

	---- 运行obj 的配置
	nodefunc.query_global_config( "drive_game_run_obj_server" , function(...) PUBLIC.load_game_run_obj_config(...) end )
	
	nodefunc.query_global_config( "drive_game_buff_server" , function(...) PUBLIC.load_buff_config(...) end )
	
	---- 策划的 车 和技能配置
	-- nodefunc.query_global_config( "drive_game_car_and_skill_server" , function(...) PUBLIC.load_game_car_and_skill_config(...) end )

	---- 技能 配置
	nodefunc.query_global_config( "drive_game_skill_server" , function(...) PUBLIC.load_skill_config(...) end )

	---- 地图配置
	nodefunc.query_global_config( "drive_game_map_server" , function(...) PUBLIC.load_game_map_config(...) end )

	---- 地图奖励库
	nodefunc.query_global_config( "map_award_cfg" , function(...) PUBLIC.load_game_map_award_config(...) end )

	---- 地图 障碍 配置
	nodefunc.query_global_config( "drive_game_map_barrier" , function(...) PUBLIC.load_map_barrier_config(...) end )
	---- 动画时间
	nodefunc.query_global_config( "drive_game_movie_time_server" , function(...) PUBLIC.load_game_movie_config(...) end )

	nodefunc.query_global_config( "drive_game_tool_server" , function(...) PUBLIC.load_tool_config(...) end )

	----- 监听一个 策划配置改变消息
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "on_drive_game_car_and_skill_server_change" , {
			msg_tag = DATA.msg_tag ,    
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_drive_game_car_and_skill_server_change" ,
		})

	PUBLIC.get_chehua_config()


	DATA.node_service=_ser_cfg.node_service
	DATA.table_count=10
	DATA.my_id = _id
	DATA.mgr_id=_config.mgr_id
	DATA.game_mode=_config.game_mode
	DATA.game_id = _config.game_id
	DATA.map_id = _config.map_id

	for i=1,DATA.table_count do
		table_list[#table_list+1]=i
	end

	------test
	if skynet.getcfg( "drive_game_test_timeout" ) then
		if DATA.player_op_timeout then
			for k,v in pairs(DATA.player_op_timeout) do
				DATA.player_op_timeout[k] = 6000
			end
		end
	end

	--skynet.fork(LF.update)
	--skynet.timer(LD.dt, LF.update , true)

	

	return 0
end

-- 启动服务
base.start_service()

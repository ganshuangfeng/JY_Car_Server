--- 任务的消息中心

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local task_base_func = require "task.task_base_func"
local cluster = require "skynet.cluster"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST = base.REQUEST
local PUBLIC = base.PUBLIC

DATA.task_msg_center_protect = {}
local task_msg_center = DATA.task_msg_center_protect

task_msg_center.msg = {}

task_msg_center.msg_tag = "task_msg_center_agent"

DATA.task_center_services_msg_listener = {}


function PUBLIC.trigger_msg( msg_head , ... )
	--print("xxx----------------PUBLIC.trigger_msg:",msg_head.name , ...)

	--dump(DATA.task_center_services_msg_listener , "xxxxxx-------------------------DATA.task_center_services_msg_listener:")

	---- 内部的消息通知 ，内部足够快，不用关心阻塞
	DATA.msg_dispatcher:call( msg_head.name , ... )

	---- 外部的消息通知，外部用send，也不用关心阻塞
	--[[if DATA.task_center_services_msg_listener[msg_head.name] then
		for key,data in pairs(DATA.task_center_services_msg_listener[msg_head.name]) do
			print("xxx----------------cluster.send:",data.cmd , DATA.my_id)
			cluster.send(data.node,data.addr,data.cmd , DATA.my_id ,...)
		end
	end--]]

	local is_send_to_center = true

	----- 向任务中心触发消息
	if is_send_to_center then
		skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "trigger_msg" , msg_head , DATA.my_id , ... )
	end

end

---- 暂时不用
function CMD.add_service_msg_listener(msg_name , _target_link)
	DATA.task_center_services_msg_listener[msg_name] = DATA.task_center_services_msg_listener[msg_name] or {}

	local data = DATA.task_center_services_msg_listener[msg_name]

	data[_target_link.msg_tag] = {
								msg_tag = _target_link.msg_tag,
								node = _target_link.node,
								addr = _target_link.addr,
								cmd = _target_link.cmd
							}
end

---- 暂时不用
function CMD.delete_msg_listener( msg_name , msg_tag )
	DATA.task_center_services_msg_listener[msg_name] = DATA.task_center_services_msg_listener[msg_name] or {}

	DATA.task_center_services_msg_listener[msg_name][msg_tag] = nil
end



---------------------------------------------- agent内部触发的消息的处理 ↓↓ ------------------------------------------------------------


------ 如果有任务过期了 , （任务还能领就不能删） ，并且这个任务不是其他任务的子任务，那么就删掉
function task_msg_center.msg.task_time_limit_over(_ , _task_id)
	local is_need_delete = true

	--- 任务还能领，就不能删
	if DATA.task_list[_task_id] then
		local obj = DATA.task_list[_task_id]
		if obj.get_award_status() == DATA.award_status.can_get then
			--- 任务还能领，就不能删
			is_need_delete = false
		end
	end

	---- 如果是其他的子任务也不删
	if is_need_delete and DATA.task_list and type(DATA.task_list) == "table" then

		local is_children_task = PUBLIC.get_one_task_is_other_data_children_task(_task_id)
		--- 如果是别人的子任务 ，那么不能删
		if is_children_task then
			is_need_delete = false
		end

	end

	----- 过期 删除时是否关心配置
	local is_care_cofig = true

	if is_need_delete then
		PUBLIC.delete_one_task( _task_id , is_care_cofig )
	end

end

function task_msg_center.msg.task_complete( _, _task_id, _award_data )

end

---------------------------------------------- agent内部触发的消息的处理 ↑↑ ------------------------------------------------------------

---------------------------------------------------------------------------------------------------- 各种外部消息的处理函数 ↓↓
function CMD.on_drive_game_car_and_skill_server_change( )
	if DATA.drive_game_info_lib_protect then
		DATA.drive_game_info_lib_protect.get_chehua_config()
	end
end

function CMD.on_timer_box_config_change(_config)
	if DATA.timer_box_agent_protect then
		DATA.timer_box_agent_protect.box_config = _config
	end
end

---------------------------------------------------------------------------------------------------- 各种外部消息的处理函数 ↑↑

function task_msg_center.on_player_logout()
	
end

function task_msg_center.init()
	--- 一上来去拿到外部服务关心的消息监听
	--DATA.task_center_services_msg_listener = skynet.call( DATA.service_config.msg_notification_center_service , "lua" , "query_all_msg_listener" )
	---- 监听一下消息
	DATA.msg_dispatcher:register( "task_msg_center" , task_msg_center.msg )

	DATA.signal_logout:bind("task_msg_center", task_msg_center.on_player_logout )

	task_msg_center.msg_tag = DATA.my_id .. "_" .. task_msg_center.msg_tag

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "add_msg_listener" , "on_drive_game_car_and_skill_server_change" , {
		msg_tag = task_msg_center.msg_tag ,
		node = skynet.getenv("my_node_name"),
		addr = skynet.self(),
		cmd = "on_drive_game_car_and_skill_server_change" ,
	} )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "add_msg_listener" , "on_timer_box_config_change" , {
		msg_tag = task_msg_center.msg_tag ,
		node = skynet.getenv("my_node_name"),
		addr = skynet.self(),
		cmd = "on_timer_box_config_change" ,
	} )

end

return task_msg_center

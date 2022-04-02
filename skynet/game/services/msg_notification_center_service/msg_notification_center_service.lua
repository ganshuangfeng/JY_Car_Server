local base=require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
require "normal_enum"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

---- 其他任务的消息监听
DATA.task_center_services_msg_listener = {}

---- 需要强行停止中转的消息
DATA.force_stop_msg = {}

---- 
---- 给外部服务加的消息监听接口
function CMD.add_msg_listener( msg_name , _target_link , is_notify_agent )
	DATA.task_center_services_msg_listener[msg_name] = DATA.task_center_services_msg_listener[msg_name] or {}

	local data = DATA.task_center_services_msg_listener[msg_name]

	local addr = _target_link.addr
	--[[if _target_link.node ~= skynet.getcfg("my_node_name") then
		addr = cluster.proxy(_target_link.node,_target_link.addr)
	end--]]

	data[_target_link.msg_tag] = {  
								msg_tag = _target_link.msg_tag,
								node = _target_link.node,
								addr = addr,
								cmd = _target_link.cmd , 
								send_filter = _target_link.send_filter ,   --- 发送过滤器（必须等于的时候才能收到）
								back_param = _target_link.back_param,
							}


	--[[if is_notify_agent then
		---- 通知所有的agent , 这个消息  新增了（但是一般是其他服务已启动就往这里加监听，这里基本上只是预防动态加监听）
		local player_status_list = skynet.call(DATA.service_config.data_service,"lua","get_player_status_list")

		local sn = 0
		local num = 5

		--发给所有玩家
		for player_id,data in pairs(player_status_list) do
			if basefunc.chk_player_is_real(player_id) then
				if data.status == "on" then
					--发送活动销毁了
					nodefunc.send(player_id,"add_service_msg_listener", msg_name , _target_link )
				end

				sn = sn + 1
				if sn > num then
					skynet.sleep(1)
					sn = 0
				end
			end
		end
	end--]]

end

---- 删除一个消息监听
function CMD.delete_msg_listener( msg_name , msg_tag , is_notify_agent )
	DATA.task_center_services_msg_listener[msg_name] = DATA.task_center_services_msg_listener[msg_name] or {}

	DATA.task_center_services_msg_listener[msg_name][msg_tag] = nil

	--[[if is_notify_agent then
		---- 通知所有的agent , 这个消息断了
		local player_status_list = skynet.call(DATA.service_config.data_service,"lua","get_player_status_list")

		local sn = 0
		local num = 10

		--发给所有玩家
		for player_id,data in pairs(player_status_list) do
			if basefunc.chk_player_is_real(player_id) then
				if data.status == "on" then
					--发送活动销毁了
					nodefunc.send(player_id,"delete_msg_listener", msg_name , msg_tag )
				end

				sn = sn + 1
				if sn > num then
					skynet.sleep(1)
					sn = 0
				end
			end
		end
	end--]]

end

---- 触发一个消息 ，供其他服务调用的，不会默认传入player_id

--[[
	消息触发点：  可以带多种消息过滤条件；分发消息时会检查所有的过滤条件是否和接收点的条件吻合
	消息接收点：  可以不选或选择某些过滤条件；没有选过滤条件可以直接得到，选了过滤条件则必须和消息出发点的过滤条件一致才能收到

--]]

function CMD.trigger_msg( msg_head , ... )
	if not DATA.force_stop_msg[msg_head.name] and DATA.task_center_services_msg_listener[msg_head.name] then
		for msg_tag,data in pairs(DATA.task_center_services_msg_listener[msg_head.name]) do

			local is_send = true
			--- 如果消息头中有过滤信息，且监听的消息中也有过滤信息，
			if data.send_filter and type(data.send_filter) == "table" and next(data.send_filter) 
					and msg_head.send_filter and type(msg_head.send_filter) == "table" and next(msg_head.send_filter) then
				---
				for key , value in pairs(msg_head.send_filter) do
					-- 如果消息头的中过滤信息不等于监听中的过滤信息，就不往外发送
					if data.send_filter[key] and ( ( type(data.send_filter[key]) ~= "table" and data.send_filter[key] ~= value ) 
							or ( type(data.send_filter[key]) == "table" and data.send_filter[key].value and data.send_filter[key].judge and not basefunc.compare_value( value , data.send_filter[key].value , data.send_filter[key].judge ) ) ) then
						is_send = false
						break
					end
				end
			end

			if is_send then
				--- 不走代理发送
				local param=table.pack(...) 
				param[param.n+1]=data.back_param 
				param.n=param.n+1 
				
				cluster.send(data.node,data.addr,data.cmd , table.unpack(param) ) -- , data.back_param
				----- 走代理发送
				--skynet.send( data.addr , "lua" , data.cmd ,... )
			end
			
		end
	end
end


---- agent 一上来获取所有的消息监听
function CMD.query_all_msg_listener()
	return DATA.task_center_services_msg_listener
end

----- 停止中转消息
function CMD.set_force_stop_msg( msg_name , bool_str )
	if bool_str == "true" then
		DATA.force_stop_msg[msg_name] = true
	else
		DATA.force_stop_msg[msg_name] = false
	end
end

function CMD.start(_service_config)

	DATA.service_config = _service_config


end

-- 启动服务
base.start_service()

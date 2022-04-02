--
-- Author: wss
-- Date: 2019/11/28
-- Time: 14:40

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require"printfunc"

local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

DATA.variant_data_agent_protect = {}

local PROTECT = DATA.variant_data_agent_protect

PROTECT.msg_tag = "variant_data_agent"

--- 原始 变量数据
PROTECT.ori_variant_data = nil
---- 变量数据( 包含原始数据 + 标签数据 + act_permission 活动权限数据 ) (这个数据一直维持最新数据。)
PROTECT.variant_data = nil
---- 活动权限
PROTECT.act_permission = nil

--- 标签
PROTECT.tag_vec = nil

PROTECT.trigger_variant_data_change_timecancel = nil

----- 处理 活动权限是否 重新更新数据
--[[function PUBLIC.deal_act_permisssion(_act_permission)
	local now_time = os.time()
	if PROTECT.act_permission and type(PROTECT.act_permission) == "table" then

		local is_re_dis_task = false

		for permission_key,data in pairs(PROTECT.act_permission) do
			if now_time > data.next_query_time then
				local old_data = _act_permission[permission_key]

				local new_data =
					skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_one_act_permission_data" , DATA.my_id , permission_key )

				if string.find(permission_key,"^actp_own_task_") and old_data.is_work == 0 and new_data.is_work == 1 then
					is_re_dis_task = true
				end

				_act_permission[permission_key] = new_data
			end
		end

		--- 重新分发任务
		if is_re_dis_task then
			CMD.distribute_task( {} )
		end

	end

end--]]

---- 获得最终的 变量数据（ 包含原始数据 + 标签数据 + 活动权限数据 ）
function PROTECT.get_variant_data()
	if not PROTECT.ori_variant_data then
		PROTECT.ori_variant_data = skynet.call( DATA.service_config.data_service , "lua" , "get_player_variants" , DATA.my_id )
	end
	if not PROTECT.act_permission then
		PROTECT.act_permission =
			skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_act_permission_data" , DATA.my_id )
	end

	--PUBLIC.deal_act_permisssion(PROTECT.act_permission)

	if not PROTECT.tag_vec then
		PROTECT.tag_vec = skynet.call( DATA.service_config.tag_center , "lua" , "get_player_tag_list" , DATA.my_id )
	end

	local data_tem = basefunc.deepcopy( PROTECT.ori_variant_data )
	data_tem.tag_vec = PROTECT.tag_vec
	data_tem.act_permission = PROTECT.act_permission

	--dump(data_tem, "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxvd")

	--- 把玩家的id加上
	data_tem.player_id = DATA.my_id

	return data_tem
end

function PROTECT.get_variant_data_from_data( _variant_data )
	local tar_variant_data = {}
	------ 这里返给客户端的 都是不能做的权限
	local send_act_permission_list = {}
	if _variant_data.act_permission and type(_variant_data.act_permission) == "table" then
		for key,data in pairs(_variant_data.act_permission) do
			-- by lyx
			PROTECT.add_send_act_permission_key(send_act_permission_list,key,data.is_work == 1)
		end
	end

	tar_variant_data[ #tar_variant_data + 1 ] = {   variant_name = "diff_act_permission",
														variant_value_type = "table" ,
														variant_type = type(send_act_permission_list[1]) ,
														variant_value = table.concat(send_act_permission_list,",")  }

	_variant_data.act_permission = nil

	for key,data in pairs( _variant_data ) do
		tar_variant_data[ #tar_variant_data + 1 ] = {   variant_name = key,
														variant_value_type = type(data) == "table" and "table" or "value" ,
														variant_type = type(data) == "table" and type(data[1]) or type(data) ,
														variant_value = type(data) == "table" and table.concat(data,",") or data }
	end
	return tar_variant_data
end

---- 客户端获取
function REQUEST.query_system_variant_data()

	PROTECT.variant_data = PROTECT.get_variant_data()
	local variant_data = basefunc.deepcopy( PROTECT.variant_data )

	local ret = {}

	ret.result = 0

	ret.variant_data = PROTECT.get_variant_data_from_data( variant_data )

	return ret
end

-- by lyx: 返回 默认值
--[[function PROTECT.act_permission_default_value(_act_permi_key)

	-- 默认为 false 的前缀
	local _default_false = {
		"^actp_own_task_",
	}

	for _,v in ipairs(_default_false) do
		if string.find(_act_permi_key,v) then
			return false
		end
	end

	return true
end--]]

-- by lyx: 得到发送的 actact_permission_key ， 返回 nil 表示不发送
function PROTECT.add_send_act_permission_key(send_act_permission_list,_act_permi_key,_value)

	-- 和默认值 不同的才发送
	if DATA.common_permission_manager and DATA.common_permission_manager.act_permission_default_value then
		if not basefunc.cmpbool( DATA.common_permission_manager.act_permission_default_value(_act_permi_key),_value) then
			local _d = DATA.common_permission_manager.permission_cfg_data[_act_permi_key]
			if _d and _d.id then
				send_act_permission_list[#send_act_permission_list + 1] = tostring(_d.id)
			end
		end
	end
end

---- 原始变量改变， 通知客户端
function CMD.on_variant_data_change( _player_id , _variant_data )
	--dump( _variant_data , "xxxx------------------------agent____on_variant_data_change," )
	PROTECT.ori_variant_data = _variant_data

	--local variant_data_tem = PROTECT.get_variant_data()
	PROTECT.variant_data = PROTECT.get_variant_data()
	local variant_data_tem = basefunc.deepcopy( PROTECT.variant_data )

	local variant_data = PROTECT.get_variant_data_from_data( variant_data_tem )

	PUBLIC.request_client( "on_system_variant_data_change_msg" , {
			variant_data = variant_data,
		} )

end

---- 标签改变
function CMD.on_player_tag_vec_changed( _player_id , _new_tags )
	PROTECT.tag_vec = _new_tags

	PROTECT.variant_data = PROTECT.get_variant_data()
	local variant_data_tem = basefunc.deepcopy( PROTECT.variant_data )

	local variant_data = PROTECT.get_variant_data_from_data( variant_data_tem )

	PUBLIC.request_client( "on_system_variant_data_change_msg" , {
			variant_data = variant_data,
		} )
end

---- 当权限改变
function CMD.on_act_permission_change_msg(_player_id , _new_act_permission )
	local old_permission = basefunc.deepcopy( PROTECT.act_permission )

	PROTECT.act_permission = _new_act_permission

	PROTECT.variant_data = PROTECT.get_variant_data()
	local variant_data_tem = basefunc.deepcopy( PROTECT.variant_data )

	local variant_data = PROTECT.get_variant_data_from_data( variant_data_tem )

	----- 是否重新分发任务
	local is_re_dis_task = false
	for permission_key,new_data in pairs(PROTECT.act_permission) do
		local old_data = old_permission[permission_key]

		if string.find(permission_key,"^actp_own_task_") and (not old_data or old_data.is_work == 0) and new_data.is_work == 1 then
			is_re_dis_task = true
		end
	end

	--- 重新分发任务
	if is_re_dis_task then
		CMD.distribute_task( {} )
	end

	PUBLIC.request_client( "on_system_variant_data_change_msg" , {
			variant_data = variant_data,
		} )



end

----- 这个一般只有 发精准任务才触发
function CMD.on_refresh_player_act_permission_msg()

	PROTECT.act_permission =
						skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_act_permission_data" , DATA.my_id )
	--dump(PROTECT.act_permission , "xxxx-----------------------------agent____PROTECT.act_permission:")
	PROTECT.variant_data = PROTECT.get_variant_data()

	--- 重新分发一下任务
	CMD.distribute_task( {} )
end

function PROTECT.destroy()
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "tag_data_variants_change_msg" , PROTECT.msg_tag )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "refresh_player_act_permission_msg" , PROTECT.msg_tag )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "player_tag_vec_changed" , PROTECT.msg_tag )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "act_permission_change_msg" , PROTECT.msg_tag )
end

---- 获取并更新(频繁调，当有now类型的更新时，会频繁请求act_permission_center_service)
--[[function PROTECT.get_player_act_permisssion()
	if not PROTECT.act_permission then
		PROTECT.act_permission =
			skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_act_permission_data" , DATA.my_id )
	end
	PUBLIC.deal_act_permisssion(PROTECT.act_permission)

	return PROTECT.act_permission
end--]]


---- 处理记录玩家的标签，只记一个大概的标签
function PROTECT.deal_recode_player_tag(tag_vec)
	--- 需要记的标签
	local need_deal_tag = {
		"tag_new_player",
		"tag_free_player",
		"tag_stingy_player",
		"tag_vip_low",
		"tag_vip_mid",
		"tag_vip_high",
	}

	if tag_vec and type(tag_vec) == "table" then
		for key,tag_name in pairs(tag_vec) do
			local is_find = false
			for _key,_n_tag in pairs(need_deal_tag) do
				if tag_name == _n_tag then
					is_find = true
					break
				end
			end

			if is_find then
				break
			end
		end
	end

end

--- 处理触发一下基础量改变
function PROTECT.deal_trigger_variant_data_change()
	--print("xx----------------------deal_trigger_variant_data_change" , DATA.my_id )
	--- 这个会触发 距离第一次登录时间不同，从而触发基础参考量改变，从而引起一系列的改变。
	skynet.send( DATA.service_config.data_service , "lua" , "trigger_base_data_change" , DATA.my_id )

	PROTECT.trigger_variant_data_change_timecancel = nodefunc.cancelable_timeout( 86400 * 100 , function()
		PROTECT.deal_trigger_variant_data_change()
	end )
end

function PROTECT.deal_init()
	---- 如果
	if DATA.common_permission_manager and DATA.variant_data_agent_protect and DATA.variant_data_agent_protect.variant_data then
		local is_can_do , error_des = DATA.common_permission_manager.judge_permission_effect( "deal_start_regress_time" , DATA.variant_data_agent_protect.variant_data )
		if is_can_do then
			---
			skynet.send( DATA.service_config.data_service , "lua" , "set_orig_variant" , DATA.my_id , "regress_time" , os.time() )
			-- print("xxx-----------------deal_start_regress_time:",os.time())
		end
	end

	----- 每天24点，触发一下，基础量改变
	local now_time = os.time()
	local today_past_time = basefunc.get_today_past_time(now_time)

	if PROTECT.trigger_variant_data_change_timecancel and type(PROTECT.trigger_variant_data_change_timecancel) == "function" then
		PROTECT.trigger_variant_data_change_timecancel()
	end

	PROTECT.trigger_variant_data_change_timecancel = nodefunc.cancelable_timeout( (86400 - today_past_time) * 100 , function()
		PROTECT.deal_trigger_variant_data_change()
	end )

end

------- 给agent 内部用的 判断权限的接口
function PUBLIC.judge_permission_is_work_for_agent(_permission_key)
	local is_actp_permission = false
	if string.find( _permission_key , "^actp" ) then
		is_actp_permission = true
	end

	---- actp类型权限
	if is_actp_permission then
		if DATA.variant_data_agent_protect and DATA.variant_data_agent_protect.variant_data then
			local act_permission = DATA.variant_data_agent_protect.variant_data.act_permission
			if not act_permission or not act_permission[ _permission_key ] then
				--- 没有数据的话，走actp类型的默认值
				return DATA.common_permission_manager and DATA.common_permission_manager.act_permission_default_value(_permission_key) or false
			else
				--- 有数据
				if act_permission and act_permission[ _permission_key ] and act_permission[ _permission_key ].is_work == 1 then
					--- is_work 等于 1
					return true
				else
					--- is_work 等于0
					return false
				end
			end
		end
	else
		if DATA.common_permission_manager and DATA.variant_data_agent_protect then
			local is_can_do , error_des = DATA.common_permission_manager.judge_permission_effect( _permission_key , DATA.variant_data_agent_protect.variant_data )
			if not is_can_do then
				return false , error_des
			else
				return true
			end
		end
	end
	return false
end


function PROTECT.init()
	---- 一上来去 data_service 去拿
	--print("xx----------------------variant_data_agent" , DATA.my_id )
	--- 这里就用call , 直接触发一次改变。(这里会改变 距离第一次登录时间，和距离上次回归时间)
	skynet.call( DATA.service_config.data_service , "lua" , "trigger_base_data_change" , DATA.my_id )

	PROTECT.ori_variant_data = skynet.call( DATA.service_config.data_service , "lua" , "get_player_variants" , DATA.my_id )

	PROTECT.act_permission = skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_act_permission_data" , DATA.my_id )

	--- 标签
	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx variant_data tag_vec 0000:",DATA.my_id,DATA.service_config.tag_center,basefunc.tostring(PROTECT.tag_vec))
	PROTECT.tag_vec = skynet.call( DATA.service_config.tag_center , "lua" , "get_player_tag_list" , DATA.my_id )
	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx variant_data tag_vec :",DATA.my_id,basefunc.tostring(PROTECT.tag_vec))

	--dump(PROTECT.tag_vec , "xxx----------------------------PROTECT.tag_vec:" .. DATA.my_id)
	------- 处理记录玩家的标签
	PROTECT.deal_recode_player_tag(PROTECT.tag_vec)

	PROTECT.variant_data = PROTECT.get_variant_data()

	----- 监听 参考变量的改变
	PROTECT.msg_tag = PROTECT.msg_tag .. "_" .. DATA.my_id

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "add_msg_listener" , "tag_data_variants_change_msg" , {
			msg_tag = PROTECT.msg_tag ,
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_variant_data_change" ,
			send_filter = { player_id = DATA.my_id } ,
		} )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "add_msg_listener" , "refresh_player_act_permission_msg" , {
			msg_tag = PROTECT.msg_tag ,
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_refresh_player_act_permission_msg" ,
		} )
	--- 监听 tag 改变
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "player_tag_vec_changed" ,{
			msg_tag = PROTECT.msg_tag,    --- DATA.msg_tag  定义在data_service.lua 中
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_player_tag_vec_changed" ,
			send_filter = { player_id = DATA.my_id } ,
		})

	--- 监听 权限 改变
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "act_permission_change_msg" ,{
			msg_tag = PROTECT.msg_tag,    --- DATA.msg_tag  定义在data_service.lua 中
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_act_permission_change_msg" ,
			send_filter = { player_id = DATA.my_id } ,
		})

	------- 马上处理一下，一些特殊的逻辑
	--skynet.timeout(300 , function()
		PROTECT.deal_init()
	--end)


end

return PROTECT
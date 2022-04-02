---- add by wss
--- 通用的系统 参考变量的数据的 管理模块 ， 给各个中心服务用的

local basefunc = require "basefunc"
local skynet = require "skynet_plus"
local base = require "base"
require "common_data_manager_lib"
local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC


DATA.common_variant_data_manager_protect = {}
local PROTECT = DATA.common_variant_data_manager_protect 

PROTECT.msg_tag = nil

---- 原始数据的载入函数
function PROTECT.load_player_variant_data(_player_id)
	return skynet.call( DATA.service_config.data_service , "lua" , "get_player_variants" , _player_id )
end

----- 原始数据的内存管理， 这一层内存缓存，为了避免实时去data_service请求
PROTECT.player_variant_data = PROTECT.player_variant_data or basefunc.hot_class.data_manager_cls.new( { 
																load_data = function(...) return PROTECT.load_player_variant_data(...) end, 
															} 
															, 2000 )    ---- 这个因为各个中心服务要用，所以需求量大，单个不要设的太大了
------------------------------------------------------------------------------------------------------------
------------------ 玩家标签数据
function PROTECT.load_player_tag_vec_data(_player_id)
	return skynet.call( DATA.service_config.tag_center , "lua" , "get_player_tag_list" , _player_id )
end

---- 其他 数据的内存管理 ， 标签 & 活动权限
PROTECT.player_tag_vec = PROTECT.player_tag_vec or basefunc.hot_class.data_manager_cls.new( { 
																load_data = function(...) return PROTECT.load_player_tag_vec_data(...) end, 
															} 
															, 2000 ) 
------------------------------------------------------------------------------------------------------------
------------------ 玩家活动权限数据
function PROTECT.load_player_act_permission_data(_player_id)
	return skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_act_permission_data" , _player_id )
end

---- 其他 数据的内存管理 ， 标签 & 活动权限
PROTECT.player_act_permission = PROTECT.player_act_permission or basefunc.hot_class.data_manager_cls.new( { 
																load_data = function(...) return PROTECT.load_player_act_permission_data(...) end, 
															} 
															, 2000 ) 


function PROTECT.init( _msg_tag )
	if not _msg_tag then
		error( "not _msg_tag !!" )
	end
	PROTECT.msg_tag = _msg_tag

	---- 监听 系统 参考量 改变消息
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "add_msg_listener" , "tag_data_variants_change_msg" , {
			msg_tag = PROTECT.msg_tag ,
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "manager_on_variant_data_change" ,
		} )
	--- 监听刷新act_permission权限
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "add_msg_listener" , "refresh_player_act_permission_msg" , {
			msg_tag = PROTECT.msg_tag ,
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "refresh_player_act_permission_msg" ,
		} )
	--- 监听 tag 改变
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "player_tag_vec_changed" ,{
			msg_tag = PROTECT.msg_tag,    
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_player_tag_vec_changed" ,
		})

	---- 监听权限改变
	--if PROTECT.msg_tag ~= "act_permission_center_service" then
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "act_permission_change_msg" ,{
			msg_tag = PROTECT.msg_tag,    
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_act_permission_change_msg" ,
		})

	--end

end

function PROTECT.destroy()
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "tag_data_variants_change_msg" , PROTECT.msg_tag )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "refresh_player_act_permission_msg" , PROTECT.msg_tag )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "player_tag_vec_changed" , PROTECT.msg_tag )

	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "delete_msg_listener" , "act_permission_change_msg" , PROTECT.msg_tag )
end

---- 当 原始数据 改变时，直接改变
function CMD.manager_on_variant_data_change( _player_id , _variant_data )
	--dump( _variant_data , "xxxx------------------------manager_on_variant_data_change___common_variant_data_manager," .. PROTECT.msg_tag)
	PROTECT.player_variant_data:add_or_update_data( _player_id , _variant_data )
	--print("xxxx---------------------------common_variant_data_manager__manager_on_variant_data_change")
	---- 处理一下活动权限
	--PROTECT.deal_player_act_permission_reload(_player_id)
end

--- 当标签改变
function CMD.on_player_tag_vec_changed( _player_id , _new_tags )
	PROTECT.player_tag_vec:add_or_update_data( _player_id , _new_tags )
	--print("xxxx---------------------------common_variant_data_manager__on_player_tag_vec_changed")
	---- 处理一下活动权限(只有 权限中心的服务才有资格处理，处理完之后，再发一个权限改变的消息出去)
	--PROTECT.deal_player_act_permission_reload(_player_id)
end

---- 强制刷新 活动权限
function CMD.refresh_player_act_permission_msg()
	---- 回收所有缓存
	PROTECT.player_act_permission:recover_data_all()
end

---- 当权限改变
function CMD.on_act_permission_change_msg(_player_id , _new_act_permission)
	PROTECT.player_act_permission:add_or_update_data( _player_id , _new_act_permission)
end

-----------------------------------------------------------------------------------------------
---- 处理活动权限重置
--[[function PROTECT.deal_player_act_permission_reload(_player_id)
	--print("xxxx---------------------------common_variant_data_manager__deal_player_act_permission_reload")
	local _player_act_permission = PROTECT.player_act_permission:get_data( _player_id )
	local now_time = os.time()
	if _player_act_permission and type(_player_act_permission) == "table" then
		for permission_key,data in pairs(_player_act_permission) do
			if now_time > data.next_query_time then
				_player_act_permission[permission_key] = 
					skynet.call( DATA.service_config.act_permission_center_service , "lua" , "get_player_one_act_permission_data" , _player_id , permission_key )
			end
		end
	end
end--]]

---- 获得原始的 系统变量
function PROTECT.get_ori_player_variant_data(_player_id)
	local player_variant_data = PROTECT.player_variant_data:get_data( _player_id )

	local data_tem = basefunc.deepcopy( player_variant_data )

	data_tem.player_id = _player_id

	return data_tem
end

---- 获取原始数据 + tag_vec
function PROTECT.get_ori_player_variant_data_with_tag(_player_id)
	local player_variant_data = PROTECT.player_variant_data:get_data( _player_id )

	local player_tag_vec = PROTECT.player_tag_vec:get_data( _player_id )

	local ret = {}
	ret.tag_vec = basefunc.deepcopy( player_tag_vec )
	
	local data_tem = basefunc.merge( player_variant_data, ret )

	data_tem.player_id = _player_id

	return data_tem
end

---- 获取某个人的 系统变量 ( -- 中心服务这边，直接掉这个函数就可以获得最新的数据 )
function PROTECT.get_player_variant_data(_player_id )
	---- 屏蔽托管,托管不参与权限
	if not basefunc.chk_player_is_real(_player_id) then
		return {}
	end

	local player_variant_data = PROTECT.player_variant_data:get_data( _player_id )

	local now_time = os.time()

	local player_tag_vec = PROTECT.player_tag_vec:get_data( _player_id )

	local player_act_permission = PROTECT.player_act_permission:get_data( _player_id )

	----- 如果有，处理一下每一类型的 是否重置
	--PROTECT.deal_player_act_permission_reload(_player_id)

	local ret = {}
	ret.tag_vec = player_tag_vec
	ret.act_permission = player_act_permission
	
	--return basefunc.merge( player_variant_data, ret )

	local data_tem = basefunc.merge( player_variant_data, ret )

	data_tem.player_id = _player_id

	return data_tem
end

------ 给外部使用的判断权限的接口
function PROTECT.judge_permission_is_work( _common_permission_manager , _player_id , _permission_key )
	local is_actp_permission = false
	if string.find( _permission_key , "^actp" ) then
		is_actp_permission = true
	end

	local variant_data = PROTECT.get_player_variant_data( _player_id )

	---- actp类型权限
	if is_actp_permission then
		if variant_data then
			local act_permission = variant_data.act_permission
			if not act_permission or not act_permission[ _permission_key ] then
				--- 没有数据的话，走actp类型的默认值
				return _common_permission_manager and _common_permission_manager.act_permission_default_value(_permission_key) or false
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
		if _common_permission_manager and variant_data then
			local is_can_do , error_des = _common_permission_manager.judge_permission_effect( _permission_key , variant_data )
			if not is_can_do then
				return false , error_des
			else
				return true
			end
		end
	end
	return false
end


return PROTECT

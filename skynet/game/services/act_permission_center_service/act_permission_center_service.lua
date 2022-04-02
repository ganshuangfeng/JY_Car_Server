----- 活动权限 中心 服务

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

require "data_func"
require "normal_enum"
require "printfunc"
require "common_data_manager_lib"
require "common_merge_push_sql_lib"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

DATA.msg_tag = "act_permission_center_service"

---- 处理 判定的类型
DATA.deal_time_type = "day_delay"    ---- now  及时处理 , day_delay  每天延迟处理
----
DATA.deal_time_day_delay_hour = 0

---- 玩家的系统参考量的管理器
DATA.variant_data_manager = require "common_variant_data_manager"
--- 权限判断模块
DATA.permission_manager = require "permission_manager.common_permission_manager"

----- 老的当原始量改变的处理函数
CMD.manager_on_variant_data_change_old = CMD.manager_on_variant_data_change
----- 老的当标签改变的处理函数
CMD.on_player_tag_vec_changed_old = CMD.on_player_tag_vec_changed

------- 检查权限是否改变
function PUBLIC.check_act_permission_change(_player_id , _old_value )

	--- 托管不用处理
	if not basefunc.chk_player_is_real(_player_id) then
		return
	end

	local _new_value = CMD.get_player_act_permission_data(_player_id)

	--dump( _new_value , "xxx-----------------check_act_permission_change___new_value:" .. _player_id )

	---- 如果两个不相同，则发出一个改变消息
	local is_same = basefunc.compare_vaule_same( _old_value , _new_value )
	--print("xxxx--------------------is_same_",is_same,_player_id)

	if not is_same then
		print.wss_test("xxx--------------------trigger_msg___act_permission_change_msg",_player_id)
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , 
			{ name = "act_permission_change_msg" , send_filter = { player_id = _player_id } } , 
			_player_id , _new_value , _old_value )
	end
end

---- 当 原始数据 改变时，直接改变
function CMD.manager_on_variant_data_change( _player_id , _variant_data )
	--dump( _variant_data , "xxxx------------------------manager_on_variant_data_change___act_permission," .. _player_id )

	--dump( DATA.variant_data_manager.player_tag_vec:get_data( _player_id ) , "xxx---------------------____tag_vec")

	local old_act_permission = CMD.get_player_act_permission_data_no_deal(_player_id)

	--dump( old_act_permission , "xxx-----------------___old_act_permission:".._player_id )

	if CMD.manager_on_variant_data_change_old and type(CMD.manager_on_variant_data_change_old) == "function" then
		CMD.manager_on_variant_data_change_old( _player_id , _variant_data )
	end

	PUBLIC.check_act_permission_change(_player_id , old_act_permission )

end

--- 当标签改变
function CMD.on_player_tag_vec_changed( _player_id , _new_tags )
	--dump( _new_tags , "xxxx------------------------manager_on_player_tag_vec_changed___new_tags," )

	local old_act_permission = CMD.get_player_act_permission_data_no_deal(_player_id)

	if CMD.on_player_tag_vec_changed_old and type(CMD.on_player_tag_vec_changed_old) == "function" then
		CMD.on_player_tag_vec_changed_old( _player_id , _new_tags )
	end

	PUBLIC.check_act_permission_change(_player_id , old_act_permission )
end

---- 权限自己，就不用更新最新的权限表了()
function CMD.on_act_permission_change_msg(_player_id , _new_act_permission)
	
end

---------------------------------------------------------------------------------------------------------------------------
function PUBLIC.load_player_act_permission_data(_player_id)
	-- 查询数据，返回结果集，出错则返回 nil
	local _sql = PUBLIC.format_sql( [[ select * from player_act_permission_data where player_id = %s; ]] , _player_id )

	local ret = PUBLIC.query_data(_sql)
	--dump(ret , "xxxx-----------------------load_player_act_permission_data:")
	if not ret then
		--print("xxx---------ret 1")
		return nil
	end

	local ret_vec = {}
	if ret and type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			--- 
			ret_vec[data.permission] = data
		end
	end
	--print("xxx---------ret 2")
	return ret_vec
end

DATA.player_act_permission_data = DATA.player_act_permission_data or basefunc.hot_class.data_manager_cls.new( { 
																load_data = function(...) return PUBLIC.load_player_act_permission_data(...) end, 
															} 
															, 30000 ) 



function PUBLIC.delete_player_act_permission_data(_player_id , _permission_name)
	---- 直接删掉这个类型的缓存数据。
	DATA.update_merge_sql_pusher:delete_sql_cache( { _player_id , _permission_name } )

	local _sql = PUBLIC.format_sql( [[ delete from player_act_permission_data where player_id = %s and permission = %s ; ]] , _player_id , _permission_name )

	PUBLIC.query_data(_sql)
end


function PUBLIC.add_or_update_act_permission_data(_player_id , _permission_name )
	--- 如果是托管return
	if not basefunc.chk_player_is_real(_player_id) then
		--print("xxx--------------------update_act_permission_error:", debug.traceback() )
		return
	end

	--local sql_str = PUBLIC.format_sql([[
	--					SET @_player_id = %s;
	--					SET @_permission = %s;
	--					SET @_is_work = %s;
	--					insert into player_act_permission_data 
	--					(player_id , permission , is_work)
	--					values(@_player_id , @_permission , @_is_work )
	--					on duplicate key update
	--					player_id = @_player_id,
	--					permission = @_permission,
	--					is_work = @_is_work;
	--				]] , _player_id , _permission_name , _is_work )
--
	--local queue_type,queue_id = PUBLIC.db_exec_call(sql_str)
	--DATA.player_act_permission_data:update_sql_queue_data(_player_id , queue_type , queue_id)

	local _now_act_permission = DATA.player_act_permission_data:get_data( _player_id )

	if _now_act_permission[_permission_name] then
		DATA.update_merge_sql_pusher:add_to_sql_cache( { _player_id , _permission_name } , _now_act_permission[_permission_name] , _player_id )

	else
		---- 如果没得这个 权限类型的数据了 ，直接删掉这个类型的缓存数据。
		DATA.update_merge_sql_pusher:delete_sql_cache( { _player_id , _permission_name } )
	end

end

--function PUBLIC.update_act_permission_lock(_player_id , _permission_name , _is_lock)
--	--- 如果是托管return
--	if not basefunc.chk_player_is_real(_player_id) then
--		print("xxx--------------------update_act_permission_error:", debug.traceback() )
--		return
--	end
--
--	local _sql = PUBLIC.format_sql( [[ update player_act_permission_data set is_lock = %s where player_id = %s and permission = %s ; ]] ,_is_lock, _player_id , _permission_name )
--
--	PUBLIC.db_exec(_sql)
--end

--function PUBLIC.update_act_permission_last_deal_time(_player_id , _permission_name , _last_deal_time)
--	--- 如果是托管return
--	if not basefunc.chk_player_is_real(_player_id) then
--		print("xxx--------------------update_act_permission_error:", debug.traceback() )
--		return
--	end
--
--	local _sql = PUBLIC.format_sql( [[ update player_act_permission_data set last_deal_time = %s where player_id = %s and permission = %s ; ]] ,_last_deal_time, _player_id , _permission_name )
--
--	PUBLIC.db_exec(_sql)
--end

------------------------------------------------------------------------------------------------------------------------------------------
---- 处理某一个 活动权限
function PUBLIC.deal_one_act_permission(_player_id , cfg_permission_name)
	local now_time = os.time()
	--print("xxxx-------------------------deal_one_act_permission:",_player_id , cfg_permission_name )
	local cfg_data = DATA.permission_manager.get_all_act_permission_cfg_data()
	local _now_act_permission = DATA.player_act_permission_data:get_data( _player_id )

	local tar_cfg_data = cfg_data[ cfg_permission_name ]
	if not tar_cfg_data then
		--print("xxxx-------------------------deal_one_act_permission___return 11:",_player_id , cfg_permission_name )
		return false
	end

	local get_is_deal = function(_deal_time_type )
		_deal_time_type = _deal_time_type or "day_delay"
		local is_deal = false

		--- 先判断时间,如果时间未到,那么不能处理
		--if tar_cfg_data and tar_cfg_data.start_deal_time and now_time < tar_cfg_data.start_deal_time then
		--	return is_deal
		--end

		---- 及时处理
		if _deal_time_type == "now" then
			is_deal = true
		elseif _deal_time_type == "day_delay" then
			local last_deal_time = _now_act_permission[cfg_permission_name] and _now_act_permission[cfg_permission_name].last_deal_time or 0

			---- 判断时间
			if not is_deal then
				local is_same_day = basefunc.is_same_day( last_deal_time , now_time , DATA.deal_time_day_delay_hour ) 
	 			if not is_same_day then

	 				is_deal = true
	 			end
			end
		end
		return is_deal
	end

	

	local is_deal = get_is_deal( tar_cfg_data.refresh_type )
	if not is_deal then ---- 这里会限制，day_delay类型的权限，只有在每天第一次登录时才处理
		--print("xxxx-------------------------deal_one_act_permission___return 22:",_player_id , cfg_permission_name )
		return false
	end

	--- 如果时间未到,那么处理成 假 的不能做(PS：这个避免是客户端一直在线，在未刷的情况下，出现客户端出现界面但没有数据的情况。)
	--- 这个客户端如果在开始处理时间的前面上来了，那么客户端拿到的是false的，如果一直不触发权限改变，这个假权限可能一直是false
	if tar_cfg_data and tar_cfg_data.start_deal_time and now_time < tar_cfg_data.start_deal_time then

		_now_act_permission[cfg_permission_name] = { 	player_id = _player_id, 
														permission = cfg_permission_name, 
														is_work = 0 , 
														is_lock = 0 , 
														last_deal_time = 0 , -- 这个值一定要是0,避免被时间检查屏蔽了
														is_fake = true,
													} 
		
		-- 这里 一定 不能写数据库。为啥？因为你存了，内存里面下次再加载进来的时候，当时间大于了 start_deal_time 就没有 is_fake这个标志了。就不是第一次设置变量了。
		--PUBLIC.add_or_update_act_permission_data(_player_id , cfg_permission_name  )
		return true
	end

	--- 如果数据库中没有
	if not _now_act_permission[cfg_permission_name] or (_now_act_permission[cfg_permission_name] and _now_act_permission[cfg_permission_name].is_fake) then
		--print("xxxx-------------------------deal_one_act_permission222:",_player_id , cfg_permission_name )
		--- 是新的，直接用这次算的是否达成条件
		local is_work = DATA.permission_manager.judge_permission_effect( cfg_permission_name , DATA.variant_data_manager.get_ori_player_variant_data_with_tag(_player_id) )
		is_work = is_work and 1 or 0
		_now_act_permission[cfg_permission_name] = { player_id = _player_id, permission = cfg_permission_name, is_work = is_work , is_lock = 0 , last_deal_time = now_time } 
		
		PUBLIC.add_or_update_act_permission_data(_player_id , cfg_permission_name  )
		--PUBLIC.update_act_permission_last_deal_time(_player_id , cfg_permission_name , now_time)
	else
		--print("xxxx-------------------------deal_one_act_permission333:",_player_id , cfg_permission_name )
		----- 如果数据库中有
		--- 如果没有锁定
		if _now_act_permission[cfg_permission_name].is_lock == 0 then
			--print("xxxx-------------------------deal_one_act_permission444:",_player_id , cfg_permission_name )
			---- 如果要动态改变
			local is_work = DATA.permission_manager.judge_permission_effect( cfg_permission_name , DATA.variant_data_manager.get_ori_player_variant_data_with_tag(_player_id) )
			is_work = is_work and 1 or 0
			
			--- 是否从新设置
			local is_reset = false
			if (is_work == 1 and tar_cfg_data.is_dynamic_codi == 1) or (is_work == 0 and tar_cfg_data.is_dynamic_cancel == 1) then
				is_reset = true
			end

			----------------------------- 针对now这种类型的权限，如果这一次的is_work和上一次的is_work一样，那么就不能更新
			--- 之前这个权限的is_work是啥，
			local old_is_work = _now_act_permission[cfg_permission_name].is_work
			if old_is_work and tar_cfg_data.refresh_type == "now" and is_work == old_is_work then
				is_reset = false
			end
			------------------------------

			if is_reset then
				_now_act_permission[cfg_permission_name].is_work = is_work 
				_now_act_permission[cfg_permission_name].last_deal_time = now_time 

				PUBLIC.add_or_update_act_permission_data(_player_id , cfg_permission_name )
				--PUBLIC.update_act_permission_last_deal_time(_player_id , cfg_permission_name , now_time)
			end
		end
	end

	DATA.player_act_permission_data:add_or_update_data(_player_id , _now_act_permission )
	return true
end

---- 处理更新活动权限
function PUBLIC.deal_act_permission( _player_id )
	--print("xxxx------------------deal_act_permission:",_player_id)

	--- 先拿出 数据库中的数据
	local _now_act_permission = DATA.player_act_permission_data:get_data( _player_id )
	--dump(_now_act_permission , "xxx--------------_now_act_permission:")
	local now_time = os.time()
	--print("xxx-------------------deal_act_permission___1")
	---- 活动权限的所有配置数据
	local cfg_data = DATA.permission_manager.get_all_act_permission_cfg_data()
	--print("xxx-------------------deal_act_permission___2")
	--- 先删掉多余的
	-- by lyx: 用 pcall 抱起来，并且 循环结束后再删除
	local ok ,msg = pcall(function()
	
		local _deletes = {}
		
		for permission_name , data in pairs(_now_act_permission) do
			if not cfg_data[ permission_name ] then

				--_now_act_permission[permission_name] = nil
				_deletes[permission_name] = _player_id
				--- 先删掉多余的
				--PUBLIC.delete_player_act_permission_data(_player_id , permission_name) 
			end
		end
		
		for k,pid in pairs(_deletes) do
			_now_act_permission[k] = nil
			PUBLIC.delete_player_act_permission_data(pid , k)
		end
	end)
	if not ok then
		dump({msg,_now_act_permission},"xxxxxxxxxxxxxxxxxxxx deal_act_permission:" )
		return
	end

	--print("xxx-------------------deal_act_permission___3")
	--dump(cfg_data , "xxx-------------------deal_act_permission__")
	---- 对所有的配置项做处理(此时，只可能是配置项里面多于数据库里面的项目)
	for cfg_permission_name , data in pairs(cfg_data) do
	--	print("xxxx----------------deal_one_act_permission____"..cfg_permission_name)
		PUBLIC.deal_one_act_permission(_player_id , cfg_permission_name)
	end
	--print("xxx-------------------deal_act_permission___4")
	--DATA.player_act_permission_data:add_or_update_data( _now_act_permission )

end

---- 设置某人的 活动权限的开关
function CMD.set_act_permission_work(_player_id , _permission_name , _is_work)
	local _now_act_permission = DATA.player_act_permission_data:get_data( _player_id )

	if not _now_act_permission[_permission_name] then
		_now_act_permission[_permission_name] = { player_id = _player_id, permission = _permission_name, is_work = _is_work , is_lock = 0 } 
	else
		_now_act_permission[_permission_name].is_work = _is_work
	end
	PUBLIC.add_or_update_act_permission_data(_player_id , _permission_name  )
end

---- 设置某人的 活动权限的锁定
function CMD.set_act_permission_lock(_player_id , _permission_name , _is_lock)
	local _now_act_permission = DATA.player_act_permission_data:get_data( _player_id )

	if not _now_act_permission[_permission_name] then
		---- 如果都没有这个活动权限的数据 ， 不用锁
		-- _now_act_permission[_permission_name] = { player_id = _player_id, permission = _permission_name, is_work = _is_work , is_lock = _is_lock } 
	else
		_now_act_permission[_permission_name].is_lock = _is_lock
	end
	--PUBLIC.update_act_permission_lock(_player_id , _permission_name , _is_lock)

	PUBLIC.add_or_update_act_permission_data(_player_id , _permission_name )
end 


--- 获得下次才能请求的时间
function PUBLIC.get_next_query_time(_deal_time_type)

	local now_time = os.time()

	if _deal_time_type == "now" then
		return now_time
	elseif _deal_time_type == "day_delay" then
		local today_past_time = basefunc.get_today_past_time(now_time)

		local time = 86400
		if today_past_time < DATA.deal_time_day_delay_hour * 3600 then
			time = now_time + DATA.deal_time_day_delay_hour * 3600 - today_past_time + 5
		else
			time = now_time + 86400 - (today_past_time - DATA.deal_time_day_delay_hour * 3600) + 5
		end

		return time
	end
	return now_time 
end

----- 获取当前的活动权限，不用带处理新的判断的那种
function CMD.get_player_act_permission_data_no_deal(_player_id)
	local act_permission_data = DATA.player_act_permission_data:get_data( _player_id )
	
	local ret_vec = {}
	------ 
	for permission_key,data in pairs(act_permission_data) do

		ret_vec[permission_key] = { is_work = data.is_work }
		
	end
	
	return ret_vec 
end

----- 获得玩家的活动权限
function CMD.get_player_act_permission_data(_player_id)
	--print("xxxx-----------CMD__get_player_act_permission_data___0")
	PUBLIC.deal_act_permission( _player_id )
	--print("xxxx-----------CMD__get_player_act_permission_data___1")
	local act_permission_data = DATA.player_act_permission_data:get_data( _player_id )
	--print("xxxx-----------CMD__get_player_act_permission_data___2")
	---- 活动权限的所有配置数据
	--local cfg_data = DATA.permission_manager.get_all_act_permission_cfg_data()
	--print("xxxx-----------CMD__get_player_act_permission_data___3")
	local ret_vec = {}
	--print("xxxx-----------CMD__get_player_act_permission_data___4")
	------ 
	for permission_key,data in pairs(act_permission_data) do

		--[[local next_query_time = PUBLIC.get_next_query_time("day_delay")
		if cfg_data[permission_key] then
			next_query_time = PUBLIC.get_next_query_time( cfg_data[permission_key].refresh_type )
		end
		----- 如果 是未到时间的假数据的下次请求，用0，随时可以请求
		if data.is_fake == true then
			if cfg_data[permission_key] then
				next_query_time = cfg_data[permission_key].start_deal_time or 0
			else
				next_query_time = 0
			end
		end--]]

		--if data.is_work == 1 then
			--ret_vec[permission_key] = { is_work = data.is_work , next_query_time = next_query_time }
			ret_vec[permission_key] = { is_work = data.is_work }
		--end
	end
	--print("xxxx-----------CMD__get_player_act_permission_data___5")
	return ret_vec 
end

----- 获得某一个权限的数据（好像已弃用了）
function CMD.get_player_one_act_permission_data(_player_id , _permission_key)
	--print("xxx---------------------------------get_player_one_act_permission_data:",_player_id , _permission_key)
	PUBLIC.deal_one_act_permission(_player_id , _permission_key)

	local act_permission_data = DATA.player_act_permission_data:get_data( _player_id )

	---- 活动权限的所有配置数据
	--local cfg_data = DATA.permission_manager.get_all_act_permission_cfg_data()

	local ret_vec = {}
	------ 
	if act_permission_data[_permission_key] then
		--[[local next_query_time = PUBLIC.get_next_query_time("day_delay")
		if cfg_data[_permission_key] then
			next_query_time = PUBLIC.get_next_query_time( cfg_data[_permission_key].refresh_type )
		end
		----- 如果 是未到时间的假数据的下次请求，用0，随时可以请求
		if act_permission_data[_permission_key].is_fake == true then
			if cfg_data[_permission_key] then
				next_query_time = cfg_data[_permission_key].start_deal_time or 0
			else
				next_query_time = 0
			end
		end--]]

		--ret_vec = { is_work = act_permission_data[_permission_key].is_work , next_query_time = next_query_time }

		ret_vec = { is_work = act_permission_data[_permission_key].is_work }
	end

	return ret_vec 
end

----- 主动触发一个消息 ; 新增项目时（让所有agent,或中心服务感知到配置变化）
function CMD.refresh_player_act_permission()
	
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , 
			{ name = "refresh_player_act_permission_msg"} )
	
end



function PUBLIC.init()

	DATA.update_merge_sql_pusher = DATA.update_merge_sql_pusher or basefunc.server_class.common_merge_push_sql_lib.new( 60 , DATA.player_act_permission_data , {
		tab_name = "player_act_permission_data",
		queue_type = "slow",
		push_type = "update",
		field_data = {
			player_id = {
				is_primary = true,
				value_type = "equal",
			},
			permission = {
				is_primary = true,
				value_type = "equal",
			},
			is_work = {
				value_type = "equal",
			},
			is_lock = {
				value_type = "equal",
			},
			last_deal_time = {
				value_type = "equal",
			},
		},
	} )

	DATA.permission_manager.init(false)

 	DATA.variant_data_manager.init( DATA.msg_tag )

 	---- 给一个开始的随机值，避免一个时间点爆发
 	--skynet.timeout( math.random(0,1000) , function() 
 	--	print("xxx--------- start__update_merge_sql_pusher:start_timer act_permission")
 	--	DATA.update_merge_sql_pusher:start_timer()
 	--end)

end

function CMD.start(_service_config)

	DATA.service_config = _service_config

	PUBLIC.init()

end

-- 启动服务
base.start_service()
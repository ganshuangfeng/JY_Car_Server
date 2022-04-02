local base=require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local skynet = require "skynet_plus"
require "normal_enum"
require "printfunc"
require "data_func"
require "common_data_manager_lib"
local task_base_func = require "task.task_base_func"
local common_task = require "task.common_task"

require "common_merge_push_sql_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

---奖励状态
DATA.award_status = {
	not_can_get = 0,
	can_get = 1,
	complete = 2,
	not_open = 3,     --- 未开启
}

---- 玩家的系统参考量的管理器
DATA.variant_data_manager = require "common_variant_data_manager"
--- 权限判断模块
DATA.permission_manager = require "permission_manager.common_permission_manager"

DATA.msg_tag = "task_center_service"
--
DATA.update_dt = 1

------ 合并更新任务数据的间隔更新时间
DATA.merge_update_task_data_delay = 2
DATA.last_merge_update_time = 0

------ 合并插入任务进度改变的间隔时间
DATA.merge_insert_task_log_delay = 3
DATA.last_merge_insert_time = 0

---- 需要延迟更新的任务数据的
DATA.need_delay_update_task_data_vec = {}
DATA.is_dealing_delay_update_task_data = false

---- 需要延迟合并插入的任务改变日志
DATA.need_delay_insert_task_log_vec = {}
DATA.is_dealing_delay_insert_task_log = false


DATA.task_center_op_interface_protect = {}
local PROTECT = DATA.task_center_op_interface_protect

function PROTECT.load_one_data( player_id )
	-- 查询数据，返回结果集，出错则返回 nil

	local _sql = string.format( [[ select * from player_task where player_id = '%s'; ]] , player_id )

	local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	if( ret.errno ) then
		print(string.format("query_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	
	local ret_vec = {}

	if ret and type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			ret_vec[data.task_id] = data
		end
	end

	--dump( ret_vec , "xxx---------------------- task_center_service , load_one_data ret: " ) 
		
	return ret_vec
	
end

-----------------------------------------------------------------------------------------------------
function PROTECT.load_one_task_switch_data(player_id)
	local _sql = string.format( [[ select * from player_task_switch where player_id = '%s'; ]] , player_id )

	local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	if( ret.errno ) then
		print(string.format("query_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	
	local ret_vec = {}

	if ret and type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			ret_vec[data.task_id] = data
		end
	end

	--dump( ret_vec , "xxx---------------------- task_center_service , load_one_data ret: " ) 
		
	return ret_vec
end


PROTECT.data_manager = PROTECT.data_manager or basefunc.server_class.data_manager_cls.new( { load_data = PROTECT.load_one_data } , 30000 )
------ 玩家的任务开关的内存管理
PROTECT.task_switch_data = PROTECT.task_switch_data or basefunc.server_class.data_manager_cls.new( { load_data = PROTECT.load_one_task_switch_data } , 10000 )



---- 给一个开始的随机值，避免一个时间点爆发
--skynet.timeout( math.random(0,1000) , function() 
-- 	print("xxx--------- start__update_merge_sql_pusher:start_timer task_center 1 ")
-- 	PROTECT.data_merge_sql_pusher:start_timer()
--end)





---- 给一个开始的随机值，避免一个时间点爆发
--skynet.timeout( math.random(0,1000) , function() 
--	print("xxx--------- start__update_merge_sql_pusher:start_timer task_center 2 ")
--	PROTECT.insert_log_merge_sql_pusher:start_timer()
--end)
----- 载入任务服务配置
function PROTECT.load_task_server_cfg(raw_config)
	--local raw_config = base.reload_config("task_server")

	--DATA.task_main_config = {}  
	local main_config = {}  

	local aws = {}
	for i,ad in ipairs(raw_config.award_data) do
		
		aws[ad.award_id] = aws[ad.award_id] or {}
		local len = #aws[ad.award_id]+1

		local target_asset_type = ad.asset_type
		---- 处理限时道具
		local str_split_vec = basefunc.string.split(ad.asset_type, "_")

		local obj_lifetime = nil
		if str_split_vec and type(str_split_vec) == "table" and next(str_split_vec) then
			if str_split_vec[1] == "obj" then
				obj_lifetime = 86400
				if tonumber(str_split_vec[#str_split_vec]) then
					target_asset_type = ""
					for i=1,#str_split_vec - 1 do
						target_asset_type = target_asset_type .. str_split_vec[i]
						if i ~= #str_split_vec - 1 then
							target_asset_type = target_asset_type .. "_"
						end
					end

					obj_lifetime = tonumber( str_split_vec[#str_split_vec] )
				end
			end
		end

		aws[ad.award_id][len] = {
			award_name = ad.award_name,
			asset_type = target_asset_type,
			value = ad.asset_count,
			weight = ad.get_weight or 1,
			broadcast_content = ad.broadcast_content,
			is_send_email = ad.is_send_email,
		}

		if obj_lifetime then
			aws[ad.award_id][len].value = nil
			aws[ad.award_id][len].lifetime = obj_lifetime
		end

	end

	----- 条件表
	local condition = {}
	for id,data in pairs(raw_config.condition) do
		condition[ data.condition_id ] = condition[ data.condition_id ] or {}
		local cond = condition[ data.condition_id ]
		cond[data.condition_name] = { condition_value = data.condition_value , judge_type = data.judge_type }
	end

	--- 参与条件表
	local join_condition = {}
	if raw_config.join_condition then
		for key,data in pairs(raw_config.join_condition) do
			join_condition[data.condition_id] = join_condition[data.condition_id] or {}
			local cond = join_condition[ data.condition_id ]
			cond[data.condition_name] = { 
				condition_value = data.condition_value, 
				judge_type = data.judge_type,
			}
		end
	end

	--- 进度来源表
	local source = {}
	if raw_config.source then
		for key,data in pairs(raw_config.source) do
			--- 如果有来源类型
			if data.source_type then
				--
				source[ data.source_id ] = source[ data.source_id ] or {}
				local tar_data = source[ data.source_id ]

				---- 防配置出错
				if data.process_discount then
					if data.process_discount > 1 then
						data.process_discount = 1
					end
					if data.process_discount < 0 then
						data.process_discount = 0
					end
				end

				tar_data[#tar_data + 1] = {
					source_type = data.source_type ,
					condition_data = basefunc.deepcopy( condition[ data.condition_id ] or {} ) , 
					process_discount = data.process_discount or 1,
				}	
			end
		end
	end

	for id,td in pairs(raw_config.task) do

		main_config[id]=td

		for i,cd in ipairs(raw_config.process_data) do
			if td.process_id == cd.process_id then
				if not cd.process then
					cd.process = 0
				end

				if type(cd.process) == "number" then
					cd.process = { cd.process }
				end

				main_config[id].condition_type = cd.condition_type
				main_config[id].source_data = cd.source_id and basefunc.deepcopy( source[ cd.source_id ] or {} ) or {}
				--main_config[id].condition_data = basefunc.deepcopy( condition[ cd.condition_id ] or {} )
				main_config[id].get_award_type = cd.get_award_type or "nor"
				main_config[id].process_data=cd.process
				main_config[id].pre_add_process = cd.pre_add_process
				main_config[id].award_data={}

				main_config[id].join_condition = cd.join_condition and join_condition[cd.join_condition]

				main_config[id].is_auto_get_award = cd.is_auto_get_award

				---- 如果是一个数字就转成数组
				if not cd.awards then
					cd.awards = {}
				elseif type(cd.awards) == "number" then
					cd.awards = { cd.awards }
				end
				for i,ai in ipairs(cd.awards) do
					main_config[id].award_data[i] = basefunc.deepcopy( aws[ai] )
				end

			end
		end

		main_config[id].process_id=nil

	end

	return main_config
end

---- 发给所有在线玩家，任务更新
function PROTECT.send_players_task_config_refresh()
	local num = 10

	skynet.fork(function ()
		
		local player_list = skynet.call(DATA.service_config.data_service,"lua"
														,"select_players_list",1,0,true)

		local sn = 0

		--发在线的玩家
		for i,player_id in ipairs(player_list) do

			--发送活动状态数据
			nodefunc.send(player_id,"on_task_config_change_and_distribute_task")

			sn = sn + 1
			if sn > num then
				skynet.sleep(1)
				sn = 0
			end

		end

	end)

	------- 发出一个改变消息
	skynet.send( base.DATA.service_config.msg_notification_center_service , "lua" , "trigger_msg" , {name = "task_config_change" } )

end


function PUBLIC.load_task_switch_set_config(_raw_config)
	local config = _raw_config

	DATA.task_switch_set_config = {}

	if config.task and type(config.task) == "table" then
		for task_id,data in pairs(config.task) do
			if config[data.player_vec] and type(config[data.player_vec]) == "table" then
				for no,data in pairs(config[data.player_vec]) do
					DATA.task_switch_set_config[tostring(data.player_id)] = DATA.task_switch_set_config[tostring(data.player_id)] or {}
					local player_config = DATA.task_switch_set_config[tostring(data.player_id)]

					player_config[task_id] = "true"

				end
			end

		end
	end


end

function PROTECT.refresh_config()

	nodefunc.query_global_config("task_server", function(config)
		DATA.task_main_config = PROTECT.load_task_server_cfg(config)
		
		PROTECT.send_players_task_config_refresh()
	end)

	------ 
	nodefunc.query_global_config("player_task_switch_set_server", PUBLIC.load_task_switch_set_config )

end

function PROTECT.clear_refresh_config()
	nodefunc.clear_global_config_cb("task_server")
end

-- 载入所有玩家数据
--[[function PUBLIC.load_all_player_task_data()
	local task_data = skynet.call(DATA.service_config.data_service,"lua","query_all_player_task_data")
	if task_data then
		DATA.player_task_data = task_data
	end
end--]]

------ 获取某个玩家的任务开关数据
function CMD.query_player_task_switch_data(_player_id)
	return PROTECT.task_switch_data:get_data(_player_id)
end

------ 设置某个玩家的任务开关
function CMD.set_player_task_switch_data(_player_id , _task_id , _bool_str , _is_not_dis_task )
	if type(_player_id) == "string" and type(_task_id) == "number" and type(_bool_str) == "string" and (_bool_str == "true" or _bool_str == "false") then
		local switch_data = PROTECT.task_switch_data:get_data(_player_id)
		--- 更新内存
		switch_data = switch_data or {}
		switch_data[_task_id] = switch_data[_task_id] or {}
		switch_data[_task_id].player_id = _player_id
		switch_data[_task_id].task_id = _task_id
		switch_data[_task_id].is_enable = _bool_str == "true" and 1 or 0

		---- 写数据库
		local _queue_type , _queue_id = skynet.call(DATA.service_config.data_service,"lua","update_player_task_switch"
					,_player_id
					,_task_id
					,switch_data[_task_id].is_enable )

		
		PROTECT.task_switch_data:add_or_update_data(_player_id , switch_data , _queue_type , _queue_id)

		--- 如果不是 不分发任务，就分发任务
		if not _is_not_dis_task then
			nodefunc.send(_player_id,"distribute_task" , { task_item_change_msg = true } )
		end
	end

end

function PUBLIC.set_task_switch_by_config(config)
	if config and type(config) == "table" then
		for player_id , data in pairs(config) do
			CMD.set_player_task_switch_data_by_vec(player_id , data)
		end
	end
end

function CMD.set_player_task_switch_data_by_config()
	local config = nodefunc.get_global_config("player_task_switch_set_config")

	PUBLIC.set_task_switch_by_config(config)

end

-----
function CMD.set_player_task_switch_data_by_auto_config()
	PUBLIC.set_task_switch_by_config( DATA.task_switch_set_config )
end

------ 设置某个玩家的任务开关
function CMD.set_player_task_switch_data_by_vec(_player_id , _task_ids)
	if type(_player_id) == "string" and type(_task_ids) == "table" then
		local switch_data = PROTECT.task_switch_data:get_data(_player_id)
		--- 更新内存
		switch_data = switch_data or {}
		
		local _queue_type = "slow"
		local _queue_id = 0
		for task_id,kaiguan in pairs(_task_ids) do
			print("xxx----open_player_task_switch_data key,value:",_player_id,task_id,kaiguan)

			-----（循环利用方案） 每次推之前要检查如果是打开这个人的任务，则判断这次推送的时间和上次推送成功的时间如果大于了n天 & 这个任务原本是打开的，就先删掉

			switch_data[task_id] = switch_data[task_id] or {}
			switch_data[task_id].player_id = _player_id
			switch_data[task_id].task_id = task_id
			switch_data[task_id].is_enable = kaiguan == "true" and 1 or 0

			_queue_type = "slow"
			_queue_id = 99999999

			---- 写数据库
			_queue_type,_queue_id = skynet.call(DATA.service_config.data_service,"lua","update_player_task_switch"
					,_player_id
					,task_id
					,switch_data[task_id].is_enable )

		end

		PROTECT.task_switch_data:add_or_update_data(_player_id , switch_data,_queue_type , _queue_id)

		nodefunc.send(_player_id,"distribute_task" , { task_item_change_msg = true } )

	end

end


-- 获取某个玩家的任务数据， 缓存 拿
function CMD.query_player_task_data(_player_id)

	--return DATA.player_task_data[_player_id]

	return PROTECT.data_manager:get_data(_player_id)

end

function CMD.query_player_one_task_data(_player_id , _task_id)
	-- DATA.player_task_data[_player_id] = DATA.player_task_data[_player_id] or {}
	local player_data = PROTECT.data_manager:get_data(_player_id)

	return player_data and player_data[_task_id] or nil
end

------- 请求一个任务的客户端显示的数据
function CMD.query_player_one_task_client_data(_player_id , _task_id)
	-- DATA.player_task_data[_player_id] = DATA.player_task_data[_player_id] or {}
	local player_data = PROTECT.data_manager:get_data(_player_id)

	local task_data = player_data and player_data[_task_id] or nil

	local target_value = nil
	if task_data then
		local task_cfg = CMD.get_main_config()
		if task_cfg[_task_id] then
			target_value = {}
			local task_obj = common_task.gen_task_obj( task_cfg[_task_id], task_data )

			task_obj.fork_init()

			task_base_func.get_one_task_data(task_obj , target_value)
			return target_value
		end
	end

	return target_value
end

function CMD.update_player_task_other_data(_player_id , _task_id , _other_data)
	local player_data = PROTECT.data_manager:get_data(_player_id)


	if player_data and player_data[_task_id] then
		local task_data = player_data[_task_id]

		task_data.other_data = _other_data

		local _queue_type,_queue_id = skynet.call(DATA.service_config.data_service,"lua","update_player_task_other_data"
					,_player_id
					,_task_id
					,_other_data
					)

		PROTECT.data_manager:add_or_update_data(_player_id , player_data , _queue_type , _queue_id)
	end
end

-- 更新or新增 玩家数据
function CMD.add_or_update_task_data(_player_id , _task_id , _process , _task_round , _create_time , _task_award_get_status , _time_limit)

	local player_data = PROTECT.data_manager:get_data(_player_id)

	player_data = player_data or {}
	player_data[_task_id] = player_data[_task_id] or {}

	local task_data = player_data[_task_id]

	task_data.player_id = _player_id
	task_data.task_id = _task_id
	task_data.process = _process
	task_data.task_round = _task_round
	task_data.create_time = _create_time
	task_data.task_award_get_status = _task_award_get_status
	task_data.time_limit = _time_limit

	PROTECT.data_manager:add_or_update_data(_player_id , player_data )

	------ 放到延迟更新的数据map中
	--PUBLIC.add_delay_merge_update_data(_player_id , _task_id , _process , _task_round , _create_time , _task_award_get_status , _time_limit)

	PROTECT.data_merge_sql_pusher:add_to_sql_cache( { _player_id , _task_id } , task_data , _player_id )

	---- 数据库更新
--[[	skynet.send(DATA.service_config.data_service,"lua","update_player_task"
					,_player_id
					,_task_id
					,_process
					,_task_round
					,_create_time
					,_task_award_get_status)--]]
end

--- 删掉一个任务
function CMD.delete_player_task(_player_id , _task_id)
	local player_data = PROTECT.data_manager:get_data(_player_id)

	if player_data and player_data[_task_id] then
		player_data[_task_id] = nil

		PROTECT.data_manager:add_or_update_data(_player_id , player_data)

		----- 如果是删除就，清掉这个任务的更新缓存
		--[[if DATA.need_delay_update_task_data_vec[_player_id] and DATA.need_delay_update_task_data_vec[_player_id][_task_id] then
			DATA.need_delay_update_task_data_vec[_player_id][_task_id] = nil
		end--]]

		---- 清掉 缓存更新器中的数据
		PROTECT.data_merge_sql_pusher:delete_sql_cache( { _player_id , _task_id } )

		print("xxx-------------------------------------delete_one_task center: ", _player_id , _task_id)

		skynet.send(DATA.service_config.data_service,"lua","delete_player_task" , _player_id , _task_id )
	end
end

--- 增加任务日志
function CMD.add_player_task_log( _player_id , _task_id , _process_change , _now_progress )
	if _process_change ~= 0 then
		--skynet.send(DATA.service_config.data_service,"lua","add_player_task_log" ,_player_id , _task_id , _process_change , _now_progress )

		--PUBLIC.add_delay_merge_insert_data( _player_id , _task_id , _process_change , _now_progress )

		PROTECT.insert_log_merge_sql_pusher:add_to_sql_cache( { _player_id , _task_id } , { 
			player_id = _player_id,
			task_id = _task_id,
			progress_change = _process_change,
			now_progress = _now_progress,
		 } , _player_id )

	end
end

function CMD.add_player_task_award_log( _player_id , _task_id , _award_progress_lv , _asset_type , _asset_value )
	skynet.send(DATA.service_config.data_service,"lua","add_player_task_award_log" , _player_id , _task_id , _award_progress_lv , _asset_type , _asset_value )
end

-- 总配置
function CMD.get_main_config()

	local main_config_tem = basefunc.deepcopy(DATA.task_main_config) or {}
	
	---- main_config_tem 是不常改任务，以它的任务优先级最高

	local ret = main_config_tem
	
	----- 处理掉enable = 0 的
	for key,data in pairs(ret) do
		if data.enable == 0 then
			ret[key] = nil
		end
	end

	--dump(ret, "xxx-------------------------------------------ret")
	return ret

end

function PROTECT.on_destroy()
	PROTECT.clear_refresh_config()
end

function PROTECT.on_load()
	PROTECT.refresh_config()
end

function CMD.get_cache_data_num()
	local num = 0

	if DATA.need_delay_update_task_data_vec and type(DATA.need_delay_update_task_data_vec) == "table" then
		for k,v in pairs(DATA.need_delay_update_task_data_vec) do
			num = num + 1
		end
	end

	if DATA.need_delay_insert_task_log_vec and type(DATA.need_delay_insert_task_log_vec) == "table" then
		for k,v in pairs(DATA.need_delay_insert_task_log_vec) do
			num = num + 1
		end
	end

	return num
end



--------------------------------------------------------------------------------------------------------------------------------------------
function PUBLIC.add_delay_merge_update_data(_player_id , _task_id , _process , _task_round , _create_time , _task_award_get_status , _time_limit)
	--[[local target_vec = DATA.need_delay_update_task_data_vec


	------ 放到延迟更新的数据map中
	target_vec[_player_id] = target_vec[_player_id] or {}
	target_vec[_player_id][_task_id] = target_vec[_player_id][_task_id] or {}
	local delay_update_vec = target_vec[_player_id][_task_id]
	delay_update_vec.player_id = _player_id
	delay_update_vec.task_id = _task_id
	delay_update_vec.process = _process
	delay_update_vec.task_round = _task_round
	delay_update_vec.create_time = _create_time
	delay_update_vec.task_award_get_status = _task_award_get_status
	delay_update_vec.time_limit = _time_limit--]]

end

function PUBLIC.deal_delay_merge_update_data()
--[[
	local now_time = os.time()
	if now_time - DATA.last_merge_update_time >= DATA.merge_update_task_data_delay then
		local deal_vec = DATA.need_delay_update_task_data_vec
		DATA.need_delay_update_task_data_vec = {}

		DATA.is_dealing_delay_update_task_data = true
		DATA.last_merge_update_time = now_time

		for player_id , player_data in pairs(deal_vec) do
			local _queue_type,_queue_id = "slow",99999999

			for task_id,task_data in pairs(player_data) do
				_queue_type,_queue_id = skynet.call(DATA.service_config.data_service,"lua","update_player_task"
					,task_data.player_id
					,task_data.task_id
					,task_data.process
					,task_data.task_round
					,task_data.create_time
					,task_data.task_award_get_status
					,task_data.time_limit)
			end

			----
			PROTECT.data_manager:update_sql_queue_data(player_id , _queue_type , _queue_id )
		end

	end

	DATA.is_dealing_delay_update_task_data = false--]]
end

---------------------------------------------------------------------------------------------------------------------------
function PUBLIC.add_delay_merge_insert_data(_player_id , _task_id , _process_change , _now_process)
	--[[local target_vec = DATA.need_delay_insert_task_log_vec

	------ 放到延迟更新的数据map中
	target_vec[_player_id] = target_vec[_player_id] or {}
	target_vec[_player_id][_task_id] = target_vec[_player_id][_task_id] or {}
	local delay_insert_vec = target_vec[_player_id][_task_id]
	delay_insert_vec.player_id = _player_id
	delay_insert_vec.task_id = _task_id
	delay_insert_vec.process_change = (delay_insert_vec.process_change or 0) + _process_change
	delay_insert_vec.now_process = _now_process--]]

end

function PUBLIC.deal_delay_merge_insert_data()
	

	--[[local now_time = os.time()
	if now_time - DATA.last_merge_insert_time >= DATA.merge_insert_task_log_delay then
		local deal_vec = DATA.need_delay_insert_task_log_vec
		DATA.need_delay_insert_task_log_vec = {}

		DATA.last_merge_insert_time = now_time
		DATA.is_dealing_delay_insert_task_log = true

		for player_id , player_data in pairs(deal_vec) do
			for task_id,task_data in pairs(player_data) do
				skynet.send(DATA.service_config.data_service,"lua","add_player_task_log" 
					,task_data.player_id 
					, task_data.task_id 
					, task_data.process_change 
					, task_data.now_process )
			end
		end

	end

	DATA.is_dealing_delay_insert_task_log = false--]]
end

function PUBLIC.update()
	-- print("xxxxx---------------task_center_service___update")
	--PUBLIC.deal_delay_merge_update_data()
	--PUBLIC.deal_delay_merge_insert_data()
end

----- 增加一个任务的进度
function CMD.add_one_task_progress( task_type , player_id , task_id , add_pro )
	local task_config = CMD.get_main_config()
	--- 加进度
	local task_ob_data = CMD.query_player_task_data(player_id)
	if task_ob_data then
		task_ob_data = task_ob_data[task_id]
		local task_config = task_config[task_id]

		--[[task_ob_data = task_ob_data or {
			player_id = player_id,
			task_id = task_id,
			process = 0,
			task_round = 1,
			create_time = os.time(),
			task_award_get_status = "0",
		}--]]
		if not task_ob_data then
			task_ob_data = task_base_func.get_default_task_data()
			task_ob_data.player_id = player_id
			task_ob_data.task_id = task_id
		end


		local max_process = task_base_func.get_max_process(task_config and task_config.process_data or {} )

		if task_ob_data.process < max_process then
			task_ob_data.process = task_ob_data.process + add_pro
			if task_ob_data.process > max_process then
				task_ob_data.process = max_process

				add_pro = add_pro - (task_ob_data.process - max_process)
			end

			--- 加日志
			CMD.add_player_task_log(task_ob_data.player_id , task_ob_data.task_id , add_pro , task_ob_data.process)

			CMD.add_or_update_task_data( task_ob_data.player_id
										,task_ob_data.task_id
										,task_ob_data.process
										,task_ob_data.task_round
										,task_ob_data.create_time
										,task_ob_data.task_award_get_status 
										,task_ob_data.time_limit )


			---- 通知，进度增加
			if task_type == "normal" then
				nodefunc.send(player_id,"update_task_process", task_id , task_ob_data.process , task_ob_data.process == max_process )
			end
		end

	end
end
------------------------------------------------------------------------------------------ 各种中心处理函数 ↓ ----------------------------------------------
------------------------------------------------------------------------------------------ 各种中心处理函数 ↓ ----------------------------------------------
------------------------------------------------------------------------------------------ 各种中心处理函数 ↓ ----------------------------------------------
----- 处理任务 判断进度来源 加进度
function CMD.check_process_source_add( can_deal_source_type , _task_type , _player_id , task_id , _source_data , ... )

		----------------------------------------------- 可以处理的来源类型map ----------------------------------------------
	local can_deal_source_type_map = {}
	if can_deal_source_type and type(can_deal_source_type) == "table" then
		for key,source_type in pairs(can_deal_source_type) do
			can_deal_source_type_map[source_type] = true
		end
	end

	for key,data in pairs(_source_data) do
		repeat
			if not can_deal_source_type_map[data.source_type] then
				break
			end
		until true
	end

end
------- 处理一个任务增加 进度
function PUBLIC.deal_one_task_add_progress( _player_id , task_id , task_cfg , data , _deal_msg_vec , ... )

	local now_time = os.time()
	----- 这里的充值任务不处理bbsc的任务
	if task_cfg then

		local start_time = math.min(task_cfg.start_valid_time , task_cfg.end_valid_time)
		local end_time = math.max(task_cfg.start_valid_time , task_cfg.end_valid_time)

		--- 如果不在有效期内，则不加进度
		if now_time < start_time or now_time > end_time then
			return false
		end
		---- 超过限时任务的有效期，不加
		if data and data.time_limit then
			if now_time > data.time_limit then
				return false
			end
		end
		---- 参与条件过滤
		if not task_base_func.check_task_join_condition( _player_id , task_cfg.join_condition ) then
			return false
		end
		---------------------------------------- ↓ 权限判断 ↓ -------------------------------
		local is_can_do , error_desc = DATA.permission_manager.judge_permission_effect( "task_" .. task_id ,
																							 DATA.variant_data_manager.get_player_variant_data(_player_id) )
		if not is_can_do then
			return false
		end
		---------------------------------------- ↑ 权限判断 ↑ -------------------------------

		CMD.check_process_source_add( _deal_msg_vec , "normal" , _player_id , task_id , task_cfg.source_data , ... )

	end
end

---- 处理 新玩家登录
function CMD.deal_player_first_login(_player_id )
	
end

---- 通知一个agent 自己任务改变
function CMD.request_agent_task_change(_player_id)
	nodefunc.send(_player_id,"distribute_task" , { task_item_change_msg = true } )
end

------------------------------------------------------------------------------------------ 各种中心处理函数 ↑ ----------------------------------------------
------------------------------------------------------------------------------------------ 各种中心处理函数 ↑ ----------------------------------------------
------------------------------------------------------------------------------------------ 各种中心处理函数 ↑ ---------------------------------------------------------------------------------------------------------------------------------------- 各种中心处理函数 ↑ ----------------------------------------------


--------------------------------------------------------------------------- for test ↓ -----------------------------------------------------------

--- for test  增加一个任务的进度 ( 也可动态增加一个人的某个任务进度 )
function CMD.add_task_progress( _player_id , _task_id , _add_value)
	local player_data = PROTECT.data_manager:get_data(_player_id)

	local all_task_config = CMD.get_main_config()
	local task_config = all_task_config[_task_id]
	local max_process = task_base_func.get_max_process(task_config and task_config.process_data or {} )

	if player_data and player_data[_task_id] then
		local task_data = player_data[_task_id]
		task_data.process = task_data.process + _add_value

		--- 防止加超过
		if task_data.process > max_process then
			task_data.process = max_process

			_add_value = _add_value - (task_data.process - max_process)
		end

		--- 加日志
		CMD.add_player_task_log( _player_id , _task_id , _add_value , task_data.process)

		PROTECT.data_manager:add_or_update_data(_player_id , player_data)

		CMD.add_or_update_task_data( _player_id , _task_id , task_data.process , task_data.task_round , task_data.create_time , task_data.task_award_get_status , task_data.time_limit )
		nodefunc.send( _player_id , "add_task_progress" , _task_id , _add_value )
	end
end
--------------------------------------------------------------------------- for test ↑ -----------------------------------------------------------

--------------------------------------------- 为task_award_get_status 整形变string做处理的函数 ↓ ----------------------------------------------

---- 启服之前 ↓↓
-------- 第一步修改字段 task_award_get_status 变成varchar 

--------第二步，增加一个 task_award_get_status_tem 字段。

-------- 第二.1步，调用sql 把 task_award_get_status 的数据存入 task_award_get_status_tem 中
-- update player_task set task_award_get_status_tem = task_award_get_status;


---- 启服之后 ↓↓
-------- 第三步，调用这个函数处理 task_award_get_status 字段。
--   call task_center_service deal_change_task_award_get_status
function CMD.deal_change_task_award_get_status()
	---- 
	local _sql = [[ select player_id , task_id , task_award_get_status from player_task where task_award_get_status is not null and task_award_get_status <> 0; ]]
	local ob_data = PUBLIC.db_query(_sql )

	--dump(ob_data , "xxx--------------------ob_data:")

	local tar_sql = {}
	local total_deal_num = 0
	local deal_num = 0
	for key,data in ipairs(ob_data) do
		local num = tonumber( data.task_award_get_status )
		local str_vec = basefunc.decode_task_award_status(num)
		local status_str = basefunc.encode_task_award_status(str_vec , "string" , true )

		tar_sql[#tar_sql + 1] = PUBLIC.format_sql([[ update player_task set task_award_get_status = %s where player_id = %s and task_id = %s ]] , status_str , data.player_id , data.task_id )

		total_deal_num = total_deal_num + 1
		deal_num = deal_num + 1

		if deal_num > 2000 then
			PUBLIC.db_query( table.concat( tar_sql , ";" ) )

			tar_sql = {}
			deal_num = 0
		end

	end

	if #tar_sql > 0 then
		PUBLIC.db_query( table.concat( tar_sql , ";" ) )
	end

	--print ("xxx----------------deal_change_task_award_get_status over !!" , total_deal_num)
end
---------- 第四步，检查一下
---- 看一下大概的对不对
-- select * from player_task where task_award_get_status is not null and task_award_get_status <> '0'
---- 搜一下还有没有没转换的
--- select * from player_task where task_award_get_status = task_award_get_status_tem and task_award_get_status <> 0 and task_award_get_status <> 1;

---------- 第五步，删掉task_award_get_status_tem字段。

---------- 第六步，再次重启游戏服务器

--------------------------------------------- 为task_award_get_status 整形变string做处理的函数 ↑ ----------------------------------------------


function PUBLIC.init()
	---- 
	PROTECT.data_merge_sql_pusher = PROTECT.data_merge_sql_pusher or basefunc.server_class.common_merge_push_sql_lib.new( 60,PROTECT.data_manager , {
		tab_name = "player_task",
		queue_type = "slow",
		push_type = "update",
		field_data = {
			player_id = {
				is_primary = true,
				value_type = "equal",
			},
			task_id = {
				is_primary = true,
				value_type = "equal",
			},
			process = {
				value_type = "equal",
			},
			task_round = {
				value_type = "equal",
			},
			create_time = {
				value_type = "equal",
			},
			task_award_get_status = {
				value_type = "equal",
			},
			time_limit = {
				value_type = "equal",
			},
		},
	} )
	-------------
	PROTECT.insert_log_merge_sql_pusher = PROTECT.insert_log_merge_sql_pusher or basefunc.server_class.common_merge_push_sql_lib.new( 60, nil , {
		tab_name = "player_task_log",
		queue_type = "slow",
		push_type = "insert",
		field_data = {
			player_id = {
				is_primary = true,
				value_type = "equal",
			},
			task_id = {
				value_type = "equal",
			},
			progress_change = {
				value_type = "num_add",
			},
			now_progress = {
				value_type = "equal",
			},
		},
	} )

	skynet.timer( DATA.update_dt , PUBLIC.update )

	DATA.permission_manager.init(false)
 	DATA.variant_data_manager.init( DATA.msg_tag )

	--- 监听 新玩家登录
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", 
		"add_msg_listener" , "player_first_login"
		,{
			msg_tag = DATA.msg_tag,
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "deal_player_first_login"
		}
		)

end


return PROTECT
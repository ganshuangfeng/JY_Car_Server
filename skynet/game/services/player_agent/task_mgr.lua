--
-- Created by lyx.
-- User: hare
-- Date: 2018/11/6
-- Time: 14:59
-- 任务进程管理器
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local task_initer = require "task.init"
local task_base_func = require "task.task_base_func"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST = base.REQUEST
local PUBLIC = base.PUBLIC

---- 任务的重置时间
DATA.REST_TIME = 6

local is_send = false


---奖励状态
DATA.award_status = {
	not_can_get = 0,
	can_get = 1,
	complete = 2,
	not_open = 3,     --- 未开启
}

DATA.task_mgr_protect = {}
local PROTECT = DATA.task_mgr_protect

PROTECT.is_load_ob_task = false

PROTECT.distribute_task_type_enum =  {
	refresh_config = true,        --- 是否对已有的任务刷新了配置
	task_item_change_msg = true,     --- 是否向客户端发送任务个数改变的消息
}

--PROTECT.distribute_task_type = PROTECT.distribute_task_type_enum
---- 下面这种，避免初始化时，所有的任务的init调用两次
PROTECT.distribute_task_type =  {
	--refresh_config = true,        --- 是否对已有的任务刷新了配置
	task_item_change_msg = true,     --- 是否向客户端发送任务个数改变的消息
}


--- 当前拥有的任务列表，-- key 值是任务id,value 是任务obj
DATA.task_list = {}

---- 增加一个任务
function PUBLIC.add_one_task(task_id,data , task_list)
	print("add_one_task:",task_id,data)
	local task_config = PUBLIC.get_all_task_config() --skynet.call(DATA.service_config.task_center_service,"lua","get_main_config")
	local config = task_config[task_id]
	--- 没得 相应的任务配置，不能创建任务
	if not config or not data then
		--error("not task config!")
		print("error_-------------not task config! ",task_id)
		return nil , true
	end

	--- 如果已经有了这个任务id的数据，不可添加
	if task_list and task_list[task_id] then
		return nil , false
	elseif not task_list and DATA.task_list[task_id] then
		return nil , false
	end

	local task_obj = task_initer.gen_task_obj(config,data)

	if task_obj then
		print("add_one_task:task_obj",task_obj)

		if task_list then
			task_list[task_id] = task_obj
		else
			DATA.task_list[task_id] = task_obj
		end
		---- 这个放在 赋值之后，避免，init中调用删除，无法删除。
		task_obj.init()
	end

	if is_send and task_obj then
		PUBLIC.deal_task_progress_change(task_obj)

	end

	return task_obj , false
end



local function load_ob_data()
	local history_task = skynet.call(DATA.service_config.task_center_service,"lua","query_player_task_data",DATA.my_id)
	--dump(history_task , "--------------------  history_task")
	local index = 0
	if history_task and type(history_task) == "table" then
		for task_id,d in pairs(history_task) do
			if not DATA.task_list[task_id] then

				local task_obj , is_delete_ob = PUBLIC.add_one_task(task_id,d)
				--- 如果没有创建 历史 任务对象，删除
			    if is_delete_ob then
			        skynet.send(DATA.service_config.task_center_service,"lua","delete_player_task",DATA.my_id,task_id)
			    end

			    index = index + 1
			    --- test
			    --[[if index == 10 then
			    	CMD.distribute_task()
			    end--]]

			end
		end
	end

	-- !!! 前面的代码不可return . 这个一定在最后赋值，不然会有大bug
	PROTECT.is_load_ob_task = true
end


---- 删掉一个任务
function PUBLIC.delete_one_task( task_id , is_care_cfg )

	if task_id and DATA.task_list and DATA.task_list[task_id] then
		local task_config = PUBLIC.get_all_task_config() --skynet.call(DATA.service_config.task_center_service,"lua","get_main_config")
		local config = task_config[task_id]

		---- 只有enable == 0 的时候才可以删数据
		local is_delete_ob = false
		if is_care_cfg and config then
			if config.enable == 0 then
				is_delete_ob = true
			end
		else
			--- 没有配置项也要删。
			is_delete_ob = true
		end
		if is_delete_ob then
			skynet.send(DATA.service_config.task_center_service,"lua","delete_player_task",DATA.my_id,task_id)
		end

		DATA.task_list[task_id].destroy()
		DATA.task_list[task_id] = nil
		print("xxx-------------------------------------delete_one_task : ", DATA.my_id , task_id)
	end
end

----- 给外部调用的删除任务列表
function CMD.delete_tasks(task_id_vec)
	for key,task_id in ipairs(task_id_vec) do
		PUBLIC.delete_one_task( task_id )
	end
end

----- 给外部调用的更新一个任务的进度
function CMD.update_task_process(task_id , now_process , is_max_progress)
	if DATA.task_list[task_id] then
		DATA.task_list[task_id].update_process(now_process)
		PUBLIC.task_process_change( task_id )
	end
end

---- 增加一个任务的进度
function CMD.add_task_progress(task_id , add_value)
	if DATA.task_list[task_id] then
		DATA.task_list[task_id].add_process(add_value)
	end
end

------ 获取所有的任务配置
function PUBLIC.get_all_task_config()
	if not PROTECT.all_task_config or PROTECT.is_task_config_change then
		PROTECT.all_task_config = skynet.call(DATA.service_config.task_center_service,"lua","get_main_config")
		PROTECT.is_task_config_change = false
	end

	return PROTECT.all_task_config
end

---- 获取所有的任务的配置list
function PUBLIC.get_all_task_config_list()
	local all_task_config = PUBLIC.get_all_task_config()

	local task_config_list = {}

	for task_id , data in pairs(all_task_config) do
		task_config_list[#task_config_list + 1] = data
	end

	table.sort( task_config_list , function(a,b) return a.id < b.id end)

	return task_config_list
end

---- 任务配置改变消息处理
function CMD.on_task_config_change_and_distribute_task()
	PROTECT.is_task_config_change = true

	CMD.distribute_task()   ---- 这里不传，则要刷新 各个任务自己的配置，和发送任务个数改变消息
end

function CMD.distribute_task( distribute_task_type )
	--- 加一个操作锁,避免多次同时调用这个重刷函数
	--- 操作限制
	if PUBLIC.get_action_lock("cmd_distribute_task") then
		return 1008
	end
	PUBLIC.on_action_lock( "cmd_distribute_task" )

	--- 没有传参数，操作都要做
	if not distribute_task_type then
		PROTECT.distribute_task_type = PROTECT.distribute_task_type_enum
	else
		PROTECT.distribute_task_type = distribute_task_type
	end

	is_send = true
	PROTECT.distribute_task()
	is_send = false

	PUBLIC.off_action_lock( "cmd_distribute_task" )
end


------ 更新一个任务的其他数据
function PUBLIC.update_task_other_data(task_id , data)
	if DATA.task_list[task_id] then
		DATA.task_list[task_id].other_data = data
	end

	local ser_data = data and basefunc.safe_serialize(data) or nil

	if ser_data then
		skynet.send(DATA.service_config.task_center_service,"lua","update_player_task_other_data",DATA.my_id,task_id , ser_data)
	end
end


---派发任务；根据玩家的自身条件返回一个任务id列表
--[[
	玩家刚进入，执行一次，需要有任务增删的地方执行一次

--]]
function PROTECT.distribute_task()
	if not PROTECT.is_load_ob_task then
		print("xxxxx-----------------distribute_task___not PROTECT.is_load_ob_task" , DATA.my_id)
		return
	end

	print("xxxxx-----------------distribute_task:" , DATA.my_id)
	local task_config = PUBLIC.get_all_task_config_list() --skynet.call(DATA.service_config.task_center_service,"lua","get_main_config")
	local task_switch = skynet.call(DATA.service_config.task_center_service,"lua","query_player_task_switch_data", DATA.my_id)


	local own_task_table = {}
	local now_time = os.time()
	--dump(task_config , "-----------------distribute_task----task_config")
	for id,task_data in ipairs(task_config) do
		local task_id = task_data.id
		repeat
			--print("xxxxxxx----------------distribute_task___",task_id)
			--- 不启用(-1表示不载入&不清理数据)
			if task_data.enable == 0 or task_data.enable == -1 then
				break
			end

			----处理是否拥有任务
			PUBLIC.deal_is_own_task(task_id , task_data, own_task_table)


			---- 任务开关;开关可以强行控制某个任务的开关
			if task_switch and task_switch[task_id] and task_switch[task_id].is_enable then
				if task_switch[task_id].is_enable == 1 then
					own_task_table[task_id] = true
				elseif task_switch[task_id].is_enable == 0 then
					own_task_table[task_id] = nil
				end
			end

			----------------- 如果是权限挂载任务 -------------------
			if DATA.variant_data_agent_protect and DATA.variant_data_agent_protect and DATA.variant_data_agent_protect.variant_data then
				local act_permission = DATA.variant_data_agent_protect.variant_data.act_permission  --DATA.variant_data_agent_protect.get_player_act_permisssion()

				----- 权限挂载任务有两套 : actp_own_task_ + task_id ; actp_own_task_ + own_type
				local is_condition = false
				if act_permission and act_permission[ "actp_own_task_"..task_id ] and act_permission[ "actp_own_task_"..task_id ].is_work == 1 then
					is_condition = true
				end
				---- 这里用的 task_data.own_type 最好有一个统一的前缀，p_xxx , p_ 表示权限的意思
				if act_permission and act_permission[ "actp_own_task_"..task_data.own_type ] and act_permission[ "actp_own_task_"..task_data.own_type ].is_work == 1 then
					is_condition = true
				end


				if is_condition then
					----PS 没有配，是不能玩的

					own_task_table[task_id] = true

					---- 打开 任务 开关 ，关掉权限开关，打开权限锁定。(相当于最终还是 以 任务开关来控制)
					end
			end
		until true
	end
	--dump(own_task_table , "-----------------distribute_task----own_task_table")
	PROTECT.add_or_delete_task( own_task_table )
end


function PROTECT.add_or_delete_task( own_task_table )
	-- dump(own_task_table , "----->>>>>add_or_delete_task1")
	-- dump(DATA.task_list , "----->>>>>add_or_delete_task2 , DATA.task_list")
	local task_change_vec = {}

	local task_table_temp = basefunc.deepcopy(own_task_table)
	local task_config = PUBLIC.get_all_task_config() --skynet.call(DATA.service_config.task_center_service,"lua","get_main_config")

	for task_id,data in pairs(DATA.task_list) do
		local isFind = false
		for own_task_id,data in pairs(task_table_temp) do
			if task_id == own_task_id then
				isFind = true
				task_table_temp[own_task_id] = nil

				--- 如果找到了，更新一下
				if PROTECT.distribute_task_type and PROTECT.distribute_task_type.refresh_config then
					DATA.task_list[task_id].refresh_config( task_config[task_id] )
				end

				break
			end
		end

		--- 没找到做移除
		if not isFind then
			----------先判断一下是不是 别人的子任务
			--local is_need_delete = true
			local is_children_task = PUBLIC.get_one_task_is_other_data_children_task(task_id)
			--- 如果不是别人的子任务，就可以删掉
			if not is_children_task then
				task_change_vec[#task_change_vec + 1] = { task_id = task_id , task_type = data.config and data.config.own_type or nil , change_type = "delete" }

				PUBLIC.delete_one_task( task_id , true)
			end
		end
	end

	-- dump(task_table_temp , "----->>>>>add_or_delete_task , task_table_temp")

	--------- 如果还有 应该要创建的任务，
	if task_table_temp and next(task_table_temp) then

		local ob_task_data = skynet.call( DATA.service_config.task_center_service , "lua" , "query_player_task_data" , DATA.my_id )
		--- 做新增
		for new_task_id,_ in pairs(task_table_temp) do
			local ob_data = ob_task_data and ob_task_data[new_task_id]
			local data = ob_data or task_base_func.get_default_task_data()

			local task_obj = PUBLIC.add_one_task(new_task_id,data)

			if task_obj then
				if DATA.task_list[new_task_id] then
					local task_data = DATA.task_list[new_task_id]
					task_change_vec[#task_change_vec + 1] = { task_id = new_task_id , task_type = task_data.config and task_data.config.own_type or nil , change_type = "add" }
				end

				--PUBLIC.update_task(new_task_id,task_obj.process,task_obj.task_round,task_obj.create_time , task_obj.task_award_get_status , task_obj.time_limit )
				task_obj.update_data(true)

			end

		end
	end

	------ 发送任务改变
	if is_send and task_change_vec and type(task_change_vec) == "table" and next(task_change_vec) then
		if PROTECT.distribute_task_type and PROTECT.distribute_task_type.task_item_change_msg then
			PUBLIC.request_client("task_item_change_msg",
									{ task_item = task_change_vec  })
		end
	end

	-- dump(DATA.task_list , "----->>>>>add_or_delete_task3 , DATA.task_list")
end

function PROTECT.deal_task_cache_add_process()

	local function deal_cache( _task_list )
		if _task_list and type(_task_list) == "table" then
			for task_id , task_obj in pairs(_task_list) do
				local tem_cache_data = task_obj.msg_process_cache
				task_obj.msg_process_cache = {}

				if tem_cache_data and type(tem_cache_data) == "table" then
					for _cache_key , _add_process in pairs( tem_cache_data ) do
						task_obj.add_process( _add_process )
					end
				end
			end
		end
	end
	-----
	deal_cache( DATA.task_list )
	-----
end

function PROTECT.init()
	print("------------ task mgr init -----------------------")

	--###test

	--从数据库获取任务进度，初始化任务对象列表
	load_ob_data()

	--PROTECT.distribute_task()
	---- 这个因为调 PROTECT.distribute_task 用的是 PROTECT.distribute_task_type 而这个默认是 只做任务个数改变消息
	CMD.distribute_task( { task_item_change_msg = true } )


	--- 触发一下，资产观察,方便登录领取任务奖励
	skynet.timeout(200 , function()
		PUBLIC.asset_observe()
	end)

	---- 开一个timer , 处理缓存加任务进度
	skynet.timer(0.5 , function()
		PROTECT.deal_task_cache_add_process()
	end)


end


---- 更新一个任务
function PUBLIC.update_task(_task_id,_process,_task_round,_create_time , _task_award_get_status , _time_limit)

	skynet.send(DATA.service_config.task_center_service,"lua","add_or_update_task_data"
					,DATA.my_id
					,_task_id
					,_process
					,_task_round
					,_create_time
					,_task_award_get_status
					,_time_limit )
end

---- 增加日志
function PUBLIC.add_player_task_log(_task_id,_process_change,_now_progress)
	skynet.send(DATA.service_config.task_center_service,"lua","add_player_task_log"
					,DATA.my_id
					,_task_id
					,_process_change
					,_now_progress)

end

---
function PUBLIC.add_player_task_award_log(_task_id ,_award_progress_lv,_asset_type , _asset_value)
	--print("xxxxxxxx---------add_player_task_award_log:",_task_id ,_award_progress_lv,_asset_type , _asset_value)
	skynet.send(DATA.service_config.task_center_service,"lua","add_player_task_award_log"
					,DATA.my_id
					,_task_id
					,_award_progress_lv
					,_asset_type
					,_asset_value )

end

---- 通知客户端一个任务进度改变
function PUBLIC.task_process_change( task_id )
	if DATA.task_list[task_id] then
		PUBLIC.request_client("task_change_msg",
								{ task_item = task_base_func.get_one_task_data( DATA.task_list[task_id] , {} ) })
	end
end

---- 获得奖励数据之后的处理
function PUBLIC.get_award_extra_deal_after(task_data , award_data)
	local target_result = 0
	local more_common_asset = {}

	---- 这个时候的task_obj可能已经被删除了 ！！
	--local task_obj = DATA.task_list[task_id]
	if task_data and award_data and type(award_data) == "table" then
		for key,data in pairs(award_data) do
			more_common_asset[#more_common_asset + 1] = basefunc.deepcopy( data )
		end
	end

	return target_result , more_common_asset
end

function PUBLIC.get_task_award(task_id , award_progress_lv)
	local task_obj = DATA.task_list[task_id]
	if not task_obj then
		return 1004 , {}
	end
	local task_data = { task_id = task_id , name = task_obj.config.name , own_type = task_obj.config.own_type  , task_enum = task_obj.config.task_enum }

	local task_award = nil
	if task_obj then
		task_award = task_obj.get_award(award_progress_lv)
	end

	---- 如果是错误码，直接先返回咯
	local result_code = 0
	if type(task_award) == "number" then
		result_code = task_award
		return result_code , {}
	end

	local extra_deal_code_after, more_common_asset = PUBLIC.get_award_extra_deal_after(task_data , task_award)

	result_code = extra_deal_code_after

	if type(more_common_asset) == "table" and next(more_common_asset)  then
		local change_type = PUBLIC.get_task_award_change_type(task_obj)
		--print("xxxx-----------------")

		local award_tem = basefunc.deepcopy(more_common_asset)
		----- 如果没有asset_type 那么不要传过去
		--[[for k,data in pairs(award_tem) do
			if not data.asset_type then
				table.remove( award_tem , k )
			end
		end--]]
		local award_len = #award_tem
		for i = award_len , 1 , -1 do
			local data = award_tem[i]
			if not data.asset_type then
				table.remove( award_tem , i )
			end
		end

		CMD.change_asset_multi(award_tem, change_type ,task_id)
	end


	return result_code , type(task_award) == "table" and task_award or {}
end


function REQUEST.get_task_award(self)
	-- dump(self , "---------- get_task_award")
	if not self or not self.id or type(self.id)~="number" then
		return {
			result = 1001,
		}
	end

	if PUBLIC.get_action_lock("get_task_award" ) then
		return {
			result = 1008,
		}
	end
	PUBLIC.on_action_lock("get_task_award" )

	local result_code , task_award = PUBLIC.get_task_award(self.id)

	local award_data = {}
	if task_award and type(task_award) == "table" then
		for key , data in pairs(task_award) do
			award_data[#award_data + 1] = { asset_type = data.asset_type , asset_value = data.value , award_name = data.award_name }
		end
	end

	PUBLIC.off_action_lock("get_task_award")
	return {
		result = result_code,
		id = self.id,
		award_list = award_data,
	}
end

---------------------------------------------------------------------------------------------- 新版获取任务奖励
function REQUEST.get_task_award_new(self)
	-- dump(self , "---------- get_task_award")
	if not self or not self.id or type(self.id)~="number" or not self.award_progress_lv or type(self.award_progress_lv)~="number" or self.award_progress_lv <= 0 then
		return {
			result = 1001,
		}
	end

	---- 这个一定是 get_task_award ，防止刷
	if PUBLIC.get_action_lock("get_task_award" ) then
		return {
			result = 1008,
		}
	end
	PUBLIC.on_action_lock("get_task_award" )

	local result_code , task_award = PUBLIC.get_task_award(self.id , self.award_progress_lv)
	--dump(task_award , "xxxx---------get_task_award_new:"..self.id .. "_" .. self.award_progress_lv )
	local award_data = {}
	if task_award and type(task_award) == "table" then
		for key , data in pairs(task_award) do
			award_data[#award_data + 1] = { asset_type = data.asset_type , asset_value = data.value , award_name = data.award_name }
		end
	end
	--dump(award_data , "xxxx---------get_task_award_new22:"..self.id .. "_" .. self.award_progress_lv )
	PUBLIC.off_action_lock("get_task_award")
	return {
		result = result_code,
		id = self.id,
		award_list = award_data,
	}

end


PROTECT.can_query_base_task_own_types = {
	"normal",
}

--- 请求所有任务数据
function REQUEST.query_task_data()
	local ret = {}

	for task_id ,task_obj in pairs(DATA.task_list) do
		local is_get = false

		for key,own_type in pairs( PROTECT.can_query_base_task_own_types ) do
			if task_obj.config.own_type == own_type then
				is_get = true
				break
			end
		end

		if is_get then
			local last_index = #ret + 1
			ret[last_index] = {}
			task_base_func.get_one_task_data(task_obj , ret[last_index])
		end
	end


	local page_num = 30
	for i = 1, math.ceil( #ret / page_num ) do
		local start_index = (i - 1) * page_num + 1

		local target_ret = {}

		for k = 0,page_num-1 do
			if ret[ start_index + k] then
				target_ret[#target_ret + 1] = ret[ start_index + k]
			end
		end

		if next(target_ret) then
			PUBLIC.request_client( "task_data_init_msg" , {task_item = target_ret} )
		end
	end



	return {
		result = 0,
		--task_list = ret,
	}

end

--- 请求所有任务数据
function REQUEST.query_one_task_data(self)
	if not self or not self.task_id then
		return { result = 1001 }
	end

	local _task_data = nil

	for task_id ,task_obj in pairs(DATA.task_list) do
		if task_id == self.task_id then
			_task_data = {}

			task_base_func.get_one_task_data(task_obj , _task_data)

			break
		end
	end

	return {
		result = 0,
		task_data = _task_data,
	}

end


return PROTECT
--
-- Author: yy
-- Date: 2018/11/7
-- Time: 15:11
-- 说明：require task floder

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST = base.REQUEST
local PUBLIC = base.PUBLIC

DATA.task_initer_protect = {}
local task_initer = DATA.task_initer_protect

task_initer.player_first_login_time = {}
task_initer.valid_day_num = 7

local common_task = require "task.common_task"

function task_initer.gen_task_obj(config,data)
	if  config.task_enum == TASK_TYPE_ENUM.common_task then
		return common_task.gen_task_obj( config,data )
	else
		----- 走默认的,用task_enum作为文件名，来加载
		local module_name = "task." .. config.task_enum
		local ok,task_protect = pcall( require , module_name)
		if ok and task_protect and task_protect.gen_task_obj then
			return task_protect.gen_task_obj(config,data)
		end
	end

	return nil
end


------------------------------------------------ 一些任务所使用的公共函数 --------------------------------------------
---- 处理重置机制
function PUBLIC.deal_reset_process(obj , pre_callback , callback)

	obj.reset_task(pre_callback , callback)


end

---- 处理自动领奖
function PUBLIC.deal_task_auto_get_award_rights(task_obj)

end



---- 处理任务进度改变
function PUBLIC.deal_task_progress_change(task_obj)
	PUBLIC.task_process_change( task_obj.id )
end

---- 处理任务领取
function PUBLIC.deal_get_task_award(task_obj , goldpig_cash_num , award_data)
	------------------------------------------------- 合并有资产类型的奖励并发出
	if award_data and next(award_data) then
		local tem_award_vec = {}
		for _,data in pairs(award_data) do
			if data.asset_type then
				--- 按资产类型累加
				if tem_award_vec[data.asset_type] then
					--- 如果有就只加value
					tem_award_vec[data.asset_type].value = (tem_award_vec[data.asset_type].value or 0) + (data.value or 0)
				else
					---- 如果没有，就用这个数据，结构保持一致
					tem_award_vec[data.asset_type] = basefunc.deepcopy( data )
				end
			end
		end
		PUBLIC.trigger_msg( {name = "task_award_receive" } , task_obj.own_type , task_obj.id, tem_award_vec )
	end
	--------------------------------------------------

	---- 任务完成发出一个消息出去
	if task_obj.process == task_obj.max_process and task_obj.task_round > task_obj.max_task_round then
		---- 有可能还有要操作这个数据，先加个延迟
		skynet.timeout(50 , function()
			PUBLIC.trigger_msg( {name = "task_complete"} , task_obj.id, award_data )
		end)
	end
end

---- 检查是否需要写log
function PUBLIC.check_is_need_write_log(_task_id)
	--- 不用写日志的任务id
	local no_log_tasks = { }
	local is_need_write = true

	for key,task_id in pairs(no_log_tasks) do
		if task_id == _task_id then
			is_need_write = false
			break
		end
	end

	return is_need_write
end

---- 检查是否需要写奖励log
function PUBLIC.check_is_need_write_task_award_log( _task_obj )
	local is_need_write = true

	---- 不写奖励日志的任务id
	local no_award_log_task_id = {}
	---- 不写奖励日志的 own_type
	local no_award_log_task_own_type = {}

	if _task_obj then
		for k,_task_id in pairs(no_award_log_task_id) do
			if _task_obj.id == _task_id then
				is_need_write = false
				break
			end
		end

		if is_need_write then
			for k,_own_type in pairs(no_award_log_task_own_type) do
				if _task_obj.config and _task_obj.config.own_type == _own_type then
					is_need_write = false
					break
				end
			end
		end
	end

	return is_need_write
end

---- 获得一个任务id 是否是别的任务的子任务 , 是子任务返true 不是 返false
function PUBLIC.get_one_task_is_other_data_children_task(_task_id)
	local is_children_task = false

	--- 遍历所有的任务，
	if DATA.task_list and type(DATA.task_list) == "table" then
		for task_id,data in pairs(DATA.task_list) do
			local is_break = false
			if data.children_task_ids and type(data.children_task_ids) == "table" then
				for _key,c_task_id in pairs(data.children_task_ids) do
					if c_task_id == _task_id then

						is_children_task = true
						is_break = true
						break
					end
				end
			end
			local _type = type(data.other_data and data.other_data.children_task_id or nil)
			--print("xxxx----------------------data.other_data.children_task_id:" ,_task_id, is_children_task and "true" or "false" , _type , data.other_data and data.other_data.children_task_id or "nil")
			---- 单独的子任务
			if not is_children_task then

				if data.other_data and data.other_data.children_task_id and data.other_data.children_task_id == _task_id then
					--print("xxx----------------is_childre_task:" , _task_id)
					is_children_task = true
					is_break = true
				end
			end

			if is_break then
				break
			end
		end
	end
	return is_children_task
end

function PUBLIC.get_task_award_change_type(task_obj)
	local change_type = ASSET_CHANGE_TYPE.TASK_AWARD

	if not task_obj then
		return change_type
	end

	------------------------------------------- 通用处理
	--- 不是normal型的
	if task_obj.config and task_obj.config.own_type ~= "normal" then
		change_type = "task_" .. task_obj.config.own_type
	end

	return change_type
end

--- 处理是否拥有任务
function PUBLIC.deal_is_own_task(task_id , task_data, own_task_table)
	local now_time = os.time()

	if task_data.own_type == "normal" then
		own_task_table[task_id] = true
	end

	--dump(own_task_table , "xxx-----------------------------own_task_table:")

end

function PUBLIC.deal_msg(obj)

	if obj.config and obj.config.source_data and type(obj.config.source_data) == "table" then
		for key,data in pairs(obj.config.source_data) do
			--- 默认的处理、
			local deal_func_name = data.source_type .. "_deal"
			if obj[ deal_func_name ] and type(obj[ deal_func_name ]) == "function" then
				obj[ deal_func_name ]( data.condition_data , data.process_discount )
			end
		end
	end

end


return task_initer
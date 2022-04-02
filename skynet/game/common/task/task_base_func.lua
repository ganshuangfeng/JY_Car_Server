--
-- Author: wss
-- Date: 2019/4/29
-- Time: 15:11
-- 说明：任务  可能需要的一些通用函数

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST = base.REQUEST
local PUBLIC = base.PUBLIC

local loadstring = rawget(_G, "loadstring") or load

DATA.task_base_func_protect = {}
local task_base_func = DATA.task_base_func_protect

---- 任务的最大的有效期的时间
task_base_func.task_max_time_limit = 32503651200

task_base_func.player_first_login_time = {}
task_base_func.valid_day_num = 7

----- 获取一个任务的数据
function task_base_func.get_one_task_data(task_obj , target_value)
	target_value.id = task_obj.id
	target_value.now_total_process = tostring( task_obj.process )
	target_value.now_lv = task_obj.lv
	target_value.now_process = tostring( task_obj.get_now_process() )
	target_value.need_process = tostring( task_obj.get_need_process() )
	target_value.task_round = task_obj.task_round 
	target_value.award_status = task_obj.get_award_status()
	target_value.award_get_status = task_obj.task_award_get_status or "0"
	target_value.task_type = task_obj.config and task_obj.config.own_type or nil

	target_value.task_condition_type = task_obj.config and task_obj.config.condition_type or nil

	target_value.create_time = tostring(task_obj.create_time)
	target_value.over_time = tostring( task_obj.time_limit )

	target_value.start_valid_time = tostring( task_obj.config and task_obj.config.start_valid_time or nil )
	target_value.end_valid_time = tostring( task_obj.config and task_obj.config.end_valid_time or nil )

	if task_obj.other_data and task_obj.other_data.fix_award_data and type(task_obj.other_data.fix_award_data) == "table" and next(task_obj.other_data.fix_award_data) then
		for key,data in pairs(task_obj.other_data.fix_award_data) do
			target_value.fix_award_data = target_value.fix_award_data or {}
			target_value.fix_award_data[key] = target_value.fix_award_data[key] or {}
			local target_vec = target_value.fix_award_data[key]
			target_vec.award_data = target_vec.award_data or {}

			for _,award_data in pairs(data) do
				target_vec.award_data[ #target_vec.award_data + 1 ] = { asset_type = award_data.asset_type , asset_value = award_data.value }
			end
			
		end
	end

	if task_obj.get_other_data_str then
		target_value.other_data_str = task_obj.get_other_data_str()
	end

	

	return target_value
end

---- 获得一个默认的任务的初始数据
function task_base_func.get_default_task_data()
	return {
				process = 0,
				task_round = 1,
				create_time = os.time(),
				task_award_get_status = "0",
			}
end

---- 获得任务的 重置信息
function task_base_func.get_is_reset_task_data(task_obj)

	local is_need_reset = false
	local next_refresh_time = nil
	----------------------------
	local now_time = os.time()
	--- 任务开始的时间
	local start_valid_time = task_obj.config and task_obj.config.start_valid_time or 0
	--- 每隔多少天重置
	local reset_delay = task_obj.config and task_obj.config.reset_delay or 1

	--- 当前时间距离开始时间的时间
	local dif_time = now_time - start_valid_time
	--- 距离开始时间已经过了多少天
	local dif_day = math.floor( dif_time / 86400 )
	--- 到下一个刷新点还需要的时间
	next_refresh_time = (reset_delay - (dif_day % reset_delay))*86400 - dif_time % 86400

	-------------
	local create_dif_time = task_obj.create_time - start_valid_time
	local create_dif_day = math.floor( create_dif_time / 86400 )

	
	if math.floor(dif_day / reset_delay) ~= math.floor(create_dif_day / reset_delay) then
		is_need_reset = true
	end

	return is_need_reset , next_refresh_time

end

--- 获得最大的进程值
function task_base_func.get_max_process(process_data)
	local max_process = 0
	local max_task_round = 0   --- 最大的领取等级
	if process_data and type(process_data) == "table" then
		for key,process_value in pairs(process_data) do
			if process_value ~= -1 then
				max_process = max_process + process_value
				max_task_round = max_task_round + 1
			else
				max_process = 99999999999
				max_task_round = 99999999
				break
			end
		end
	end
	return max_process , max_task_round
end

--- 获得达到一个等级所需的总共进度
function task_base_func.get_grade_total_process(process_data,grade)
	local total_process = 0
	
	if not process_data or not grade or type(process_data) ~= "table" or type(grade) ~= "number" then
		return total_process
	end

	
	local index = 0
	local process_index = 1
	while true do
		index = index + 1
		if index >= grade then
			break
		end

		local lv_process = process_data[process_index]
		if not lv_process then
			break
		elseif lv_process == -1 then
			process_index = process_index - 1
			lv_process = process_data[process_index]
		end

		process_index = process_index + 1

		total_process = total_process + lv_process

	end

	return total_process
end

function task_base_func.parse_activity_data(_data)
	if not _data then
		return nil
	end

	local code = "return " .. _data
	local ok, ret = xpcall(function ()
		local data = loadstring(code)()
		if type(data) ~= 'table' then
			data = {}
			print("parse_activity_data error : {}")
		end
		return data
	end
	,function (err)
		print("parse_activity_data error : ".._data)
		print(err)
	end)

	if not ok then
		ret = {}
	end

	return ret or {},ok
end


---------------------------------------------------------------------------↓ 检查参与条件的处理函数 ↓---------------------------------------------------------
----- 检查参与条件
function task_base_func.check_task_join_condition( _player_id , _join_condition_data )
	local flag = true

	--dump(_join_condition_data , "xxxx------------------------_join_condition_data")

	if not _join_condition_data then
		return flag
	end

	for cond_name , cond_data in pairs(_join_condition_data) do
		if cond_name == "is_new_player" then
			flag = task_base_func.check_join_cond_is_new_player( _player_id , cond_data )
		end

		if not flag then
			return false
		end
	end
	
	return flag
end


--------- 检查是否是新玩家
function task_base_func.check_join_cond_is_new_player(_player_id, _condition_data )
	local now_time = os.time()
	local first_login_time=nil

	if not task_base_func.player_first_login_time[_player_id] then
		first_login_time = skynet.call( DATA.service_config.data_service , "lua" , "get_first_login_time" , _player_id )
		task_base_func.player_first_login_time[_player_id] = first_login_time or now_time
	end

	--检查当前玩家是否为新玩家
	local is_new_player = false
	if now_time - task_base_func.player_first_login_time[_player_id] < 86400 * task_base_func.valid_day_num then
		is_new_player = true
	end
	return basefunc.compare_value( is_new_player and 1 or 0 , _condition_data.condition_value , _condition_data.judge_type )

end

---------------------------------------------------------------------------↑ 检查参与条件的处理函数 ↑---------------------------------------------------------

------------ 缓存 合并进度，增加
function task_base_func.msg_process_cache_add(obj , _cache_key , _add_process )
	---- 消息的进度缓存表。
	obj.msg_process_cache = obj.msg_process_cache or {}
	obj.msg_process_cache[_cache_key] = (obj.msg_process_cache[_cache_key] or 0) + _add_process
	--obj.msg_process_cache[_cache_key] = obj.msg_process_cache[_cache_key] or {}
	--local precess_cache = obj.msg_process_cache[_cache_key]

	--[[local now_time = skynet.now()
	--- 缓存值，相加
	precess_cache.num = (precess_cache.num or 0) + _add_process
	--- 时间，
	precess_cache.time = precess_cache.time or 0

	local delay_time = 50

	--- 如果当前时间距离上次缓存时间，大于了，0.5 秒
	if now_time - precess_cache.time > delay_time then
		if precess_cache.timeout_cancel and type(precess_cache.timeout_cancel) == "function" then
			precess_cache.timeout_cancel()
			precess_cache.timeout_cancel = nil
		end

		precess_cache.time = now_time
		local add_num = precess_cache.num
		precess_cache.num = 0

		--print("xxx-----------------msg_process_cache_add:",_cache_key,add_num)
		obj.add_process( add_num )
		
	else

		if precess_cache.timeout_cancel and type(precess_cache.timeout_cancel) == "function" then
			precess_cache.timeout_cancel()
			precess_cache.timeout_cancel = nil
		end

		precess_cache.timeout_cancel = nodefunc.cancelable_timeout( delay_time - (now_time - precess_cache.time) , function() 
			precess_cache.timeout_cancel = nil

			local add_num = precess_cache.num
			precess_cache.num = 0
			--print("xxx-----------------msg_process_cache_add_timeout:",_cache_key,add_num)
			obj.add_process(add_num)

		end )

	end--]]

end

return task_base_func
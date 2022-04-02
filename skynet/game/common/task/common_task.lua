---  通用任务

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local task_base_func = require "task.task_base_func"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST = base.REQUEST
local PUBLIC = base.PUBLIC

DATA.common_task_protect = {}
local task = DATA.common_task_protect


function task.gen_task_obj(config,data)
	--local other_config = skynet.call(DATA.service_config.task_center_service,"lua","get_vip_duiju_hongbao_task_config")
	local obj = {
		-- 所有配置
		config = config,
		-- 任务id
		id = config.id,
		-- 任务进度
		process = data.process,
		-- 当前要领的奖励等级
		task_round = data.task_round,

		-- 这个任务的创建时间
		create_time = data.create_time,

		--- 其他数据
		other_data = data.other_data,

		-- 进度等级
		lv = nil,
		-- 当前阶段的进度
		now_lv_process = nil,
		-- 当前阶段还需要多少进度
		now_lv_need_process = nil,

		task_award_get_status = data.task_award_get_status or "0",

		---- 时间限制
		time_limit = data.time_limit ,


		process_index = nil,
		msg = {},

		--- 设置是否启用
		is_open = true,
	}

	---- 处理一下other_data
	if obj.other_data then
		local other_parse_data = task_base_func.parse_activity_data(obj.other_data)
		obj.other_data = other_parse_data
	end

	------ 时间限制的 初始化 处理(这个在更新任务时，可能无法及时更新到)
	if (not obj.time_limit or obj.time_limit == task_base_func.task_max_time_limit ) and config.time_limit then
		if config.time_limit == -1 then
			obj.time_limit = task_base_func.task_max_time_limit
		elseif config.time_limit >= 0 then
			obj.time_limit = os.time() + config.time_limit
		end
		if not obj.time_limit then
			obj.time_limit = task_base_func.task_max_time_limit
		end
	end

	---- 刷新配置
	obj.refresh_config = function(config)
		obj.config = config
		obj.init(true)
	end

	---- 初始化
	obj.init = function ( is_refresh_cfg )

		PUBLIC.deal_msg(obj)

		--- 监听消息
		DATA.msg_dispatcher:register( obj , obj.msg )

		if obj.reset_timecancler then
			obj.reset_timecancler()
		end
		if obj.time_limit_timecancler then
			obj.time_limit_timecancler()
		end

		obj.max_process , obj.max_task_round = task_base_func.get_max_process(obj.config.process_data)

		obj.lv = 1
		obj.process_index = 1

		--- 处理预先的进度
		if obj.config.pre_add_process and obj.process < obj.config.pre_add_process then
			obj.process = obj.config.pre_add_process
			---- ps:这里可以不用立刻更新，因为这个判断的操作基本上是这个任务第一次创建的时候执行的，第一次执行，后续会更新数据的 
			-- [但是从数据库中加载进来，并不会调用更新函数，所以在最后还是加一个更新函数]
		end

		obj.get_lv_info()

		--- 处理是否重置进程 , 这个在 get_lv_info 之后，避免处理重置时，要访问任务等级信息
		if obj.config.is_reset == 1 then
			PUBLIC.deal_reset_process( obj )
		end

		---- 处理时限
		if obj.time_limit and obj.time_limit > os.time() and obj.time_limit ~= task_base_func.task_max_time_limit then
			obj.time_limit_timecancler = nodefunc.cancelable_timeout( ( obj.time_limit - os.time() ) * 100 , function ()
				---- 发出一个任务时限到期的消息
				PUBLIC.trigger_msg( {name = "task_time_limit_over"} , obj.id )
			end)
		elseif obj.time_limit and obj.time_limit < os.time() then
			---- 下次上来，任务已经过期了，那么直接发出一个过期消息（ 避免捕鱼挑战任务过期后未删掉，上线时主动触发一下 ）
			obj.time_limit_timecancler = nodefunc.cancelable_timeout(50 , function()
				PUBLIC.trigger_msg( {name = "task_time_limit_over"} , obj.id )
			end)
		end

		---- 管他的都更新一下
		obj.update_data(true)
	end

	---- 虚假的init，给师徒系统
	obj.fork_init = function()
		obj.max_process , obj.max_task_round = task_base_func.get_max_process(obj.config.process_data)

		obj.lv = 1
		obj.process_index = 1
		obj.get_lv_info()
	end

	--- 重置任务
	obj.reset_task = function(pre_callback , callback)
		----------------------------
		local now_time = os.time()
		--[[
		--- 任务开始的时间
		local start_valid_time = obj.config.start_valid_time or 0
		--- 当前时间距离开始时间的时间
		local dif_time = now_time - start_valid_time
		--- 距离开始时间已经过了多少天
		local dif_day = math.floor( dif_time / 86400 )
		--- 到下一个刷新点还需要的时间
		local next_refresh_time = (obj.config.reset_delay - (dif_day % obj.config.reset_delay))*86400 - dif_time % 86400

		-------------
		local create_dif_time = obj.create_time - start_valid_time
		local create_dif_day = math.floor( create_dif_time / 86400 )

		local is_same_round = true

		if math.floor(dif_day / obj.config.reset_delay) ~= math.floor(create_dif_day / obj.config.reset_delay) then
			is_same_round = false
		end--]]

		local is_reset , next_refresh_time = task_base_func.get_is_reset_task_data(obj)


		if is_reset then
			if pre_callback then
				pre_callback()
			end

			obj.create_time = now_time
			obj.process = 0
			obj.lv = 1
			obj.process_index = 1
			obj.task_round = 1
			obj.task_award_get_status = "0"

			--- 处理预先的进度,重置的时候也 会加自动进度
			if obj.config.pre_add_process and obj.process < obj.config.pre_add_process then
				obj.process = obj.config.pre_add_process
				---- ps:这里可以不用立刻更新，因为这个判断的操作基本上是这个任务第一次创建的时候执行的，第一次执行，后续会更新数据的
			end
			--- 获得等级数据
		    obj.get_lv_info()

			obj.update_data()

			if callback then
				callback()
			end
			--- 通知进度改变
			PUBLIC.deal_task_progress_change(obj)

			--- 触发一下，资产观察
			skynet.timeout(200 , function()
				PUBLIC.asset_observe()
			end)
		end

		---- 下一天的timeout
		obj.reset_timecancler = nodefunc.cancelable_timeout( next_refresh_time * 100 , function ()
			obj.reset_task( pre_callback , callback )
		end)
	end

	---- 设置是否启用
	obj.set_is_open = function(bool)
		--print("-----------------set_is_open:",obj.id , bool and "true" or "false")
		obj.is_open = bool
		if not bool then
			DATA.msg_dispatcher:unregister( obj )
			obj.msg = {}
		else
			PUBLIC.deal_msg(obj)
			DATA.msg_dispatcher:register( obj , obj.msg )
		end
	end

	obj.get_is_open = function()
		return obj.is_open
	end

	-- 设置不接受消息
	obj.not_accept_msg = function()
		--print("-----------------not_accept_msg:",obj.id)
		DATA.msg_dispatcher:unregister( obj )
		obj.msg = {}
	end

	---- 销毁
	obj.destroy = function ()

		DATA.msg_dispatcher:unregister( obj )

		if obj.reset_timecancler then
			obj.reset_timecancler()
		end
		if obj.time_limit_timecancler then
			obj.time_limit_timecancler()
		end
	end

	obj.complete = function ()
	end

	obj.update_data = function(_is_update_other_data)

		PUBLIC.update_task( obj.id , obj.process , obj.task_round , obj.create_time , obj.task_award_get_status , obj.time_limit )

		--- 如果要更新other_data
		if _is_update_other_data then
			PUBLIC.update_task_other_data( obj.id , obj.other_data )
		end
	end

	--- 获得当前所处的lv等级,只适用于不能累积任务进度类型的
	obj.get_lv_info = function()
		local now_process = obj.process - task_base_func.get_grade_total_process(obj.config.process_data , obj.lv)
		local process_index = obj.process_index
		local now_lv_need_process = obj.config.process_data[process_index]
		assert( now_lv_need_process ~= -1 , "error now_lv_need_process ~= -1" )
		local lv = obj.lv
		while true do
			local is_add_lv = false
			---- 如果等级已经达到最大了，直接返回
			if lv >= obj.max_task_round then
				break
			end
			---- 如果等级没有达到最大，但进度已经达到这个等级了
			if now_process >= now_lv_need_process then
				is_add_lv = true
			end


			if is_add_lv then
				now_process = now_process - now_lv_need_process
				lv = lv + 1
				process_index = process_index + 1
				now_lv_need_process = obj.config.process_data[process_index]

				if not now_lv_need_process then
					now_lv_need_process = 0
					break
				elseif now_lv_need_process == -1 then
					process_index = process_index - 1
					now_lv_need_process = obj.config.process_data[process_index]
				end
			else
				break
			end
		end


		obj.lv = lv
		obj.now_lv_process = now_process
		obj.now_lv_need_process = now_lv_need_process
		obj.process_index = process_index
	end

	---- 获取一个等级的具体的奖励数据
	obj.get_lv_award_data = function(award_lv)
		local award_data = {}

		local target_award_cfg = obj.config.award_data

		---- 如果other_data里面有fix_award_data 就用fix_award_data里面的数据
		if obj.other_data and obj.other_data.fix_award_data then
			target_award_cfg = obj.other_data.fix_award_data
		end

		if target_award_cfg[award_lv] then
			award_data = basefunc.deepcopy( target_award_cfg[award_lv] )
		else
			if obj.config.process_data[#obj.config.process_data] == -1 then
				award_data = basefunc.deepcopy( target_award_cfg[#target_award_cfg] )
			end
		end

		if award_data then

			----- 目标奖励,,随机选一个，
			if obj.config.get_award_type == "random" then

				local target_rand_award = basefunc.get_random_data_by_weight( award_data , "weight" )
				award_data = { [1] = target_rand_award }
			end

			------ 处理 value 的自带随机功能
			for key,data in pairs(award_data) do
				--local awa = basefunc.deepcopy( data )
				local end_value = 0
				if data.value and type(data.value) ~= "table" then
					end_value = data.value
				elseif data.value and type(data.value) == "table" then
					if #data.value == 1 then
						end_value = data.value[1]
					elseif #data.value > 1 then
						local min_value = math.min( data.value[1],data.value[2] )
						local max_value = math.max( data.value[1],data.value[2] )
						end_value = math.random(min_value,max_value)
					end
				end
				data.value = end_value
				--target_award[#target_award + 1] = awa
				--break
			end

			------- 处理限时道具 -------------
			for key,data in pairs(award_data) do
				if data.lifetime then
					data.attribute = {valid_time= os.time() + data.lifetime }
					data.value = nil
					data.lifetime = nil
				end
			end
		end

		return award_data
	end

	----- 获得奖励
	obj.get_award = function (_award_progress_lv)
		----- 限制任务的有效期，非有效期可以领已经能领的，
		--[[local now_time = os.time()
		if obj.config.start_valid_time and obj.config.end_valid_time then
			if now_time < obj.config.start_valid_time or now_time > obj.config.end_valid_time then
				return 3808
			end
		end--]]
		local award_progress_lv = _award_progress_lv or obj.task_round

		---- 做验证
		if award_progress_lv <= 0 then
			return 1003
		end
		if award_progress_lv > obj.lv then
			return 1003
		end
		if award_progress_lv == obj.lv then
			if obj.now_lv_process < obj.now_lv_need_process then
				return 1003
			end
		end

		local award_status_vec = basefunc.decode_task_award_status( obj.task_award_get_status )
		if award_status_vec[award_progress_lv] then
			return 1003
		end

		-------------------------------------------------------- ↓ 判断权限限制 ↓ ---------------------------------------------------
		--[[if DATA.common_permission_manager and DATA.variant_data_agent_protect then
			local is_can_do , error_des = DATA.common_permission_manager.judge_permission_effect( "task_" .. obj.id , DATA.variant_data_agent_protect.variant_data )

			if not is_can_do then
				----处理错误信息
				CMD.notify_client_permission_error_desc( error_des )

				return -666
			end
		end--]]
		-------------------------------------------------------- ↑ 判断权限限制 ↑ ---------------------------------------------------
			local award_data = obj.get_lv_award_data(award_progress_lv)

			if award_data then

				obj.task_round = obj.task_round + 1

				---- 任务领奖状态更新

				award_status_vec[award_progress_lv] = true
				obj.task_award_get_status = basefunc.encode_task_award_status( award_status_vec , "string" , true )

				--dump(award_status_vec , string.format("xxxx--------------------------award_status_vec: player_id:%s , task_id:%d , task_award_get_status:%d", DATA.my_id , obj.id , obj.task_award_get_status)   )

				----- 记录任务奖励日志
				if PUBLIC.check_is_need_write_task_award_log( obj ) then
					for key,data in pairs(award_data) do
						PUBLIC.add_player_task_award_log( obj.id , award_progress_lv , data.asset_type , data.value or 0 )
					end
				end

				obj.update_data()

				------------------ 通知客户端，状态改变 --------------------
				PUBLIC.deal_task_progress_change(obj)

				PUBLIC.deal_get_task_award(obj , goldpig_cash_num , award_data)

				--[[---- 任务完成发出一个消息出去
				if obj.process == obj.max_process and obj.task_round > obj.max_task_round then
					---- 有可能还有要操作这个数据，先加个延迟
					skynet.timeout(50 , function()
						PUBLIC.trigger_msg( {name = "task_complete"} , obj.id, award_data )
					end)
				end--]]

				return award_data
			end
		--end

		return false
	end

	----- 增加进度,返回进度是否改变
	obj.add_process = function (exp)
		if obj.process == obj.max_process then
			return false
		end

		---- 参与条件过滤
		if not task_base_func.check_task_join_condition( DATA.my_id , obj.config.join_condition ) then
			return false
		end

		----- 限制任务的有效期
		local now_time = os.time()
		if obj.config.start_valid_time and obj.config.end_valid_time then
			if now_time < obj.config.start_valid_time or now_time > obj.config.end_valid_time then
				return false
			end
		end

		--- 任务有效期
		if obj.time_limit and obj.time_limit < now_time then
			return false
		end

		-------------------------------------------------------- ↓ 判断权限限制 ↓ ---------------------------------------------------
		if DATA.common_permission_manager and DATA.variant_data_agent_protect then
			local is_can_do , error_des = DATA.common_permission_manager.judge_permission_effect( "task_" .. obj.id , DATA.variant_data_agent_protect.variant_data )
			if not is_can_do then
				----处理错误信息
				--CMD.notify_client_permission_error_desc( error_des )
				return false
			end
		end
		-------------------------------------------------------- ↑ 判断权限限制 ↑ ---------------------------------------------------

		obj.process = obj.process + exp
		if obj.process > obj.max_process then
			exp = exp - (obj.process - obj.max_process )
			obj.process = obj.max_process
		end

		if obj.process == obj.max_process then
			PUBLIC.trigger_msg( {name = "task_process_complete" , send_filter ={ task_own_type = obj.config.own_type } } , obj.id )
		end

		--- 加日志
		if PUBLIC.check_is_need_write_log(obj.id) then
			PUBLIC.add_player_task_log(obj.id , exp , obj.process)
		end

		obj.get_lv_info()

		obj.update_data()

		--- 发出一个消息
		PUBLIC.trigger_msg( {name = "on_task_progress_change" , send_filter = { task_id = obj.id } } , obj.id , exp , obj.process )

		------------------ 通知客户端，状态改变 --------------------
		PUBLIC.deal_task_progress_change(obj)

		--------------- 如果是金猪礼包2的金币保障任务，自动领奖。
		PUBLIC.deal_task_auto_get_award_rights(obj)

		return true
	end

	--- 任务进度清零(慎用)
	obj.clear_process = function()
		local old_process = obj.process
		obj.process = 0
		local exp = -old_process
		--- 加日志
		if PUBLIC.check_is_need_write_log(obj.id) then
			PUBLIC.add_player_task_log(obj.id , exp , obj.process)
		end

		obj.get_lv_info()

		obj.update_data()

		--- 发出一个消息
		PUBLIC.trigger_msg( {name = "on_task_progress_change" , send_filter = { task_id = obj.id } } , obj.id , exp , obj.process )

		------------------ 通知客户端，状态改变 --------------------
		PUBLIC.deal_task_progress_change(obj)

		--------------- 如果是金猪礼包2的金币保障任务，自动领奖。
		-- PUBLIC.deal_task_auto_get_award_rights(obj)

		return true
	end

	----- 获取这个任务应该能领的任务奖励
	obj.get_should_get_awards = function( is_change_award_status )
		local should_award = {}

		local tem_award_vec = {}

		local award_status_vec = basefunc.decode_task_award_status( obj.task_award_get_status )
		for key = 1 , obj.lv do
			--- 如果这个等级没有领
			if not award_status_vec[key] then
				if key == obj.lv then
					if obj.now_lv_process < obj.now_lv_need_process then
						break
					end
				end

				local award_data = obj.get_lv_award_data(key)

				if is_change_award_status then
					award_status_vec[key] = true
					obj.task_round = obj.task_round + 1

					----- 记录任务奖励日志( 如果是要改变奖励状态 的请求，就记录一下日志 )
					if PUBLIC.check_is_need_write_task_award_log( obj ) then
						for _,data in pairs(award_data) do
							PUBLIC.add_player_task_award_log( obj.id , key , data.asset_type , data.value or 0 )
						end
					end

				end

				for _,data in pairs(award_data) do
					if data.asset_type then
						--- 按资产类型累加
						if tem_award_vec[data.asset_type] then
							--- 如果有就只加value
							tem_award_vec[data.asset_type].value = tem_award_vec[data.asset_type].value + (data.value or 0)
						else
							---- 如果没有，就用这个数据，结构保持一致
							tem_award_vec[data.asset_type] = basefunc.deepcopy( data )
						end

					else
						should_award[#should_award + 1] = basefunc.deepcopy(data)
					end
				end
			end
		end
		--- 组合
		for k,data in pairs(tem_award_vec) do
			should_award[#should_award + 1] = data
		end


		if is_change_award_status then
			obj.task_award_get_status = basefunc.encode_task_award_status( award_status_vec , "string" , true  )
			obj.update_data()

			if next(should_award) then  --- 如果领了奖励
				---- 自动领奖时,发送一个处理
				PUBLIC.deal_get_task_award( obj )
			end
		end

		return should_award
	end

	--- 直接刷新进度
	obj.update_process = function(now_process)
		obj.process = now_process
		obj.get_lv_info()

		PUBLIC.deal_task_auto_get_award_rights(obj)
	end

	--- 获得当前进度，分子
	obj.get_now_process = function()
		local now_lv_process = obj.now_lv_process
		---- 充值类型的任务的进度为了方便客户端，返回/100的
		--[[if obj.config.condition_type == "charge_any" or obj.config.condition_type == "pre_charge_any" then
			now_lv_process = math.ceil(now_lv_process / 100)
		end--]]

		return now_lv_process
	end

	--- 获得当前等级需要的进度，分母
	obj.get_need_process = function()
		local now_lv_need_process = obj.now_lv_need_process
		---- 充值类型的任务的进度为了方便客户端，返回/100的
		--[[if obj.config.condition_type == "charge_any" or obj.config.condition_type == "pre_charge_any" then
			now_lv_need_process = math.ceil(now_lv_need_process / 100)
		end--]]

		return now_lv_need_process
	end

	--- 获得奖励领取状态
	obj.get_award_status = function()
		if not obj.is_open then
			return DATA.award_status.not_open
		end

		--- 该领取的等级大于最大领取等级，
		if obj.task_round > obj.max_task_round then
			return DATA.award_status.complete
		end

		--# 0-不能领取 | 1-可领取 | 2-已完成
		if obj.lv == obj.task_round then
			if obj.now_lv_process == obj.now_lv_need_process then
				return DATA.award_status.can_get
			end
			return DATA.award_status.not_can_get
		elseif obj.lv > obj.task_round then
			return DATA.award_status.can_get
		elseif obj.lv < obj.task_round then
			if obj.process == obj.max_process then
				return DATA.award_status.complete
			else
				return DATA.award_status.not_can_get
			end
		end
		return DATA.award_status.not_can_get
	end
	
	return obj
end

return task
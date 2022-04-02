------  buff 和 obj 都立刻 创建的技能； 当受到消息的 处理也是立刻执行

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.hurry_create_skill_protect = {}
local D = DATA.hurry_create_skill_protect


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	
	----- 获得一个 处理消息的 通用函数
	function C:get_one_msg_deal_func(data)
		return function(_self , _arg_table )
			--print("xxxx----------------on_deal_msg wss:" , data.trigger_msg , _arg_table)
			--dump(_arg_table , "xxxx-----------------------------------_arg_table:")

			--- 针对每一个参数 做检查
			local is_all_ok = true
			if _arg_table and type(_arg_table) == "table" then

				------
				local condition_env = basefunc.deepcopy( _arg_table )
				local extra_data = { owner = self.owner , _d = self.d , skill_self = self }
				condition_env = basefunc.merge( extra_data , condition_env )

				if data.trigger_msg_condition then
					for key, cond_dsl in pairs(data.trigger_msg_condition) do
						if cond_dsl.func and cond_dsl._env then

							--dump(cond_dsl._env , string.format("xxx----------------------cond_dsl._env:%s" , cond_dsl._env )  )

							local is_true = cond_dsl.func( condition_env )

							--print( string.format("xxx----check_condition__%s__%s__%s_is_%s", self.id , data.trigger_msg , cond_dsl.conditon_dsl , is_true and "true" or "false" ) )
							if is_true then
								--dump( self.owner , string.format("xxx----------------check_condition skill_id:%s  self.owner:%s", self.id ,data.trigger_msg ) )
								--dump( _arg_table , string.format("xxx----------------check_condition _arg_table skill_id:%s  self.owner:%s", self.id ,data.trigger_msg ) )
							end
							----- 正式版 ↓
							--local is_ok , is_true = pcall( cond_dsl.func , condition_env )
							--if is_ok and not is_true then
							----- 正式版 ↑

							if not is_true then
								is_all_ok = false
								break
							end
						end
					end
				end

			end

			---- 如果全部成立 
			if is_all_ok then
				----- 把 deal_work 放到执行队列中
				--self.d.game_run_system:create_delay_func_obj(function() 
					_self:deal_work( data , _arg_table )
				--end)
			end
		end
	end

	--- 处理操作
	function C:deal_work( _work_module , _arg_table)
		---- 处理 前置条件检查
		if not self:deal_work_condition(_work_module.work_condition)  then
			----- 发出一个消息，技能 前置条件检查 失败
			PUBLIC.trriger_msg( self.d , "skill_work_condition_false" , { skill_id = self.id , trigger = _arg_table.trigger , false_skill_owner = self.owner } )

			return false
		end

		local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

		if skill_target then

			----------------------------------- 记录过程数据
			self:deal_skill_trigger_process_data( skill_target , _arg_table , _work_module.trigger_msg )

			------------------------------------------- 执行操作
			local create_obj_num = 1
			--[[local work_twice_gl = DATA.car_prop_lib.get_skill_buff_value( self , "work_twice_gl" )
			if math.random(100) < work_twice_gl then
				create_obj_num = 2
			end--]]
			----- 要做的 obj 列表
			for i = 1,create_obj_num do
				self:create_run_obj( _work_module , skill_target )
			end

		
			----- 延迟创建 buff
			local last_process_no = self.last_process_no
			--self.d.game_run_system:create_delay_func_obj(function() 
				self:create_buff( _work_module , skill_target , last_process_no )
			--end)


			-------- 创建buff , （这个得 用 创 obj 的方式来创。 保证顺序）
			--self:create_buff( _work_module , skill_target )
			
			--------------------------------------------- 生命周期处理
			self:deal_skill_life_data( "trigger_num" )

		end

		return true
	end

	---- 处理 work
	function C:deal_real_work( _run_obj_id , _work_target)
		print("xxxx-------------common_task__deal_real_work_1:" , _run_obj_id , _work_target)

		local data = { owner = _work_target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no , obj_run_type = "now" }

		PUBLIC.run_obj_create_factory( self.d , _run_obj_id , data )

	end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
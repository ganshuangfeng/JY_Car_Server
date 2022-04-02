----- 基础的 技能 组件对象

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("common_skill")

C.msg_table = {}

function C:ctor( _d , _config , _data )
	print("xxxx----------common_skill_new:" , _config.id)
	------------------------------------ 通用项 ↓
	self.d = _d

	self.config = _config

	---- 唯一编号
	self.d.skill_no = self.d.skill_no + 1
	self.no = self.d.skill_no

	self.id = _config.id or 1
	self.key = _config.key

	self.life_type = _config.life_module and _config.life_module.life_type
	self.life_value = _config.life_module and _config.life_module.life_value
	self.life_overlay_rule = _config.life_module and _config.life_module.overlay_rule

	self.owner = _data.owner

	self.create_data = _data

	---- 导致创建技能的 过程编号
	--self.father_process_no = _data.father_process_no

	--- 技能的标签
	self.tag = _config.tag

	---- 这个技能创建的 buff obj
	self.created_buff = {}       --- { [1] = buff_obj , [2] = buff_obj2 }

	---- 可以被buff影响的属性
	self.buff_prop = {
		bj_gl = 0,            --- (在操作obj中获取) 暴击概率 0~100
		lj_gl = 0,            --- (在操作obj中获取) 连击概率
		final_at = 0,         --- (在操作obj中获取) 攻击值，传默认值
		final_add_at = 0,     --- 最终 额外增加的 攻击值

		fix_at_value = 0,           --- (在操作obj中获取) 固定伤害值，传默认值
		base_at_time = 0,     --- 基础伤害的倍数，传默认值
		

		random_work_gl = 0,   --- (在技能中获取) 技能触发概率，传默认值
		
	}

	------- 技能的叠加次数 (默认是0次表示没有叠加，叠加了之后再 + 1)
	self.overlay_num = 0

	------ 哪些消息是 自己处理的
	self.self_deal_msg = {
		on_create = true,
		on_create_after = true ,
		on_destroy = true,
		on_refresh_after = true ,

		self_skill_life_over = true,
	}

	-------------------------------- 通用项 ↑
	
	---- 创建技能 时的 过程no
	self.create_skill_process_no = nil
	---- 上一次的 触发的 process_no
	self.last_process_no = nil

	---- 自己的消息处理 列表
	self.msg_deal = {}
	---- 消息处理的 函数表 ， 一个消息对应多个函数
	self.msg_deal_func = {}

	---- 上次 技能作用的对象
	self.skill_target = nil
	
	dump(C.msg_table , "xxxx------------------------C.msg_table:")

	---- 直接在构造函数里面处理
	self:deal_msg_condition_func()

	----- 避免和 配置的消息监听重叠
	self.class_msg_obj = { self = self }
	----- 监听消息
	PUBLIC.add_msg_listener( self.d , self.class_msg_obj , C.msg_table )
end

function C:deal_msg_condition_func()
	--print("xxx---------------deal_msg_condition_func:" , self.id)

	--if self.id == 10009 then
		--dump(self.config.work_module , "xxx------self.config.work_module:")
	--end

	if self.config.work_module and self.config.work_module then
		for _key , work_module_data in pairs( self.config.work_module ) do
			for _k , _msg_cond in pairs( work_module_data.trigger_msg_condition ) do

				---- 先转换一下条件判断
				--_msg_cond.conditon_dsl = PUBLIC.convert_chehua_config( self.d , _msg_cond.conditon_dsl , self.id , self.owner and self.owner.seat_num )

				local tar_vec = { func = nil , _env = {setmetatable = setmetatable , _error = error , P = PUBLIC } }
				local tar_dsl_str = "setmetatable(_ENV,{__index=... , __newindex = function() _error('canot change variant!') end}) if " 
						 						.. _msg_cond.conditon_dsl .. " then return true else return false end"
				
				tar_vec.func = load( tar_dsl_str , nil , "t" , tar_vec._env )
				tar_vec.conditon_dsl = _msg_cond.conditon_dsl

				work_module_data.trigger_msg_condition[_k] = tar_vec
			end
		end
	end

	--dump(self.config.work_module , "xxx------self.config.work_module22:")
end

---- 刷新技能 , _father_process_no 导致刷新的 process_no
function C:refresh( _father_process_no )
	self.overlay_num = self.overlay_num + 1

	local is_overlay_max = false
	if self.overlay_num > self.config.overlay_max then
		self.overlay_num = self.config.overlay_max
		is_overlay_max = true
	end

	----- 处理生命周期的叠加
	if self.life_overlay_rule then
		self.life_value = PUBLIC.deal_overlay_rule( self.life_value , self.config.life_module.life_value , self.life_overlay_rule , self.overlay_num )
	end

	----- 技能叠加刷新， 调用技能改变
	local process_no = self:on_skill_change( _father_process_no )


	----- 刷新buff 
	if not is_overlay_max then
		self:refresh_buff( process_no )
	end

	---- 处理消息
	self:common_deal_on_msg( "on_refresh_after" )
end

----- 通用的 调用 主动处理的消息
function C:common_deal_on_msg( _msg_name )
	--- 处理  on_create 消息的多个函数
	if self.msg_deal_func and self.msg_deal_func[_msg_name] and type(self.msg_deal_func[_msg_name]) == "table" then
		--- 这里 用 ipairs 确保顺序
		for key,data in ipairs( self.msg_deal_func[_msg_name] ) do
			--self.d.game_run_system:create_delay_func_obj(function() 
				self:deal_work( data , { trigger = self.owner } )
			--end)
		end
	end
end


--- 初始化 ， 当技能创建之后调用
function C:init( _father_process_no )
	---- 加入obj的技能列表
	self.create_skill_process_no = PUBLIC.add_skill( self , _father_process_no )

	--- 处理 消息监听
	self:deal_msg()

	--self:deal_on_create_msg()
	
	---- 处理消息
	self:common_deal_on_msg( "on_create" )

	---- 处理消息
	self:common_deal_on_msg( "on_create_after" )

end

--- 销毁时 调用
function C:destroy( _father_process_no )
	--self:deal_on_destroy_msg()
	self:common_deal_on_msg( "on_destroy" )

	self:remove_msg()

	self:clear_buff()
end

---- 清除 buff
function C:clear_buff()
	if self.created_buff and type(self.created_buff) == "table" then
		for key,buff_obj in pairs(self.created_buff) do
			--buff_obj:destroy()
			PUBLIC.delete_buff( buff_obj )

		end
	end

	self.created_buff = {}
end

function C:refresh_buff( _father_process_no )
	if self.created_buff and type(self.created_buff) == "table" then
		for key,buff_obj in pairs(self.created_buff) do
			if buff_obj.refresh then
				buff_obj:refresh( _father_process_no )
			end
		end
	end
end

---- 加入 消息处理函数
function C:add_msg_deal_func( _msg_name , _func)
	self.msg_deal_func[_msg_name] = self.msg_deal_func[_msg_name] or {}
	local tar_vec = self.msg_deal_func[_msg_name]
	tar_vec[#tar_vec + 1] = _func
end

----- 获得一个 处理消息的 通用函数
function C:get_one_msg_deal_func(data)
	return function(_self , _arg_table )
		print("xxxx----------------on_deal_msg wss:" , self.id , data.trigger_msg , _arg_table)
		--dump(_arg_table , "xxxx-----------------------------------_arg_table:")
		local _arg_table = _arg_table
		local _self = _self
		local data = data

	--self.d.game_run_system:create_delay_func_obj(function() 
		print("xxxx----------------------on_deal_msg wss 22:" , self.id , data.trigger_msg , _arg_table)
		--- 针对每一个参数 做检查
		local is_all_ok = true
		if _arg_table and type(_arg_table) == "table" then

			------
			--local condition_env = basefunc.deepcopy( _arg_table )
			--local extra_data = { owner = self.owner , _d = self.d , skill_self = self }
			--condition_env = basefunc.merge( extra_data , condition_env )

			local condition_env = { owner = self.owner , _d = self.d , skill_self = self } -- basefunc.deepcopy( _arg_table )
			--local extra_data = { owner = self.owner , _d = self.d , skill_self = self }
			condition_env = basefunc.merge( _arg_table , condition_env )

			if data.trigger_msg_condition then
				for key, cond_dsl in pairs(data.trigger_msg_condition) do
					if cond_dsl.func and cond_dsl._env then

						--dump(cond_dsl._env , string.format("xxx----------------------cond_dsl._env:%s" , cond_dsl._env )  )

						local is_true = cond_dsl.func( condition_env )

						print( string.format("xxx----check_condition__%s__%s__%s_is_%s", self.id , data.trigger_msg , cond_dsl.conditon_dsl , is_true and "true" or "false" ) )

						if self.id == 10011 then
							print("xxx----------test 10011 :" ,  _arg_table.trigger.is_move , _arg_table.trigger.pos , self.owner.road_id , _arg_table.trigger.group , self.owner.group)
						end

						if is_true then
							print("xxxx----------------------on_deal_msg wss 33:" , self.id , data.trigger_msg , _arg_table)
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
			print("xxxx----------------------on_deal_msg wss 44:" , self.id , data.trigger_msg , _arg_table)
			----- 把 deal_work 放到执行队列中
			self.d.game_run_system:create_delay_func_obj(function() 
				_self:deal_work( data , _arg_table )
			end)
		end
	--end)

	end
end

---- 处理 每一个 工作模块
function C:deal_one_work_module(data)

	if self.self_deal_msg[data.trigger_msg] then --  data.trigger_msg == "on_create" or data.trigger_msg == "on_destroy"  then
		---- 创建时调用，把 模块数据存起来
		self:add_msg_deal_func( data.trigger_msg , data )
	elseif data.trigger_msg == "zhudong" then
		----- 不做任何处理的消息

	else

		--- 监听 触发 消息
		local func = self:get_one_msg_deal_func(data)

		----- 先把消息要处理的函数，存起来
		self:add_msg_deal_func( data.trigger_msg , func )
	end
end

function C:connect_msg_deal_func()
	for msg_name , msg_func_vec in pairs(self.msg_deal_func) do
		----- 不是消息监听处理的 
		if not self.self_deal_msg[msg_name] and msg_name ~= "zhudong" then
			print("xxx------------connect_msg_deal_func:" ,self.id , msg_name )
			self.msg_deal[msg_name] = function(...)
				if msg_func_vec and type(msg_func_vec) == "table" then
					for key,func in pairs(msg_func_vec) do
						func(...)
					end
				end
			end
		end
	end
end

--- 处理 消息监听
function C:deal_msg ()
	self.msg_deal = {}
	self.msg_deal_func = {}

	if self.config and self.config.work_module then
		--- 这里 用 ipairs 确保顺序
		for key,data in ipairs(self.config.work_module) do

			self:deal_one_work_module(data)

		end
	end

	----- 把消息处理函数列表，连接给消息处理
	self:connect_msg_deal_func()

	PUBLIC.add_msg_listener( self.d , self , self.msg_deal )
end

	--- 删除 消息
function C:remove_msg()
		
	PUBLIC.delete_msg_listener( self.d , self )
	PUBLIC.delete_msg_listener( self.d , self.class_msg_obj )
	
end

------ 处理技能触发 的过程数据
function C:deal_skill_trigger_process_data( skill_target , _arg_table , _trigger_msg )
	local trigger_data = _arg_table.trigger and { PUBLIC.get_game_owner_data( _arg_table.trigger ) } or {}
	-----
	---- 记录一下
	self.skill_target = skill_target

	local receive_data = {}
	for key,data in pairs(skill_target) do
		receive_data[#receive_data+1] = PUBLIC.get_game_owner_data( data )
	end

	----- 收集数据 , 技能触发
	------------- 忽略不必要的 过程数据
	if not DATA.process_ignore_skill_key[ self.config.key ] then
		self.last_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
			skill_trigger = {
				owner_data = PUBLIC.get_game_owner_data( self.owner )  ,
				trigger_msg = _trigger_msg ,

				skill_data =  DATA.game_info_center.get_one_skill_data( self ) ,

				trigger_data = trigger_data ,
				receive_data = receive_data ,

				skill_name = self.config.name ,
			} } , self.create_skill_process_no
		)
	end
end

------ 创建 运行 obj
function C:create_run_obj( _work_module , skill_target )
	----- 要做的 obj 列表
	local work_obj_id_vec = _work_module.work_obj_id
	---- 要做的事情
	for _obj_id_index , _obj_id in ipairs(work_obj_id_vec) do
		---- 要做的具体事情 和 次数
		local obj_id , obj_num = PUBLIC.get_skill_cfg_obj_data( _obj_id )
		print("xxx--------------create_run_obj:" , self.id , _obj_id , obj_num , obj_id )
		for i = 1 , obj_num do
			--- 对每一个目标做
			for key, target in pairs(skill_target) do
				self:deal_real_work( obj_id , target ) 
			end
		end
	end
end

--- _father_process_no 从外面传进来，避免 使用时已经改变了
function C:create_buff( _work_module , skill_target , _father_process_no )
	local buff_id_vec = _work_module.buff_id

	for _ , _buff_id in ipairs(buff_id_vec) do
		local obj_id , obj_num  = PUBLIC.get_skill_cfg_obj_data( _buff_id )


		for i = 1 , obj_num do
			for key, target in pairs(skill_target) do
				
				------ 创建buff
				local _data =  { owner = target , skill = self , father_process_no = _father_process_no }
			
				self:create_one_buff(obj_id , _data)
			end
		end
	end
end

---- 创建一个 buff 
function C:create_one_buff(_buff_id , _data)
	local buff_obj = PUBLIC.buff_obj_create_factory( self.d , _buff_id , _data)

	if buff_obj then
		
		self:add_buff_to_skill( buff_obj )
	end
end

function C:add_buff_to_skill( buff_obj )
	self.created_buff[#self.created_buff + 1] = buff_obj
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
		self.d.game_run_system:create_delay_func_obj(function() 
			self:create_buff( _work_module , skill_target , last_process_no )
		end)


		-------- 创建buff , （这个得 用 创 obj 的方式来创。 保证顺序）
		--self:create_buff( _work_module , skill_target )
		
		--------------------------------------------- 生命周期处理
		self:deal_skill_life_data( "trigger_num" )

	end

	return true
end



----- 处理生命周期  减
function C:deal_skill_life_data( _life_type )
	if self.life_type and self.life_value and self.life_type == _life_type then
		self.life_value = self.life_value - 1

		--- 轮次的生命周期 ，需要减到 -1 才死。
		local is_delete = false
		if _life_type == "round_num" then
			if self.life_value < 0 then
				is_delete = true
			end
		else
			if self.life_value <= 0 then
				is_delete = true
			end
		end


		---- 删掉
		if is_delete then
			----- 触发消息 , 技能 生命周期完了
			PUBLIC.trriger_msg( self.d , "skill_life_over" , { skill_id = self.id } )

			----
			--self:deal_on_self_skill_life_over_msg()
			self:common_deal_on_msg( "self_skill_life_over" )


			self.d.game_run_system:create_delay_func_obj(function() 
				PUBLIC.delete_skill( self )
			end )
		end
	end
end

---- 处理 work de 前置条件
function C:deal_work_condition(_work_condition)
	if not self.owner then
		return false
	end

	if not _work_condition or type(_work_condition) ~= "table" or not next(_work_condition) then
		return true
	end

	if _work_condition.random then
		---- 随机概率条件
		local c_data =  _work_condition.random
		local random = math.random(100)

		local tar_condition_value = c_data.condition_value
		local tar_judge_type = c_data.judge_type

		----- 处理叠加值
		if c_data.overlay_rule then
			tar_condition_value = PUBLIC.deal_overlay_rule( tar_condition_value , c_data.condition_value , c_data.overlay_rule , self.overlay_num )
		end

		----- 获取buff 影响后的值
		local real_condition_value = DATA.car_prop_lib.get_skill_buff_value( self , "random_work_gl" , tar_condition_value )

		if basefunc.compare_value( random , real_condition_value , tar_judge_type ) then
			return true
		end

	end


	return false
end

---- 获取 技能目标
function C:get_skill_target(_skill_target , _arg_table)
	if _skill_target == "owner_obj" then
		return { self.owner }
	elseif _skill_target == "trigger_obj" then
		return { _arg_table.trigger }
	elseif _skill_target == "owner_enemy" then
		---- 
		local target = PUBLIC.get_game_obj_by_type( self.d , self.owner , "enemy" )
		--dump(target , "xxx-------------------------target:")

		return target

	elseif _skill_target == "all_car" then
		return self.d.car_info

	elseif string.sub( _skill_target , 1 , 7 ) == "car_id_" then 
		local target = PUBLIC.get_game_obj_by_type( self.d , self.owner , _skill_target )
		return target
	elseif string.sub( _skill_target , 1 , 11 ) == "not_car_id_" then 
		local target = PUBLIC.get_game_obj_by_type( self.d , self.owner , _skill_target )
		return target
	elseif _skill_target == "system" then
		return { self.d.system_obj }

	elseif _skill_target == "owner_car" then
		local car_info = PUBLIC.get_car_info_by_data( self.d , self.owner)

		return { car_info }
	elseif _skill_target == "enemy_car" then
		local car_info = PUBLIC.get_car_info_by_seat( self.d , ( (self.owner.seat_num == 1) and 2 or 1) )

		return { car_info }

	----
	elseif _skill_target == "owner_player" then
		local p_info = PUBLIC.get_player_info_by_data( self.d , self.owner)

		return { p_info }
		
	end

	----- 执行代码
	if _skill_target and type(_skill_target) == "string" then
		local tar_code = "return " .. _skill_target
		local _env = { P = PUBLIC , owner = self.owner , _d = self.d }
		local ok , func = xpcall( load , basefunc.error_handle , tar_code , nil , "t" , _env)

		if ok and func and type(func) == "function" then
			local targets = func()

			if targets and type(targets) == "table" then
				return targets
			end
		end
	end


	return {}
end

---- 处理 work
function C:deal_real_work( _run_obj_id , _work_target)
	print("xxxx-------------common_task__deal_real_work_1:" , _run_obj_id , _work_target)

	local data = { owner = _work_target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no }

	PUBLIC.run_obj_create_factory( self.d , _run_obj_id , data )

end

------ 主动出发技能，只触发 trigger_msg 是 zhudong 的技能
function C:trigger_zhudong_skill()
	if self.config and self.config.work_module then
		for key,data in ipairs(self.config.work_module) do
			repeat

			if data.trigger_msg == "zhudong" then
				self:deal_work( data , { trigger = self.owner } )
			end

			until true
		end
	end
end

----- 当技能改变 
function C:on_skill_change( _father_process_no )
	local process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
		skill_change = {
			owner_data = PUBLIC.get_game_owner_data( self.owner )  ,

			skill_data = DATA.game_info_center.get_one_skill_data( self ) , 
		} } , _father_process_no
	)
	return process_no
end


------------------  处理 生命周期的消息监听
function C.msg_table:round_start( _arg_table ) 
	local self = self.self

	print("xxxx--------------------------common_skill__round_start:",self.id,self.life_value)
	self:deal_skill_life_data( "round_num" )

end



return C

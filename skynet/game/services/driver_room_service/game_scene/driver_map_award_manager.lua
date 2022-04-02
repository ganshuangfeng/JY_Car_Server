
local basefunc = require "basefunc"
local base=require "base"
local skynet = require "skynet_plus"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA
local C = basefunc.create_hot_class("driver_map_award_manager")

local map_award_create_lib = require ("driver_room_service.game_scene.map_award_create_lib")

--[[
	格子种类
		3_c_1  N选1      带随机库,随机库可以自带规则
		2_c_1 2选1
	 	random 随机     带随机库,随机库可以自带规则，非具体显示
		clear           固定的种类

	award 包装格式
	{	
		road_award_type              道路 的 大 奖励  
		road_award_create_type       道路的奖励 创建类型

		award_library_type	         奖励库的选择 类型
		award_library_data           奖励库数据
				
		award_list
		{
			award_type = prop   # 奖励 skill or prop
			award_id
			award_level
		}
	}
--]]

C.msg_table = {}

function C:ctor(_d , _map_award_cfg )
	self.d = _d

	self.d.single_obj["driver_map_award_manager"] = self
	--- 配置
	self.map_award_cfg = _map_award_cfg

	--dump(_map_award_cfg , "xxxx----------------_map_award_cfg:")

	---- 首次创建 clear 类型的奖励 的最终数组
	self.first_clear_award_vec = {  }

	----- 监听消息
	PUBLIC.add_msg_listener( _d , self , C.msg_table )

	---- 上一次的 过程id （触发路面奖励的id）
	self.last_process_no = nil

	---- 奖励创建 事件 列表
	self.award_refresh_event = {}
	---- 奖励事件的配置
	--self.award_refresh_event_cfg = nil

	-- 道具发放事件
	self.tool_award_event = {}


	----- 奖励刷新配置
	self.cehua_map_award_cfg = nil

	----- normal 类型的道路的表 , key = index , value = road_id
	self.normal_road_vec = {}
	----- normal 类型的道路的奖励表，key = index , value = { type_id = xx  }
	self.normal_award_vec = {}

	------ 测试的 强制的奖励 , key = road_id , value = type_id
	self.debug_force_award = {
	}

	----轮次开始的次数
	self.round_start_num = 0

	self:init()

end

function C:init()
	--- 地图奖励配置
	self.cehua_map_award_cfg = DATA.map_road_award_lib[ self.d.map_id ]

	--self.award_refresh_event_cfg = self.cehua_map_award_cfg.road_refresh_event
	---- 设置固定先手
	print("xxxx-------------force_set_first_player_seat 111 :" , self.cehua_map_award_cfg.first_player_seat )
	if self.cehua_map_award_cfg.first_player_seat then
		print("xxxx-------------force_set_first_player_seat 222 :" , self.cehua_map_award_cfg.first_player_seat )
		self.d.game_dis_system:force_set_first_player_seat( self.cehua_map_award_cfg.first_player_seat )
	end
	---- 处理 固定移动list
	self:deal_fix_move_list( self.cehua_map_award_cfg.fix_move_list )

	self.normal_road_vec = self:get_first_nor_award_road_id()
	---- 初始化刷新事件
	self:init_award_refresh_event( self.cehua_map_award_cfg.road_refresh_event )

	self:init_tool_award_event( self.cehua_map_award_cfg.tool_award_event )

	----- 处理初始化的奖励 规则
	--if not skynet.getcfg("is_open_drive_move_test") then
	self:deal_first_clear_award_new()
	--end
	---- 创建 初始化的奖励
	self:create_first_map_award( )
end

function C:destroy()
	self.d.single_obj["driver_map_award_manager"]=nil
	PUBLIC.delete_msg_listener( _d , self )
end

---- 初始化 固定移动配置
function C:deal_fix_move_list( _fix_move_list )
	if not _fix_move_list or type(_fix_move_list) ~= "table" then
		return 
	end

	for key,data in ipairs(_fix_move_list) do
		self.d.test_move_list[#self.d.test_move_list + 1] = data.move_step

		---- 处理 nor_op 的强制操作
		if data.youmen_type == "big" then
			--self.d.debug_nor_op_permit[ DATA.player_op_type.big_youmen ] = true

			self.d.debug_nor_op_permit[#self.d.debug_nor_op_permit + 1] = { [ DATA.player_op_type.big_youmen ] = true }
		elseif data.youmen_type == "small" then
			--self.d.debug_nor_op_permit[ DATA.player_op_type.small_youmen ] = true

			self.d.debug_nor_op_permit[#self.d.debug_nor_op_permit + 1] = { [ DATA.player_op_type.small_youmen ] = true }
		end
	end

	dump(self.d.test_move_list , "xxxx--------------------self.d.test_move_list:")

end

--拿到刚开始road_type为normal的格子id
function C:get_first_nor_award_road_id()
	local award_lib = self.map_award_cfg
	local cfg = {}
	for key,data in pairs (award_lib) do
		if data.road_award_type == "normal" then
			cfg[#cfg+1] = key
		end
	end
	return cfg
end


function C:create_first_map_award( )
	for _,data in pairs( self.map_award_cfg ) do
		if data.road_award_type ~= "normal" then
			local road_type_id_map = DATA.road_award_type_id_map  -- self.cehua_map_award_cfg.road_award_type_id_map
			local road_id = data.road_id
			if road_type_id_map and road_type_id_map[data.road_award_type] then
				local type_id = road_type_id_map[data.road_award_type].type_id
				self.d.map_road_award[ road_id ] = self:create_grid_new( road_id , type_id )
			end
		end
	end

	dump(self.normal_road_vec , "xxxxx--------------------self.normal_road_vec:")
	dump(self.normal_award_vec , "xxxxx--------------------self.normal_award_vec:")

	---- 把奖励，随机分配 到各个normal类型的位置上
	if self.normal_road_vec and type(self.normal_road_vec) == "table" and self.normal_award_vec and type(self.normal_award_vec) == "table" then
		local normal_road_vec = basefunc.deepcopy(self.normal_road_vec)

		for key,award_data in ipairs(self.normal_award_vec) do
			local road_id = nil

			----支持直接给的特定位置
			if award_data.road_id then
				road_id = award_data.road_id

				---- 的把 正常里面的 删掉
				for _key , _road_id in pairs(normal_road_vec) do
					if _road_id == road_id then
						table.remove( normal_road_vec , _key )
						break
					end
				end

			else
				local r_index = math.random( #normal_road_vec )
				road_id = normal_road_vec[r_index]
				table.remove( normal_road_vec , r_index )
			end	

			local type_id = award_data.type_id

			---- 初始化的时候用测试配置
			if self.debug_force_award and self.debug_force_award[road_id] then
				type_id = self.debug_force_award[road_id]
			end

			self.d.map_road_award[ road_id ] = self:create_grid_new( road_id , type_id )
		 
		end
	end
	

end

function C:create_grid_new( _road_id , _type_id )
	local create_type = "skill"

	if self.cehua_map_award_cfg and self.cehua_map_award_cfg.mapAward_createInfo_cfg then
		local tar_data = self.cehua_map_award_cfg.mapAward_createInfo_cfg

		create_type = tar_data[_type_id] and tar_data[_type_id]["create_type"] or create_type

	end

	local data = {
		road_id = _road_id ,
		road_award_type = self.map_award_cfg[_road_id].road_award_type ,
		type_id = _type_id ,
		create_type = create_type ,
	}

	self.d.running_data_statis_lib.add_game_data( self.d , {
			road_award_change = {
				road_id = _road_id ,
				data_type = 1 ,
				road_award_data = data,
			} } , self.last_process_no
		)

	return data
end

---------------------------------------------------------------------------- 奖励创建事件 & 道具发放事件 ↓ -----------------------------------------------------------------

---- 初始化 创建奖励 事件
function C:init_award_refresh_event( _event_cfg )
	self.award_refresh_event = {}
	if _event_cfg and type(_event_cfg) == "table" then
		for key , data in pairs( _event_cfg ) do 
			self.award_refresh_event[data.event_key] = self.award_refresh_event[data.event_key] or {}
			local tar_data = self.award_refresh_event[data.event_key]

			local _data_copy = basefunc.deepcopy( data )

			----- 处理事件参数
			if _data_copy.event_key == "round_delay" then
				if _data_copy.event_data and type(_data_copy.event_data) == "number" then
					---- 延迟数量
					_data_copy.round_delay_num = _data_copy.event_data
					_data_copy.round_delay_count = 0
				end

			end

			tar_data[#tar_data + 1] = _data_copy
		end
	end

	dump(self.award_refresh_event , "xxxx------------self.award_refresh_event:")
end

----- 当 创建 事件 触发
function C:on_award_create_event( _event_name )
	if self.award_refresh_event and self.award_refresh_event[_event_name] then
		for key, event_data in pairs(self.award_refresh_event[_event_name]) do
			print("xxx------------on_award_create_event:" , _event_name)
			self:on_one_award_create_event( event_data )
		end
	end
end
---- 当触发 一个 奖励事件
function C:on_one_award_create_event( _event_data )
	if _event_data.event_key == "round_delay" then
		print("xxx------------on_one_award_create_event:" , _event_data.event_key )
		_event_data.round_delay_count = _event_data.round_delay_count + 1
		if _event_data.round_delay_count >= _event_data.round_delay_num then
			_event_data.round_delay_count = 0

			self:deal_one_award_create_event( _event_data )
		end
	else
		self:deal_one_award_create_event( _event_data )
	end
end

------ 处理一个 创建 事件
function C:deal_one_award_create_event( _event_data )
	print("xxx------------deal_one_award_create_event 1:" )
	local refresh_num = _event_data.refresh_num
	local for_select_vec = {}

	if _event_data.refresh_type == "fill_empty" then
		for i = 1 , self.d.map_length do
			if not self.d.map_road_award[i] then
				for_select_vec[#for_select_vec + 1] = i
			end
		end
	elseif _event_data.refresh_type == "replace" then
		for i = 1 , self.d.map_length do
			------ 讲道理 ，只能换 普通的
			if self.map_award_cfg[i] and self.map_award_cfg[i].road_award_type == "normal" then
				for_select_vec[#for_select_vec + 1] = i
			end
		end
	end

	------ 先用， 用威哥写的 刷新规则 生产出n 个
	local real_award_vec = nil
	if _event_data.mapAward_refresh_rule and _event_data.mapAward_refresh_cfg then
		local rule_func = map_award_create_lib[_event_data.mapAward_refresh_rule]

		if rule_func and type(rule_func) == "function" then
			real_award_vec = rule_func( basefunc.deepcopy( _event_data.mapAward_refresh_cfg ) , refresh_num , PUBLIC.get_type_id_sum(self.d) )
		end
	end

	--dump(real_award_vec , "xxxx----------------------real_award_vec::")

	---- 再把这 n 个 填入
	for i = 1, refresh_num do
		if not real_award_vec or type(real_award_vec) ~= "table" or not next(real_award_vec) then
			break
		end

		----- 如果没有位置
		print("xxx------------deal_one_award_create_event 2:" )
		if not next(for_select_vec) then
			break
		end
		---- 先确定是哪个位置
		local tar_rand_inx = math.random(#for_select_vec)
		local tar_road_id = for_select_vec[ tar_rand_inx ]
		table.remove( for_select_vec , tar_rand_inx )

		------ 如果有 奖励，先删除
		if self.d.map_road_award[tar_road_id] then
			self:delete_map_award( tar_road_id )
		end

		----- 再选一个 奖励
		local r_index = math.random(#real_award_vec)
		local tar_data = real_award_vec[r_index]
		table.remove( real_award_vec , r_index )

		--dump(tar_data , "xxxx----------------------tar_data::")

		--dump(self.d.debug_next_map_award , "xxx------------------- debug_next_map_award 111111")
		----- 创建一个
		if self.d.debug_next_map_award and next(self.d.debug_next_map_award) then
			--dump(self.d.debug_next_map_award , "xxx------------------- debug_next_map_award 11")
			local type_id = self.d.debug_next_map_award[1]
			table.remove( self.d.debug_next_map_award , 1)

			--dump(self.d.debug_next_map_award , "xxx------------------- debug_next_map_award 22")

			self.d.map_road_award[ tar_road_id ] = self:create_grid_new( tar_road_id , type_id )
		else
			self.d.map_road_award[ tar_road_id ] = self:create_grid_new( tar_road_id , tar_data.type_id )
		end
	end


end
--------------------------------------------------------------------------------------------------------------------- 刷新事件 ↑  道具发放事件 ↓
---- 初始化 道具发放 事件
function C:init_tool_award_event( _event_cfg )
	self.tool_award_event = {}
	if _event_cfg and type(_event_cfg) == "table" then
		for key , data in pairs( _event_cfg ) do 
			self.tool_award_event[data.event_key] = self.tool_award_event[data.event_key] or {}
			local tar_data = self.tool_award_event[data.event_key]

			local _data_copy = basefunc.deepcopy( data )

			----- 处理事件参数
			if _data_copy.event_key == "round_delay" then
				if _data_copy.event_data and type(_data_copy.event_data) == "number" then
					---- 延迟数量
					_data_copy.round_delay_num = _data_copy.event_data
					_data_copy.round_delay_count = 0
				end
			elseif _data_copy.event_key == "on_road_pass" then
				if _data_copy.event_data and type(_data_copy.event_data) == "number" then
					---- 经过的百分比
					_data_copy.pass_percent = _data_copy.event_data
				end
			end

			---- 道具发放的限制数据
			_data_copy.limit_data = {
				--[[
				total_trigger_num = 0,
				--]] 
			}

			tar_data[#tar_data + 1] = _data_copy
		end
	end

	dump(self.tool_award_event , "xxxx------------self.tool_award_event:")
end

----- 当 创建 事件 触发
function C:on_tool_award_event( _event_name , _arg_table )
	if self.tool_award_event and self.tool_award_event[_event_name] then
		for key, event_data in pairs(self.tool_award_event[_event_name]) do
			print("xxx------------on_tool_award_event:" , _event_name)
			self:on_one_tool_award_event( event_data , _arg_table )
		end
	end
end
---- 当触发 一个 奖励事件
function C:on_one_tool_award_event( _event_data , _arg_table )
	---- 每隔n 回合
	if _event_data.event_key == "round_delay" then
		print("xxx------------on_one_tool_award_event:" , _event_data.event_key )
		_event_data.round_delay_count = _event_data.round_delay_count + 1
		if _event_data.round_delay_count >= _event_data.round_delay_num then
			_event_data.round_delay_count = 0

			self:deal_one_tool_award_event( _event_data , _arg_table )
		end
	---- 经过 路程的 % 多少
	elseif _event_data.event_key == "on_road_pass" then
		local old_pecent = _arg_table.old_pos / ( self.d.map_length * self.d.map_game_over_circle )
		local now_pecent = _arg_table.now_pos / ( self.d.map_length * self.d.map_game_over_circle )

		local tar_pecent = _event_data.pass_percent / 100

		if old_pecent < tar_pecent and now_pecent >= tar_pecent then
			print("xxxx----------------------on_road_pass__tar_pecent:" , tar_pecent )
			self:deal_one_tool_award_event( _event_data , _arg_table )
		end

	else
		self:deal_one_tool_award_event( _event_data , _arg_table )
	end
end

------ 处理一个 道具发放 事件
function C:deal_one_tool_award_event( _event_data , _arg_table )
	print("xxx------------deal_one_tool_award_event 1:" )
	
	----- 判断 道具发放数量限制
	local limit_data = _event_data.limit_data
	--- 已经 发放的次数
	local total_trigger_num = limit_data.total_trigger_num or 0

	if total_trigger_num >= _event_data.trigger_limit then
		return
	end
	limit_data.total_trigger_num = (limit_data.total_trigger_num or 0) + 1

	local award_cfg = _event_data.award_rule_data

	----- 对 所有的车发放 对应奖励
	for car_no , car_data in pairs( self.d.car_info ) do
		local car_award_cfg = award_cfg and award_cfg[ car_data.id ]

		if car_award_cfg then
			---- 发放道具奖励
			self:deal_award_tool( car_award_cfg , car_data , car_award_cfg.award_num )
		end

	end

end

---------------------------------------------------------------------------- 奖励创建事件 & 道具发放事件 ↑ -----------------------------------------------------------------

----- 加攻，加速，加血要先于技能触发
function C.msg_table:position_relation_stay_road_award_before( _arg_table )

	local arg_table = _arg_table
	local is_double = false

	------- 
	self.d.game_run_system:create_delay_func_obj(function() 
		------ 如果不能获取道具
		if PUBLIC.get_tag( arg_table.trigger , "is_canot_get_map_award" ) then
			
			return
		end


		local trigger_car_pos = arg_table.trigger and arg_table.trigger.pos 

		----- 如果是先触发的就不管
		local road_id = PUBLIC.get_grid_id( trigger_car_pos , self.d.map_length )
		local map_road_award = self.d.map_road_award[road_id]
		if map_road_award and not DATA.first_award_map_type_id[ map_road_award.type_id ] then
			return
		end

		if PUBLIC.get_tag( arg_table.trigger , "double_award" ) then
			is_double = true
		end
		--双倍资源卡监听发奖
		PUBLIC.trriger_msg( self.d , "use_grid_award_before" , { trigger = arg_table.trigger , seat_num = arg_table.seat_num})

		self:use_grid_award( trigger_car_pos , trigger_car_pos , arg_table.trigger ,is_double)
	end)


end

----- 监听消息
function C.msg_table:position_relation_stay_road_award_after( _arg_table )
	
	----- 地图发奖，如果是 冲刺则不发奖
	--local move_type_tag = PUBLIC.get_tag( _arg_table.trigger , "move_type_sprint" )
	--if move_type_tag then
	--	return
	--end

	local arg_table = _arg_table
	local is_double = false

	------- 
	self.d.game_run_system:create_delay_func_obj(function() 
		------ 如果不能获取道具
		if PUBLIC.get_tag( arg_table.trigger , "is_canot_get_map_award" ) then
			
			return
		end


		local trigger_car_pos = arg_table.trigger and arg_table.trigger.pos 

		----- 如果是先触发的就不管
		local road_id = PUBLIC.get_grid_id( trigger_car_pos , self.d.map_length )
		local map_road_award = self.d.map_road_award[road_id]
		if map_road_award and DATA.first_award_map_type_id[ map_road_award.type_id ] then
			return
		end

		if PUBLIC.get_tag( arg_table.trigger , "double_award" ) then
			is_double = true
		end
		--双倍资源卡监听发奖
		PUBLIC.trriger_msg( self.d , "use_grid_award_before" , { trigger = arg_table.trigger , seat_num = arg_table.seat_num})

		self:use_grid_award( trigger_car_pos , trigger_car_pos , arg_table.trigger ,is_double)
	end)

	
end

function C.msg_table:round_start_before( _arg ) 
	self.round_start_num = self.round_start_num + 1

	----- 附加上车辆的id 参数
	local car_info = PUBLIC.get_car_info_by_data( self.d , self.d.p_info[ _arg.seat_num ] )
	local car_id = car_info and car_info.id or nil

	local arg_tem = basefunc.deepcopy( _arg )
	arg_tem.car_id = car_id


	self:on_award_create_event( "round_delay" , arg_tem)

	self:on_tool_award_event( "round_delay" , arg_tem )
end

---- 当经过路程
function C.msg_table:position_road_pass(_arg)
	print("xxxx-----------position_road_pass:")
	self:on_tool_award_event( "on_road_pass" , _arg )
end

----- 处理 伦次开始 ，发放 道具
function C:deal_award_tool( _award_cfg , _trigger_car , _award_num )
	print("xxx-----------deal_award_tool: 1")
	local seat_num = _seat_num

	self.d.game_run_system:create_delay_func_obj(function() 
		self.last_process_no = nil

		---- 处理给 这个轮次的车发奖
		local car_info = _trigger_car
		local trigger_pos = car_info.pos

		if car_info then
			--- 回合奖励
			local car_huihe_award = _award_cfg

			local lib_is_only = true        						--- 是否是从 库的第一个选项出来
			local award_create_rule = car_huihe_award.award_create_rule or "zjUse_Nc1_by_item_refresh"   ------ 从库中出来的 规则，默认就是随机出

			---- 调用对应的出库程序
			local award_create_func = map_award_create_lib[ award_create_rule ]
			local final_award_vec = {}
			local create_group_need = {}

			if award_create_func and type(award_create_func) == "function" then
				final_award_vec = award_create_func( car_huihe_award.group_data , _award_num or 1 , lib_is_only , create_group_need ) -- _trigger_car.lib_type_id_num_map or {} )
			end

			dump( final_award_vec , "xxx-----------deal_award_tool: 2" )

			----- 从库中 根据 规则选出来的奖励列表
			if final_award_vec and type(final_award_vec) == "table" and next(final_award_vec) then
				for key, data in pairs(final_award_vec) do
					--- 从库中出来奖励 默认是 直接用
					data.create_type = data.create_type or "prop"  
					self:create_map_award( data , trigger_pos , car_info , false)
				end
			end

		end

	end)
end


----- 发放奖励
function C:use_grid_award(_road_id , _trigger_pos , _trigger_car , is_double)
	print("xxx---------------use_grid_award:" , _road_id , _trigger_car )
	local road_id = PUBLIC.get_grid_id( _road_id , self.d.map_length )
	--if self.d.map_road_award_useTime[road_id] 
	--	and self.d.map_road_award_useTime[road_id] > 0
	--	and self.d.map_road_award[road_id] then

	if self.d.map_road_award[road_id] then
		local data = self.d.map_road_award[road_id]

		self.last_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
			road_award_change = {
				pos = _trigger_pos,
				road_id = road_id ,
				data_type = 3 ,
				road_award_data = data,
			} }
		)

		if not DATA.can_double_award[ data.type_id ] then
			is_double = false
		end

		self:create_map_award( self.d.map_road_award[road_id] , _trigger_pos , _trigger_car , is_double)

		---- 发完将之后，发一个 发放完毕消息
		PUBLIC.trriger_msg( self.d , "on_grid_award_after" , { trigger = _trigger_car , _trigger_pos = _trigger_pos , type_id = data.type_id  })

		----- 如果是 normal 类型的 得删除 
		if data.road_award_type == "normal" then
			self:delete_map_award( road_id , self.last_process_no )
		end


		return 
	end

end

----
function C:delete_map_award( _road_id , _father_process_no )
	local data = self.d.map_road_award[_road_id]
	------ 统计过程数据
	self.d.running_data_statis_lib.add_game_data( self.d , {
		road_award_change = {
			road_id = _road_id ,
			data_type = 2 ,
			road_award_data = data,
		} } , _father_process_no
	)

	self.d.map_road_award[_road_id] = nil
end


function C:deal_first_clear_award_new()
	local init_rule = self.cehua_map_award_cfg.mapAward_init_rule
	local init_cfg = basefunc.deepcopy( self.cehua_map_award_cfg.mapAward_init_cfg )
	local init_func = map_award_create_lib[ init_rule ]


	if init_func and type(init_func) == "function" then
		self.normal_award_vec = init_func( init_cfg , #self.normal_road_vec  )

		--- 先处理 有 road_id 的
		table.sort( self.normal_award_vec , function(a , b) 
			return a.road_id and not b.road_id
		end )
	end
end


------- 地图的创建中心
function C:create_map_award( _map_award , _trigger_pos , _trigger_car , is_double)
	----- 特殊路面奖励，不能直接创建
	print("xxxx---------------create_map_award:" , _map_award.type_id , _map_award.create_type )

	if _map_award.create_type == "skill" then
		self:create_skill_award(_map_award , _trigger_pos , _trigger_car , is_double)
	elseif _map_award.create_type == "prop" then
		---- 先找到 对应的 道具id
		local tool_id = PUBLIC.get_tool_id_by_type_id(_map_award.type_id)
		----双倍奖励
		local num = 1
		local extra_num = 0

		local award_extra_num_name = DATA.can_double_award_type_id_to_award_extra_num_name[_map_award.type_id] or nil
		if award_extra_num_name then
			extra_num = DATA.car_prop_lib.get_car_prop( _trigger_car , award_extra_num_name )
		end
		--extra_num = DATA.car_prop_lib.get_car_prop( _trigger_car , "tool_award_extra_num" )
		num = num + extra_num
		if tool_id then
			if is_double then
				num = num + 1
			end
			for i=1,num do
				PUBLIC.create_tools( self.d , _trigger_car.seat_num , tool_id , self.last_process_no )
			end
		end
	end


end

---- 获取group对象的lib , 通过 type_id , 车 id 就能唯一确定一个库
function C:get_map_award_lib( _type_id , _car_id )
	local lib = nil
	if self.cehua_map_award_cfg and self.cehua_map_award_cfg.groupObj_gourp_cfg then
		local tar_data = self.cehua_map_award_cfg.groupObj_gourp_cfg

		lib = tar_data[_type_id] and tar_data[_type_id][_car_id]
	end
	
	return lib
end

function C:get_map_award_create_info(_type_id)
	local create_info = nil
	if self.cehua_map_award_cfg and self.cehua_map_award_cfg.mapAward_createInfo_cfg then
		local tar_data = self.cehua_map_award_cfg.mapAward_createInfo_cfg

		create_info = tar_data[_type_id]
	end
	
	return create_info
end

------ 统计 从库里面出来的 type_id 的数量
function C:statis_car_lib_type_id_num( _car_obj , _type_vec )
	if _car_obj and _type_vec and type(_type_vec) == "table" then
		_car_obj.lib_type_id_num_map = _car_obj.lib_type_id_num_map or {}
		local tar_data = _car_obj.lib_type_id_num_map

		for key,data in pairs(_type_vec) do
			if data.type_id then
				tar_data[data.type_id] = (tar_data[data.type_id] or 0) + 1
			end
		end
	end
end

---- 获取创建 group 奖励时，需要的 统计数据
function C:get_create_group_data_need( _trigger_car )
	local tar_data = {}

	----- 从库中 random  or  3_c_1 中出来的 type_id 对应 num 的 map
	tar_data.lib_type_id_num_map = _trigger_car.lib_type_id_num_map or {}
	----- 这个人有的道具 的 type_id 对应 num 的map
	tar_data.tool_type_id_map = PUBLIC.get_tool_type_id_map( self.d , _trigger_car.seat_num)

	-----
	tar_data.system_now_skill_id_map = {}
	if self.d.system_obj and self.d.system_obj.skill then
		for skill_id , skill_obj in pairs(self.d.system_obj.skill) do
			tar_data.system_now_skill_id_map[skill_id] = true
			
		end
	end



	return tar_data
end

------ 创建直接释放的奖励,
function C:create_skill_award(_map_award , _trigger_pos , _trigger_car , is_double)
	print("xxxx=--------------- create_skill_award ")
	----- 特殊路面奖励类型 和 奖励id ，从指定库中拿配置
	local lib = self:get_map_award_lib( _map_award.type_id , _trigger_car.id )
	dump(lib , "xxxxx---------- create_skill_award lib 1")
	----- 拿到库之后，通过筛选规则筛选
	if lib and next(lib) and lib.group_data then
		dump(lib , "xxxxx---------- create_skill_award lib 2")
		---- 获取如果从库中出来的信息
		local create_info = self:get_map_award_create_info( _map_award.type_id )

		---- 默认数据
		local select_num = 1            --- 从库中选择多少个出来 , random 默认是1
		local choose_type = "random"    --- 从库中出来的方式，random , 3_c_1 , 3_c_1_fl 等
		local lib_is_only = true        --- 是否是从 库的第一个选项出来
		local award_create_rule = "zjUse_Nc1_by_item_refresh"   ------ 从库中出来的 规则，默认就是随机出
		local create_group_need = self:get_create_group_data_need( _trigger_car )

		if create_info then
			choose_type = create_info.choose_type

			if string.find( create_info.choose_type , "^%d+_c_1" ) then
				local _s,_e , _n = string.find( create_info.choose_type , "^(%d+)_c_1" )
				select_num = _n
			end

			----- 是从分项 库中创建
			if  string.find( create_info.choose_type , "^%d+_c_1_fl" ) then
				lib_is_only = false
			end

			if create_info.award_create_rule and type(create_info.award_create_rule) == "string" then
				award_create_rule = create_info.award_create_rule
			end
		end
		
		----------- 根据规则 处理过滤
		--for key, group_data in pairs(lib.group_data) do
		--	---- 每一组都处理过滤
		--end

		----- 处理随机选
		if create_info.choose_type == "random" then

			local award_extra_num_name = DATA.can_double_award_type_id_to_award_extra_num_name[_map_award.type_id] or nil
			local extra_num = 0
			if award_extra_num_name then
				extra_num = DATA.car_prop_lib.get_car_prop( _trigger_car , award_extra_num_name )
			end
			local num = 1 + extra_num
			if is_double then
				num = num + 1 
				is_double = false
			end

			for i=1, num do
				print("xxx----------------- create_info.choose_type___random 1")
				local award_create_func = map_award_create_lib[ award_create_rule ]
				local final_award_vec = {}

				if award_create_func and type(award_create_func) == "function" then
					final_award_vec = award_create_func( lib.group_data , select_num , lib_is_only , create_group_need ) -- _trigger_car.lib_type_id_num_map or {} )
				end
				dump( final_award_vec , "xxx----------------- create_info.choose_type___random 2")
				---- 统计从库里面出来的 type_id 数量
				self:statis_car_lib_type_id_num( _trigger_car , final_award_vec )

				----- 从库中 根据 规则选出来的奖励列表
				if final_award_vec and type(final_award_vec) == "table" and next(final_award_vec) then
					for key, data in pairs(final_award_vec) do
						--- 从库中出来奖励 默认是 直接用
						data.create_type = create_info.context_type or data.create_type or "skill"  
						self:create_map_award( data , _trigger_pos , _trigger_car ,is_double)
					end
				end
			end

			return
		end

		----- 处理 3_c_1
		if string.find( create_info.choose_type , "^%d+_c_1" ) then
			local real_vec = {}

			local award_create_func = map_award_create_lib[ award_create_rule ]
			local final_award_vec = {}

			if award_create_func and type(award_create_func) == "function" then
				final_award_vec = award_create_func( lib.group_data , select_num , lib_is_only , create_group_need ) --  _trigger_car.lib_type_id_num_map or {} )
			end
			dump(final_award_vec , "xxxxx--------------------final_award_vec 11")
			---- 统计从库里面出来的 type_id 数量
			self:statis_car_lib_type_id_num( _trigger_car , final_award_vec )

			----- 从库中 根据 规则选出来的奖励列表
			if final_award_vec and type(final_award_vec) == "table" and next(final_award_vec) then
				for key, data in pairs(final_award_vec) do
					--- 从库中出来奖励 默认是 直接用
					data.create_type = create_info.context_type or data.create_type or  "skill"  
				end
			end

			local data = { owner = _trigger_car ,
				level = 1 , 
				obj_enum = "n_select_1_map_award_obj",
				select_lib = final_award_vec ,
				select_num = select_num,
				is_double = is_double,
				father_process_no = self.last_process_no ,
			}
			local run_obj = PUBLIC.create_obj( self.d , data )
			if run_obj then
				---- 加入 运行系统
				self.d.game_run_system:create_add_event_data( run_obj , 1 , "next")
			end

			return 
		end

	else
		------ 处理简单 奖励
		local sample_award_map = DATA.sample_award_map -- self.cehua_map_award_cfg.sample_award_map

		if _map_award.type_id and sample_award_map[_map_award.type_id] then
			local type_id = _map_award.type_id
			local skill_id = sample_award_map[_map_award.type_id].skill_id
			local extra_num = 0

			local award_extra_num_name = DATA.can_double_award_type_id_to_award_extra_num_name[_map_award.type_id] or nil
			if award_extra_num_name and award_extra_num_name ~= "n2o_award_extra_num" then  --- 冲刺不在这里处理
				extra_num = DATA.car_prop_lib.get_car_prop( _trigger_car , award_extra_num_name )
			end
			local num = 1 + extra_num
			print("kkkkkkkkk ",num)
			if skill_id then
				if is_double then
					num = num + 1
				end
				for i=1,num do
					local data={
							owner = _trigger_car,
							father_process_no = self.last_process_no ,
						}
					PUBLIC.skill_create_factory(self.d , skill_id , data)
				end
			end
		end
		---直接对应上，之前的逻辑
		return 
	end


end






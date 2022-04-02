require "normal_enum"
local skynet = require "skynet_plus"
require "skynet.manager"
require"printfunc"
local nodefunc = require "nodefunc"
local base=require "base"
local basefunc = require "basefunc"

require "driver_room_service.game_scene.object.youmen_obj"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

---- 根据 真实位置 获得 所在 格子数
function PUBLIC.get_grid_id(pos,road_len)
	pos = pos % road_len
	if pos==0 then
		pos=road_len
	end
	return pos
end

function PUBLIC.get_grid_id_quick(_d , pos)
	return PUBLIC.get_grid_id(pos, _d.map_length )
end

----- 处理 run_obj 和 buff 的叠加规则
function PUBLIC.deal_run_obj_buff_overlay_rule(self)
	if self and self.overlay_rule and type(self.overlay_rule) == "table" then
		for key , rule in pairs( self.overlay_rule ) do
			if type(self[key]) == "function" then
				error("xxxx--------deal_run_obj_buff_overlay_rule is function:" .. key)
			end
			if self[key] and self.config[key] and self.skill and self.skill.overlay_num then
				self[key] = PUBLIC.deal_overlay_rule( self[key] , self.config[key] , rule , self.skill.overlay_num )
			end
		end
	end
end

------- 执行叠加规则
--[[
	_now_value          当前的值
	_org_value          原始值
	_overlay_rule       叠加规则
	_now_overlay_num    当前叠加层数
--]]
function PUBLIC.deal_overlay_rule( _now_value , _org_value , _overlay_rule , _now_overlay_num )
	local tar_value = _now_value
	if _overlay_rule == "nor_add" then
		tar_value = _now_value + ((_now_overlay_num > 0 ) and _org_value or 0 )
	elseif _overlay_rule == "overlay_bei" then 
		tar_value = _org_value * (_now_overlay_num + 1)
	elseif _overlay_rule == "reset" then
		tar_value = _org_value
	end

	return tar_value
end

------------------------------------------------------------------------------- 创建技能 ↓ ------------------------------------------------------------------------
---- 创建技能
function PUBLIC.create_skill( _d , _config , _data , ...)
	local skill_obj = nil

	--------- 做检查，owner 是否有相同的技能，如果有则调用刷新逻辑
	if _data.owner and _data.owner.skill and _data.owner.skill[_config.id] then
		-----如果可以叠加
		if _config.overlay_max then
			print("xxx----------------refresh_skill_ob:" , _config.id)
			local tar_skill_obj = _data.owner.skill[_config.id]
			if tar_skill_obj.refresh then
				tar_skill_obj:refresh( _data.father_process_no )
			end

			return "refresh"
		else
			---- 如果不可以叠加，直接删掉
			PUBLIC.delete_skill( _data.owner.skill[_config.id] )

		end

	end

	
	if _config and _config.skill_enum then
		local module_name = "driver_room_service.game_scene.skill." .. _config.skill_enum
		local ok,skill_protect = pcall( require , module_name)
		if ok and skill_protect then
			skill_obj = skill_protect.new( _d , _config , _data , ... )
		else
			print("xxx---------not require skill_obj:" , ok, skill_protect)
		end

		if skill_obj then
			skill_obj:init( _data.father_process_no )
		end
	end

	--dump(skill_obj , "xxxx-----------------------------create_skill:" .. _config.skill_enum )

	return skill_obj
end

----  _merge_config 是可以合并替换到 配置中的数据 
function PUBLIC.skill_create_factory( _d , _skill_id , _data , _merge_config )
	print("xxx------------------skill_create_factory:" , _d , _skill_id ,_data )

	---- 发出一个消息
	PUBLIC.trriger_msg( _d , "on_skill_create_factory_before" , { skill_id = _skill_id , trigger = _data.owner , seat_num = _data.owner.seat_num } )

	local config = DATA.skill_config[_skill_id]
	if not config then
		print("xxx------------error no skill_config for :",_skill_id)
		return nil
	end

	---- 先把 特殊数据合并
	local config_copy = basefunc.deepcopy( config )

	---- 拷贝之后，将 技能配置中的 $ 给转换了 ， 
	PUBLIC.convert_chehua_config( _d , config_copy , _skill_id , _data.owner and _data.owner.seat_num )

	if _merge_config and type(_merge_config) == "table" then
		config_copy = basefunc.merge( _merge_config , config_copy )
	end

	local _obj = PUBLIC.create_skill( _d , config_copy , _data )

	if _obj == "refresh" then
		print("xxxx----------------refresh skill_obj:",_skill_id)
		return nil
	end

	if not _obj then
		print("xxxx----------------not create skill_obj:",_skill_id)
		return nil
	end
	--------- 如果技能的主体类型不一致
	--if _data.owner and _data.owner.kind_type ~= config_copy.owner_type then    ---- 正式
	if _data.owner and config_copy.owner_type then
		local is_owner_type_right = false
		if type(config_copy.owner_type) ~= "table" and _data.owner.kind_type == config_copy.owner_type then
			is_owner_type_right = true
		end
		if type(config_copy.owner_type) == "table" then
			for k,v in pairs(config_copy.owner_type) do
				if _data.owner.kind_type == v then
					is_owner_type_right = true
					break
				end
			end
		end

		if not is_owner_type_right then
			error("xxxx----------------skill_owner_type___is_not_right:" .. _skill_id)
			return nil
		end
	end


	return _obj
end

---- 加技能
function PUBLIC.add_skill( _skill_obj , _father_process_no)
	local add_skill_no = nil

	if _skill_obj and _skill_obj.owner then
		_skill_obj.owner.skill = _skill_obj.owner.skill or {}
		_skill_obj.owner.skill[ _skill_obj.id ] = _skill_obj
	
		---- 统计技能创建数据
		_skill_obj.owner.skill_created_statis = _skill_obj.owner.skill_created_statis or {}
		_skill_obj.owner.skill_created_statis[ _skill_obj.id ] = ( _skill_obj.owner.skill_created_statis[ _skill_obj.id ] or 0 ) + 1

		---- 统计数据
		----- 收集数据 , 技能触发
		if not DATA.process_ignore_skill_key[ _skill_obj.config.key ] then
			add_skill_no = _skill_obj.d.running_data_statis_lib.add_game_data( _skill_obj.d , {
				skill_create = {
					owner_data = PUBLIC.get_game_owner_data(_skill_obj.owner) ,

					skill_data =  DATA.game_info_center.get_one_skill_data( _skill_obj ) ,

					skill_name = _skill_obj.config.name ,
					--pos = _skill_obj.owner.pos , 
				} } , _father_process_no
			)

		end
	end

	return add_skill_no
end

---- 删技能
function PUBLIC.delete_skill( _skill_obj )
	if _skill_obj and _skill_obj.owner then
		
		local process_no = nil
		----- 收集数据 , 
		if not DATA.process_ignore_skill_key[ _skill_obj.config.key ] then
			process_no = _skill_obj.d.running_data_statis_lib.add_game_data( _skill_obj.d , {
				skill_dead = {
					owner_data = PUBLIC.get_game_owner_data(_skill_obj.owner) ,

					skill_data =  DATA.game_info_center.get_one_skill_data( _skill_obj ) ,

					skill_name = _skill_obj.config.name ,
				} } 
			)
		end

		----- 销毁时，传入 技能死亡 process_no
		_skill_obj:destroy( process_no )

		_skill_obj.owner.skill = _skill_obj.owner.skill or {}
		_skill_obj.owner.skill[ _skill_obj.id ] = nil

		_skill_obj.owner = nil
	end
end

---- 获取技能
function PUBLIC.get_skill_by_id( _owner , _skill_id )
	if _owner and _owner.skill and _owner.skill[_skill_id] then
		return _owner.skill[_skill_id]
	end

	return nil
end

------------------------------------------------------------------------------- 创建技能 ↑ ------------------------------------------------------------------------

------------------------------------------------------------------------------- 创建 运行 obj ↓ ------------------------------------------------------------------------
--- 创建运行obj
function PUBLIC.create_obj(_d , _config , ...)
	local run_obj = nil

	if _config and _config.obj_enum then
		local module_name = "driver_room_service.game_scene.object." .. _config.obj_enum
		local ok,skill_protect = pcall( require , module_name)
		if ok and skill_protect then
			run_obj =  skill_protect.new( _d , _config , ... )
		else
			print("xxx---------not require run_obj:" , ok, skill_protect)
		end

		if run_obj then
			run_obj:init()
		end
	end

	--dump(run_obj , "xxxx-----------------------------create_skill:" .. _config.obj_enum )

	return run_obj
end

--[[
	data={
		name
		level
		owner_seat_num
		car_id
	}
--]]
function PUBLIC.run_obj_create_factory(_d , _run_obj_id , _data)
	print("xxx------------------run_obj_create_factory:" , _d , _run_obj_id ,_data )

	---- 发出一个消息
	PUBLIC.trriger_msg( _d , "on_run_obj_create_factory_before" , { run_obj_id = _run_obj_id , trigger = _data.owner } )

	local config = DATA.game_run_obj_config[_run_obj_id]
	if not config then
		print("xxx------------error no run_obj_id for :",_run_obj_id)
		return nil
	end

	---- 先把 特殊数据合并
	local config_copy = basefunc.deepcopy( config )

	---- 拷贝之后，将 obj配置中的 $ 给转换了 ， 
	PUBLIC.convert_chehua_config( _d , config_copy , DATA.work_id_2_skill_id_map[_run_obj_id] , _data.owner and _data.owner.seat_num )

	if _data then
		---- 用 _data  是可以替换 原来的 数据的
		config_copy = basefunc.merge( _data , config_copy )
	end

	----- 叠加规则，
	local overlay_rule = {}

	----- 在上层做配置数值转换 ( config中传入的值 一定是初始值， )
	for key,value in pairs( config_copy ) do
		local tar_value , tar_overlay_rule = PUBLIC.convert_arg_data(value )

		config_copy[key] = tar_value
		overlay_rule[key] = tar_overlay_rule
	end

	---- 最后赋值一下
	config_copy.overlay_rule = overlay_rule

	local run_obj = PUBLIC.create_obj( _d , config_copy )

	if not run_obj then
		print("xxxx----------------not create run_obj:",_run_obj_id)
		return nil
	end

	---- 加入 运行系统
	_d.game_run_system:create_add_event_data(
		run_obj , 1 , _data.obj_run_type or "next"
	) 

	return run_obj
end

------------------------------------------------------------------------------- 创建 运行 obj ↑ ------------------------------------------------------------------------

------------------------------------------------------------------------------- 创建 buff ↓ ------------------------------------------------------------------------
--- 创建运行obj
function PUBLIC.create_buff(_d , _config , ...)
	local obj = nil

	if _config and _config.buff_enum then
		local module_name = "driver_room_service.game_scene.buff." .. _config.buff_enum
		local ok,skill_protect = pcall( require , module_name)
		if ok and skill_protect then
			obj =  skill_protect.new( _d , _config , ... )
		else
			print("xxx---------not require buff obj:" , ok, skill_protect)
		end

		if obj and obj.init then
			obj:init( _config.father_process_no )
		end
	end

	--dump(obj , "xxxx-----------------------------create_skill:" .. _config.obj_enum )

	return obj
end

--------- 创建 buff
function PUBLIC.buff_obj_create_factory(_d , _buff_id , _data)
	print("xxx------------------create_buff:" , _d , _buff_id , _data )

	---- 发出一个消息
	PUBLIC.trriger_msg( _d , "on_buff_obj_create_factory_before" , { buff_id = _buff_id , trigger = _data.owner } )

	local config = DATA.game_buff_config[_buff_id]
	--if not config then
	--	print("xxx------------error no _buff_id for :",_buff_id)
	--	return nil
	--end

	---- 先把 特殊数据合并
	local config_copy = basefunc.deepcopy( config )

	---- 拷贝之后，将 buff 配置中的 $ 给转换了 ， 
	PUBLIC.convert_chehua_config( _d , config_copy , DATA.buff_id_2_skill_id_map[_buff_id] , _data.owner and _data.owner.seat_num )

	if _data then
		---- 用 _data  是可以替换 原来的 数据的
		config_copy = basefunc.merge( _data , config_copy )
	end

	----- 叠加规则，
	local overlay_rule = {}

	----- 在上层做配置数值转换
	for key,value in pairs( config_copy ) do
		--config_copy[key] = PUBLIC.convert_arg_data(value)

		local tar_value , tar_overlay_rule = PUBLIC.convert_arg_data(value )

		config_copy[key] = tar_value
		overlay_rule[key] = tar_overlay_rule
	end

	---- 最后赋值一下
	config_copy.overlay_rule = overlay_rule


	local buff_obj = PUBLIC.create_buff( _d , config_copy )

	if not buff_obj then
		print("xxxx----------------not create buff:",_buff_id)
		return nil
	end


	return buff_obj
end

----- 添加 buff
function PUBLIC.add_buff(_buff_obj , _father_process_no )
	local buff_type_replace = {
		car_hudun_buff = true,
	}

	--dump( _buff_obj , "xxxx-------add_buff 11")
	if _buff_obj and _buff_obj.owner then
		print("xxxx-------add_buff 22")
		----
		local buff_type = _buff_obj.config.buff_enum

		local owner = _buff_obj.owner

		owner.buff = owner.buff or {}
		owner.buff[ buff_type ] = owner.buff[ buff_type ] or {}
		local tar_vec = owner.buff[ buff_type ]

		----buff 顶掉逻辑，先按 buff_id 来顶掉
		for _index , buff_obj in pairs( tar_vec ) do
			if buff_obj.id == _buff_obj.id then
				table.remove( tar_vec , _index )
				--- 删掉对应的技能
				PUBLIC.delete_skill( buff_obj.skill )
				break
			end
		end
		-------------------
		---- 车辆护盾buff  , 要根据类型顶掉
		if tar_vec[1] and buff_type_replace[ buff_type ] then
			table.remove(tar_vec , 1)
		end
		
		tar_vec[#tar_vec + 1] = _buff_obj

		----- 收集数据 , 技能触发
		local process_no = nil
		if not _buff_obj.is_not_send_client then
			process_no = _buff_obj.d.running_data_statis_lib.add_game_data( _buff_obj.d , {
				buff_create = {
					owner_data = PUBLIC.get_game_owner_data(_buff_obj.owner) , 

					buff_data = DATA.game_info_center.get_one_buff_data( _buff_obj ) ,
					
				} } , _father_process_no
			)
		end

		return process_no
	end

	return nil
end

----- 删除buff
function PUBLIC.delete_buff( _buff_obj )
	if _buff_obj and _buff_obj.owner then
		----- 收集数据 , 技能触发
		local process_no = nil

		if not _buff_obj.is_not_send_client then
			process_no = _buff_obj.d.running_data_statis_lib.add_game_data( _buff_obj.d , {
				buff_dead = {
					owner_data = PUBLIC.get_game_owner_data(_buff_obj.owner) ,

					buff_data = DATA.game_info_center.get_one_buff_data( _buff_obj ) ,
				} } 
			)
		end


		_buff_obj:destroy( process_no )

		local buff_type = _buff_obj.config.buff_enum

		local owner = _buff_obj.owner

		owner.buff = owner.buff or {}

		for _buff_type , buff_list in pairs(owner.buff) do
			local is_find = false

			for key, buff_obj in pairs(buff_list) do
				if buff_obj.no == _buff_obj.no then
					table.remove( buff_list, key )
					is_find = true
					break
				end
			end

			if is_find then
				break
			end
		end

		
		_buff_obj.owner = nil

		return process_no
	end
	
	return nil
end

----

------------------------------------------------------------------------------- 创建 buff ↑ ------------------------------------------------------------------------

----------------------------------------------------------------------------------------------- 创建主体 ↓ ------------------------------------------
------创建 车辆
function PUBLIC.create_car(_d , _car_id , _owner_seat_num )
	local config = basefunc.deepcopy( DATA.game_car_config[ _car_id ] )
	if not config then
		print("xxx-------------nor car_config for :",_car_id)
		return 
	end

	_d.car_no = _d.car_no + 1
	local car_info = {
		kind_type = DATA.game_kind_type.car ,
		car_no = _d.car_no ,
		seat_num = _owner_seat_num , 
		group = _owner_seat_num,

		id = config.id ,
		name = config.name ,
		type = config.type ,

		pinzhi = config.pinzhi ,
		
		hp = config.hp ,
		hp_max = config.hp ,
		at = config.at , 
		sp = config.sp ,
		bj_gl = config.bj_gl ,
		miss_gl = config.miss_gl ,
		lj_gl = config.lj_gl or 0,      --- 这个暂时废掉
		lj_xishu = config.lj_xishu ,    --- 伤害的连击系数
		bj_xishu = config.bj_xishu ,    --- 暴击的系数

		fanshang = 0 ,
		extra_move_step = 0 ,


		sp_award_extra_num  = 0 ,
		at_award_extra_num  = 0 ,
		hp_award_extra_num  = 0 ,
		n2o_award_extra_num = 0 ,           
		small_daodan_award_extra_num = 0 ,	
		car_award_extra_num = 0 ,				 
		tool_award_extra_num = 0 ,		

		pos = 1,
		virtual_circle = 0,
		hd = 0,
		extra_lj_num = 0,    --- 额外的连击次数
		final_add_at = 0,    --- 额外增加，最终攻击力

		skill_tag = {} ,
		skill = {} ,

		config = config ,
	}

	----- 将基础数据 附加
	--basefunc.merge( config.base_prop_data , car_info )

	--dump(car_info , "xxxx-------------create_car:")
	----- 创建技能 , 创建老版 ，可升级的技能
	--[[for skill_tag,data in pairs( config.skill_data ) do
		local first_index_config = data.level_up_data[1]
		---- 创建第一个技能
		PUBLIC.skill_create_factory( _d , first_index_config.skill_id , { owner = car_info } )
		car_info.skill_tag[ skill_tag ] = { level_up_index = 1 , skill_id = first_index_config.skill_id }
	end--]]


	---- 记录大小油门
	if config.youmen_skill and type(config.youmen_skill) == "table" then
		car_info.big_youmen_skill_id = config.youmen_skill[1]
		car_info.small_youmen_skill_id = config.youmen_skill[2]
	end

	---- 获取附加数据
	local fuzhu_data = _d.player_fujia_data[_owner_seat_num] and _d.player_fujia_data[_owner_seat_num][_car_id]
	if fuzhu_data then
		--- 处理基础值的改变
		if fuzhu_data.prop_set then
			for key , value in pairs( fuzhu_data.prop_set ) do
				car_info[key] = value
			end
		end

		car_info["hp_max"] = car_info["hp"]

		--[[car_info.level = fuzhu_data.level 
		car_info.star = fuzhu_data.star--]]

		if config.id == 3 then
			dump(fuzhu_data.skill_change , "xxxx--------------------fuzhu_data.skill_change:")
		end

		--- 处理 车身上技能
		if fuzhu_data.skill_change then
			local car_skill_fujia_data = fuzhu_data.skill_change

			---- 用附加的数据，替换原始 slot_skill 的 数据
			for skill_type , data in pairs( car_skill_fujia_data ) do
				if not config.slot_skill[skill_type] or config.slot_skill[skill_type] ~= data.type_id then

					config.slot_skill[skill_type] = data.type_id
				end

				--- 对要改变的type_id 的字段 加buff
				if data.change_data and type(data.change_data) == "table" then
					---- 对所有要改变的车技能的 type_id 加上改变buff
					for key , change in pairs( data.change_data ) do
						local buff_data = {
							owner = _d.p_info[_owner_seat_num] , skill = nil ,
							buff_enum = "type_id_cfg_buff",

							type_id = data.type_id ,
							modify_key_name = key , 
							modify_type = 1 ,
							modify_value = change ,
						}

						PUBLIC.create_buff(_d , buff_data )
					end

				end
			end

		end

	end

	------- 有基础值的字段
	local base_value_key = {
		hp = true ,
		hp_max = true ,
		at = true ,
		sp = true ,
	}
	------- 附加基础值, 这个是 升级 和 装备附加之后的基础值
	for k,b in pairs(base_value_key) do
		if car_info[k] then
			car_info[ "base_" .. k ] = car_info[k]
		end
	end

	if config.id == 3 then
		dump(config.slot_skill , "xxxx---------------------config.slot_skill:")
	end

	---- 创建插槽技能
	for skill_type , type_id in pairs( config.slot_skill ) do
		local type_id_cfg = DATA.chehua_skill_type_id_config[type_id]
		
		--- 把 type_id 对应的 skill_id 都给创建了
		if type_id_cfg then
			local _skill_id_list = type_id_cfg._skill_id_list
			if _skill_id_list then
				for key, skill_id in pairs(_skill_id_list) do

					PUBLIC.skill_create_factory( _d , skill_id , { owner = car_info } )

				end
			end
		end

		
	end

	----- 自动使用维修工具
	PUBLIC.skill_create_factory( _d , 1015 , { owner = car_info } )
	PUBLIC.skill_create_factory( _d , 1016 , { owner = car_info } )
	

	---- 添加到 数据中心
	DATA.game_info_center.add_car( _d , _owner_seat_num , car_info)
end

----- 创建 地图障碍
function PUBLIC.create_map_barrier(_d , _barrier_id , _road_id , _father_process_no , _owner , _is_clear_enemy_barrier , _is_clear_owner_barrier)
	local config = DATA.map_barrier_config[_barrier_id]
	
	if not config then
		print("xxx-------------nor barrier_config for :",_car_id)
		return false
	end

	_d.barrier_no = _d.barrier_no + 1

	local barrier_info = {
		kind_type = DATA.game_kind_type.road_barrier ,
		no = _d.barrier_no ,

		id = config.id , 
		type = config.type ,

		road_id = _road_id ,
		owner = _owner ,
		seat_num = _owner.seat_num ,
		group = _owner.group , 
	}



	------ 处理清除
	if _is_clear_enemy_barrier then
		if _d.map_barrier[_road_id] then
			for b_no , b_obj in pairs( _d.map_barrier[_road_id] ) do
				if b_obj.group ~= _owner.group then
					PUBLIC.delete_map_barrier(_d , b_obj , nil , "replace" , nil )
					break
				end
			end
		end
	end

	------ 处理清除
	if _is_clear_owner_barrier then
		if _d.map_barrier[_road_id] then
			for b_no , b_obj in pairs( _d.map_barrier[_road_id] ) do
				if b_obj.group == _owner.group then
					PUBLIC.delete_map_barrier(_d , b_obj , nil , "replace" , nil )
					break
				end
			end
		end
	end
	----- 统计数据
	local process_no = _d.running_data_statis_lib.add_game_data( _d , {
		road_barrier_change = {
			road_id = _road_id ,

			data_type = 1 ,
			road_barrier_data = DATA.game_info_center.get_one_map_barrier_data( barrier_info ) , 
		} } , _father_process_no
	)

	---- 信息加入 info_center , 这里面会触发删除 原本的地图障碍。 或者 升级障碍。
	DATA.game_info_center.add_map_barrier( _d , _road_id , barrier_info )


	----- 创建技能 
	for key, skill_id in pairs( config.skill_data ) do	
		---- 创建第一个技能
		PUBLIC.skill_create_factory( _d , skill_id , { owner = barrier_info , father_process_no = process_no } )
	end

	return barrier_info , process_no
	--dump( barrier_info , "xxxx-------------create_map_barrier:" )
end

---- 删除 地图障碍 
function PUBLIC.delete_map_barrier(_d , _barrier_obj , _father_proces_no , _reason , _release_skill_id)
	
	---- 
	local _road_id = _barrier_obj.road_id
	local _no = _barrier_obj.no
	print("xxx--------------------delete_map_barrier11:",_road_id , _no)


	if _d.map_barrier[_road_id] and _d.map_barrier[_road_id][_no] and _barrier_obj == _d.map_barrier[_road_id][_no] then

		print("xxx--------------------delete_map_barrier 22:",_road_id , _no)
		
		---- 统计数据
		_d.running_data_statis_lib.add_game_data( _d , {
			road_barrier_change = {
				road_id = _road_id ,
				data_type = 2 ,
				reason = _reason ,
				release_skill_id = _release_skill_id ,
				road_barrier_data = DATA.game_info_center.get_one_map_barrier_data( _barrier_obj ) , 
			} } , _father_proces_no
		)

		---- 删除对应的技能
		local have_skill = _barrier_obj.skill 
		if have_skill and type(have_skill) == "table" then
			for skill_id,skill_obj in pairs(have_skill) do
				PUBLIC.delete_skill( skill_obj ) 
			end
		end
		---
		_d.map_barrier[_road_id][_no] = nil

	end

	----

end

--------- 创建道具
function PUBLIC.create_tools( _d , _seat_num , _tool_id , _father_proces_no)
	local tool_config = DATA.game_tools_config[_tool_id]

	if not tool_config then
		print("error---- no tool_config fo tool_id:" , _tool_id)
		return false
	end

	local player_info = _d.p_info[_seat_num]

	if not _d.tools_info[_seat_num] or not _d.tools_info[_seat_num][_tool_id] then

		_d.tools_info[_seat_num] = _d.tools_info[_seat_num] or {}

		local tool_info = {
			id = tool_config.id ,        --- 
			type = tool_config.type ,      --- 类型
			num = 0,       --- 有多少个
			spend_mp = tool_config.spend_mp ,  --- 消耗mp点数 
			is_end_op = tool_config.is_end_op , --- 是否结束 普通操作

			owner = player_info ,     --- owner 是玩家 ，
			seat_num = player_info.seat_num ,
			group = player_info.group ,
			--skill = basefunc.deepcopy( tool_config.skill ) ,
			type_id = tool_config.type_id ,
		}

		_d.tools_info[_seat_num][_tool_id] = tool_info

	end

	local tar_data = _d.tools_info[_seat_num][_tool_id]
	tar_data.num = tar_data.num + 1


	----- 统计数据
	_d.running_data_statis_lib.add_game_data( _d , {
		tool_create = {
			owner_data = PUBLIC.get_game_owner_data( tar_data.owner ) ,

			id = tar_data.id ,
			spend_mp = tar_data.spend_mp ,
			num = tar_data.num ,
		} } , _father_proces_no
	)

	----- 如果大于4个 立即使用(使用不好，有传送，)
	--local total_tool_num = basefunc.key_count( _d.tools_info[_seat_num] )
	--if total_tool_num > skynet.getcfgi( "drive_game_total_tool_num" , 4 ) then
	--	PUBLIC.use_tools( _d , _seat_num , _tool_id)
	--end

	return true
end

function PUBLIC.use_tools( _d , _seat_num , _tool_id)
	if _d.tools_info[_seat_num] and _d.tools_info[_seat_num][_tool_id] then
		local tar_data = _d.tools_info[_seat_num][_tool_id]
		if tar_data.num <= 0 then
			return false
		end

		----- 减个数
		tar_data.num = tar_data.num - 1

		----- 统计数据
		local process_no = _d.running_data_statis_lib.add_game_data( _d , {
			tool_use = {
				owner_data = PUBLIC.get_game_owner_data( tar_data.owner ) ,
				
				id = tar_data.id ,
				num = tar_data.num ,
			} }
		)

		---- 创建技能 , 技能的owner 直接写成 player
		--for key, skill_id in pairs(tar_data.skill) do
		--	PUBLIC.skill_create_factory( _d , skill_id , { owner = tar_data.owner , father_process_no = process_no } )
		--end

		------- 创建地图奖励
		local map_award_data = {
			create_type = "skill" ,
			type_id = tar_data.type_id ,
		}

		local trrigger_car = PUBLIC.get_car_info_by_data(_d , _d.p_info[_seat_num] )

		_d.single_obj["driver_map_award_manager"]:create_map_award( map_award_data , trrigger_car.pos , trrigger_car )


		return process_no
	else
		return nil
	end
end

----------------------------------------------------------------------------------------------- 创建主体 ↑ ------------------------------------------

------------- 获取 run_obj 的 参数数值
function PUBLIC.convert_arg_data(_value )
	if type(_value) ~= "table" then
		return _value
	else
		if not _value.arg_value or not _value.value_type then
			return _value
		else
			local tar_value = nil
			local tar_overlay_rule = nil
			if _value.value_type == "nor" then
				tar_value = _value.arg_value
			elseif _value.value_type == "random" then
				tar_value = math.random( _value.arg_value[1] , _value.arg_value[2] )
			end

			if _value.overlay_rule then
				tar_overlay_rule = _value.overlay_rule
			end

			return tar_value , tar_overlay_rule
		end
	end
end



----- 获得目标类型的 对象集合
--[[
	_type        是游戏对象类型
	_get_type    是获取方式，all 全部， enemy 敌方 , other 除此之外
--]]
function PUBLIC.get_game_obj_by_type( _d , _tar_entity , _get_type )
	local tar_vec = {}

	local select_vec = {}
	------- 
	if string.sub( _get_type , 1 , 7 ) == "car_id_" then
		select_vec = _d.car_info
		local car_id = tonumber( string.sub( _get_type , 8 , -1 ) )

		for key,data in pairs(select_vec) do
			if data.id == car_id then
				tar_vec[#tar_vec + 1] = data
			end
		end
		return tar_vec
	end

	if string.sub( _get_type , 1 , 11 ) == "not_car_id_" then
		select_vec = _d.car_info
		local car_id = tonumber( string.sub( _get_type , 12 , -1 ) )

		for key,data in pairs(select_vec) do
			if data.id ~= car_id then
				tar_vec[#tar_vec + 1] = data
			end
		end
		return tar_vec
	end

	
	if _tar_entity.kind_type == DATA.game_kind_type.player then
		select_vec = _d.p_info
	elseif _tar_entity.kind_type == DATA.game_kind_type.car then
		select_vec = _d.car_info
		
	end

	if select_vec then
		if _get_type == "all" then
			tar_vec = select_vec
		elseif _get_type == "enemy" then 
			for key,data in pairs(select_vec) do
				if data.group ~= _tar_entity.group then
					tar_vec[#tar_vec + 1] = data
				end
			end
		elseif _get_type == "other" then 
			for key,data in pairs(select_vec) do
				if data ~= _tar_entity then
					tar_vec[#tar_vec + 1] = data
				end
			end
		end

	end

	return tar_vec
end

------- 获取 游戏对象的种类类型 和 类型下 唯一id
function PUBLIC.get_game_owner_data(_game_obj)
	if not _game_obj then
		return {}
	end

	local owner_data = {
		owner_type = _game_obj.kind_type ,
		owner_id = -1 ,
		owner_pos = nil ,
	}

	
	if _game_obj.kind_type == DATA.game_kind_type.player then
		
		owner_data.owner_id = _game_obj.seat_num

	elseif _game_obj.kind_type == DATA.game_kind_type.car then

		owner_data.owner_id = _game_obj.car_no
		owner_data.owner_pos = _game_obj.pos

	elseif _game_obj.kind_type == DATA.game_kind_type.road_barrier then

		owner_data.owner_id = _game_obj.no
		owner_data.owner_pos = _game_obj.road_id

	end


	return owner_data
end



------- 获得玩家信息 通过车 or 人
function PUBLIC.get_player_info_by_data(_d , _data)
	if _data.kind_type == DATA.game_kind_type.player then
		return _data
	elseif _data.kind_type == DATA.game_kind_type.car then
		return _d.p_info[ _data.seat_num ]
	end
end

----- 获得车 信息 通过 车 或人
function PUBLIC.get_car_info_by_data(_d , _data)
	if _data.kind_type == DATA.game_kind_type.car then
		return _data
	elseif _data.kind_type == DATA.game_kind_type.player then
		if _data.car and next(_data.car) then
			local car_id , car_data = next(_data.car)
			return car_data
		end
	end
	return nil
end

---- 根据座位号来获取车的数据
function PUBLIC.get_car_info_by_seat(_d , _seat_num )

	if _d.p_info[ _seat_num ] then
		return PUBLIC.get_car_info_by_data( _d , _d.p_info[ _seat_num ] )
	end

	return nil
end

----- 获得敌人车的road_id
function PUBLIC.get_enemy_car_road_id( _d , _seat_num )
	local e_seat_num = (_seat_num == 1 ) and 2 or 1

	local car_data = PUBLIC.get_car_info_by_seat(_d , e_seat_num )

	return PUBLIC.get_grid_id_quick( _d , car_data.pos )
end

---- 获得一个技能表中的  某种技能tag 的技能的个数
function PUBLIC.find_tag_skill_num( _skill_vec , _tag )
	local num = 0
	if _skill_vec and type(_skill_vec) == "table" then
		for skill_id , skill_obj in pairs(_skill_vec) do
			if skill_obj.tag and skill_obj.tag[_tag] then
				num = num + 1
			end
		end
	end

	return num
end

----- 检查一个 地图奖励 是否可以 被选择 给 一个主体
function PUBLIC.check_map_award_can_be_select( _d , _award_data , _for_main_obj  )
	local is_can_add = true

	local _skill_id = _award_data.award_id

	---- 没有主体直接返回true
	if not _for_main_obj then
		return is_can_add
	end

	local trigger_skills = _for_main_obj.skill
	local trigger_id = _for_main_obj.id

	local trigger_slot_skill_num = PUBLIC.find_tag_skill_num(trigger_skills , "slot_show_skill" )
			
	----- 这个库要奖励的任务id
	local skill_id = _skill_id
	local skill_config = DATA.skill_config[skill_id]

	---- 处理已经 有相同的 
	--[[if trigger_skills and trigger_skills[skill_id] then
		is_can_add = false
	end--]]

	---- 处理 其他
	if is_can_add and skill_config then
		local refresh_tag = _award_data.refresh_tag  --skill_config.tag

		------ 处理技能标签
		for _tag , _v in pairs(refresh_tag) do
			if _tag == "no_same" then
				---- 相同的不出现
				if trigger_skills and trigger_skills[skill_id] then
					is_can_add = false
					break
				end

			elseif string.sub( _tag , 1 , 11 ) == "skill_buff_" then
				local effect_skill_id = tonumber( string.sub( _tag , 12 , -1 ) )
				---- 如果没有则不能加，必须有某个buff技能才能加
				if not trigger_skills or not trigger_skills[effect_skill_id] then
					is_can_add = false
					break
				end

			elseif string.sub( _tag , 1 , 8 ) == "own_car_" then
				local owner_car = tonumber( string.sub( _tag , 9 , -1 ) )
				if owner_car ~= trigger_id and _for_main_obj.kind_type == DATA.game_kind_type.car then
					is_can_add = false
					break
				end

			--[[elseif _tag == "slot_show_skill" then
				if trigger_slot_skill_num >= 4 then
					is_can_add = false
					break
				end--]]
			elseif _tag == "sys_clear" then
				---- 必须要有 system_buff 这种tag 的技能在系统上，才会出现这个技能
				local sys_skill_num = PUBLIC.find_tag_skill_num( _d.system_obj.skill , "system_buff" )

				print( "xxxx---------------sys_skill_num: " , sys_skill_num )
				if sys_skill_num == 0 then
					is_can_add = false
					break
				end
			elseif string.sub( _tag , 1 , 16 ) == "no_system_skill_" then
				local _sys_skill_id = tonumber( string.sub( _tag , 17 , -1 ) )
				if _d.system_obj.skill and _d.system_obj.skill[ _sys_skill_id ] then
					is_can_add = false
					break
				end
			elseif string.sub( _tag , 1 , 15 ) == "forever_create_" then
				---- 永远只能创建N次的技能
				local _create_num = tonumber( string.sub( _tag , 16 , -1 ) )
				local skill_created_statis = _for_main_obj.skill_created_statis

				if skill_created_statis and skill_created_statis[_skill_id] and type(skill_created_statis[_skill_id]) == "number" then
					---已经创建 得 大于最大创建数
					if skill_created_statis[_skill_id] >= _create_num then
						is_can_add = false
						break
					end
				end

			end

		end
	end

	return is_can_add
end

------ 获取 真正的 策划的数据配置 ，通过技能 对应的 type_id 来作用 配置buff , 获取 最终的策划配置数据
function PUBLIC.get_real_chehua_config( _d , _skill_id , _seat_num )
	--- 先拷贝出来
	local chehua_config = basefunc.deepcopy( DATA.chehua_skill_config[ _skill_id ] )

	--- 找到对应 type_id
	local type_id = DATA.chehua_skill_id_2_type_id_map[ _skill_id ]

	if type_id then
		local player_info = _d.p_info[_seat_num]

		if player_info then
			---- 对现有的策划配置，加上 buff加持
			for key , value in pairs( chehua_config ) do
				chehua_config[key] = DATA.car_prop_lib.get_type_id_cfg_value( player_info , type_id , key , value )
			end

		end
	end

	return chehua_config
end

------ 把配置表中的引用处理了。
--[[
	--- 对一个表是进行表字段赋值
	--- 对一个字符串是，直接解析后返回

	将 _config 中包含 $的字段转换
--]]
function PUBLIC.convert_chehua_config( _d , _config , _skill_id , _seat_num )
	local chehua_skill = PUBLIC.get_real_chehua_config( _d , _skill_id , _seat_num ) -- DATA.chehua_skill_config[ _skill_id ]

	local function deal_func(_value , _k , _father)
		if type(_value) == "table" then
			for k,v in pairs(_value) do
				deal_func(v , k , _value)
			end
		elseif type(_value) == "string" then
			--print("xxx-----------_value:" , _value)
			local new_value = string.gsub( _value , "%$([a-zA-Z0-9_]+)" , function( _s )
				print("xxxxxx------convert_chehua_config:"  , _skill_id)
				if not chehua_skill[_s] then
					error( string.format("no index : %s for skill_config skill_id:%s " , _s , _skill_id ) )
				end

				---- 直接是 一个 字符串的可以直接返回
				return chehua_skill[_s]
			end )

			if tonumber(new_value) then
				new_value = tonumber(new_value)
			end

			if _father and _k then
				_father[_k] = new_value
			end
			return new_value
		end
	end
	return deal_func(_config)
	
end

---- 获取 obj id 和
function PUBLIC.get_skill_cfg_obj_data( _obj_id )
	local obj_num = 1
	local obj_id = tonumber(_obj_id)
	if not obj_id and type(_obj_id) == "string" then
		local _start,_end, _r_obj_id , _repeat_num = string.find( _obj_id , "(%d+)%*(.+)" )
		obj_id = tonumber(_r_obj_id)
		if tonumber( _repeat_num ) then
			obj_num = tonumber( _repeat_num )
		else
			local _s , _e , _min , _max = string.find( _repeat_num , "(%d+)~(%d+)" )

			if _s and _min and _max then
				obj_num = math.random( tonumber(_min) , tonumber(_max) )
			end
		end
	end

	return obj_id , obj_num
end

---- 根据 type_id  获取对应的 道具id
function PUBLIC.get_tool_id_by_type_id(_type_id)
	local tool_id = nil
	if _type_id and DATA.game_tools_config and type(DATA.game_tools_config) == "table" then
		for key,data in pairs( DATA.game_tools_config ) do
			if data.type_id == _type_id then
				tool_id = data.id
				break
			end
		end
	end
	return tool_id
end

----- 获取 某个人 有的道具的 type_id -> num 的 map
function PUBLIC.get_tool_type_id_map( _d , _seat_num)
	local tar_map = {}
	if _d.tools_info and _d.tools_info[_seat_num] and type(_d.tools_info[_seat_num]) == "table" then
		for id , data in pairs( _d.tools_info[_seat_num] ) do
			tar_map[ data.type_id ] = (tar_map[ data.type_id ] or 0) + data.num

		end
	end

	return tar_map
end


----  获取路面奖励 & 人身上的道具的  type_id的数量，key为type_id,data为sum
function PUBLIC.get_type_id_sum(_d)
  	local type_id_sum = {}
  	for key,data in pairs (_d.map_road_award) do
		type_id_sum[data.type_id] = (type_id_sum[data.type_id] or 0) + 1
  	end

	for seat_num,data in pairs (_d.tools_info) do
    	for id,_data in pairs (data) do
    		type_id_sum[_data.type_id] = (type_id_sum[_data.type_id] or 0) + 1
    	end
  	end
  	return type_id_sum
end



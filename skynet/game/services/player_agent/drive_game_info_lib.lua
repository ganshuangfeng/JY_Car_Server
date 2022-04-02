-- 赛车游戏的 agent 的信息 处理
--[[
	如何 获取 车辆的数据 ， 比如是否需要车升级的 附加 数据， 是否需要装备附加的数据
--]]

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require"printfunc"

local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

DATA.drive_game_info_lib_protect = {}
local PROTECT = DATA.drive_game_info_lib_protect


---- 


--- 车辆的配置 ，
PROTECT.game_car_config = nil

--- 纯粹的 type_id 对应的 配置表
PROTECT.pure_chehua_skill_type_id_config = nil

---- 获取车辆的数据
function PROTECT.get_chehua_config()
	PROTECT.game_car_config = skynet.call( DATA.service_config.driver_cehua_config_center_service , "lua" , "get_game_car_config" )

	PROTECT.pure_chehua_skill_type_id_config = skynet.call( DATA.service_config.driver_cehua_config_center_service , "lua" , "get_pure_chehua_skill_type_id_config" )
	--dump(PROTECT.pure_chehua_skill_type_id_config , "xxxx-----------PROTECT.pure_chehua_skill_type_id_config:")
end

---- 转换成 给客户端的 消息结构
function PROTECT.convert_car_data_to_client( _org_data )
	local tar_data = {}

	tar_data.base_data = _org_data.base_data

	if _org_data.car_base_data and type(_org_data.car_base_data) == "table" then
		for key , value in pairs(_org_data.car_base_data) do
			tar_data[ key ] = value
		end
	end

	local tar_car_skill_data = {}
	if type( _org_data.car_skill_data ) == "table" then
		for skill_type , skill_data in pairs(_org_data.car_skill_data) do
			local on_skill_data = {  skill_type = skill_type , type_id = skill_data.type_id , skill_values = {} }

			if type( skill_data.data ) == "table" then
				for key,value in pairs(skill_data.data) do
					on_skill_data.skill_values[ #on_skill_data.skill_values + 1 ] = { key = key , change = math.floor( value * 100 ) }
				end
			end

			tar_car_skill_data[#tar_car_skill_data + 1] = on_skill_data

		end
	end

	tar_data.car_skill_data = tar_car_skill_data

	------
	local tar_equipment_data = {}

	if type( _org_data.equipment_data ) == "table" then
		for no , eqp_data in pairs( _org_data.equipment_data ) do
			tar_equipment_data[#tar_equipment_data + 1] = eqp_data
		end
	end

	tar_data.equipment_data = tar_equipment_data

	return tar_data
end

---- 转成 给 房间的 消息结构
function PROTECT.convert_car_data_for_room( _org_data )
	local tar_data = {}

	local prop_set = {}
	if _org_data.base_data then
		prop_set.level = _org_data.base_data.level
		prop_set.star = _org_data.base_data.star
	end

	if _org_data.car_base_data then
		for key,value in pairs( _org_data.car_base_data ) do
			prop_set[ key ] = value
		end
	end

	prop_set.equipment_data = _org_data.equipment_data

	tar_data.prop_set = prop_set

	-----------------
	local skill_change = _org_data.car_skill_data_change

	tar_data.skill_change = skill_change

	return tar_data
end



---- 获取当前的 车辆数据 ， 负责客户端数据  和 带入房间 的数据的整理
--[[
	_info_switch 包括 level_up , equipment

	return:
		-- 车升级基础值
		base_data = {
			car_id
			level
			star
		}                
		
		-- 附加 的车辆 最终基础值
		car_base_data = {
			hp
			at
			sp
		}       
		

		 --- 车辆 最终的 技能数据
		car_skill_data  = {
			skill_type = { 
			 	type_id = xxx , 
			 	data = {          ---- 所有的 配置值  
			 		key = xx , 
			 		key_2 = xx2 ,
			 	} 
			}
		}

		--- 改变 的技能 数据
		car_skill_data_change = {   
			skill_type = { 
			 	type_id = xxx , 
			 	change_data = {          ---- 所有的 改变的 配置值
			 		key = xx , 
			 		key_2 = xx2 ,
			 	} 
			}
		}

		equipment_data = {
			[no] = {
				no $ : integer                # 标号，全局唯一的编号 ，当升级 or 升星 or 装备时 ，得发这个过来
				id $ : integer                # 类型id , 相同类型id 可能有多个
				level $ : integer             # 等级
				star $ : integer              # 星级
				now_exp $ : integer           # 当前等级的 exp
				sold_exp $ : integer          # 用来提升其他装备的经验值 
				owner_car_id $ : integer      # 在哪个车上
				
			}
		}

--]]
--[[
	_force_data 强制数据，一个表 ，
	{
		base_car_data = {
			car_id
			level
			star
		}
		equipment_data = {
			[no] = {
				no = v.no,
	            id = v.id,
	            level = v.level,
	            star = v.star,
	        }
		}

	}
--]]
function PUBLIC.base_get_drive_car_data( _car_id , _base_info_switch , _skill_switch , _force_data )
	local _base_info_switch = basefunc.list_to_map( _base_info_switch )
	local _skill_switch = basefunc.list_to_map( _skill_switch )

	---- 获得这个车的 基础 升级 数据
	local base_data = _force_data and _force_data.base_car_data or DATA.car_base_lib.safe_car_data( _car_id )

	---- 如果没有车数据
	if not base_data then
		return 1004
	end

	----
	if _force_data and _force_data.base_car_data and _force_data and _force_data.base_car_data.car_id then
		_car_id = _force_data.base_car_data.car_id
	end

	---- 车辆的基础配置
	local base_car_cfg = PROTECT.game_car_config[ _car_id ]

	---- 需要返回的 基础数据 key
	local need_base_car_prop = {
		hp = true,
		at = true,
		sp = true,
	}

	

	------- 等级带来的改变
	local level_change = nil
	if _force_data and _force_data.base_car_data then
		level_change = DATA.car_base_lib.get_car_up_level_change_by_data( _force_data.base_car_data.car_id , _force_data.base_car_data.level , _force_data.base_car_data.star )
	end
	if not level_change then
		level_change = DATA.car_base_lib.get_car_up_level_change(_car_id)
	end

	dump(level_change , "xxxx--------------------------level_change:")
	--- 所有 装备带来的改变
	--[[
		base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
        skill_change = {   --- 当前，改变的技能的数据
        	[eqp_no] = {
				skill_type_1 = { 
	                type_id = xxx , 
	                change_data = { 
	                    key = xx , 
	                    key_2 = xx2 ,
	                } 
	            },
	            ...
        	}
            
        }
	--]]
	local equipment_change = nil
	if _force_data and _force_data.equipment_data and type(_force_data.equipment_data) == "table" then
		local equipment_list = {}
		for key,data in pairs(_force_data.equipment_data) do
			equipment_list[#equipment_list + 1 ] = data
		end

		equipment_change = DATA.car_equipment_lib.get_car_equipment_change_by_data( equipment_list )
	end
	if not equipment_change then
		equipment_change = DATA.car_equipment_lib.get_car_all_equipment_change(_car_id)
	end
	dump(equipment_change , "xxxx--------------------------equipment_change:")
	--------------------------------------------------------------- 处理基础值 ↓
	------- 先获得 基础的  车数据
	local car_base_data = {}
	--- 初始化
	for prop_key , bool in pairs(need_base_car_prop) do
		car_base_data[ prop_key ] = base_car_cfg[ prop_key ]
	end

	---- 处理升级
	if _base_info_switch.level_up then
		if level_change and level_change.base_change_sum then
			for prop_key , value in pairs( car_base_data ) do
				car_base_data[prop_key] = car_base_data[prop_key] + ( level_change.base_change_sum[ prop_key ] or 0 )
			end
		end
	end

	if _base_info_switch.equipment then
		if equipment_change and equipment_change.base_change_sum then
			for prop_key , value in pairs( car_base_data ) do
				car_base_data[prop_key] = car_base_data[prop_key] + ( equipment_change.base_change_sum[ prop_key ] or 0 )
			end
		end
	end

	--------------------------------------------------------------- 处理技能 ↓
	local car_skill_data = {}
	local car_skill_data_change = {}

	--- 初始化
	if base_car_cfg.slot_skill then
		for skill_type , type_id in pairs(base_car_cfg.slot_skill) do
			car_skill_data[skill_type] = {
				type_id = type_id ,
				data = basefunc.deepcopy( PROTECT.pure_chehua_skill_type_id_config[ type_id ] ) ,
			}
		end
	end

	if _skill_switch.level_up then
		if level_change and level_change.skill_change then

			--- 附加到 改变数据中去
			basefunc.deepmerge( level_change.skill_change , car_skill_data_change )

			--- 附加到 最终技能数据中去
			for skill_type , skill_change_data in pairs( level_change.skill_change ) do
				car_skill_data[skill_type] = car_skill_data[skill_type] or {}
				local tar_data = car_skill_data[skill_type]


				if tar_data.type_id ~= skill_change_data.type_id then
					tar_data.type_id = skill_change_data.type_id
					---- 如果之前没有 ，说明是新增，新增时得用配置来初始化一下 数据
					tar_data.data = basefunc.deepcopy( PROTECT.pure_chehua_skill_type_id_config[ skill_change_data.type_id ] ) 
				end

				if skill_change_data.change_data then
					for key , change in pairs(skill_change_data.change_data) do
						tar_data.data[ key ] = ( tar_data.data[ key ] or 0 ) + change
					end
				end
			end

		end
	end

	if _skill_switch.equipment then
		if equipment_change and equipment_change.skill_change then

			----  转换 key
			local tem_skill_change = {}
			for _eqp_no , _eqp_change_data in pairs( equipment_change.skill_change ) do
				for skill_type , data in pairs(_eqp_change_data) do
					tem_skill_change[ _eqp_no .. "_" .. skill_type ] = data
				end
			end

			basefunc.deepmerge( tem_skill_change , car_skill_data_change )
			

			---basefunc.deepmerge( equipment_change.skill_change , car_skill_data_change )

			--- 附加到 最终技能数据中去
			for eqp_no , eqp_data in pairs(equipment_change.skill_change) do
				for skill_type , skill_change_data in pairs( eqp_data ) do
					---- 这里的 skill_type 的加上装备的 隔离
					local tar_skill_type = eqp_no .. "_" .. skill_type

					car_skill_data[tar_skill_type] = car_skill_data[tar_skill_type] or {}
					local tar_data = car_skill_data[tar_skill_type]

					if tar_data.type_id ~= skill_change_data.type_id then
						tar_data.type_id = skill_change_data.type_id
						---- 如果之前没有 ，说明是新增，新增时得用配置来初始化一下 数据
						tar_data.data = basefunc.deepcopy( PROTECT.pure_chehua_skill_type_id_config[ skill_change_data.type_id ] ) 
					end

					if skill_change_data.change_data then
						for key , change in pairs(skill_change_data.change_data) do
							tar_data.data[ key ] = ( tar_data.data[ key ] or 0 ) + change
						end
					end
				end
			end


		end
	end

	----- 获得一个车的已佩戴的 装备的数据
	--[[
		{
			[no] = {
				no $ : integer                # 标号，全局唯一的编号 ，当升级 or 升星 or 装备时 ，得发这个过来
				id $ : integer                # 类型id , 相同类型id 可能有多个
				level $ : integer             # 等级
				star $ : integer              # 星级
				now_exp $ : integer           # 当前等级的 exp
				sold_exp $ : integer          # 用来提升其他装备的经验值 
				owner_car_id $ : integer      # 在哪个车上
				
			}
		}
	--]]
	local equipment_data = _force_data and _force_data.equipment_data or DATA.car_equipment_lib.get_car_all_equipment_data( _car_id )

	return {
		base_data = base_data ,
		car_base_data = car_base_data ,
		car_skill_data = car_skill_data ,
		car_skill_data_change = car_skill_data_change ,
		equipment_data = equipment_data ,
	}
end

----- 获得车辆升级界面的 车数据
function PUBLIC.get_drive_lv_up_car_data( _car_id )
	local data = PUBLIC.base_get_drive_car_data( _car_id , { "level_up" , "equipment" } , { "level_up" } )

	if type(data) == "number" then
		return data
	end

	----- 组装结构
	local tar_data = PROTECT.convert_car_data_to_client( data ) 

	

	return tar_data
end




---- 获得进入游戏的 车 附加 数据
function PUBLIC.get_drive_in_room_car_fujia_data( _car_id , _force_data )
	local data = PUBLIC.base_get_drive_car_data( _car_id , { "level_up" , "equipment" } , { "level_up" , "equipment" } , _force_data )

	if type(data) == "number" then
		return data
	end

	----- 组装结构
	local tar_data = PROTECT.convert_car_data_for_room( data ) 
	
	dump( data , "xxxx------------------------data___::" )
	dump( tar_data , "xxxx------------------------tar_data___::" )
	

	return tar_data
end


------------------------------------------------------------------------------------------------------------- 装备相关 ↓
-----  获取 一个车的 一个装备 的数据
function PUBLIC.get_one_equipment_data( _eqp_no )
	--[[
		return {
			no $ : integer                # 标号，全局唯一的编号 ，当升级 or 升星 or 装备时 ，得发这个过来
			id $ : integer                # 类型id , 相同类型id 可能有多个
			level $ : integer             # 等级
			star $ : integer              # 星级
			now_exp $ : integer           # 当前等级的 exp
			sold_exp $ : integer          # 用来提升其他装备的经验值 
			owner_car_id $ : integer      # 在哪个车上
			
		}
	--]]
	local base_data = DATA.car_equipment_lib.get_one_equipment_data( _eqp_no )

	--[[
		return {
			base_change_sum={hp=,...}  -- 升级到当前等级 累计增加的参数（相对 等级 1）
	        skill_change = {   --- 当前，改变的技能的数据
				skill_type_1 = { 
		            type_id = xxx , 
		            change_data = { 
		                key = xx , 
		                key_2 = xx2 ,
		            } 
		        },
		        ...
	        	
	        }
		}
	--]]
	local change_data = DATA.car_equipment_lib.get_one_equipment_change( _eqp_no )
	dump( change_data , "xxxxx-----------------change_data:" )
	---- 最终的技能数据
	local skill_data = {}

	for skill_type , skill_change_data in pairs(change_data.skill_change) do
		
		---- 这里的 skill_type 的加上装备的 隔离
		local tar_skill_type = skill_type

		skill_data[tar_skill_type] = skill_data[tar_skill_type] or {}
		local tar_data = skill_data[tar_skill_type]

		tar_data.skill_type = tar_skill_type

		if tar_data.type_id ~= skill_change_data.type_id then
			tar_data.type_id = skill_change_data.type_id
			---- 如果之前没有 ，说明是新增，新增时得用配置来初始化一下 数据
			tar_data.data = basefunc.deepcopy( PROTECT.pure_chehua_skill_type_id_config[ skill_change_data.type_id ] ) 
		end
		print("xxx--------------- get_one_equipment_data:"  , skill_change_data.type_id )
		if skill_change_data.change_data then
			for key , change in pairs(skill_change_data.change_data) do
				tar_data.data[ key ] = ( tar_data.data[ key ] or 0 ) + math.floor(change * 100 )
			end
		end
		
	end

	-----
	local tar_skill_data = {}

	for key,_data in pairs(skill_data) do
		_data.skill_values = {}

		if _data.data and type(_data.data) == "table" then
			for _key,_value in pairs(_data.data) do
				_data.skill_values[#_data.skill_values + 1] = { key = _key , change = _value }
			end
		end
		tar_skill_data[#tar_skill_data + 1] = _data
	end


	return {
		base_data = base_data ,
		skill_data = tar_skill_data ,
	}
end

---
function PROTECT.init()
	--- 先从 中心拿到对应的 策划配置
	PROTECT.get_chehua_config()




end

return PROTECT
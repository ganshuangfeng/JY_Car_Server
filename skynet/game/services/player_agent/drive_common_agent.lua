----- 赛车游戏的 外部的通用 agent  ,, 跟外部 客户端 通信的模块

require "normal_enum"
local skynet = require "skynet_plus"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require"printfunc"
local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local CMD = base.CMD
local REQUEST = base.REQUEST

DATA.drive_common_agent_protect = {}
local PROTECT = DATA.drive_common_agent_protect



---- 请求所有的车辆数据
function REQUEST.query_drive_all_car_data()
	local ret = {}
	--- 操作限制
	if PUBLIC.get_action_lock( "query_drive_all_car_data" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_drive_all_car_data" )

	local all_car_data = DATA.car_base_lib.get_all_car_data()

	ret.result = 0
	local car_base_data = {}
	
	if all_car_data and type(all_car_data) == "table" then
		for car_id , car_data in pairs(all_car_data) do
			car_base_data[#car_base_data + 1] = car_data
		end
	end

	ret.base_data = car_base_data

	PUBLIC.off_action_lock( "query_drive_all_car_data" )
    return ret
end

---- 获取一个 车辆 的数据
function REQUEST.query_drive_car_data(self)
	local ret = {}
	if not self or not self.car_id or type( self.car_id ) ~= "number" then
		ret.result = 1001
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "query_drive_car_data" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_drive_car_data" )

	----- 车数据
	local car_data = PUBLIC.get_drive_lv_up_car_data( self.car_id )

	if type(car_data) == "number" then
		ret.result = car_data
	else
		ret = car_data
		ret.result = 0
	end

	PUBLIC.off_action_lock( "query_drive_car_data" )
	return ret
end

------ 给外部调用的接口
function PUBLIC.add_drive_car( _car_id )
	local ret , errcode = DATA.car_base_lib.add_car( _car_id )

	if not ret then
		return errcode
	end

	--- 通知客户端 改变
	PROTECT.on_car_info_change( _car_id , "add" )
	
	return ret
end

---- 车辆升级
function REQUEST.drive_car_up_level(self)
	local ret = {}
	---- 参数检查
	if not self.car_id or type(self.car_id) ~= "number" then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_car_up_level" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_car_up_level" )

	ret = DATA.car_base_lib.car_upgrade(self.car_id)

	if ret.result == 0 then
		skynet.timeout( 1 , function() 
			PROTECT.on_car_info_change( self.car_id , "up_level" )
		end ) 
	end

	PUBLIC.off_action_lock( "drive_car_up_level" )
    return ret
end

---- 车辆升星
function REQUEST.drive_car_up_star( self )
	local ret = {}
	---- 参数检查
	if not self.car_id or type(self.car_id) ~= "number" then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_car_up_star" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_car_up_star" )

	ret = DATA.car_base_lib.car_up_star(self.car_id)

	if ret.result == 0 then
		skynet.timeout( 1 , function() 
			PROTECT.on_car_info_change( self.car_id , "up_star" )
		end ) 
	end

	PUBLIC.off_action_lock( "drive_car_up_star" )
    return ret
end

----- 请求客户端 ，车辆信息改变
function PROTECT.on_car_info_change( _car_id , _change_type )

	local car_data = PUBLIC.get_drive_lv_up_car_data( _car_id )

	car_data.change_type = _change_type

	PUBLIC.request_client( "on_drive_car_data_change" , car_data )

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function REQUEST.query_drive_all_equipment()
	local ret = {}

	--- 操作限制
	if PUBLIC.get_action_lock( "query_drive_all_equipment" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_drive_all_equipment" )

	--[[
		return {
			[no] = {
				no $ : integer                # 标号，全局唯一的编号 ，当升级 or 升星 or 装备时 ，得发这个过来
				id $ : integer                # 类型id , 相同类型id 可能有多个
				level $ : integer             # 等级
				star $ : integer              # 星级
				now_exp $ : integer           # 当前等级的 exp
				sold_exp $ : integer         *# 用来提升其他装备的经验值 
				owner_car_id $ : integer      # 在哪个车上
				
			},
			[no] = {
				
			}

		}
	--]]
	local all_eqp_data = DATA.car_equipment_lib.get_all_equipment_data()
	dump( all_eqp_data , "xxx-----------------get_all_equipment_data")
	ret.result = 0
	local base_data = {}
	
	if all_eqp_data and type(all_eqp_data) == "table" then
		for no , eqp_data in pairs(all_eqp_data) do
			base_data[#base_data + 1] = eqp_data
		end
	end

	ret.base_data = base_data

	PUBLIC.off_action_lock( "query_drive_all_equipment" )

	return ret
end

---- 获得 一个 装备的 详细 数据
function REQUEST.query_drive_equipment_data( self )
	local ret = {}
	---- 参数检查
	if not self.no or type(self.no) ~= "number" then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "query_drive_equipment_data" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_drive_equipment_data" )

	ret = PUBLIC.get_one_equipment_data( self.no )

	ret.result = 0
	PUBLIC.off_action_lock( "query_drive_equipment_data" )
	return ret
end

---- 加装备
function PUBLIC.add_drive_equipment( _eqp_id )
	local ret , errcode = DATA.car_equipment_lib.add_equipment( _eqp_id )

	if not ret then
		return errcode
	end

	--- 通知客户端 改变
	PROTECT.on_equipment_info_change( ret.no , "add" )
	
	return ret
end

---- 装备升级
function REQUEST.drive_equipment_up_level( self )
	local ret = {}
	---- 参数检查
	if not self.no or type(self.no) ~= "number" or not self.spend_no or type(self.spend_no) ~= "table" or not next(self.spend_no) then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_equipment_up_level" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_equipment_up_level" )

	--[[
		return { result = xx }
	--]]
	ret = DATA.car_equipment_lib.equipment_up_level( self.no , self.spend_no )

	if ret.result == 0 then
		skynet.timeout( 1 , function() 
			PROTECT.on_equipment_info_change( self.no , "up_level")

			if ret.owner_car_id and ret.owner_car_id ~= 0 then
				PROTECT.on_car_info_change( ret.owner_car_id , "equipment_up_level" )
			end

		end ) 
	end

	ret.spend_no = self.spend_no

	PUBLIC.off_action_lock( "drive_equipment_up_level" )
	return ret
end

----- 装备 升星
function REQUEST.drive_equipment_up_star( self )
	local ret = {}
	---- 参数检查
	if not self.no or type(self.no) ~= "number" then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_equipment_up_star" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_equipment_up_star" )

	--[[
		return { result = xx }
	--]]
	ret = DATA.car_equipment_lib.equipment_up_star( self.no )

	if ret.result == 0 then
		skynet.timeout( 1 , function() 
			PROTECT.on_equipment_info_change( self.no , "up_star" )

			if ret.owner_car_id and ret.owner_car_id ~= 0 then
				PROTECT.on_car_info_change( ret.owner_car_id , "equipment_up_star" )
			end

		end ) 
	end

	PUBLIC.off_action_lock( "drive_equipment_up_star" )
	return ret
end

----- 装备佩戴
function REQUEST.drive_equipment_load( self )
	local ret = {}
	---- 参数检查
	if not self.no or type(self.no) ~= "number" or not self.car_id or type(self.car_id) ~= "number" then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_equipment_load" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_equipment_load" )

	--[[
		return { result = xx }
	--]]
	ret = DATA.car_equipment_lib.equipment_load( self.no , self.car_id )

	if ret.result == 0 then
		skynet.timeout( 1 , function() 
			PROTECT.on_equipment_info_change( self.no , "load" )

			if ret.old_eqp_no then
				PROTECT.on_equipment_info_change( ret.old_eqp_no , "unload" )

			end

			PROTECT.on_car_info_change( self.car_id , "equipment_load" )

		end ) 
	end

	local equip_data = PUBLIC.get_one_equipment_data( self.no )
	ret.base_data = equip_data.base_data

	PUBLIC.off_action_lock( "drive_equipment_load" )
	return ret
end

---- 装备卸下
function REQUEST.drive_equipment_unload( self )
	local ret = {}
	---- 参数检查
	if not self.no or type(self.no) ~= "number" then
		return { result = 1001 }
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "drive_equipment_unload" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "drive_equipment_unload" )

	--[[
		return { result = xx }
	--]]
	ret = DATA.car_equipment_lib.equipment_unload( self.no )

	if ret.result == 0 then
		skynet.timeout( 1 , function() 
			PROTECT.on_equipment_info_change( self.no , "unload" )

			if ret.owner_car_id and ret.owner_car_id ~= 0 then
				PROTECT.on_car_info_change( ret.owner_car_id , "equipment_unload" )
			end
		end ) 
	end

	local equip_data = PUBLIC.get_one_equipment_data( self.no )
	ret.base_data = equip_data.base_data
	
	PUBLIC.off_action_lock( "drive_equipment_unload" )
	return ret
end

------ 当一个装备 信息改变
function PROTECT.on_equipment_info_change( _eqp_no , _change_type )
	local eqp_data = PUBLIC.get_one_equipment_data( _eqp_no )

	eqp_data.change_type = _change_type

	PUBLIC.request_client( "on_drive_equipment_data_change" , eqp_data ) 
end



function PROTECT.init()

	--local ret = REQUEST.query_drive_all_car_data()
	--dump( { ret , DATA.my_id } , "xxxx--------------query_drive_all_car_data:"  )

	--ret = REQUEST.query_drive_car_data( { car_id = 1 } )
	--dump( { ret , DATA.my_id } , "xxxx--------------query_drive_car_data:" )

	---ret = REQUEST.drive_car_up_level( { car_id = 1 } )
	---dump( { ret , DATA.my_id } , "xxxx--------------drive_car_up_level:" )

	--local ret = REQUEST.query_drive_all_equipment()
	--dump( { ret , DATA.my_id } , "xxxx--------------query_drive_all_equipment:" )

	--local ret = REQUEST.query_drive_equipment_data( { no = 2 } )
	--dump( { ret , DATA.my_id } , "xxxx--------------query_drive_equipment_data:" )

	---local ret = REQUEST.drive_equipment_load( { no = 4 , car_id = 1 } )
	--dump( { ret , DATA.my_id } , "xxxx--------------drive_equipment_load:" )

end

return PROTECT
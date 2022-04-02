---- 策划的游戏配置 中心服务 ，由于 房间 or agent 升级模块等等都需要读取 策划的配置文件，所以，单独抽成一个中心服务
---- 这边处理最原始的 数据



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

---- 车辆配置 ， key = car_id  , value = cfg
DATA.game_car_config = nil

---- key = skill_id , value = { 配置字段 = 配置值 } , 这个支持配置的附加
DATA.chehua_skill_config = nil

---- 技能id 对应 type_id的 map 表示表 ，这个只能是 没有时赋值
DATA.chehua_skill_id_2_type_id_map = nil

---- key = type_id , value = cfg  ； cfg._skill_id_list 表示这个 type_id 涉及到的技能id
DATA.chehua_skill_type_id_config = nil


function CMD.get_game_car_config()
	return DATA.game_car_config
end

function CMD.get_chehua_skill_config()
	return DATA.chehua_skill_config
end

function CMD.get_chehua_skill_id_2_type_id_map()
	return DATA.chehua_skill_id_2_type_id_map
end

function CMD.get_chehua_skill_type_id_config()
	return DATA.chehua_skill_type_id_config
end

--- 获取 存粹 type_id 对应的 配置变量 - 值
function CMD.get_pure_chehua_skill_type_id_config()
	local tem = basefunc.deepcopy(DATA.chehua_skill_type_id_config)

	for type_id , data in pairs(tem) do
		data.id	 = nil
		data.type_id = nil
		data.skill_name	 = nil
		data.level	 = nil
		data.skill_rule = nil

		data._skill_id_list = nil
	end

	return tem
end


function PUBLIC.load_game_car_and_skill_config(_config)
	
	------ 策划技能配置
	DATA.chehua_skill_config = {}

	DATA.chehua_skill_id_2_type_id_map = {}

	DATA.chehua_skill_type_id_config = {}

	local deal_func = function(data)
		---- 这个type_id 需要的 技能id list , 
		local is_need_deal_skill_id_list = true
		data._skill_id_list = {}

		if data.skill_id then
			if type(data.skill_id) ~= "table" then
				data._skill_id_list = { data.skill_id }
			else
				data._skill_id_list = data.skill_id
			end
			is_need_deal_skill_id_list = false
		end

		DATA.chehua_skill_type_id_config[data.type_id] = data

		---- 找到技能对应 配置
		if data.skill_rule then
			---- 如果 只有一个 数字，说明 只配了这一个技能对应的配置
			if type( data.skill_rule ) == "number" then
				DATA.chehua_skill_config[ data.skill_rule ] = basefunc.merge( data , DATA.chehua_skill_config[ data.skill_rule ] )

				DATA.chehua_skill_id_2_type_id_map[ data.skill_rule ] = data.type_id
				
				if is_need_deal_skill_id_list then
					data._skill_id_list[#data._skill_id_list + 1] = data.skill_rule
				end
			elseif type( data.skill_rule ) == "string" then
				for skill_id , key_name_str in string.gmatch( data.skill_rule , "(%d+):([^;]+)" ) do
					print("xxx---------------aaaa:" , skill_id , key_name_str )
					if skill_id and key_name_str then
						local r_skill_id = tonumber(skill_id)
 						
						DATA.chehua_skill_config[r_skill_id] = DATA.chehua_skill_config[r_skill_id] or {}
						local tar_skill_cfg = DATA.chehua_skill_config[r_skill_id]

						DATA.chehua_skill_id_2_type_id_map[ r_skill_id ] = data.type_id

						if is_need_deal_skill_id_list then
							data._skill_id_list[#data._skill_id_list + 1] = r_skill_id
						end
						if type(key_name_str) == "string" then
							for k_name in string.gmatch( key_name_str , "([^,]+)" ) do
								print("xxx---------------bbbb:" , k_name )

								if not data[k_name] then
									error( string.format("xxx--------------no data[%s] for skill_rule !" , k_name) )
								end

								tar_skill_cfg[k_name] = data[k_name]

							end
						end


					end
				end
			end
		end
	end

	for no , data in pairs(_config.skill_base) do
		
		deal_func( data )

	end

	for no , data in pairs(_config.equipment_skill) do
		
		deal_func( data )

	end
	
	---------------------- 车辆配置
	DATA.game_car_config = {}
	---- main
	for key,data in pairs(_config.car_base) do
		local slot_skill = {}

		---- 解析 车身上的技能 ， skill_type = type_id
		if type(data.slot_skill) == "string" then
			for skill_type , type_id in string.gmatch( data.slot_skill , "([^;]+):(%d+)" ) do
				print("xxx---------------aaaa:" , skill_type , type_id )
				if skill_type and type_id then
					local r_type_id = tonumber(type_id)
 						
					slot_skill[ skill_type ] = r_type_id
				end
			end
		end


		data.slot_skill = slot_skill
		
		
		DATA.game_car_config[data.id] = data
	end

	---- 可以发出一个消息，外部收到之后，重新请求数据
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "trigger_msg" , { name = "on_drive_game_car_and_skill_server_change"  }  )

	--dump( DATA.chehua_skill_config , "xxxxx-----------------------DATA.chehua_skill_config:" )


end

function CMD.start( _service_config )

	DATA.service_config = _service_config

	----- 读取配置
	---- 策划的 车 和技能配置
	nodefunc.query_global_config( "drive_game_car_and_skill_server" , function(...) PUBLIC.load_game_car_and_skill_config(...) end )

end

base.start_service()
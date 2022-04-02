------- 加载配置中心

require "normal_enum"
local skynet = require "skynet_plus"
require "skynet.manager"
require"printfunc"
local nodefunc = require "nodefunc"
local base=require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

--- 路面奖励类型 对应 type_id 的map
DATA.road_award_type_id_map = {
	start=
	{
		road_award_type = "start",
		type_id = 47,
	},
	gj_center=
	{
		road_award_type = "gj_center",
		type_id = 48,
	},
	big=
	{
		road_award_type = "big",
		type_id = 49,
	},
	gz_center=
	{
		road_award_type = "gz_center",
		type_id = 50,
	},
	radar_center=
	{
		road_award_type = "radar_center",
		type_id = 51,
	},
}

----- 配置项，type_id 对应 技能id
DATA.sample_award_map = {
	[1]= { skill_id =  2007 } ,
	[2]= { skill_id =  2012 } ,
	[3]= { skill_id =  2006 } ,
	[4]= { skill_id =  2013 } ,
	[5]= { skill_id =  2005 } ,
	[6]= { skill_id =  2011 } ,
	[7]= { skill_id =  2004 } ,
	[8]= { skill_id =  2010 } ,
	[9]= { skill_id =  6003 } ,
	[10] = { skill_id = 6004  } ,
	[11] = { skill_id = 6005  } ,
	[12] = { skill_id = 6006  } ,
	[13] = { skill_id = 6007  } ,
	[14] = { skill_id = 6000  } ,
	[15] = { skill_id = 6009  } ,
	[16] = { skill_id = 6001  } ,
	[17] = { skill_id = 6010  } ,
	[18] = { skill_id = 6002  } ,
	[19] = { skill_id = 6011  } ,
	[20] = { skill_id = 3000  } ,
	[21] = { skill_id = 3001  } ,
	[22] = { skill_id = 20005   } ,
	[23] = { skill_id = 4000  } ,
	[24] = { skill_id = 4001  } ,
	[25] = { skill_id = 4002  } ,
	[26] = { skill_id = 5003  } ,
	[27] = { skill_id = 5001  } ,
	[28] = { skill_id = 20003   } ,
	[29] = { skill_id = 20004   } ,
	[30] = { skill_id = 20011   } ,
	[31] = { skill_id = 20012   } ,
	[32] = { skill_id = 20008   } ,
	[33] = { skill_id = 20014   } ,
	[34] = { skill_id = 20013   } ,
	[35] = {  } ,
	[36] = { skill_id = 2001 } ,
	[37] = { skill_id = 2014 } ,
	[43] = { skill_id = 20007 } ,
	[44] = { skill_id = 5002 } ,
	[45] = { skill_id = 20001 } ,
	[46] = { skill_id = 20002 } ,
	[49] = { skill_id = 2008 } ,
	[52] = { skill_id = 5005 } ,
	[53] = { skill_id = 2002 } ,
	[54] = { skill_id = 20009 } ,
	[57] = { skill_id = 6012 } ,
	[58] = { skill_id = 6013 } ,
	[59] = { skill_id = 5006 } ,
	[60] = { skill_id = 5008 } ,
	[61] = { skill_id = 20006 } ,
	[62] = { skill_id = 20010 } ,
	[63] = { skill_id = 20015 } ,
	[64] = { skill_id = 3002 } ,
	[65] = { skill_id = 20018 } ,
	[66] = { skill_id = 4003 } ,
	[68] = { skill_id = 20017 } ,
	[67] = { skill_id = 4004 } ,
	[69] = { skill_id = 2017 } ,
	[70] = { skill_id = 2018 } ,
	[72] = { skill_id = 1022 } ,
	[73] = { skill_id = 1023 } ,
	[74] = { skill_id = 2019 } ,
	[75] = { skill_id = 2020 } ,
	[76] = { skill_id = 2021 } ,
	[77] = { skill_id = 2022 } ,
	[78] = { skill_id = 2023 } ,
	[79] = { skill_id = 2024 } ,
	[80] = { skill_id = 2025 } ,
	[83] = { skill_id = 1024 } ,
	[84] = { skill_id = 1025 } ,
	[85] = { skill_id = 2026 } ,
	[86] = { skill_id = 6014 } ,
	[87] = { skill_id = 6015 } ,
	[88] = { skill_id = 6016 } ,
	[89] = { skill_id = 1027 } ,
	[94] = { skill_id = 6017 } ,
	[95] = { skill_id = 6018 } ,
	[96] = { skill_id = 6019 } ,
	[97] = { skill_id = 6020 } ,
	[98] = { skill_id = 1028 } ,


}


function PUBLIC.load_game_run_obj_config(_config)
	DATA.game_run_obj_config = {}

	--- 参数
	local arg = {}
	if _config.arg then
		for key,data in pairs( _config.arg ) do
			arg[ data.arg_id ] = arg[ data.arg_id ] or {}
			local tar_data = arg[ data.arg_id ]

			tar_data[ data.arg_type ] = { arg_value = data.arg_value , value_type = data.value_type , overlay_rule = data.overlay_rule }
		end
	end

	--- main

	for key,data in pairs( _config.main ) do
		local arg_data = basefunc.deepcopy( arg[ data.id ] or {} )
		
		----- 把arg的参数 合并过来
		DATA.game_run_obj_config[ data.id ] = basefunc.merge( arg_data , data )
	end

end

function PUBLIC.load_skill_config(_config)
	DATA.skill_config = {}

	
	---- 工作 前置条件
	local work_condition = {}
	if _config.work_condition then
		for key,data in pairs(_config.work_condition) do
			work_condition[ data.condition_id ] = work_condition[ data.condition_id ] or {}
			local tar_data = work_condition[ data.condition_id ]

			tar_data[data.condition_name] = { condition_value = data.condition_value , judge_type = data.judge_type , overlay_rule = data.overlay_rule }
		end
	end

	---- 触发消息的条件
	local trigger_msg_condition = {}
	if _config.trigger_msg_condition then
		for key,data in pairs(_config.trigger_msg_condition) do
			trigger_msg_condition[ data.condition_id ] = trigger_msg_condition[ data.condition_id ] or {}
			local tar_data = trigger_msg_condition[ data.condition_id ]

			----- 这里直接处理载入
			------------------ 做验证
			--[[local tar_vec = { func = nil , _env = {setmetatable=setmetatable , _error = error , P = PUBLIC } }

		    local tar_dsl_str = "setmetatable(_ENV,{__index=... , __newindex = function() _error('canot change variant!') end}) if " .. data.conditon_dsl .. " then return true else return false end"
		    
		    tar_vec.func = load( tar_dsl_str , nil , "t" , tar_vec._env )
		    tar_vec.conditon_dsl = tar_dsl_str

		    tar_data[#tar_data + 1] = tar_vec--]]
		    
		    tar_data[#tar_data + 1] = data
		end
	end

	---- 触发模式
	local work_module = {}
	if _config.work_module then
		--- 用 ipairs 保证顺序
		for key,data in ipairs(_config.work_module) do
			work_module[ data.skill_id ] = work_module[ data.skill_id ] or {}
			local tar_data = work_module[ data.skill_id ]

			data.trigger_msg_condition = basefunc.deepcopy( trigger_msg_condition[ data.trigger_msg_condition ] or {} )
			data.work_condition = basefunc.deepcopy( work_condition[ data.work_condition ] or {} )

			tar_data[#tar_data + 1] = data
		end
	end
	---- main
	for skill_id , data in pairs(_config.skill) do
		data.life_module = basefunc.deepcopy( _config.life_module[ data.life_module ] or {} )
		data.work_module = basefunc.deepcopy( work_module[ data.id ] or {} )

		---- 处理 标签 tag  ; 标签一定有，并且是列表，map 表
		data.tag = basefunc.list_to_map(data.tag)
		---- 
		data.overlay_max = data.overlay_max

		------- 暂时
		--if data.id ~= 1007 and data.id ~= 1008 then
		DATA.skill_config[data.id] = data
		--end
	end

	-------------- 处理 数值对应
	local deal_work_buff_obj = function( _skill_id , _old_vec , _obj_config , _deal_tag , _map )
		local old_vec = _old_vec
		--local new_vec = {}
		if type(old_vec) ~= "table" then
			old_vec = { old_vec }
		end

		for key , obj_id in ipairs(old_vec) do
			local real_obj_id = PUBLIC.get_skill_cfg_obj_data( obj_id )

			if real_obj_id and _obj_config[real_obj_id] and not _deal_tag[real_obj_id] then
				_deal_tag[real_obj_id] = true
				--PUBLIC.convert_chehua_config( _obj_config[real_obj_id] , _skill_id)

				---- 赋值 对应关系， 用后面的顶掉前面的; 但是 技能id 和 有配置数据的 obj_id ，buff_id 只能是一一对应
				_map[real_obj_id] = _skill_id
			end
		end

		--return new_vec
	end

	local dealed_work_obj_id = {}
	local dealed_word_buff_id = {}

	for skill_id , data in pairs(DATA.skill_config) do
		---- 先把能转的数值都转了
		-- PUBLIC.convert_chehua_config(data , skill_id)
		---- 处理 创建 work_obj 和 buff_obj
		if data.work_module then
			for _ , work_module_data in pairs(data.work_module) do
				if type(work_module_data.work_obj_id) ~= "table" then
					work_module_data.work_obj_id = { work_module_data.work_obj_id }
				end
				if type(work_module_data.buff_id) ~= "table" then
					work_module_data.buff_id = { work_module_data.buff_id }
				end

				deal_work_buff_obj( skill_id , work_module_data.work_obj_id , DATA.game_run_obj_config , dealed_work_obj_id , DATA.work_id_2_skill_id_map )
				
				deal_work_buff_obj( skill_id , work_module_data.buff_id , DATA.game_buff_config , dealed_word_buff_id , DATA.buff_id_2_skill_id_map )

				----- 处理每个 work_module 的 消息条件 ( 这个已经是处理了 引用了的 )
				--[[for _k , _msg_cond in pairs( work_module_data.trigger_msg_condition ) do

					local tar_vec = { func = nil , _env = {setmetatable = setmetatable , _error = error , P = PUBLIC } }
				    local tar_dsl_str = "setmetatable(_ENV,{__index=... , __newindex = function() _error('canot change variant!') end}) if " 
				    						.. _msg_cond.conditon_dsl .. " then return true else return false end"
				    
				    tar_vec.func = load( tar_dsl_str , nil , "t" , tar_vec._env )
				    tar_vec.conditon_dsl = _msg_cond.conditon_dsl

				    work_module_data.trigger_msg_condition[_k] = tar_vec
				end--]]

			end
		end

	end


	---- 这里获取的 只是带了 $ 符号的配置
	--dump( DATA.skill_config , "xxxx-------------------DATA.skill_config:" )

	--dump( DATA.game_run_obj_config , "xxxx-------------------DATA.game_run_obj_config:" )
end

---


------ 如果 run_obj 的配置更新了，这个可能也有更新，因为用到了 run_obj 的配置
function PUBLIC.load_game_map_config(_config)
	DATA.game_map_config = {}

	DATA.map_road_award_lib = {}

	if _config.road_award_lib then
		for key,data in pairs(_config.road_award_lib) do
			DATA.map_road_award_lib[ data.id ] = DATA.map_road_award_lib[ data.id ] or {}
			local tar_data = DATA.map_road_award_lib[ data.id ]

			data.weight = data.weight or 1
			data.refresh_tag = basefunc.list_to_map( data.refresh_tag )

			--if data.award_type == "skill" then
				--data.award_skill_data = {}

				--data.award_skill_data = basefunc.deepcopy( DATA.skill_config[ data.award_id ] or {} )

				--local skill_data = basefunc.deepcopy( DATA.skill_config[ data.award_id ] or {} )

			--end


			tar_data[#tar_data + 1] = data
		end
	end

	

	---- 已经载入过的 map_award_cfg
	local load_map_cfg = {}

	for key,data in pairs(_config.map_info) do
		local road_cfg_id = data.road_cfg_id

		if road_cfg_id and _config[ road_cfg_id ] then
			 
			if not load_map_cfg[ road_cfg_id ] then
				load_map_cfg[ road_cfg_id ] = _config[ road_cfg_id ]
				local tar_data = load_map_cfg[ road_cfg_id ]


				for _key,_data in pairs(tar_data) do
					_data.award_library_data = basefunc.deepcopy( DATA.map_road_award_lib[ _data.award_library_id ] or {} )

					_data.side = basefunc.list_to_map( _data.side )
				end
				----
				
			end
		end
		data.road_cfg_data = basefunc.deepcopy( load_map_cfg[ road_cfg_id ] or {} )

		--data.road_award_event = basefunc.deepcopy( data.road_award_event and award_create_event[ data.road_award_event ] or {} )

		DATA.game_map_config[data.map_id] = data
	end

	--dump(DATA.game_map_config , "xxx-----------------DATA.game_map_config :")

end


function PUBLIC.load_map_barrier_config(_config)
	DATA.map_barrier_config = {}

	----
	--[[local skill = {}
	for key,data in pairs(_config.skill) do
		skill[data.id] = skill[data.id] or {}
		local tar_data = skill[data.id]

		tar_data[#tar_data + 1] = data
	end--]]

	for key,data in pairs(_config.main) do
		if type(data.skill) ~= "table" then
			data.skill = { data.skill }
		end
		
		data.skill_data = data.skill --basefunc.deepcopy( data.skill and skill[data.skill] or {} )

		DATA.map_barrier_config[data.id] = data
	end


end

----- 加载 动画 时间配置
function PUBLIC.load_game_movie_config(_config)
	DATA.game_movie_time_config = {}

	local condition = {}
	for key,data in pairs( _config.condition ) do
		condition[data.id] = condition[data.id] or {}
		local tar_data = condition[data.id]

		tar_data[ data.condition_name ] = { condition_value = data.condition_value , judge_type = data.judge_type }
	end

	for key,data in pairs( _config.main ) do

		data.condition_data = basefunc.deepcopy( data.arg_condition and condition[ data.arg_condition ] or {} )

		DATA.game_movie_time_config[ data.movie_name ] = data
	end

end

function PUBLIC.load_buff_config(_config)
	DATA.game_buff_config = {}

	--- 参数
	local arg = {}
	if _config.arg then
		for key,data in pairs( _config.arg ) do
			arg[ data.arg_id ] = arg[ data.arg_id ] or {}
			local tar_data = arg[ data.arg_id ]

			tar_data[ data.arg_type ] = { arg_value = data.arg_value , value_type = data.value_type , overlay_rule = data.overlay_rule }
		end
	end

	--- main

	for key,data in pairs( _config.main ) do
		local arg_data = basefunc.deepcopy( arg[ data.id ] or {} )
		
		if data.condition then
			local tar_vec = { func = nil , _env = {setmetatable = setmetatable , _error = error , P = PUBLIC } }
			local tar_dsl_str = "setmetatable(_ENV,{__index=... , __newindex = function() _error('canot change variant!') end}) if " 
					    						.. data.condition .. " then return true else return false end"
					    
			tar_vec.func = load( tar_dsl_str , nil , "t" , tar_vec._env )
			tar_vec.conditon_dsl = data.condition
			
			--- 指向 表
			data.condition = tar_vec
		end

		----- 把arg的参数 合并过来
		DATA.game_buff_config[ data.id ] = basefunc.merge( arg_data , data )
	end
	
end

----- 载入 道具配置
function PUBLIC.load_tool_config(_config)
	DATA.game_tools_config = {}

	if _config.main then
		for id , data in pairs(_config.main) do
			--[[if type(data.skill) ~= "table" then
				data.skill = { data.skill }
			end--]]

			data.use_cond = basefunc.list_to_map( data.use_cond )

			DATA.game_tools_config[data.id] = data

		end
	end

end

function PUBLIC.load_game_map_award_config( _config )
	DATA.map_road_award_lib = {}

	---- 处理所有的库 ， 把库数据组装到 第一级数据中
	for key,data in pairs(_config) do
		----- 处理所有的奖励库
		if string.sub( key , 1 , 12 ) == "award_group_" then
			local award_group_vec = {}
			for _key,_data in pairs(data) do
				award_group_vec[_data.group_id] = award_group_vec[_data.group_id] or {}
				local tar_data = award_group_vec[_data.group_id] 

				tar_data[#tar_data + 1] = _data
			end

			DATA.map_road_award_lib[key] = award_group_vec
		end
	end

	----- 处理要分组的分车等 信息库
	for key,data in pairs(_config) do
	---- 处理所有的使用奖励库
		if string.sub( key , 1 , 19 ) == "groupObj_gourp_cfg_" then
			local groupObj_gourp_cfg_vec = {}
			for _key,_data in pairs(data) do
				groupObj_gourp_cfg_vec[_data.type_id] = groupObj_gourp_cfg_vec[_data.type_id] or {}
				local tar_data = groupObj_gourp_cfg_vec[_data.type_id]

				if not DATA.map_road_award_lib[ _data.group_cfg_name ] then
					error("xxxx------------ groupObj_gourp_cfg_ no group_cfg_name:" , _data.group_cfg_name )
				end

				local for_select_group = DATA.map_road_award_lib[ _data.group_cfg_name ]
				_data.group = type(_data.group) == "table" and _data.group or { _data.group }

				_data.group_data = {}
				for k,group_id in ipairs( _data.group ) do
					if not for_select_group[group_id] then
						error("xxxx------------ not for_select_group[group_id]:" , _data.group_cfg_name , group_id )
					end
					_data.group_data[#_data.group_data + 1] = for_select_group[group_id]
				end

				tar_data[_data.car_id] = _data
			end

			DATA.map_road_award_lib[key] = groupObj_gourp_cfg_vec
		end
	end


	----- 处理刷新时间
	local road_refresh_event = {}
	if _config.road_refresh_event then
		for key,data in pairs( _config.road_refresh_event ) do
			road_refresh_event[data.id] = road_refresh_event[data.id] or {}
			local tar_data = road_refresh_event[data.id] 

			---- 直接数据 平铺过来
			data.mapAward_refresh_cfg = data.mapAward_refresh_cfg and _config[ data.mapAward_refresh_cfg ]

			tar_data[ #tar_data + 1 ] = data

		end
	end

	----- 每回合 开始 送的道具的配置
	local tool_award_rule = {}
	if _config.tool_award_rule then
		for key,data in pairs( _config.tool_award_rule ) do
			tool_award_rule[data.id] = tool_award_rule[data.id] or {}
			local tar_data = tool_award_rule[data.id]

			if not DATA.map_road_award_lib[ data.group_cfg_name ] then
				error("xxxx------------ tool_award_rule no group_cfg_name:" , data.group_cfg_name )
			end

			local for_select_group = DATA.map_road_award_lib[ data.group_cfg_name ]

			if not for_select_group[ data.group ] then
				error("xxxx------------ not for_select_group[group_id] 22:" , data.group_cfg_name , data.group )
			end
			data.group_data = { for_select_group[ data.group ] }


			tar_data[ data.car_id ] = data
		end
	end

	---- 道具奖励事件
	local tool_award_event = {}
	if _config.tool_award_event then
		for key,data in pairs( _config.tool_award_event ) do
			tool_award_event[data.id] = tool_award_event[data.id] or {}
			local tar_data = tool_award_event[data.id] 

			data.award_rule_data = data.award_rule and tool_award_rule[ data.award_rule ]

			tar_data[ #tar_data + 1 ] = data

		end
	end

	---- 固定发奖的 顺序
	local fix_move_list = {}
	if _config.fix_move_list then
		for key,data in ipairs( _config.fix_move_list ) do
			fix_move_list[data.id] = fix_move_list[data.id] or {}
			local tar_data = fix_move_list[data.id]

			tar_data[#tar_data + 1] = data
		end
	end

	----
	for key,data in pairs(_config.main) do

		data.mapAward_createInfo_cfg = _config[ data.mapAward_createInfo_cfg ]

		data.mapAward_init_cfg = _config[ data.mapAward_init_cfg ]

		data.groupObj_gourp_cfg = DATA.map_road_award_lib[ data.groupObj_gourp_cfg ]

		--data.sample_award_map = _config[ data.sample_award_map ]

		--data.road_award_type_id_map = _config[ data.road_award_type_id_map ]

		----
		data.road_refresh_event = data.road_refresh_event and road_refresh_event[ data.road_refresh_event ]

		data.tool_award_event = data.tool_award_event and tool_award_event[ data.tool_award_event ]

		--data.car_huihe_award = car_huihe_award_cfg[ data.car_huihe_award ]

		data.fix_move_list = fix_move_list[ data.fix_move_list ]

		DATA.map_road_award_lib[data.map_id] = data
	end


	--dump(DATA.map_road_award_lib , "xxxx---------------------DATA.map_road_award_lib:")




end


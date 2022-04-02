------ 赛车游戏， ai 分数系统模块

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

DATA.ai_grade_system_protect = {}
local PROTECT = DATA.ai_grade_system_protect

require ("tuoguan_service.ai_grade_system.ai_fuzhu_lib")

----- 请求配置
require ( "driver_room_service.game_scene.driver_game_cfg_center" )

----- 最大的ai分数
PROTECT.max_score = 999999

----- 忽略数据的概率
PROTECT.ignore_gl = 0.0001

------ 环境数据
--[[
	my_seat = xx,          -- 要处理的座位号
	enemy_seat = xxx ,     -- 地方座位号
	
	total_move_gl = ,      -- 总的移动概率 ， (默认是 1 , 100% ， 但是当踩到拦截路障，可能有20%概率同行，那么这个值就被改成了 0.2 )
	

	[seat_num_1] = {
		money = ,          -- 钱
		car_pos = ,        -- 车位置
		car_id = ,         -- 车id
		car_hp = ,         -- 车的当前血量
		car_max_hp = ,     -- 车的最大血量,(经过buff 运算之后的值)
		car_at = ,         -- 车攻击力，倾向于buff影响的值,(经过buff 运算之后的值)
		car_sp = ,         -- 车速度（经过buff处理）
		car_extra_move_num -- 车额外移动步数
		car_base_at = ,
	
		sp_award_extra_num , --路面 加速度 的奖励的额外奖励数量(经过buff 运算之后的值)
		at_award_extra_num , --路面 加攻击 的奖励的额外奖励数量(经过buff 运算之后的值)
		hp_award_extra_num , --路面 加血 的奖励的额外奖励数量(经过buff 运算之后的值)
		
		small_daodan_award_extra_num ,    ---- 小导弹 额外奖励数量
		n2o_award_extra_num ,             ---- 冲刺   额外奖励数量
		tool_award_extra_num ,            ---- 道具   额外奖励数量
		car_award_extra_num ,             ---- 车升级 额外奖励数量

		--- buff = ,           -- 有哪些buff
		
		tag = { [tag_name] = tag_value } , ---标签，不管是车上还是 人上的

		tools = {  }       -- 有哪些道具      , key = type_id , value = { type_id = x , num = x , spend_mp = x }

		nor_op_mp = ,          -- 普通操作的 剩余 mp
		nor_op_id = ,          -- 每次普通操作的唯一编号
	
		--map_barrier = {}   -- 有哪些地图障碍  ，key = road_id , value = 

		--------------------- 额外的数据
 
		tank_bullet_num = ,           坦克特有
		tank_attack_range = ,  坦克特有
		tank_max_bullet_num = ,   坦克特有

	},
	[seat_num_2] = {
		
	}
	
	--- 地图格子总数
	map_length =

	--- 小油门的移动步数
	small_youmen_move_step

	---- 可以双倍奖励的
	can_double_award = {
		[type_id] = true,
	}

	---- 地图奖励
	map_award = {
		[road_id] = { type_id = , is_use = }
	}

	---- 地图障碍
	map_barrier = {
		[road_id] = { [no] = { no = , road_id = x ,  id = barrier_id , group = x , } }
	}

	---- type_id  2  tool_id 的map
	type_id_2_tool_id = { [type_id] = tool_id }

	--地图格子
	map_cfg = {
		[road_id] = pos,
	}



--]]
---- 游戏环境数据
PROTECT.game_data = nil

---- 消息 通道
PROTECT.msg_channel = {}

---- 效果模式数据 key = car_id , value = { [index] = module_obj }
PROTECT.effect_module = {}
---- 分数判定模块
PROTECT.score_judge_module = {}

---- 策划配置的 技能数据
PROTECT.cehua_skill_config = {}


---效果枚举
PROTECT.effect_type = {
	add_sp = "add_sp" ,               --- 加速度

	add_at = "add_at",

	add_move_pos = "add_move_pos" ,   --- 移动位置增加

	add_hp = "add_hp" ,     --- 加血or伤害 ，正为加血，负为伤害

	big_skill = "big_skill" , ---- 大招

	play_again = "play_again" ,   ---- 再来一次

	add_tank_bullet_num = "add_tank_bullet_num"    ----坦克经过起点子弹增加

}

---- 监听消息
function PROTECT.add_msg_listener( _car_id , _obj , _msg_table )
	if PROTECT.msg_channel and PROTECT.msg_channel[_car_id] then
		local msg_dispatcher = PROTECT.msg_channel[_car_id]

		msg_dispatcher:register( _obj , _msg_table)
	end
	
end
---- 删除消息
function PROTECT.delete_msg_listener( _car_id , _obj )
	if PROTECT.msg_channel and PROTECT.msg_channel[_car_id] then
		local msg_dispatcher = PROTECT.msg_channel[_car_id]

		msg_dispatcher:unregister( _obj )
	end
end
---- 触发消息
function PROTECT.trriger_msg( _car_id , _msg_name , ... )
	if PROTECT.msg_channel and PROTECT.msg_channel[_car_id] then
		local msg_dispatcher = PROTECT.msg_channel[_car_id]
		msg_dispatcher:call( _msg_name , ... )
	end
end


----ai配置
PROTECT.ai_config = {

	--[[
	car = {
		---- 车的id
		[1] = {
			car_id = 1,
			---- 效果处理 模块
			effect_module = {
				---- index
				[1] = {
					module_name = "effect_module_add_sp",
					type_id = 1,

					arg = {
						add_value = 2,
					},
				},
				[2] = {
					module_name = "effect_module_add_sp",
					type_id = 2,

					arg = {
						add_value = 4,
					},
				},

			},
			---- 分数判定 模块
			score_judge_module = {
				[1] = {
					module_name = "score_judge_add_sp" ,

				},
			},
		},

	}--]]
}

---------------------------------------------------------------------------------------- 处理 决策点 ↓ ---------------------------------------------------------------------------
---- 处理不同的决策点 , 外部的调用接口
--[[
	return {
		op_type = xxx ,
		op_arg_1 = n ,
	}
--]]
function PROTECT.deal_decision( _decision_name , _game_data , ... )
	if _decision_name and type(_decision_name) == "string" and PROTECT[ "deal_decision_" .. _decision_name ] and type( PROTECT[ "deal_decision_" .. _decision_name ] ) == "function" then 
		local ret = PROTECT[ "deal_decision_" .. _decision_name ]( _game_data , ...)

		return ret
	end
end

---- 处理 普通操作 决策点
--[[
	decision_data = {
		name = xxx, --- 决策点名

		op_data = {
			[index] = {
				decision_name = ,     --- 决策点的名字(后面打分可能要用)
				op_type = xx,         --- 操作类型
				op_arg_1 = n,         --- 操作参数
				effect_data = {            --- 原始的效果集合
					[index] = { effect = xx , tar_seat = xx , value = xx , gl = xx }
				},
				effect_avg_map = {    ---- 效果平均值的map , key = 效果名，value = 平均值
					[effect_name] = {
						[tar_seat_1] = avg_value,
						
					}
				},
				effect_score = {      -- 效果分数
					[effect_name] = {
						[tar_seat_1] = score ,
					}
				},
				score = 0,   --- 最终分数
			},
		},

	}
 
--]]
function PROTECT.deal_decision_nor_op( _game_data )
	

	---- 决策数据
	local decision_data = { name = DATA.decision_name.nor_op , op_data = {} }

	------------------------------------------------------------------------------------------
	---- 处理使用 道具 , 的概率 加 效果期望整理
	PROTECT.deal_effect_use_tool( _game_data , decision_data)

	---- 处理 小油门的 效果整理
	PROTECT.deal_effect_small_youmen( _game_data , decision_data)
	
	---- 处理 大油门的 效果整理
	PROTECT.deal_effect_big_youmen( _game_data , decision_data)
	------------------------------------------------------------------------------------------

	------ 效果搜集完之后，算出各个效果的数学期望(平均值)
	PROTECT.deal_decision_effect_avg_value( decision_data )

	------ 对值 进行打分 ， 每种车可能判断逻辑不同
	PROTECT.deal_decision_op_score( _game_data , decision_data )


	------ 选择最优的 操作 选项。
	--- 先排序
	--table.sort( decision_data.op_data , PROTECT.decision_sort_func )

	PROTECT.sort_decision_data(decision_data.op_data)


	-- dump(decision_data , "xxxx---------------------total___decision_data:")

	---- 这里肯定有操作数据，直接返回第一个
	if decision_data.op_data[1] then
		return decision_data.op_data[1]
	end

	return nil
end

----- 处理选择道具
function PROTECT.deal_decision_select_map_award( _game_data , _select_map_award )
	---- 决策数据
	local decision_data = { name = DATA.decision_name.select_map_award , op_data = {} }

	PROTECT.deal_effect_select_map_award( _game_data , decision_data , _select_map_award )

	------------------------------------------------------------------------------------------
	------ 效果搜集完之后，算出各个效果的数学期望(平均值)
	PROTECT.deal_decision_effect_avg_value( decision_data )

	------ 对值 进行打分 ， 每种车可能判断逻辑不同
	PROTECT.deal_decision_op_score( _game_data , decision_data )


	------ 选择最优的 操作 选项。
	--- 先排序
	--table.sort( decision_data.op_data , PROTECT.decision_sort_func )

	PROTECT.sort_decision_data(decision_data.op_data)

	-- dump(decision_data , "xxxx---------------------total___decision_data 22:")

	---- 这里肯定有操作数据，直接返回第一个
	if decision_data.op_data[1] then
		return decision_data.op_data[1]
	end

	return nil
end

----- 处理选择道路
function PROTECT.deal_decision_select_road( _game_data , _select_road , _op_data )
	---- 决策数据
	local decision_data = { name = DATA.decision_name.select_road , op_data = {} }

	PROTECT.deal_effect_select_road( _game_data , decision_data , _select_road , _op_data )

	------------------------------------------------------------------------------------------
	------ 效果搜集完之后，算出各个效果的数学期望(平均值)
	PROTECT.deal_decision_effect_avg_value( decision_data )

	------ 对值 进行打分 ， 每种车可能判断逻辑不同
	PROTECT.deal_decision_op_score( _game_data , decision_data )


	------ 选择最优的 操作 选项。
	--- 先排序
	--table.sort( decision_data.op_data , PROTECT.decision_sort_func )
	PROTECT.sort_decision_data(decision_data.op_data)

	-- dump(decision_data , "xxxx---------------------total___decision_data 33:")

	---- 这里肯定有操作数据，直接返回第一个
	if decision_data.op_data[1] then
		return decision_data.op_data[1]
	end

	return nil
end


---------------------------------------------------------------------------------------- 处理 决策点 ↑ ---------------------------------------------------------------------------


---- 创建一个 决策点的 操作数据
function PROTECT.create_one_decision_op_data( _decision_name , _op_type , _op_arg_1 )
	local op_data = { decision_name = _decision_name , op_type = _op_type , op_arg_1 = _op_arg_1 , effect_data = {} , score = 0  }

	return op_data
end


---- 处理某个决策的所有的 操作的效果的 平均值
function PROTECT.deal_decision_effect_avg_value( _decision_data )
	if _decision_data.op_data and type(_decision_data.op_data) == "table" then
		for key,data in pairs(_decision_data.op_data) do
			---- 算出 效果 平均值
			data.effect_avg_map = PROTECT.cal_one_effect_avg_value( data.effect_data )
			
		end
	end
end

------ 算出某个效果集合的  相同效果的数学期望值
function PROTECT.cal_one_effect_avg_value( _effect_vec )
	local effect_avg_map = {}

	if _effect_vec and type(_effect_vec) == "table" then
		for key, data in pairs(_effect_vec) do
			effect_avg_map[data.effect] = effect_avg_map[data.effect] or {}

			effect_avg_map[data.effect][data.tar_seat] = ( effect_avg_map[data.effect][data.tar_seat] or 0 ) + data.value * data.gl

		end
	end


	return effect_avg_map
end

--- 处理打分
function PROTECT.deal_decision_op_score( _game_data , _decision_data )

	local my_data = _game_data[ _game_data.my_seat  ]
	local my_car_id = my_data.car_id

	if _decision_data.op_data then
		for key,data in pairs( _decision_data.op_data ) do
			data.effect_score = data.effect_score or {}

			---- 效果平均值 map
			local effect_avg_map = data.effect_avg_map

			for effect_name,effect_data in pairs( effect_avg_map ) do
				for tar_seat , effect_value in pairs(effect_data) do

					data.effect_score[effect_name] = data.effect_score[effect_name] or {}

					PROTECT.trriger_msg( my_car_id , "deal_score_judge" , data.effect_score[effect_name] , _game_data , effect_name , tar_seat , effect_value  )
				end
				
			end

		end

		---- 分数求和
		for key,data in pairs( _decision_data.op_data ) do
			for effect_name , score_data in pairs( data.effect_score ) do
				for _tar_seat , score in pairs(score_data) do
					data.score = data.score + score
				end
			end
		end

	end
end

---------------------------------------------------------------------------- 搜集各种 操作效果 ↓ -----------------------------------------------------------------------------
---- 获得 效果 数据
--[[
	*
--]]
function PROTECT.deal_effect_use_tool( _game_data , _decision_data )
	
	------ 先获得自己有哪些道具
	local my_data = _game_data[ _game_data.my_seat  ]
	local my_car_id = my_data.car_id
	local my_tools = my_data.tools
	
	----
	for type_id , _data in pairs(my_tools) do

		local op_data = PROTECT.create_one_decision_op_data( _decision_data.name , DATA.player_op_type.use_tools , _game_data.type_id_2_tool_id[ type_id ] )
		table.insert( _decision_data.op_data , op_data )

		PROTECT.trriger_msg( my_car_id , "on_use_tool" , op_data.effect_data , _game_data , type_id , 1 )
	end
	
end

----- 处理 选择 奖励的效果
function PROTECT.deal_effect_select_map_award( _game_data , _decision_data , _select_map_award )
	local my_data = _game_data[ _game_data.my_seat  ]
	local my_car_id = my_data.car_id

	if _select_map_award and type(_select_map_award) == "table" then
		for key, type_id in pairs( _select_map_award ) do

			local op_data = PROTECT.create_one_decision_op_data( _decision_data.name , DATA.player_op_type.select_map_award , type_id )
			table.insert( _decision_data.op_data , op_data )

			PROTECT.trriger_msg( my_car_id , "on_select_award" , op_data.effect_data , _game_data , type_id , 1 )
		end
	end

end

---- 处理选择道路
function PROTECT.deal_effect_select_road(  _game_data , _decision_data , _select_road , _op_data)
	local my_data = _game_data[ _game_data.my_seat  ]
	local my_car_id = my_data.car_id

	if _select_road and type(_select_road) == "table" then
		for key, road_id in pairs( _select_road ) do

			local op_data = PROTECT.create_one_decision_op_data( _decision_data.name , DATA.player_op_type.select_road , road_id )
			table.insert( _decision_data.op_data , op_data )

			----- 如果是 选择传送，走的是，踩到的位置发奖的逻辑
			if _op_data and _op_data.logic_name == "car_select_road_transfer_obj" then
				--- 地图奖励
				local map_award_data = PROTECT.get_map_award_data( _game_data , road_id )

				if map_award_data and not map_award_data.is_use then
					map_award_data.is_use = true

					PROTECT.trriger_msg( my_car_id , "on_stay_road" , op_data.effect_data , _game_data , map_award_data.type_id , 1 , { road_id = road_id } )
				end
			end

			
		end
	end
end


----- 计算小油门的操作
function PROTECT.deal_effect_small_youmen( _game_data , _decision_data )

	local op_data = PROTECT.create_one_decision_op_data( _decision_data.name , DATA.player_op_type.small_youmen , nil )
	table.insert( _decision_data.op_data , op_data )

	-----由于可能会修改 游戏数据，所以会拷贝出来
	_game_data = basefunc.deepcopy( _game_data )

	---- 移动长度
	local step_len = _game_data.small_youmen_move_step

	local my_data = _game_data[ _game_data.my_seat ]
	local my_car_id = my_data.car_id

	for i = 1 , step_len do
		local stay_gl = 1 / step_len 
		local move_in_gl = 1 - ( (i - 1) * 1 / step_len )

		---- 移动 和 停留 概率得 * 总的移动概率
		stay_gl = stay_gl * _game_data.total_move_gl
		move_in_gl = move_in_gl * _game_data.total_move_gl

		---- 如果概率不够，则不移动了
		if move_in_gl <= 0 then
			break
		end
		
		---- 当前位置修改
		my_data.car_pos = my_data.car_pos + 1

		local now_car_pos = my_data.car_pos

		local now_road = PROTECT.pos_to_road_id( _game_data , now_car_pos )

		print("xxx-------------deal_effect_small_youmen road_id:" , now_road)

		----- 获得地图奖励
		local map_award_data = PROTECT.get_map_award_data( _game_data , now_road )

		---- 移动距离的 效果统计
		op_data.effect_data[#op_data.effect_data + 1] = { effect = PROTECT.effect_type.add_move_pos , tar_seat = _game_data.my_seat , value = 1 , gl = move_in_gl }

		---- 发出经过消息
		PROTECT.trriger_msg( my_car_id , "on_move_in_road" , op_data.effect_data , _game_data , move_in_gl , { road_id = now_road } )

		---- 发出停留消息
		if map_award_data and not map_award_data.is_use then
			map_award_data.is_use = true

			PROTECT.trriger_msg( my_car_id , "on_stay_road" , op_data.effect_data , _game_data , map_award_data.type_id , stay_gl , { road_id = now_road } )
		end


	end

	return effect_data
end

function PROTECT.deal_effect_big_youmen(_game_data , _decision_data)
	local op_data = PROTECT.create_one_decision_op_data( _decision_data.name , DATA.player_op_type.big_youmen , nil )
	table.insert( _decision_data.op_data , op_data )

	-----由于可能会修改 游戏数据，所以会拷贝出来
	_game_data = basefunc.deepcopy( _game_data )

	local my_data = _game_data[ _game_data.my_seat ]
	local my_car_id = my_data.car_id

	---- 移动长度
	local step_len = my_data.car_sp * _game_data.map_length + my_data.car_extra_move_step              

	for i=1 , step_len do
		local stay_gl = 0
		local move_in_gl = 1

		---- 移动 和 停留 概率得 * 总的移动概率
		stay_gl = stay_gl * _game_data.total_move_gl
		move_in_gl = move_in_gl * _game_data.total_move_gl

		---- 如果概率不够，则不移动了
		if move_in_gl <= 0 then
			break
		end

		---- 当前位置修改
		my_data.car_pos = my_data.car_pos + 1

		local now_car_pos = my_data.car_pos

		local now_road = PROTECT.pos_to_road_id( _game_data , now_car_pos )

		-----
		local map_award_data = PROTECT.get_map_award_data( _game_data , now_road )

		---- 移动距离的 效果统计
		op_data.effect_data[#op_data.effect_data + 1] = { effect = PROTECT.effect_type.add_move_pos , tar_seat = _game_data.my_seat , value = 1 , gl = move_in_gl }

		---- 发出经过消息
		PROTECT.trriger_msg( my_car_id , "on_move_in_road" , op_data.effect_data , _game_data , move_in_gl , { road_id = now_road } )

	end

	local step_long = _game_data.map_length
	for i=1,step_long do
		local stay_gl = 1/step_long
		local move_in_gl = 1 - ( (i - 1) / step_long )

		---- 移动 和 停留 概率得 * 总的移动概率
		stay_gl = stay_gl * _game_data.total_move_gl
		move_in_gl = move_in_gl * _game_data.total_move_gl

		---- 如果概率不够，则不移动了
		if move_in_gl <= 0 then
			break
		end

		---- 当前位置修改
		my_data.car_pos = my_data.car_pos + 1

		local now_car_pos = my_data.car_pos

		local now_road = PROTECT.pos_to_road_id( _game_data , now_car_pos )

		-----
		local map_award_data = PROTECT.get_map_award_data( _game_data , now_road )

		---- 移动距离的 效果统计
		op_data.effect_data[#op_data.effect_data + 1] = { effect = PROTECT.effect_type.add_move_pos , tar_seat = _game_data.my_seat , value = 1 , gl = move_in_gl }

		---- 发出经过消息
		PROTECT.trriger_msg( my_car_id , "on_move_in_road" , op_data.effect_data , _game_data , move_in_gl  , { road_id = now_road } )

		---- 发出停留消息
		if map_award_data and not map_award_data.is_use then

			map_award_data.is_use = true
			PROTECT.trriger_msg( my_car_id , "on_stay_road" , op_data.effect_data , _game_data , map_award_data.type_id , stay_gl , { road_id = now_road } )

		end
	end


	return effect_data
end

---------------------------------------------------------------------------- 搜集各种 操作效果 ↑ -----------------------------------------------------------------------------

---- 创建效果处理模块
function PROTECT.create_effect_module()
	for car_id , data in pairs(PROTECT.ai_config.car) do
		if data.effect_module then
			for index , module_data in pairs( data.effect_module ) do
				local module_name = "tuoguan_service.ai_grade_system.effect_module." .. module_data.module_name
				local ok , module_class = xpcall( require , basefunc.error_handle , module_name ) 
				
				if ok and module_class then

					---- 模块配置
					local module_cfg = basefunc.deepcopy( module_data )
					local other_cfg = { car_id = car_id }
					basefunc.merge( other_cfg , module_cfg )

					local obj = module_class.new( module_cfg )

					if obj then
						obj:init()

						PROTECT.effect_module[car_id] = PROTECT.effect_module[car_id] or {}
						local tar_data = PROTECT.effect_module[car_id]
						tar_data[#tar_data + 1] = obj
					end
				else
					print("xxxx -------------- require error ai effect_module :" , module_data.module_name )
				end

			end
		end

	end

end

function PROTECT.create_score_judge_module()
	for car_id , data in pairs(PROTECT.ai_config.car) do
		if data.score_judge_module then
			for index , module_data in pairs( data.score_judge_module ) do
				local module_name = "tuoguan_service.ai_grade_system.score_judge_module." .. module_data.module_name
				local ok , module_class = xpcall( require , basefunc.error_handle , module_name ) 

				if ok and module_class then

					---- 模块配置
					local module_cfg = basefunc.deepcopy( module_data )
					local other_cfg = { car_id = car_id }
					basefunc.merge( other_cfg , module_cfg )


					local obj = module_class.new( module_cfg )

					if obj then
						obj:init()

						PROTECT.score_judge_module[car_id] = PROTECT.score_judge_module[car_id] or {}
						local tar_data = PROTECT.score_judge_module[car_id]
						tar_data[#tar_data + 1] = obj
					end
				else
					print("xxxx -------------- require error ai score_judge_module :" , module_data.module_name )
				end

			end
		end

	end

end

------- 载入策划配置
function PROTECT.load_game_car_and_skill_config( _raw_config )
	PROTECT.cehua_skill_config = {}
	
	if _raw_config.skill_base then
		for key,data in pairs(_raw_config.skill_base) do
			PROTECT.cehua_skill_config[data.type_id] = data
		end
	end

	-- dump(PROTECT.cehua_skill_config , "xxxxx-----------------PROTECT.cehua_skill_config:")
end

---- 载入ai 配置
function PROTECT.load_game_ai_config(_raw_config )

	PROTECT.ai_config = {}

	---- 载入参数配置
	local arg = {}
	if _raw_config.arg then
		for key,data in pairs(_raw_config.arg) do
			arg[data.id] = arg[data.id] or {}
			local tar_data = arg[data.id]

			local arg_value = data.arg_value

			if type(arg_value) == "string" and string.find( arg_value , "(%d+):(.+)" ) then
				local _s,_e , type_id , arg_key = string.find( arg_value , "(%d+):(.+)" )

				type_id = tonumber(type_id)

				if not PROTECT.cehua_skill_config[type_id] or not PROTECT.cehua_skill_config[type_id][arg_key] then
					error( "xxxx----------------no cehua_skill_config for type_id:" .. type_id .. "," .. arg_key )
				end

				arg_value = PROTECT.cehua_skill_config[type_id][arg_key]
			end


			tar_data[ data.arg_type ] = arg_value
		end
	end

	---- 处理分数处理模块
	local score_judge_module = {}
	if _raw_config.score_judge_module then
		for key,data in pairs(_raw_config.score_judge_module) do
			score_judge_module[data.id] = score_judge_module[data.id] or {}
			local tar_data = score_judge_module[data.id]

			tar_data[#tar_data + 1] = data
		end
	end

	---- 效果处理模块
	local effect_module = {}
	if _raw_config.effect_module then
		for key,data in pairs(_raw_config.effect_module) do
			effect_module[data.id] = effect_module[data.id] or {}
			local tar_data = effect_module[data.id]

			data.arg_data = basefunc.deepcopy( arg[data.arg] )

			----- 直接合并过来
			basefunc.merge( data.arg_data , data )

			tar_data[#tar_data + 1] = data
		end
	end

	----- main
	PROTECT.ai_config.car = {}
	for key,data in pairs( _raw_config.main ) do

		data.effect_module = effect_module[ data.effect_module ] 
		data.score_judge_module = score_judge_module[ data.score_judge_module ] 

		PROTECT.ai_config.car[data.car_id] = data
	end

end

function PROTECT.init()
	---- 载入 策划 配置 
	nodefunc.query_global_config( "drive_game_car_and_skill_server" , function(...) PROTECT.load_game_car_and_skill_config(...) end )

	---- 载入 ai 配置
	nodefunc.query_global_config( "drive_game_ai_server" , function(...) PROTECT.load_game_ai_config(...) end )

	---- 创建消息通道
	for car_id , data in pairs( PROTECT.ai_config.car ) do
		PROTECT.msg_channel[ car_id ] = basefunc.dispatcher.new()
	end

	---- 创建 效果 处理模块
	PROTECT.create_effect_module()
	----- 创建分数 处理模块
	PROTECT.create_score_judge_module()

end

return PROTECT
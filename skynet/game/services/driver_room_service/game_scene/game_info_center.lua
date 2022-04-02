---- 游戏 的 信息中心

local basefunc = require "basefunc"
local base = require "base"
local skynet = require "skynet_plus"

local DATA = base.DATA 
local PUBLIC = base.PUBLIC
local CMD = base.CMD

local running_data_statis_lib = require "driver_room_service.game_scene.running_data_statis_lib"
require "driver_room_service.game_scene.game_run_system"

--local drive_move_test_server = require "drive_move_test_server"

DATA.game_info_center_protect = {}
local C = DATA.game_info_center_protect

--- 初始化 桌子 数据 ， 每次开游戏不能清的数据 ，
function C.init_table_info(_d , _t_num , _table_config)
	_d.table_config=_table_config

	---- 单例对象
	_d.single_obj={}
	
	---- 系统对象
	--[[
		kind_type =         种类类型
		group = -1 ,        --- 敌我分组，
		skill = { [skill_id_1] = skill_obj , [skill_id_2] = skill_obj },

	--]]
	_d.system_obj = { 
		kind_type = DATA.game_kind_type.system ,
		group = -1 ,
		skill = {} ,
	}

	--- 玩家信息，key  座位id
	--[[
		
		kind_type =         种类类型
		group = ,   --- 分组
		car_id = xxx , 进场时选的车的id
		
		duanwei_grade =  段位的大等级
		seat_num=_seat_num,
		id=DATA.my_id,  玩家id
		name=DATA.player_data.player_info.name,
		head_link=DATA.player_data.player_info.head_image,
		sex=DATA.player_data.player_info.sex,
		
		skill = {},   -- { [skill_id] = skill_obj , }
		---- 技能创建次数统计 -- { [skill_id_1] = num ,  }
		skill_created_statis = {}

		money = 0,
		last_move_car = nil,

		---- 自己的车的列表
		car = { [car_id] = car_obj , [car_id2] = car_obj2 },
		---- 大油门，小油门的 run_obj_id
		big_youmen_move_obj_id = ,
		small_youmen_move_obj_id = ,

	--]]
	_d.p_info={}

	_d.t_num = _t_num

	_d.player_money = 10000

	--- 座位对应玩家id , key座位id , value 是玩家id
	_d.p_seat_number={}
	--- 当前玩家数量
	_d.p_count=0
	--- 游戏类型
	_d.game_type = assert(_table_config.game_type)
	---座位数量，玩家数量
	_d.seat_count = GAME_TYPE_SEAT[_table_config.game_type] or 2

	_d.game_mode = assert(_table_config.game_mode)

	_d.game_id = assert(_table_config.game_id)

	---- 
	_d.running_data_statis_lib = running_data_statis_lib

	

	---- 从外部带进来的，基础值的改变 & 技能数据的改变 
	--[[
		[seat_num] = {
			[car_id] = {
				---- 这个是车的 直接设置的
				prop_set = {
				
					hp = n,   --- key 是字段名 ， n 是 最终值
					at = n,   --- key 是字段名 ， n 是 最终值
					sp = n,   --- key 是字段名 ， n 是 最终值

					level 
					star
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
				}
			
				skill_change = {
				---- 某种车的 技能的修改数据，or 创建数据 ，这里的数据需要和 基础数据叠加，才是最终数据 ； 用最终数据来创建车身上的技能 (包含了车升级 和 装备 带来的改变 )
				
					---- 如果只有 type_id 就是用默认的配置值，有 change_data 就把数据附加上
					skill_type = { 
					 	type_id = xxx , 
					 	change_data = { 
					 		key = xx , 
					 		key_2 = xx2 ,

					 	} 
					}  
					skill_type_2 = { 

					}
				},
				

			},


		}
	--]]
	_d.player_fujia_data = {}
	
end

function C.new_game(_d)

	--- 玩家的准备数据
	_d.ready = {}
	--- 准备的玩家数量
	_d.p_ready=0

	_d.ecs_world = nil
	--- 消息分发
	_d.msg_dispatcher = basefunc.dispatcher.new()

	---- 运行的 过程 数据 编号
	_d.running_process_no = 0

	---- 从上一个执行点，到 下一个执行的所有的数据
	_d.running_data = {}

	--- 总共的
	_d.total_running_data = {}

	--- 预估 过程动画 时间
	_d.game_process_time = 0

	---- 游戏 主流程 分发 基础操作 系统
	_d.game_dis_system = basefunc.hot_class.game_dis_system.new( _d )

	--- 运行 系统
	_d.game_run_system = basefunc.hot_class.game_run_system.new( _d )

	--------------------------------------------- 各种 唯一编号 ↓ ----------------------------------
	---- 车辆 编号自增key
	_d.car_no = 0
	---- 地图障碍的 自增key
	_d.barrier_no = 0

	_d.skill_no = 0 

	_d.buff_create_no = 0
	--------------------------------------------- 各种 唯一编号 ↑ ----------------------------------

	---- 在map_award 里面 处理
	_d.test_move_list = {}
	-- _d.test_move_list = basefunc.deepcopy( drive_move_test_server )

	---- 结算信息
	_d.settlement_info = {}

	---- 调试移动多少格 { [seat_num] = nn , [] }
	_d.debug_move_num = {  }

	---- 测试的 下一个 地图奖励
	_d.debug_next_map_award = {}

	---- 测试 操作权限，只管 nor_op 的
	_d.debug_nor_op_permit = {}

	--- 车辆信息 ,
	--[[ 
			[no1] = { 
					kind_type          种类  "car"
					group = xxx  , 分组
					seat_num $ : integer      # 所属座位号 ， 如果是系统的 ，则 seat_num为 system
					car_no 唯一编号
					car_id $ : integer        # 所属于 玩家的 第几辆车
					
					id $ : integer            # 车辆的 类型id
					name                      # 车名
					type                      # 车类型
					pinzhi                    # 车 品质
				    level $ : integer         # 等级
				    star                      # 星级
				    pos $ : integer           # 位置
					
					hd                        # 护盾

				    hp $ : integer            # 当前血量
				    base_hp                   # 基础的当前血量
				    hp_max $ : integer        # 最大血量
				    base_hp_max               # 基础的最大血量

				    at $ : integer            # 攻击
					base_at                   # 基础的 攻击

				    sp $ : integer            # 速度
				    base_sp                   # 基础速度
					
					bj_gl                     # 暴击概率
					miss_gl                   # miss 概率
					lj_gl                     # 连击概率
					lj_xishu                  # 连击系数
					bj_xishu                  # 暴击系数
					extra_lj_num              # 额外连击次数
					final_add_at              # 最终额外增加攻击

					extra_move_num
					is_attack  是否攻击
					is_move  是否在移动中

					fanshang                  # 反伤百分比
					sp_award_extra_num         # 吃到地图奖励的 加速 ，提升的百分比
					at_award_extra_num          # 吃到地图奖励的 攻击 ，提升的百分比
					hp_award_extra_num         # 吃到地图奖励的 血量 ，提升的百分比
					n2o_award_extra_num              单双倍资源卡    氮气
					small_daodan_award_extra_num	 小型导弹
					car_award_extra_num				 车辆升级	
					tool_award_extra_num			 道具



					skill = { [skill_id_1] = skill_obj , [skill_id_2] = skill_obj },
					
					--- 技能标志,已存在的技能
					-- skill_tag = { car_head = { level_up_index = 1, skill_id = skill_id1 } , car_body = skill_id2 ... }
					
					---- 技能创建次数统计 -- { [skill_id_1] = num ,  }
					skill_created_statis = {}
				
					---- 从库中 random or 3_c_1 中出来的 type_id的数量表;key = type_id , value = num
					lib_type_id_num_map = {}

					--- 配置
					config = ,

					tag = {},   --- 标签相关
					
					buff = { [buff_type1] = { [1] = buff_obj , [2] = buff_obj2 } , ... } , ---
				} , 
			[no2] = xxx }
	--]] 
	_d.car_info = {}

	--- 游戏结束的 圈数
	_d.map_game_over_circle = nil

	--- 地图长度
	_d.map_length = 0
	
	--地图id
	_d.map_id=nil 
	--地图 起点终点
	_d.map_start_id = nil
	_d.map_end_id = nil 

	--- 地图格子
	--[[
		_road_id = {
			type                   类型
			road_id                道路id
			road_award_type        奖励类型
		}
	--]]
	_d.map_road = {}
	---- 地图上的奖励 ，
	--[[
		---
	road_id = {
			road_id                   # 道路id
			road_award_type           # 大的道路奖励类型  big ...
			
			type_id                  # 奖励id  ( 普通奖励，道具箱，升级箱，(甚至改装中心) )  对应策划配置中的奖励id
			create_type               # 创建方式 ( skill 直接给奖励 , prop 直接给道具 )

			---choose_type               # 从库里面出来的方式  (, random 从库里面随机给 , n_c_1 从库里面选择n个出来 )
			---award_create_rule         # 从库里面选出来的规则
			---context_type		      #  自己库里面再创的东西的 create_type 是直接给还是给道具
			
			

			！！ 某些road_award_type（xx中心） or 某些 award_id，需要有从库里面出来的规则 ; 有对应库，可以用 road_award_type 和 award_id 来对应具体的库。

			----------------------
			use_times                 # 奖励使用多少次，删除
			road_award_create_type    #  奖励的创建方式 clear , random , 3_c_1
			award_list                #  具体的奖励 列表，clear类型的有，直接就创出来了
			award_library_data        # 奖励库数据
			award_library_type        # 奖励库的类型，如何从库里面出来

		}
	--]]
	_d.map_road_award = {}
	---- 使用次数
	_d.map_road_award_useTime = {}

	------------- 地图上的障碍
	--[[
		[road_id] = 
		{ 
			[barrier_no1] = 
			{
				kind_type = ,          --- 种类 类型，地图上的障碍

				no = ,            --- 唯一标志编号
				id = ,            --- 障碍的id
				type ,            --- 障碍类型
				road_id = ,           -- 所在地图 位置
				seat_num = ,      -- 属于哪个座位
				owner = ,         -- 所属者，是车 或 人 或 系统
				group = ,         -- 分组 ，用来判断敌我的

				skill = {[skill_id_1] = skill_obj , [skill_id_2] = skill_obj},       -- 道具拥有的 skill
				---- 技能创建次数统计 -- { [skill_id_1] = num ,  }
				skill_created_statis = {}
			}
			[barrier_no2] = {...}
		}

	--]]
	_d.map_barrier = {}


	----------- 道具
	--[[
		[seat_num] = {
			[id] = {
				id = ,        --- 
				type = ,      --- 类型
				num = ,       --- 有多少个
				spend_mp = ,  --- 消耗mp点数 
				is_end_op = , --- 是否结束 普通操作

				owner = ,     --- owner 一定是玩家 
				seat_num = ,  --- 属于哪个座位
				group = ,
				--skill = {[index1] = skill_id1 , [index2] = skill_id2 },       -- 道具拥有的 skill

				---- 技能创建次数统计 -- { [skill_id_1] = num ,  }
				--skill_created_statis = {}

				type_id = xxx,     --- 奖励类型id
			}
	
		}

		
	--]]
	_d.tools_info = {}



end

function C.create_map( _d , _map_type )
	if not _map_type or _map_type=="nor_map" then
		_d.map_length = #DATA.nor_map
		_d.map_road_data = DATA.nor_map
	end
end

---- 添加 玩家 技能
--[[function C.add_player_skill(_d , _seat_num , _skill_obj)
	_d.p_info[_seat_num] = _d.p_info[_seat_num] or {}

	_d.p_info[_seat_num][_skill_obj.id] = _skill_obj
end--]]

---- 添加 车 实体
function C.add_car( _d , _seat_num , _car_info)
	_d.car_info = _d.car_info or {}

	_d.car_info[ _car_info.car_no ] = _car_info

	---- 赋值玩家的车，引用上。
	_d.p_info[_seat_num].car = _d.p_info[_seat_num].car or {}
	local player_car_table = _d.p_info[_seat_num].car

	local car_id = #player_car_table + 1
	player_car_table[car_id] = _car_info

	_car_info.car_id = car_id
end




--- 设置 地图 长度
function C.set_map_len( _d , _map_length )
	_d.map_length = _map_length
end

----- 添加map_barrier
function C.add_map_barrier(_d , _road_id , _barrier_info)
	--local barrier_info = _d.map_barrier[_road_id]

	---- 之前有，先顶掉
	--if barrier_info then
	--	PUBLIC.delete_map_barrier(_d , _road_id )
	--end

	--_d.map_barrier[_road_id] = _barrier_info

	_d.map_barrier[_road_id] = _d.map_barrier[_road_id] or {}
	local tar_vec = _d.map_barrier[_road_id]
	tar_vec[ _barrier_info.no ] = _barrier_info

end


------------------------------------------------
---- 获得 玩家 要操作的车
function C.get_next_dis_car(_d , _seat_num)
	--- 这里可以加一段 ，处理玩家操作的哪个车 
	local p_info = _d.p_info[ _seat_num ]
	local player_car_info = p_info.car

	--- 上次 移动的 车计数 增加
	if not p_info.last_move_car then
		p_info.last_move_car = 1
	else
		p_info.last_move_car = p_info.last_move_car + 1
	end

	--- 超过了最大
	if player_car_info and p_info.last_move_car > #player_car_info then
		p_info.last_move_car = 1
	end

	local select_car_info = player_car_info[ p_info.last_move_car ]

	return select_car_info   -- p_info.last_move_car
end

-------------------------------------------------------------- 获取所有的玩家的数据 ↓ --------------------------------------------------
function C.get_total_game_data(_d)
	local total_data = {}

	total_data.system_data = C.get_total_system_data(_d)

	total_data.car_data = C.get_total_car_data(_d)
	total_data.players_info = C.get_total_player_data(_d)
	total_data.map_data = C.get_total_map_info(_d)

	--dump(total_data , "xxx-----------------get_total_game_data:")

	return total_data
end

function C.get_one_skill_data(_skill_obj)

	local skill_tag_list = {}
	if _skill_obj.tag then
		for _tag, _v in pairs(_skill_obj.tag) do
			skill_tag_list[#skill_tag_list + 1] = _tag
		end
	end

	return { 
		no = _skill_obj.no , 
		skill_id = _skill_obj.id , 
		skill_tag = skill_tag_list ,
		process_no = _skill_obj.create_skill_process_no , 
		life_value = _skill_obj.life_value ,
		overlay_num = _skill_obj.overlay_num ,
		other_data = _skill_obj.get_other_data and _skill_obj:get_other_data() or nil ,
	}
end

----- 获取 技能数据
function C.get_skill_data( _skill_vec )
	local _tar_vec = {}
	if _skill_vec then
		for skill_id,skill_obj in pairs(_skill_vec) do
			
			_tar_vec[#_tar_vec + 1] = C.get_one_skill_data( skill_obj )
		end
	end

	table.sort( _tar_vec , function( a , b) 
		return a.no < b.no
	end )

	return _tar_vec
end

---- 获取一个buff 的数据
function C.get_one_buff_data(_buff_obj)

	return {
		buff_no = _buff_obj.no ,
		buff_id = _buff_obj.id ,
		skill_id = _buff_obj.skill and _buff_obj.skill.id ,
		skill_owner_data = _buff_obj.skill and PUBLIC.get_game_owner_data( _buff_obj.skill.owner ) or {} ,
		other_data = _buff_obj.get_other_data and _buff_obj:get_other_data() or nil ,
	}
end

---- 获取buff列表的数据
function C.get_buff_data(_buff_vec)
	local tar_vec = {}
	if _buff_vec then
		for _buff_type , _type_vec in pairs( _buff_vec ) do
			for _key , buff_obj in ipairs( _type_vec ) do
				tar_vec[#tar_vec + 1] = C.get_one_buff_data(buff_obj)
			end
		end
	end

	return tar_vec
end

----  获取 系统 主体的 数据
function C.get_total_system_data(_d)
	local tart_data = {}

	if _d and _d.system_obj then
		local skill_datas = {}


		tart_data.skill_datas = C.get_skill_data( _d.system_obj.skill )
	end

	return tart_data
end

---- 获得所有的 车的数据
function C.get_total_car_data(_d)
	local tart_data = {}

	if _d and _d.car_info then
		for _car_no , car_data in pairs(_d.car_info) do

			----------------------------- 组装数据
			local skill_datas = C.get_skill_data( car_data.skill )

			--[[local skill_tags = {}
			if car_data.skill_tag then
				for skill_tag,skill_data in pairs(car_data.skill_tag) do
					skill_tags[#skill_tags + 1] = { skill_id = skill_data.skill_id  , tag_name = skill_tag }
				end
			end--]]

			--------------------------
			local tar_data = basefunc.deepcopy( car_data )
			tar_data.skill = nil
			tar_data.skill_tag = nil
			tar_data.config = nil
			tar_data.buff = nil

			tar_data.skill_datas = skill_datas
			-- tar_data.skill_tags = skill_tags

			tar_data.buff_datas = C.get_buff_data( car_data.buff )

			------ 需要用buff 来获取的列表
			local buff_value_vec = {
				at = true,
				sp = true ,
				bj_gl = true ,
				miss_gl = true ,
				lj_gl = true ,
				hp_max = true ,
			}

			for key,value in pairs( tar_data ) do
				if buff_value_vec[key] then
					tar_data[key] = DATA.car_prop_lib.get_car_prop( car_data , key ) 
				end
			end
			
			

			tart_data[#tart_data + 1] = tar_data

		end
	end

	return tart_data
end

---- 获得所有的 玩家的数据
function C.get_total_player_data(_d)
	local tart_data = {}

	if _d and _d.p_info then
		for _seat_num , data in pairs(_d.p_info) do

			local skill_id_vec = C.get_skill_data( data.skill )

			------ 收集玩家的道具数据
			local tools_data = {}
			local tools_map_data = {}
			if _d.tools_info[_seat_num] then
				for _tool_id , _tool_data in pairs( _d.tools_info[_seat_num] ) do
					if _tool_data.num > 0 then
						tools_data[#tools_data + 1] = { id = _tool_data.id , num = _tool_data.num , spend_mp = _tool_data.spend_mp , is_end_op = _tool_data.is_end_op }
					end
					tools_map_data[_tool_data.id] = { id = _tool_data.id , num = _tool_data.num , spend_mp = _tool_data.spend_mp , is_end_op = _tool_data.is_end_op }
				end
			end

			tart_data[#tart_data + 1] = {
				name = data.name ,
				head_link = data.head_link ,
				seat_num = data.seat_num ,
				sex = data.sex ,
				id = data.id ,
				car_id = data.car_id ,
				money = data.money ,
				duanwei_grade = data.duanwei_grade ,

				tools_data = tools_data,
				tools_map_data = tools_map_data ,
				skill_datas = skill_id_vec ,
			}
		end
	end

	return tart_data
end

---- 获得所有的地图的数据
function C.get_total_map_info(_d)
	local ret = {
		map_id = _d.map_id ,
		map_award = C.get_total_map_award_data(_d) ,
		map_barrier = C.get_total_map_barrier_data(_d) ,
	}

	return ret
end


----- 获取 所有的 地图的奖励数据
function C.get_total_map_award_data(_d)
	local tart_data = {}

	if _d and _d.map_road_award then
		for _road_id , data in pairs(_d.map_road_award) do
			tart_data[#tart_data + 1] = {
				road_id = _road_id ,
				road_award_type = data.road_award_type ,
				--road_award_create_type = data.road_award_create_type ,
				--award_list = data.award_list ,

				type_id = data.type_id ,
			} 
		end
	end

	return tart_data
end


----- 获得一个 地图障碍 的数据
function C.get_one_map_barrier_data(_data)
	local skill_datas = C.get_skill_data( _data.skill )

	return {
		owner_data = PUBLIC.get_game_owner_data( _data.owner ) ,
		no = _data.no ,
		id = _data.id ,
		level = _data.level ,
		type = _data.type ,
		road_id = _data.road_id ,
		skill_datas = skill_datas ,
	} 
end

---- 获得 地图障碍数据
function C.get_total_map_barrier_data(_d)
	local tart_data = {}

	if _d and _d.map_barrier then
		for _road_id , vec_data in pairs(_d.map_barrier) do
			for _no , data in pairs(vec_data) do
				tart_data[#tart_data + 1] = C.get_one_map_barrier_data( data )
			end
		end
	end

	return tart_data
end

-------------------------------------------------------------- 获取所有的玩家的数据 ↑ --------------------------------------------------

return C



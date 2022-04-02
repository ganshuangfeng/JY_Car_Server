-----游戏配置中心，房间 & AI 都可以使用这个


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

---- 游戏主体的  种类 类型
DATA.game_kind_type = {
	system = -1,           -- 系统

	player = 1,            -- 人
	car = 2,               -- 车
	road = 3,              -- 道路
	road_barrier = 4,      -- 路上障碍

}


---- 游戏 状态 类型
DATA.game_status_type = {
	game_begin = 1,
	round_start = 2,
	game_over = 3,

	
}

DATA.msg_type = {
	game_progress = "game_progress",

}

--- 基础操作类型
DATA.player_op_type = {
	console = -1 ,         -- n选1 退出选择
	nor_op = 1,             --玩家普通操作
	big_youmen = 2,         ---  大油门(基础)
	small_youmen = 3,       ---  小油门(基础)
	
	--select_index = 4,       ---  选择索引(基础)

 	select_road = 5,        ---  选择道路 (用选择索引)
 	select_skill = 6 ,      ---  选择技能 (用选择索引)
 	select_tool_op = 8,     ---  选择 道具 选项，（1是立刻使用，2是稍后使用(放道具栏) ）
 	select_clear_enemy_barrier = 10 , ----- 选择清理敌方障碍

 	select_map_award = 11 ,    ---- 选择地图奖励

 	---- 释放道具
 	use_tools = 7 , 

 	---- 平头哥，冲撞操作
 	ptg_chongzhuang = 12 ,

 	----- 地雷安装车，安装
 	dlc_anzhuang = 13,

}

--- 决策点名
DATA.decision_name = {
	nor_op = "nor_op",                        --- 普通操作
	select_map_award = "select_map_award" ,   --- 地图上的 n 选 1
	
}


---- 操作消耗的 mp 点数
DATA.player_op_spend_mp = {
	big_youmen = 1 ,
	small_youmen = 1 ,
	ptg_chongzhuang = 1 ,
	dlc_anzhuang = 1,
}


--- 大的 操作类型 的倒计时
DATA.player_op_timeout = {
	nor_op = 15 ,
	select_road = 15 ,
 	select_skill = 15 ,
 	select_tool_op = 15 ,
 	select_clear_enemy_barrier = 15 ,
 	select_map_award = 15 ,
}



----- 过程数据 忽略 技能
DATA.process_ignore_skill_key = {
	player_dis_skill = true,
	car_big_youmen_skill = true,
	car_small_youmen_skill = true,
}

----- 游戏结束的原因
DATA.game_over_reason = {
	all_hp_zero = 1,
	move_over = 2,
	surrender = 3,
}

---- 延迟发送 结算 时间
DATA.game_over_time_delay = {
	[DATA.game_over_reason.all_hp_zero] = 100,
	[DATA.game_over_reason.move_over] = 100,
	[DATA.game_over_reason.surrender] = 100,
}

---- 需要加入 运行系统的 消息 
DATA.need_add_run_system_msg = {
	car_hp_reduce_before = true ,
	car_hp_reduce = true ,
	car_hp_reduce_after = true ,
}


---- 双倍卡可以双倍的奖励，排除了 冲刺的，冲刺在另一个地方
DATA.can_double_award = {
	[55] = true ,			   -- 道具箱
	[56] = true ,              -- 车辆升级
	[1] = true ,			   -- 1-6是加血加攻加圈数
	[2] = true ,			   -- n2o在油门里单独处理
	[3] = true ,
	[4] = true ,
	[5] = true ,
	[6] = true ,
}

----- 单项双倍的 buff 值对应表，也可作为单项 双倍的 开关表
DATA.can_double_award_type_id_to_award_extra_num_name = {
	[1] = "sp_award_extra_num" ,
	[2] = "sp_award_extra_num" ,
	[3] = "at_award_extra_num" ,
	[4] = "at_award_extra_num" ,
	[5] = "hp_award_extra_num" ,
	[6] = "hp_award_extra_num" ,
	[7] = "small_daodan_award_extra_num" ,
	[8] = "small_daodan_award_extra_num" ,
	[36] = "n2o_award_extra_num" ,
	[37] = "n2o_award_extra_num" ,
	[55] = "tool_award_extra_num" ,
	[56] = "car_award_extra_num" ,

}

----- 地图上的障碍的 名字 对应id
DATA.map_barrier_name_2_id = {
	lanjie_luzhang = 2 ,
}

---- 先于技能发奖的地图奖励 type_id
DATA.first_award_map_type_id = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
}




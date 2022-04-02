--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:13
-- 说明：模块初始化
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local mysql = require "skynet.db.mysql"
local base = require "base"
local basefunc = require "basefunc"
require "data_func"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

---- 信号消息分发器
DATA.msg_dispatcher = basefunc.dispatcher.new()


-- 数据库中存放的 单一值（表 system_variant ）
-- 由 init_system_variant 函数管理
DATA.system_variant = DATA.system_variant or {
	last_match_ddz_game_id = 0,      	-- 表 match_ddz_game 的上一次 id 值
	last_match_ddz_race_log_id = 0,  	-- 表 match_ddz_race_log 的上一次 id 值
	last_pay_order_today_index = 0,  	-- 最近一次的订单当日序号
	last_pay_order_date = "20180101",	-- 最近一次订单的日期
	last_withdraw_today_index = 0,  	-- 最近一次的提现 当日序号
	last_withdraw_date = "20180101",-- 最近一次提现的日期
	last_user_index = 5387,			-- 最近一次用户序号
	last_player_info_seq = 0,		-- 最近一次玩家信息同步序号（和 web 后台同步）
	last_asset_log_seq = 0,			-- 最近一次  消费信息同步序号（和 web 后台同步）
	current_instance_id = 0,	-- 服务器 实例 id，每次启动增长一次， 用于客户端判断是否需要重新登录
	last_vip_record_id = 0,	-- 最近一次 vip 购买记录 id
	last_zajindan_round = 0,          --- 最近一次的砸金蛋的轮数
	freestyle_activity_log_id = 200,    --- 最近一次自由场活动的日志id,初始值
	xiaoxiaole_once_game_log_id = 0,    --- 消消乐单笔赢金排行榜的log_ id
	sczd_achievement_test_paper_log_id = 0,    --- sczd成就系统做试卷的log_ id
	xiaoxiaole_shuihu_once_game_log_id = 0,    --- 水浒 消消乐单笔赢金排行榜的log_ id
	-- master_square_info_id = 0,				   --- 师徒系统师徒广场的发布信息id
	-- master_apprentice_message_info_id = 0,	   --- 师徒系统师徒之间通知信息id
	-- sczd_total_rebate_value = 300000 ,         --- 生财之道的全场返利的值
	common_question_answer_topic_log_id = 0,      --- 通用问答系统的题目日志的id
	guess_apple_period_id = 0,      --- 猜苹果的周期id
	common_rank_data_id = 0,        --- 通用的排行榜的id
	pay_wechat_max_once = 0,	-- 微信支付，单次最大限额
	pay_wechat_max_day = 0,		-- 微信支付，每天最大限额
	pay_wechat_max_count_day = 0,	-- 微信支付，每天最大次数
	pay_wechat_max_month = 0,	-- 微信支付，每月最大限额
	super_money_pool = 1688888, -- 超级彩金
    last_equipment_no = 0,			-- 最近一个 装备 序列号
}

local LD = base.LocalData("data_module_init",{

})
local LF = base.LocalFunc("data_module_init")


----------------------------------------
-- 模块加载

local man_gm_user_list = require "data_service.man_gm_user_list"
local server_manager_lib = require "server_manager_lib"
local data_stat = require "data_service.data_stat"
local data_common = require "data_service.data_common"
local player_pay_channel = require "data_service.player_pay_channel"
local db_sql_stat = require "data_service.db_sql_stat"
local car_upgrade_data = require "data_service.car_upgrade_data"
local email_data = require "data_service.email_data"

function LF.init()

	----------------------------------------
	-- 模块初始化

	db_sql_stat.init()

	man_gm_user_list.init()

	server_manager_lib.init()

	data_stat.init()
	data_common.init()
	player_pay_channel.init()

    car_upgrade_data.init()

    -- 初始化邮件数据
	email_data.init_email_data()
	
end

return LF


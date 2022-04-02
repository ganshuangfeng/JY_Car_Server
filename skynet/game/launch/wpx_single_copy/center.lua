--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 服务的配置文件，所有服务信息 都配置在这里
--

-- 商城服务器
--shoping_server = "http://mall-webapp-user.jyhd919.cn"
local shoping_server = "http://jy-mall-webapp-user.ngrok.wd310.com"

-- 充值服务器
local payment_server = "http://test-es-caller.jyhd919.cn"
--payment_server = "http://jy-es-caller.ngrok.wd310.com"

--------------------------------------------------
-- 全局参数配置，分发到每个节点
local configs =
{
	-- 支付测试：为 true 则表示支付行为在测试环境
	-- is_pay_test = true,

	-- 网关配置
	gate_port = 5501,		-- 监听端口
	gate_maxclient = 5000,	-- 同时在线
	max_request_rate = 100,	-- 每个客户端 5 秒内最大的请求数

	-- 商城接口 url
	shoping_url = shoping_server .. "/#/?token=@token@",

	-- 支付接口的 url
	payment_url = payment_server .. "/Pay.apply.do?order_id=@order_id@",

	-- 提现接口 url
	withdraw_url = payment_server .. "/Withdraw.apply.do?withdrawId=@withdrawId@",

	-- 分享 url
	get_share_url = payment_server .. "/MpWeixinPublic.generateUserRecommendQrCode.do?userId=@userId@",

	-- 发送短信 url
	send_phone_sms_url = payment_server .. "/Sms.send.do",
	signName_bind_phone = "竟娱互动",
	templateCode_bind_phone = "SMS_136171608",

	-- 商城 token 的超时时间（秒）
	shop_token_timeout = 180,

	-- majiang 调试
	--lyx_majiang_debug = 1,

	-- network_error_debug = 1,

	-- 客户端bug报告文件
	clientBugTrackLog = "logs/client_bug_report_",

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7701,

	--dev_debug = 1,

	client_message_log = 1,

	--web
	webserver_port = 8801,
	webserver_agent_num = 1,
	webserver_disable_cache = true,

	mysql_host = "127.0.0.1",
	mysql_dbname = "wpx_test1",
	mysql_port = 3306,
	mysql_user = "root",
	mysql_pwd = "wpx",

	-- 发送短信 url
	send_phone_sms_url = payment_server .. "/Sms.send.do",
	signName_bind_phone = "竟娱互动",
	templateCode_bind_phone = "SMS_136171608",

	bind_phone_code_sms = "【鲸鱼斗地主】亲爱的鲸鱼斗地主用户，您的验证码为：%s，该验证码有效时限为5分钟，请尽快确认。请注意不要泄露验证码，若非本人操作，请联系官方客服",

	--debug_player_prefix = "W_",

	-- skynet 调试控制台端口
	debug_console_port = 8800,

	-- 强化托管玩家的 id 清单
	tuoguan_list = "robot_list_tg",

	free_tuoguan_count = 1500,

	tuoguan_max_count = 1550,

	-- ddz lv1 tuoguan
	nor_ddz_hp_shuangfei=40,
	nor_ddz_hp_sanfei=50,
	nor_ddz_hp_max_boom=2,
	nor_ddz_hp_boom=60,
	nor_ddz_hp_limit_dp_count=50,

	--  pdk lv1 tuoguan
	nor_pdk_hp_shuangfei=40,
	nor_pdk_hp_sanfei=50,
	nor_pdk_hp_max_boom=2,
	nor_pdk_hp_boom=60,
	nor_pdk_hp_limit_dp_count=35,

	-- 给指定 游戏模式的 指定 id 分配托管： tuoguan_[游戏模式]_[id]
	-- 特别的 tuoguan_[游戏模式]_x 表示 所有该游戏模式的场次
	tuoguan_match_game_2 = true,
	tuoguan_match_game_3 = true,
	tuoguan_freestyle_game_1 = true,
	tuoguan_freestyle_game_2 = true,
	tuoguan_freestyle_game_13 = true,
	tuoguan_freestyle_game_14 = true,
	tuoguan_freestyle_game_17 = true,
	tuoguan_freestyle_game_18 = true,
	tuoguan_freestyle_game_37 = true,
	tuoguan_freestyle_game_38 = true,
	tuoguan_freestyle_game_39 = true,
	tuoguan_freestyle_game_40 = true,

	----
	--[[tuoguan_freestyle_game_free_match_player_min_num_21 = 0,
	tuoguan_freestyle_game_free_match_player_min_num_22 = 0,
	tuoguan_freestyle_game_free_match_player_min_num_23 = 0,
	tuoguan_freestyle_game_free_match_player_min_num_24 = 0,--]]
	--- 二人麻将
	--tuoguan_freestyle_game_free_match_player_min_num_13 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_14 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_15 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_16 = 0,
	-- 4人麻将
	--tuoguan_freestyle_game_free_match_player_min_num_17 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_18 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_19 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_20 = 0,
	-- 经典斗地主
	--tuoguan_freestyle_game_free_match_player_min_num_1 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_2 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_3 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_4 = 0,

	-- 禁用斗地主发好牌
	-- forbid_ddz_nice_pai = true,
	-- tuoguan_v_tuoguan = true,
	--forbid_tuoguan_manager = true,

	--砸金蛋
	--财神模式
	zjd_caishen_model=true,
	zjd_cs_lisnsheng_round=1,
	zjd_cs_lisnsheng_level_3=true,
	zjd_cs_lisnsheng_level_4=true,
	zjd_cs_lisnsheng_start=1556450713,
	zjd_cs_lisnsheng_end=1557071999,

	--麻将发好牌配置************************start
	er_mj_hp_hu_time_min=2,
	er_mj_hp_hu_time_max=5,
	er_mj_hp_ddz_gailv=40,
	er_mj_hp_peng_gailv=30,
	er_mj_hp_gang_gailv=30,
	nor_mj_hp_hu_time_min=5,
	nor_mj_hp_hu_time_max=8,
	nor_mj_hp_ddz_gailv=35,
	nor_mj_hp_peng_gailv=35,
	nor_mj_hp_gang_gailv=35,
	tuoguan_er_mj_dapiao_gailv = 35,
	--麻将发好牌配置************************end

	must_huan_zhuo_game_num = 2,

	---- 幸运号 ******************************* ↓↓↓
	-- 幸运号地主概率
	lock_id_ddz_dz_rate = 60,
	-- 幸运账号个数
	lucky_id_num = 0,

	--
	lucky_id_1 = "",

	---- 幸运号 ******************************* ↑↑↑

	-- 自由场玩家个人小水池开关(关闭的话就用大水池)
	freestyle_game_player_water_pool = true,

	--- 自动重加载文件
	--debug_reload_center = true,

	-- 记录斗地主对局数据
	log_ddz_round_data = true,

	-- 记录pdk对局数据
	log_pdk_round_data = true,

	--- 任务系统 是否启用
	task_system_is_open = true,

	--- 步步生财 是否启用
	stepstep_money_is_open = true,

	--- 砸金蛋是否启用
	zajindan_is_open = true,

	-- 是否对客户端-服务端通讯进行加密
	--proto_encrypt = true,

	-- 所有人都是 gm 用户（正式服 千万不能要这行！！！！）
	gm_user_debug = true,

	luck_box_lottery_open = true,

	is_ignore_glory_error = true,

	-- 前缀 debug_no_log_ 禁止日志输出到文件过滤的消息名(避免日志过多)
	debug_no_log_multicast_msg = 1,
	debug_no_log_heartbeat = 1,
	debug_no_log_nor_fishing_nor_frame_data_test = 1,
	debug_no_log_query_all_gift_bag_status = 1,

}

--------------------------------------------------
-- 节点参数配置，可覆盖全局配置
-- 系统参数说明：
--	resource 可分配的资源数量
--	resource_types 可分配的资源类型集合
--		格式： {"ddz_test_agent","player_agent/player_agent"}
--		默认：不填则允许所有类型
--

local nodes =
{
	-- 节点
	node_1 =
	{
		resource = 50000,
	},
}

--------------------------------------------------
-- 服务配置
-- 说明：
--	launch 启动文件，给出启动的 lua 文件位置
--	deploy 部署配置，指定要部署到哪些节点，并给出名字：
--		1、全局服务，在每个节点均有唯一名字，例如：
--			{test_name1=node_1,test_name2=node_2,...}
--		2、私有服务，在不同节点名字均相同，例如：
--			{test_name={node_1,node_2,...}}
--
--			特别的，部署到所有节点：{test_name="*"}
--

local services =
{
	{	-- 重加载 中心
		launch = "reload_center/reload_center",
		deploy = {reload_center="node_1"},
	},
	{	-- sql 序号中心
		launch = "sql_id_center",
		deploy = {sql_id_center="node_1"},
	},
	{	-- 数据
		launch = "data_service/data_service",
		deploy = {data_service="node_1"},
	},
	{	-- 后台管理系统：数据采集
		launch = "collect_service/collect_service",
		deploy = {collect_service="node_1"},
	},
	{	-- 自动防控系统服务
		launch = "auto_control_system_service",
		deploy = {auto_control_system_service="node_1"},
	},
	{	-- 设置随机数的服务
		launch = "random_reset_service",
		deploy = {random_reset_service="*"},
	},
	{	-- 荣耀中心
		launch = "glory_center_service",
		deploy = {glory_center_service="node_1"},
	},
	{	-- 邮件服务
		launch = "email_service/email_service",
		deploy = {email_service="node_1"},
	},
	{	-- 资产折扣中心
		launch = "asset_discount_record_center_service",
		deploy = {asset_discount_record_center_service="node_1"},
	},
	{	-- 玩家信息服务
		launch = "player_info_service",
		deploy = {player_info_service="node_1"},
	},
	{	-- 标签中心服务
		launch = "tag_center/tag_center",
		deploy = {tag_center="node_1"},
	},
	{	-- 标签中心服务
		launch = "act_permission_center_service/act_permission_center_service",
		deploy = {act_permission_center_service="node_1"},
	},
	{	-- 登录
		launch = "login_service/login_service",
		deploy = {login_service="node_1"},
	},
	{	-- 广告
		launch = "ad_center_service",
		deploy = {ad_center_service="node_1"},
	},
	{	-- 签到服务
		launch = "sign_in_center_service/sign_in_center_service",
		deploy = {sign_in_center_service="node_1"},
	},
	{	-- 统计累积赢金 中心服务
		launch = "statis_leijiyingji_center_service/statis_leijiyingji_center_service",
		deploy = {statis_leijiyingji_center_service="node_1"},
	},
	{	-- 活跃玩家数据服务
		launch = "active_player_data_service",
		deploy = {active_player_data_service="node_1"},
	},
	{	-- 邀请新玩家挑战获得8元
		launch = "new_player_challenge_active_center_service",
		deploy = {new_player_challenge_active_center_service="node_1"},
	},
	{	-- 验证
		launch = "verify_service/verify_service",
		deploy = {verify_service="node_1"},
	},
	{	-- 消息通知中心
		launch = "msg_notification_center_service/msg_notification_center_service",
		deploy = {msg_notification_center_service="node_1"},
	},
	{	-- 调试控制服务
		launch = "debug_console_service/debug_console_service",
		deploy = {debug_console_service="node_1"},
	},
	{	-- 资产服务
		launch = "asset_service/asset_service",
		deploy = {asset_service="node_1"},
	},
	{	-- 自由场水池服务
		launch = "freestyle_water_pool_service",
		deploy = {freestyle_water_pool_service="node_1"},
	},
	{	-- 礼券服务
		launch = "gift_coupon_center_service",
		deploy = {gift_coupon_center_service="node_1"},
	},
	{	-- 砸金蛋 管理 服务
		launch = "zajindan_manager_service/zajindan_manager_service",
		deploy = {zajindan_manager_service="node_1"},
	},
	--[[{	-- 砸金蛋 活动 服务
		launch = "zajindan_activity_service/zajindan_activity_service",
		deploy = {zajindan_activity_service="node_1"},
	},--]]
	{	-- 消消乐 管理 服务
		launch = "xiaoxiaole_manager_service/xiaoxiaole_manager_service",
		deploy = {xiaoxiaole_manager_service="node_1"},
	},
	{	-- 消消乐 开奖中心 服务
		launch = "xiaoxiaole_lottery_center_service/xiaoxiaole_lottery_center_service",
		deploy = {xiaoxiaole_lottery_center_service="node_1"},
	},
	{	-- 消消乐水浒 管理 服务
		launch = "xiaoxiaole_shuihu_manager_service/xiaoxiaole_shuihu_manager_service",
		deploy = {xiaoxiaole_shuihu_manager_service="node_1"},
	},
	{	-- 消消乐水浒 开奖中心 服务
		launch = "xiaoxiaole_shuihu_lottery_center_service/xiaoxiaole_shuihu_lottery_center_service",
		deploy = {xiaoxiaole_shuihu_lottery_center_service="node_1"},
	},
	{	-- 消消乐 财神 管理 服务
		launch = "xiaoxiaole_caishen_manager_service/xiaoxiaole_caishen_manager_service",
		deploy = {xiaoxiaole_caishen_manager_service="node_1"},
	},
	{	-- 消消乐 财神 开奖中心 服务
		launch = "xiaoxiaole_caishen_lottery_center_service/xiaoxiaole_caishen_lottery_center_service",
		deploy = {xiaoxiaole_caishen_lottery_center_service="node_1"},
	},
	{   -- 弹弹乐 管理服务
		launch = "tantanle_manager_service/tantanle_manager_service",
		deploy = {tantanle_manager_service="node_1"},
	},
	{  -- 弹弹乐 开奖中心服务
		launch = "tantanle_lottery_center_service/tantanle_lottery_center_service",
		deploy = {tantanle_lottery_center_service="node_1"},
	},
	-- {	-- 师徒系统 中心服务
	-- 	launch = "master_apprentice_center_services/master_apprentice_center_services",
	-- 	deploy = {master_apprentice_center_services="node_1"},
	-- },
	{	-- 通用抽奖
		launch = "common_lottery_center_service/common_lottery_center_service",
		deploy = {common_lottery_center_service="node_1"},
	},
	{	-- 通用问答系统
		launch = "common_question_answer_center_service/common_question_answer_center_service",
		deploy = {common_question_answer_center_service="node_1"},
	},
	{	-- cszd成就系统
		launch = "sczd_achievement_sys_center_service/sczd_achievement_sys_center_service",
		deploy = {sczd_achievement_sys_center_service="node_1"},
	},
	{	-- 鲸鱼快跑
		launch = "jing_yu_kuai_pao_room_service/jing_yu_kuai_pao_room_service",
		deploy = {jing_yu_kuai_pao_room_service="node_1"},
	},
	{	-- 步步生财 中心服务
		launch = "bbsc_center_service/bbsc_center_service",
		deploy = {bbsc_center_service="node_1"},
	},
	{	-- 生财之道中心服务
		launch = "sczd_center_service/sczd_center_service",
		deploy = {sczd_center_service="node_1"},
	},
	{	-- 生财之道  高级合伙人 中心服务
		launch = "sczd_gjhhr_service/sczd_gjhhr_service",
		deploy = {sczd_gjhhr_service="node_1"},
	},
	------------------------------------------------------------------------------- 活动型的模块，有时间限制的模块 ---------- ↓
	--[[{	-- 大富豪活动 服务
		launch = "da_fu_hao_activity_service/da_fu_hao_activity_service",
		deploy = {da_fu_hao_activity_service="node_1"},
	},--]]
	--[[{	-- 西瓜排行榜 活动 服务
		launch = "activity_service/watermelon_rank_service",
		deploy = {watermelon_rank_service="node_1"},
	},--]]
	--[[{	-- 每日分享 活动 服务
		launch = "activity_service/everyday_share_service",
		deploy = {everyday_share_service="node_1"},
	},--]]
	--[[{	-- 老玩家专属 活动 服务
		launch = "activity_service/old_player_lottery_service",
		deploy = {old_player_lottery_service="node_1"},
	},--]]
	--[[{	-- 周年庆预约 活动 服务
		launch = "activity_service/zhounianqing_yuyue_service",
		deploy = {zhounianqing_yuyue_service="node_1"},
	},
	{	-- 周年庆 纪念币开奖 服务
		launch = "activity_service/zhounianqing_jinianbi_lottery_service",
		deploy = {zhounianqing_jinianbi_lottery_service="node_1"},
	},
	{	-- 周年回顾 服务
		launch = "activity_service/znq_look_back_service",
		deploy = {znq_look_back_service="node_1"},
	},--]]
	--{   -- 点赞有礼 服务
	--	launch = "activity_service/click_like_service",
	--	deploy = {click_like_service="node_1"},
	--},
	--[[{   -- 猜灯谜 服务
		launch = "activity_service/cai_dengmi_service",
		deploy = {cai_dengmi_service="node_1"},
	},--]]
	{   -- 好友召回 服务
		launch = "activity_service/recall_children_service",
		deploy = {recall_children_service="node_1"},
	},
	------------------------------------------------------------------------------- 活动型的模块，有时间限制的模块 ---------- ↑

	{	-- 捕鱼排行榜 活动 服务
		launch = "activity_service/buyu_rank_service",
		deploy = {buyu_rank_service="node_1"},
	},
	{	-- 新人专属 活动 服务
		launch = "activity_service/new_player_lottery_service",
		deploy = {new_player_lottery_service="node_1"},
	},
	{	-- 红包雨 活动 服务
		launch = "activity_service/red_envelope_rain_service",
		deploy = {red_envelope_rain_service="node_1"},
	},
	{	-- 许愿池 活动 服务
		launch = "activity_service/xuyuanchi_center_service",
		deploy = {xuyuanchi_center_service="node_1"},
	},
	{	-- 消消乐单笔赢金排行榜 中心服务
		launch = "activity_service/xiaoxiaole_once_game_rank_service",
		deploy = {xiaoxiaole_once_game_rank_service="node_1"},
	},
	{	--水浒 消消乐单笔赢金排行榜 中心服务
		launch = "activity_service/xiaoxiaole_shuihu_once_game_rank_service",
		deploy = {xiaoxiaole_shuihu_once_game_rank_service="node_1"},
	},
	{	-- 充值抽奖 活动 服务
		launch = "charge_lottery_activity_service/charge_lottery_activity_service",
		deploy = {charge_lottery_activity_service="node_1"},
	},
	{	-- 金猪  中心
		launch = "goldpig_center_service/goldpig_center_service",
		deploy = {goldpig_center_service="node_1"},
	},
	{	-- 周卡
		launch = "zhouka_system_service/zhouka_system_service",
		deploy = {zhouka_system_service="node_1"},
	},
	{	-- 月卡
		launch = "yueka_system_service/yueka_system_service",
		deploy = {yueka_system_service="node_1"},
	},
	{	-- 新月卡
		launch = "new_yueka_system_service/new_yueka_system_service",
		deploy = {new_yueka_system_service="node_1"},
	},
	{	-- 登录福利
		launch = "login_benefits_center_service/login_benefits_center_service",
		deploy = {login_benefits_center_service="node_1"},
	},
	{	-- 季卡
		launch = "jika_system_service/jika_system_service",
		deploy = {jika_system_service="node_1"},
	},
	{	-- 小游戏畅玩卡
		launch = "chang_wan_ka_center_service/chang_wan_ka_center_service",
		deploy = {chang_wan_ka_center_service="node_1"},
	},
	{	-- vip 礼包
		launch = "sczd_vip_lb_service/sczd_vip_lb_service",
		deploy = {sczd_vip_lb_service="node_1"},
	},
	--[[{	-- vip 中心服务
		launch = "vip_center_service/vip_center_service",
		deploy = {vip_center_service="node_1"},
	},--]]
	{	-- 猜苹果 中心服务
		launch = "guess_apple_room_service/guess_apple_room_service",
		deploy = {guess_apple_room_service="node_1"},
	},
	--{	-- 房卡场
	--	launch = "friendgame_center_service/friendgame_center_service",
	--	deploy = {friendgame_center_service="node_1"},
	--},
	--{	-- 自建房
	--	launch = "zijianfang_center_service/zijianfang_center_service",
	--	deploy = {zijianfang_center_service="node_1"},
	--},
	{	-- 比赛场
		launch = "match_center_service/match_center_service",
		deploy = {match_center_service="node_1"},
	},
	{	-- 捕鱼
		launch = "fish_match_center_service/fish_match_center_service",
		deploy = {fish_match_center_service="node_1"},
	},
	{	-- 捕鱼
		launch = "fishing_game_center_service/fishing_game_center_service",
		deploy = {fishing_game_center_service="node_1"},
	},
	{	-- 玩家保护服务
		launch = "player_protect_service/player_protect_service",
		deploy = {player_protect_service="node_1"},
	},
	{	-- 冠名赛辅助服务
		launch = "naming_match_assist_service",
		deploy = {naming_match_assist_service="node_1"},
	},
	{	-- 分享服务
		launch = "shared_game_center_service",
		deploy = {shared_game_center_service="node_1"},
	},
	{	-- 自由场
		launch = "freestyle_game_center_service/freestyle_game_center_service",
		deploy = {freestyle_game_center_service="node_1"},
	},
	-- {	-- lhd自由场
	-- 	launch = "lhd_game_center_service/lhd_game_center_service",
	-- 	deploy = {lhd_game_center_service="node_1"},
	-- },
	{	-- 比赛详细排行服务
		launch = "match_detail_rank_center_service",
		deploy = {match_detail_rank_center_service="node_1"},
	},
	{	-- 斗地主百万大奖赛
		launch = "ddz_million_center_service/ddz_million_center_service",
		deploy = {ddz_million_center_service="node_1"},
	},
	{	-- 血流麻将自由场
		launch = "normal_mjxl_freestyle_center_service/normal_mjxl_freestyle_center_service",
		deploy = {normal_mjxl_freestyle_center_service="node_1"},
	},
	{	-- 听用斗地主自由场
		launch = "tyddz_freestyle_center_service/tyddz_freestyle_center_service",
		deploy = {tyddz_freestyle_center_service="node_1"},
	},
	{	-- 游戏 盈亏统计 管理
		launch = "game_profit_manager_service/game_profit_manager",
		deploy = {game_profit_manager="node_1"},
	},
	{	-- 支付服务
		launch = "pay_service/pay_service",
		deploy = {pay_service="node_1"},
	},
	{	-- 商城配置中心服务
		launch = "shoping_config_center_service",
		deploy = {shoping_config_center_service="node_1"},
	},
	{	-- 广播服务
		launch = "broadcast_service/broadcast_service",
		deploy = {broadcast_svr="node_1"},
	},
	{	-- web 服务
		launch = "websever_service/websever_service",
		deploy = {web_server_service="node_1"},
	},
	{	-- 广播中心
		launch = "broadcast_center_service/broadcast_center_service",
		deploy = {broadcast_center_service="node_1"},
	},
	{	-- 任务中心
		launch = "task_center_service/task_center_service",
		deploy = {task_center_service="node_1"},
	},
	{	-- 新版 vip 中心服务
		launch = "new_vip_center_service/new_vip_center_service",
		deploy = {new_vip_center_service="node_1"},
	},
	{	-- 排行榜 中心服务
		launch = "rank_center_service/rank_center_service",
		deploy = {rank_center_service="node_1"},
	},
	{	-- 抽奖中心
		launch = "lottery_center_service",
		deploy = {lottery_center_service="node_1"},
	},
	{	-- 兑换码中心
		launch = "redeem_code_center_service/redeem_code_center_service",
		deploy = {redeem_code_center_service="node_1"},
	},
	{	-- 自由场活动中心 服务
		launch = "freestyle_activity_center_service/freestyle_activity_center_service",
		deploy = {freestyle_activity_center_service="node_1"},
	},
	{	-- 服务管理
		launch = "admin_console_service/admin_console_service",
		deploy = {service_console="node_1"},
	},
	{	-- 游戏管理
		launch = "game_manager_service/game_manager_service",
		deploy = {game_manager_service="node_1"},
	},
	{	-- 第三方服务代理，如 短信、分享
		launch = "third_agent_service/third_agent_service",
		deploy = {third_agent_service="node_1"},
	},
	{	-- 自由场机器人调度器：为排队过久的用户安排陪玩机器人
		launch = "freestyle_robot_observer_service/freestyle_robot_observer_service",
		deploy = {free_bot_ob_service="node_1"},
	},
	{	-- 聊天室服务
		launch = "chat_service/chat_service",
		deploy = {chat_service="node_1"},
	},
	{	-- web客户端服务：转发 http 请求
		launch = "webclient_service",
		deploy = {webclient_service="node_1"},
	},
	{	-- 强化托管服务
		launch = "tuoguan_service/tuoguan_service",
		deploy = {tuoguan_service="node_1"},
	},
	{	-- 客户端bug记录服务
		launch = "client_bug_log_service/client_bug_log_service",
		deploy = {cbug_log_service="node_1"},
	},
	{	-- 斗地主好牌服务
		launch = "ddz_haopai_service/ddz_haopai_service",
		deploy = {ddz_haopai_service="node_1"},
	},
	{
		launch = "vip_addr_list_service/vip_addr_list_service",
		deploy = {vip_addr_list_service="node_1"},
	},
	{
		launch = "cpl_xian_wan_service/cpl_xian_wan_service",
		deploy = {cpl_xian_wan_service="node_1"},
	},
	{
		launch = "cpl_xian_wan_clby_service/cpl_xian_wan_clby_service",
		deploy = {cpl_xian_wan_clby_service="node_1"},
	},
	{
		launch = "cpl_pceggs_service/cpl_pceggs_service",
		deploy = {cpl_pceggs_service="node_1"},
	},
	{
		launch = "cpl_qwxq_service/cpl_qwxq_service",
		deploy = {cpl_qwxq_service="node_1"},
	},
	{
		launch = "cpl_juxiang_service/cpl_juxiang_service",
		deploy = {cpl_juxiang_service="node_1"},
	},
	{
		launch = "cpl_juju_service/cpl_juju_service",
		deploy = {cpl_juju_service="node_1"},
	},
	{
		launch = "cpl_xiaozhuo_service/cpl_xiaozhuo_service",
		deploy = {cpl_xiaozhuo_service="node_1"},
	},
	{	-- 系统监控服务
		launch = "monitor_service/monitor_service",
		deploy = {monitor_service="node_1"},
	},
	-- {	-- 压力测试服务
	-- 	launch = "player_test_service/player_test_service",
	-- 	deploy = {player_test_service="node_1"},
	-- },
	{	-- 网关
		launch = "gate_service/gate_service",
		deploy = {gate_service="node_1"},
	},
	{
		launch = "ddz_nor_query_service/ddz_nor_query_service",
		deploy = {ddz_nor_query_service="node_1"},
	},
	--{	-- 砸金蛋 财神模式  连胜活动活动
	--	launch = "activity_service/zjd_cs_liansheng_act_service",
	--	deploy = {zjd_cs_liansheng_act_service="node_1"},
	--},
}




return {

	configs = configs,
	nodes = nodes,
	services = services,
}
--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 服务的配置文件，所有服务信息 都配置在这里
--


-- 商城服务器
local shoping_server = "http://test.mall-webapp-user.jyhd919.cn"

local shoping_api_server = "http://test.mall-server-user.jyhd919.cn/"

-- 充值服务器
local payment_server = "http://test.es-caller.jyhd919.cn"

--------------------------------------------------
-- 全局参数配置，分发到每个节点
local configs = 
{
	-- 支付测试：为 true 则表示支付行为在测试环境
	is_pay_test = true,

	-- 网关配置
	gate_port = 5112,		-- 监听端口
	gate_maxclient = 5000,	-- 同时在线
	max_request_rate = 150,	-- 每个客户端 5 秒内最大的请求数


	-- 友盟推送
	umeng_android_appkey = "5b8d0566f29d98698d0000c8",
	umeng_android_master_secret = "jx9o6uplgm7tftdzjl45sgnhufq3zpoi",
	umeng_ios_appkey = "5b8e1f8eb27b0a1355000063",
	umeng_ios_master_secret = "furryknmq5xq05xhzuerpoxmzfy70khp",

	-- 产品模式： false 表示只推送给测试设备
	umeng_ios_pmode = "false",

	-- 商城接口 url
	shoping_url = shoping_server .. "/#/?token=@token@",

	-- 支付接口的 url
	payment_url = payment_server .. "/Pay.apply.do?order_id=@order_id@",

	-- 提现接口 url
	withdraw_url = payment_server .. "/Withdraw.apply.do?withdrawId=@withdrawId@",

	-- 分享 url
	get_share_url = payment_server .. "/MpWeixinPublic.generateUserRecommendQrCode.do?userId=@userId@",

	-- 1元话费url
	pay_phone_tariffe_url = shoping_api_server .. "/OrderTransactor.goodsOrderPlaceForShoppingGoldPay.command",

	-- 1元话费商品id
	pay_phone_tariffe_goodsid="89181",

	-- 绑定手机的验证码通知短信
	bind_phone_code_sms = "【鲸鱼斗地主】亲爱的鲸鱼斗地主用户，您的验证码为：%s，该验证码有效时限为5分钟，请尽快确认。请注意不要泄露验证码，若非本人操作，请联系官方客服",

	-- 发送短信 url
	send_phone_sms_url = "http://es-caller.jyhd919.cn/Sms.send.do",
--	signName_bind_phone = "竟娱互动",
--	templateCode_bind_phone = "SMS_136171608",

	-- 商城 token 的超时时间（秒）
	shop_token_timeout = 180,

	-- majiang 调试
	--lyx_majiang_debug = 1,

	-- network_error_debug = 1,

	-- 客户端bug报告文件
	clientBugTrackLog = "logs/client_bug_report_",
	
	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7101,

	-- dev_debug = 1,

	client_message_log = 1,


	is_pay_test = true,
	debug_player_prefix = "T_",

	--web
	webserver_port = 8101,
	webserver_agent_num = 1,
	webserver_disable_cache = true,

	mysql_host = "192.168.0.203",
	mysql_dbname = "game_test1",
	mysql_port = 23456,
	mysql_user = "jy",
	mysql_pwd = "123456",

	-- skynet 调试控制台端口
	debug_console_port = 8102,

	-- 强化托管玩家的 id 清单
	tuoguan_list = "robot_list_tg",

	free_tuoguan_count = 2500,
	
	tuoguan_max_count = 5000,

	-- forbid_tuoguan_manager = true,

	--麻将发好牌配置************************start
	er_mj_hp_hu_time_min=2,
	er_mj_hp_hu_time_max=4,
	er_mj_hp_ddz_gailv=40,
	er_mj_hp_peng_gailv=60,
	er_mj_hp_gang_gailv=40,
	nor_mj_hp_hu_time_min=4,
	nor_mj_hp_hu_time_max=7,
	nor_mj_hp_ddz_gailv=40,
	nor_mj_hp_peng_gailv=60,
	nor_mj_hp_gang_gailv=40,
  
	er_mj_hp_qys_gailv=90,
	er_mj_hp_lqd_gailv=40,
	nor_mj_hp_qys_gailv=55,
	nor_mj_hp_lqd_gailv=25,
	--麻将发好牌配置************************end  
	tuoguan_er_mj_dapiao_gailv = 25,

	------------------cp cd---------------------
	tuoguan_mj_delay_1 = 50,
	tuoguan_mj_delay_2 = 250,
	tuoguan_ddz_delay_1 = 50,
	tuoguan_ddz_delay_2 = 250,

	player_agent_robot_cd=12,
	----------------------------------------
	
	-- ddz lv1 tuoguan
	nor_ddz_hp_shuangfei=40,
	nor_ddz_hp_sanfei=50,
	nor_ddz_hp_max_boom=2,
	nor_ddz_hp_boom=60,
	nor_ddz_hp_limit_dp_count=35,


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
	
	create_order_wait_time = 30,
	
	-- 自由场随机匹配的阀值，小于用托管补充 默认值为15
	--tuoguan_freestyle_game_free_match_player_min_num_1 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_2 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_6 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_10 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_14 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_18 = 0,
	--tuoguan_freestyle_game_free_match_player_min_num_22 = 0,
	tuoguan_freestyle_game_free_match_player_min_num_25 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_11 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_12 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_15 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_16 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_19 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_20 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_21 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_22 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_23 = 0,
	-- tuoguan_freestyle_game_free_match_player_min_num_24 = 0,


	--- 任务系统 是否启用
	task_system_is_open = true,

	--- 步步生财 是否启用
	stepstep_money_is_open = true,

	--- 砸金蛋是否启用
	zajindan_is_open = true,
	
	-- 烂牌 的情况下 抢地主的概率
	freestyle_game_down_bad_pai_dizhu = 0,
	freestyle_game_free_bad_pai_dizhu = 0,
	freestyle_game_up_bad_pai_dizhu = 0,
	match_game_down_bad_pai_dizhu = 0,
	match_game_free_bad_pai_dizhu = 0,
	match_game_up_bad_pai_dizhu = 0,

	ddz_tuoguan_imp_c=true,
	
	-- 是否对客户端-服务端通讯进行加密
	proto_encrypt = true,

	-- 所有人都是 gm 用户（正式服 千万不能要这行！！！！）
	gm_user_debug = true,

	
	--砸金蛋
	--财神模式
	zjd_caishen_model=true,
	zjd_cs_lisnsheng_round=1,
	zjd_cs_lisnsheng_level_3=true,
	zjd_cs_lisnsheng_level_4=true,
	zjd_cs_lisnsheng_start=1556450713,
	zjd_cs_lisnsheng_end=1557071999,

	--高级合伙人自动结算
	gjhhr_auto_period_settle=true,
	--高级合伙人提现关闭  每月最后一天关闭
	-- wait_jicha_settle=true,
	--强制同意高级合伙人提现
	-- gjhhr_tx_force_agree=true,

	-- 自由场对局结算兑换红包的概率和转换率,同时配置正确有效
	freestyle_game_settle_exchange_hb_pro = 0.9,
	freestyle_game_settle_exchange_hb_rate = 0.005,

	-- 记录 单人比赛 数据
	danren_match_write_test = true,
	
	-- 记录斗地主对局数据
	log_ddz_round_data = true,
	
	-- 幸运宝箱抽奖
	luck_box_lottery_open = true,
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
	{	-- 数据
		launch = "data_service/data_service",
		deploy = {data_service="node_1"},
	},
	{	-- 消息通知中心
		launch = "msg_notification_center_service/msg_notification_center_service",
		deploy = {msg_notification_center_service="node_1"},
	},
	{	-- 后台管理系统：数据采集
		launch = "collect_service/collect_service",
		deploy = {collect_service="node_1"},
	},
	{	-- 登录
		launch = "login_service/login_service",
		deploy = {login_service="node_1"},
	},
	{	-- 验证
		launch = "verify_service/verify_service",
		deploy = {verify_service="node_1"},
	},
	{	-- 资产服务
		launch = "asset_service/asset_service",
		deploy = {asset_service="node_1"},
	},
	{	-- 调试控制服务
		launch = "debug_console_service/debug_console_service",
		deploy = {debug_console_service="node_1"},
	},
	{	-- 砸金蛋 管理 服务
		launch = "zajindan_manager_service/zajindan_manager_service",
		deploy = {zajindan_manager_service="node_1"},
	},
	{	-- 砸金蛋 活动 服务
		launch = "zajindan_activity_service/zajindan_activity_service",
		deploy = {zajindan_activity_service="node_1"},
	},
	{	-- 消消乐 管理 服务
		launch = "xiaoxiaole_manager_service/xiaoxiaole_manager_service",
		deploy = {xiaoxiaole_manager_service="node_1"},
	},
	{	-- 消消乐 开奖中心 服务
		launch = "xiaoxiaole_lottery_center_service/xiaoxiaole_lottery_center_service",
		deploy = {xiaoxiaole_lottery_center_service="node_1"},
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
	{	-- 强化托管服务
		launch = "tuoguan_service/tuoguan_service",
		deploy = {tuoguan_service="node_1"},
	},
	{	-- 比赛场
		launch = "match_center_service/match_center_service",
		deploy = {match_center_service="node_1"},
	},
	{	-- 捕鱼
		launch = "fishing_game_center_service/fishing_game_center_service",
		deploy = {fishing_game_center_service="node_1"},
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
	{	-- 玩家保护服务
		launch = "player_protect_service/player_protect_service",
		deploy = {player_protect_service="node_1"},
	},
	{	-- 房卡
		launch = "friendgame_center_service/friendgame_center_service",
		deploy = {friendgame_center_service="node_1"},
	},
	{	-- 游戏 盈亏统计 管理
		launch = "game_profit_manager_service/game_profit_manager",
		deploy = {game_profit_manager="node_1"},
	},
	{	-- 邮件服务
		launch = "email_service/email_service",
		deploy = {email_service="node_1"},
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
		deploy = {broadcast_svr="*"},
	},
	{	-- web 服务
		launch = "websever_service/websever_service",
		deploy = {web_server_service="node_1"},
	},
	{	-- 广播中心
		launch = "broadcast_center_service/broadcast_center_service",
		deploy = {broadcast_center_service="node_1"},
	},
	{	-- 荣耀中心
		launch = "glory_center_service",
		deploy = {glory_center_service="node_1"},
	},
	{	-- 任务中心
		launch = "task_center_service/task_center_service",
		deploy = {task_center_service="node_1"},
	},
	-- {	-- 大富豪活动 服务
	-- 	launch = "da_fu_hao_activity_service/da_fu_hao_activity_service",
	-- 	deploy = {da_fu_hao_activity_service="node_1"},
	-- },
	{	-- 西瓜排行榜 活动 服务 
		launch = "activity_service/watermelon_rank_service",
		deploy = {watermelon_rank_service="node_1"},
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
	{	-- vip 礼包
		launch = "sczd_vip_lb_service/sczd_vip_lb_service",
		deploy = {sczd_vip_lb_service="node_1"},
	},
	--[[{	-- vip 中心服务
		launch = "vip_center_service/vip_center_service",
		deploy = {vip_center_service="node_1"},
	},--]]
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
	
	{	-- 客户端bug记录服务
		launch = "client_bug_log_service/client_bug_log_service",
		deploy = {cbug_log_service="node_1"},
	},
	{	-- web客户端服务：转发 http 请求
		launch = "webclient_service",
		deploy = {webclient_service="*"},
	},
	{	-- 网关
		launch = "gate_service/gate_service",
		deploy = {gate_service="node_1"},
	},
}


return {
	
	configs = configs,
	nodes = nodes,
	services = services,
}
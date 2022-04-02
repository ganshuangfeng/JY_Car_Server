--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 服务的配置文件，所有服务信息 都配置在这里
--

-- 商城服务器
shoping_server = "http://test.mall-webapp-user.jyhd919.cn"

shoping_api_server = "http://test.mall-server-user.jyhd919.cn/"

-- 充值服务器
payment_server = "http://test.es-caller.jyhd919.cn"

--------------------------------------------------
-- 全局参数配置，分发到每个节点
local configs = 
{
	-- 支付测试：为 true 则表示支付行为在测试环境
	is_pay_test = true,

	-- 强化托管玩家： id , 名字, 头像
	tuoguan_list = "robot_list_tg",

	-- 网关配置
	gate_port = 5005,		-- 监听端口
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

	-- 1元话费url
	pay_phone_tariffe_url = shoping_api_server .. "/OrderTransactor.goodsOrderPlaceForShoppingGoldPay.command",

	-- 1元话费商品id
	pay_phone_tariffe_goodsid="89181",

	-- 发送短信 url
	send_phone_sms_url = payment_server .. "/Sms.send.do",
	-- signName_bind_phone = "竟娱互动",
	-- templateCode_bind_phone = "SMS_136171608",
	
	-- 客户端bug报告文件
	clientBugTrackLog = "logs/client_bug_report_",
	
	client_message_log = 1,

	-- 商城 token 的超时时间（秒）
	shop_token_timeout = 180,
	--web
	webserver_port = 8005,
	webserver_agent_num = 20,
	resource = 500000,

	-- 数据服务配置
	mysql_host = "127.0.0.1",
	mysql_dbname = "jygame5",
	mysql_port = 3306,
	mysql_user = "game",
	mysql_pwd = "jYserVer135",
	--mysql_user = "root",
	--mysql_pwd = "jY123",



	-- skynet 调试控制台端口
	debug_console_port = 8515,

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7005,

	debug_player_prefix = "S5",

	-- 禁止游客登录
	forbid_youke = nil,

	-- 禁止 sql 日志
	--forbid_sql_log = true,

	-- 禁止强化托管代码
	--forbid_tuoguan_manager = true,

	tuoguan_max_count = 1000,

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

	-- 强化托管操作延时：1/100 秒
	tuoguan_mj_delay_1 = 50,
	tuoguan_mj_delay_2 = 250,
	tuoguan_ddz_delay_1 = 50,
	tuoguan_ddz_delay_2 = 250,

	--tuoguan_freestyle_game_x = true,

	-- 调试警报系统
	--debug_monitor_system = true,
	-- 打开系统报警功能
	--enable_monitor = true,

	-- 每种报警数据 发送告警邮件的最短时间间隔（秒）
	monitor_email_time = 5,

	-- 不真正发邮件，仅仅输出日志（测试用）
	monitor_mock_email = true,

	-- 接收报警数据 的 邮件地址（支持多个，逗号隔开）
	monitor_recieve_email = "695223392@qq.com,421951953@qq.com,24090841@qq.com,949652665@qq.com,344813836@qq.com,83046971@qq.com,liangpai@163.com",
	--- 任务系统 是否启用
	task_system_is_open = true,

	--- 步步生财 是否启用
	stepstep_money_is_open = true,

	-- 禁止 外部创建订单。目前就是 微信公总号支付
	--forbid_external_order = true,

	-- 登录调试
	network_error_debug = true,
	-- 重加载中心 调试模式
	debug_reload_center = true,

	-- 自由的托管（不限于入场范围）
	free_tuoguan_count = 1000,

	-- 托管可以随便发互动表情
	tuoguan_interaction_always = true,

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
	er_mj_hp_qys_gailv=95,
	er_mj_hp_lqd_gailv=40,
	nor_mj_hp_qys_gailv=60,
	nor_mj_hp_lqd_gailv=20,
	--麻将发好牌配置************************end	

	tuoguan_er_mj_dapiao_gailv = 25,
	--------------------------free matching--------------------------------
	-- 自由场随机匹配的阀值，小于用托管补充 默认值为15
	-- tuoguan_freestyle_game_free_match_player_min_num_1 = 3,
	-- tuoguan_freestyle_game_free_match_player_min_num_2 = 3,
	-- tuoguan_freestyle_game_free_match_player_min_num_3 = 3,
	-- tuoguan_freestyle_game_free_match_player_min_num_4 = 3,

	-- 托管请求间隔
	freestyle_game_tuoguan_update_interval_19 = 16,
	freestyle_game_tuoguan_update_interval_20 = 16,
	-- 托管请求间隔随机浮动值
	-- tuoguan_update_interval_random_1 = 2,
	---------------------------------------------------------
	---- 幸运号 ******************************* ↓↓↓
    -- 幸运号地主概率
    lock_id_ddz_dz_rate = 60,
    -- 幸运账号个数
    lucky_id_num = 0,
    
    --
    lucky_id_1 = "",

    ---- 幸运号 ******************************* ↑↑↑

	-- ddz lv1 tuoguan
	nor_ddz_hp_shuangfei=40,
	nor_ddz_hp_sanfei=50,
	nor_ddz_hp_max_boom=2,
	nor_ddz_hp_boom=60,
	nor_ddz_hp_limit_dp_count=50,
	
	zajindan_is_open = true,

	debug_gain_power = 0,

	--tuoguan_v_tuoguan = true,

	-- 经典斗地主
	tuoguan_ob_freestyle_game_1 = true,
	tuoguan_ob_freestyle_game_2 = true,
	tuoguan_ob_freestyle_game_3 = true,
	tuoguan_ob_freestyle_game_4 = true,

	-- 川渝斗地主
	tuoguan_ob_freestyle_game_21 = true,
	tuoguan_ob_freestyle_game_22 = true,
	tuoguan_ob_freestyle_game_23 = true,
	tuoguan_ob_freestyle_game_24 = true,
	
	-- 禁用斗地主发好牌
	-- forbid_ddz_nice_pai = true,

	-- 烂牌 的情况下 抢地主的概率
	freestyle_game_down_bad_pai_dizhu = 80,
	freestyle_game_free_bad_pai_dizhu = 1,
	freestyle_game_up_bad_pai_dizhu = 2,
	match_game_down_bad_pai_dizhu = 80,
	match_game_free_bad_pai_dizhu = 3,
	match_game_up_bad_pai_dizhu = 4,

	-- 新手保护模拟，当前时间戳
	xinshou_mock_time = nil,

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

	-- dev_debug_gufing_fp=true,
	-- debug_gufing_fp_p1="3334566789000022W",
	-- debug_gufing_fp_p2="4455678JJJJQQA22w",
	-- debug_gufing_fp_p3="3456788999QKKKAAA",
	-- dev_debug_gufing_dz=true,
	-- debug_gufing_dz=1,

	-- 发固定等级的好牌（用于测试好牌）
	--ddz_haopai_debug_enable = true,
	
	-- 记录 单人比赛 数据
	danren_match_write_test = true,

	-- 记录斗地主对局数据
	log_ddz_round_data = true,

	-- 竞标赛 压力测试
	--jingbiaosai_test = true,
}

--------------------------------------------------
-- 节点参数配置，可覆盖全局配置
-- 系统参数说明：
--	resource 可分配的资源数量
--	resource_types 可分配的资源类型集合
--		格式： {"ddz_test_agent","player_agent/player_agent"}
--		默认：不填则允许所有类型
--	reject_resource_types 拒绝的资源类型集合（暂未实现）
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
	{	-- 捕鱼排行榜 活动 服务 
		launch = "activity_service/buyu_rank_service",
		deploy = {buyu_rank_service="node_1"},
	},
	{	-- 每日分享 活动 服务 
		launch = "activity_service/everyday_share_service",
		deploy = {everyday_share_service="node_1"},
	},
	{	-- 新人专属 活动 服务 
		launch = "activity_service/new_player_lottery_service",
		deploy = {new_player_lottery_service="node_1"},
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
	{
		launch = "vip_addr_list_service/vip_addr_list_service",
		deploy = {vip_addr_list_service="node_1"},
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
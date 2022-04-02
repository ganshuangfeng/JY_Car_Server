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
	--is_pay_test = true,

	-- 网关配置
	gate_port = 5001,		-- 监听端口
	gate_maxclient = 5000,	-- 同时在线
	max_request_rate = 100,	-- 每个客户端 5 秒内最大的请求数

	-- 商城接口 url
	shoping_url = shoping_server .. "/#/?token=@token@",

	-- 支付接口的 url
	payment_url = payment_server .. "/Pay.apply.do?order_id=@order_id@",

	-- 提现接口 url
	withdraw_url = payment_server .. "/Withdraw.apply.do?withdrawId=@withdrawId@",

	---- 获取提现配置的 url
	withdraw_cfg_url = payment_server .. "/AliPayWithDrawLimitConf.do",

	-- 分享 url
	get_share_url = payment_server .. "/MpWeixinPublic.generateUserRecommendQrCode.do?userId=@userId@",

	-- 发送短信 url
	send_phone_sms_url = payment_server .. "/Sms.send.do",
	signName_bind_phone = "竟娱互动",
	templateCode_bind_phone = "SMS_136171608",

	-- 商城 token 的超时时间（秒）
	shop_token_timeout = 180,


	-- 客户端bug报告文件
	clientBugTrackLog = "logs/client_bug_report_",

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7001,


	client_message_log = 1,

	--web
	webserver_port = 8001,
	webserver_agent_num = 1,
	webserver_disable_cache = true,

	mysql_host = "192.168.0.204",
	mysql_dbname = "xyx_df_test",
	mysql_port = 3306,
	mysql_user = "root",
	mysql_pwd = "jy520",

	-- 发送短信 url
	send_phone_sms_url = payment_server .. "/Sms.send.do",
	signName_bind_phone = "竟娱互动",
	templateCode_bind_phone = "SMS_136171608",

	bind_phone_code_sms = "【鲸鱼斗地主】亲爱的鲸鱼斗地主用户，您的验证码为：%s，该验证码有效时限为5分钟，请尽快确认。请注意不要泄露验证码，若非本人操作，请联系官方客服",

	--debug_player_prefix = "W_",

	-- skynet 调试控制台端口
	debug_console_port = 8000,

	debug_player_prefix = "XYX_",

	-- 前缀 debug_no_log_ 禁止日志输出到文件过滤的消息名(避免日志过多)
	debug_no_log_multicast_msg = 1,
	debug_no_log_heartbeat = 1,
	debug_no_log_nor_fishing_nor_frame_data_test = 1,
	debug_no_log_query_all_gift_bag_status = 1,
	debug_no_log_driver_game_syn_client_data = 1,

	
	--- 测试消消乐的去掉的消息
	--debug_no_log_notify_asset_change_msg = 1,

	------
	auto_complete_pay_order = true,

	------ 生成原始托管列表 的 文件
	tuoguan_list = "robot_list_tg",
	----- 托管最大请求数量
	tuoguan_max_count = 100,

	---- 如果是 打开，都是gm调试用户
	gm_user_debug = true,

	drive_game_test_timeout = true,

	--------- 是否打开 赛车的 移动测试 （按剧本走）
	--is_open_drive_move_test = true ,

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
	{	-- 消息通知中心
		launch = "msg_notification_center_service/msg_notification_center_service",
		deploy = {msg_notification_center_service="node_1"},
	},
	{	-- 后台管理系统：数据采集
		launch = "collect_service/collect_service",
		deploy = {collect_service="node_1"},
	},
	{	-- 标签中心服务
		launch = "tag_center/tag_center",
		deploy = {tag_center="node_1"},
	},
	{	-- 标签中心服务
		launch = "act_permission_center_service/act_permission_center_service",
		deploy = {act_permission_center_service="node_1"},
	},
	--- 托管中心
	{	
		launch = "tuoguan_service/tuoguan_service",
		deploy = {tuoguan_service="node_1"},
	},
	{	-- 广播服务
		launch = "broadcast_service/broadcast_service",
		deploy = {broadcast_svr="*"},
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
	{	-- 排行榜 中心服务
		launch = "rank_center_service/rank_center_service",
		deploy = {rank_center_service="node_1"},
	},
	{	-- 服务管理
		launch = "admin_console_service/admin_console_service",
		deploy = {service_console="node_1"},
	},
	{	-- 第三方服务代理，如 短信、分享
		launch = "third_agent_service/third_agent_service",
		deploy = {third_agent_service="node_1"},
	},
	{	-- 客户端bug记录服务
		launch = "client_bug_log_service/client_bug_log_service",
		deploy = {cbug_log_service="node_1"},
	},
	{	-- 系统监控服务
		launch = "monitor_service/monitor_service",
		deploy = {monitor_service="node_1"},
	},

	{	-- web客户端服务：转发 http 请求
		launch = "webclient_service",
		deploy = {webclient_service="*"},
	},
	{	-- 网关
		launch = "gate_service/gate_service",
		deploy = {gate_service="node_1"},
	},
	{	-- 游戏中心服务
		launch = "game_center_service/game_center_service",
		deploy = {game_center_service="node_1"},
	},
}

return {

	configs = configs,
	nodes = nodes,
	services = services,
}
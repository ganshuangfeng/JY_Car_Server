--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 服务的配置文件，所有服务信息 都配置在这里
--


-- 商城服务器
local shoping_server = "http://jy-mall-webapp-user.ngrok.wd310.com"

-- 充值服务器
local payment_server = "http://jy-es-caller.ngrok.wd310.com"

--------------------------------------------------
-- 全局参数配置，分发到每个节点
local configs =
{
	-- 如果不是调试阶段，则注释掉此行
	debug = 1,

	-- 支付测试：为 true 则表示支付行为在测试环境
	is_pay_test = true,

	-- 客户端是否为正式环境：不配置此项，则登录消息 is_test 字段为 1
	--client_is_release = true,


	-- 网关配置
	gate_port = 5401,		-- 监听端口
	gate_maxclient = 1000000,	-- 同时在线
	max_request_rate = 100,	-- 每个客户端 5 秒内最大的请求数
	
	-- 发布准备状态倒计时，单位 秒。 服务启动时，在倒计时结束后才允许登录
	--publish_prepare_cd = 900,

	-- 支付接口的 url
	payment_url = payment_server .. "/Pay.apply.do?order_id=@order_id@",

	-- 分享 url
	get_share_url = payment_server .. "/MpWeixinPublic.generateUserRecommendQrCode.do?userId=@userId@",

	-- 发送短信 url
	send_phone_sms_url = payment_server .. "/Sms.send.do",
	signName_bind_phone = "竟娱互动",
	templateCode_bind_phone = "SMS_136171608",
	
	-- 绑定手机的验证码通知短信
	bind_phone_code_sms = "亲爱的鲸鱼斗地主用户，您的验证码为：%s，该验证码有效时限为5分钟，请尽快确认。请注意不要泄露验证码，若非本人操作，请联系官方客服",

	-- 商城 token 的超时时间（秒）
	shop_token_timeout = 180,

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7801,

	--dev_debug = 1,
	client_message_log = 1,

	--web
	webserver_port = 5211,
	webserver_agent_num = 1,
	webserver_disable_cache = true,

	mysql_host = "192.168.0.203",
	mysql_dbname = "dongfeng_test",
	mysql_port = 23456,
	mysql_user = "root",
	mysql_pwd = "jy520.",
	
	-- skynet 调试控制台端口
	debug_console_port = 18802,

	-- 客户端bug报告文件
	clientBugTrackLog = "logs/client_bug_report_",

	-- 禁止游客登录
	forbid_youke = nil,

	-- 禁止 sql 日志
	--forbid_sql_log = true,

	-- 调试警报系统
	--debug_monitor_system = true,

	-- 打开系统报警功能
	enable_monitor = true,

	-- 每种报警数据 发送告警邮件的最短时间间隔（秒）
	monitor_email_time = 5,

	-- 不真正发邮件，仅仅输出日志（测试用）
	monitor_mock_email = true,

	-- 接收报警数据 的 邮件地址（支持多个，逗号隔开）
	monitor_recieve_email = "695223392@qq.com,421951953@qq.com,24090841@qq.com,949652665@qq.com,344813836@qq.com,83046971@qq.com,liangpai@163.com",
	monitor_recieve_sms = "18382364786,13882218571",

	--- 任务系统 是否启用
	--task_system_is_open = true,

	-- 禁止 外部创建订单。目前就是 微信公总号支付
	--forbid_external_order = true,

	debug_player_prefix = "LYX.",

	-- 登录调试
	network_error_debug = true,

	-- 重加载中心 调试模式
	debug_reload_center = true,

	debug_file_size = 100,	-- 日志文件大小（单位：MB）：超过此大小即分文件

	-- 所有人都是 gm 用户（正式服 千万不能要这行！！！！）
	gm_user_debug = true,
	
	-- 前缀 debug_no_log_ 禁止日志输出到文件过滤的消息名(避免日志过多)
	debug_no_log_multicast_msg = 1,
	debug_no_log_heartbeat = 1,

	-- 开启 热更新配置检查
	--check_hot_config = true,

	mock_send_phone_code = true,
	mock_phone_verify_code=true,

	mock_shutdown_server = true,

	--launch_ok_shell = "./launch_ok.sh",
	
	-- 查询 耗时超过此值的 则打印日志，单位 1/100 秒
	sql_query_timeout = 5,

	-- 需要禁止的日志： {{类型1,模块1},{类型2,模块2} 。。。} * 表示所有
	block_log = {},
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

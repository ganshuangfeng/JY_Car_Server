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

	-- 强化托管玩家： id , 名字, 头像
	tuoguan_list = "robot_list_tg",

	-- 网关配置
	gate_port = 5001,		-- 监听端口
	gate_maxclient = 1000000,	-- 同时在线
	max_request_rate = 100,	-- 每个客户端 5 秒内最大的请求数

	-- 支付测试：为 true 则表示支付行为在测试环境
	is_pay_test = true,
	
	-- 发布准备状态倒计时，单位 秒。 服务启动时，在倒计时结束后才允许登录
	--publish_prepare_cd = 900,

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

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7001,

	--dev_debug = 1,
	--client_message_log = 1,

	-- 语音聊天最大长度（单位 kB）
	voice_max_len = 30,

	--web
	webserver_port = 8001,
	webserver_agent_num = 1,
	webserver_disable_cache = true,

	mysql_host = "192.168.0.203",
	--mysql_host = "171.223.209.152",
	--mysql_dbname = "jygame",
	mysql_dbname = "hewei_test",
	--mysql_dbname = "lyx_test",
	mysql_port = 23456,
	--mysql_port = 5005,
	mysql_user = "jy",
	mysql_pwd = "123456",

	-- skynet 调试控制台端口
	debug_console_port = 18002,

	-- 客户端bug报告文件
	clientBugTrackLog = "logs/client_bug_report_",

	-- 友盟推送
	umeng_android_appkey = "5b8d0566f29d98698d0000c8",
	umeng_android_master_secret = "jx9o6uplgm7tftdzjl45sgnhufq3zpoi",
	umeng_ios_appkey = "5b8e1f8eb27b0a1355000063",
	umeng_ios_master_secret = "furryknmq5xq05xhzuerpoxmzfy70khp",

	-- 产品模式： false 表示只发送给测试设备
	umeng_ios_pmode = "false",

	-- 禁止游客登录
	forbid_youke = nil,

	-- 禁止 sql 日志
	--forbid_sql_log = true,

	-- 禁止强化托管代码
	forbid_tuoguan_manager = true,
	
	tuoguan_max_count = 800,

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
	enable_monitor = true,

	-- 每种报警数据 发送告警邮件的最短时间间隔（秒）
	monitor_email_time = 5,

	-- 不真正发邮件，仅仅输出日志（测试用）
	monitor_mock_email = true,

	-- 接收报警数据 的 邮件地址（支持多个，逗号隔开）
	monitor_recieve_email = "695223392@qq.com,421951953@qq.com,24090841@qq.com,949652665@qq.com,344813836@qq.com,83046971@qq.com,liangpai@163.com",
	--- 任务系统 是否启用
	--task_system_is_open = true,

	--- 步步生财 是否启用
	stepstep_money_is_open = true,

	-- 禁止 外部创建订单。目前就是 微信公总号支付
	--forbid_external_order = true,

	-- 登录调试
	--network_error_debug = true,

	-- 重加载中心 调试模式
	debug_reload_center = true,

	ddz_tuoguan_imp_c = true,

	-- 自由的托管（不限于入场范围）
	free_tuoguan_count = 500,

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
	--麻将发好牌配置************************end	

	tuoguan_er_mj_dapiao_gailv = 25,


	--砸金蛋
	--财神模式
	zjd_caishen_model=true,
	zjd_csmode_zj_power=95,
	zjd_cs_lisnsheng_round=1,
	zjd_cs_lisnsheng_level_3=true,
	zjd_cs_lisnsheng_level_4=true,
	zjd_cs_lisnsheng_start=1556450713,
	zjd_cs_lisnsheng_end=1557071999,


	-- dev_debug_gufing_fp=true,
	-- debug_gufing_fp_p1="566677789900K2222",
	-- debug_gufing_fp_p2="33455788900JQKAAA",
	-- debug_gufing_fp_p3="334689JJJQQQKKAwW",
	-- dev_debug_gufing_dz=true,
	-- debug_gufing_dz=1,

	-- 转换牌
	--mode_trans_pai = true,
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
	node_103 =
	{
		resource = 50000,
	},
	-- node_207 =
	-- {
	-- 	resource = 50000,
	-- },
	-- node_146 =
	-- {
	-- 	resource = 50000,
	-- },

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

	{	
		launch = "ddz_ctor_pai_service/ddz_ctor_pai_center_service",
		deploy = {ddz_ctor_pai_center_service="node_103"},
	},
	{	
		launch = "ddz_ctor_pai_service/ddz_ctor_pai_service",
		deploy = {ddz_ctor_pai_service="*"},
	},
	
}



return {

	configs = configs,
	nodes = nodes,
	services = services,
}

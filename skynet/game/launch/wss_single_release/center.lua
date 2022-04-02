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
	gate_port = 5201,		-- 监听端口

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7201,

	--web
	webserver_port = 8201,

	--[[mysql_host = "192.168.0.203",
	mysql_dbname = "wss_df_test",
	mysql_port = 23456,
	mysql_user = "root",
	mysql_pwd = "jy520.",--]]

	mysql_host = "localhost",
    mysql_dbname = "jygame",
    mysql_port = 3306,
    mysql_user = "root",
    mysql_pwd = "mfkqxxr**111",

	-- skynet 调试控制台端口
	debug_console_port = 8200,

	--debug_player_prefix = "WSS_",

	----- 是否收集 过程数据
	-- is_collect_process_data = true ,
	-- pvp 有真人时，强制匹配真人
    pvp_debug_force_real = true,

    ---- pvp 算战力的规则 ，
    ---- 初始值
	pvp_int_fight = 1400,
	---- 每级的增加值
	pvp_car_level_fight = 100,
	--- 装备每级的增加值
	pvp_eqpt_level_fight = 25 ,
	--- pvp的 匹配上下 战力 范围
	pvp_pipei_fight_range = 200,


}


return {

	configs = configs,
}
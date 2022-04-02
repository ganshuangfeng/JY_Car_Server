--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 服务的配置文件，所有服务信息 都配置在这里
--

--------------------------------------------------
-- 全局参数配置，分发到每个节点
local configs =
{

	-- 网关配置
	gate_port = 5001,		-- 监听端口

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7701,

	--web
	webserver_port = 5212,
	-- mysql_host = "192.168.0.203",
	-- mysql_dbname = "jygame",
	-- mysql_port = 23456,
	-- mysql_user = "jy",
	-- mysql_pwd = "123456",

	mysql_host = "192.168.10.2",--"172.16.88.128", 
	mysql_dbname = "df_test2",
	mysql_port = 3306,
	mysql_user = "root",
	mysql_pwd = "123456",

        -- skynet 调试控制台端口
	debug_console_port = 18801,

	debug_player_prefix = "LYXDF.",
}


return {

	configs = configs,
}
    
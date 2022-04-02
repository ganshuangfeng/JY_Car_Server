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
	admin_console_port = 7001,

	--web
	webserver_port = 8001,

	mysql_host = "127.0.0.1", --"172.18.107.231",
	mysql_dbname = "jygame",
	mysql_port = 15001,
	mysql_user = "read",
	mysql_pwd = "jYserVer246",

	-- skynet 调试控制台端口
	debug_console_port = 8000,

	debug_player_prefix = "WSS_T_",

}


return {

	configs = configs,

}
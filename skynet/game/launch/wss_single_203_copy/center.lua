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
	gate_port = 5602,	
	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7602,


	--web
	webserver_port = 8602,
	mysql_host = "192.168.0.204",
	mysql_dbname = "df_203_copy",
	mysql_port = 3306,
	mysql_user = "root",
	mysql_pwd = "jy520",

	-- skynet 调试控制台端口
	debug_console_port = 8702,

	debug_player_prefix = "203_c_",

		---- 如果是 打开，都是gm调试用户
	gm_user_debug = true,

}

return {

	configs = configs,
}
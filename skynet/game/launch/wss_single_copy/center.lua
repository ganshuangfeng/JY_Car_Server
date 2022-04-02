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
	gate_port = 5202,		-- 监听端口

	-- 管理控制台端口：管理服务状态、关机
	admin_console_port = 7202,


	--web
	webserver_port = 8202,

	mysql_host = "192.168.0.204",
	mysql_dbname = "wss_df_test_2",
	mysql_port = 3306,
	mysql_user = "root",
	mysql_pwd = "jy520",
	debug_console_port = 8202,

	debug_player_prefix = "WSS_",
	----- 是否收集 过程数据
	is_collect_process_data = true ,

	-- pvp 有真人时，强制匹配真人
    pvp_debug_force_real = true,

    ---- 如果是 打开，都是gm调试用户
	gm_user_debug = true,

	
}

return {

	configs = configs,
}
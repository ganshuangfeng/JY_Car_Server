--
-- Created by lyx.
-- User: hare
-- Date: 2018/7/5
-- Time: 15:06
-- 说明：数据采集服务，供 web 后台系统采集本游戏系统中的数据
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local mysql = require "skynet.db.mysql"
local base = require "base"
local nodefunc = require "nodefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

require "data_func"

require "printfunc"

require "collect_service.collect"

local web_api_lib = require "collect_service.web_api_lib"
local web_api_appoint = require "collect_service.web_api_appoint"
local web_api_hotfix = require "collect_service.web_api_hotfix"
local web_api_cpl_admin = require "collect_service.web_api_cpl_admin"
local web_api_other = require "collect_service.web_api_other"
local web_api_log_parse = require "collect_service.web_api_log_parse"

-- 数据库中存放的 单一值（表 system_variant ）
-- 由 init_system_variant 函数管理
DATA.system_variant = DATA.system_variant or {
	last_appoint_id = 0,      	-- 表 admin_webapi_appoint 的上一次 id 值
}

-- 服务配置
base.DATA.service_config = nil

local _readonly_db_param = {

	host=skynet.getenv("readonly_mysql_host"),
	port=tonumber(skynet.getenv("readonly_mysql_port")),
	database=skynet.getenv("readonly_mysql_dbname"),
	user=skynet.getenv("readonly_mysql_user"),
	password=skynet.getenv("readonly_mysql_pwd"),
}

local _db_param = {

	host=skynet.getenv("mysql_host"),
	port=tonumber(skynet.getenv("mysql_port")),
	database=skynet.getenv("mysql_dbname"),
	user=skynet.getenv("mysql_user"),
	password=skynet.getenv("mysql_pwd"),
}

-- 初始化函数（数据库连接成功后调用）
local function on_dbconnected()

end

-- 初始化
local function init_database()

	-- 优先使用只读配置
	local _params = _readonly_db_param.host and _readonly_db_param or _db_param

	_params.max_packet_size = 1024 * 1024

	_params.on_connect = function(_db)
		print(string.format("mysql connect to %s:%s db:%s succeeded !",
						_params.host,
						tostring(_params.port),
						_params.database))

		print("collect service db connected:",_params.host,_params.port,_params.database)

		_db:query( [[
			set character_set_client='utf8mb4';
			set character_set_connection='utf8mb4';
			set character_set_results='utf8mb4';
		]])

		base.DATA.db_mysql = _db

		on_dbconnected()
	end

	mysql.connect(_params)
end

function base.CMD.query_user_online_time(_userId)

	if type(_userId)~="string" or string.len(_userId)<1 then
		return nil,1001
	end

	local sql = string.format([[
						select sum(TO_SECONDS(logout_time)-TO_SECONDS(login_time)) as time from player_login_log where id = '%s' and logout_time is not null;
						]]
				,_userId)

	local ret = base.DATA.db_mysql:query(sql)

	if( ret.errno ) then
		print(string.format("query_user_assets_from_db sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( asset_ret )))
		return nil,1001
	end
	if not ret[1] then
		print(string.format("query_user_assets_from_db asset_ret[1] is nil"))
		return nil,1001
	end

	return ret[1],0
end

function base.CMD.start(_service_config)

	base.DATA.service_config = _service_config

	init_database()

	-- 初始化 系统变量
	PUBLIC.init_system_variant()

	base.import("game/services/collect_service/collect.lua")
	base.import("game/services/collect_service/web_manage.lua")
	base.import("game/services/collect_service/utils.lua")

	web_api_lib.init()
	web_api_appoint.init()
	web_api_log_parse.init()
	web_api_hotfix.init()
	web_api_cpl_admin.init()
	web_api_other.init()
	
end


-- 启动服务
base.start_service()



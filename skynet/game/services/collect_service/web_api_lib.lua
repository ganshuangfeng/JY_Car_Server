--
-- Author: lyx
-- Date: 2018/4/26
-- Time: 17:34
-- 说明：系统管理功能函数
--

local skynet = require "skynet_plus"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local base=require "base"
local payment_config = require "payment_config"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

require "normal_enum"
require "normal_func"
require "data_func"
require "printfunc"

local cluster = require "skynet.cluster"

local server_manager_lib = require "server_manager_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("web_api_lib",{
	-- 玩家的 json 缓存： user_id => json
	api_json_cache = {},

	-- 玩家权限 缓存
	api_permi_cache = {},

	-- api 的名字映射
	api_ch2name_map = {}, -- name_ch => name
	api_name2ch_map = {}, -- name => name_ch
	api_name2data_map = {}, -- name => 数据

	-- 监控配置的 中文名字映射 desc => 配置项
	watch_desc_map = {},

	-- 配置修改时间
	api_config = nil,
	api_config_time = nil,
})

local LF = base.LocalFunc("web_api_lib")

LF.select_funcs = LF.select_funcs or {}
LF.default_funcs = LF.default_funcs or {}

function LF.init()
	skynet.timer(3,function() LF.reset_cache() end)
	skynet.timer(10,function() LF.reset_config() end)
end

function LF.reset_config()
	LD.api_config = nil
end

function LF.reset_cache()
	LD.api_json_cache = {}
	LD.api_permi_cache = {}
end

function LF.role_memb2map(_memb)
	local _map = {}
	for _,v in ipairs(_memb) do
		if "*" == v then
			return "*"
		end
		_map[v] = true
	end

	return _map
end

-- 返回： {env={}或"*",api={}或"*"} ， * 表示所有
function LF.get_env_api_names(_config,_user_info)
	local _ret = {env={},api={}}
	for _,role in ipairs(_user_info.role) do

		if _ret.env ~= "*" then
			local _membs = LF.role_memb2map(_config.role[role].env)
			if _membs ~= "*" then
				basefunc.merge(_membs,_ret.env)
			else
				_ret.env = "*"
			end
		end

		if _ret.api ~= "*" then
			local _membs = LF.role_memb2map(_config.role[role].api)
			if _membs ~= "*" then
				basefunc.merge(_membs,_ret.api)
			else
				_ret.api = "*"
			end
		end

		if _ret.env == "*" and _ret.api == "*" then -- 都是通配符，不用再找了
			return _ret
		end
	end


	return _ret
end

function LF.select_funcs.nodes(_context)
	local ret = {}
	local nodes = skynet.call(DATA.service_config.center_service,"lua","get_node_list")
	if nodes then
		for _name,_ in pairs(nodes) do
			table.insert(ret,_name)
		end

		return ret
	else
		return {"game","data","gate","tg","node_1"}
	end
end 

function LF.select_funcs.market_channels(_context)
	local _cfg = nodefunc.get_global_config("share_invite_config")
	local ret = {}
	for _name,_ in pairs(_cfg.all_market_channel) do
		table.insert(ret,_name)
	end

	return ret
end

function LF.select_funcs.cpl_names(_context)
	local cpl_admin = base.LocalData("web_api_cpl_admin")
	if not cpl_admin or not cpl_admin.CPLS then
		return nil -- 不显示选择框
	end

	local ret = {}
	for _name,_ in pairs(cpl_admin.CPLS) do
		table.insert(ret,_name)
	end

	return ret
	
end

function LF.select_funcs.platforms(_context)
	local _cfg = nodefunc.get_global_config("share_invite_config")
	local ret = {}
	for _name,_ in pairs(_cfg.all_platform) do
		table.insert(ret,_name)
	end

	return ret
end

function LF.select_funcs.static_services(_context)
	local ret = {}
	local _services = skynet.call(DATA.service_config.node_service,"lua","get_service_config")
	for _name,_ in pairs(_services) do
		table.insert(ret,_name)
	end

	return ret
end

function LF.select_funcs.login_channel_types(_context)
	local ret = {}
	local _lcfg = nodefunc.get_global_config("login_config")
	for _name,_ in pairs(_lcfg.login_info) do
		table.insert(ret,_name)
	end

	return ret
end

function LF.select_funcs.op_user_list(_context)
	local ret = {}
	local _webcfg = nodefunc.get_global_config("webapi_define")
	for _name,_ in pairs(_webcfg.user) do
		table.insert(ret,_name)
	end

	return ret
end

function LF.select_funcs.op_type_list(_context)
	local ret = {}
	local _webcfg = nodefunc.get_global_config("webapi_define")
	for _,_data in pairs(_webcfg.api) do
		table.insert(ret,_data.name_ch)
	end

	return ret
end

function LF.select_funcs.watch_name_list(_context)

	local ret = {}
	local _cfg = nodefunc.get_global_config("monitor_config")
	for _,_data in pairs(_cfg) do
		if _data.watch then
			table.insert(ret,_data.watch.desc)
		end
	end

	return ret
end

function LF.select_funcs.appoint_list(_context)

	local ret = {}
	local wa_appoint = base.LocalFunc("web_api_appoint")
	for _,_data in pairs(wa_appoint.get_appoint_data_list()) do
		table.insert(ret,_data.desc)
	end

	return ret
end

function LF.default_funcs.shutdown_time(_context)
	return tostring(server_manager_lib.get_shutdown_time())
end

function LF.reset_watch_desc_map()

	LD.watch_desc_map = {}

	local _cfg = nodefunc.get_global_config("monitor_config")
	for _,_data in pairs(_cfg) do
		if _data.watch then
			if LD.watch_desc_map[_data.watch.desc] then
				print("monitor config error,watch desc duplicate:",_data.watch.desc)
			end
			LD.watch_desc_map[_data.watch.desc] = _data
		end
	end
end

-- 配置解析
function LF.parse_api_config(_config,_user_id) 

	_config = basefunc.deepcopy(_config)

	local _context = {
		user_id = _user_id,
		api = nil,
		param_i=nil,
		param_name=nil,
	}

	LF.reset_watch_desc_map()

	LD.api_ch2name_map = {}
	LD.api_name2ch_map = {}
	LD.api_name2data_map = {}

	for _,_api_def in pairs(_config.api) do

		-- 找 select 参数
		_context.api = _api_def

		if LD.api_ch2name_map[_api_def.name_ch] then
			print("web api lib parse_api_config error,api name_ch duplicate:",_api_def.name_ch)
		end
		LD.api_ch2name_map[_api_def.name_ch] = _api_def.name

		if LD.api_name2ch_map[_api_def.name] then
			print("web api lib parse_api_config error,api name_ch duplicate:",_api_def.name)
		end
		LD.api_name2ch_map[_api_def.name] = _api_def.name_ch

		LD.api_name2data_map[_api_def.name] = _api_def

		for i,param in ipairs(_api_def.params) do

			-- 获取默认值
			if type(param.select) == "string" then -- 字符串表示函数
				local _f = LF.select_funcs[param.select]
				if _f then
					_context.param_i = i
					_context.param_name = param.name
					param.select = _f(_context)
				else
					print("parse web api define error,not found select funcs:",_api_def.name,param.select)
				end
			end
			
			-- 获取默认值
			if type(param.default)=="string" and string.sub(param.default,1,5) == "func:" then
				local _f = LF.default_funcs[string.sub(param.default,6)]
				if _f then
					param.default = _f(_context)
				else
					print("parse web api define error,not found default funcs:",_api_def.name,param.default)
				end
			end
		end
	end

	return _config
end

function LF.safe_user_api_json(_user_id)

	local _json = LD.api_json_cache[_user_id]
	if _json then
		return _json
	end

	local _config,_time = nodefunc.get_global_config("webapi_define")
	if not LD.api_config or _time ~= LD.api_config_time then

		_config = LF.parse_api_config(_config,_user_id)
		
		LD.api_config = _config
		LD.api_config_time = _time
	else
		_config = LD.api_config
	end

	local _data = {
		env = {},
		route = {},
	}

	local _user_info = _config.user[_user_id]
	if not _user_info then
		return 
[[
	{
		"env": [ ], 
		"route": [ ]
	}	
]]		
	end

	-- 获得权限信息
	local _perms = LF.get_env_api_names(_config,_user_info)
	LD.api_permi_cache[_user_id] = _perms

	for _,v in ipairs(_config.env) do
		if _perms.env == "*" or _perms.env[v.name] then
			table.insert(_data.env,v)
		end
	end
	
	for _,v in ipairs(_config.api) do
		if _perms.api == "*" or _perms.api[v.name] then
			table.insert(_data.route,v)
		end
	end

	_json = cjson.encode(_data)
	LD.api_json_cache[_user_id] = _json
	return _json
end

function CMD.getApiDefine(_op_user)
    return LF.safe_user_api_json(_op_user)
end

-- 用户操作验证
function LF.user_op_verify(_op_user,_api)

	if not _op_user then
		return false,"错误:未提供操作人!"
	end

	local _config = nodefunc.get_global_config("webapi_define")
	if not _config.user[_op_user] then
		return false,"错误:操作人 '" .. tostring(_op_user) .. "' 不存在!"
	end
	
	LF.safe_user_api_json(_op_user)

	local _d = LD.api_permi_cache[_op_user]
	if not _d then
		return false,"错误:操作人 '" .. tostring(_op_user) .. "' 没有权限数据!"
	end

	if string.sub(_api,1,1) ~= "/" then -- 相对路径，默认为 /sczd/xxxxx
		_api = "/sczd/" .. _api 
	end

	if _d.api == "*" or _d.api[_api] then
		return true
	end

	return false,"错误:操作人 '" .. tostring(_op_user) .. "' 没有该权限!"
end

function LF.name_from_ch(_name_ch)
	return LD.api_ch2name_map[_name_ch]
end

function LF.ch_from_name(_name)
	if not _name then
		return nil
	end
	return LD.api_name2ch_map[_name] or LD.api_name2ch_map["/sczd/" .. _name]
end

function LF.api_from_name(_name)
	if not _name then
		return nil
	end
	return LD.api_name2data_map[_name] or LD.api_name2data_map["/sczd/" .. _name]
end

function LF.monitor_from_watch_desc(_watch_desc)
	return LD.watch_desc_map[_watch_desc]
end

function LF.format_api_param_value(_type,_val)
	if nil == _val then
		return "<空>"
	end

	if "datetime" == _type then
		return basefunc.date(nil,math.floor(_val/1000))
	elseif "date" == _type then
		return basefunc.date("%Y-%m-%d",math.floor(_val/1000))
	elseif "time" == _type then
		return basefunc.date("%H:%M:%S",math.floor(_val/1000))
	elseif "bool" == _type then
		return _val == true and "是" or "否"
	else
		return tostring(_val)
	end
end

LF.html_encode_repls = {
	[" "] = "&nbsp;",
	["\n"] = "<br/>",
	["\t"] = "&nbsp;&nbsp;&nbsp;&nbsp;",
}

function LF.html_encode(_str)
	_str = tostring(_str)

	_str = string.gsub(_str,"[ \n\t]",LF.html_encode_repls)
	_str = string.gsub(_str,"\\/","/")
	_str = string.gsub(_str,"\\n","<br/>")
	_str = string.gsub(_str,"\\t","&nbsp;&nbsp;&nbsp;&nbsp;")

	return _str
end



return LF
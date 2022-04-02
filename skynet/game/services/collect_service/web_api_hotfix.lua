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

local cluster = require "skynet.cluster"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local wa_lib = base.LocalFunc("web_api_lib")

local LD = base.LocalData("web_api_hotfix",{
	
	shutcut_help_text = "\n服务名称的格式：\n" .. PUBLIC.service_invoker_help_text,
})

local LF = base.LocalFunc("web_api_hotfix")

function LF.init()
	
end

function LF.hot_fix_sys_service_base(_api_name,_data_json,data,_src_code,_src_name)
	
	local ok,err = wa_lib.user_op_verify(data.op_user,_api_name)
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _invoker,_msg = PUBLIC.get_service_invoker(data.service_name,"call")
	if not _invoker then
		return [[<font color="#FF0000">[失败]</font></br>service name error:</br>]] .. wa_lib.html_encode(_msg .. "\n" .. LD.shutcut_help_text)
	end

	-- 注意， ok22 接收 exe_lua_base 的 true/false
	local ok2,ok22,ret = pcall(_invoker,"exe_lua_base",_src_code,_src_name) 

	local _err_info
	if not ok2 then
		_err_info = tostring(ok22)
	elseif not ok22 then
		_err_info = tostring(ret)
	end

	local ret_str
	if _err_info then
		ret_str = [[<font color="#FF0000">[失败] </font></br>exec error:</br></br>]] .. wa_lib.html_encode(_err_info)
	else
		ret_str = [[<font color="#00FF50">[成功]</font></br></br>]] .. wa_lib.html_encode(cjson.encode(ret))
	end

	-- 记录日志
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = _api_name,
		params = _data_json,
		succ = _err_info and 0 or 1,
		result = ret_str,
	}
	
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return ret_str
end

function LF.hot_fix_dyna_service_base(_api_name,_data_json,data,_src_code,_fix_name)
	
	local ok,err = wa_lib.user_op_verify(data.op_user,_api_name)
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local fixnames = skynet.call(DATA.service_config.center_service,"lua","get_dyna_hotfix_list")
	if not fixnames[_fix_name] then
		return [[<font color="#FF0000">[失败]</font></br>更新标识不存在:</br>]] .. tostring(_fix_name)
	end

	local ok2,ok22,msg = xpcall(cluster.call,basefunc.error_handle,data.node_name,"node_service","perform_hotfix_file",_fix_name,_src_code)

	local _err_info
	if not ok2 then
		_err_info = tostring(ok22)
	elseif not ok22 then
		_err_info = tostring(msg)
	end

	local ret_str
	if _err_info then
		ret_str = [[<font color="#FF0000">[失败] </font></br>hot fix error:</br></br>]] .. wa_lib.html_encode(_err_info)
	else
		ret_str = [[<font color="#00FF50">[成功]</font></br></br>]] .. wa_lib.html_encode(cjson.encode(msg))
	end
	
	-- 记录日志
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = _api_name,
		params = _data_json,
		succ = ok and 1 or 0,
		result = ret_str,
	}
	
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return ret_str
end
------------------------------------------------------------
-- 接口函数

-- 【web 调用】热更新文件，静态服务
-- service_name 支持的格式参见 PUBLIC.get_service_invoker
function CMD.hot_fix_sys_service_code(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local _code = basefunc.string.trim_nil(data.src_code)
	local _fcode = basefunc.string.trim_nil(data.src_file.data)
	if _code and _fcode then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> '输入代码' 和 '选择文件' 只能提供一个]]
	end

	if _fcode then
		return LF.hot_fix_sys_service_base("hot_fix_sys_service_file",_data_json,data,_fcode,data.src_file.name)
	else
		return LF.hot_fix_sys_service_base("hot_fix_sys_service_code",_data_json,data,_code,"[hotfix service code]")
	end

end

-- 【web 调用】热更新代码，动态服务
function CMD.hot_fix_dyna_service_code(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	return LF.hot_fix_dyna_service_base("hot_fix_dyna_service_code",_data_json,data,data.src_code,data.dyna_fix_name)
end
-- 【web 调用】热更新代码，动态服务
function CMD.hot_fix_dyna_service_file(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end
	
	return LF.hot_fix_dyna_service_base("hot_fix_dyna_service_file",_data_json,data,data.src_code.data,basefunc.path.split_ext(data.src_code.name))
end

-- 【web 调用】热更新动态配置文件（lua代码）

-- 【web 调用】热更新静态配置文件（excel导出配置）



return LF
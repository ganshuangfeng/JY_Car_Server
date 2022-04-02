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
local wa_appoint = base.LocalFunc("web_api_appoint")

local LD = base.LocalData("web_api_cpl_admin",{

	-- cpl 配置文件时间
	cpl_common_time = 0,

	-- CPL 信息： 服务短名称 => {channel=渠道名,service=服务名}
	CPLS = {},
	
})

local LF = base.LocalFunc("web_api_cpl_admin")

function LF.init()
	LF.safe_load_cpls()
end

function LF.safe_load_cpls()
	local _cfg,_time = nodefunc.get_global_config("cpl_common_config")
	if _cfg and _time ~= LD.cpl_common_time then
		LD.CPLS = {}

		for _plat,_cpls in pairs(_cfg.trigger_service) do
			for _cpl,_cpl_serv in pairs(_cpls) do
				local _name = string.gsub(_cpl_serv,"_service$","")
				_name = string.gsub(_name,"^cpl_","")
				LD.CPLS[_name] = {channel=_cpl,service=_cpl_serv}
			end
		end
	end
end

function LF.get_cpl_service(_cpl_name)
	LF.safe_load_cpls()
	return LD.CPLS[_cpl_name] and LD.CPLS[_cpl_name].service
end

-- 得到 cpl 的渠道名
function LF.get_cpl_channel(_cpl_name)
	LF.safe_load_cpls()
	return LD.CPLS[_cpl_name] and LD.CPLS[_cpl_name].channel
end

-- 【web 调用】查询用户信息
function CMD.cpl_get_player_info(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"cpl_get_player_info")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _cpl_name = basefunc.string.trim_nil(data.cpl_name)
	if not _cpl_name or not LF.get_cpl_service(_cpl_name) then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> CPL名称不存在:]] .. tostring(_cpl_name)
	end
	local _svr = DATA.service_config[LF.get_cpl_service(_cpl_name)]
	if not _svr then
		return [[<font color="#FF0000">[失败]</font></br>内部错误:</br> CPL程序模块未运行:]] .. tostring(LF.get_cpl_service(_cpl_name))
	end

	local _device_id = basefunc.string.trim_nil(data.device_id)
	local _player_id = basefunc.string.trim_nil(data.player_id)
	if _device_id and _player_id or not _device_id and not _player_id then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> '设备ID' 和 '账号ID' 必须且只能提供一个]]
	end

	local ok2,_data
	if _device_id then
		ok2,_data = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","query_cpl_data","device_id",_device_id)
	else
		ok2,_data = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","query_cpl_data","id",_player_id)
	end

	local ret_str
	if not ok2 then
		ret_str = [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(_data)
	else
		local s
		if _data then
			s = wa_lib.html_encode(basefunc.tostring(_data))
		else
			s = "<无数据>"
		end
		ret_str = [[<font color="#00FF50">[成功]</font></br></br>]] .. s
	end

	-- 查询不做日志
	------

	return ret_str
	
end


-- 【web 调用】修改玩家设备ID
function CMD.cpl_set_device_id(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"cpl_set_device_id")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _cpl_name = basefunc.string.trim_nil(data.cpl_name)
	if not _cpl_name or not LF.get_cpl_service(_cpl_name) then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> CPL名称不存在:]] .. tostring(_cpl_name)
	end
	local _svr = DATA.service_config[LF.get_cpl_service(_cpl_name)]
	if not _svr then
		return [[<font color="#FF0000">[失败]</font></br>内部错误:</br> CPL程序模块未运行:]] .. tostring(LF.get_cpl_service(_cpl_name))
	end

	local _device_id = basefunc.string.trim_nil(data.device_id)
	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _device_id or not _player_id then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> '设备ID' 或 '账号ID' 不合法]]
	end	

	-- 查询 渠道
	local _pdata = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register")
	if not _pdata then
		return [[<font color="#FF0000">[失败]</font></br>错误:</br> 玩家 id 不存在！]]
	elseif _pdata.market_channel ~= LF.get_cpl_channel(data.cpl_name) then
		return [[<font color="#FF0000">[失败]</font></br>错误:</br> 玩家不属于该渠道！]]
	end

	-- 查询设备 id 是否已存在
	local _,_data3 = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","query_cpl_data","device_id",_device_id)
	if _data3 then
		if _data3.id ~= _player_id then
			return [[<font color="#FF0000">[失败]</font></br>错误:</br> 设备id已被其他玩家使用！]]
		else
			return [[<font color="#008800">[未执行]</font></br></br> 设备id相等，无需修改！]]
		end
	end

	local ok2,_data = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","man_set_cpl_value",_player_id,"device_id",_device_id)

	local ret_str
	if not ok2 then
		ret_str = [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(_data)
	else
		if _data then
			ret_str = [[<font color="#00FF50">[成功]</font></br></br>]] .. wa_lib.html_encode(_data)
		else
			ret_str = [[<font color="#FF0000">[失败]</font></br>错误:</br> 玩家数据错误！]]
			ok2 = false
		end
	end

	-- 记录日志
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "cpl_set_device_id",
		params = _data_json,
		succ = ok2 and 1 or 0,
		result = ret_str,
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return ret_str
	
end

-- 【web 调用】cpl 开始新的一期
-- 参数 _do_appoint： 预约被实际执行时 为 true
function CMD.cpl_begin_new_phase_data(_data_json,_do_appoint)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"cpl_begin_new_phase_data")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _cpl_name = basefunc.string.trim_nil(data.cpl_name)
	if not _cpl_name or not LF.get_cpl_service(_cpl_name) then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> CPL名称不存在:]] .. tostring(_cpl_name)
	end
	local _svr = DATA.service_config[LF.get_cpl_service(_cpl_name)]
	if not _svr then
		return [[<font color="#FF0000">[失败]</font></br>内部错误:</br> CPL程序模块未运行:]] .. tostring(LF.get_cpl_service(_cpl_name))
	end

	local _os = basefunc.string.trim_nil(data.os)
	local _platform = basefunc.string.trim_nil(data.platform)

	local _appoint_time = tonumber(basefunc.string.trim_nil(data.appoint_time))
	if _appoint_time then
		_appoint_time = math.floor(_appoint_time/1000)
	end

	local ok2,_ok3,_count
	local ret_str
	local _appoint

	if not _appoint_time or _do_appoint then -- 不是预约，或 预约执行 才 真正执行

		ok2,_ok3,_count = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","begin_new_phase_data",_os,_platform)

		if not ok2 then
			ret_str = [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(_ok3)
		else
			if _ok3 then
				ret_str = [[<font color="#00FF50">[成功]</font></br></br> 清理玩家数量：]] .. tostring(_count)
			else
				ret_str = [[<font color="#FF0000">[失败]</font></br>错误:</br>]] .. tostring(_count)
				ok2 = false
			end
		end

		if _do_appoint then -- 执行预约，则注明
			_appoint = 2
		end
	elseif _appoint_time then -- 预约
		if _appoint_time < (os.time() + 1800) then
			return [[<font color="#FF0000">[失败]</font></br> 预约执行时间至少应该在 30 分钟以后！]]
		end

		local apt_ok,apt_err = wa_appoint.append_appoint_data("cpl_begin_new_phase_data",data,_data_json)
		if not apt_ok then
			return [[<font color="#FF0000">[失败]</font></br> ]] .. tostring(apt_err)
		end
		_appoint = 1
		ok2 = true

		ret_str = [[<font color="#00FF50">[预约成功]</font></br></br>]]
	else
		return [[<font color="#FF0000">[失败]</font></br> 参数不正确:]] .. tostring(_appoint_time) .. "," .. tostring(_do_appoint) 
	end

	-- 记录日志
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "cpl_begin_new_phase_data",
		params = _data_json,
		succ = ok2 and 1 or 0,
		result = ret_str,
		appoint = _appoint,
	}
	
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return ret_str	
	
end

-- 【web 调用】cpl 备份日志查询
function CMD.cpl_back_phase_list(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"cpl_back_phase_list")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _cpl_name = basefunc.string.trim_nil(data.cpl_name)
	if not _cpl_name or not LF.get_cpl_service(_cpl_name) then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> CPL名称不存在:]] .. tostring(_cpl_name)
	end
	local _svr = DATA.service_config[LF.get_cpl_service(_cpl_name)]
	if not _svr then
		return [[<font color="#FF0000">[失败]</font></br>内部错误:</br> CPL程序模块未运行:]] .. tostring(LF.get_cpl_service(_cpl_name))
	end

	local ok2,ok3,_data = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","get_back_phase_list")
	if not ok2 then
		return [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(ok3)
	end

	if not ok3 then
		return [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(_data)
	end

	local rows = {[[<font color="#00FF50">[成功]</font></br></br>]]}
	table.insert(rows,[[<table border="1">]])
	table.insert(rows,[[
<tr>
<th>备份id</th>
<th>系统类型</th>
<th>平台标识</th>
<th>数量</th>
<th>时间</th>
</tr>]])
	for i,v in ipairs(_data) do
		v.systype = v.systype or "<无>"
		v.platform = v.platform or "<无>"
		table.insert(rows,basefunc.repl_str_var([[
<tr>
<td>@backup_id@</td>
<td>@systype@</td>
<td>@platform@</td>
<td>@user_numb@</td>
<td>@time@</td>
</tr>]],v))

	end

	table.insert(rows,[[</table>]])

	return table.concat(rows,"\n")
end

-- 【web 调用】cpl 恢复备份
function CMD.cpl_restore_back_phase_data(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"cpl_restore_back_phase_data")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _cpl_name = basefunc.string.trim_nil(data.cpl_name)
	if not _cpl_name or not LF.get_cpl_service(_cpl_name) then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> CPL名称不存在:]] .. tostring(_cpl_name)
	end
	local _svr = DATA.service_config[LF.get_cpl_service(_cpl_name)]
	if not _svr then
		return [[<font color="#FF0000">[失败]</font></br>内部错误:</br> CPL程序模块未运行:]] .. tostring(LF.get_cpl_service(_cpl_name))
	end

	local _back_id = tonumber(data.bakup_id)
	if not _back_id then
		return [[<font color="#FF0000">[失败]</font></br>参数错误:</br> 备份id必须为数字]]
	end

	local ok2,ok3,_count = xpcall(skynet.call,basefunc.error_handle,_svr,"lua","restore_back_phase_data",_back_id)

	local ret_str
	if not ok2 then
		ret_str = [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(ok3)
	elseif not ok3 then
		ret_str = [[<font color="#FF0000">[失败] </font></br>query error:</br></br>]] .. wa_lib.html_encode(_count)
	else
		ret_str = [[<font color="#00FF50">[成功]</font></br></br> 恢复玩家数量：]] .. tostring(_count)
	end

	return ret_str
end

return LF
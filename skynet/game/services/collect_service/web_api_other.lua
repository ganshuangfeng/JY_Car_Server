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

local server_manager_lib = require "server_manager_lib"
 
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local wa_lib = base.LocalFunc("web_api_lib")
local wa_logp = base.LocalFunc("web_api_log_parse")
local wa_appoint = base.LocalFunc("web_api_appoint")

local LD = base.LocalData("web_api_other",{

})

local LF = base.LocalFunc("web_api_other")


function LF.init()
	
end



-- 转换日期时间范围：
-- 	微妙转换为毫秒
--	未给出值时， 转换默认范围
function LF.translate_time_range(_data)
	local _start_time = basefunc.string.trim_nil(_data.start_time)
	local _end_time = basefunc.string.trim_nil(_data.end_time)

	if _start_time then 
		_start_time = math.floor(_start_time/1000)
	else
		_start_time = skynet.time_of_today() -- 默认为今天开始的时间
	end

	if _end_time then 
		_end_time = math.floor(_end_time/1000)
	else
		_end_time = skynet.time_of_today(_start_time) + 86400 -- 默认 当天为结束时间
	end

	-- 范围不合法，则调整
	if _end_time <= _start_time then
		_end_time = skynet.time_of_today(_start_time) + 86400 -- 默认 当天为结束时间
	end

	return _start_time,_end_time
end

function CMD.admin_query_op_log(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_query_op_log")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _log_op_user = basefunc.string.trim_nil(data.log_op_user)
	local _log_op_type = basefunc.string.trim_nil(data.log_op_type)
	local _start_time,_end_time = LF.translate_time_range(data)

	local _api_name = _log_op_type and wa_lib.name_from_ch(_log_op_type)
	_api_name = _api_name and string.gsub(_api_name,"^/sczd/","")

	-- 构建 sql

	local _wheres = {}
	if _log_op_user then
		table.insert(_wheres,PUBLIC.format_sql("op_user=%s",tostring(_log_op_user)))
	end
	if _api_name then
		table.insert(_wheres,PUBLIC.format_sql("api=%s",tostring(_api_name)))
	end
	if _start_time then
		table.insert(_wheres,PUBLIC.format_sql("op_time>=FROM_UNIXTIME(%s)",_start_time))
	end
	if _end_time then
		table.insert(_wheres,PUBLIC.format_sql("op_time<=FROM_UNIXTIME(%s)",_end_time))
	end

	local _sql = string.format("select * from admin_webapi_log where %s order by op_time;",table.concat(_wheres," and "))

	-- 查询数据
	local ret = DATA.db_mysql:query(_sql)
	if( ret.errno ) then
		return [[<font color="#FF0000">[失败]</font><br/>sql error:<br/>]] .. wa_lib.html_encode(
			string.format("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
	end

	local _date_str = string.format("时间范围：%s ~ %s",basefunc.date(nil,_start_time),basefunc.date(nil,_end_time))
	  
	if not ret[1] then
		return string.format([[<br/>%s <br/> <br/> 查询结果 <br/><font color="#000050">[没有数据]</font><br/><br/>]],_date_str)
	end

	local _func = wa_logp.get_parse_func(_api_name)

	local _html_titles = {}
	table.insert(_html_titles,[[<tr>]])
	table.insert(_html_titles,[[<th>序号</th>]])
	local _title_names = _func()
	for _,_tstr in ipairs(_title_names) do
		table.insert(_html_titles,string.format([[<th>%s</th>]],_tstr))
	end
	table.insert(_html_titles,[[</tr>]])
	
	local _html_rows = {}
	for i,_d in ipairs(ret) do
		local _row_d = _func(_d)
		local _cells = {}
		table.insert(_cells,[[<tr>]])
		table.insert(_cells,string.format([[<td>%d</td>]],i))
		for i2=1,#_title_names do
			table.insert(_cells,string.format([[<td>%s</td>]],_row_d[i2]))
		end
		table.insert(_cells,[[</tr>]])
		table.insert(_html_rows,table.concat(_cells))
	end
	return string.format([[
		%s
		</br>
		<table border="1">%s %s </table>
	]],_date_str,
	table.concat(_html_titles),table.concat(_html_rows))
end

-- 【web 调用】设置 单日 限额
function CMD.admin_set_player_day_limit(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_set_player_day_limit")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	local _limit = tonumber(basefunc.string.trim_nil(data.limit))
	if not _player_id or not _limit then
		return [[<font color="#FF0000">[失败]</font><br/>参数错误<br/>]]
	end

	local _cur_sum = tonumber(basefunc.string.trim_nil(data.cur_sum))
	
	local ok2,_ok3,_data = xpcall(skynet.call,basefunc.error_handle,DATA.service_config.data_service,"lua","set_player_day_limit",_player_id,_limit,_cur_sum)

	local ret_str
	if not ok2 then
		ret_str = [[<font color="#FF0000">[失败] </font><br/>query error:<br/><br/>]] .. wa_lib.html_encode(_ok3)
	else
		if _ok3 then
			if _data then
				ret_str = [[<font color="#00FF50">[成功]</font><br/><br/>限额已设置为 ]] .. tostring(_data.pay_limit)
			else
				ret_str = [[<font color="#00FF50">[成功]</font><br/><br/>玩家限额已清除]]
			end
		else
			ret_str = [[<font color="#FF0000">[失败]</font><br/>]] .. wa_lib.html_encode(tostring(_data))
			ok2 = false
		end
	end

	-- 记录日志
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_set_player_day_limit",
		params = _data_json,
		succ = ok2 and 1 or 0,
		result = ret_str,
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return ret_str	
	
end

-- 【web 调用】查询 单日 限额
function CMD.admin_query_player_day_limit(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_query_player_day_limit")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)

	local ok2,_data = xpcall(skynet.call,basefunc.error_handle,DATA.service_config.data_service,"lua","query_player_day_limit",_player_id)

	if not ok2 then
		return [[<font color="#FF0000">[失败] </font><br/>query error:<br/><br/>]] .. wa_lib.html_encode(_data)
	end

	if not _data then
		return [[<font color="#00FF50">[失败]</font><br/> <没有数据>]]
	end

	local rows = {[[<font color="#00FF50">[成功]</font><br/><br/>]]}
	table.insert(rows,[[<table border="1">]])
	table.insert(rows,[[
<tr>
<th>玩家id</th>
<th>每日限额</th>
<th>今天支付</th>
</tr>]])
	for k,v in pairs(_data) do
		v.id = k
		local s = string.gsub([[
<tr>
<td>@id@</td>
<td>@pay_limit@</td>
<td>@cur_sum@</td>
</tr>]],"@(%g-)@",v)
		table.insert(rows,s)

	end

	table.insert(rows,[[</table>]])

	return table.concat(rows,"\n")
end

function LF.admin_query_player_info_base(_player_id)
	
	local _pinfo = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id)
	if not _pinfo then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>没找到玩家数据<br/>]]
	end

	local _base_str = [[
	<img src="@head_image@"</img><br/>
	<table border="0">
	<tr><td>id:</td><td>@id@</td></tr>
	<tr><td>昵称:</td><td>@name@</td></tr>
	</table>
]]

	local _asset_str = [[
	<table border="0">
	<tr><td>钻石：</td><td>@diamond@</td></tr>
	<tr><td>福卡：</td><td>@shop_gold_sum@</td></tr>
	<tr><td>鲸币：</td><td>@jing_bi@</td></tr>
	<tr><td>现金：</td><td>@cash@</td></tr>
	</table>
]]

	-- 道具
	local _player_props = {[[<table border="0">]]}
	for _,v in pairs(_pinfo.player_prop) do
		table.insert(_player_props,string.format("<tr><td>%s:</td><td>%s</td></tr>",v.prop_type,v.prop_count or 0 ))
	end
	table.insert(_player_props,[[</table>]])
	local _player_props_str = table.concat(_player_props,"\n")
	
	local _register_str = [[
	<table border="0">
	<tr><td>平台：</td><td>@platform@</td></tr>
	<tr><td>渠道：</td><td>@market_channel@</td></tr>
	<tr><td>扫码标志：</td><td>@share_sources@</td></tr>
	<tr><td>系统类型：</td><td>@systype@</td></tr>
	<tr><td>操作系统：</td><td>@register_os@</td></tr>
	<tr><td>设备id：</td><td>@device_id@</td></tr>
	<tr><td>注册途径：</td><td>@register_channel@</td></tr>
	<tr><td>注册时间：</td><td>@register_time@</td></tr>
	</table>
]]

	local _is_online = skynet.call(DATA.service_config.data_service,"lua","is_player_online",_player_id)
	local _is_online_str = _is_online and [[<font color="#008800">在线</font>]] or [[<font color="#FF0000">离线</font>]]

	local _laster_login = {[[<table border="0">]]}
	local llret = PUBLIC.db_query_va("SELECT * FROM `player_login_log` where id = %s order by login_time desc limit 5",_player_id)
	for _,v in ipairs(llret) do
		table.insert(_laster_login,string.format("<tr><td>%s</td><td>&nbsp;到&nbsp;</td><td>%s</td></tr>",v.login_time,v.logout_time or "" ))
	end
	table.insert(_laster_login,[[</table>]])
	local _laster_login_str = table.concat(_laster_login,"\n")
	
	-- 登录方式
	local _lcfg = nodefunc.get_global_config("login_config")
	local _verify_info = {[[<table border="0">]]}
	local llret = PUBLIC.db_query_va("select * from player_verify where id = %s",_player_id)
	for _,v in ipairs(llret) do
		table.insert(_verify_info,string.format("<tr><td>%s:</td><td>%s</td></tr>",_lcfg.login_info[v.channel_type] or "<未知>",v.login_id or "" ))
	end
	table.insert(_verify_info,[[</table>]])
	local _verify_info_str = table.concat(_verify_info,"\n")
	

	-- 合并最终结果
	local ret_str = "状态：" .. _is_online_str
	ret_str = ret_str .. "<hr/><h3>基本资料</h3>" .. string.gsub(_base_str,"@(%g-)@",_pinfo.player_info)
	ret_str = ret_str .. "<hr/><h3>财富</h3>" .. string.gsub(_asset_str,"@(%g-)@",function(_name) return _pinfo.player_asset[_name] or "" end)
	ret_str = ret_str .. "<hr/><h3>道具</h3>" .. _player_props_str
	ret_str = ret_str .. "<hr/><h3>注册信息</h3>" .. string.gsub(_register_str,"@(%g-)@",function(_name) return _pinfo.player_register[_name] or "" end)
	ret_str = ret_str .. "<hr/><h3>账号绑定</h3>" .. _verify_info_str
	ret_str = ret_str .. "<hr/><h3>最近登录</h3>" .. _laster_login_str
	
	return ret_str
end

-- 【web 调用】查询 玩家数据
function CMD.admin_query_player_info(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_query_player_info")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>必须输入 玩家id<br/>]]
	end

	return LF.admin_query_player_info_base(_player_id)
end

-- 【web 调用】查询 玩家数据2
function CMD.admin_query_player_info2(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_query_player_info2")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _platform = basefunc.string.trim_nil(data.platform)
	local _channel_type = basefunc.string.trim_nil(data.channel_type)
	local _login_id = basefunc.string.trim_nil(data.login_id)
	if not _platform or not _channel_type or not _login_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>参数不足，请输入参数！<br/>]]
	end

	local sql = PUBLIC.format_sql("select * from player_verify where login_id=%s and channel_type=%s and platform=%s;",
	_login_id,_channel_type,_platform)
	local ret = PUBLIC.db_query_va(sql)
	if ret.errno then
		return [[<font color="#FF0000">[失败] </font><br/>数据查询时出错：<br/><br/>]] .. wa_lib.html_encode(basefunc.tostring(ret))
	end
	if not ret[1] then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>没找到玩家！<br/>]]
	end

	return LF.admin_query_player_info_base(ret[1].id)
end

-- 【web 调用】删除玩家账号绑定信息
function CMD.admin_del_verify_info(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_del_verify_info")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家id<br/>]]
	end
	local _channel_type = basefunc.string.trim_nil(data.channel_type)
	if not _channel_type then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入绑定类型<br/>]]
	end
	local _lcfg = nodefunc.get_global_config("login_config")
	if not _lcfg.login_info[_channel_type] then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>绑定类型错误<br/>]]
	end
	
	local sql = PUBLIC.format_sql("select * from player_verify where channel_type = %s and id = %s;",_channel_type,_player_id)
	local ret = PUBLIC.db_query(sql)
	if ret.errno then
		return [[<font color="#FF0000">[失败] </font><br/>数据查询脚本错误：<br/>]] .. wa_lib.html_encode(cjson.encode(data))
	end

	if not ret[1] or not ret[1].channel_type or not ret[1].login_id then
		return [[<font color="#FF0000">[失败] </font><br/>玩家没有该类型的绑定信息<br/>]]
	end

	local code,errinfo = skynet.call(DATA.service_config.verify_service,"lua","del_verify_info",_player_id,ret[1].channel_type,ret[1].login_id,data.op_user)
	if 0 == code then

		-- 记录日志
		local log_data = {
			op_user = data.op_user,
			launch = skynet.getenv("start"),
			api = "admin_del_verify_info",
			params = _data_json,
			succ = 1,
			result = basefunc.tostring({code,errinfo}),
		}
		PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))
		return [[<font color="#00FF50">[成功]</font><br/><br/>玩家绑定信息已删除]]
	else
		return [[<font color="#FF0000">[失败] </font><br/>绑定信息删除失败：<br/>]] .. wa_lib.html_encode(tostring(errinfo))
	end	
end


-- 【web 调用】查询已删除玩家账号绑定信息
function CMD.admin_query_deled_verify_info(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_query_deled_verify_info")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	local _login_id = basefunc.string.trim_nil(data.login_id)
	if not _player_id and not _login_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>玩家id、绑定id至少输入一个！<br/>]]
	end

	local _datas = {}

	-- 所有 有关联，或曾经相关的 id
	local _login_ids = {} 
	local _player_ids = {}

	if _player_id then
		table.insert(_player_ids,PUBLIC.sql_strv(_player_id))
		local ret = PUBLIC.db_query_va("select login_id from player_verify where id=%s union select login_id from player_verify_log where id=%s;",_player_id,_player_id)
		for _,v in ipairs(ret) do
			table.insert(_login_ids,PUBLIC.sql_strv(v.login_id))
		end
	end

	if _login_id then
		table.insert(_login_ids,PUBLIC.sql_strv(_login_id))
	end

	local _where
	if next(_login_ids) then
		_where = string.format(" login_id in ('%s') ",table.concat(_login_ids,"','"))
	end
	if next(_player_ids) then
		local _tmp = string.format(" id in ('%s') ",table.concat(_player_ids,"','"))
		if _where then
			_where = _where .. " or " .. _tmp
		else
			_where = _tmp 
		end

	end

	local ret = PUBLIC.db_query(string.format("select * from player_verify_log where %s;",_where))
	if not ret[1] then
		return [[<font color="#AA6650">没有删除的绑定信息</font><br/><br/>]]
	end

	local rows = {[[<font color="#00FF50">[成功]</font><br/><br/>]]}
	table.insert(rows,[[<table border="1">]])
	table.insert(rows,[[
<tr>
<th>玩家id</th>
<th>平台标识</th>
<th>绑定类型</th>
<th>绑定id</th>
<th>操作人</th>
<th>删除日期</th>
</tr>]])
	for k,v in pairs(ret) do
		local s = string.gsub([[
<tr>
<td>@id@</td>
<td>@platform@</td>
<td>@channel_type@</td>
<td>@login_id@</td>
<td>@op_user@</td>
<td>@date@</td>
</tr>]],"@(%g-)@",v)
		table.insert(rows,s)

	end

	table.insert(rows,[[</table>]])

	return table.concat(rows,"\n")	
end

-- 【web 调用】增加账号绑定信息
function CMD.admin_add_verify_info(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_add_verify_info")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	local _channel_type = basefunc.string.trim_nil(data.channel_type)
	local _login_id = basefunc.string.trim_nil(data.login_id)
	if not _player_id or not _login_id or not _channel_type then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>参数不完整（每个都必须填）！<br/>]]
	end

	local _lcfg = nodefunc.get_global_config("login_config")
	if not _lcfg.login_info[_channel_type] then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>无法识别的绑定类型！<br/>]]
	end

	if not skynet.call(DATA.service_config.data_service,"lua","is_player_exists",_player_id) then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>玩家id 不存在！<br/>]]
	end
	
	local _code,_err = skynet.call(DATA.service_config.verify_service,"lua","add_verify_info",_player_id,_channel_type,_login_id,nil,data.op_user)
	if 0 == _code then
		-- 记录日志
		local log_data = {
			op_user = data.op_user,
			launch = skynet.getenv("start"),
			api = "admin_add_verify_info",
			params = _data_json,
			succ = 1,
			result = "ok",
		}
		PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))
		return [[<font color="#00FF50">[成功]</font><br/><br/>账号绑定成功]]
	end

	if 1055 == _code or 2414 == _code then
		local _platform = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register","platform")
		local _pid_old = skynet.call(DATA.service_config.verify_service,"lua","userId_from_login_id",_platform,_channel_type,_login_id)
		if _pid_old == _player_id then
			return [[<font color="#005550">[无需增加]</font><br/>该绑定信息已经存在<br/>]]
		else
			return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>绑定id已被玩家 ]] .. tostring(_pid_old) .. [[ 使用！<br/>]]
		end
	end

	if 2 == _code then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>绑定id已被锁定，稍后再试！<br/>]]
	end

	return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>未知错误！<br/>]]
end

-- 【web 调用】 加入内部测试玩家
function CMD.admin_add_test_user(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_add_test_user")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家id ！<br/>]]
	end

	if not skynet.call(DATA.service_config.data_service,"lua","is_player_exists",_player_id) then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>玩家id不存在 ！<br/>]]
	end

	local _real_name = basefunc.string.trim_nil(data.real_name)
	if not _real_name then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家真实姓名 ！<br/>]]
	end

	skynet.call(DATA.service_config.verify_service,"lua","add_test_user",_player_id,_real_name)

	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_add_test_user",
		params = _data_json,
		succ = 1,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return [[<font color="#00FF50">[成功]</font><br/><br/>加入成功]]
end

-- 【web 调用】 删除内部测试玩家
function CMD.admin_del_test_user(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_del_test_user")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家id ！<br/>]]
	end

	skynet.call(DATA.service_config.verify_service,"lua","del_test_user",_player_id)

	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_del_test_user",
		params = _data_json,
		succ = 1,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return [[<font color="#00FF50">[成功]</font><br/><br/>删除成功]]
end

-- 【web 调用】 查看全部内部测试玩家
function CMD.admin_view_test_user(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_view_test_user")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local ret = PUBLIC.db_query("select * from test_user_list order by op_date;")

	local _usdata = skynet.get_global_data("test_user_list")

	local rows = {[[<font color="#00FF50">[成功]</font><br/><br/>]]}
	table.insert(rows,[[<table border="1">]])
	table.insert(rows,[[
<tr>
<th>#</th>
<th>玩家id</th>
<th>真实姓名</th>
<th>状态</th>
</tr>]])
	for i,v in ipairs(ret) do
		v.index=i
		if _usdata[v.id] then
			v.status = [[<font color="#00AA00">正常</font>]]
		else
			v.status = [[<font color="#FF0000">异常</font>]]
		end

		local s = string.gsub([[
<tr>
<td>@index@</td>
<td>@id@</td>
<td>@real_name@</td>
<td>@status@</td>
</tr>]],"@(%g-)@",v)
		table.insert(rows,s)

	end

	table.insert(rows,[[</table>]])

	return table.concat(rows,"\n")	
end


-- 【web 调用】 加入内部GM玩家
function CMD.admin_add_gm_user(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_add_gm_user")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家id ！<br/>]]
	end

	if not skynet.call(DATA.service_config.data_service,"lua","is_player_exists",_player_id) then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>玩家id不存在 ！<br/>]]
	end

	local _real_name = basefunc.string.trim_nil(data.real_name)
	if not _real_name then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家真实姓名 ！<br/>]]
	end

	skynet.call(DATA.service_config.data_service,"lua","add_gm_user",_player_id,_real_name)

	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_add_gm_user",
		params = _data_json,
		succ = 1,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return [[<font color="#00FF50">[成功]</font><br/><br/>加入成功]]
end

-- 【web 调用】 删除内部GM玩家
function CMD.admin_del_gm_user(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_del_gm_user")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家id ！<br/>]]
	end

	skynet.call(DATA.service_config.data_service,"lua","del_gm_user",_player_id)

	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_del_gm_user",
		params = _data_json,
		succ = 1,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return [[<font color="#00FF50">[成功]</font><br/><br/>删除成功]]
end

-- 【web 调用】 查看全部内部GM玩家
function CMD.admin_view_gm_user(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font><br/>param decode error:<br/>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_view_gm_user")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local ret = PUBLIC.db_query("select * from gm_user_list order by op_date;")

	local _usdata = skynet.get_global_data("gm_user_list")

	local rows = {[[<font color="#00FF50">[成功]</font><br/><br/>]]}
	table.insert(rows,[[<table border="1">]])
	table.insert(rows,[[
<tr>
<th>#</th>
<th>玩家id</th>
<th>真实姓名</th>
<th>状态</th>
</tr>]])
	for i,v in ipairs(ret) do
		v.index=i
		if _usdata[v.id] then
			v.status = [[<font color="#00AA00">正常</font>]]
		else
			v.status = [[<font color="#FF0000">异常</font>]]
		end

		local s = string.gsub([[
<tr>
<td>@index@</td>
<td>@id@</td>
<td>@real_name@</td>
<td>@status@</td>
</tr>]],"@(%g-)@",v)
		table.insert(rows,s)

	end

	table.insert(rows,[[</table>]])

	return table.concat(rows,"\n")	
end


-- 【web 调用】热更新配置
function CMD.admin_reload_config(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	if not data.config_data.name or not data.config_data.data then 
		return [[<font color="#FF0000">[失败]</font></br>请输入配置文件！</br>]]
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_reload_config")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _cfg_name = basefunc.path.split_ext(basefunc.path.name(data.config_data.name))
	local ok,err = skynet.call(DATA.service_config.reload_center,"lua","update_config",_cfg_name,data.config_data.data)

	local ret_str

	if ok then
		ret_str = [[<font color="#00FF50">[成功]</font><br/><br/>配置已更新]]
	else
		ret_str = [[<font color="#FF0000">[失败]</font></br></br>]] .. wa_lib.html_encode(tostring(err))
	end
	
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_reload_config",
		params = _data_json,
		succ = ok and 1 or 0,
		result = ret_str,
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return ret_str
end

-- 【web 调用】热更新配置
function CMD.admin_update_config(_data_json)

	--print("xxxxxxxxxxxxxxxx admin_update_config 1")
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_update_config")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _optype = basefunc.string.trim_nil(data.optype)
	if not _optype then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请选择操作 ！<br/>]]
	end

	if not data.config_data.name or not data.config_data.data then 
		return [[<font color="#FF0000">[失败]</font></br>请输入配置文件！</br>]]
	end

	local ok,ret_str
	local _cfg_name = basefunc.path.split_ext(basefunc.path.name(data.config_data.name))

	--print("xxxxxxxxxxxxxxxx admin_update_config 2",_optype)

	if "upload" == _optype then

		--print("xxxxxxxxxxxxxxxx admin_update_config 3")
		
		local ret,err = skynet.call(DATA.service_config.reload_center,"lua","upload_light_config_file",_cfg_name,data.config_data.data)

		if ret then
			if ret == "checking" then
				ret_str = string.format([[<font color="#00FF50">[成功]</font><br/><br/>配置已上传（时间戳：%s）。后续请执行<font size="15" color="#F05050"> check </font>操作检查内容！]],basefunc.timefmt(err))
			elseif ret == "succ" then
				ret_str = [[<font color="#00FF50">[成功]</font><br/><br/>配置已上传。将在<font size="20" color="#00FF50"> 5 </font> 秒左右自动生效！]]
			else
				return [[<font color="#FF0000">[失败]</font></br></br>]] .. wa_lib.html_encode(tostring(err))
			end
		else
			return [[<font color="#FF0000">[失败]</font></br></br>]] .. wa_lib.html_encode(tostring(err))
		end
	elseif "check" == _optype then
		--print("xxxxxxxxxxxxxxxx admin_update_config check fffffff1:")
		local _cfgdata,err = skynet.call(DATA.service_config.reload_center,"lua","get_checking_config",_cfg_name)
		--print("xxxxxxxxxxxxxxxx admin_update_config check fffffff2:",ok,msg)
		if _cfgdata then
			return string.format([[<font color="#00FF50">[成功]</font><br/>时间戳：%s<br/> <textarea rows="50" cols="150" readonly> %s </textarea> <br/>]],basefunc.timefmt(err),basefunc.tostring(_cfgdata))
		else
			return [[<font color="#FF0000">[失败]</font></br></br>]] .. wa_lib.html_encode(tostring(err))
		end
	elseif "apply" == _optype then
		local _data,err = skynet.call(DATA.service_config.reload_center,"lua","apply_checking_config",_cfg_name)
		if _data then
			ret_str = string.format([[<font color="#00FF50">[成功]</font><br/> 时间戳：%s <br/> <textarea rows="50" cols="150" readonly> %s </textarea> <br/>]],basefunc.timefmt(err),basefunc.tostring(_data))
		else
			ret_str = [[<font color="#FF0000">[失败]</font></br></br>]] .. wa_lib.html_encode(tostring(err))
		end
	else
		--print("xxxxxxxxxxxxxxxx admin_update_config err:",_optype)
		return [[<font color="#FF0000">[失败]操作类型不合法：</font></br></br>]] .. wa_lib.html_encode(tostring(_optype))
	end

	
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_update_config",
		params = _data_json,
		succ = ok and 1 or 0,
		result = ret_str,
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	--print("xxxxxxxxxxxxxxxx admin_update_config 4")
	return ret_str
end

-- 【web 调用】得到配置值
function CMD.admin_get_config(_data_json)

	--print("xxxxxxxxxxxxxxxxxxxxx admin_get_config",_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_get_config")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _config_type = basefunc.string.trim_nil(data.config_type)
	if not _config_type then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请选择配置类型 ！<br/>]]
	end

	local _config_name = basefunc.string.trim_nil(data.config_name)
	if (_config_type ~= "getcfg") and not _config_name then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入配置名称 ！<br/>]]
	end

	local _node_name = basefunc.string.trim_nil(data.node_name) or skynet.getenv("my_node_name")

	if "getcfg" == _config_type then

		if _config_name then
			local _v = cluster.call(_node_name,"node_service","query_config",_config_name)
			return string.format([[<font color="#00FF50">[成功]</font><br/> %s:%s <br/>]],type(_v),wa_lib.html_encode(tostring(_v)))
		else
			local _vs = cluster.call(_node_name,"node_service","get_all_config")
			local rows = {[[<div><font color="#00FF50">[成功]</font><br/><br/>]]}
			table.insert(rows,[[<table border="1">]])
			table.insert(rows,[[
						<tr>
						<th>#</th>
						<th>配置名</th>
						<th>配置值</th>
						<th>数据类型</th>
						</tr>]])
			local i = 0
			for k,v in pairs(_vs) do
				i=i+1
				local vars = {index=i,name=k,tname=type(v),value=wa_lib.html_encode(tostring(v))}
				local s = string.gsub([[
					<tr>
					<td>@index@</td>
					<td>@name@</td>
					<td>@value@</td>
					<td>@tname@</td>
					</tr>]],"@(%g-)@",vars)
					
				table.insert(rows,s)
			end

			table.insert(rows,"</table></div>")

			return table.concat(rows,"\n")	
		end

	elseif "getenv" == _config_type then
		local _v = cluster.call(_node_name,"node_service","query_env",_config_name)
		return string.format([[<font color="#00FF50">[成功]</font><br/> %s:%s <br/>]],type(_v),wa_lib.html_encode(tostring(_v)))
	elseif "get_global_config" == _config_type then
		local _v,_time = nodefunc.get_global_config(_config_name)
		return string.format([[<font color="#00FF50">[成功]</font><br/> 加载时间：%s<br/>配置内容：<br/>%s <br/>]],os.date("%Y-%m-%d %H:%M:%S",_time),wa_lib.html_encode(basefunc.tostring(_v)))
	elseif "query_global_config" == _config_type then
		local _v = nodefunc.query_global_config(_config_name)
		return string.format([[<font color="#00FF50">[成功]</font><br/> 配置内容：<br/>%s <br/>]],wa_lib.html_encode(basefunc.tostring(_v)))
	else
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>配置类型不正确 ！<br/>]]
	end
end



-- 【web 调用】查询服务器信息
function CMD.admin_get_server_info(_data_json)
	
	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_get_server_info")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _data = server_manager_lib.get_server_manager_data()
	local _ret_data = {
		start_time = os.date("%Y-%m-%d %H:%M:%S",_data.server_start_time),
		down_time = "<未设置>",
	}
	_ret_data.start_dur = basefunc.format_time_diff(os.time()-_data.server_start_time)

	if _data.shutdown_time then
		_ret_data.down_time = os.date("%Y-%m-%d %H:%M:%S",_data.shutdown_time)
		_ret_data.shut_cd = string.format("（倒计时：%s）",basefunc.format_time_diff(_data.shutdown_time-os.time()))
	else
		_ret_data.down_time = ""
		_ret_data.shut_cd = ""
	end

	local _db_write_status = skynet.call(DATA.service_config.data_service,"lua","debug_get_status")
	_ret_data.sql_debug_info = table.concat(_db_write_status,"<br/>")

	local _info_str = [[
	<h2>启停状态</h2>
		<table border="0">
		<tr><td>启动时间：</td><td>@start_time@</td><td>（已运行：@start_dur@）</td></tr>
		<tr><td>停服时间：</td><td>@down_time@</td><td>@shut_cd@</td></tr>
		</table>
	<h2>数据写入状态</h2>
		@sql_debug_info@	
]]

	local ret_str = string.gsub(_info_str,"@(%g-)@",_ret_data )

	--print("xxxxxxxxxxxxxxxxxxxxxxx admin_get_server_info 333:",ret_str)
	return ret_str
end


-- 【web 调用】 设置停服时间
function CMD.admin_set_shutdown_time(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_set_shutdown_time")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _down_time = tonumber(basefunc.string.trim_nil(data.shutdown_time))
	if not _down_time then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入停服时间 ！<br/>]]
	end

	_down_time = math.floor(_down_time/1000)
	local _min_diff = math.floor(tonumber(skynet.getcfg("shutdown_min_time_diff") or 600))

	if _down_time - os.time() < _min_diff then
		return string.format([[<font color="#FF0000">[失败] </font><br/>错误：<br/>至少设置在距离现在 '<font size="20" color="#FF0000">%s</font>' 之后！<br/>]],basefunc.format_time_diff(_min_diff))
	end

	if not server_manager_lib.set_shutdown_time(_down_time) then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>内部错误 ！<br/>]]
	end

	local _ret_data = {
		down_time = os.date("%Y-%m-%d %H:%M:%S",_down_time),
		down_cd = basefunc.format_time_diff(_down_time-os.time()),
	}

	local _info_str = [[
		<font color="#00FF50">[成功]</font><br/>
	<table border="0">
	<tr><td>停服时间：</td><td>@down_time@</td></tr>
	<tr><td>倒计时：</td><td>@down_cd@</td></tr>
	</table>
]]

	local _ret_str = string.gsub(_info_str,"@(%g-)@",_ret_data )

	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_set_shutdown_time",
		params = _data_json,
		succ = ok and 1 or 0,
		result = _ret_str,
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return _ret_str
end

-- 【web 调用】 设置微信支付限额
function CMD.admin_set_wechat_pay_limit(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_set_wechat_pay_limit")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _wechat_max_day = tonumber(basefunc.string.trim_nil(data.wechat_max_day)) or -1
	local _wechat_max_once = tonumber(basefunc.string.trim_nil(data.wechat_max_once)) or -1
	local _wechat_max_count_day = tonumber(basefunc.string.trim_nil(data.wechat_max_count_day)) or -1
	local _wechat_max_month = tonumber(basefunc.string.trim_nil(data.wechat_max_month)) or -1

	skynet.call(DATA.service_config.data_service,"lua","set_system_variant","pay_wechat_max_day",_wechat_max_day)
	skynet.call(DATA.service_config.data_service,"lua","set_system_variant","pay_wechat_max_once",_wechat_max_once)
	skynet.call(DATA.service_config.data_service,"lua","set_system_variant","pay_wechat_max_count_day",_wechat_max_count_day)
	skynet.call(DATA.service_config.data_service,"lua","set_system_variant","pay_wechat_max_month",_wechat_max_month)
	
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_set_wechat_pay_limit",
		params = _data_json,
		succ = ok and 1 or 0,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return string.format([[
		<font color="#00FF50">[成功]</font><br/>
	<table border="0">
	<tr><td>微信每天限次：</td><td>%s</td></tr>
	<tr><td>微信单笔限额：</td><td>%s</td></tr>
	<tr><td>微信每天限额：</td><td>%s</td></tr>
	<tr><td>微信每月限额：</td><td>%s</td></tr>
	</table>
	]], tostring(_wechat_max_count_day),tostring(_wechat_max_once),
	    tostring(_wechat_max_day),tostring(_wechat_max_month)
	)
end

-- 【web 调用】 设置玩家支付渠道
function CMD.admin_set_player_pay_channel(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_set_player_pay_channel")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _player_id = basefunc.string.trim_nil(data.player_id)
	if not _player_id then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>请输入玩家 id ！<br/>]]
	end
	if not skynet.call(DATA.service_config.data_service,"lua","is_player_exists",_player_id) then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>玩家 id 不存在！<br/>]]
	end

	local _channels = {
		alipay = data.alipay == true or false,
		weixin = data.weixin == true or false,
	}

	if _channels.alipay and _channels.weixin then
		skynet.call(DATA.service_config.data_service,"lua","set_player_pay_channels",_player_id,nil)	
	elseif not _channels.alipay and not _channels.weixin then
		return [[<font color="#FF0000">[失败] </font><br/>错误：<br/>至少要选择一个 ！<br/>]]
	else
		skynet.call(DATA.service_config.data_service,"lua","set_player_pay_channels",_player_id,_channels)	
	end
	
	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_set_player_pay_channel",
		params = _data_json,
		succ = ok and 1 or 0,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))

	return string.format([[
		<font color="#00FF50">[成功]</font><br/>
	<table border="0">
	<tr><td>玩家：</td><td>%s</td></tr>
	<tr><td>微信：</td><td>%s</td></tr>
	<tr><td>支付宝：</td><td>%s</td></tr>
	</table>
	]], tostring(_player_id),_channels.weixin and "是" or "否",_channels.alipay and "是" or "否")
end

function CMD.admin_query_wechat_pay_config(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_query_wechat_pay_config")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _ret_str = string.format([[
		<h5>微信限额配置：</h5><br/>
		<table border="0">
		<tr><td>微信每日限次：</td><td>%d</td></tr>
		<tr><td>微信单笔限额：</td><td>%d</td></tr>
		<tr><td>微信每日限额：</td><td>%d</td></tr>
		<tr><td>微信每月限额：</td><td>%d</td></tr>
		</table>
		<h5>下列用户手动设置了支付渠道：</h5><br/>
		]],
		skynet.call(DATA.service_config.data_service,"lua","get_system_variant","pay_wechat_max_count_day"),
		skynet.call(DATA.service_config.data_service,"lua","get_system_variant","pay_wechat_max_once"),
		skynet.call(DATA.service_config.data_service,"lua","get_system_variant","pay_wechat_max_day"),
		skynet.call(DATA.service_config.data_service,"lua","get_system_variant","pay_wechat_max_month")
	)

	local _player_id = basefunc.string.trim_nil(data.player_id)
	local _player_cfg = skynet.call(DATA.service_config.data_service,"lua","get_player_pay_channels",_player_id)

	local _row_strs = {
		[[
			<table border="1">			
			<tr>
			<th>序号</th>
			<th>ID</th>
			<th>昵称</th>
			<th>支付方式</th>
			</tr>			
		]]
	}


	local payment_config = nodefunc.get_global_config "payment_config"

	local _idx = 0
	for _id,_data in pairs(_player_cfg) do
		_idx = _idx + 1
		local _channels = {}
		local _pinfo = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_id,"player_info")
		for _name,_v in pairs(_data._data) do
			if _v then
				table.insert(_channels,payment_config.channel_names[_name])
			end
		end
		table.insert(_row_strs,string.format([[
			<tr>
			<td>%s</td>
			<td>%s</td>
			<td>%s</td>
			<td>%s</td>
			</tr>			
		]],_idx,_id,_pinfo.name,table.concat(_channels,",")))
	end
	
	return _ret_str .. table.concat(_row_strs)
end


function CMD.admin_watch_history(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_watch_history")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _watch_name = basefunc.string.trim_nil(data.watch_name)
	if not _watch_name then
		return [[<font color="#FF0000">[失败]</font></br>请选择 监控项名称！</br>]]
	end

	local _monitor_config = wa_lib.monitor_from_watch_desc(data.watch_name)
	if not _monitor_config then
		return [[<font color="#FF0000">[失败]</font></br>内部错误：你选择的 监控项 可能已经被管理员删除！</br>]]
	end

	local _start_time,_end_time = LF.translate_time_range(data)

	local _sql = PUBLIC.format_sql("select * from system_watch where watch_name=%s and watch_time >= FROM_UNIXTIME(%s) and watch_time <= FROM_UNIXTIME(%s) order by watch_time;",
		_monitor_config.watch.name,_start_time,_end_time)
	local ret = PUBLIC.db_query(_sql)
	if( ret.errno ) then
		return [[<font color="#FF0000">[失败]</font><br/>sql error:<br/>]] .. wa_lib.html_encode(
			string.format("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
	end

	local _date_str = string.format("时间范围：%s ~ %s",basefunc.date(nil,_start_time),basefunc.date(nil,_end_time))
	local _html = string.gsub([[
		</br>
		@date_str@
		</br>
		<div id="my_chart" style="max-width: 100%; height: 500px;"></div>
	]],"@(%g-)@",_date_str)
	
	local _charts = {
		my_chart = {
			title=_watch_name,
			style="line",
			axis_name=_monitor_config.watch.axis_name,
			data = {},
		}
	}

	local _chart_data = _charts.my_chart.data

	for i,_d in ipairs(ret) do
		table.insert(_chart_data,{
			_d.watch_time,
			_d.watch_value,
		})
	end

	return {
		html = _html,
		charts = _charts,
	}
end

-- 得到参数串（会排除预约时间）
function LF.gen_params_html_string(_api,_data)
	local _api_def = wa_lib.api_from_name(_api)

	local _strs = {[[<table border="0">]]}
	for _,_param in ipairs(_api_def.params) do
		if "appoint_time" ~= _param.name then
			table.insert(_strs,string.format([[<tr><td>%s</td><td>=</td><td>%s</td></tr>]],_param.name_ch,wa_lib.format_api_param_value(_param.type,_data[_param.name])))
		end
	end
	table.insert(_strs,[[</table>]])

	return table.concat(_strs)
end

function LF.admin_get_appoint_base()

	local _appoint_data = wa_appoint.get_appoint_data_list()

	local rows = {[[<div><font color="#00FF50">[成功]</font><br/><br/>]]}
	table.insert(rows,[[<table border="1">]])
	table.insert(rows,[[
				<tr>
				<th>id</th>
				<th>操作人</th>
				<th>API名称</th>
				<th>输入参数</th>
				<th>执行时间<br/>(倒计时)</th>
				</tr>]])
	for _,v in pairs(_appoint_data) do

		local vars = basefunc.deepcopy(v)
		vars.api = wa_lib.ch_from_name(v.api)
		vars.param_str = LF.gen_params_html_string(v.api,basefunc.decode_json(v.params))
		vars.cd = basefunc.format_time_diff(v.appoint_time-os.time())
		vars.appoint_time = basefunc.date(nil,v.appoint_time)
		local s = string.gsub([[
			<tr>
			<td>@appoint_id@</td>
			<td>@appoint_user@</td>
			<td>@api@</td>
			<td>@param_str@</td>
			<td>@appoint_time@<br/>(@cd@)</td>
			</tr>]],"@(%g-)@",vars)
			
		table.insert(rows,s)
	end

	table.insert(rows,"</table></div>")

	return table.concat(rows,"\n")		
end

-- 【web 调用】查看预约中的任务
function CMD.admin_get_appoint(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_get_appoint")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	return LF.admin_get_appoint_base()
end

function CMD.admin_cancel_appoint(_data_json)

	local ok, data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return [[<font color="#FF0000">[失败]</font></br>param decode error:</br>]] .. wa_lib.html_encode(tostring(data))
	end

	local ok,err = wa_lib.user_op_verify(data.op_user,"admin_cancel_appoint")
	if not ok then
		return [[<font color="#FF0000">[失败]</font></br>verify error:</br>]] .. wa_lib.html_encode(err)
	end

	local _appoint_desc = basefunc.string.trim_nil(data.appoint_desc)
	if not _appoint_desc then
		return [[<font color="#FF0000">[失败]</font></br>请选择要取消的 预约！</br>]]
	end

	local ok2,err2 = wa_appoint.cancel_appoint_data(_appoint_desc)
	if not ok2 then
		return [[<font color="#FF0000">[失败]</font></br>]] .. tostring(err2)
	end

	local log_data = {
		op_user = data.op_user,
		launch = skynet.getenv("start"),
		api = "admin_cancel_appoint",
		params = _data_json,
		succ = 1,
		result = "ok",
	}
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_log",log_data))
	
	return LF.admin_get_appoint_base()
end

return LF
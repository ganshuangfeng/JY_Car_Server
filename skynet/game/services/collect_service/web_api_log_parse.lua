--
-- Author: lyx
-- Date: 2018/4/26
-- Time: 17:34
-- 说明：web api 日志的解析，用于显示
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

local LD = base.LocalData("web_api_log_parse",{
	
})

local LF = base.LocalFunc("web_api_log_parse")

LF.parse_funcs = LF.parse_funcs or {}


function LF.init()
	
end

-- 得到解析函数
-- 解析函数： 传入日志表行数据；传出数据数组
function LF.get_parse_func(_api_name)
	_api_name = _api_name and string.gsub(_api_name,"^/sczd/","")
	local f = _api_name and LF.parse_funcs[_api_name] -- 支持自定义解析函数
	if f then
		return f
	else
		return function(_data) 
			return LF.normal_parse_func_base(_api_name,_data)
		end
	end
end

function LF.get_succ_html_text(_succ)
	if 1 == _succ then
		return [[<font color="#00AA50">成功</font>]]
	else
		return [[<font color="#FF0000">失败</font>]]
	end
end

-- 默认解析函数
-- 参数 _data： 日志行数据
-- 返回 标题/值 数组
function LF.normal_parse_func_base(_api_name,_data)

	local _api_def = wa_lib.api_from_name(_api_name)
	
	if _data then

		if _api_def then

			local _row = {_data.op_user}
			local ok,_pdata = pcall(cjson.decode,_data.params)
			_pdata = _pdata or {}
			for _,_param in ipairs(_api_def.params) do
				table.insert(_row,tostring(_pdata[_param.name]))
			end
			table.insert(_row,LF.get_succ_html_text(_data.succ))
			table.insert(_row,_data.op_time)

			return _row
		else 
			return {_data.op_user,wa_lib.ch_from_name(_data.api),LF.get_succ_html_text(_data.succ),_data.op_time}
		end

		
	else
		if _api_def then
			local _title = {"操作人"}
			for _,_param in ipairs(_api_def.params) do
				table.insert(_title,_param.name_ch)
			end
			table.insert(_title,"结果")
			table.insert(_title,"时间")
			return _title
		else
			return {"操作人","操作类型","结果","时间"}
		end
	end
end

return LF
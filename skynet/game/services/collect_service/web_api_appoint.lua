--
-- Author: lyx
-- Date: 2018/4/26
-- Time: 17:34
-- 说明：web api 预约 调用
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

local LD = base.LocalData("web_api_appoint",{

	-- 预约的操作 appoint_id => 数据库行
	appoint_data = {},	
	appoint_desc_map = {}, -- desc => id
})

local LF = base.LocalFunc("web_api_appoint")

function LF.init()

	LF.load_appoint_data()

	skynet.timer(5,function() LF.check_appoint_task() end)
end

-- 加载预约数据
function LF.load_appoint_data()
	
	local ret,err = PUBLIC.db_query("select a.*,unix_timestamp(a.appoint_time) _appoint_time from admin_webapi_appoint a")
	if err then
		print(err)
		return
	end	

	for _,_d in ipairs(ret) do
		_d.appoint_time = _d._appoint_time -- 取时间戳
		LD.appoint_data[_d.appoint_id] = _d
		LD.appoint_desc_map[_d.desc] = _d.appoint_id
	end
end

-- 得到数组形式的预约 任务； 并按 appoint_id 排序
function LF.get_appoint_data_list()
	local ret = {}
	for _,v in pairs(LD.appoint_data) do
		table.insert(ret,v)
	end

	table.sort(ret,function(v1,v2)
		return v1.appoint_id < v2.appoint_id
	end)

	return ret
end

-- 得到 desc 串
function LF.gen_desc_string(_api,_data)
	local _api_def = wa_lib.api_from_name(_api)

	local _strs = {_api_def.name_ch}
	for _,_param in ipairs(_api_def.params) do
		table.insert(_strs,wa_lib.format_api_param_value(_param.type,_data[_param.name]))
	end

	return table.concat(_strs,"-")
end

function LF.append_appoint_data(_api,_data,_data_json)

	if not CMD[_api] then
		return false,"append_appoint_data error:not found web api '" .. tostring(_api) .. "'"
	end

	local _desc = LF.gen_desc_string(_api,_data)
	if LD.appoint_desc_map[_desc] then
		return false,"相同的预约已经存在，请先删除：" .. _desc
	end

	local _appoint_time = tonumber(basefunc.string.trim_nil(_data.appoint_time))
	if _appoint_time then
		_appoint_time = math.floor(_appoint_time/1000)
	end

	local _d = {
		appoint_id = PUBLIC.auto_inc_id("last_appoint_id"),
		appoint_user = _data.op_user,
		appoint_time = basefunc.date(nil,_appoint_time), -- 数据库格式的时间
		api = _api,
		params = _data_json,
		desc = _desc,
	}
	
	PUBLIC.db_exec(PUBLIC.gen_insert_sql("admin_webapi_appoint",_d))

	_d.appoint_time = _appoint_time -- 恢复为 时间戳
	LD.appoint_data[_d.appoint_id] = _d
	LD.appoint_desc_map[_d.desc] = _d.appoint_id

	return true
end

function LF.cancel_appoint_data(_desc)
	local _id = LD.appoint_desc_map[_desc]
	if not _id then
		return false,"预约不存在"
	end

	LD.appoint_data[_id] = nil
	LD.appoint_desc_map[_desc] = nil
	PUBLIC.db_exec_va("delete from admin_webapi_appoint where appoint_id=%s;",_id)

	return true
end

function LF.check_appoint_task()

	local _now = os.time()

	-- 收集
	local _curitems = {}
	basefunc.table.remove_array(LD.appoint_data,function(_data)
		if _now >= _data.appoint_time then
			table.insert(_curitems,_data)
			return true
		end
	end)

	-- 执行
	for i,v in ipairs(_curitems) do
		print("========= begin exec appoint ==========\n" .. basefunc.tostring(v))
		CMD[v.api](v.params,true)
		print("========= end exec appoint ==========")
	end
end


return LF
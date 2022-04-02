--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：登录服务
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

local function get_log_file_prefix()
	local _cname = skynet.getenv("launch_config")
	if not _cname then
		error("not found launch_config for log!")
	end

	local iter_func = string.gmatch(_cname,"game[\\/]launch[\\/](.+)[\\/](.+)%.lua")
	local p1,p2 = iter_func()
	if "string" ~= type(p1) or "string" ~= type(p2) then
		error("lauch file path  is error!") -- 路径格式不正确
	end

	return p1 .. "_" .. p2
end

local LD = base.LocalData("write_logfile",{

	launch = skynet.getenv("launch_config"),
	node_name = skynet.getenv("my_node_name"),

	-- 日志文件前缀
	--log_file_prefix = get_log_file_prefix(),

	--[[ 文件信息。 
		type name => {
			module name => {
				handle=,
				type=,
				module=,
				header=, -- 文件头字符串
				file_ext_name=,
				file_base_name=,
				file_name=,
				is_error=,
				last_flush_time=,
				size=, 文件尺寸
			} 
		}
	--]]
	files = {},
})

local LF = base.LocalFunc("write_logfile")

-- 写入文件内容
function LF.write_file_text(_file_info,_text)
	if _text then
		_file_info.size = _file_info.size + string.len(_text)
		_file_info.handle:write(_text)	
	end
end

-- 处理日志文件 备份
function LF.safe_backup_log_file(_file_info)

	--local _f_size = _file_info.handle:seek("end")
	local debug_file_size = (tonumber(skynet.getcfg("debug_file_size")) or 120) * 1024 * 1024
	if debug_file_size > 0 and _file_info.size >= debug_file_size then

		-- 准备备份文件夹
		local _dir = "./logs.bak/" .. _file_info.type
		basefunc.path.mkdirs(_dir)

		_file_info.handle:close()
		local _dstr = os.date("_%Y%m%d_%H%M%S")
		local _last_dindex
		if _file_info.last_dstr == _dstr then
			_file_info.last_dindex = (_file_info.last_dindex or 0) + 1
			_file_info.last_dstr = _dstr

			_last_dindex = _file_info.last_dindex
		else
			_file_info.last_dindex = nil -- 跨秒，则归零
		end

		if _last_dindex then
			_dstr = _dstr .. "." .. _last_dindex
		end
		os.rename(_file_info.file_name,_dir .. "/" .. _file_info.file_base_name .. _dstr .. _file_info.file_ext_name)

		local err
		_file_info.handle,err = io.open(_file_info.file_name,"a")
		if not _file_info.handle then
			_file_info.is_error = true
			skynet.error(string.format("open log file '%s' error:%s!",_file_info.file_name,tostring(err)))
			return 
		end
		
		_file_info.size = _file_info.handle:seek("end")
		LF.write_file_text(_file_info,_file_info.header)
	end
end

-- 生成日志文件头信息
function LF.get_log_header(_type,_module_name)

	return string.format(
[[
========================================
launch :%s
node   :%s
type   :%s
module :%s
========================================
]],	
	LD.launch,LD.node_name,
	_type,_module_name or "normal")	
end

-- 得到日志文件对象
function LF.safe_get_file_info(_type,_module_name)

	local _m = LD.files[_type] or {}
	LD.files[_type] = _m

	_module_name = _module_name or "normal"
	local _f = _m[_module_name] or {}
	_m[_module_name] = _f

	if _f.is_error then
		return nil
	end

	if _f.handle then
		-- 备份日志文件
		LF.safe_backup_log_file(_f)
	else

		_f.type=_type
		_f.module=_module_name

		local _dir = "./logs/" .. _type
		basefunc.path.mkdirs(_dir)

		-- 拆分扩展名
		local _base,_ext = basefunc.path.split_ext(_module_name,true)
		if _ext == nil or _ext == "" then
			_f.file_base_name = _module_name
			_f.file_ext_name = ".log"
		else
			_f.file_base_name = _base
			_f.file_ext_name = _ext
		end

		_f.file_name = _dir .. "/" .. _f.file_base_name .. _f.file_ext_name

		local err
		_f.handle,err = io.open(_f.file_name,"a")

		if not _f.handle then
			_f.is_error = true
			skynet.error(string.format("open log file '%s' error:%s!",_f.file_name,tostring(err)))
			return nil
		end

		_f.size = _f.handle:seek("end")
		_f.header = LF.get_log_header(_type,_module_name)
		LF.write_file_text(_f,_f.header)
	end

	return _f
end

local write_queue = basefunc.queue.new()

local function write_queue_size()
	skynet.error(">>>>> log queue size:" .. tostring(write_queue:size()) .. "<<<<<<\n")
end

local function update_write_log()

	-- 文件内容收集： handle => 数组
	local _datas = {}
	while not write_queue:empty() do
		local _d = write_queue:pop_front()
		local _f = LF.safe_get_file_info(_d.t or "print",_d.m)
		if _f then
			_datas[_f] = _datas[_f] or {}
			table.insert(_datas[_f],_d.s)
		end
	end

	-- 写入
	for _f,_s in pairs(_datas) do
		LF.write_file_text(_f,table.concat(_s,"\n"))
		LF.write_file_text(_f,"\n")
		_f.handle:flush()
	end

end

function CMD.get_queue_size()
	return write_queue:size()
end

function CMD.write(_text)
	write_queue:push_back(_text)
end

skynet.error("log service started!")
skynet.timer(0.5,update_write_log)
skynet.timer(60,write_queue_size)

-- 启动服务
base.start_service(nil,"wlog_service")

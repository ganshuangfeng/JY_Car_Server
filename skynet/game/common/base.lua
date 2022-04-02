--
-- Author: lyx
-- Date: 2018/3/22
-- Time: 15:11
-- 说明：程序开始的 基础表
-- 	具体使用举例
--[[

	local base = require "base"

	-- 保护函数
	local PROTECTED = {}

	function PROTECTED.xxxfunc()

	end

	-- 命令处理函数
	function base.CMD.xxxcmd()
		。。。
	end

	-- 公共功能函数
	function base.PUBLIC.xxxfunc()

		base.DATA.nnn = nnn -- 访问公共数据
	end


	return PROTECTED
]]

local skynet = require "skynet_plus"
local basefunc = require "basefunc"
require "skynet.manager"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

local MAX_DUMP_STRING = 10 * 1024 * 1024

local self_link = {node=skynet.getenv("my_node_name"),addr=skynet.self()}

local base = {

-- 供外部服务调用的命令
	CMD = {},

	-- 客户端的请求
	REQUEST={},

	-- 公共函数
	PUBLIC = {},

	-- 公共数据
	DATA = {},

	CUR_CMD = {},
}

local CMD=base.CMD
local DATA = base.DATA
local PUBLIC = base.PUBLIC
CUR_CMD = base.CUR_CMD

local _config_dir = skynet.getenv("game_config_dir")

-- 得到本地数据 表
function base.LocalData(_module_name,_default)
	local _name = "LD_" .. _module_name
	DATA[_name] = DATA[_name] or _default or {}
	return DATA[_name]
end

-- 得到本地函数 表
function base.LocalFunc(_module_name,_default)
	local _name = "LF_" .. _module_name
	PUBLIC[_name] = PUBLIC[_name] or _default or {}
	return PUBLIC[_name]
end

---- add by wss
--- 操作锁
DATA.action_lock = DATA.action_lock or {}
--- 打开 操作锁,   ！！！！ player_id 不传用于agent；player_id要传用于中心服务
function PUBLIC.on_action_lock( lock_name , player_id )
	if player_id then
		DATA.action_lock[lock_name] = DATA.action_lock[lock_name] or {}
		DATA.action_lock[lock_name][player_id] = true
	else
		DATA.action_lock[lock_name] = true
	end
end
--- 关闭锁
function PUBLIC.off_action_lock( lock_name , player_id )
	if player_id then
		DATA.action_lock[lock_name] = DATA.action_lock[lock_name] or {}
		DATA.action_lock[lock_name][player_id] = false
	else
		DATA.action_lock[lock_name] = false
	end
end
--- 获得锁
function PUBLIC.get_action_lock( lock_name , player_id )
	if player_id then
		return DATA.action_lock[lock_name] and DATA.action_lock[lock_name][player_id] or false
	else
		return DATA.action_lock[lock_name]
	end
end

-- 重新加载配置文件
function base.reload_config(_config_file)

	package.loaded[_config_file] = basefunc.path.reload_lua(_config_dir .. _config_file .. ".lua")

	return package.loaded[_config_file]
end

-- 重新加载文件
function base.require(_dir,_file)

	package.loaded[_file] = basefunc.path.reload_lua(_dir .. _file .. ".lua")

	return package.loaded[_file]
end

local import_files = {}

local import_update_timer

local function re_import_file(_file,_data)
	local _prev
	if type(_data) == "table" and _data.on_destroy then
		_prev = _data.on_destroy()
	end

	local _cur = basefunc.path.reload_lua(_file)
	if type(_cur) == "table" and _cur.on_load then
		_cur.on_load(_prev)
	end

	import_files[_file] = _cur
end

local function import_update(dt)
	for _file,_data in pairs(import_files) do
		re_import_file(_file,_data)
	end
end

-- 以可热更新的方式加载 lua 文件
function base.import(_file)

	local _ret = import_files[_file]
	if _ret then
		return _ret
	end

	_ret = basefunc.path.reload_lua(_file)
	import_files[_file] = _ret

	if type(_ret) == "table" and _ret.on_load then
		_ret.on_load()
	end

	-- 不启用时钟检查，改为：通过 reload_center 的 通知 更新！
	-- if not import_update_timer then
	-- 	import_update_timer = skynet.timer(5,import_update)
	-- end

	-- 注册重新载入通知
	-- by lyx 2019-1-18 ： 废弃此种热更新方式，现在 用新的方式： execfile hotfix/xxxx.lua
	-- skynet.send(base.DATA.service_config.reload_center,"lua","register_lua",self_link,_file)

	return _ret
end

function base.CMD.on_lua_changed(_name)
	re_import_file(_name,import_files[_name])
end

function base.CMD.debug_modify_data(_name,_value)
	base.DATA[_name] = _value
end
function base.CMD.debug_show_data(_name)
	return base.DATA[_name]
end


function base.CMD.get_self_link()
	return self_link
end

function base.CMD.exe_lua_base(_text,_name)
	local _err_stack

	local ok,msg = xpcall(
		function()
			local _ret = basefunc.exe_lua(_text,_name)
			if type(_ret) == "table" then
				if _ret.on_load then
					return _ret.on_load()
				end
			elseif type(_ret) == "function" then
				return _ret()
			else
				return "lua loaded!"
			end
		end,
		function(_msg)
			_err_stack = debug.traceback()
			return _msg
		end
	)

	if ok then
		return true,msg
	else
		return false,tostring(msg) .. ":\n" .. tostring(_err_stack)
	end
end

function base.CMD.exe_lua(_text,_name)

	local _,msg = base.CMD.exe_lua_base(_text,_name)

	-- 返回值 丢弃是否错误
	return msg
end

function base.CMD.exe_file(_file)

	local _text = basefunc.path.read(_file)

	return base.CMD.exe_lua(_text,_file)
end

local _dump_index = 0

-- 导出 base 中的数据
-- 可导出多层子键
function base.CMD.debug_dump(_name,...)
	if not _name then
		return "not input name!"
	end

	local _data = base[_name]
	if not _data then
		return "not found data:" .. tostring(_name)
	end

	local _dname = _name

	local _keys = {...}
	for _,v in ipairs(_keys) do
		if _data[v] then
			_data = _data[v]
			_dname = _dname .. "_" .. tostring(v)
		else
			break
		end
	end

	_dump_index = _dump_index + 1
	local _serv_name = DATA and DATA.my_id or string.format("%x",skynet.self())
	local _fname = string.format("/dump_%s_%s_%s_%d.txt",_serv_name,_dname,os.date("%Y%m%d_%H%M%S"),_dump_index)
	local _fpath = skynet.getenv("dumpath") or "./logs"

	basefunc.path.write(_fpath .. _fname,basefunc.tostring(_data,nil,nil,tonumber(skynet.getcfg("max_dump_string")) or MAX_DUMP_STRING))

	return "ok"
end

-- 统计表的内存占用
-- 返回两个值： 内存占用 + 节点数
function PUBLIC.stat_mem(_v,_map)

	if type(_v) ~= "table" then
		if type(_v) == "string" then
			return string.len(_v),1
		else
			return 8,1
		end
	end

	_map = _map or {}

	local _count = 0
	local _mem = 0

	_map[_v] = true -- 避免重复

	for k,v in pairs(_v) do

		DATA.stat_mem_counter = DATA.stat_mem_counter + 1
		if DATA.stat_mem_counter % 10000 == 0 then
			if skynet.getcfg("break_stat_mem") then
				return _mem,_count
			end
			skynet.sleep(0)
		end

		_count = _count + 1
		local _m,_c
		if not _map[k] then
			_m,_c = PUBLIC.stat_mem(k,_map)
			_mem = _mem + _m
			_count = _count + _c
		end
		if not _map[v] then
			_m,_c = PUBLIC.stat_mem(v,_map)
			_mem = _mem + _m
			_count = _count + _c
		end
	end

	return _mem,_count
end


-- 计算数据的  内存占用信息
function CMD.debug_mem_info(_name,...)

	-- 此命令 递归处理所有内存，有卡死危险，默认不开放
	if not skynet.getcfg("enable_debug_mem_info") then
		return "not enable debug_mem_info!"
	end

	if not _name then
		return "not input name!"
	end

	local _data = base[_name]
	if not _data then
		return "not found data:" .. tostring(_name)
	end

	local _dname = _name

	local _keys = {...}
	for _,v in ipairs(_keys) do
		if _data[v] then
			_data = _data[v]
			_dname = _dname .. "." .. tostring(v)
		else
			break
		end
	end

	skynet.setcfg("break_stat_mem",nil)
	DATA.stat_mem_counter = 0

	if type(_data) == "table" then

		local ret = {}
		local _m,_c = PUBLIC.stat_mem(_data)

		local _child_count = 0

		ret[1] = ""

		for k,v in pairs(_data) do
			_child_count = _child_count + 1

			local _m2,_c2 = PUBLIC.stat_mem(v)

			ret[#ret + 1] = string.format("    %30s : mem=%15s, count =%10s, value = %s",tostring(k),tostring(_m2),tostring(_c2),tostring(v))
		end

		ret[1] = string.format("%s : mem=%s,count=%s",tostring(_dname),tostring(_m),tostring(_child_count))

		return ret
	else
		return _dname .. "(" .. type(_data) .. ")" .. ":" .. tostring(PUBLIC.stat_mem(_data))
	end
end

-- 统计表的子项（不递归）
function base.CMD.debug_children_info(_name,...)
	if not _name then
		return "not input name!"
	end

	local _data = base[_name]
	if not _data then
		return "not found data:" .. tostring(_name)
	end

	local _dname = _name

	local _keys = {...}
	for _,v in ipairs(_keys) do
		if _data[v] then
			_data = _data[v]
			_dname = _dname .. "." .. tostring(v)
		else
			break
		end
	end

	if type(_data) == "table" then

		local _child_count = 0

		local ret = {}

		ret[1] = ""

		local _max_count = skynet.getcfgi("stat_children_max_count",10000)

		for k,v in pairs(_data) do

			_child_count = _child_count + 1

			if _child_count == _max_count then
				ret[#ret + 1] = "              ... more ...                 "
			elseif _child_count < _max_count then
				local _cc_count = 0
				if type(v) == "table" then
					for k2,v2 in pairs(v) do
						_cc_count = _cc_count + 1
					end
				end

				ret[#ret + 1] = string.format("    %30s : %10s, value = %s",tostring(k),tostring(_cc_count),tostring(v))
			end
		end

		ret[1] = string.format("%s : %s",tostring(_dname),tostring(_child_count))

		return ret
	else
		return _dname .. "(" .. type(_data) .. ")"
	end
end


--[[ 递归统计内存： 通过 _max_time 限制最长执行时间
     注意： 不会处理引用（判断引用 需要保存映射，在数据量大的情况下 会占用大量的额外的内存）
	参数 _contex:
		start_time 开始时间
		max_time 最长执行时间，超过则立即返回
		cur_count 上次判断时间以来的数量
		mem_size 统计出的内存
		quit 是否 停止：耗时太久
		up_table 上层表：防止无限递归
--]]
function base.calc_data_mem_r(_contex,_v)
	if _contex[_v] then
		return
	end
	if _contex.quit then
		return
	end
		
	_contex[_v] = true
	_contex.cur_count = _contex.cur_count + 1
	if _contex.cur_count >= 10000 then -- 处理 n 次，判断一次时间
		_contex.cur_count = 0
		if os.time() - _contex.start_time >= _contex.max_time then
			_contex.quit = true
		end
	end
	if type(_v) == "table" then
		_contex.mem_size = _contex.mem_size + 16
		for k2,v2 in pairs(_v) do
		
			base.calc_data_mem_r(_contex,k2)
			base.calc_data_mem_r(_contex,v2)
			
			if _contex.quit then
				return
			end
		end
	elseif type(_v) == "number" then
		_contex.mem_size = _contex.mem_size + 16
	elseif type(_v) == "string" then
		_contex.mem_size = _contex.mem_size + 16 + string.len(_v)
	elseif type(_v) == "function" then
		_contex.mem_size = _contex.mem_size + 16
	else
		_contex.mem_size = _contex.mem_size + 16
	end
	
	_contex[_v] = nil
end

-- 统计表的子项（递归）
function base.CMD.debug_children_info_r(_total_time,_max_time,_name,...)
	if not _name then
		return "not input name!"
	end

	local _data = base[_name]
	if not _data then
		return "not found data:" .. tostring(_name)
	end

	local _dname = _name

	local _keys = {...}
	for _,v in ipairs(_keys) do
		if _data[v] then
			_data = _data[v]
			_dname = _dname .. "." .. tostring(v)
		else
			break
		end
	end

	if type(_data) == "table" then

		local _child_count = 0

		local ret = {}

		ret[1] = ""

		local _max_count = skynet.getcfgi("stat_children_max_count",10000)
		
		local _time0 = os.time()

		for k,v in pairs(_data) do

			_child_count = _child_count + 1

			if _child_count == _max_count then
				ret[#ret + 1] = "              ... more ...                 "
			elseif _child_count < _max_count then
				local _cc_count = 0
				if type(v) == "table" then
					for k2,v2 in pairs(v) do
						_cc_count = _cc_count + 1
					end
				end

				local _contex={
					start_time = os.time(),
					max_time = _max_time,
					cur_count = 0,
					total_count = 0,
					mem_size = 0,
					quit = false,
					up_table={},
				}
				if os.time() - _time0 > _total_time then
					_contex.quit = "no stat"  -- 总时间超过，不统计
				else
					base.calc_data_mem_r(_contex,v)
				end
				
				ret[#ret + 1] = string.format("    %30s : %6s,%8s,%10s,%s,val=%s",tostring(k),tostring(_cc_count),tostring(_contex.total_count),tostring(_contex.mem_size),tostring(_contex.quit),tostring(v))
			end
		end

		ret[1] = string.format("%s : %s",tostring(_dname),tostring(_child_count))

		return ret
	else
		return _dname .. "(" .. type(_data) .. ")"
	end
end

function base.PUBLIC.inner_get_dump_base_data(_name,...)

	if not _name then
		return "not input name!"
	end

	local _data = base[_name]
	if not _data then
		return "not found data:" .. tostring(_name)
	end

	local _keys = {...}
	for _,v in ipairs(_keys) do
		_data = _data[v]
		if not _data then
			break
		end
	end

 	---- 干掉所有的function 类型的
	return basefunc.deepcopy(_data ,{["function"] = true})

end

----
function base.CMD.return_data_dump_str(_name,...)

	return basefunc.tostring(base.PUBLIC.inner_get_dump_base_data(_name,...) ,nil,nil,tonumber(skynet.getcfg("max_dump_string")) or MAX_DUMP_STRING )
end

function base.CMD.return_data_dump_vec(_name,...)

	return base.PUBLIC.inner_get_dump_base_data(_name,...)
end

function base.CMD.return_data_dump_json(_name,...)
	local ret = base.PUBLIC.inner_get_dump_base_data(_name,...)
	if type(ret) == "string" then
		return ret
	elseif ret then
		return cjson.encode(ret)
	else
		return "nil"
	end
end


local _last_dump_file
local _last_dump_file_i = 0

function base.CMD.dump_data()
	local _file = string.format("data_dump_%x_",skynet.self()) ..  os.date("%Y%m%d_%H%M%S")
	if _file == _last_dump_file then
		_last_dump_file_i = _last_dump_file_i + 1
		_file = _file .. "_" .. tostring(_last_dump_file_i)
	else
		_last_dump_file_i = 0
	end

	local ok,err = basefunc.path.write(_file .. ".txt",basefunc.tostring(base.DATA,nil,nil,tonumber(skynet.getcfg("max_dump_string")) or MAX_DUMP_STRING))

	if ok then
		return ok
	else
		return err
	end
end

-- 当前状态 ： 含义参见 try_stop_service 函数
base.DATA.current_service_status = "running"
base.DATA.current_service_info = nil 			-- 说明信息

--[[
尝试停止服务：在这个函数中执行关闭前的事情，比如保存数据
（这里是默认实现，服务应该根据需要实现这个函数）
参数 ：
	_count 被调用的次数，可以用来判断当前是第几次尝试
	_time 距第一次调用以来的时间
返回值：status,info
	status
		"free"		自由状态。没有缓存数据需要写入，可以关机。
		"stop"	    已停止服务，可以关机
		"runing"	正在运行，不能关机
		"wait"      正在关闭，但还未完成，需要等待；
		            如果返回此值，则会一直调用 check_service_status 直到结果不是 "wait"
	info  （可选）可以返回一段文本信息，用于说明当前状态（比如还有 n 个玩家在比赛）
 ]]
function base.PUBLIC.try_stop_service(_count,_time)
	-- 5 秒后允许关闭
	if _time < 5 then
		return "wait",string.format("after %g second stop!",5 - _time)
	else
		return "stop"
	end
end

-- 得到服务状态
function CMD.get_service_status()
	return base.DATA.current_service_status,base.DATA.current_service_info
end

-- 供调试控制台列出所有命令
function CMD.incmd()
	local ret = {}
	for _name,_ in pairs(CMD) do
		ret[#ret + 1] = _name
	end

	table.sort(ret)
	return ret
end

--[[
关闭服务
	返回执行此命令后的状态
返回值：
	参见 try_stop_service

注意： 如果 返回 "stop" 则在返回后 会立即退出（后续不要再调用此服务）
 ]]
local _last_command_running = false
function CMD.stop_service()

	-- 最近一次还正在执行，则直接返回结果
	if _last_command_running then
		return base.DATA.current_service_status,base.DATA.current_service_info
	end

	-- 停止
	base.DATA.current_service_status,base.DATA.current_service_info = base.PUBLIC.try_stop_service(1,0)

	-- 如果需要等待，则不断查询状态
	if "wait" == base.DATA.current_service_status then

		local _stop_time = skynet.now()
		local _count = 1

		_last_command_running = true
		skynet.timer(0.5,function()
			_count = _count + 1
			base.DATA.current_service_status,base.DATA.current_service_info = base.PUBLIC.try_stop_service(_count,(skynet.now()-_stop_time)*0.01)

			if "stop" == base.DATA.current_service_status then

				-- 停止服务
				skynet.call("node_service","lua","destroy_byaddr",skynet.self())
				skynet.timeout(1,function ()
					skynet.exit()
				end)

				return false

			elseif "wait" ~= base.DATA.current_service_status then

				-- 服务已不是等待状态，不需要再查询

				_last_command_running = false
				return false
			end

			_last_command_running = false
		end)
	end

	-- 停止服务
	if "stop" == base.DATA.current_service_status then
		skynet.call("node_service","lua","destroy_byaddr",skynet.self())
		skynet.timeout(1,function ()
			skynet.exit()
		end)
	end

	return base.DATA.current_service_status,base.DATA.current_service_info
end



function CMD.shutdown_service()

end


--[[ 设置热修补文件名
参数 _file_name:	热修补文件名，注意，不包括 路径和扩展名
					文件 固定放置在 hotfix 文件夹下
	使用举例：
		base.set_hotfix_file("fix_common_mj_xzdd_room_service")
--]]
function base.set_hotfix_file(_file_name)
	DATA.hot_fix_file = string.format("hotfix/%s.lua",_file_name)
	DATA.hot_fix_file_ver = 0
	DATA.hot_fix_ver_name = _file_name .. "_ver"
	DATA.hot_fix_status_name = _file_name .. "_enable"

	local _center = skynet.service_config_addr("center_service")
	skynet.call(_center,"lua","add_dyna_hotfix_file",_file_name)

	local function fix()
		if skynet.getcfg(DATA.hot_fix_status_name) then
			local _ver = tonumber(skynet.getcfg(DATA.hot_fix_ver_name))
			if _ver and _ver > DATA.hot_fix_file_ver then
				DATA.hot_fix_file_ver = _ver
				local _hotfix_ret = CMD.exe_file(DATA.hot_fix_file)
				print(string.format("hotfix file '%s' result:%s",DATA.hot_fix_file,_hotfix_ret))
			end
		end
	end

	-- 立即检测一次
	fix()

	-- 5 秒检测一次 是否需要热更行
	skynet.timer(5,fix)
end

-- 得到自己的地址
-- 说明：供外部使用者得到目标服务的真实地址，绕过可能的代理（例如 clusterproxy ）
function base.CMD.self()
	return skynet.self()
end

-- 设置 service_name ： 手动启动的服务名字，必须在 service_config 中存在
function base.CMD.set_service_name(_service_name)
	base.DATA.service_name = _service_name
end

local function cmd_get_args(...)
	if select("#") > 0 then
		return table.pack(...)
	else
		return nil
	end
end

local _service_start_stack_info

-- 默认的消息分发函数
function base.default_dispatcher(session, source, cmd, subcmd, ...)
	local f = CMD[cmd]

	CUR_CMD.session = session
	CUR_CMD.source = source
	CUR_CMD.cmd = cmd
	CUR_CMD.subcmd = subcmd
	CUR_CMD.args = cmd_get_args(...)

	if f then
		if session == 0 then
			local ok,msg = xpcall(function(...) f(subcmd, ...) end,basefunc.error_handle,...)
			if not ok then
				local _err_str = string.format("send :%08x ,session %d,from :%08x,CMD.%s(...)\n error:%s\n >>>> param:\n%s ",skynet.self(),session,source,cmd,tostring(msg),basefunc.tostring({subcmd, ...}))
				print(_err_str)
				error(_err_str)
			end
		else
			local ok,msg,sz = xpcall(function(...) return skynet.pack(f(subcmd, ...)) end,basefunc.error_handle,...)
			if ok then
				skynet.ret(msg,sz)
			else
				local _err_str = string.format("send :%08x ,session %d,from :%08x,CMD.%s(...)\n error:%s\n >>>> param:\n%s ",skynet.self(),session,source,cmd,tostring(msg),basefunc.tostring({subcmd, ...}))
				print(_err_str)
				error(_err_str)
			end
		end
	else
		local _err_str
		if _service_start_stack_info then
			_err_str = string.format("call :%08x ,session %d,from :%08x ,error: command '%s' not found.\nservice start %s",skynet.self(),session,source,cmd,_service_start_stack_info)
		else
			_err_str = string.format("call :%08x ,session %d,from :%08x ,error: command '%s' not found.",skynet.self(),session,source,cmd)
		end
		fault(_err_str)
		error(_err_str)
		-- if session ~= 0 then
		-- 	skynet.ret(skynet.pack("CALL_FAIL"))
		-- end
	end
end
local default_dispatcher = base.default_dispatcher

-- 启动服务
-- 参数:
-- 	_dispatcher    （可选） 协议分发函数
-- 	_register_name （可选） 注册服务名字
function base.start_service(_dispatcher,_register_name,_on_start)

	-- 记录栈信息，以便在找不到命令是，输出上层文件信息
	_service_start_stack_info = debug.traceback(nil,2)

	skynet.start(function()

		if type(_on_start) == "function" then
			if _on_start() then -- 返回 true 表示 自己处理完，系统不要再处理
				return
			end
		end

		skynet.dispatch("lua", _dispatcher or default_dispatcher)

		if _register_name then
			skynet.register(_register_name)
		end

	end)

end

function base.service_visitor()
	return setmetatable({}, {
		__index=function(t,k)
			return skynet.service_config_addr(k)
		end
	})
end

-- 系统层的 服务开始函数： 接管 service_config ，用于动态获取服务地址
function CMD.sys_start()

	return CMD.start(base.service_visitor())
end

-- 应用层服务（通过 node service 创建）开始函数： 接管 service_config ，用于动态获取服务地址
function CMD.app_start(_id,...)

	return CMD.start(_id,base.service_visitor(),...)
end
---- 把一个表中的key合并到 base.REQUEST ， base.CMD 中
function base.merge_key_to_base(PROTECT)
	if PROTECT.REQUEST and type(PROTECT.REQUEST) == "table" then
		basefunc.merge( PROTECT.REQUEST , base.REQUEST )
	end
	if PROTECT.CMD and type(PROTECT.CMD) == "table" then
		basefunc.merge( PROTECT.CMD , base.CMD )
	end
end
----- 从base.REQUEST ， base.CMD 中排除
function base.un_merge_key_from_base(PROTECT)
	if PROTECT.REQUEST and type(PROTECT.REQUEST) == "table" then
		for k,v in pairs(PROTECT.REQUEST) do
			base.REQUEST[k] = nil
		end
	end

	if PROTECT.CMD and type(PROTECT.CMD) == "table" then
		for k,v in pairs(PROTECT.CMD) do
			base.CMD[k] = nil
		end
	end
end

--[[ 开始 模块的 热修补逻辑
	参数 _module_name:	模块名
					文件 固定放置在 hotfix 文件夹下
	
--]]
function base.start_module_hotfix(_module_name)
	DATA.module_hotfix_data = DATA.module_hotfix_data or {}
	DATA.module_hotfix_data[_module_name] = DATA.module_hotfix_data[_module_name] or {}

	local par_data = DATA.module_hotfix_data[_module_name]

	local fix_file_name = "fix_agent_module_" .. _module_name
	par_data.hot_fix_file = string.format("hotfix/%s.lua" , fix_file_name)
	par_data.hot_fix_file_ver = 0
	par_data.hot_fix_ver_name = fix_file_name .. "_ver"
	par_data.hot_fix_status_name = fix_file_name .. "_enable"

	local _center = skynet.service_config_addr("center_service")
	skynet.call(_center,"lua","add_dyna_hotfix_file",fix_file_name)

	par_data.fix = function()
		if skynet.getcfg(par_data.hot_fix_status_name) then
			local _ver = tonumber(skynet.getcfg(par_data.hot_fix_ver_name))
			if _ver and _ver > par_data.hot_fix_file_ver then
				par_data.hot_fix_file_ver = _ver
				local _hotfix_ret = CMD.exe_file(par_data.hot_fix_file)
				print(string.format("hotfix file '%s' result:%s",par_data.hot_fix_file,_hotfix_ret))
			end
		end
	end

	-- 立即检测一次
	par_data.fix()

	if par_data.fix_timer then
		par_data.fix_timer:stop()
	end
	-- 5 秒检测一次 是否需要热更行
	par_data.fix_timer = skynet.timer(5,function() par_data.fix() end)
end

function base.stop_module_hotfix(_module_name)
	DATA.module_hotfix_data = DATA.module_hotfix_data or {}
	
	local par_data = DATA.module_hotfix_data[_module_name]
	if par_data and par_data.fix_timer then
		par_data.fix_timer:stop()
		par_data.fix_timer = nil
	end

	DATA.module_hotfix_data[_module_name] = nil
end

------ 加载一个大的agent模块
function base.load_module(_module_name)
	if not _module_name or type(_module_name) ~= "string" then
		return nil
	end
	local require_path = PLAYER_AGENT_MODULE_PATH[_module_name]
	if not require_path then
		print("----------no PLAYER_AGENT_MODULE_PATH for ",_module_name)
		return
	end

	if not package.loaded[ require_path ] then
		local req = require( require_path )
		if type(req) == "table" and req.init and type(req.init) == "function" then
			req.init()
		end

		base.start_module_hotfix(_module_name)

		--print( "xxxx--------------require__module_:" , package.loaded[ require_path ] )
		--dump(package.loaded[ require_path ] ,  string.format("xxx------------------package.loaded[ %s ]:" , require_path) )
	end

	return package.loaded[ require_path ]
end
------ 卸载一个大的agent模块
function base.un_load_module(_module_name)
	if not _module_name or type(_module_name) ~= "string" then
		return nil
	end
	local require_path = PLAYER_AGENT_MODULE_PATH[_module_name]

	if not require_path then
		print("----------no PLAYER_AGENT_MODULE_PATH for ",_module_name)
		return
	end

	if package.loaded[ require_path ] then
		local req = package.loaded[ require_path ]

		base.stop_module_hotfix(_module_name)

		if type(req) == "table" and req.un_init and type(req.un_init) == "function" then
			req.un_init()
		end

		package.loaded[ require_path ] = nil
	end
end
--------------------------------------------------------------------------- 加载子模块
----- 加载一个小的子模块
function base.load_lib(_lib_name)
	if not _lib_name or type(_lib_name) ~= "string" then
		return nil
	end
	local require_path = _lib_name

	if not package.loaded[ require_path ] then
		local req = require( require_path )
		if req.init and type(req.init) == "function" then
			req.init()
		end
		--print( "xxxx--------------require__module_:" , package.loaded[ require_path ] )
		--dump(package.loaded[ require_path ] , string.format("xxx------------------package.loaded[ %s ]:" , require_path) )
	end

	return package.loaded[ require_path ]
end

----- 卸载一个小的子模块
function base.un_load_lib(_lib_name)
	if not _lib_name or type(_lib_name) ~= "string" then
		return nil
	end
	local require_path = _lib_name

	if package.loaded[ require_path ] then
		local req = package.loaded[ require_path ]

		if req and req.un_init and type(req.un_init) == "function" then
			req.un_init()
		end

		package.loaded[ require_path ] = nil
	end
end

return base



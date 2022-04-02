--
-- Author: lyx
-- Date: 2018/3/12
-- Time: 11:21
-- 说明：对 skynet 某些功能增加的函数
--

local skynet = require "skynet"
local basefunc = require "basefunc"
local sharedata = require "skynet.sharedata"
local cluster = require "skynet.cluster"
local webclientlib = require "webclient"
local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

local md5 = require "md5.core"

--local _rand_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
-- 去掉容易混淆的字符
local _rand_chars = "6A9BD4E7FG8HJLMQNKR3TUdYabefhgijkmnqrt2uy"
local _rand_len = string.len(_rand_chars)

local _rand_num = "123456789"

local random = math.random
local max = math.max
local floor = math.floor

-- uuid 序号
local _uuid_number = 0

-- 出错时调用此函数
function skynet.fail(err)
	if skynet.getenv("debug") == "1" then
		error(tostring(err),2)
	else
		fault(debug.traceback(tostring(err),2))
	end
end


-- 保护 webclientlib.url_encoding 的参数（传入非字符串 会导致进程崩溃！！！）
webclientlib.orig_create = webclientlib.create

function webclientlib.create()
	local _wclib = webclientlib.orig_create()
	if nil == _wclib then
		return nil
	end

	local _ret = {}

	setmetatable(_ret,{__index=function(_t,_k)
		local _v

		if type(_wclib[_k]) == "function" then
			_v = function(_self,...)
				return _wclib[_k](_wclib,...) -- 注意： 这里的 _self 为 lua 表（_ret），通过这种方式，替换为真实的 _wclib 对象
			end
		else
			_v = _wclib[_k]
		end

		_t[_k] = _v

		return _v
	end})

	function _ret.url_encoding(_,_url)

		if type(_url) == "string" then
			return _wclib.url_encoding(_wclib,_url)
		elseif type(_url) == "table" then
			local _tmp = cjson.encode(_url)
			if type(_tmp) == "string" then
				return _wclib.url_encoding(_wclib,_tmp)
			else
				return _tmp
			end
		elseif nil == _url then
			return nil
		else
			local _tmp = tostring(_url)
			if type(_tmp) == "string" then
				return _wclib.url_encoding(_wclib,_tmp)
			else
				return _tmp
			end
		end
	end

	return _ret
end

-- 时钟对象
local timer = basefunc.class()
function timer:ctor(_interval,_callback,_init_call)

	self._interval = _interval * 100 -- 转换为 skynet 的时钟单位
	self._callback = _callback
	self._init_call = _init_call

	self:start()
end


function timer:start()

	local _err_count = 0

	local _last_print_err = os.time()

	local function error_handle(msg)
		_err_count = _err_count + 1

		-- n 秒打印一次错误
		if _err_count == 1 or os.time() - _last_print_err > 60 then
			print(tostring(msg) .. " => error count:" .. tostring(_err_count),debug.traceback())
			_last_print_err = os.time()
		end
	end

	if not self._running then
		self._running = true

		if self._init_call then
			local ok ,ret = xpcall(self._callback, error_handle, 0)
			if ok and false == ret then
				return
			end
		end
	
		skynet.fork(function()

			local lastDt = skynet.now()

			-- 更新函数
			while self._running do

				skynet.sleep(self._interval)
				if not self._running then
					break
				end
				
				local cur = skynet.now()
				local ok ,ret = xpcall(self._callback, error_handle, max((cur - lastDt) * 0.01,0.00001))  -- 不能是 0 ，以便和 init call 区分开

				if ok and false == ret then
					break
				end

				lastDt = cur

			end

		end)
	end
end

function timer:stop()
	self._running = false
end

function timer:set_interval(_interva1)
	self._interval = _interva1 * 100
end

-- 新建时钟： 按 _interval 时间间隔，重复调用 _callback
-- 返回一个时钟对象 timer，支持操作：
--  	timer:stop()  销毁时钟
--  	timer:set_interval()  重新设置时间间隔（秒）
-- 终止时钟（两种方式）：
--		1、调用 timer:stop()
--		2、_callback 返回 false （返回 nil 或 true 均表示继续 ）
function skynet.timer(_interval,_callback,_init_call)
	return timer.new(_interval,_callback,_init_call)
end

-- 周期定点时钟对象
local timer2 = basefunc.class()
timer2.day_ref_time = os.time({year=2020,month=1,day=1,hour=0}) -- 天的 时间参考点
timer2.week_ref_time = os.time({year=2020,month=1,day=6,hour=0}) -- 周的 时间参考点（星期一的零点）
function timer2:ctor(_ref_time,_interval,_offset,_callback,_init_call)

	_interval = max(_interval,1)

	self._ref_time = _ref_time

	self._interval = _interval
	self._offset = _offset or 0
	self._callback = _callback
	self._init_call = _init_call

	-- 检查周期 秒，1 小时及以上的 半分钟 检查一次
	if _interval >= 3600 then
		self._check_cycle = 30
	else
		self._check_cycle = 1
	end

	self._timer = nil

	-- 当前的触发周期 序号
	self.interval_index = floor((os.time()-_ref_time)/_interval)

	self:start()
end

function timer2:start()
	self._timer = skynet.timer(self._check_cycle,function(...)

		local _now = os.time()-self._ref_time
		local _index = floor(_now / self._interval)
		if _index > self.interval_index then
			if _now % self._interval >= self._offset then -- 偏移
				self.interval_index = _index
				self._callback(...)
			end
		end
	end)
end



function timer2:stop()
	if self._timer then
		self._timer:stop()
		self._timer = nil
	end
end

--[[ 
	周期定点时钟：周期性触发，但在周期的某个偏移时间点触发，比如 一天的凌晨 3 点。
	参数
		_interval  周期，单位 秒
		_offset    偏移，单位 秒
		_callback  回调函数
		_init_call 是否在启动时，立即触发一次
--]]
function skynet.timer2(_interval,_offset,_callback,_init_call)
	return timer2.new(timer2.day_ref_time,_interval,_offset,_callback,_init_call)
end

-- 时钟：按小时触发
--	_offset 偏移，单位 秒
--  _init_call 是否立即触发一次
function skynet.timer2_hour(_callback,_offset,_init_call)
	return timer2.new(timer2.day_ref_time,3600,_offset,_callback,_init_call)
end

-- 时钟：按天触发
--	_offset 偏移，单位 秒
--  _init_call 是否立即触发一次
function skynet.timer2_day(_callback,_offset,_init_call)
	return timer2.new(timer2.day_ref_time,86400,_offset,_callback,_init_call)
end

-- 时钟：按周触发
--	_offset 偏移 秒
--  _init_call 是否立即触发一次
function skynet.timer2_week(_callback,_offset,_init_call)
	return timer2.new(timer2.week_ref_time,604800,_offset,_callback,_init_call)
end

-- 得到天的序号
function skynet.get_day_index(_now,_offset)
	_offset = _offset or 0
	_now = _now or os.time()
	return math.floor((_now - timer2.day_ref_time + _offset)/86400)
end

-- 根据天的序号,得到当日的 起始点 时间
function skynet.time_of_day(_day_index,_offset)
	_offset = _offset or 0
	return timer2.day_ref_time + _offset + 86400 * _day_index
end

-- 得到给定时间 当天的 起始时间
function skynet.time_of_today(_now,_offset)
	_offset = _offset or 0
	_now = _now or os.time()
	
	return skynet.time_of_day(skynet.get_day_index(_now,_offset),_offset)
end

-- 生成一个随机数字串，不包含 0
function skynet.random_num(_len)
	if _len <= 0 then
		return ""
	end

	local _chars = {}
	for i=1,_len do
		local r = random(9)
		_chars[#_chars + 1] = string.sub(_rand_num,r,r)
	end

	return table.concat(_chars)
end

-- 生成一个随机字符串
function skynet.random_str(_len)
	if _len <= 0 then
		return ""
	end

	local _chars = {}
	for i=1,_len do
		local r = random(_rand_len)
		_chars[#_chars + 1] = string.sub(_rand_chars,r,r)
	end

	return table.concat(_chars)
end

-- 生成一个 uuid
function skynet.generate_uuid()
	_uuid_number = _uuid_number + 1
	local _str = os.time() .. "." .. skynet.self() .. "." .. _uuid_number .. "." .. math.random(100000)
	local _bdata = md5.sum(_str)
	if _rand_len < 32 then -- 如果少于 32 ，则有碰撞可能
		error("generate_uuid error:rand str too shot!")
	end
	local _ret = {}
	for i=1,string.len(_bdata) do
		local r = string.byte(_bdata,i)
		for i=0,1 do -- 依此取低位 、 高位
			local c = ((r >> (i*4)) & 0x0f) + 1
			if random(100) <= 50 then
				c = c + 16
			end
			_ret[#_ret+1] = string.sub(_rand_chars,c,c)
		end
	end

	return table.concat(_ret)
end

-- 生成加密用的 key，参数 _mix_data: 用于混合到生成的 key 中
function skynet.gen_encrypt_key(_len,_mix_data)
	local _ret = {}

	for i=1,_len do
		if _mix_data and #_mix_data > 0 then
			local _i = random(255 + #_mix_data)
			if _i > 255 then
				_ret[#_ret + 1] = string.sub(_mix_data,_i-255,_i-255)
			else
				_ret[#_ret + 1] = string.char(_i)
			end
		else
			_ret[#_ret + 1] = string.char(random(255))
		end
	end

	return table.concat(_ret)
end

local _node_share
local function ensure_node_share()
	if not _node_share then

		--local sharedata = require "skynet.sharedata"

		_node_share = sharedata.query("node_share")
		if not _node_share then
			error("sharedata 'node_share' has not created!")
		end
	end
end

-- 共享数据 是否 准备好
local _is_share_ready = false
local _share_printed_1 = false
local _share_printed_2 = false
function skynet.share_ready()
	if _is_share_ready then
		if not _share_printed_2 then
			print("share data is ready.")
			_share_printed_2 = true
		end
		return true
	end
	_is_share_ready = sharedata.exists("node_share")
	if not _is_share_ready then
		if not _share_printed_1 then
			print("share data is waiting ...")
			_share_printed_1 = true
		end
	end
	return _is_share_ready
end
-- 读取一个 sharedata 中的 配置项（用于替代 skynet.getenv）
function skynet.getcfg(_name,_default)
	if not skynet.share_ready() then
		print("skynet plus getcfg error:",_name,debug.traceback())
	end
	
	ensure_node_share()

	local _v = _node_share.node_configs[_name]
	if nil == _v then
		return _default 
	else
		return _v
	end
end
function skynet.getcfg_2number(_name,_default)
	return tonumber(skynet.getcfg(_name)) or _default
end

function skynet.getcfgi(_name,_default)
	return tonumber(skynet.getcfg(_name)) or _default
end

-- 得到共享数据
function skynet.getshare(_name)
	ensure_node_share()

	return _node_share[_name]
end

-- 设置配置项
function skynet.setcfg(_name,_value)
	skynet.call("node_service","lua","update_config",_name,_value)
end

-- 得到节点表
function skynet.get_nodes()
	ensure_node_share()
	return _node_share.nodes
end

-- 全局数据： 返回 数据 + 更新时间
-- 没有数据返回 nil
-- 参数 _copy ：是否返回副本； 如果 使用者需要赋值、改变，则需要返回副本；因为共享表结构不允许任何修改！
function skynet.get_global_data(_name,_copy)

	ensure_node_share()
	local v = _node_share.global_data[_name] 
	if v then
		if _copy then
			return basefunc.deepcopy(v.data),v.time
		else
			return v.data,v.time
		end
	else
		return nil,nil
	end
end

-- 设置全局数据
-- ★★注意★★： 不适合做高频修改；仅适合用来共享配置，或其他 偶尔需要改变的数据
function skynet.set_global_data(_name,_data)
	ensure_node_share()
	local now_ = os.time()
	for _node,_ in pairs(_node_share.nodes) do
		cluster.send(_node,"node_service","update_global_data",_name,_data,now_)
	end
end

local _is_console = (not skynet.getenv("daemon"))

skynet.orig_print = print

-- 得到系统服务地址
local _service_config_addr_emptys = {}
function skynet.service_config_addr(_name)

	if nil == _name then
		return nil
	end

	ensure_node_share()

	return _node_share.service_config[_name]

	-- local _addr = _node_share.service_config[_name]

	-- if not _addr then  -- 报错，仅报一次
	-- 	if not _service_config_addr_emptys[_name] then
	-- 		_service_config_addr_emptys[_name] = true

	-- 		local _errinfo = string.format("service is not launch:'%s',stack:\n%s",_name,debug.traceback())
	-- 		print(_errinfo)
	-- 		fault(_errinfo)
	-- 	end
	-- end

	-- return _addr
end

-- 控制台输出信息 加上 辅助信息

local _log_service
local _log_service_error = false

local _last_day = 0


local debug_file = skynet.getenv("debug_file")

local write_queue = basefunc.queue.new()


local pack = table.pack
-- 参数打包成字符串
local function pack_param(...)
	local _st = pack(...)
	for i=1,_st.n do
		_st[i] = tostring(_st[i])
	end

	return table.concat(_st,"\t")
end

-- 需要阻挡的日志： type=>module
local block_log_config = {}

function debug_write_log(_module,_type,...)

	_module = _module or "normal"

	-- 是否禁止了(_type="record" 的情况不适用通配符)
	if _type ~= "record" then
		if block_log_config == "*" or block_log_config[_type] == "*" then
			return 
		end
	end
	if block_log_config[_type] and block_log_config[_type] == _module then
		return
	end

	local _str = string.format("[:%08x] [%s] ",skynet.self(),os.date("%Y-%m-%d %H:%M:%S")) .. pack_param(...)

	if _is_console then -- 有控制台，则输入到控制台
		skynet.orig_print(_str)
	end

	if debug_file and not _log_service_error then
		
		write_queue:push_back({
			m=_module,
			t=_type,
			s=_str
		})

	end
end

local function flush_log()

	if write_queue:empty() then return end

	if not _log_service then
		_log_service = skynet.uniqueservice("write_logfile_service")
		if not _log_service then
			write_queue:clear()
			_log_service_error = true
			return false
		end
	end

	while not write_queue:empty() do
		skynet.send(_log_service,"lua","write",write_queue:pop_front())
	end
end

local function refresh_log_cfg()
	block_log_config = {}

	local _cfg = skynet.getcfg("block_log")
	if not _cfg or _cfg == "" then return end
	if _cfg == "*" then
		block_log_config = _cfg
		return
	end

	if "table" ~= type(_cfg) then
		return
	end

	for _,_d in ipairs(_cfg) do
		if _d[1] then
			block_log_config[_d[1]] = _d[2] or "*"
		end
	end
end

local _refresh_log_cfg_cd = 10
skynet.init(function()
	if debug_file then
		skynet.timer(0.5,function() 
			if not skynet.share_ready() then
				return 
			end
			_refresh_log_cfg_cd = _refresh_log_cfg_cd - 1
			if _refresh_log_cfg_cd <= 0 then
				_refresh_log_cfg_cd = 10
				refresh_log_cfg()
			end
	
			flush_log()
		end)
	end
end)

local _orig_exit = skynet.exit
function skynet.exit()
	if debug_file then
		flush_log()
	end

	_orig_exit()
end

local meta_logger = {
	__call = function(t,...)
		debug_write_log(rawget(t,"_module_"),rawget(t,"_type_"),...)
	end,
}
rawset(meta_logger,"__index",function(t,k)
	if rawget(t,k) then
		return rawget(t,k)
	else
		rawset(t,k,setmetatable({_parent_=t,_type_=rawget(t,"_type_"),_module_=k},meta_logger))
		return rawget(t,k)
	end
end)

-- 适应多种参数方式，返回正确的 nesting,modulename
local function _get_dump_nesting_modulename(t,nesting,modulename)

	-- 通过参数指定的 modulename 优先
	if type(modulename) == "string" then
		return nesting,modulename  
	end
	if type(nesting) == "string" then
		return nil,modulename  
	end

	return nesting,rawget(t,"_module_")
end

local meta_dumper = {
	__call = function(t,value, description, nesting,modulename)
		local traceback = basefunc.string.split(debug.traceback("", 2), "\n")
		nesting,modulename = _get_dump_nesting_modulename(t,nesting,modulename)
		debug_write_log(modulename,"dump",dump_str(value, description, nesting,traceback))
	end,
}
rawset(meta_dumper,"__index",function(t,k)
	if rawget(t,k) then
		return rawget(t,k)
	else
		rawset(t,k,setmetatable({_parent_=t,_type_=rawget(t,"_type_"),_module_=k},meta_dumper))
		return rawget(t,k)
	end
end)

--[[

普通用法 ：	
	print("输出信息xxxxx")    -- 普通信息
	warning("警告信息xxxxx")  -- 警告信息
	fault("错误信息xxxxx")    -- 出错信息
	dump(lua表, "标题xxxxx")  -- 打印整个lua表

指定模块：
	print.moudlename("输出信息xxxxx")   
	warning.moudlename("警告信息xxxxx")   
	fault.moudlename("错误信息xxxxx")   
	dump.moudlename(lua表, "标题xxxxx")

dump 也兼容旧的方式:
	dump(lua表, "文本xxxxxxxxx")   -- 默认
	dump(lua表, "文本xxxxxxxxx","modulename") -- 指定模块名

record_info (自定义的调试信息)
	record_info(_info_name,...)     -- 会记录在 record 文件夹，名为 _info_name 的文件


 系统可根据 日志类型(print,warning,fault,dump) 和 模块名(modulename) 打开或关闭信息

--]] 
print = setmetatable({_type_="print"},meta_logger)
warning = setmetatable({_type_="warning"},meta_logger)
fault = setmetatable({_type_="fault"},meta_logger)
dump = setmetatable({_type_="dump"},meta_dumper)


-- 记录信息到文件： 大于配置值，会自动按时间分文件
function record_info(_info_name,...)
	debug_write_log(_info_name,"record",...)
end



return skynet
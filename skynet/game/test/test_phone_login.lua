--
-- Author: lyx
-- Date: 2018/3/13
-- Time: 10:12
-- 说明：测试网关内存bug
--

package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;game/protocol/?.lua;game/common/?.lua;game/config/?.lua;./game/test/?.lua"
require "printfunc"
--math.randomseed(os.time()) 

local error_code = require "error_code"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local HEART_BEAT_TIME = 1

-- 每秒连入用户
local COUNT_PER_SECOND = 1

-- 总用户数量
local MAX_COUNT = 1

-- 连接服务器
local SERVER = "127.0.0.1:5002"

local unpack = unpack

if not unpack then
	unpack = table.unpack
end

local _std_output = io.stdout
--local _std_input = io.stdin
local _std_input = io.open("/dev/tty")

local function user_input(_prompt)

	_std_output:setvbuf("no")
	_std_output:write(_prompt or "input:")
	_std_output:flush()

	_std_input:setvbuf("line")
	local r = _std_input:read()
	print("输入结果:",r)
	return r
end

local proto = require "proto"
local sproto = require "sproto"
local basefunc = require "basefunc"
local socket = require "client.socket"

-- 创建一个类
function class()
	local cls = {}

	function cls.new(...)
		local ret = setmetatable({class=cls},{__index=cls})
		ret:ctor(...)
		return ret
	end

	return cls
end

-- sleep ，单位 秒
local function sleep(time)
	socket.usleep(time * 1000000)
end

local client_set={}

local error_fds = {}


local session = 0

host = sproto.new(proto.s2c):host "package"
request = host:attach(sproto.new(proto.c2s))

local function error_handle(msg)
	print(tostring(msg) .. ":\n" .. tostring(debug.traceback()))
	return msg
end	

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function send_package(fd,pack)


	local package = string.pack(">s2", pack)
	local ok,err = xpcall(socket.send,error_handle,fd, package)
	if not ok then
		error(string.format("socket send error,fd %d,err:%s !",fd,tostring(err)))
	end
	return true
end

local function handler(object,func)
	assert(object,"handler error:object is nil!")
	assert(func,"handler error:func is nil!")
	return function(...)
		func(object,...)
	end
end

local _login_succ_count = 0
local _sign_succ_count = 0

----------------------------------------------
-- 类定义

local client = class()

client.msg = {}

function client:ctor(_phone_number,_token)

	self.fd = nil

	self.response_call_back={}
	self.request_call_back={}
	self.timer={}
	self.len=1
	self.is_login=false	

	self.phone_number = _phone_number
	self.token = _token
end

function client:do_login()
	
	if self.token then

		print("采用 token 登录：",self.token)

		-- 登录
		local device_id="test_client_game."..math.random(10000000,9000000000)

		self:send_request("login",{
				channel_type="phone",
				login_id=self.phone_number,
				device_os="windows 10 testxxnn",
				device_id=device_id,
				channel_args = cjson.encode({
					token = self.token
				})
			},handler(self,self.on_login))
	else

		-- 请求图片验证码
		self:send_request("get_vcode_picture",
			{
				phone_number=self.phone_number
			},handler(self,self.on_get_vcode_picture))
		
	end

end

function client:on_connected()

	self:do_login()
end


function client:on_get_vcode_picture(data)

	if data.result == 0 then

		print("图片验证码：",data.pic_data)
		local vcode = user_input("输入图片验证码：")

		-- 发送短信验证码
		self:send_request("send_sms_vcode",
			{
				phone_number=self.phone_number,
				pic_vcode = vcode,
			},handler(self,self.on_send_sms_vcode))
	else
		print("获取图片验证码失败：",data.result,error_code[data.result])
	end
	
end

function client:on_send_sms_vcode(data)

	if data.result == 0 then

		print("发送短信验证码成功！")

		self:send_request("login",{
			channel_type="phone",
			login_id=self.phone_number,
			device_os="windows 10 testxxnn",
			device_id=device_id,
			channel_args = cjson.encode({
				sms_vcode = user_input("输入短信验证码：")
			})
		},handler(self,self.on_login))
	
	else
		print("发送短信验证码失败：",data.result,error_code[data.result])
	end
	
end

function client:on_login(data)

	if data.result == 0 then
		_login_succ_count = _login_succ_count + 1

		self.is_login=true

		print("登录成功：",basefunc.tostring(data))

		--self:delay_send_request("dfg_req_game_list", {},handler(self,self.on_respone_reg_game_list),2)
		
	else
		print("登录失败：",data.result,error_code[data.result])

		self.token = nil -- 清除 token 重新登录
		self.fd = nil

		print("用短信验证码重新登录！")
		self:connect()
	end


end

function client:on_respone_reg_game_list(data)

	self:delay_send_request("dfg_signup", {id = 2},handler(self,self.on_sign_result))

end

function client:on_sign_result(data)
	if data.result == 0 then
		_sign_succ_count = _sign_succ_count + 1
	else
		print("sign error id:",data.result)
	end
end

function client:connect()
	local host, port = string.match(SERVER, "([^:]+):(.*)$")
	local ok,fd = xpcall(socket.connect,error_handle,host, tonumber(port))
	if ok then
		self.fd = fd

		self:timeout(handler(self,self.on_connected))

		return true
	else
		print("connect error:",fd)
		return false
	end
end

function client:send_request(name, args,cb)

	if not self.fd then return end

	session = session + 1
	local str = request(name, args, session)
	
	self.response_call_back[session]={req=name,cb=cb,time=os.time()}

	if not send_package(self.fd, str) then
		error(string.format("send package error,fd %d,name '%s'!",self.fd,name))
	end
end

function client:delay_send_request(name, args,cb,time)
	self:timeout(self.send_request,time or 0,self,name, args,cb)
end

function client:recv_package(last)
	if not self.fd then
		return nil,last
	end

	local result
	result, last =unpack_package(last)
	if result then
		return result, last
	end
	local ok,r = xpcall(socket.recv,error_handle,self.fd)
	if not ok then
		error(string.format("socket closed:%d ,%s!",self.fd,tostring(r)))
	end

	if not r then
		return nil, last
	end
	if r == "" then
		--error(string.format("socket closed:%d !",self.fd))
		--print(string.format("socket closed:%d !",self.fd))
		self.fd = nil
		return nil,last
	end
	return unpack_package(last .. r)
end

function client.msg:dfg_permit_msg(_name,_data)
	if _data and _data.status=="jdz" then
		self:delay_send_request("dfg_jiao_dizhu", {rate=3})
	end

end

local max_update_time = 0
local last_print_htime = os.time()

local max_send_heart_time = -1

local max_response_times = {}

local function update_response_time(_name,_time,_arrive)


	local mrt = max_response_times[_name]
	if mrt then
		if _time > mrt.time then
			mrt.time = _time
			mrt.arrive = _arrive
		end
	else
		mrt = {time=_time,arrive=_arrive}
		max_response_times[_name] = mrt
	end

end


function client:update(dt)

	self:dispatch_package()

	for k,v in pairs(self.timer) do
		v.time=v.time-dt
		if v.time<=0 then
			local ok = xpcall(v.cb,error_handle,unpack(v.params))

			if not ok then
				self.fd = nil
				break
			end

			if not v.keep then
				self.timer[k]=nil
			end
		end
	end

	local now = os.time()

	if self._update_time then
		max_update_time = math.max((now - self._update_time) , max_update_time)
	end

	self._update_time = now

	if now - last_print_htime > 3 then
		--print("max update time :",max_update_time)
		last_print_htime = now
	end

	if self.is_login then

		if not self.last_send_heart_time or os.time() - self.last_send_heart_time >= HEART_BEAT_TIME then 

			if self.last_send_heart_time then
				max_send_heart_time = math.max(max_send_heart_time,os.time() - self.last_send_heart_time)
			end

			self.last_send_heart_time = os.time()
			self:delay_send_request("heartbeat", {})
		end
	end

	-- 处理未返回的超时请求
	self._check_resp_time = (self._check_resp_time or 0) + dt
	if self._check_resp_time > 5 then
		self._check_resp_time = 0

		local _now = os.time()
		for _,_data in pairs(self.response_call_back) do
			if _now - _data.time > 5 then
				update_response_time(_data.req,_now - _data.time,false)
			end
		end
	end
end

function client:timeout(cb,time,...)
	self.timer[#self.timer + 1] = {time=time or 0,cb=cb,params={...}}
end


function client:dispatch_package()
	local last = ""
	while true do
		local v
		v, last = self:recv_package(last)
		if not v then
			break
		end

		local t,name,data = host:dispatch(v)
		if t == "REQUEST" then
			if client.msg[arg1] then
				client.msg[arg1](self,name,data)
			end
		else
			assert(t == "RESPONSE")
			local r = self.response_call_back[name]
			if r then

				self.response_call_back[name] = nil

				update_response_time(r.req,os.time() - r.time,true)

				if r.cb then
					r.cb(data)
				end
			end
		end
	end
end
-----------------------------------------------

local clients = basefunc.list.new()

local _dt = 1

local _stat_cd = 5

local _exit_create = false

local _online_count = 0


local _login_succ_count_last = 0
local _sign_succ_count_last = 0

local _phone = "12788888888"
local _token -- = "JtJDkG36kKeqDEt"
local game_client = client.new(_phone,_token)

game_client:connect()

while true do

	sleep(_dt)
	-- update
	if game_client.fd then
		xpcall(client.update,error_handle,game_client,_dt)
	end

end




--
-- Author: lyx
-- Date: 2018/3/14
-- Time: 9:23
-- 说明：客户端对象，每个客户端连接（fd） 对应一个
--		注意：不缓存 session 和此对象的映射关系，客户端断开即销毁。
-- 		因为：此对象创建时 还未收到任何数据，无法知道 fd 和 用户的对应关系
--

local skynet = require "skynet_plus"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local base = require "base"
local socket = require "skynet.socket"
local sprotoloader = require "sprotoloader"
local sproto_core = require "sproto.core"
local netpack = require "skynet.netpack"

local cluster = require "skynet.cluster"
require "data_func"
require "normal_func"

local client = basefunc.class()

-- 本连接处理的请求
client.req = {}

local node_name = skynet.getenv("my_node_name")

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- 协议解包/打包
local spt_host
local spt_request

-- client 对象的 id ，在当前 gate agent 中唯一
local last_client_id = 0

function client.init()

	client.load_sproto()
	
end

-- 加载协议。
function client.load_sproto()
	-- 加载协议
	spt_host = sprotoloader.load(1):host "package"
	spt_request = spt_host:attach(sprotoloader.load(2))

end

function client:ctor()

	last_client_id = last_client_id + 1
	self.id = last_client_id

	self.gate_link =
	{
		node = node_name,
		addr = skynet.self(),
		client_id = self.id,
	}
end

-- 连接的时候调用
function client:on_connect(fd,addr)
	self.fd = fd
	self.ip = string.gsub(addr,"(:.*)","")

	self:print_log("new client.")

	-- 用于匹配发回 response 的 id
	self._last_responeId = 0

	-- 发回的 response 暂存: response id => response
	self.responses = {}

	-- 请求的名称缓存： response id => name
	self.req_names = {}

	-- 接受消息时间记录： response id => time
	self.req_time = {}

	-- 玩家 agent 的 service id
	self.player_agent_id = nil

	-- 玩家agent 连接
	self.agent_link = nil

	-- 登录 id，登录成功后有效
	self.login_id = nil

	-- 用户 id，登录成功后有效
	self.user_id = nil

	-- 消息序号
	self._request_number = 0

	-- 连接已断开
	self._dis_connected = false

	-- 已经禁止收数据
	self._forbid_request = false

	-- 消息限制计数器
	self.__limit_request_counter = 0

	-- 等待踢出
	self._wait_kick = false

	-- 通讯密码
	self.proto_key = nil


end

-- 断开的时候调用
function client:on_disconnect()

	self._dis_connected = true

	if self.agent_link then
		cluster.send(self.agent_link.node,self.agent_link.addr,"disconnected",self.gate_link)
	end

end

function client:send_package(pack)

	if string.len(pack) <= 0 then
		return
	end

	if self.fd then
		
		if self.proto_key and string.len(pack) > 0 then
			pack = sproto_core.xteaencrypt(pack,self.proto_key)
		end

		local package = string.pack(">s2", pack)
		socket.write(self.fd, package)
	end	
end

function client:print_log(_info,...)
	print(string.format("[cli-%d#%d]",self.id or 0,self.fd or 0) .. tostring(_info),...)
end

function client:gen_response_id(_req_name,_resp)

	self._last_responeId = self._last_responeId + 1
	_responeId = self._last_responeId

	self.responses[_responeId] = _resp
	self.req_names[_responeId] = _req_name
	self.req_time[_responeId] = skynet.now()

	return _responeId
end

function client:del_response_id(_response_id)
	if _response_id then
		self.responses[_response_id] = nil
		self.req_names[_response_id] = nil
		self.req_time[_response_id] = nil
	end
end

function client:check_responses()

	-- 移除过期的

	local _remove
	local _now = skynet.now()
	local _timeout_cfg = skynet.getcfgi("response_timeout",2000) -- 单位： 0.01 秒
	for k,v in pairs(self.req_time) do
		if _now - v > _timeout_cfg then
			_remove = _remove or {}
			table.insert(_remove,k)
		end
	end
	
	if _remove then
		for _,v in ipairs(_remove) do
			self:del_response_id(v)
		end
	end
end


-- 记录消息日志
-- 参数 _type ： 类型：  "request_c2s" , "request_s2c", "response_s2c"
function client:log_msg(_type,_name,_data,responeId)

	if not skynet.getcfg("network_error_debug") then
		return
	end

	local _no_log = nodefunc.get_global_config("debug_no_log")
	if _no_log and _no_log[_name] then
		return
	end

	local _t_diff = -1
	if self.req_time[responeId] then
		_t_diff = skynet.now() - self.req_time[responeId]
		if _t_diff > skynet.getcfgi("response_warning_time",300) then
			warning.response("message reponse time too long:",string.format("type=%s, msg='%s',t=%d,response id=%d:",_type,_name,_t_diff,responeId or 0) .. basefunc.tostring(_data))
		end
	end

	self:print_log(string.format("[gate msg] %s '%s' t(%d) #%d:",_type,_name,_t_diff,responeId or 0) .. basefunc.tostring(_data))
end

--[[
发送消息响应包
默认 会 清除 response id 信息（除非强制 设置 _not_del_id=true）
--]]
function client:send_response(_resp_id,_data,_not_del_id)

	local _resp = self.responses[_resp_id]
	if _resp then
		
        self:log_msg("response_s2c",tostring(self.req_names[_resp_id]),_data,_resp_id)
        if _data then
            self:send_package(_resp(_data))
        end
	end

	if not _not_del_id then
		self:del_response_id(_resp_id)
	end
end

-- 来自客户端的请求
function client:on_request(msg,sz)

	if self.proto_key and sz > 0 then
		sproto_core.xteadecrypt_c(self.proto_key,msg,sz)
	end

	local ok,type,name,args,response = xpcall(spt_host.dispatch,basefunc.error_handle,spt_host,msg,sz)
	skynet.trash(msg,sz)
	if ok then
		if type == "REQUEST" then
			local ok, result  = xpcall(client.dispatch_request,basefunc.error_handle,self,response, name,args)
			if not ok then
				self:print_log("call dispatch_request error:",result)
			end
		else
			if type ~= "RESPONSE" then
				self:print_log(string.format("error:not suport msg type '%s'! ", tostring(type)))
			end
			self:print_log("error:doesn't support request client")
		end
	end
	
end

-- 向客户端发送请求
function client:request_client(name,data)

	self:log_msg("request_s2c",name,data)
	self:send_package(spt_request(name,data))
end

-- 向客户端发送 response
function client:response_client(responeId,data)

	self:send_response(responeId,data)

end
 
-- 更新函数（1 秒）
function client:update(dt)

	if self._wait_kick then
		self:print_log("client kick.")
		skynet.send(DATA.gate,"lua","kick",self.fd)
		self._wait_kick = false
		return
	end

	-- 每 5 秒 update
	if os.time() - (self.__last_update5 or 0) >= 5 then
		self.__last_update5 = os.time()
		self:update5(dt)
	end

end

-- 更新函数（5 秒）
function client:update5(dt)

	self.__limit_request_counter = 0
	
	self:check_responses()
end

-- 登录
function client.req:login(_response_id,data)

	self:print_log("client.req:login")

	-- 此两种 方式禁止通过 网关登录
	if data.channel_type == "test" or data.channel_type == "robot" then
		self._forbid_request = true
		self._wait_kick = true

		self:print_log("login type error,invalid:",data.channel_type)
		self:send_response(_response_id,{result=1039})
		return
	end

	if data.channel_type == "youke" and skynet.getcfg("forbid_youke") then
		self._forbid_request = true
		self._wait_kick = true

		self:print_log("error:youke login is forbid!")
		self:send_response(_response_id,{result=1039})
		return
	end

	-- 发送到 login
	local result = skynet.call(DATA.service_config.login_service,"lua","client_login",data,self.gate_link,self.ip)
	if result.result ~= 0 then
		self._forbid_request = true
		self._wait_kick = true
		self:print_log(string.format("error:result id %s!",tostring(result.result)))
		self:send_response(_response_id,result)
		return
	end

	-- 在等待其他服务过程中断开，则直接返回
	if self._dis_connected then
		return
	end

	self.player_agent_id = result.player_agent_id
	self.agent_link = result.agent_link

	self.login_id = result.login_id
	self.user_id = result.user_id

	if skynet.getcfg("proto_encrypt") then

		-- 如果 socket 未断的情况下重新 login 则不重新生成 key， 因为客户端可能同步不及时
		result.proto_token = self.proto_key or skynet.gen_encrypt_key(30,self.login_id)

		-- 发送 response 信息
		self:send_response(_response_id,result)

		-- 发送完 key，则保存
		self.proto_key = result.proto_token
	else
		-- 发送 response 信息
		self:send_response(_response_id,result)
	end
end

function client.req:client_breakdown_info(_response_id,data)

	if DATA.service_config.cbug_log_service then
		skynet.send(DATA.service_config.cbug_log_service,"lua","write_bug_log",data.error,self.player_agent_id)
	else
		self:del_response_id(_response_id)
	end

end


function client.req:send_sms_vcode(_response_id,data)

	local _code,err = skynet.call(DATA.service_config.third_agent_service,"lua","send_sms_vcode",data.phone_number,data.pic_vcode)

	PUBLIC.db_exec(PUBLIC.gen_insert_sql("phone_sms_log",{
		phone_number=data.phone_number,
		sms_code = _code and tostring(_code),
		direct = "send",
		op_type = "login",
		result = tonumber(err),
	}))

	local _platform = PUBLIC.check_platform(data.platform)
	local _v_data = skynet.call(DATA.service_config.verify_service,"lua","query_player_verify_info",_platform,"phone",data.phone_number)

	local _ret = {
		result = err,
		new_user = _v_data and 0 or 1
	}


	self:send_response(_response_id,{result = err})
end

-- 得到 此设备中，可绑定当前微信 登录的用户
function client.req:get_wechat_bind_list(_response_id,data)

	local _ret = skynet.call(DATA.service_config.verify_service,"lua","get_wechat_bind_list",data)
	self:send_response(_response_id,_ret)
end

-- 中转
function client:transit(_response_id,data)

	-- 第一个消息不正确，首个消息只允许： req 中的
	if self._request_number == 1 then
		self._forbid_request = true
		self._wait_kick = true
		self:send_response(_response_id,{result = 1034})
		return
	end

	local _name = self.req_names[_response_id]

	if self.player_agent_id then

		-- gm 用户验证
		if self.user_id and _name == "gm_command" and not nodefunc.is_gm_player(self.user_id) then
			self:send_response(_response_id,{result = "错误：你不是管理员用户！"})
			return
		end

		cluster.send(self.agent_link.node,self.agent_link.addr,"request",_name,data,_response_id)
	else
		-- 还未登录
		self._forbid_request = true
		self:print_log(string.format("error:ip %s, request name '%s'. but have not logined   ! ", tostring(self.ip),_name))

		self._wait_kick = true
		self:send_response(_response_id,{result = 1035})
	end
end


-- 客户端消息分发
function client:dispatch_request(response,name,data)


	if self._forbid_request or self._dis_connected then
		return
	end

	self._request_number = self._request_number + 1

	local _resp_id = self:gen_response_id(name,response)
	self:log_msg("request_c2s",name,data,_resp_id)

	-- 客户端发送请求太频繁，则断开
	self.__limit_request_counter = (self.__limit_request_counter or 0) + 1
	if self.__limit_request_counter >= DATA.max_request_rate then
		self._forbid_request = true

		self:print_log(string.format("error:request too much , max is %d ,but %d!",DATA.max_request_rate,self.__limit_request_counter))

		self._wait_kick = true
		if response then
			self:send_response(_resp_id,{result = 1031})
		else
			self:del_response_id(_resp_id)
		end
		return
	end

	local _func = client.req[name]

	if _func then
		_func(self,_resp_id,data)
	else
		-- 转发消息
		self:transit(_resp_id,data)
	end

end

return client

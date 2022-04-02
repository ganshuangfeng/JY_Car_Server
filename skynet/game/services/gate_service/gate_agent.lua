--
-- Author: lyx
-- Date: 2018/3/13
-- Time: 17:34
-- 说明：用户 agent，多个用户共享一个
-- ###_temp 网关不能有异常。。。

local skynet = require "skynet_plus"
local basefunc = require "basefunc"
local base = require "base"
require "printfunc"

local client = require("gate_service.client")

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.gate=nil

local function refresh_config()
	DATA.max_request_rate = tonumber(skynet.getcfg("max_request_rate")) or 50 -- 每个客户端 5 秒内最大的请求数
end

local function error_handle(msg)
	print(tostring(msg) .. ":\n" .. tostring(debug.traceback()))
	return msg
end	

-- 客户端 fd 表 ： fd -> client
local fd_clients = basefunc.listmap.new()

-- 客户端 id 表： id -> client
-- 此表作用： 避免 login server 踢出同一 gate 上玩家的多次登录时混淆
local id_clients = {}

function base.CMD.connect(fd,addr)

	if skynet.getcfg("network_error_debug") then
		print(string.format("<socket fd(%d)>",fd), "connected",addr)
	end

	local c = fd_clients:at(fd)
	if c then
		
		-- 此种可能性很小：前一个断开 事件还未来。 这时 旧的 client 必须废弃，否则消息会互串

		print(string.format("error:addr %s, fd %d  connected,client: ", addr, fd),c.id)

		fd_clients:erase(fd)
		id_clients[c.id] = nil
	end

	c = client.new()
	fd_clients:push_back(fd,c)
	id_clients[c.id] = c

	c:on_connect(fd,addr)
end

-- 来自客户端的请求
function base.CMD.request(fd,msg,sz)

	local client = fd_clients:at(fd)
	if not client then
		print(string.format("error: message from fd (%d), name=%s , not connected!", fd,name,basefunc.tostring(args)))
		if sz > 0 and msg then
			skynet.trash(msg,sz)
		end
		return
	end

	client:on_request(msg,sz)
end

-- 向客户端发送请求
function base.CMD.request_client(client_id,name,data)


	if not client_id then
		print("gate_agent CMD.request_client client_id is nil :"..tostring(name))
		return
	end

	local _client = id_clients[client_id]

	if not _client then
		print(string.format("gate_agent CMD.request_client client_id '%s' is not exists ! %s",tostring(client_id),tostring(name)))
		return
	end

	_client:request_client(name,data)
end

-- 向客户端发送 response
function base.CMD.response_client(client_id,responeId,data)

	local client = id_clients[client_id]
	if client then
		if client.fd then

			client:response_client(responeId,data)
		end
	else
		print("response_client is nil:",client_id,responeId)
	end
end

function base.CMD.disconnect(fd)
	local _client = fd_clients:at(fd)
	if skynet.getcfg("network_error_debug") then
		print(string.format("<socket fd(%d)>",fd), "disconnect",_client and _client.id)
	end

	if _client then

		-- 移除映射
		fd_clients:erase(fd)
		id_clients[_client.id] = nil

		_client:on_disconnect()
	end

end

-- 踢出某个客户端
function base.CMD.kick_client(_id,_call_event)

	local client = id_clients[_id]

	if client then

		if client.fd then

			if skynet.getcfg("network_error_debug") then
				print(string.format("<socket fd(%d)>",client.fd), "kick_client",_id)
			end

			fd_clients:erase(client.fd)
			skynet.send(DATA.gate,"lua","kick",client.fd)
		end

		id_clients[_id] = nil

		if _call_event then
			client:on_disconnect()
		end
	else
		print("kick_client is nil:",_id,_call_event)
	end
end

-- 更新函数，一秒一次
local function update(dt)
	local cur = fd_clients.list:front_item()
	while cur do

		-- 用 xpcall 隔离每个 client 的异常
		local ok,err = xpcall(cur[1].update,error_handle,cur[1],dt)
		if not ok then
			print(string.format("client update error,client id:%d,err:%s",fd,err,cur[1].id,tostring(err)))
		end

		cur = cur.next
	end
end

function base.CMD.reload_sproto()
	client.load_sproto()
end

function base.CMD.broadcast_client(name,data)

	local cur = fd_clients.list:front_item()
	while cur do

		cur[1]:request_client(name,data)

		cur = cur.next
	end
	
end
function base.CMD.start(gate)

	base.set_hotfix_file("fix_gate_agent")

	DATA.gate = gate
	DATA.service_config = base.service_visitor()
	DATA.node_name = skynet.getenv "my_node_name"

	-- 执行 update
	skynet.timer(1,update)

	refresh_config()
	skynet.timer(5,refresh_config)

	client.init()
end


-- 启动服务
base.start_service()

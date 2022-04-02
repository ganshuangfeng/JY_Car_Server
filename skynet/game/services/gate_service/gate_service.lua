--
-- Author: lyx
-- Date: 2018/3/13
-- Time: 17:32
-- 说明：
--

local skynet = require "skynet_plus"
local gateserver = require "snax.gateserver"
local basefunc = require "basefunc"
local handle = require "gate_service.handle_socket"
local base = require "base"

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

---- 玩家请求客户端的消息的 最大单位时间的个数的统计,
DATA.statis_request_client_msg_max = {}

function CMD.deal_statis_request_client_msg(_player_id , data)
	--dump(data,"xx----------------------------deal_statis_request_client_msg:"..(_player_id or "NULL"))
	for mag_name , msg_data in pairs(data) do
		DATA.statis_request_client_msg_max[mag_name] = DATA.statis_request_client_msg_max[mag_name] or {}

		local now_msg_max_data = DATA.statis_request_client_msg_max[mag_name]

		if not now_msg_max_data.num or msg_data.num > now_msg_max_data.num then
			now_msg_max_data.num = msg_data.num
			now_msg_max_data.time = msg_data.time
			now_msg_max_data.player_id = _player_id
		end
	end
end

function CMD.query_statis_request_client_msg()
	return DATA.statis_request_client_msg_max
end

function CMD.kick(fd)
	gateserver.closeclient(fd)
end

function CMD.set_service_name(_service_name)
	handle.service_name = _service_name
end

function CMD.start(_service_config)

	-- 加载协议
	DATA.protoloader = skynet.uniqueservice("protoloader")
	skynet.call(DATA.protoloader,"lua","load_sproto")

	skynet.sleep(50)

	handle.start()

	return skynet.call(skynet.self(), "lua", "open" , {
		port = tonumber(skynet.getenv "gate_port"),
		maxclient = tonumber(skynet.getenv "gate_maxclient" or 5000) * 1.5 ,
		nodelay = true,
	})

end

-- 重新加载协议
function CMD.reload_sproto()
	skynet.call(DATA.protoloader,"lua","load_sproto")

	handle.broadcast_agent("reload_sproto")
end

-- 向所有的 client 发送请求
function CMD.broadcast_client(_name,_data)
	handle.broadcast_agent("broadcast_client",_name,_data)
end

function CMD.stop_service()
	return "free"
end
function CMD.get_service_status()
	return "free"
end

function handle.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(...)
end

gateserver.start(handle)
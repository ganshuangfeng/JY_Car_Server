-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:13
-- 说明：玩家代理服务

require"printfunc"
local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local mc = require "skynet.multicast.core"
local base = require "base"
require "player_agent.behavior_mgr"
local heartbeat = require "player_agent.heartbeat"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
require "normal_enum"

require "player_agent.asset_manage"
require "player_agent.multicast_mgr"
require "player_agent.email_mgr"

local task_msg_center = require "task.task_msg_center"
local task_mgr = require "player_agent.task_mgr"


local rank_agent = require "player_agent.rank_agent.rank_agent"

local variant_data_agent = require "player_agent.variant_data_agent"
local pvp_game_agent = require "player_agent.pvp_game_agent"


local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

DATA.car_base_lib = require "player_agent.car_base_lib"
DATA.car_equipment_lib = require "player_agent.car_equipment_lib"
DATA.drive_game_info_lib = require "player_agent.drive_game_info_lib"
DATA.drive_common_agent = require "player_agent.drive_common_agent"
DATA.timer_box_agent = require "player_agent.timer_box_agent"

---- 通用的限制管理器
DATA.common_permission_manager = require "permission_manager.common_permission_manager"


local my_agent_link =
{
	node = skynet.getenv("my_node_name"),
	addr = skynet.self(),
}

--排他锁
DATA.game_lock=nil
DATA.location=nil
DATA.game_id=nil

DATA.agent_update_dt = 10

-- 玩家所在 gate 的信息
DATA.gate_link = nil

-- Id
DATA.my_id = nil
-- 服务配置
DATA.service_config = nil

DATA.player_data = nil

DATA.login_msg = nil

DATA.extend_data = nil

local act_lock = nil

local return_msg={result=0}

DATA.signal_restart = basefunc.signal.new()
DATA.signal_disconnect = basefunc.signal.new()
DATA.signal_logout = basefunc.signal.new()
DATA.signal_login = basefunc.signal.new()

---- 信号消息分发器
DATA.msg_dispatcher = basefunc.dispatcher.new()

-- agent 引用表：以名字为键（也可以是其他，能唯一标识自己即可），同一名字多次引用 等同一次
local agent_reference = {}

-- 引用 agent
function PUBLIC.ref_agent(name)
	agent_reference[name] = true
end

-- 释放对 agent 的引用
function PUBLIC.free_agent(name)

	agent_reference[name] = nil

	-- 没有对象引用，则登出整个 agent
	if not next(agent_reference) then
		PUBLIC.logout()
	end
end

function PUBLIC.is_ref(name)
	return agent_reference[name]
end

-- 踢用户下线 （不用等5分钟，直接下线了）
function CMD.kick()
	print("xxxx----------agent__player_ kick 1")
	heartbeat.stop_hearbeat()

end

-- 错误报警 将用户强制下线
function CMD.error_warning()
	print(" error_warning "..DATA.my_id)
	PUBLIC.logout()
end

-- 客户端主动请求登出
function REQUEST.player_quit()
	print("xxxx----------agent__player_quit 1")
	--游戏中不能登出
	if DATA.game_lock then
		print("xxxx----------agent__player_quit 2")
		return {result=1040}
	end
	print("xxxx----------agent__player_quit 3")
	CMD.kick()

	return {result=0}
end

function PUBLIC.get_gate_link()
	return DATA.gate_link
end


-- 登出事件
function PUBLIC.logout()
	--print("xxx------ player_agent login out")
	--正在退出
	DATA.exiting=true

	-- 发送登出消息
	skynet.send( DATA.service_config.msg_notification_center_service , "lua"
								, "trigger_msg" , {name = "logout"} , DATA.my_id )

	DATA.signal_logout:trigger()

	if variant_data_agent and variant_data_agent.destroy then
		variant_data_agent.destroy()
	end

	if DATA.common_permission_manager and DATA.common_permission_manager.destroy then
		DATA.common_permission_manager.destroy()
	end


	-- 告诉 node service ，自己销毁了
	nodefunc.destroy(DATA.my_id)

	-- 登出日志
	skynet.send(DATA.service_config.data_service,"lua","player_logout",DATA.my_id)

	local ok,err = xpcall(skynet.call,basefunc.error_handle,DATA.service_config.login_service,"lua","client_outline",DATA.my_id,PUBLIC.get_gate_link(),"logout")
	if not ok then
		print("call login_service client_outline error:",DATA.my_id,err)
	end

	print("player agent exit ok:",DATA.my_id)

	skynet.timeout( 50 , function() 
		skynet.exit()
	end)
	
end


-- 记录消息日志
-- 参数 _type 类型：
--		客户端：   "request_c2s" , "request_s2c", "response_s2c"
--		webview ："request_w2s" , "request_s2w", "response_s2w"
function PUBLIC.log_agent_msg(_type,_name,_data,responeId)

	if not basefunc.chk_player_is_real(DATA.my_id)
		or not skynet.getcfg("client_message_log") then
		return
	end

	local _no_log = nodefunc.get_global_config("debug_no_log")
	if _no_log and _no_log[_name] then
		return
	end

	if responeId then
		print("[agent msg]" .. _type .. " '" .. _name .. "' #" .. tostring(responeId) .. ":" .. basefunc.tostring(_data))
	else
		print("[agent msg]" .. _type .. " '" .. _name .. "':" .. basefunc.tostring(_data))
	end
end

function PUBLIC.request_client_base(_is_real,_name,_data,...)
	if DATA.gate_link then

		PUBLIC.log_agent_msg("request_s2c",_name,_data)

		if not _is_real then
			_data.msg_time = os.time()
		end
		cluster.send(DATA.gate_link.node,DATA.gate_link.addr,"request_client",DATA.gate_link.client_id,_name,_data,...)
		return true
	else
		return false
	end
end

-- 向客户端发送 请求
function PUBLIC.request_client(_name,_data,...)
    local _is_real = basefunc.is_real_player(DATA.my_id)
    return PUBLIC.request_client_base(_is_real,_name,_data,...)
end

-- 向客户端直接发送消息
function CMD.send_client(_name,_data,...)
	PUBLIC.request_client(_name,_data,...)
end

---------------- test
local function init_msg_handle()
	local MSG = {}

	return MSG
end

--加载玩家信息
function PUBLIC.load_player_info()

	DATA.player_data = skynet.call(DATA.service_config.data_service,"lua","get_player_info",DATA.my_id)
	if not DATA.player_data then
		error("asset data is nil !!! user id :"..DATA.my_id)
	end

	PUBLIC.load_asset()

	--拿取最新的资产信息
	DATA.player_data.player_asset = PUBLIC.query_asset()
	DATA.player_data.player_prop = nil

	DATA.player_data.first_login_time = DATA.player_data.player_login_stat.first_login_time

	DATA.player_data.market_channel = skynet.call(DATA.service_config.data_service,"lua","get_player_info",DATA.my_id,"player_register","market_channel")
	DATA.player_data.register_time = basefunc.get_time_by_date( skynet.call(DATA.service_config.data_service,"lua","get_player_info",DATA.my_id,"player_register","register_time") )

	--- 托管，真人都要
	DATA.car_base_lib.init()
	DATA.car_equipment_lib.init()
	DATA.drive_game_info_lib.init()
	pvp_game_agent.init()

    -- 托管的情况
    if not basefunc.chk_player_is_real(DATA.my_id) then
    	
	else

		DATA.common_permission_manager.init( false , nil , "agent" )
		---
		variant_data_agent.init()

		
	    DATA.drive_common_agent.init()
		DATA.timer_box_agent.init()

		-- 真实玩家
		task_msg_center.init()

		rank_agent.init()

		---------------------------------------------------任务管理器初始化 , 任务需要的模块需要在前面初始化 ↑
		if skynet.getcfg("task_system_is_open") then
			task_mgr.init()
		else
			task_mgr = nil
		end

		
	end
end

-- 重登录
function CMD.restart(_my_id,_gate_link,_login_msg,_extend_data)
	if DATA.exiting then
		return {result=1064}
	end

	DATA.gate_link = _gate_link

	DATA.login_msg = _login_msg

	DATA.extend_data.ip = _extend_data.ip
	DATA.extend_data.player_level = _extend_data.player_level

	-- 开始心跳检测
	heartbeat.start_heartbeat()

	--拿取最新的资产信息
	DATA.player_data.player_asset = PUBLIC.query_asset()

	skynet.timeout(0,function() DATA.signal_restart:trigger() end)
	return {
				result=0,
				agent_link=my_agent_link,
				location = DATA.location,
				vice_location = DATA.vice_location,
				game_id = DATA.game_id,
				player_data = DATA.player_data,
			}
end

local _max_deal_request_time = 0
local max = math.max

function CMD.start(_my_id,_service_config,_gate_link,_login_msg,_extend_data)

	local _start_tm = os.clock()
	print(string.format("starting player servie : %s",_my_id))

	skynet.timer(5,function ()
		if _max_deal_request_time ~= 0 then
			-- print("max deal request time:",_max_deal_request_time)
			_max_deal_request_time = 0
		end
	end)

	DATA.service_config = _service_config
	DATA.my_id =_my_id

	DATA.gate_link = _gate_link

	DATA.login_msg = _login_msg

	DATA.extend_data = _extend_data

	PUBLIC.load_player_info()

    

	-- 开始心跳检测
	heartbeat.start_heartbeat()

	-- 登录日志
	skynet.call(DATA.service_config.data_service,"lua","player_login",_my_id,_extend_data.ip,_login_msg.device_os)

	--监听广播
	PUBLIC.init_multicast_msg()


	--信息用户首次登录处理
	if DATA.player_data.player_info.logined ~= 1 then
		skynet.call(DATA.service_config.data_service,"lua","modify_player_info",DATA.my_id,"player_info",{logined=1})
		PUBLIC.dispose_new_user()
	end

	--登录后即处理
	PUBLIC.dispose_logined()

	print(string.format("started player servie : %s,dur:%s",_my_id,tostring(os.clock()-_start_tm)))

	return {
		agent_link=my_agent_link,
		player_data=DATA.player_data,
	}
end

-- 玩家断开网关
function CMD.disconnected(_gate_link)
	--print("xxxx---------------agent disconnected 1")
	-- 判断是否当前正在使用 gate 信息，否则可能是旧的
	if DATA.gate_link and nodefunc.equal_gate_link(DATA.gate_link,_gate_link) then

		DATA.signal_disconnect:trigger()
		--print("xxxx---------------agent disconnected 2")
		DATA.gate_link = nil

		heartbeat.net_error()

		print("disconnected :",DATA.my_id,_gate_link.addr,_gate_link.client_id)

	end
end


local function dispatch_request(name ,data,responeId)

	PUBLIC.log_agent_msg("request_c2s",name ,data,responeId)

	-- 只对管理员加载，避免频繁 读取 文件
	if "gm_command" == name and not REQUEST[name] then
		base.import("./game/services/player_agent/gm_tools.lua")
	end

	local f = REQUEST[name]

	---- 如果没得请求消息，去进入配置中找一下

	if not f then
		local dynamic_module = PLAYER_AGENT_MODULE_ENTER[name]
		if dynamic_module then
			REQUEST.open_game_module({ name = dynamic_module} )
			f = REQUEST[name]
		end
	end

	if f then

		local ttt1 = skynet.now()
		--print( "xxx-------------dispatch_request 1 :" , name )
		local resp = f(data)
		local ttt2 = skynet.now()
		_max_deal_request_time = max(ttt2-ttt1,_max_deal_request_time)
		if ttt2 - ttt1 > skynet.getcfgi("message_warning_time",250) then
			warning.dispatch_request("deal message time warning,time,name,data:",ttt2 - ttt1,name,basefunc.tostring(data))
		end

		--print( "xxx-------------dispatch_request 2 :" , name )
		if responeId then
			--print( "xxx-------------dispatch_request 3 :" , name , DATA.gate_link.node , DATA.gate_link.addr )
			if DATA.gate_link then
				--print( "xxx-------------dispatch_request 4 :" , name , DATA.gate_link.node , DATA.gate_link.addr )
				PUBLIC.log_agent_msg("response_s2c",name ,resp,responeId)
				cluster.send(DATA.gate_link.node,DATA.gate_link.addr,"response_client",DATA.gate_link.client_id,responeId,resp)
			end
		end
	else
		print("error : message name invalid:" .. tostring(name))
		if responeId then
			if DATA.gate_link then
				-- 需要 response ，则回送错误消息
				PUBLIC.log_agent_msg("response_s2c",name ,{result = -1},responeId)
				cluster.send(DATA.gate_link.node,DATA.gate_link.addr,"response_client",DATA.gate_link.client_id,responeId,{result = -1})
			end
		end
	end    
end


--新用户处理
function PUBLIC.dispose_new_user()

	PUBLIC.trigger_msg( {name = "player_first_login"} )

	local start_jing_bi = 100
	local start_diamond = 3

	local _asset_data={
				{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=start_jing_bi},
				{asset_type=PLAYER_ASSET_TYPES.DIAMOND,value=start_diamond },
	}
	CMD.change_asset_multi(_asset_data,ASSET_CHANGE_TYPE.NEW_USER_LOGINED_AWARD,0)
	print("xxxxx------------------------dispose_new_user")

end

--登录后 首次处理
function PUBLIC.dispose_logined()
	PUBLIC.trigger_msg( {name = "logined"} )
	DATA.signal_login:trigger()

end


--*********************************************客户端请求 *****************************************
----
function REQUEST.set_xsyd_pos(self)
	local ret = {}

	if not self or not self.pos or type(self.pos ) ~= "number" then
		ret.result = 1001
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "set_xsyd_pos" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "set_xsyd_pos" )

	skynet.send(DATA.service_config.data_service,"lua","update_player_ext_data",DATA.my_id ,"xsyd_pos" , self.pos )

	if self.is_send_client then
		PUBLIC.request_client( "on_xsyd_pos_change" , { pos = self.pos } )
	end

	ret.result = 0
	PUBLIC.off_action_lock( "set_xsyd_pos" )
	return ret
end


function REQUEST.get_xsyd_pos(self)
	local ret = {}
	--- 操作限制
	if PUBLIC.get_action_lock( "get_xsyd_pos" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "get_xsyd_pos" )

	local ext_status = skynet.call(DATA.service_config.data_service,"lua","query_player_ext_status", DATA.my_id , "xsyd_pos" )

	ret.pos = ext_status and ext_status.status or 1

	if ret.pos == 0 then
		ret.pos = 1
	end

	ret.result = 0
	PUBLIC.off_action_lock( "get_xsyd_pos" )
	return ret
end


function REQUEST.change_clientStatus(self)
	if self.status == 1 then		-- 切换到后台
		heartbeat.net_error()
	else							-- 切换到正常
		heartbeat.heartbeat()
	end

	return {result=0}
end

--加载与获得游戏
function PUBLIC.require_game_by_type(_type)

	local path=GAME_TYPE_AGENT[_type]

	if path then
		return require(path)
	end
	return nil
end

-- 测试代码
function CMD.launch_debug_test()

	-- 加载 并初始化测试代码
	local debug_agent = require "player_agent.test.debug_agent"
	if debug_agent then
		debug_agent.init()
	end

end

function PUBLIC.update()
	if rank_agent and rank_agent.update then
		rank_agent.update(DATA.agent_update_dt)
	end
end

----- 通知客户端 ， 权限错误信息
function CMD.notify_client_permission_error_desc( _error_desc )
	PUBLIC.request_client( "on_player_permission_error" , { error_desc = _error_desc } )
end

----- 启用一个游戏模块
function REQUEST.open_game_module( self )
	local ret = {}
	--- 检查参数
	if not self or not self.name or type(self.name) ~= "string" then
		ret.result = 1001
		
		return ret
	end
	if not PLAYER_AGENT_MODULE_PATH[self.name] then
		ret.result = 1004

		return ret
	end

	base.load_module(self.name)

	ret.result = 0
	return ret
end

skynet.start(function()

	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)

			if "request" == cmd then	-- 客户端请求
				dispatch_request(subcmd,...)
			else						-- 服务器之间调用

				-- 调用 默认的消息分发函数 进行处理
				base.default_dispatcher(session, source, cmd, subcmd, ...)
			end
	end)

	skynet.timer( DATA.agent_update_dt , PUBLIC.update )

	--广播协议
	skynet.register_protocol {
		name = "multicast",
		id = skynet.PTYPE_MULTICAST,
		unpack = mc.unpack,
		dispatch = function(_channel, _source, _pack, _msg, _sz)
			local msg = skynet.unpack(_msg, _sz)

			PUBLIC.multicast_msg(_channel,msg)

			mc.close(_pack)
		end,
	}

end)


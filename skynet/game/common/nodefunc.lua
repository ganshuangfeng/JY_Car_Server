--
-- Author: lyx
-- Date: 2018/3/22
-- Time: 9:36
-- 说明：和框架结构的 node_service 相关的简化函数
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local basefunc = require "basefunc"
local my_node_name = skynet.getenv("my_node_name")
local cjson = require "cjson"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

local self_link = {node=skynet.getenv("my_node_name"),addr=skynet.self()}

local function node_call_mt(t,key)

	local v = rawget(t,key)
	if v then
		return v
	else
		v = function(...)
			return skynet.call("node_service","lua",key,...)
		end
		rawset(t,key,v)
		return v
	end
end

local nodefunc = setmetatable({},{__index = node_call_mt})

function nodefunc.call(id,func,...)

	return skynet.call("node_service","call",id,func,...)
end

function nodefunc.send(id,func,...)

	skynet.send("node_service","send",id,func,...)
end

-- 全局配置数据缓存：name => {time=,cofig=,}
local _global_cache = nil

local function start_global_cache()

	skynet.timer(5,function ()
		for _name,_data in pairs(_global_cache) do
			local _config,_time = skynet.call(DATA.service_config.reload_center,"lua","get_global_config",_name,_data.time)
			if _config then
				_data.config = _config
				_data.time = _time
			end
		end
	end)	

end

-- 全局配置读取
-- 返回值： config + 最近更新时间
function nodefunc.get_global_config(_name)

	-- 初始化
	if not _global_cache then
		_global_cache = {}
		start_global_cache()
	end

	-- 读缓存
	local _data = _global_cache[_name]
	if _data then
		return _data.config,_data.time
	end

	-- 读远程
	_data = {}
	_data.config,_data.time = skynet.call(DATA.service_config.reload_center,"lua","get_global_config",_name)
	_global_cache[_name] = _data

	return _data.config,_data.time
end

-- 配置改变通知回调。 name => {callback=>_params}
local query_config_callbacks = {}

-- 全局配置查询（支持多个）
-- 参数 callback ： 配置变化的时候通知
function nodefunc.query_global_config(_name,callback,...)

	local _data = skynet.call(DATA.service_config.reload_center,"lua","get_config",_name)

	if callback then

        basefunc.safe_keys(query_config_callbacks,nil,_name)[callback] = table.pack(...)
        
		skynet.send(DATA.service_config.reload_center,"lua","register_config",self_link,_name)

		callback(_data,...)
	end

	return _data
end

-- 释放配置 回调函数，避免无谓的调用
function nodefunc.clear_global_config_cb(_name)
	skynet.send(DATA.service_config.reload_center,"lua","unregister_config",self_link,_name)
	query_config_callbacks[_name] = nil
end

function CMD.on_config_changed(_name,_data)
	local funcs = query_config_callbacks[_name]
    for _cb,_param in pairs(funcs) do 
        local _ok,_err = xpcall(_cb,basefunc.error_handle,_data,table.unpack(_param,1,_param.n))
        if not _ok then
            print("nodefunc on_config_changed error:" .. tostring(_name) .. "," ..  tostring(_err))
        end
    end
end

-- 比较两个网关连接
function nodefunc.equal_gate_link(_gate_link1,_gate_link2)
	return _gate_link1.node == _gate_link2.node and 
		_gate_link1.addr == _gate_link2.addr and 
		_gate_link1.client_id == _gate_link2.client_id
end

-- 比较两个服务连接
function nodefunc.equal_service_link(_service_link1,_service_link2)

	return _service_link1.node == _service_link2.node and 
		_service_link1.addr == _service_link2.addr 
end

-- 向游戏管理服务注册一款游戏
function nodefunc.register_game(_name)
	if not base.DATA.service_name then
		skynet.fail("not found service_name !")
		return
	end
	
	skynet.call(base.DATA.service_config.game_manager_service,"lua","register_game",
		_name,base.DATA.service_name)
end

-- 直接向客户端发送数据
-- 参数 _gate_link ： 其中包含 节点 、服务 、 client_id
function nodefunc.send_to_client(_gate_link,_name,_data)
	cluster.send(_gate_link.node,_gate_link.addr,"request_client",_gate_link.client_id,_name,_data)
end

-- 通过 链接数据直接调用一个服务的命令
-- 参数 _cmd_link ： 其中包含 节点 、服务 、cmd 名字
function nodefunc.call_cmd(_cmd_link,...)
	if my_node_name == _cmd_link.node then
		skynet.call(_cmd_link.addr,"lua",_cmd_link.cmd,...)
	else
		cluster.call(_cmd_link.node,_cmd_link.addr,_cmd_link.cmd,...)
	end
end
function nodefunc.send_cmd(_cmd_link,...)
	if my_node_name == _cmd_link.node then
		skynet.send(_cmd_link.addr,"lua",_cmd_link.cmd,...)
	else
		cluster.send(_cmd_link.node,_cmd_link.addr,_cmd_link.cmd,...)
	end
end

function nodefunc.get_kaiguan_multi_cfg( game_type )
	local split_name = basefunc.string.split(game_type, "_")
	local data = nil
	local time = nil
	if split_name[2] == "mj" then
		data,time = nodefunc.get_global_config("mj_kaiguan_multi")
	elseif split_name[2] == "ddz" then
		--data,time = nodefunc.get_global_config("mj_kaiguan_multi")
	end
	return data , time
end

---- 获取配置开关
function nodefunc.trans_kaiguan_multi_cfg( data,cfg_type )
	local ret = {}
	ret["kaiguan"] = {}
	ret["multi"] = {}
	if data[cfg_type] then
		for key,data in pairs(data[cfg_type]) do
			if data.type == "kaiguan" then
				ret["kaiguan"][data.name] = data.value == 1
			elseif data.type == "multi" then
				ret["multi"][data.name] = data.value	
			end
		end
	end
	return ret 
end

---add by wss 可取消的timeout
function nodefunc.cancelable_timeout(ti, func)
  local function cb()
    if func then
      func()
    end
  end
  local function cancel()
    func = nil
  end
  skynet.timeout(ti, cb)
  return cancel
end

-- 访问 http 接口
-- 返回 data 或 nil + 错误信息
function nodefunc.http_call(url, get, post)
	local ok,content = skynet.call(DATA.service_config.webclient_service,"lua",
					"request", url,get,post)
	if ok then

		local status, retArgs = pcall( cjson.decode, content )
		if status then
			return retArgs
		else
			print("http call error 1:",url,basefunc.tostring({ get, post,retArgs}))
			return nil,retArgs
		end
	else
		print("http call error 2:",url,basefunc.tostring({ get, post,content}))
		return nil,content
	end

end

function nodefunc.is_gm_player(_player_id)
	if skynet.getcfg("gm_user_debug") then
		return true  -- 调试情况，所有人都是 gm
	end

	local gm_list = skynet.get_global_data("gm_user_list")
	return gm_list[_player_id] and true or false
end

-- 用户等级： 0 普通； 1 内部用户（支持 gm_command、允许改服务器地址）
function nodefunc.get_player_level(_player_id)
	if nodefunc.is_gm_player(_player_id) then
		return 1
	end

	local _usdata = skynet.get_global_data("test_user_list")
	if _usdata and _usdata[_player_id] then
		return 1
	end
	
	return 0
end

return nodefunc


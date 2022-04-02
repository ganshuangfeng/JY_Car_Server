--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：重加载中心，负责配置、代码的重加载
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

local light_config = require "reload_center.light_config"

require "printfunc"

local CMD=base.CMD
local DATA=base.DATA

local LD = base.LocalData("reload_center",{

	config_dir = skynet.getenv("game_config_dir"),

	-- 配置改变通知: service_hash_id => {name => link}
	config_notify = {},
	config_names = {}, -- name => {data=}

	-- 清理时钟
	clear_timer = nil,
})

local LF = base.LocalFunc("reload_center")


function LF.load_config_base(_name)
	local ok,_cfgdata = xpcall(basefunc.path.reload_lua,basefunc.error_handle,LD.config_dir .. _name .. ".lua")
	if ok then
		if type(_cfgdata) == "table" then
			print("load read config succ:",_name)
			return _cfgdata
		else
			print("load read config data type error:",_name,type(_cfgdata))
			return nil
		end
	else
		print("load read config version error:",_name,_cfgdata)
		return nil
	end
end


function LF.get_link_hash(_link)
	return tostring(_link.node) .. tostring(_link.addr)
end

function LF.add_notify(_notify,_service_hash_id,_link,_name)
	local _s_data = _notify[_service_hash_id] or {}
	_notify[_service_hash_id] = _s_data

	_s_data[_name] = _link
end

function LF.del_notify(_notify,_service_hash_id,_name)

	if _name then
		local _s_data = _notify[_service_hash_id]
		if _s_data then
			_s_data[_name] = nil
		end
	else
		_notify[_service_hash_id] = nil
	end

end

function LF.send_notify(_notify,_name,_cmd,...)
	for _service_hash_id,_data in pairs(_notify) do
		local _link = _data[_name]
		if _link then
			cluster.send(_link.node,_link.addr,_cmd,...)
		end
	end	
end

function CMD.register_config(_link,_name)
	LF.add_notify(LD.config_notify,LF.get_link_hash(_link),_link,_name)

end

function CMD.unregister_config(_link,_name)
	LF.del_notify(LD.config_notify,LF.get_link_hash(_link),_name)
end

-- 重加载配置
function CMD.reload_config(_name)
	
	local _data = LF.load_config_base(_name)

	if not _data then
		return false,"load config fail!"
	end

	LD.config_names[_name] = {
		data=_data
	}

	LF.send_notify(LD.config_notify,_name,"on_config_changed",_name,_data)

	return true
end

-- 修改配置文件，并 调用 reload_config
function CMD.update_config(_name,_data)

	local _cfgdata

	local chunk,err = load(_data,"update_config '" .. tostring(_name) .. "'")
	if chunk then
		local _ret = chunk()
		if type(_ret) == "table" then
			_cfgdata = _ret
		else
			return false,"config file load error,type not invalid:" .. tostring(type(_ret))
		end
	else
		return false,"config file load error:" .. tostring(err)
	end

	local ok,err = basefunc.path.update(LD.config_dir .. _name .. ".lua",_data)
	if not ok then
		return ok,err
	end

	LD.config_names[_name] = {
		data=_cfgdata
	}	

	LF.send_notify(LD.config_notify,_name,"on_config_changed",_name,_cfgdata)
	
	return true
end

function CMD.get_config(_name)

	local _d = LD.config_names[_name]
	if _d then
		return _d.data
	end

	local _data = LF.load_config_base(_name)

	if not _data then
		return nil
	end	

	LD.config_names[_name] = {

		data=_data
	}
	
	return _data
end


function CMD.test_addr_valid(_node,_addr)
    return cluster.call(_node,"node_service","addr_valid",_addr)
end

function CMD.clear_invalid_notify()

    local _clear_count = 0

    local _counter = 0
    
    if LD.config_notify then
        local _list_copy = {}
        for k,_ in pairs(LD.config_notify) do
            _list_copy[#_list_copy + 1] = k
        end

        for _,_link_hash in ipairs(_list_copy) do
            local _noti_data = LD.config_notify[_link_hash]
            if _noti_data then

                local _,_link = next(_noti_data)
                
                if not _link or not CMD.test_addr_valid(_link.node,_link.addr) then
                    LD.config_notify[_link_hash] = nil -- 不存在 ，则 清除
                    _clear_count = _clear_count + 1
                end
            end
        end
    end

    return _clear_count
    
end


function CMD.start(_service_config)

	DATA.service_config = _service_config

	LD.clear_timer = skynet.timer(60,function() CMD.clear_invalid_notify() end)

	light_config.init()
	

end

-- 启动服务
base.start_service()

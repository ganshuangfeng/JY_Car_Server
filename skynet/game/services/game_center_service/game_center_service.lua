
-- 游戏中心服务

local skynet = require "skynet_plus"
require "skynet.manager"
local base=require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local config_module = require "game_center_service.game_config_module"
require "printfunc"
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LF = base.LocalFunc("game_center_service")
local LD = base.LocalData("game_center_service",{
	manager_services = {},
})

--- 服务配置
DATA.service_config = nil
--- 运行的游戏
DATA.game_list_configs = {}

---- 获得 游戏 manager的服务名
function CMD.create_service_id(game_mode, game_id)
	return string.format("%s_game_service_%d", game_mode, game_id)
end

function LF.create_one_game_service(game_mode, game_id, cfg_data)

	if cfg_data.enable == 1 then

		local new_service_id = CMD.create_service_id(game_mode, game_id)

		local ok,state = skynet.call("node_service","lua","create", false, cfg_data.manager_path, new_service_id, cfg_data )
		if ok then
			LD.manager_services[game_mode] = LD.manager_services[game_mode] or {}
			LD.manager_services[game_mode][game_id] = {service_id = new_service_id, game_mode = game_mode, game_id = game_id}
		else
			skynet.fail(string.format("game_service lauch %s error : %s!", cfg_data.manager_path,tostring(state)))
		end

	else
		print("game_service is disable : "..game_mode..game_id)
	end

end


--获取游戏服务
function CMD.get_game_map()
	return LD.manager_services
end

--获取游戏配置清单
function CMD.get_game_config()
	return DATA.game_list_configs
end

-- 重新加载配置
function PUBLIC.reload_config( game_mode, game_id, cfg_data )

	LD.manager_services[game_mode] = LD.manager_services[game_mode] or {}

	if LD.manager_services[game_mode][game_id] then
		nodefunc.call(LD.manager_services[game_mode][game_id].service_id,"reload_config", cfg_data )
	else
		LF.create_one_game_service(game_mode, game_id, cfg_data)
	end

	return 0
end

function CMD.start(_service_config)

	DATA.service_config=_service_config

	config_module.init()
end

-- 启动服务
base.start_service()


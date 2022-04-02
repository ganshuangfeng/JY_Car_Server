
-- 读取游戏配置清单

local skynet = require "skynet_plus"
local basefunc = require "basefunc"
local base = require "base"
local nodefunc = require "nodefunc"
require "normal_enum"
require "printfunc"

local PUBLIC = base.PUBLIC
local DATA = base.DATA

local LF = base.LocalFunc("game_config_module")
local LD = base.LocalData("game_config_module",{
	refresh_config_dt = 10,
	config_last_change_time = 0,
})

function LF.refresh_config(config_name)
	local raw_configs,time = nodefunc.get_global_config(config_name) 

	---- 自动刷新，时间不一样，不刷新
	local need_refresh = false
	if LD.config_last_change_time ~= time then
		need_refresh = true
	end
	LD.config_last_change_time = time

	if not need_refresh then
		return
	end
	---- 处理配置
	for _, cfg_data in ipairs(raw_configs.game_main) do
		local game_mode = cfg_data.game_mode
		local game_id = cfg_data.game_id

		DATA.game_list_configs[game_mode] = DATA.game_list_configs[game_mode] or {}

		if not DATA.game_list_configs[game_mode][game_id] then
			DATA.game_list_configs[game_mode][game_id] = cfg_data
			PUBLIC.reload_config(game_mode, game_id, cfg_data)
		else
			if cfg_data.version ~= DATA.game_list_configs[game_mode][game_id].version then
				DATA.game_list_configs[game_mode][game_id] = cfg_data
				PUBLIC.reload_config(game_mode, game_id, cfg_data)
			end
		end
	end

	return raw_configs, time
end

--- 刷新配置
function LF.refresh_configs()
	-- print("=-------->>>>>> refresh_configs")

	local _, time = LF.refresh_config("game_server")


end

function LD.init()
	LF.refresh_configs()

	skynet.timer( LD.refresh_config_dt , LF.refresh_configs )

end

return LD
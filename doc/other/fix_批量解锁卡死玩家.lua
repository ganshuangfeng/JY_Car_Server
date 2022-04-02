--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：发公告
-- 使用方法：
-- call match_center_service exe_file "hotfix/fix_player_freestyle_game.lua"
--


local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

require "data_func"
require "normal_enum"
require "printfunc"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC



local write_file_handle = nil
function write_file_data(_str)

	write_file_handle = write_file_handle or io.open("./logs/fix_player_freestyle_game.txt","a+")

	write_file_handle:write(_str .. "\n")
	write_file_handle:flush()

end

-- local deal_player = {
-- }

return function()
	local count = 0
	
	-- 两个小时了还没打完
	local FT = os.time() - 20*60

	local deal_player = skynet.call(DATA.service_config.data_service,"lua"
											,"select_players_list",1,0,true)

	-- dump(deal_player,"ssssssssssssssd__")

	for key,player_id in pairs(deal_player) do
		local player_id = tostring(player_id)

		local game_lock = skynet.call( DATA.service_config.debug_console_service , "lua" , "get_service_debug_data" , player_id , "DATA" , "game_lock" )
		local game_id = skynet.call( DATA.service_config.debug_console_service , "lua" , "get_service_debug_data" , player_id , "DATA" , "game_id" )
		local gf = skynet.call( DATA.service_config.debug_console_service , "lua" , "get_player_debug_game_info" , player_id )

		local str = ""
		if game_lock and game_id and game_id ~= "CALL_FAIL" and type(gf) == "table" then

			local gbt = tonumber(gf.game_begin_time)
			if gbt and gbt < FT then
				str = str .. player_id .. ":" .. gbt

				if game_lock and string.sub( tostring(game_lock), 1 , 9 ) == "freestyle" then
					str = str .. " ok"

					-- 操作
					--local mid = "freestyle_service_"..game_id
					--nodefunc.call( mid , "set_player_game_status" , player_id)
					--nodefunc.call( mid , "player_exit_game" , player_id)
					--nodefunc.call( player_id , "error_warning" , player_id)

				end

				count = count + 1

				write_file_data(str)

			end

		end

	end

	write_file_data("count：" .. count)
    
    return "send ok!!! " .. count .. "\n"

end


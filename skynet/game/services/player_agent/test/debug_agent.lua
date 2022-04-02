-- friendgame_agent

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
require"printfunc"
require "normal_enum"
local nodefunc = require "nodefunc"
local base = require "base"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

local LF = base.LocalFunc("debug_agent")

local LD = base.LocalData("debug_agent",{
	-- 随机测试的 模块
	random_modules = {
		-- {	-- 捕鱼测试
		-- 	launch=function()
		-- 		LF.start_test("fish_game")
		-- 	end
		-- },
		-- {	-- 自由场测试
		-- 	launch=function()
		-- 		local _game_id = math.random(1,4) -- 斗地主的四个自由场
		-- 		LF.start_test("free_game",{
		-- 			game_id =_game_id,
		-- 			game_type = "nor_ddz_nor",
		-- 			service_id = "freestyle_service_" .. _game_id,
		-- 		})
		-- 	end
		-- },
		-- {	-- 抢红包测试
		-- 	launch=function()
		-- 		-- local _game_id = math.random(41,43)
		-- 		local _game_id = 41
		-- 		LF.start_test("qhb_game",{
		-- 			game_id = _game_id,
		-- 			game_type = "nor_qhb_nor",
		-- 			service_id = "freestyle_service_" .. _game_id,
		-- 			game_level = _game_id - 40
		-- 		})
		-- 	end
		-- },
		-- {	-- 抢红包测试
		-- 	launch=function()
		-- 		-- local _game_id = math.random(41,43)
		-- 		local _game_id = 42
		-- 		LF.start_test("qhb_game",{
		-- 			game_id = _game_id,
		-- 			game_type = "nor_qhb_nor",
		-- 			service_id = "freestyle_service_" .. _game_id,
		-- 			game_level = _game_id - 40
		-- 		})
		-- 	end
		-- },
		{	-- 抢红包测试
			launch=function()
				-- local _game_id = math.random(41,43)
				local _game_id = 43
				LF.start_test("qhb_game",{
					game_id = _game_id,
					game_type = "nor_qhb_nor",
					service_id = "freestyle_service_" .. _game_id,
					game_level = _game_id - 40
				})
			end
		},
		-- {	-- caishen_xxl
		-- 	launch=function()
		-- 		LF.start_test("caishen_xxl",{
		-- 		})
		-- 	end
		-- },
		-- {	-- zijianfang
		-- 	launch=function()
		-- 		LF.start_test("zjf_game",{
		-- 		})
		-- 	end
		-- },
	}
})


function LF.start_test(_module_name,...)
	local _module = require("player_agent.test." .. _module_name)
	if _module then
		_module.init(...)
	end
end

function LF.init()
	skynet.timeout(math.random(10,15),function ()
		local _m = basefunc.random_select(LD.random_modules)
		if _m then
			_m.launch()
		end
	end)

	-- 心跳
	skynet.timer(1,function() REQUEST.heartbeat() end)

end

return LF

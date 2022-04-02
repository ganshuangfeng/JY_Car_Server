local skynet = require "skynet"

local service_type={
	["system_service"]={
		resource=0 -- by lyx : 系统服务，不纳入资源管理
	},
	["node_test_service/node_test_service"]={	-- 服务器 多节点测试用 服务
		resource=1
	},
	["player_agent/player_agent"]={
		resource=1,
		node_name= skynet.getenv("plyer_agent_node") or "game",
	},
	["pvp_game_manager_service/pvp_game_manager_service"]={
		resource=1
	},
	["driver_room_service/driver_room_service"]={
		resource=1
	},
	["tuoguan_service/tuoguan_agent"]={
		resource=1,
		-- node_name= skynet.getenv("tuoguan_test_node") or "tg",
	},

}
return service_type
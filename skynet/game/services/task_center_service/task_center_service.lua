
local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

require "normal_enum"

require "printfunc"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

DATA.service_config = nil

DATA.task_main_config = {}

--- 玩家任务数据
DATA.player_task_data = nil

function CMD.start(_service_config)

	DATA.service_config = _service_config

	base.import("game/services/task_center_service/task_center_op_interface.lua")


	PUBLIC.init()

	--PUBLIC.load_all_player_task_data()

	--PUBLIC.refresh_config()

	--------------------------------------------------test ------------------------------------------------------

	--[[local data_manager = DATA.task_center_op_interface_protect.data_manager

	skynet.timeout( 2000 , function() 
		for i = 1, 6000000 do

			local test_data = data_manager:get_data("test_"..i)
			test_data = test_data or {}
			test_data.title = "test"
			test_data.name = "test_"..i
			data_manager:add_or_update_data("test_"..i , test_data)

			data_manager:add_data( i , { 
				id = i,
				title = "for_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
				name = "xxadfasdfasfasdf_____i:" .. i
			} )
			if i % 1000 == 0 then
				print("xxx-------------------test data_manager__i:" , i)
			end
		end

	end )--]]
	

	------------------------------------------------------test ----------------------------------------------

end

-- 启动服务
base.start_service()

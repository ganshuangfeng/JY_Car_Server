--
-- Author: yy
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：资产服务
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
local cjson = require "cjson"

local prop_reset = require "asset_service.prop_reset"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC


local function init()

	prop_reset.init()

end

local function update(dt)

end



function CMD.start(_service_config)
	DATA.service_config = _service_config

	init()

	skynet.timer(10,update)

end

-- 启动服务
base.start_service()


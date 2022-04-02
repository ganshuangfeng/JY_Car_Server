--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 标签中心
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "client.crypt"
-- crypt.hmac64_md5

local md5 = require "md5"
-- md5.hmacmd5

require "normal_enum"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local car_level_mgr = require "car_upgrade_center.car_level_mgr"
local car_star_mgr = require "car_upgrade_center.car_star_mgr"
local equipment_level_mgr = require "car_upgrade_center.equipment_level_mgr"
local equipment_star_mgr = require "car_upgrade_center.equipment_star_mgr"

require "car_upgrade_center.upgrade_interface"

local LD = base.LocalData("car_upgrade_center",{

    

})

local LF = base.LocalFunc("car_upgrade_center")


function CMD.start(_service_config)

	DATA.service_config = _service_config

    car_level_mgr.init()
    car_star_mgr.init()
    equipment_level_mgr.init()
    equipment_star_mgr.init()
end

-- 启动服务
base.start_service()
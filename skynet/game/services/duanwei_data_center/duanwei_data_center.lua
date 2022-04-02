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

require "data_func"

require "normal_enum"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- 数据库中存放的 单一值（表 system_variant ）
-- 由 init_system_variant 函数管理
DATA.system_variant = DATA.system_variant or {

    last_duanwei_period_id = 0,			-- 最近一个 段位赛序号
    current_duanwei_period_id = 0,			-- 当前段位赛序号

}

local data_manager = require "duanwei_data_center.data_manager"
local config_manager = require "duanwei_data_center.config_manager"


local LD = base.LocalData("duanwei_data_center",{

    

})

local LF = base.LocalFunc("duanwei_data_center")


function CMD.start(_service_config)

	DATA.service_config = _service_config

	-- 初始化 系统变量
	PUBLIC.init_system_variant()

    config_manager.init()
    data_manager.init()
end

-- 启动服务
base.start_service()
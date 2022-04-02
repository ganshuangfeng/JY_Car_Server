-- Author: lyx
-- Date: 2018/10/9
-- Time: 15:14
-- 说明：ai段位和战力调整 
--


local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require"printfunc"
require "tuoguan_service.tuoguan_enum"
local nodefunc = require "nodefunc"


local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC


local LD = base.LocalData("adjuest_duanwei_fight",{

	-- 预约的操作 appoint_id => 数据库行
	appoint_data = {},	
	appoint_desc_map = {}, -- desc => id
})

local LF = base.LocalFunc("adjuest_duanwei_fight")

function LF.init()
    
end


return LF
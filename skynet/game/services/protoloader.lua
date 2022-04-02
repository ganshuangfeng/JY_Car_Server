
local skynet = require "skynet_plus"
local sprotoloader = require "sprotoloader"
local sprotoparser = require "sprotoparser"

local basefunc = require "basefunc"
local base = require "base"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

function CMD.load_sproto()

	local proto = basefunc.path.reload_lua("game/protocol/proto.lua")
	
	print("load sproto c2s !!!")
	sprotoloader.save(proto.c2s, 1)
	print("load sproto s2c !!!")
	sprotoloader.save(proto.s2c, 2)

end

-- 启动服务
base.start_service()

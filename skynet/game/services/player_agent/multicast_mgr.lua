--
-- Author: lyx
-- Date: 2018/3/30
-- Time: 15:14
-- 说明：心跳 的 处理
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require "normal_enum"
require"printfunc"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST


local PROTECTED = {}


-- 广播消息
function PUBLIC.init_multicast_msg()

	if basefunc.chk_player_is_real(DATA.my_id) then
			
		--监听广播
		local ret = skynet.call(DATA.service_config.broadcast_svr,"lua","listen",
									1,DATA.my_id,skynet.self())

	end

end


-- 广播消息
function PUBLIC.multicast_msg(_channel, _msg)

	if basefunc.chk_player_is_real(DATA.my_id) then

		PUBLIC.request_client("multicast_msg",_msg)

	end

end





return PROTECTED
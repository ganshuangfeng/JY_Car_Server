--
-- Author: wss
-- Date: 2018/10/23
-- Time: 19:59
-- 说明：玩家 登录日志 的数据存储
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require "data_func"

local PROTECTED = {}

local LOCAL_FUNC = {}

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

----- 19年10月22~29号玩家登录次数的记录
DATA.player_login_log_19_22_29 = {}

function CMD.query_player_login_log_19_22_29(_player_id)
	local login_num = DATA.player_login_log_19_22_29[_player_id]
	if not login_num then
		local sql = PUBLIC.format_sql( [[ select count(*) count from player_login_log where id = %s and login_time > '2019-10-22 00:00:00' and login_time < '2019-10-29 00:00:00' limit 1; ]] , _player_id )

		login_num = 0
		local data = base.CMD.db_query(sql)
		dump(data , "xxxx------------------------login_num:")
		if data and data[1] and data[1].count then
			DATA.player_login_log_19_22_29[_player_id] = data[1].count

			login_num = data[1].count
		end
	end

	return login_num
end



function PROTECTED.init_data()

	return true
end



return PROTECTED
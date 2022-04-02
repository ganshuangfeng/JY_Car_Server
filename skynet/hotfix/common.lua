--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：测试
-- 使用方法：
--  call cpl_pceggs_service exe_file "hotfix/common.lua"
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
require "common_data_manager_lib"

local data_manager = require "cpl_common.cpl_data_manager"
local cpl_payment_stat = require "cpl_common.cpl_payment_stat"
local cpl_config_manager = require "cpl_common.cpl_config_manager"
require "cpl_common.cpl_event_handle"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

function CMD.pceggs_get_player_info(_player_id,_device_id,_keycode)

	if not _player_id and not _device_id then
		return {
			status = -1,
			message = "'player_id' and 'device_id' is empty!",
		}
	end

	if not PUBLIC.check_key_code(_keycode,_player_id or _device_id,DATA.pceggs_key) then
		return {
			status = -3,
			message = "Verification error",
			}
	end

	local _d 
	if _player_id then
		_d = CMD.query_cpl_data("id",_player_id)
	else
		_d = CMD.query_cpl_data("device_id",_device_id)
	end
	if not _d then
		return {
			status = -4,
			message = "No such user or not pceggs user",
		}
	end

	return {
		status = 0,
		player_id = _d.id,
		device_id = _d.device_id,
		player_type=_d.old_player or 0,
		ddz_round_count=_d.ddz_round_count or 0,
		win_jingbi = _d.win_jingbi or 0,
		payment = (_d.payment or 0)/100,
	}	

end

return function()

    return "完成!"
end
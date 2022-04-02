local skynet = require "skynet_plus"
local cjson = require "cjson"
require "printfunc"
local basefunc = require "basefunc"
require "normal_func"

local function main()
	if skynet.getcfg("forbid_external_order") then
		echo("{\"result\":2403}")
		return
	end
	
	
	
	local get = request.get

	if not get.player then
		echo("{\"result\":1001}")
		return		
	end

	local _pid,_errcode

	if string.len(get.player) == 11 then -- 电话号码
		local _vdata
		_vdata,_errcode = skynet.call(host.service_config.verify_service,"lua","get_player_by_login_info",get.platform,"phone",get.player)
		if not _vdata then
			echo(string.format("{\"result\":%d}",_errcode))
			return
		end
		_pid = _vdata.player_id
	else
		_pid = get.player
	end

	local _d = skynet.call(host.service_config.data_service,"lua","get_player_info",_pid,"player_info",{"name","head_image"})
	if _d then
		_d.result = 0
		_d.user_id = _pid
		echo(cjson.encode(_d))
	else
		echo("{\"result\":1004}")
	end
	
end

main()



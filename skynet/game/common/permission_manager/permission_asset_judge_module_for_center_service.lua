---- 权限的判断模块，for center_service

local base = require "base"
local basefunc = require "basefunc"
local skynet = require "skynet_plus"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC = base.PUBLIC


local C = {}

C.Fixed_Time = 0
C.buffer = {}

function C.is_use_query_asset(_asset_key , _player_id)
	local assert_last_time = os.time()
	local buffer = C.buffer

	buffer[_asset_key] = buffer[_asset_key] or {}

	if buffer[_asset_key].asset_num then
		if assert_last_time - buffer[_asset_key].time >= C.Fixed_Time then
			local asset_num = skynet.call(DATA.service_config.data_service,"lua","query_asset" , _player_id ,_asset_key)
			
			buffer[_asset_key].time = assert_last_time
			buffer[_asset_key].asset_num = asset_num
		end	
	else			
		local asset_num = skynet.call(DATA.service_config.data_service,"lua","query_asset" , _player_id ,_asset_key)
		buffer[_asset_key].time = assert_last_time
		buffer[_asset_key].asset_num = asset_num
	end

	return buffer[_asset_key] and buffer[_asset_key].asset_num or nil
end


function C.judeg_condition_asset( _asset_key , _condition_data , _player_id)
	local res = C.is_use_query_asset(_asset_key , _player_id)
	--print("xxxxxx---------------------judeg_condition_asset:" , _asset_key , _player_id , res , _condition_data.value , _condition_data.judge)
	if res then
		return basefunc.compare_value( res , _condition_data.value , _condition_data.judge )
	else
		return false
	end
end	


return C
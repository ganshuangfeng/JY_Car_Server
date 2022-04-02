---- 权限的判断模块，for agent

local base = require "base"
local basefunc = require "basefunc"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC = base.PUBLIC

local C = {}

---- 判断资产类型的
--[[
	参数：_asset_key          资产的key
		  _condition_data     判断条件
--]]
function C.judeg_condition_asset( _asset_key , _condition_data , _player_id)
	local asset_num = CMD.query_asset_by_type(_asset_key)
	return basefunc.compare_value( asset_num , _condition_data.value , _condition_data.judge )
end


return C
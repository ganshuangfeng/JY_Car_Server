--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：发公告
-- 使用方法：
-- call debug_console_service exe_file "hotfix/fix_debug_console_service.lua"
-- call debug_console_service write_services_mem_info
--
local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.mem_file_index = DATA.mem_file_index or 0

function CMD.write_services_mem_info()

	DATA.mem_file_index = DATA.mem_file_index + 1

	local mem_info = skynet.call(".launcher", "lua", "MEM")

	local _strs = {}
	for k,v in pairs(mem_info) do
		_strs[#_strs + 1] = string.format( "%s:\t%s",tostring(k),tostring(v))
	end

	local _time_str = os.date("%Y%m%d_%H%M%S")

	basefunc.path.write(string.format("./logs/mem_info_%s_%04d.log",_time_str,DATA.mem_file_index),table.concat(_strs,"\n"))

	return "file index:" .. DATA.mem_file_index
end

return function()

    return "send ok!!!"

end
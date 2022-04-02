--
-- Author: yy
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：验证相关函数库

local skynet = require "skynet_plus"
local base = require "base"
require"printfunc"
local md5 = require "md5.core"

local cjson = require "cjson"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

function PUBLIC.request_http_get(_url,_param)

	local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
						"request", _url,
						_param)

	if ok then

		local ok2, data = pcall( cjson.decode, content )
		if ok2 then
			return data
		else

			dump({data,content,_url,_param},"request_http_get decode json error:")
			return nil,1003
		end

		return ret
	else

		dump({content,_url,_param},"request_http_get request error:")
		return nil,2154
	end
end


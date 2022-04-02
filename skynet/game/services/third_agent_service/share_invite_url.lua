--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：分享 邀请链接
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"

require"printfunc"

require "normal_enum"
require "normal_func"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


-- 分享 url
local share_url = nil

local share_url_msg = {
	result = 0,
	share_url = nil,
}


function CMD.get_share_url(_userId,_market_channel ,_share_sources,_category)

	local config_shop_url = skynet.getcfg("get_share_url")

	if config_shop_url then

		local get_url,n = string.gsub(config_shop_url,"@userId@",_userId)

		local _platform = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_userId,"player_register","platform")

		_platform,_market_channel = PUBLIC.trans_invite_target(_platform,_market_channel)

		get_url = get_url .. "&platform=" .. _platform
		get_url = get_url .. "&market_channel=" .. _market_channel
		get_url = get_url .. "&share_sources=" .. tostring(PUBLIC.check_share_source(_share_sources))
		get_url = get_url .. "&category=" .. ( tostring(_category or "1") )


		local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
										"request",get_url)
		if ok then

			local xok,_ret_data = xpcall(
				function ()
					return cjson.decode(content)
				end,
			function (error)
				print("error:decode url failed.url:",content)
			end)
			if xok then
				print("get share url. resp data ,req url:",basefunc.tostring(_ret_data),get_url)
				--share_url_msg.share_url = _ret_data.url
				share_url_msg.share_url = _ret_data.data and _ret_data.data.qrcodedata and _ret_data.data.qrcodedata.url or "get url error!"
				share_url_msg.result = 0
			else
				share_url_msg.result = 2406
			end
		else
			print("error:call url failed.url:",get_url)
			share_url_msg.result = 2406
		end
	else
		share_url_msg.result = 2405
		share_url_msg.share_url = "error:server not config 'get_share_url' !"
	end

	return share_url_msg
end


-- 得到玩家的平台 和 deeplink 等数据（web 用）
function CMD.getPlayerAppScheme(_player_id)

	local _data = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register")
	if not _data then
		return nil,2251
	end

	local _plat = _data.platform or "normal"

	local _cfg = nodefunc.get_global_config("share_invite_config")

	return {
		platform = _plat,
		market_channel = _data.market_channel or "normal",
		url = _cfg.all_platform[_plat] and _cfg.all_platform[_plat].app_link or _cfg.all_platform.normal.app_link
	}
end
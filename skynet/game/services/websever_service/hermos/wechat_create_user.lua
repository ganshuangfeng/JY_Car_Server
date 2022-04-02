local skynet = require "skynet_plus"
local cjson = require "cjson"
local basefunc = require "basefunc"
require "printfunc"

local data,errcode = skynet.call(host.service_config.data_service,"lua","wechat_safecreate_user",
	request.get.platform,
	request.get.market_channel,
	request.get.weixinUnionId,
	request.get.parentUserId,
	request.get.share_sources)

if data then
	data.result=0
	echo(cjson.encode(data))
else
	echo(string.format("{\"result\":%d}",errcode))
end

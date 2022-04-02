local skynet = require "skynet_plus"
local cjson = require "cjson"
require "printfunc"
local basefunc = require "basefunc"

if skynet.getcfg("forbid_external_order") then
	
	echo("{\"result\":2403}")

else

	local get = request.get

	local order_id,errcode = skynet.call(host.service_config.pay_service,"lua","create_pay_order",
		get.user_id,get.channel_type,"web",tonumber(get.goods_id),get.convert,get.channel_account_id)

	if order_id then

		local order_data,errcode = skynet.call(host.service_config.pay_service,"lua","query_pay_order",order_id)
		if order_data then
			local _ret_data = {
				result=0,
				order_id=order_data.order_id,
				channel_account_id=order_data.channel_account_id
			}
			echo(cjson.encode(_ret_data))
		else
			echo(string.format("{\"result\":%d}",errcode))
		end
	else
		echo(string.format("{\"result\":%d}",tostring(errcode)))
	end
end


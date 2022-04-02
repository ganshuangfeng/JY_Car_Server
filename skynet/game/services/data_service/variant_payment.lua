--
-- Author: lyx
-- Date: 2019/12/6
-- Time: 19:59
-- 说明：累计充值计算
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require "common_data_manager_lib"

local CMD = base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local LD = base.LocalData("variant_pay_sum",{

	-- 不计入 sum 的商品
	no_sum_product_ids = {},

	config_time = 0,
	

})

local LF = base.LocalFunc("variant_pay_sum")

function LF.init()

	----  向新消息通知中心注册
	skynet.timeout(20,function()
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", 
			"add_msg_listener" , "on_pay_success"
			,{
				msg_tag = "tag_variant_pay_sum",
				node = skynet.getenv("my_node_name"),
				addr = skynet.self(),
				cmd = "player_pay_msg"
			}
		)
	end)


end

function LF.can_sum_goods(_produce_id)
	local _cfg,_time = nodefunc.get_global_config("new_vip_server")
	if _time ~= LD.config_time then
		LD.config_time = _time
		LD.no_sum_product_ids = {}
		if _cfg.not_add_vip_progress_lb_id then
			for _,v in ipairs(_cfg.not_add_vip_progress_lb_id) do
				LD.no_sum_product_ids[ v.lb_id ] = true
			end
		end
	end

	return not LD.no_sum_product_ids[_produce_id]
end

function CMD.player_pay_msg(_player_id,_produce_id,_money,_channel_type)
	print("xxx-variant_payment---------player_pay_msg:",_player_id,_produce_id,_money,_channel_type)
	if LF.can_sum_goods(_produce_id) then
		local _v = (CMD.get_orig_variant(_player_id,"pay_sum") or 0) + _money
		CMD.set_orig_variant(_player_id,"pay_sum",_v)

		local _max = math.max(CMD.get_orig_variant(_player_id,"max_pay") or 0, _money)
		CMD.set_orig_variant(_player_id,"max_pay",_max)
	end
	
end

return LF












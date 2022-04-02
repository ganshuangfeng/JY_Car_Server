--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：商城购物 和 
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
require"printfunc"

require "normal_enum"

local monitor_lib = require "monitor_lib"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

local PROTECTED = {}

DATA.shop_info_data = DATA.shop_info_data or 
{
	broadcast_data = {},

	-- 订单表
	shop_orders = {},

	--[[
	-- 玩家在商城的 token ： token -> 数据
	-- 数据结构说明：
		token = {user_id=,create_time=,}
	--]]
	shop_token = {},

	user_token_map = {}, -- user id => token 数组

	-- 进行广播
	ignore_shop_info_broadcast_content = 
	{
		["0.3元微信红包"] = true,
	}

}
local LL = DATA.shop_info_data

function PUBLIC.shop_order_json_filed(_order,_name)
	if type(_order[_name]) == "string" then

		if string.len(_order[_name]) > 0 then
			local ok,data = pcall(cjson.decode,_order[_name])
			if ok then
				_order[_name] = data
			else
				_order[_name] = nil
			end
		else
			_order[_name] = nil
		end
	end
end

function PROTECTED.init()

	local sql = "select order_id,player_id,order_status,amount,props_json,goods_id,authflags_json from player_shop_order"
	local ret = base.DATA.db_mysql:query(sql)	
	if( ret.errno ) then
		skynet.fail(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
		return false
	end

	for i = 1,#ret do

		-- json 解码
		PUBLIC.shop_order_json_filed(ret[i],"authflags_json")
		PUBLIC.shop_order_json_filed(ret[i],"props_json")

        LL.shop_orders[ret[i].order_id] = ret[i]
	end

end


function PUBLIC.shop_info_broadcast_msg(_user_name,_desc,_order_id)

	local content = string.gsub(_desc,"_%d$","")

	-- if string.find(_desc,"红包") then
	-- 	content = string.gsub(_desc,"_%d$","")
	-- else
	-- 	content = string.gsub(_desc,"_"," ") .. "件"
	-- end

	if LL.ignore_shop_info_broadcast_content[content] then
		return
	end

	LL.broadcast_data[_order_id] = {
		time = os.time() + 10,
		func = function ()
			skynet.send(base.DATA.service_config.broadcast_center_service,"lua",
							"fixed_broadcast","user_shoping_gold_pay",_user_name,content)
		end
	}

	skynet.timeout(1000,function ()
		
		local d = LL.broadcast_data[_order_id]

		if d then
			d.func()
			LL.broadcast_data[_order_id] = nil
		end

	end)

end



-- 创建 token
-- 返回值：
--		1、token，出错则为 nil
--		2、如果出错，则为错误号
function CMD.create_shop_token(_userId)

	if not _userId then
		return nil,2251
	end

	if skynet.getcfg("forbid_shoping") then
		return nil,2403
	end

	local user_name = CMD.get_player_info(_userId,"player_info","name")
	if not user_name then
		return nil,2251
	end

	local _token_map = LL.user_token_map[_userId]
	local _now = os.time()

	-- 清除过期的 token
	if type(_token_map) == "table" then

		local token_timeout = tonumber(skynet.getcfg("shop_token_timeout")) or 180

		local _last_timeout
		for i,v in ipairs(_token_map) do
			local user_info = LL.shop_token[v]
			if not user_info or (_now-user_info.create_time) > token_timeout then
				_last_timeout = i
				LL.shop_token[v] = nil
			else
				break -- 没过期（后面的 更不可能过期）
			end
		end

		-- 有过期的，则把没过期的  搬到新的里面
		if _last_timeout then

			local _new_map = {}
			for i=_last_timeout+1,#_token_map do
				_new_map[#_new_map + 1] = _token_map[i]
			end

			_token_map = _new_map
			LL.user_token_map[_userId] = _new_map
		end
	else
		_token_map = {}
		LL.user_token_map[_userId] = _token_map
	end

	local token = skynet.random_str(30)

	_token_map[#_token_map + 1] = token

	LL.shop_token[token] = {user_id=_userId,name=user_name,create_time=_now }

	print("create_shop_token,userId,token:",_userId,token)
	return token
end


-- 得到 玩家 gwj 道具：各种面额的集合
-- 注意：面额 为字符串，否则 转为 json 会报错
-- local function get_shop_golds(_userId)

-- 	local ret = {}

-- 	for _type,_face in pairs(SHOP_GOLD_FACEVALUES) do
-- 		ret[tostring(_face)] = CMD.get_prop(_userId,_type)
-- 	end


-- 	return ret
-- end

-- 根据 userid 得到用户 购物相关的信息
-- 返回值：
--		1、用户信息表，出错则为 nil
--		2、如果出错，则为错误号
function CMD.get_shop_info_by_id(_userId)

	if not _userId then
		return nil,2251
	end

	local user = base.PUBLIC.load_player_info(_userId)
	if not user then
		return nil,2251
	end

	if not user.player_info then
		return nil,1010
	end


	local user_name = CMD.get_player_info(_userId,"player_info","name")
	if not user_name then
		return nil,2251
	end

	local ret = {
		user_id=_userId,
		nickname=user.player_info.name,
		-- shop_golds=get_shop_golds(_userId),
		--shop_golds={["1"]=user.player_asset.shop_gold_sum},

		assets = {}, -- 其他财富, name => value

		status=user.player_info.is_block == 1 and "disable" or  "enable"
	}

	local _wsc = nodefunc.get_global_config("webapi_shop_config")
	for _,v in ipairs(_wsc.api_assets) do
		ret.assets[v] = CMD.query_asset(_userId,v) or 0
	end

	return ret

end

-- 根据 token 得到用户 购物相关的信息
-- 返回值：
--		1、用户信息表，出错则为 nil
--		2、如果出错，则为错误号
function CMD.get_shop_info_by_token(_token)

	if not _token then
		return nil,2252
	end

	local user_info = LL.shop_token[_token]

	if not user_info then
		return nil,2252
	end

	local token_timeout = tonumber(skynet.getcfg("shop_token_timeout")) or 180

	if os.time() - user_info.create_time > token_timeout then
		LL.shop_token[_token] = nil
		return nil,2252
	end

	return CMD.get_shop_info_by_id(user_info.user_id)
end

-- 用户通过 gwj 买东西（仅 web 调用）

function CMD.shoping_gold_pay(_data)

	local arg,_err = basefunc.parse_post_data(_data)
	if not arg then
		print("shoping_gold_pay param error:",basefunc.tostring(_data),_err)
		return nil,1001
	end

	return CMD.user_shoping_gold_pay(
		arg.user_id,
		arg.amount,
		arg.order_id,
		arg.shoping_desc,
		arg.goods_id,
		arg.authflags,
		arg.actual_amount)
end

-- 检查是否属于3元礼包（特殊处理）
function PUBLIC.check_shop_3_yuan_gift(_authflags)

	if type(_authflags) == "table" then
		if basefunc.table.array_find( _authflags, function(v) return v == "web_gift_bag_3_yuan" end )  then
			return true
		else
			return false
		end
	end

	return false
end

-- 用户通过 gwj 买东西
-- 参数 _amount： 多个资产， key => value
-- 参数 _actual_amount ： 商品的实际价值，只做记录，用于 web 端统计数据
-- 返回值：
--		1、true/false 是否成功
--		2、如果出错，则为错误号
function CMD.user_shoping_gold_pay(_userId,_amount,_order_id,_shoping_desc,_goods_id,_authflags,_actual_amount)

	if not _userId then
		return nil,2251
	end

	if not _order_id then
		return nil,2254
	end
	
	if LL.shop_orders[_order_id] then
		return nil,2254
	end

	local user = base.PUBLIC.load_player_info(_userId)
	if not user then
		return nil,2159
	end	

	local _amounts2 = {}
	local _asset_change = {} -- 扣除的
	for k,v in pairs(_amount) do

		_amounts2[k] = math.floor(tonumber(v) + 0.5)
		if not _amounts2[k] then
			return nil,1001
		end

		if CMD.query_asset(_userId,k) < _amounts2[k] then
			return nil,2253
		end

		table.insert(_asset_change,{
			asset_type = k,
			value = -_amounts2[k],
		})
	end
	
	LL.shop_orders[_order_id] = 
	{
		player_id=_userId,
		order_status="complete",
		amount=_amounts2.shop_gold_sum or 0,
		goods_id = math.floor(tonumber(_goods_id) + 0.5),
		authflags = _authflags,
		props_json = _amounts2,
	}

	local ok,err = xpcall(function()

		if _shoping_desc and type(_shoping_desc)== "string" then
			PUBLIC.shop_info_broadcast_msg(user.player_info.name,_shoping_desc,_order_id)
		end
		
		-- 3元礼包特殊处理
		if PUBLIC.check_shop_3_yuan_gift(_authflags) then
			local _count = (CMD.get_orig_variant(_userId,"gift_bag_3_yuan") or 0) + 1
			CMD.set_orig_variant(_userId,"gift_bag_3_yuan",_count,true) -- 不触发变化通知
		end
	
		if _amounts2.shop_gold_sum then
			CMD.add_consume_statistics(_userId,"cost_shop_gold",-_amounts2.shop_gold_sum)
			CMD.add_asset_stat(_userId,"shoping",-_amounts2.shop_gold_sum)
		end
	
		CMD.multi_change_asset_and_sendMsg(_userId,_asset_change,ASSET_CHANGE_TYPE.SHOPING,_order_id)
		
		-- 延迟发奖，避免对退款订单发奖
		skynet.timeout(100 * skynet.getcfgi("shoping_timeout",30),function()

			local _tmp_ord = LL.shop_orders[_order_id]
			if _tmp_ord and _tmp_ord.order_status ~= "refund" then
	
				----- 触发一个 兑换商品的消息
				skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "trigger_msg" ,
													{name = "shoping_in_web_store" , send_filter = { player_id = _userId } } 
													, _userId , math.floor(tonumber(_goods_id) + 0.5) )
			end

		end)

		-- 记录日志
		base.DATA.sql_queue_slow:push_back(PUBLIC.format_sql(
			[[insert into player_shop_order(order_id,player_id,props_json,amount,shoping_desc,goods_id,authflags_json,actual_amount) 
			values(%s,%s,%s,%s,%s,%s,%s,%s); ]],
			_order_id,
			_userId,
			cjson.encode(_amounts2),
			_amounts2.shop_gold_sum or 0,
			_shoping_desc or "",
			math.floor(tonumber(_goods_id) + 0.5),
			cjson.encode(_authflags),
			tonumber(_actual_amount)
		))
	
	
		if _amounts2.shop_gold_sum then

			-- 成功订单统计
			base.DATA.sql_queue_slow:push_back(PUBLIC.format_sql([[insert into player_shop_gold_stat(player_id,dui_shiwu_gold) 
				value(%s,%s) on duplicate key update dui_shiwu_gold=dui_shiwu_gold+%s;]],_userId,_amounts2.shop_gold_sum,_amounts2.shop_gold_sum))

			monitor_lib.add_data("redshop",_amounts2.shop_gold_sum)
		end

	end,basefunc.error_handle)

	if ok then
		return true
	else
		print("user_shoping_gold_pay error:",err,_userId,basefunc.tostring(_amounts2))
		LL.shop_orders[_order_id] = nil
		return false,1010
	end
end

-- 退款（ gwj 买东西）
-- 返回值：
--		1、true/false 是否成功
--		2、如果出错，则为错误号
function CMD.user_shoping_gold_refund(_order_id)
	-- _userId,_amount,_order_id,_shoping_desc

	local _order = LL.shop_orders[_order_id]

	if not _order then
		return nil,2231
	end

	if _order.order_status ~= "complete" then
		return nil,2255
	end
	
	local user = base.PUBLIC.load_player_info(_order.player_id)
	if not user then
		return nil,2159
	end	
	
	_order.amount = math.floor(tonumber(_order.amount) + 0.5)

	if not _order.amount then
		return nil,1004
	end

	-- 马上置 标志，避免 多次退款
	_order.order_status = "refund"

	CMD.add_consume_statistics(_order.player_id,"cost_shop_gold",_order.amount)

	if _order.props_json and next(_order.props_json) then
		-- 新版本，财富存在 props_json 中
		local _asset_change = {}
		for k,v in pairs(_order.props_json) do
			table.insert(_asset_change,{
				asset_type = k,
				value = v,
			})
		end

		if _order.props_json.shop_gold_sum then
			CMD.add_asset_stat(_order.player_id,"shoping",_order.props_json.shop_gold_sum)
		end

		CMD.multi_change_asset_and_sendMsg(_order.player_id,_asset_change,ASSET_CHANGE_TYPE.SHOPING_REFUND,_order_id)
	else
		-- 兼容旧版本 遗留的订单
		CMD.change_asset_and_sendMsg(_order.player_id,"shop_gold_sum",_order.amount,ASSET_CHANGE_TYPE.SHOPING_REFUND,_order_id)
	end

	-- 记录日志
	base.DATA.sql_queue_slow:push_back(string.format("update player_shop_order set order_status='refund',refund_time=FROM_UNIXTIME(%u) where order_id='%s'",os.time(),_order_id))

	-- 成功退款订单统计
	base.DATA.sql_queue_slow:push_back(PUBLIC.format_sql([[insert into player_shop_gold_stat(player_id,dui_shiwu_gold) 
		value(%s,%s) on duplicate key update dui_shiwu_gold=dui_shiwu_gold+%s;]],_order.player_id,-_order.amount,-_order.amount))

	-- 3元礼包特殊处理
	if PUBLIC.check_shop_3_yuan_gift(_order.authflags) then
		local _count = math.max(0,(CMD.get_orig_variant(_order.player_id,"gift_bag_3_yuan") or 0) - 1)
		CMD.set_orig_variant(_order.player_id,"gift_bag_3_yuan",_count,true) -- 不触发变化通知
	end

	-- 去掉广播
	LL.broadcast_data[_order_id] = nil

	-- monitor_lib.add_data("redshop",_amount)

	return true
end

-- 专属的退款（ gwj 买东西）
-- （退给另外的人，并且扣 手续费）
-- 参数 ：_player_id 收款玩家
--		 _cancel_fee 扣手续费
-- 返回值：
--		1、true/false 是否成功
--		2、如果出错，则为错误号
-- !!!!! 此功能 可能没用了！！！！！！！！！！！！！
function CMD.user_reserve_shoping_gold_refund(_order_id,_player_id,_cancel_fee)
	
	if not type(_player_id) == "string" then
		return nil,1001
	end

	_cancel_fee = tonumber(_cancel_fee)
	if not _cancel_fee or _cancel_fee < 0 then
		return nil,1001
	end

	if not CMD.is_player_exists(_player_id) then
		return nil,1001
	end

	local sql = string.format("select player_id,order_status,amount from player_shop_order where order_id='%s'",tostring(_order_id))
	local ret = base.DATA.db_mysql:query(sql)
	
	if( ret.errno ) then
		print(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
		return nil,1010
	end

	local _order = ret[1]

	if not _order then
		return nil,2231
	end

	if _order.order_status ~= "complete" then
		return nil,2255
	end
	
	local user = base.PUBLIC.load_player_info(_order.player_id)
	if not user then
		return nil,2159
	end	
	
	_order.amount = math.floor(tonumber(_order.amount) + 0.5)

	if not _order.amount then
		return nil,1004
	end

	if _cancel_fee >= _order.amount then
		return nil,1013
	end

	CMD.add_consume_statistics(_player_id,"cost_shop_gold",_order.amount - _cancel_fee)


	CMD.change_asset_and_sendMsg(_player_id,"shop_gold_sum",_order.amount - _cancel_fee,ASSET_CHANGE_TYPE.SHOPING_REFUND,_order_id)

	-- 记录日志
	base.DATA.sql_queue_slow:push_back(string.format("update player_shop_order set order_status='refund',refund_time=FROM_UNIXTIME(%u) where order_id='%s'",os.time(),_order_id))


	-- 去掉广播
	LL.broadcast_data[_order_id] = nil

	-- monitor_lib.add_data("redshop",_amount)

	return true	
end

-- 记录最近用过的订单，做重复检查
local used_merchant_order_ids = {}

-- 用于通过 gwj 从  买服务
-- 返回值：
--		1、true/false 是否成功
--		2、如果出错，则为错误号
function CMD.user_merchant_gold_pay(_userId,_amount,_order_id,_shoping_desc)

	if not _userId then
		return nil,2251
	end

	if not _order_id then
		return false,2254
	end

	if used_merchant_order_ids[_order_id] then
		return false,2254
	end

	local user = base.PUBLIC.load_player_info(_userId)
	if not user then
		return nil,2159
	end	
	
	_amount = math.floor(tonumber(_amount) + 0.5)

	if not _amount then
		return nil,1001
	end

	if user.player_asset.shop_gold_sum < _amount then
		return nil,2253
	end

	CMD.add_consume_statistics(_userId,"cost_shop_gold",-_amount)
	CMD.add_asset_stat(_userId,"merchant_buy",-_amount)

	used_merchant_order_ids[_order_id] = true

	
	CMD.change_asset_and_sendMsg(_userId,"shop_gold_sum",-_amount,ASSET_CHANGE_TYPE.MERCHANT_BUY,_order_id)
	monitor_lib.add_data("redshop",_amount)

	-- 记录日志
	base.DATA.sql_queue_slow:push_back(PUBLIC.format_sql("insert into player_merchant_order(order_id,player_id,props_json,amount,shoping_desc) values(%s,%s,%s,%s,%s); ",
	_order_id,_userId,"",_amount,_shoping_desc or ""))

	-- 成功订单统计
	base.DATA.sql_queue_slow:push_back(PUBLIC.format_sql([[insert into player_shop_gold_stat(player_id,dui_xiaofei_gold) 
		value(%s,%s) on duplicate key update dui_xiaofei_gold=dui_xiaofei_gold+%s;]],_userId,_amount,_amount))

	return true
end

return PROTECTED
--
-- Author: cf
-- Date: 2019/11/11
-- Time: 15:39
-- 说明：华为登录

local skynet = require "skynet_plus"
local base = require "base"
require"printfunc"
local nodefunc = require "nodefunc"

local cjson = require "cjson"

local webclientlib = require "webclient"
local webclient = webclientlib.create()

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

PUBLIC.channels.huawei = {}

local LD = base.LocalData("channel_huawei")
local LF = base.LocalFunc("channel_huawei")

LD.requestMethod = "external.hms.gs.checkPlayerSign"
LD.huaweiVerifyUrl = "https://jos-api.cloud.huawei.com/gameservice/api/gbClientApi"
LD.nativeSignUrl = "http://game-support.jyhd919.cn/HuaWeiView.loginSign.query"
LD.nativeVerifyUrl = "http://game-support.jyhd919.cn/HuaWeiView.payVerify.query"


function LF.format(parms)
	local data = {}

	if parms and type(parms) == "table" then
		for k,v in pairs(parms) do
			v = webclient:url_encoding(v)
			table.insert(data, string.format("%s=%s", k, v))
		end
	end

	-- 按ASCII码升序排序
	table.sort(data)

	return table.concat(data , "&")
end

function LF.sign(baseStr)
	local jsonStr = cjson.encode({params = {content = baseStr}})
	local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
							"request_post_json", LD.nativeSignUrl, jsonStr)
	if ok then
		print("channel_huawei sign 签名1")

		local status, retArgs = pcall( cjson.decode, content )

		dump(retArgs,"channel_huawei sign 签名2")

		if not status then
			print("cjson.decode error",2)
			return "cjson.decode error "
		end

		if not retArgs.data then
			print("retArgs.data is null",2)
			return "sign 错误"
		end

		local signed = retArgs.data.signResult

		return signed
	else
		print("channel_huawei sign http请求失败")
		return "sign http请求失败"
	end
end

-- local function verifyTest(content, sign, signtype)
-- 	local jsonStr = cjson.encode({params = {content = content, sign = sign, signtype = signtype}})

-- 	local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
-- 							"request_post_json", LD.nativeVerifyUrl, jsonStr)
-- 	if ok then
-- 		print("channel_huawei verify 校验1")

-- 		local status, retArgs = pcall( cjson.decode, content )

-- 		dump(retArgs,"channel_huawei verify 校验2")

-- 		if not status then
-- 			error("cjson.decode error",2)
-- 			return false
-- 		end

-- 		if not retArgs.data then
-- 			error("retArgs.data is null",2)
-- 			return false
-- 		end

-- 		local signed = retArgs.data.verifyResult

-- 		print("verifyNew is " .. tostring(signed))

-- 		return signed
-- 	else
-- 		print("channel_huawei verify http请求失败")
-- 		return false
-- 	end
-- end

-- skynet.timer(10, function()
-- 	local baseStr = "amount=6.00&applicationID=101028639&country=CN&currency=CNY&merchantId=890086000300087772&productDesc=xxxxxxxDes&productName=钻石&requestId=2019121910283666511231&sdkChannel=1&url=http://127.0.0.1:18001/sczd/cymj_huaweipay_notify&urlver=2"
-- 	local signed = sign(baseStr)
-- 	verifyTest(baseStr, signed, "RSA256")
-- end)

function LF.generateCPSign(parms)
    -- 对消息体中查询字符串按字典序排序并且进行URLCode编码
	local baseStr = LF.format(parms);

	print("签名字符串："..baseStr)
	-- 用CP侧签名私钥对上述编码后的请求字符串进行签名
	local cpSign = LF.sign(baseStr);

	return cpSign;
end

--[[
  用户验证函数

  参数：_login_data 玩家登录数据。（参见客户端协议 login ）

  返回值：succ,verify_data, user_data
  	succ : true/false ，验证成功 或 失败
  	verify_data : （必须）验证结果数据，如果失败，则为错误号。
		{
			login_id=, (必须)登录id
			password=, (可选) 用户密码
			refresh_token=, (可选) 刷新凭据，某些渠道需要，比如微信
			extend_1=, (可选)扩展数据1
			extend_2=, (可选)扩展数据2
		}
  	user_data : （可选）用户数据，如果为 nil ，则表明用户数据未改变（此前至少登录过）。如果失败 ，则为错误 描述
		{
			name=, (可选)昵称
			head_image=, (可选)头像
			sex = (可选)性别
			sign=, (可选)签名
		}
	★ 注意：返回表里不要包含其他字段，否则 会导致 更新的 sql 出错！！！
--]]
function PUBLIC.channels.huawei.verify(_login_data)

	-- 调试登录
	-- if skynet.getcfg("debug") and _login_data.wechat_test then
	-- 	return true,{
	-- 		login_id = _login_data.login_id,
	-- 	},{
	-- 		name = _login_data.nickname,
	-- 		head_image = _login_data.headimgurl,
	-- 		sex = _login_data.sex or 1,
	-- 	}
	-- end
	print("PUBLIC.channels.huawei.verify 开始验证")
	dump(_login_data)


	local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
	if not status then
		return nil,1001,"_channel_args 参数错误"
	end

	if not retArgs or type(retArgs)~="table" then
		return nil,1001,"decode args 参数错误"
	end

	if not retArgs.ts or type(retArgs.ts) ~= "string" or retArgs.ts == "" then
		return nil,1001,"参数ts 不存在或格式错误"
	end

	if not retArgs.playerId or type(retArgs.playerId) ~= "string" or retArgs.playerId == "" then
		return nil,1001,"参数playerId 不存在或格式错误"
	end

	if retArgs.playerLevel and type(retArgs.playerLevel) == "number" then
		retArgs.playerLevel, _ = math.modf(retArgs.playerLevel)
		retArgs.playerLevel = tostring(retArgs.playerLevel)
	end

	if not retArgs.playerLevel or type(retArgs.playerLevel) ~= "string" or retArgs.playerLevel == "" then
		return nil,1001,"参数playerLevel 不存在或格式错误"
	end

	if not retArgs.playerSSign or type(retArgs.playerSSign) ~= "string" or retArgs.playerSSign == "" then
		return nil,1001,"参数playerSSign 不存在或格式错误"
	end

	local _sdk_cfg = nodefunc.get_global_config "channel_sdk_config"

	local parms = {}
	parms.method = LD.requestMethod
	parms.appId = _sdk_cfg.channels.huawei.appId
	parms.cpId = _sdk_cfg.channels.huawei.cpId
	parms.ts = retArgs.ts
	parms.playerId = retArgs.playerId
	parms.playerLevel = retArgs.playerLevel
	parms.playerSSign = retArgs.playerSSign
	parms.cpSign = LF.generateCPSign(parms)

    local kvData = {}
	for k,v in pairs(parms) do
		k = webclient:url_encoding(k)
		v = webclient:url_encoding(v)

		table.insert(kvData, string.format("%s=%s", k, v))
	end
	local postJson = table.concat(kvData , "&")

	local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
						"request_post_json", LD.huaweiVerifyUrl, postJson)

	if ok then

		print("PUBLIC.channels.huawei.verify 验证回调")

		local status, retArgs = pcall( cjson.decode, content )

		dump(retArgs,"huawei verify 验证回调")

		if not status then
			dump(retArgs,"huawei verify error 1:")
			--error("cjson.decode error",2)
			return nil,1003,"cjson.decode error "
		end

		if retArgs.rtnCode ~= 0 then
			dump(retArgs,"huawei verify error 2:")
			return nil,2155,"华为验证凭据失效"
		end

		local _user = PUBLIC.get_player_verify_data(_login_data.platform,"huawei",parms.playerId)

		if _user then
			return true,{
				login_id=parms.playerId,
			}
		else

			return true,{
				login_id = parms.playerId,
				extend_1 =
				{
					appId = parms.appId,
					cpId = parms.cpId,
					ts = parms.ts,
					playerId = parms.playerId,
					playerLevel = parms.playerLevel,
					playerSSign = parms.playerSSign,
				},
			},{
				name = "华为用户"..  math.random(134,9999),
				sex = 1,
			}
		end

	else
		dump(content,"huawei verify error 3:")
		return nil,2154,content
	end
end

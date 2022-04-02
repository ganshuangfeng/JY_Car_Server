--
-- Author: yy
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：qq 登录

local skynet = require "skynet_plus"
local base = require "base"
require"printfunc"
local md5 = require "md5.core"

local cjson = require "cjson"
local basefunc = require "basefunc"

local nodefunc = require "nodefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

PUBLIC.channels.yyb_qq = PUBLIC.channels.yyb_qq or {}

local LL = PUBLIC.channels.yyb_qq

--[[获取玩家信息
	--请求用户信息返回的body格式
	-- {
			ret	返回码
			msg	如果ret<0，会有相应的错误信息提示，返回数据全部用UTF-8编码。
			nickname	用户在QQ空间的昵称。
			figureurl	大小为30×30像素的QQ空间头像URL。
			figureurl_1	大小为50×50像素的QQ空间头像URL。
			figureurl_2	大小为100×100像素的QQ空间头像URL。
			figureurl_qq_1	大小为40×40像素的QQ头像URL。
			figureurl_qq_2	大小为100×100像素的QQ头像URL。需要注意，不是所有的用户都拥有QQ的100x100的头像，但40x40像素则是一定会有。
			gender	性别。 如果获取不到则默认返回"男"
			is_yellow_vip	标识用户是否为黄钻用户（0：不是；1：是）。
			vip	标识用户是否为黄钻用户（0：不是；1：是）
			yellow_vip_level	黄钻等级
			level	黄钻等级
			is_yellow_year_vip	标识是否为年费黄钻用户（0：不是； 1：是）
	-- }
]]
function LL.getUserInfo( authArgs )

	local _sdk_cfg = nodefunc.get_global_config "channel_sdk_config"

	local userInfo,code = PUBLIC.request_http_get("https://graph.qq.com/user/get_user_info",
	{
		access_token=authArgs.access_token,
		openid=authArgs.openid,
		oauth_consumer_key=_sdk_cfg.channels.yyb.appid,
	})

	if userInfo then
		if userInfo.ret ~= 0 then
			return nil,1001,"qq get UserInfo error :" .. userInfo.ret .. "," .. tostring(userInfo.msg)
		end

		if userInfo.gender == "男" then
			userInfo.sex = 1
		else
			userInfo.sex = 0
		end

		return userInfo
	end

	return nil,code
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
			refresh_token=, (可选) 刷新凭据，某些渠道需要，比如QQ
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
function LL.verify(_login_data)

	--dump(_login_data,"xxxxxxxxxxxxxxxxxxxxx qq verify data:")

	-- login_id, channel_args 至少有一个

	-- 调试登录
	if skynet.getcfg("debug") and _login_data.qq_test then
		return true,{
			login_id = _login_data.login_id,
		},{
			name = _login_data.nickname,
			head_image = _login_data.headimgurl,
			sex = _login_data.sex or 1,
		}
	end

	local _sdk_cfg = nodefunc.get_global_config "channel_sdk_config"

	--直接验证
	if false then --_login_data.login_id then

		-- local _channel = base.DATA.player_verify_data.qq
		-- local _user = _channel and _channel[_login_data.login_id]

		-- if not _user then

		-- 	return nil,2150,"login_id error"

		-- else


		-- 	local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
		-- 	if not status then
		-- 		dump({retArgs,_login_data.channel_args},"qq json decode error 1001.2:")
		-- 		return nil,1001,"_channel_args 参数错误 1001.2"
		-- 	end

		-- 	if not retArgs or type(retArgs)~="table" then
		-- 		return nil,1001,"decode args 参数错误 1001.3"
		-- 	end 

		-- 	if not retArgs.refresh_token then
		-- 		return nil,1001,"refresh_token 不存在 1001.4"
		-- 	end

		-- 	--刷新access_token 即验证是否有效
		-- 	local refreshResult,_code = PUBLIC.request_http_get("https://graph.qq.com/oauth2.0/token",
		-- 	{
		-- 		client_id=qq_config.AppID,
		-- 		grant_type="refresh_token",
		-- 		refresh_token=retArgs.refresh_token or retArgs.token,
		-- 		client_secret=qq_config.AppKey,
		-- 	})

		-- 	if refreshResult then

		-- 		if refreshResult.code ~= nil then
		-- 			return nil,2155,"QQ验证凭据失效，请重新授权QQ登录"
		-- 		end

		-- 		local user_info,_code = LL.getUserInfo( {
		-- 			access_token=refreshResult.access_token,
		-- 			openid=retArgs.openid,
		-- 		} )
		-- 		if not user_info then
		-- 			return nil,_code,"解析QQ服务器返回的用户信息失败"
		-- 		end

		-- 		--dump(user_info,"xxxxxxxxxxxxxxxxxxxxxxxxxx qq refresh getUserInfo:")

		-- 		if retArgs.openid ~= _login_data.login_id then
		-- 			return nil,2154,"qq openid 和 login_id 不匹配"
		-- 		end

		-- 		return true,{
		-- 			login_id = retArgs.openid,
		-- 			refresh_token = refreshResult.refresh_token,
		-- 			extend_1 = retArgs.openid,
		-- 		},{
		-- 			name = user_info.nickname,
		-- 			head_image = user_info.figureurl_qq_2 or user_info.figureurl_qq_1,
		-- 			sex = user_info.sex or 1,
		-- 		}

		-- 	else
		-- 		return nil,_code,"qq refresh token fail 11 !"
		-- 	end


		-- end


	elseif _login_data.channel_args then

		local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
		if not status then
			dump({retArgs,_login_data.channel_args},"qq verify error 1001.5:")
			return nil,1001,"_channel_args 参数错误 1001.5"
		end

		if not retArgs or type(retArgs)~="table"  then
			return nil,1001,"decode args 参数错误 1001.6"
		end

		local code = retArgs.code

		-- 特殊： qq 没有 refresh_token ， 客户端可能将 token 放在 refresh_token  中
		retArgs.token = retArgs.token or retArgs.refresh_token

		if type(code)~="string"
			or string.len(code)<1 then

			code = retArgs.token

			if type(code)~="string"
				or string.len(code)<1 then
				return nil,1001,"code and token 错误 1001.7"
			end

		end

		local _now_time = os.time()
		local _check_param = {
			appid=_sdk_cfg.channels.yyb.appid,
			openid=retArgs.openid,
			openkey=retArgs.token,
			timestamp=_now_time,
			sig=basefunc.md5(_sdk_cfg.channels.yyb.appkey ,tostring(_now_time)),
		}

		local _check_addr = skynet.getcfg("yyb_qq_check_token") or "http://ysdktest.qq.com/auth/qq_check_token"
		local checkResult,_code = PUBLIC.request_http_get(_check_addr,_check_param)
				
		if checkResult then

			if checkResult.ret ~= 0 then
				dump({checkResult,_check_param,_sdk_cfg.channels.yyb.appkey},"qq check token error:")
				return nil,2156,"QQ验证失败，请重试"
			end

			--dump(checkResult,"xxxxxxxxxxxxxxxxxxxxxxxxxx qq checkResult:")

			local user_info,_code = LL.getUserInfo( {
				access_token=retArgs.token,
				openid=retArgs.openid,
			})
			
			if not user_info then
				return nil,_code,"解析QQ服务器返回的用户信息失败"
			end

			dump(retArgs,"xxxxxxxxxxxxxxxxxxxxxxxxxx qq check retArgs:")

			return true,{
				login_id = retArgs.openid,
				refresh_token = checkResult.token,
				extend_1 = retArgs.openid,
			},{
				name = user_info.nickname,
				head_image = user_info.figureurl_qq_2 or user_info.figureurl_qq_1,
				sex = user_info.sex or 1,
			},{
				openid = retArgs.openid,
				openkey = retArgs.paytoken,
				pf = retArgs.pf,
				pfkey = retArgs.pfkey,
			}

		else
			return nil,_code,"qq check token fail!"
		end

	else
		--至少有一个参数 _login_id or _channel_args
		return nil,1001,"登录的参数未找到 _login_id or _channel_args 1001.1"
	end

end



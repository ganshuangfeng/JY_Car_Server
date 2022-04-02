--
-- Author: yy
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：微信登录
-- 微信渠道的login id 使用的是微信的openid

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

PUBLIC.channels.yyb_wechat = {}

--[[获取玩家信息
	--请求用户信息返回的body格式
	-- {
	-- "openid":"OPENID",
	-- "nickname":"NICKNAME",
	-- "sex":1,
	-- "province":"PROVINCE",
	-- "city":"CITY",
	-- "country":"COUNTRY",
	-- "headimgurl": "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
	-- "privilege":[
	-- "PRIVILEGE1",
	-- "PRIVILEGE2"
	-- ],
	-- "unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"
	-- }
]]
function PUBLIC.channels.yyb_wechat.getUserInfo( authArgs )
	--通过access_token获取玩家的信息
	local url_to = string.format("https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s",
									 authArgs.access_token, authArgs.openid )
	--print("xxxxxxxxxxxxxxxxxxx channels.yyb_wechat.getUserInfo: ",url_to)

	local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
									"request", url_to)

	if ok then

		local status, retArgs = pcall( cjson.decode, content )
		if not status then
			dump({retArgs,content},"yyb_wechat json decode error 1003.1:")
			return false,1003,"cjson.decode error 1003.1"
		end

		if retArgs.errcode ~= nil then
			dump(retArgs,"error gat user info xxx 2:")
			return false,1001,"get UserInfo error  1001.4 :"..retArgs.errcode
		end

		--dump(retArgs,"xxxxxxxxxxxxxxxxxxxxx get user yyb_wechat 33333:")

		--微信的普通用户性别，1为男性，2为女性
		if retArgs.sex == 2 then
			retArgs.sex = 0
		else
			retArgs.sex = 1
		end

		return true,retArgs

	else
		-- dump(content)
		return false,2154,content
	end

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
function PUBLIC.channels.yyb_wechat.verify(_login_data)

	-- 调试登录
	if skynet.getcfg("debug") and _login_data.wechat_test then
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
	if _login_data.login_id then

		local _user = PUBLIC.get_player_verify_data(_login_data.platform,"yyb_wechat",_login_data.login_id)

		if not _user then

			return nil,2150,"login_id error"

		else

			local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
			if not status then
				dump({retArgs,_login_data.channel_args},"yyb_wechat json decode error 1001.5:")
				return nil,1001,"_channel_args 参数错误 1001.5"
			end

			if not retArgs or type(retArgs)~="table" then
				return nil,1001,"decode args 参数错误 1001.6"
			end 

			if not retArgs.refresh_token then
				return nil,1001,"refresh_token 不存在 1001.7"
			end

			--刷新access_token 即验证是否有效
			local url_to = string.format("https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%s&grant_type=refresh_token&refresh_token=%s",
							_sdk_cfg.channels.yyb.wx_appid,
							retArgs.refresh_token)

			local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
								"request", url_to)

			if ok then

				local status, refreshResult = pcall( cjson.decode, content )

				if not status then
					dump({refreshResult,content},"yyb_wechat json decode error 1003.2:")
					return nil,1003,"cjson.decode error 1003.2"
				end

				if refreshResult.errcode ~= nil then
					dump(refreshResult,"yyb_wechat verify error 2:")
					return nil,2155,"微信验证凭据失效，请重新授权微信登录"
				end

				--dump(refreshResult,"xxxxxxxxxxxxxxxxxxxxx refresh yyb_wechat 111:")

				local ok, user_info = PUBLIC.channels.yyb_wechat.getUserInfo(  {
					access_token=refreshResult.access_token,
					openid=refreshResult.openid,
				} )
				if( not ok ) then
					return nil,user_info,"解析微信服务器返回的用户信息失败"
				end

				if user_info.unionid ~= _login_data.login_id then
					return nil,2154,"unionid 和 login_id 不匹配"
				end

				return true,{
					login_id = user_info.unionid,
					refresh_token = refreshResult.refresh_token,
					extend_1 = retArgs.openid,
				},{
					name = user_info.nickname,
					head_image = user_info.headimgurl,
					sex = user_info.sex or 1,
				},{
					appid = _sdk_cfg.channels.yyb.wx_appid,
					openid = retArgs.openid,
					openkey = retArgs.paytoken,
					pf = retArgs.pf,
					pfkey = retArgs.pfkey,
				}

			else
				dump(content,"yyb_wechat verify error 3:")
				return nil,2154,content
			end


		end


	elseif _login_data.channel_args then

		local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
		if not status then
			dump({retArgs, _login_data.channel_args},"yyb_wechat json decode error 1001.1:")
			return nil,1001,"_channel_args 参数错误 1001.1"
		end

		if not retArgs or type(retArgs)~="table"  then
			return nil,1001,"decode args 参数错误 1001.2"
		end

		local code = retArgs.code

		if type(code)~="string"
			or string.len(code)<1 then

			code = retArgs.token

			if type(code)~="string"
				or string.len(code)<1 then
				return nil,1001,"code and token 错误 1001.3"
			end
		end

		local _now_time = os.time()
		local _check_param = {
			appid=_sdk_cfg.channels.yyb.wx_appid,
			openid=retArgs.openid,
			openkey=retArgs.token,
			timestamp=_now_time,
			sig=basefunc.tohex(md5.sum(_sdk_cfg.channels.yyb.wx_appkey .. tostring(_now_time))),
		}
		local _check_addr = skynet.getcfg("yyb_wx_check_token") or "http://ysdktest.qq.com/auth/wx_check_token"
		local ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
							"request", _check_addr,_check_param)

		if ok then

			local status, checkResult = pcall( cjson.decode, content )

			if not status then
				dump({checkResult, content},"yyb_wechat json decode error 1003.3:")
				return nil,1003,"cjson.decode error 1003.3"
			end

			if checkResult.ret ~= 0 then
				dump({checkResult,_check_param,_sdk_cfg.channels.yyb.wx_appkey},"wx check token error:")
				return nil,2156,"微信验证失败，请重试"
			end

			--dump(checkResult,"xxxxxxxxxxxxxxxxxxxxx checkResult yyb_wechat 22222:")

			local ok, user_info = PUBLIC.channels.yyb_wechat.getUserInfo( {
				access_token=retArgs.token,
				openid=retArgs.openid,
			})
			
			if( not ok ) then
				return nil,user_info,"解析微信服务器返回的用户信息失败"
			end

			return true,{
				login_id = user_info.unionid,
				refresh_token = checkResult.token,
				extend_1 = retArgs.openid,
			},{
				name = user_info.nickname,
				head_image = user_info.headimgurl,
				sex = user_info.sex or 1,
			},{
				appid = _sdk_cfg.channels.yyb.wx_appid,
				openid = retArgs.openid,
				openkey = retArgs.paytoken,
				pf = retArgs.pf,
				pfkey = retArgs.pfkey,
			}

		else
			dump(content,"yyb_wechat verify error 300:")
			return nil,2154,content
		end

	else
		--至少有一个参数 _login_id or _channel_args
		return nil,1001,"登录的参数未找到 _login_id or _channel_args  1001.8"
	end

end

function PUBLIC.channels.yyb_wechat.after_verify(is_new_user,player_id,new_verify_data,new_user_data,_login_data)

	local _sdk_cfg = nodefunc.get_global_config "channel_sdk_config"
	local status, retArgs = pcall( cjson.decode, _login_data.channel_args)

	skynet.call(DATA.service_config.data_service,"lua","add_player_openid",
			player_id,
			retArgs.appid or _sdk_cfg.channels.yyb.wx_appid,
			new_verify_data.extend_1)
end
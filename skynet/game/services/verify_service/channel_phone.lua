--
-- Author: lyx
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：手机用户登录
--[[

	★ 上线手机登录的 初始化操作，执行下列 sql ,将所有已绑定的手机号 添加到验证表

	insert into player_verify(platform,channel_type,login_id,id) 
	select b.platform,'phone',a.phone_number,a.player_id from bind_phone_number a 
	inner join player_register b on a.player_id = b.id
	on duplicate key update refresh_token=refresh_token;

	★ 用户绑定的时候，和之前手机号登录的用户冲突，则用下列方式修改 验证信息

		移除旧的验证信息：CMD.del_verify_info(_player_id,_channel_type,_login_id)
		加上新的验证信息：CMD.add_verify_info(_player_id,_channel_type,_verify_data)
		 
--]]


local skynet = require "skynet_plus"
local base = require "base"
local cjson = require "cjson"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

PUBLIC.channels.phone = {}
local this = PUBLIC.channels.phone

-- 将手机号加入到 手机验证 渠道
function CMD.phone_add_verify_info(_player_id,_phone_number)
	
	return CMD.add_verify_info(_player_id,"phone",_phone_number,
	{
		login_id = _phone_number,
	})
end

--[[
	通过 短信 验证
	参数 _login_data.channel_args 结构：
		sms_vcode
--]]
function this.verify_by_sms(_login_data)

	local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
	if not status then
		return nil,1001,"channel_args 参数语法错误"
	end

	if not retArgs or type(retArgs)~="table"  then
		return nil,1003,"decode args 参数错误"
	end

	if retArgs.sms_vcode and string.len(retArgs.sms_vcode) > skynet.getcfg("max_sms_len",8) then
		print("login verify_by_sms error:sms code too long.",_login_data.login_id,string.len(retArgs.sms_vcode))
		return {result=1003}
	end

	local _code = skynet.call(base.DATA.service_config.third_agent_service,"lua","verify_phone_vcode",_login_data.login_id,retArgs.sms_vcode)
	if _code ~= 0 then
		return nil,_code,"sms verify code error!"
	end

	local _user = PUBLIC.get_player_verify_data(_login_data.platform,"phone",_login_data.login_id)

	-- 已有手机号，直接返回
	if _user then

		return true,{
			login_id = _login_data.login_id,
			refresh_token = skynet.random_str(15),
			extend_1 = os.time(),
		}
	else

		-- 新手机号，注册用户
		return true,{
			login_id = _login_data.login_id,
			refresh_token = skynet.random_str(15),
			extend_1 = os.time(),
		},{
			name= string.sub(_login_data.login_id,1,3) .. "****" .. string.sub(_login_data.login_id,-4,-1),
			sex=1,
		}
	end
	
end

-- 自动登录信息默认 7 天过期
this.DEFAULT_TIMEOUT = 3600 * 24 * 7

--[[
	通过 token 验证（自动登录）
	参数 _login_data.channel_args 结构：
		token
--]]
function this.verify_by_token(_login_data)
	
	local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
	if not status then
		return nil,1001,"channel_args 参数错误"
	end

	if not retArgs or type(retArgs)~="table"  then
		return nil,1003,"decode args 参数错误"
	end

	local _user = PUBLIC.get_player_verify_data(_login_data.platform,"phone",_login_data.login_id)

	if not _user then
		return nil,1043,"user not exists!"
	end

	local _timeout = skynet.getcfg("login_token_timeout") or this.DEFAULT_TIMEOUT
	if os.time() - (_user.extend_1 or 0)  > _timeout then
		return nil,1042,"token expire!"
	end

	if retArgs.token ~= _user.refresh_token then
		return nil,1044,"token invalid!"
	end

	-- 验证成功，返回信息
	return true,{
		login_id = _login_data.login_id,
		refresh_token = _user.refresh_token, -- token 原样返回
		extend_1 = os.time(),
	}
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
			extend_1=, 上次验证的时间，用于判断自动登录的 token 过期
		}
  	user_data : （可选）用户数据，如果为 nil ，则表明用户数据未改变（此前至少登录过）。如果失败 ，则为错误 描述
		{
			name=, (可选)昵称
			head_image=, (可选)头像
			sex = (可选)性别
			sign=, (可选)签名
		}
	★ 注意：返回表里不要包含其他字段，否则 会导致 更新的 sql 出错！！！

	channel_args 的 json 内容
		sms_vcode 短信验证码
		token 如果没有 sms_vcode , 则用 token 自动登录
--]]
function this.verify(_login_data)

	local status, retArgs = pcall( cjson.decode, _login_data.channel_args )
	if not status then
		return nil,1001,"channel_args 参数语法错误"
	end

	if not retArgs or type(retArgs)~="table"  then
		return nil,1003,"decode args 参数错误"
	end

	if retArgs.sms_vcode then
		return this.verify_by_sms(_login_data)
	else
		return this.verify_by_token(_login_data)
	end
end


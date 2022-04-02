--
-- Author: yy
-- Date: 2018/3/28
-- Time: 11:57
-- 说明：验证服务
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require "printfunc"
local nodefunc = require "nodefunc"
local normal_func = require "normal_func"

require "verify_service.verify_funcs"
local man_test_user_list = require "verify_service.man_test_user_list"

local verify_data = require "verify_service.verify_data"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local _error_handler = basefunc.debug.common_xpcall_handler_type1

------------------------------------------------------------------------------
--[[ 各渠道的验证 模块
 【验证程序的 verify 函数接口规范】
  ★ 参数： _login_data 登录数据
  ★ 返回值：succ,verify_data, user_data
  	succ : true/false ，验证成功 或 失败
  	verify_data : （必须）验证结果数据，如果失败，则为错误号。
		{
			login_id=, (必须)登录id
			password=, (可选) 用户密码
			re几千个 fresh_token=, (可选) 刷新凭据，某些渠道需要，比如微信
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
	status_data : (可选) 渠道自己需要保存的状态数据。（比如 应用宝需要保存相关key 供后续支付用！）
  ★ 注意：返回表里不要包含其他字段，否则 会导致 更新的 sql 出错！！！
--]]
DATA.channel_modules = {
	youke="verify_service.channel_youke", -- 游客登录
	wechat="verify_service.channel_wechat", -- 微信登录
	yyb_wechat="verify_service.channel_yyb_wechat", -- （应用宝）微信登录
	yyb_qq="verify_service.channel_yyb_qq", -- （应用宝）qq登录
	phone="verify_service.channel_phone", -- 电话号码登录
	robot="verify_service.channel_robot", -- 机器人登录 无论如何都只能服务器内部登录
	test="verify_service.channel_test", -- 测试用户
	huawei="verify_service.channel_huawei", -- 华为登录
--	weixin_gz="verify_service.channel_weixin_gz", -- 微信公众号登录
--	weixin_kf="verify_service.weixin_kf", -- 微信开放平台登录
}
------------------------------------------------------------------------------

-- 登录渠道的函数 表，加载的时候由 渠道代码自己填充
PUBLIC.channels = PUBLIC.channels or {}

-- 测试期间 登录限制的倒计时
local function countdown_publish_prepare_time()
	local prc = skynet.getcfg("publish_prepare_cd")
	if prc then 
		prc = tonumber(prc) - 1
		if prc < 1 then
			skynet.setcfg("publish_prepare_cd",nil)

			print("===>>>> publish prepare is over <<<<====")
		else
			skynet.setcfg("publish_prepare_cd",prc)

			if math.fmod(prc,5) < 1 then
				print("===>>>> publish prepare count down:",prc)
			end
		end
	end
end

-- 内部测试中，检查是否 允许登录
-- 返回 false  
function PUBLIC.test_check_allow_login(_platform,_channel_type,_login_id)

	if 'robot' == _channel_type then
		return true
	end

	if not skynet.getcfg("publish_prepare_cd") then
		return true 
	end

	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)
	if not _info or not _info.data then
		return false -- 不存在
	end	

	if not _info.data.id then
		print("error:not found verify info player id")
		return false
	end

	return man_test_user_list.is_test_user(_info.data.id)
end

function CMD.start(_service_config)

	--math.randomseed(os.time())

	-- 加载 所有登录模块
	for _name,_m in pairs(DATA.channel_modules) do
		require (_m)
		if not PUBLIC.channels[_name] then
			error(string.format("login channel '%s' init fail!",_name))
		end
	end

	DATA.service_config = _service_config

	verify_data.init()
	man_test_user_list.init()

	skynet.timer(1,countdown_publish_prepare_time)

end

-- 外部模块创建用户（不通过登录验证创建）
function CMD.extend_create_user(_platform,
								_channel_type,
								_login_id,
								_market_channel,
								_parentUserId,
								_register_os,
								_share_source)

	local _verify_info,_is_new_user = PUBLIC.enter_verifying_status(_platform,_channel_type,_login_id)
	if not _verify_info then
		return nil,1036 -- 正在验证中
	end

	if not _is_new_user then
		_verify_info.is_verifying = false
		return _verify_info.data.id
	end

	local _userId,code

	local ok,_err = xpcall(function()
		_userId,code = skynet.call(DATA.service_config.data_service,"lua","create_player_info",
		{
			channel_type=_channel_type,
			platform=_platform,
			introducer=_parentUserId,
			register_os=_register_os,
			share_source = _share_source,
			market_channel = _market_channel,
			login_id = _login_id,
		})

		if not _userId then
			return
		end

		local _vdata = {
			id = _userId,
			platform = _platform,
			channel_type = _channel_type,
			login_id = _share_source,
		}

		-- 修改验证数据
		PUBLIC.base_add_verify(_platform,_channel_type,_login_id,_vdata)

	end,_error_handler)

	_verify_info.is_verifying = false

	return _userId,code
end


--[[
	用户验证
	参数：
		_login_data 登录数据（参见客户端协议 login ）
		_ip 登录 ip 地址
	多个返回值：userId,login_id
		userId  	验证成功 返回用户 id ，出错则返回 nil
		login_id    用户的登录 id，出错则为错误码

--]]
function CMD.verify(_login_data,_ip)

	_login_data.platform = PUBLIC.check_platform(_login_data.platform)
	_login_data.market_channel = PUBLIC.check_market_channel(_login_data.market_channel)

	local channel = PUBLIC.channels[_login_data.channel_type]
	if not channel then
		return nil,2151
	end

	-- 调用第三方验证
	local succ,new_verify_data, new_user_data,status_data = channel.verify(_login_data)

	-- 出错
	if not succ then
		print(string.format("verify error:ip='%s',login_id='%s',channel_args='%s' !",tostring(_ip),tostring(_login_data.login_id),tostring(_login_data.channel_args)))
		dump({code=new_verify_data,login_data = _login_data,addr = _ip,verify_errid=new_user_data},"verify error")
		return nil,new_verify_data
	end

	if not new_verify_data.login_id then
		print(string.format("channel '%s' veirfy error: login_id is nil!",_login_data.channel_type))
		return nil,2157
	end

	-- 设置验证状态 并得到验证信息
	local _verify_info,_is_new_user = PUBLIC.enter_verifying_status(_login_data.platform,_login_data.channel_type,new_verify_data.login_id)
	if not _verify_info then

		return nil,1036 -- 正在验证中
	end
	
	-- 用 xpcall 包起来，避免异常时未恢复 is_verifying 变量
	local ok,_error_code = xpcall(function()

		if _is_new_user then

			local userId,error_code = skynet.call(DATA.service_config.data_service,"lua","create_player_info",
			{
				platform = _login_data.platform,
				introducer = _login_data.introducer,
				register_os = _login_data.device_os,
				device_id = _login_data.device_id,
				channel_type = _login_data.channel_type,
				register_ip = _ip,
				market_channel = _login_data.market_channel,
				share_source = "",
				login_id = new_verify_data.login_id,
			},new_user_data)


			if userId then

				-- 加入验证信息
				new_verify_data.id = userId
				PUBLIC.base_add_verify(_login_data.platform,_login_data.channel_type,new_verify_data.login_id,new_verify_data)

				if 'robot' ~= _login_data.channel_type then
					local _parent_id
					-- 登录时不绑定
					-- if _login_data.introducer then -- 平台渠道相同才能绑定
					-- 	local _inp = normal_func.safe_player_info(_login_data.introducer)
						
					-- 	if _inp.platform == _login_data.platform and _inp.market_channel == _login_data.market_channel then
					-- 		_parent_id = _login_data.introducer
					-- 	end
					-- end
				end

			else
				print(string.format("player verify error:create player fail:%s",tostring(error_code)))
				return error_code
			end
		else

			-- 已经存在的机器人不需要验证
			if _login_data.channel_type == "robot" then
				return 0
			end

			if not PUBLIC.test_check_allow_login(_login_data.platform,_login_data.channel_type,new_verify_data.login_id) then
				return 1002
			end			

			PUBLIC.base_modify_verify(_login_data.platform,_login_data.channel_type,new_verify_data.login_id,new_verify_data)

			return skynet.call(DATA.service_config.data_service,"lua","verify_user",_login_data.channel_type,_verify_info.data.id,new_user_data)
		end

		-- 验证成功后，允许渠道处理
		if channel.after_verify then
			channel.after_verify(_is_new_user,_verify_info.data.id,new_verify_data,new_user_data,_login_data)
		end

		return 0

	end,_error_handler)

	-- 退出验证状态
	_verify_info.is_verifying = false

	-- 程序运行错误，继续抛出
	if not ok then
		error(_error_code)
	end

	if _error_code ~= 0 then

		if skynet.getcfg("network_error_debug") then
			print("verify service,verify error:",_error_code)
		end

		return nil,_error_code
	end

	-- 记录验证状态数据
	status_data = status_data or {}
	status_data.device_os = _login_data.device_os
	PUBLIC.set_verify_status_data(	_verify_info.data.id,
									_login_data.platform,
									_login_data.channel_type,
									new_verify_data.login_id,
									status_data)

	return _verify_info.data.id,new_verify_data.login_id,_is_new_user,new_verify_data.refresh_token
end

-- 启动服务
base.start_service()

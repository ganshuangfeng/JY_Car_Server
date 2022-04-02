--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：手机验证码管理
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "skynet.crypt"
require "data_func"

require"printfunc"

require "normal_enum"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

--[[ 手机验证码
	phone_number => {
		pic_vcode=, 图片验证码
		pic_vcode_time=, 时间
		pic_vcode_count=, 规定时间内 的数量限制

		sms_vcode=, 短信验证码
		sms_vcode_time=,时间
	}
--]]
DATA.phone_verify_codes = DATA.phone_verify_codes or {}
local verify_codes = DATA.phone_verify_codes

function PUBLIC.safe_phone_data(_phone)
	local _d = verify_codes[_phone] or {}
	verify_codes[_phone] = _d

	return _d
end

-- 生成图片验证码，用于 验证真人操作
-- 返回值： 图片数据，或 nil,error_code
function CMD.create_picture_vcode(_phone)

	if not _phone then
		return nil,1001
	end

	local _d = PUBLIC.safe_phone_data(_phone)

	local _now = os.time()

	-- 限制在 picture_vcode_time 秒 内 最多 picture_vcode_count 个图片验证码
	if not skynet.getcfg("mock_send_phone_code") and _d.pic_vcode_count then
		if _d.pic_vcode_count >= (skynet.getcfg("picture_vcode_count") or 5) then
			if _now - _d.pic_vcode_time < (skynet.getcfg("picture_vcode_time") or 10) then
				return nil,1069
			else
				-- 时间，数量复位
				_d.pic_vcode_count = 0
				_d.pic_vcode_time = _now
			end
		end
	else
		-- 初始化
		_d.pic_vcode_count = 0
		_d.pic_vcode_time = _now
	end

	_d.pic_vcode_count = _d.pic_vcode_count + 1

	if not skynet.getcfg("sms_login_require_pic_vcode") then
		return "" 
	end

	-- 调用 web 接口，获得图片数据

	local _vcode = skynet.random_str(skynet.getcfg("picture_vcode_len") or 4)
	local _url = skynet.getcfg("picture_vcode_url")
	if not _url then
		print("create_picture_vcode error:config 'picture_vcode_url' not found!")
		return nil,2405
	end

	local _pic_w = skynet.getcfg("picture_vcode_width") or 100
	local _pic_h = skynet.getcfg("picture_vcode_heigth") or 40

	local ok,content
	if skynet.getcfg("mock_phone_verify_code") then
		ok,content = true,string.format([[{"validateBase64Str":"%s"}]],crypt.base64encode(_vcode))
	else
		ok,content = skynet.call(base.DATA.service_config.webclient_service,"lua",
										"request",_url,{
											code=_vcode,
											width=_pic_w,
											height=_pic_h,
										})	

		-- dump({url=_url,param={
		-- 	code=_vcode,
		-- 	width=_pic_w,
		-- 	height=_pic_h,
		-- },result={ok,content}},"xxxxxxxxxxxxxxxxxxxxxx call pic code:")
	end

	if not ok then
		print("create_picture_vcode error:call url fail:",_url,basefunc.tostring(content))
		return nil,2406
	end

	local ok, _ret = pcall( cjson.decode, content )

	if not ok then
		print("picture vcode server result error:",basefunc.tostring(content),basefunc.tostring(_ret))
		return nil,2407
	end

	_d.pic_vcode = _vcode

	local _pic_data
	if _ret.validateBase64Str then
		return crypt.base64decode(_ret.validateBase64Str)
	else
		-- 用户看不到图片，手动发起 刷新， 计数器 不增长
		_d.pic_vcode_count = _d.pic_vcode_count - 1
		return "" 
	end
end

-- 发送手机验证码
-- 参数： 手机号 , 验证唯一 id, 验证图片的字符识别内容
-- 返回： 0 成功； 或 错误码
function CMD.send_sms_vcode(_phone,_pic_vcode,_player_id)

	if not _phone then
		return nil,1001
	end

	local _d = verify_codes[_phone]
	if not _d then
		return nil,1004
	end

	if skynet.getcfg("sms_login_require_pic_vcode") then
		if string.lower(_d.pic_vcode) ~= string.lower(_pic_vcode) then
			return nil,1060
		end
	end

	local _now = os.time()

	-- 倒计时
	if not skynet.getcfg("mock_send_phone_code") then
		local _sms_cd = skynet.getcfg("phone_verify_sms_cd") or 60

		if _d.sms_vcode_time and ((_now - _d.sms_vcode_time) < (_sms_cd + 5)) then
			return nil,1069
		end
	end

	local _code = skynet.random_num(skynet.getcfg("phone_vcode_len") or 4)

	local ret
	if skynet.getcfg("mock_phone_verify_code") then
		print(">>>>>> phone sms verify code send:",_phone,_code)
		ret = 0
	else
		local cfg = skynet.getcfg("phone_login_code_sms") or skynet.getcfg("bind_phone_code_sms")

		if type(cfg)~="string" then
			print("send sms error:not config 'phone_login_code_sms' !")
			return nil,2405
		end

		ret = CMD.send_phone_bind_code(_phone,_code,_player_id,cfg)
	end

	if ret == 0 then
		_d.sms_vcode = _code
		_d.sms_vcode_time = _now
	end

	return _code,ret
end

function PUBLIC.write_phone_verify_log(_err_code,_sms_code,_phone)

	PUBLIC.db_exec(PUBLIC.gen_insert_sql("phone_sms_log",{
		--player_id=nil,
		phone_number=_phone,
		sms_code = _sms_code,
		direct = "recv",
		op_type = "login",
		result = tonumber(_err_code),
	}))
	
end

-- 验证手机短信
-- 返回 0  或 错误码
function CMD.verify_phone_vcode(_phone,_sms_vcode)

	if not _phone or not _sms_vcode then
		PUBLIC.write_phone_verify_log(1001,_sms_vcode,_phone)
		return 1001
	end

	local _d = verify_codes[_phone]
	if not _d then
		PUBLIC.write_phone_verify_log(1004,_sms_vcode,_phone)
		return 1004
	end

	if (os.time() - (_d.sms_vcode_time or 0)) > (skynet.getcfg("sms_login_timeout") or 300) then
		PUBLIC.write_phone_verify_log(2602,_sms_vcode,_phone)
		return 2602
	end

	if string.lower(_d.sms_vcode) ~= string.lower(_sms_vcode) then
		PUBLIC.write_phone_verify_log(1060,_sms_vcode,_phone)
		return 1060
	end
	
	PUBLIC.write_phone_verify_log(0,_sms_vcode,_phone)
	return 0
end
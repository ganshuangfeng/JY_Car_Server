--
-- Author: lyx
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：游客登录
--

local skynet = require "skynet_plus"
local base = require "base"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

PUBLIC.channels.test = {}




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
function PUBLIC.channels.test.verify(_login_data)

	--dump(_login_data,"xxxxxxxxxxxxxxxxxdddddddddd test verify:")

	local _user = PUBLIC.get_player_verify_data(_login_data.platform,"test",_login_data.login_id)

	if _user then
		return true,{
			login_id=_login_data.login_id,
		}
	else

		return true,{
			login_id=_login_data.login_id,
		},{
			name="测试_".. math.random(134,9999),
			sex=1,
		}

	end
end


--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：登录配置
--

local ret = {

	-- 登录渠道及名称
	login_info = 
	{
		wechat = "微信",
		phone = "手机号",
		youke = "游客",
		test = "内部测试",
		qq = "QQ",
		yyb_wechat = "微信(应用宝)",
		yyb_qq = "QQ(应用宝)",
		huawei = "华为",
	},

	-- 登录开关 
	login_switch = 
	{
		wechat = true,
		phone = true,
		youke = true,
		test = true,
		qq = true,
		yyb_wechat = true,
		yyb_qq = true,
		huawei = true,
	},

	-- 真人登录（排除测试、游客。。。）
	real_channel = {},
}


for k,v in pairs(ret.login_switch) do
	if "test" ~= k and "youke" ~= k then
		ret.real_channel[k] = v
	end
end

return ret
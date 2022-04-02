--
-- 和登录、支付相关的 sdk 的配置
--[[
	霸王斗地主（目前用作 闲玩CPL 提 企业签用）
		AppID: wxe5218102416a3a8b
		AppSecret:2838560a3f41604a39c3262102e23112

		潮流捕鱼新平台（包含AppSecret） 新潮流家园
		AppID: wx02bdeb0600f2d63a
		AppSecret: 9d512ed9066f7bf0fd85398aa77652ea
		Android平台
		应用签名：1b5692183799f9fc5d4c80db4a63a834
		包名：com.gaoshou.clby		

		潮流捕鱼
		wx445e7d41a847e238
		com.kashibuyi.chaoliuby
		1c3c2f481e8b727565f4684dafb2fb61
--]]

return
{
	-- 所有的 appid 映射： appid => key （AppSecret）
	appids = 
	{
		-- wechat
		["wxe5218102416a3a8b"] = "2838560a3f41604a39c3262102e23112",
		["wxf64ec3fb99c28771"] = "a5de436ba39176eb97dfabf720d45459",
		["wxac0acbbcc95a3e17"] = "b7ba1a4f9522d30553c023f94c0aad32",
		["wx02bdeb0600f2d63a"] = "9d512ed9066f7bf0fd85398aa77652ea",
		["wx445e7d41a847e238"] = "1c3c2f481e8b727565f4684dafb2fb61",
		["wxa67208ed9db78f10"] = "fe5dd50239dc75ad1587608600817597",

		-- 应用宝
		["1109655980"] = "uAZqcD5Uwg86onHP",
		["wx40ae5dfaaa09975d"] = "f9946ff715c5c8cc5bdee74cceb94d18",
	},

	-- 作为微信提现 的 appid （否则使用支付宝）， 支持填多个
	wechat_withdraw_appids =
	{
		"wxf64ec3fb99c28771",
	},

	-- 各种渠道配置
	channels = 
	{
		-- 原生渠道
		nor = 
		{
			-- 微信登录
			wx_appid = "wxf64ec3fb99c28771",
			wx_appkey = "a5de436ba39176eb97dfabf720d45459",
		},

		-- 应用宝
		yyb = 
		{
			-- qq登录
			appid = "1109655980",
			appkey = "uAZqcD5Uwg86onHP", 

			-- 米大师支付的 appid 和 key 
			midas_appid = "1109655980",
			--midas_appkey = "uAZqcD5Uwg86onHP", -- 沙箱
			midas_appkey = "HDQSBHEiYwTLNGTS18IlVNmiB4wbulqB", -- 正式

			-- 微信登录
			wx_appid = "wx40ae5dfaaa09975d",
			wx_appkey = "f9946ff715c5c8cc5bdee74cceb94d18",
		},

		-- 华为
		huawei = 
		{
			-- 应用ID
			appId = "101288269",

			-- 商户ID，用于登录和支付
			cpId = "70086000192742361",

			-- 发货地址
			pay_url = "http://paynotify.jyhd919.cn/sczd/cymj_huaweipay_notify"
		}
	},

}
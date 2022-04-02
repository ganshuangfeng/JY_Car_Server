--
-- Author: lyx
-- Date: 2018/5/24
-- Time: 15:14
-- 说明：支付相关的配置
--

local skynet = require "skynet_plus"

require "normal_enum"

local this = {}

-- 支持的渠道
this.channel_types =
{
	alipay = true,
	weixin = true,
	wxgzh = true,
	appstore = true,
	yyb = true, -- 应用宝
	huawei = true, -- 华为
}

-- 渠道的中文显示名字
this.channel_names =
{
	alipay = "支付宝",
	weixin = "微信",
	wxgzh = "微信公众号",
	appstore = "苹果商店",
	yyb = "应用宝",
	huawei = "华为",
}

this.appstore_bundleid=
{
	["com.scjyhd.jyjjddz"] = true,
	["com.jyhdjyj.jyjjddz"] = true,
	["com.kashibuyi.bawangddz"] = true,
	["com.jyhdgame.shyxz"] = true,
	["com.wcdma.wwee"] = true,
}

-- 平台、渠道对应的 商品配置文件名后缀（默认用 不带后缀的 shoping_config）
-- 第一层为 平台，第二层为 推广渠道；平台渠道说明 参见 share_invite_config.lua
-- default 表示 默认平台/渠道
this.platform_shoping_config=
{
	default = 
	{
		default = "shoping_config",
	},

	yyb_cymj = 
	{
		default = "shoping_config_cymj",
	},
	hw_cymj = 
	{
		default = "shoping_config_cymj_hw",
	},
	-- wqp = 
	-- {
	-- 	wqp_yyb = "shoping_config_wqp_yyb",
	-- },
}

-- 全部支付商城配置
this.shoping_configs = 
{
	"shoping_config",
	"shoping_config_cymj", -- 应用宝彩云麻将平台 (钻石为1毛)
	"shoping_config_cymj_hw", -- 华为彩云麻将平台
	--"shoping_config_wqp_yyb", -- 玩棋牌平台 应用宝 渠道
}

-- 变量系统中， 不计入累计充值的 商品
--this.not_sum_goods = { 10084,10085,10086,10,10080,10169,10190 , 10087 , 10088 , 10248 , 10249 , 10250 , 10251 , 10252 , 10253 , 10254 , 10255 , 10283 }

return this
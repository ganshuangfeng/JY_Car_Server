--
-- Author: lyx
-- Date: 2018/10/9
-- Time: 15:14
-- 说明：分享邀请配置
--[[

	★★★【鲸鱼斗地主】★★★
	-----------------------------------
	-- 平台、 推广渠道

	平台(platform)            APP名称       推广渠道(market_channel)
	---------------------------------------------------------------------
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     normal:官方
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     juxiang:聚享玩(CPL)
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     pceggs:pc蛋蛋(CPL)
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     xianwan:闲玩(CPL)
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     xiaozhuo:小啄(CPL)
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     yingxiongji:貴州英雄鷄
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     xjwh:星嘉文化
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     dandanzhuan:蛋蛋赚
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     aibianxian:爱变现
	yyb_cymj:应用宝-彩云麻将   彩云麻将       yyb_cymj:应用宝-彩云麻将
	hw_cymj:华为-彩云麻将      彩云麻将       hw_cymj:华为-彩云麻将
	hw_wqp:华为-玩棋牌         玩棋牌         hw_wqp:华为-玩棋牌
	xw_clby:闲玩-潮流捕鱼      潮流捕鱼       xw_clby:闲玩(CPL 独立为平台)
	wqp:玩棋牌                 玩棋牌         wqp:玩棋牌 
	wqp:玩棋牌                 玩棋牌         wqp_pceggs:玩棋牌 蛋蛋(CPL)
	wqp:玩棋牌                 玩棋牌         wqp_xianwan:玩棋牌 闲玩(CPL)
	wqp:玩棋牌                 玩棋牌         wqp_juxiang:玩棋牌 聚享玩(CPL)
	wqp:玩棋牌                 玩棋牌         wqp_xiaozhuo:玩棋牌 小啄(CPL)
	wqp:玩棋牌                 玩棋牌         wqp_tcc:玩棋牌 停车场(CPL)
	wqp:玩棋牌                 玩棋牌         wqp_dandanzhuan:蛋蛋赚
	wqp:玩棋牌                 玩棋牌         wqp_pdd:拼多多
	wqp:玩棋牌                 玩棋牌         wqp_yyb:应用宝
	wqp:玩棋牌                 玩棋牌         wqp_mtzd:每天赚点
	wqp:玩棋牌                 玩棋牌         wqp_juxiang:玩棋牌 聚享玩(CPL)
	wqp:玩棋牌                 玩棋牌         wqp_xiaozhuo:玩棋牌 小啄(CPL)

	-- 废弃
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     qwxq:趣味星球(CPL)     (废弃)
	normal:官方-鲸鱼斗地主     鲸鱼斗地主     juju:聚聚玩(CPL)       (废弃)

	-- 修改记录
	 2020/2/5    xw_clby/xianwan => xw_clby/xw_clby
	 2020/3/13   新增:  hw_wqp/hw_wqp
	 2020/3/16   新增:  normal/xjwh
	 2020/4/7    新增:  wqp/wqp
	 2020/4/13   新增:  wqp/wqp_pceggs,wqp_xianwan,wqp_juxiang,wqp_xiaozhuo
	 2020/5/13   新增:  normal/dandanzhuan
	 2020/5/15   新增:  wqp/wqp_tcc
	 2020/5/28   新增:  wqp/wqp_pdd
	 2020/6/4    新增:  wqp/wqp_yyb
	 2020/6/19   新增:  xw_cymj/xw_cymj
	 2020/6/23   删除:  xw_cymj/xw_cymj
	 2020/6/23   新增:  cymj/cymj
	 2020/6/23   新增:  cymj/cymj_xw
	 2020/6/23   删除:  cymj/cymj
	 2020/6/23   删除:  cymj/cymj_xw
	 2020/7/2    增加:  wqp/wqp_mtzd
	 2020/7/27   增加:  normal/aibianxian
	 2020/9/21   增加:  wqp/wqp_juxiang,wqp_xiaozhuo
--]]

local config = {

	-- default 表示 默认配置
	-- 分享的 平台 渠道映射： 平台,渠道 => 平台,渠道 , nil 表示跟随
	invite_config = {
		default = {
			default={"normal","normal"}, -- 默认使用官方平台，官方渠道
			yingxiongji={nil,nil}, -- 英雄鸡 渠道要跟随
			xjwh={nil,nil}, -- 星嘉文化 渠道要跟随
		},
		xw_clby = {
			default = {"xw_clby","xw_clby"},
		},
		wqp = {
			default = {"wqp","wqp"},
		},
	},

	-- 所有的平台： 未配置 的 默认用 normal 中的
	all_platform = {
		normal = {
			app_link = "www.jyhd919.cn",
			sms_sign = "【高手互娱】",
		},
		yyb_cymj = {
			app_link = "www.jyhd919.cn",
		},
		hw_cymj = {
			app_link = "www.jyhd919.cn",
		},
		hw_wqp = {
			app_link = "www.jyhd919.cn",
		},
		xw_clby = {
			app_link = "www.jyhd919.cn",
		},
		wqp = {
			app_link = "www.jyhd919.cn",
			sms_sign = "【高手互娱】",
		},
	},

	-- 所有的渠道
	all_market_channel = {

		-- normal
		normal = {

		},
		juxiang = {

		},
		pceggs = {

		},
		xianwan = {

		},
		xiaozhuo = {

		},
		yingxiongji = {

		},
		xjwh = {

		},
		dandanzhuan = {

		},
		aibianxian = {

		},

		-- cps
		yyb_cymj = {

		},
		hw_cymj = {

		},
		xw_clby = {

		},
		hw_wqp = {

		},

		-- 玩棋牌
		wqp = {

		},
		wqp_pceggs = {

		},
		wqp_xianwan = {

		},
		wqp_juxiang = {

		},
		wqp_xiaozhuo = {

		},
		wqp_tcc = {

		},
		wqp_dandanzhuan = {

		},
		wqp_pdd = {

		},
		wqp_yyb = {

		},
		wqp_mtzd = {

		},
		wqp_juxiang = {

		},
		wqp_xiaozhuo = {

		},
	},
}

return config
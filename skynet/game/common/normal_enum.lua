--
-- Author: lyx
-- Date: 2018/4/14
-- Time: 10:31
-- 说明：公用的 枚举变量
--

-- 条件的处理方式
NOR_CONDITION_TYPE =
{
	CONSUME = 1, -- 消费：必须大于等于，并扣除
	EQUAL = 2, -- 等于
	GREATER = 3, -- 大于等于
	LESS	= 4, -- 小于等于
	NOT_EQUAL = 5, --- 不等于
}


-- 玩家财富类型
PLAYER_ASSET_TYPES =
{
	DIAMOND 			= "diamond", 		-- 钻石
	JING_BI 			= "jing_bi",	    -- 鲸币
	CASH 				= "cash", 			-- 现金
	SHOP_GOLD_SUM		= "shop_gold_sum",	-- 总数：各面额加起来
	GEAR                = "gear" ,          -- 零件
	PATCH_FALALI        = "patch_falali" ,  -- 法拉利碎片
	PATCH_TANKE         = "patch_tanke" ,   -- 坦克碎片 
	PATCH_PINGTOU       = "patch_pingtou" , -- 平头哥碎片
	PATCH_DILEI         = "patch_dilei" ,   -- 地雷车碎片

}


-- 玩家财富类型
PLAYER_ASSET_TYPES_TO_NAME =
{
	[PLAYER_ASSET_TYPES.DIAMOND]                 = "钻石",
	[PLAYER_ASSET_TYPES.JING_BI]                 = "鲸币",
	[PLAYER_ASSET_TYPES.CASH]                    = "现金",
	[PLAYER_ASSET_TYPES.SHOP_GOLD_SUM]           = "福卡",
	[PLAYER_ASSET_TYPES.GEAR]                    = "零件",

	[PLAYER_ASSET_TYPES.PATCH_FALALI]            = "法拉利碎片",
	[PLAYER_ASSET_TYPES.PATCH_TANKE]             = "坦克碎片",
	[PLAYER_ASSET_TYPES.PATCH_PINGTOU]           = "平头哥碎片",
	[PLAYER_ASSET_TYPES.PATCH_DILEI]             = "地雷车碎片",

}

-- 财富类型转金币的兑换率,一个单位转几个鲸币
PLAYER_ASSET_TRANS_JINGBI = {
	[PLAYER_ASSET_TYPES.DIAMOND]                 = 100,     -- 钻石
	[PLAYER_ASSET_TYPES.JING_BI]                 = 1,       -- 鲸币
	[PLAYER_ASSET_TYPES.CASH]                    = 100,     -- 现金（分）
	[PLAYER_ASSET_TYPES.SHOP_GOLD_SUM]           = 100,     -- 总数：各面额加起来
	[PLAYER_ASSET_TYPES.GEAR]                    = 100 ,
	
	[PLAYER_ASSET_TYPES.PATCH_FALALI]                    = 100 ,
	[PLAYER_ASSET_TYPES.PATCH_TANKE]                    = 100 ,
	[PLAYER_ASSET_TYPES.PATCH_PINGTOU]                    = 100 ,
	[PLAYER_ASSET_TYPES.PATCH_DILEI]                    = 100 ,

}

-- 玩家财富类型集合 以及 所有 prop_ 开头的东西
PLAYER_ASSET_TYPES_SET =
{
	["diamond"] 		= "diamond", 		-- 钻石
	["jing_bi"] 		= "jing_bi",		-- 鲸币
	["cash"] 			= "cash", 			-- 现金
	["shop_gold_sum"] 	= "shop_gold_sum", 	-- 
	["gear"]            = "gear" ,

	["patch_falali"]            = "patch_falali" ,
	["patch_tanke"]            = "patch_tanke" ,
	["patch_pingtou"]            = "patch_pingtou" ,
	["patch_dilei"]            = "patch_dilei" ,
	
}

-- 面额映射
SHOP_GOLD_FACEVALUES =
{
	["shop_gold_10"] = 10,
	["shop_gold_100"] = 100,
	["shop_gold_1000"] = 1000,
	["shop_gold_10000"] = 10000,
}
-- 类型映射
SHOP_GOLD_PROPTYPES =
{
	[10] 	= "shop_gold_10",
	[100] 	= "shop_gold_100",
	[1000] 	= "shop_gold_1000",
	[10000] = "shop_gold_10000",
}

--财富改变类型
--[[
	所有类型可以后面接 _email 表示从邮件获取(和原本的进行区别)
	例如 buy_email buy_gift_email
--]]
ASSET_CHANGE_TYPE = {



	BUY = "buy",	 			--玩家充值购买
	BUY_GIFT = "buy_gift",	 	--玩家充值购买 附赠 的东西
	SHOPING = "shoping",		--玩家在线上商城通过  买东西
	MERCHANT_BUY = "merchant_buy",	
	WITHDRAW = "withdraw",		--玩家现金提现
	WITHDRAW_TO_SHOP_GOLD = "withdraw_to_shop_gold",		--玩家现金提现

	SHOPING_REFUND = "shoping_refund",		--退款（玩家在线上商城通过  买东西）

	PAY_EXCHANGE_JINGBI = "pay_exchange_jingbi", -- 充值界面中，用钻石购买鲸币
	PAY_EXCHANGE_JIPAIQI = "pay_exchange_jipaiqi", -- 充值界面中，用钻石购买记牌器
	PAY_EXCHANGE_ROOMCARD = "pay_exchange_roomcard", 	-- 充值界面中，用钻石购买房卡

	-- pay_exchange_ .. "type"...


	NEW_USER_LOGINED_AWARD = "new_user_logined_award",

	NEW_USER_QYS_AWARD = "new_user_qys_award",

	---- PVP 游戏报名
	PVP_GAME_SIGNUP = "pvp_game_signup",

	-- 兑物券
	DWQ_CHANGE_1="dwq_change_1", 		--兑物券合成扣除
	DWQ_CHANGE_2="dwq_change_2", 		--兑物券合成增加
	DWQ_CHANGE_3="dwq_change_3", 		--兑物券普通使用扣除
	DWQ_CHANGE_4="dwq_change_4", 		--兑物券被激活码的方式使用
	--
	GWJ_CHANGE_1="gwj_change_1", 		--自己使用兑物券增加

	FREESTYLE_LHD_SIGNUP="freestyle_lhd_signup", 	--自由场金蛋大乱斗报名
	FREESTYLE_LHD_GAME_SETTLE="freestyle_lhd_game_settle", 	--自由场金蛋大乱斗游戏下注或赢钱

	FREESTYLE_SIGNUP="freestyle_signup", 	--自由场报名
	FREESTYLE_CANCEL_SIGNUP="freestyle_cancel_signup", 	--自由场报名
	FREESTYLE_GAME_SETTLE="freestyle_game_settle", 	--自由场游戏输赢

	--laizi
	LZ_FREESTYLE_SIGNUP="lz_freestyle_signup", 	--自由场报名
	LZ_FREESTYLE_CANCEL_SIGNUP="lz_freestyle_cancel_signup", 	--自由场报名
	LZ_FREESTYLE_AWARD="lz_freestyle_award", 	--自由场获奖
	LZ_FREESTYLE_LOSE="lz_freestyle_lose", 	--自由场输了

	--laizi
	TY_FREESTYLE_SIGNUP="ty_freestyle_signup", 	--自由场报名
	TY_FREESTYLE_CANCEL_SIGNUP="ty_freestyle_cancel_signup", 	--自由场报名
	TY_FREESTYLE_AWARD="ty_freestyle_award", 	--自由场获奖
	TY_FREESTYLE_LOSE="ty_freestyle_lose", 	--自由场输了


	MILLION_SIGNUP="million_signup", 		--百万大奖赛报名
	MILLION_CANCEL_SIGNUP="million_cancel_signup",	--百万大奖赛取消报名
	MILLION_COMFORT_AWARD="million_comfort_award", 	--百万大奖赛安慰奖
	MILLION_AWARD="million_award", 	--百万大奖赛获奖
	MILLION_FUHUO="million_fuhuo", 	--百万大奖赛复活

	-- 麻将自由场
	MAJIANG_FREESTYLE_SIGNUP="majiang_freestyle_signup", 	--自由场报名
	MAJIANG_FREESTYLE_CANCEL_SIGNUP="majiang_freestyle_cancel_signup", 	--自由场报名
	MAJIANG_FREESTYLE_AWARD="majiang_freestyle_award", 	--自由场获奖
	MAJIANG_FREESTYLE_LOSE="majiang_freestyle_lose", 	--自由场输了
	MAJIANG_FREESTYLE_REFUND="majiang_freestyle_refund", 	--退税（杠的钱）


	-- 麻将自由场
	MJXL_MAJIANG_FREESTYLE_SIGNUP="mjxl_majiang_freestyle_signup", 	--自由场报名
	MJXL_MAJIANG_FREESTYLE_CANCEL_SIGNUP="mjxl_majiang_freestyle_cancel_signup", 	--自由场报名
	MJXL_MAJIANG_FREESTYLE_AWARD="mjxl_majiang_freestyle_award", 	--自由场获奖
	MJXL_MAJIANG_FREESTYLE_LOSE="mjxl_majiang_freestyle_lose", 	--自由场输了
	MJXL_MAJIANG_FREESTYLE_REFUND="mjxl_majiang_freestyle_refund", 	--退税（杠的钱）

	MATCH_SIGNUP="match_signup", 		--比赛场报名
	MATCH_CANCEL_SIGNUP="match_cancel_signup",	--比赛场取消报名
	MATCH_AWARD="match_award", 	--自由场获奖
	MATCH_REVIVE="match_revive", 	--自由场复活

	MANUAL_SEND="manual_send", 	--手工发送
	TUOGUAN_ADJUST="tuoguan_adjust", 	--托管 调整

	TUOGUAN_FIT_GAME="tuoguan_fit_game", 	--托管 适配游戏

	ADMIN_DECREASE_ASSET="admin_decrease_asset", 	--管理员进行扣除资产

	EVERYDAY_SHARED_FRIEND="everyday_shared_friend", 	--每日分享朋友奖励
	EVERYDAY_SHARED_TIMELINE="everyday_shared_timeline", 	--每日分享朋友圈奖励
	EVERYDAY_FLAUNT="everyday_flaunt", 	--每日炫耀奖励
	EVERYDAY_SHARED_MATCH="everyday_shared_match", 	--每日分享朋友圈奖励

	XSYD_FINISH_AWARD="xsyd_finish_award", 	--新手引导完成奖励

	FRIENDGAME_RENT = "friendgame_rent", 	--房卡开放费用

	ZIJIANFANG_SETTLE = "zijianfang_settle",  --自建房结算费用
	ZIJIANFANG_ROOM_RENT = "zijianfang_room_rent",--自建房房费
	-- ZIJIANFANG_SIGNUP = "zijianfang_signup", --自建房报名

	-- 所有礼包
	--"buy_gift_bag_".._order.product_id

	FG_TODAY_HB = "fg_today_hb", 	--自由场每日红包
	FG_WEEK_CASH = "fg_week_cash", 	--自由场每周奖金

	TASK_AWARD = "task_award", 	--任务奖励

	GOLD_PIG2_TASK_AWARD = "gold_pig2_task_award",     --- 金猪2的任务奖励

	GLORY_AWARD = "glory_award", 	--荣耀奖励

	PAY_EXPRESSION_LOTTERY = "pay_expression_lottery", 	--购买表情抽奖

	EXPRESSION_LOTTERY_RESULT = "expression_lottery_result", 	--表情抽奖的结果

	REDEEM_CODE_AWARD = "redeem_code_award", --兑换码奖励

	BROKE_SUBSIDY = "broke_subsidy", --破产补助
	FREE_BROKE_SUBSIDY = "free_broke_subsidy", --破产补助

	BROKE_BEG = "broke_beg", --免费领鲸币
	EGG_GAME_SPEND = "egg_game_spend",                 -- 砸金蛋消费
	EGG_GAME_AWARD = "egg_game_award",                 -- 砸金蛋 奖励
	EGG_GAME_REPLACE_EGG = "egg_game_replace_egg",     -- 砸金蛋 换蛋


	-- freestyle_activity_award_email -- 自由场活动奖励通过邮件获取
	FREESTYLE_ACTIVITY_AWARD = "freestyle_activity_award",     -- 自由场活动奖励
	FREESTYLE_ACTIVITY_EXT_AWARD = "freestyle_activity_ext_award",     -- 自由场活动额外奖励

	FISHING_TASK_CHOU_JIANG = "fishing_task_chou_jiang",       -- 捕鱼累积赢金抽奖任务

	FISHING_GAME_SETTLE = "fishing_game_settle",     -- 捕鱼游戏

	--- 捕鱼每日任务 奖励
	BUYU_DAILY_TASK_AWARD = "buyu_daily_task_award",

	--- 发放礼券奖励(绑定上级)
	GRANT_GIFT_COUPON = "grant_gift_coupon",

	-- vip礼包返利
	-- vip_lb_rebate

	-- 活动兑换
	-- activity_exchange_ .. "xxx"

	-- 过期了
	-- overdue

	-- 隐藏背包的物品被再利用
	-- hide_bag_reuse

	-- 自由场结算红包兑换
	FREESTYLE_SETTLE_EXCHANGE_HONGBAO = "freestyle_settle_exchange_hongbao",

		---- 消消乐消耗
	XXL_GAME_SPEND = "xxl_game_spend",
	---- 消消乐奖励
	XXL_GAME_AWARD = "xxl_game_award",
		---- 水浒消消乐消耗
	XXL_SHUIHU_GAME_SPEND = "xxl_shuihu_game_spend",
	---- 水浒消消乐奖励
	XXL_SHUIHU_GAME_AWARD = "xxl_shuihu_game_award",

	XXL_CAISHEN_GAME_SPEND = "xxl_caishen_game_spend",

	XXL_CAISHEN_GAME_AWARD = "xxl_caishen_game_award",

	-- XXL_CAISHEN_GAME_ZP_AWARD = "xxl_caishen_game_zp_award",

	-- 弹弹乐
	TTL_GAME_SPEND = "ttl_game_spend",

	TTL_GAME_AWARD = "ttl_game_award",


	---- 大富豪奖励
	DAFUHAO_GAME_AWARD = "dafuhao_game_award",

	---- 充值抽奖奖励
	CHARGE_LOTTERY_AWARD = "charge_lottery_award",

	LOTTERY_LUCK_BOX = "lottery_luck_box",

	OPEN_LUCK_BOX = "open_luck_box",

	USE_OBJ = "use_obj", -- 道具使用
	USE_PROP = "use_prop", -- 道具使用

	---- 打鱼抽奖任务奖励
	BUYU_SPEND_LOTTERY_TASK_AWARD = "buyu_spend_lottery_task_award",

	--- 西瓜排行
	WATERMELON_RANK_AWARD = "watermelon_rank_award",

	BUYU_RANK_AWARD = "buyu_rank_award",

	XIAOXIAOLE_ONCE_GAME_RANK_AWARD = "xiaoxiaole_once_game_rank_award",

	XIAOXIAOLE_SHUIHU_ONCE_GAME_RANK_AWARD = "xiaoxiaole_shuihu_once_game_rank_award",
	---
	EVERYDAY_SHARE_ACTIVITY_AWARD = "everyday_share_activity_award",

	--- 新人专属奖励
	NEW_PLAYER_LOTTERY_AWARD = "new_player_lottery_award",

	--- 夏日活动
	OLD_PLAYER_LOTTERY_AWARD = "old_player_lottery_award",

	OLD_PLAYER_LOTTERY_RANK_AWARD = "old_player_lottery_rank_award",

	IOS_PLYJ = "ios_plyj",

	---月卡升级奖励
	YUEKA_UPGRADE_AWARD = "yueka_upgrade_award",

	JIKA_LOTTERY_AWARD = "jika_lottery_award",

	---- 鲸鱼快跑
	JING_YU_KUAI_PAO = "jing_yu_kuai_pao",

	---- 鲸鱼快跑 下注
	JING_YU_KUAI_PAO_BET = "jing_yu_kuai_pao_bet",
	---- 鲸鱼快跑 撤销
	JING_YU_KUAI_PAO_CABCEL_BET = "jing_yu_kuai_pao_cabcel_bet",
	---- 鲸鱼快跑 奖励
	JING_YU_KUAI_PAO_AWARD = "jing_yu_kuai_pao_award",
	JING_YU_KUAI_PAO_AUTO_AWARD = "jing_yu_kuai_pao_auto_award",
	---- 鲸鱼快跑 奖励
	JING_YU_KUAI_PAO_EMAIL_AWARD = "jing_yu_kuai_pao_email_award",

	PAY_STRIDE_1000 = "pay_stride_1000",

	FISH_USE_SKILL_FROZEN = "fish_use_skill_frozen",

	FISH_USE_SKILL_LOCK = "fish_use_skill_lock",

	---- 许愿池领取奖励消耗
	XUYUANCHI_GET_AWARD_SPEND = "xuyuanchi_get_award_spend",


	BIND_PHONE_AWARD = "bind_phone_award",

	----- vip充值奖励
	VIP_CHARGE_AWARD = "vip_charge_award",

  	---- 周年庆预约奖励
	ZHOUNIANQING_YUYUE_AWARD = "zhounianqing_yuyue_award",

	FISH_MATCH_SIGNUP = "fish_match_signup",

	BUYU_MATCH_REVIVE = "buyu_match_revive",

	---- 点赞有礼奖励
	CLICK_LIKE_AWARD = "click_like_award",

	---- 元宵猜灯谜奖励
	CAI_DENGMI_AWARD = "cai_dengmi_award",

	----- 捕鱼比赛奖励
	BUYU_MATCH_AWARD = "buyu_match_award",

	FISH_MATCH_CANCEL_SIGNUP = "fish_match_cancel_signup",

	ZNQ_LOOK_BACK = "znq_look_back",

	ZHOUNIANQING_YINGJING_RANK_EMAIL_AWARD = "zhounianqing_yingjing_rank_email_award",

	ZHOUNIANQING_YINGJING_RANK_WANGZHE_EMAIL = "zhounianqing_yingjing_rank_wangzhe_email",

	-- 纪念币兑换兑换券
	ZNQ_JNB_EXCHANGE_DHQ = "znq_jnb_exchange_dhq",

	-- 纪念币回收
	ZNQ_JNB_RECYCLE = "znq_jnb_recycle" ,

	--兑换券抽奖
	ZNQ_DHQ_LOTTERY = "znq_dhq_lottery",

	--兑换券抽奖 奖励
	ZNQ_DHQ_LOTTERY_AWARD = "znq_dhq_lottery_award",

	--千元赛每次提醒 奖励
	QYS_EVERY_TIME_REMIND = "qys_every_time_remind",


	--签到 奖励
	SIGN_IN_AWARD = "sign_in_award",

	--累积签到 奖励
	SIGN_IN_ACC_AWARD = "sign_in_acc_award",
	-- 邮件通知附赠
	EMAIL_NOTIFICATION_GIFT = "email_notification_gift",

    --师徒系统发布收徒信息
    STXT_PUBLISH_INFO = "stxt_publish_info",
    --师徒系统每日奖励
    STXT_EVERYDAY_TASK_AWARDS = "stxt_everyday_task_awards",
    --师徒系统师父获赞数达标每日奖励
    STXT_EVERY_DAY_MASTER_AWARD = "stxt_every_day_master_award",
	--师徒系统徒弟每周获得奖励类型
    STXT_EVERY_WEEK_APPRENTICE_AWARD = "stxt_every_week_apprentice_award",
    --师徒系统师父赠送道具
    STXT_GIVE_PROPS = "stxt_give_props",

	--师徒系统拜师
	STXT_ASK_MASTER = "stxt_ask_master",

	-- 推广成就系统奖励
	SCZD_ACHIEVEMENT_SYS_AWARD = "sczd_achievement_sys_award",
	-- 宝箱兑换抽奖活动兑换奖励 接活动id id
	-- "box_exchange_active_award_" .. id,

	-- 红包容量到上限后，进行转换
	HB_LIMIT_CONVERT = "hb_limit_convert",

    --幸运抽奖币清理
	XYCJ_CLEAR = "xycj_clear",
	--看广告奖励
	WATCH_AD_AWARD = "watch_ad_award",
	-- 抢红包抢
	QHB_QIANG = "qhb_qiang",
	-- 抢红包发
	QHB_SEND = "qhb_send",
	-- 抢红包返
	QHB_FAN = "qhb_fan",
	-- 抢红包踩雷
	QHB_BOOM = "qhb_boom",
	-- 抢红包雷返
	QHB_BOOM_FAN = "qhb_boom_fan",

	-- 匹配连胜
	PIPEI_LIANSHENG = "pipei_liansheng",
	-- 红包雨
	RED_ENVELOPE_RAIN_AWARD = "red_envelop_rain",

	-- 实名认证
	AUTHENTICATION_AWARD = "authentication_award",

	-- 分享拉新活动奖励
	-- fxlx_award

	--- 全返礼包3 额外赠送
	ALL_RETURN_LB_3_EXTRA_AWARD = "all_return_lb_3_extra_award",

	-- 宝箱兑换抽奖活动兑换奖励 接活动id id
	-- "box_exchange_active_award_" .. id,

    ---- 猜苹果 下注 消耗
    GUESS_BET_SPEND = "guess_bet_spend",
    ---- 猜苹果 奖励
	GUESS_APPLE_AWARD = "guess_apple_award",
	---- 猜苹果 取消下注
	GUESS_APPLE_CANCEL_BET = "guess_apple_cancel_bet",
	-- 母亲节特惠
	BUY_GIFT_BAG_MOTHER_DAY_DISCOUNT = 'buy_gift_bag_mother_day_discount',

	BUY_GIFT_BAG_IN_KIND_AWARD = 'buy_gift_bag_in_kind_award',

	NEW_YUEKA_AWARD = 'new_yueka_award',

 	--玩家修改名字
	OPENINSTALL_NAME_CHANGE = "openinstall_name_change",

	---- 赢一把就睡觉活动报名消耗
	SLEEP_ACT_SIGNUP_SPEND = "sleep_act_signup_spend",

	---- 赢一把就睡觉新活动报名消耗
	SLEEP_ACT_NEW_SIGNUP_SPEND = "sleep_act_new_signup_spend",
	---- 赢一把就睡觉新活动刷新
	SLEEP_ACT_NEW_REFRESH_SPEND = "sleep_act_new_refresh_spend",


	---- 畅玩卡 刷新任务消耗
	CHANG_WAN_KA_REFRESH_TASK_SPEND = "chang_wan_ka_refresh_task_spend",

	---- 砸金蛋欢乐活动
	HAPPY_ZAJINDAN_ACT_SPEND = "happy_zajindan_act_spend",
	HAPPY_ZAJINDAN_ACT_CLAER = "happy_zajindan_act_clear",
	
	XXL_XIYOU_GAME_SPEND = "xxl_xiyou_game_spend",

	XXL_XIYOU_GAME_AWARD = "xxl_xiyou_game_award",
	XXL_XIYOU_PROGRESS_TASK_AWARD = "xxl_xiyou_progress_task_award",



	-- 翻倍卡奖励
	-- "freestyle_fanbeika_award"

	--- 2周年纪念卡，抽奖
	JINIANKA_2_ANNIVERSARY_AWARD = "jinianka_2_anniversary_award",

	--- 通用瓜分
	COMMON_DIVIDE_AWARD = "common_divide_award",

	CAR_UPGRADE_SPEND = "car_upgrade_spend",
	CAR_UPSTAR_SPEND = "car_upstar_spend",

	EQUIPMENT_UPSTAR_SPEND = "equipment_upstar_spend",

	EQUIPMENT_RECYCLE_SPEND = "equipment_recycle_spend", -- 回收装备消耗的 金币

	OPEN_TIMER_BOX_SPEND = "open_timer_box_spend",
	OPEN_TIMER_BOX_AWARD = "open_timer_box_award",

    PVP_FIGHT_AWARD = "pvp_fight_award",
    PVP_UP_DUANWEI_AWARD = "pvp_up_duanwei_award", -- 段位升级

    PATCH_HC_CAR_SPEND = "patch_hc_car_spend" ,

}


-- 游戏类型 -> 房间服务
GAME_TYPE_ROOM =
{
	--nor_ddz_nor = "common_ddz_nor_room_service/common_ddz_nor_room_service",
	driver = "driver_room_service/driver_room_service",
}

-- 游戏类型 -> 玩家代理文件
GAME_TYPE_AGENT =
{
	--nor_ddz_nor = "player_agent/normal_ddz_nor_agent",
	driver = "player_agent/driver_game_agent",

}

GAME_AGENT_PROTO =
{
	["player_agent/driver_game_agent"] = "nor_drive_game_info"
}

-- 游戏模式 -> 配置转换文件
GAME_MODEL_CFG_TRANS =
{
	friendgame = "cfg_trans_friendgame",
	zijianfang = "cfg_trans_zijianfang",
}

-- 游戏类型 -> 配置转换文件
GAME_TYPE_CFG_TRANS =
{
	nor_mj_xzdd_er_7 = "cfg_trans_nor_mj_xzdd_er_7",
	nor_mj_xzdd = "cfg_trans_nor_mj_xzdd",
	nor_ddz_nor = "cfg_trans_nor_ddz_nor",
	nor_ddz_lz = "cfg_trans_nor_ddz_nor",
	nor_ddz_er = "cfg_trans_nor_ddz_nor",
	nor_ddz_boom = "cfg_trans_nor_ddz_nor",
	nor_pdk_nor = "cfg_trans_nor_pdk_nor",
}

GAME_TYPE_SEAT =
{
	driver = 2,	
}

GAME_TYPE_PAI_NUM =
{
	nor_mj_xzdd = 13,
	nor_mj_xzdd_er_7 = 7,
	nor_mj_xzdd_er_13 = 13,
	--[[nor_ddz_nor = 3,
	nor_ddz_lz = 3,
	nor_ddz_er = 2,--]]
}

---- 麻将牌的总数
GAME_TYPE_TOTAL_PAI_NUM =
{
	nor_mj_xzdd = 108,
	nor_mj_xzdd_er_7 = 72,
	nor_mj_xzdd_er_13 = 72,
	--[[nor_ddz_nor = 3,
	nor_ddz_lz = 3,
	nor_ddz_er = 2,--]]
}


---- 麻将斗地主类型
GAME_TYPE_TO_PLAY_TYPE =
{
	nor_mj_xzdd = "mj",
	nor_mj_xzdd_er_7 = "mj",
	nor_mj_xzdd_er_13 = "mj",
	nor_ddz_nor = "ddz",
	nor_ddz_lz = "ddz",
	nor_ddz_er = "ddz",
	nor_gobang_nor = "gobang",
	nor_ddz_boom = "ddz",
	nor_pdk_nor = "pdk",
	nor_lhd_nor = "lhd",
}



-------------------------- 任务相关
-- 任务类型枚举
TASK_TYPE_ENUM = {
	chuji_duiju_hongbao = "chuji_duiju_hongbao",
	zhongji_duiju_hongbao = "zhongji_duiju_hongbao",
	gaoji_duiju_hongbao = "gaoji_duiju_hongbao",
	jingyu_award_box = "jingyu_award_box",
	vip_duiju_hongbao_task = "vip_duiju_hongbao_task",
	vip_duiju_jingbi_task = "vip_duiju_jingbi_task",
	common_task = "common",
}

--------------------------
GAME_TAG = {
	normal = "normal",
	xsyd = "xsyd",
	vip = "vip",

	npca_win = "npca_win",
	npca_lose = "npca_lose",
}

GAME_FORM = {
	freestyle = "freestyle",
	matchstyle = "matchstyle",
}

-- 可以转换的资产类型(商城直接购买金币问题)
ASSETS_CONVERT_TYPE = {
	[PLAYER_ASSET_TYPES.JING_BI] = 1,

}


FISH_OBJ_PROP_TYPE =
{
	obj_fish_free_bullet = true,
	obj_fish_power_bullet = true,
	obj_fish_crit_bullet = true,
	obj_fish_drill_bullet = true,
	obj_fish_pierce_bullet = true,

	obj_fish_summon_fish = true,

	obj_fish_secondary_bomb = true,
	obj_fish_secondary_bolt = true,
	obj_fish_base_bomb = true,
	obj_fish_base_bolt = true,
	obj_fish_super_bomb = true,
	obj_fish_super_bolt = true,
}


FISH_PROP_PROP_TYPE =
{
	prop_fish_lock = true,
	prop_fish_frozen = true,

	prop_fish_summon_fish = true,

	prop_fish_secondary_bomb_1 = true,
	-- prop_fish_secondary_bolt_1 = true,

	prop_fish_secondary_bomb_2 = true,
	-- prop_fish_secondary_bolt_2 = true,

	prop_fish_secondary_bomb_3 = true,
	-- prop_fish_secondary_bolt_3 = true,

	prop_fish_super_bomb_1 = true,
	-- prop_fish_super_bolt_1 = true,

	prop_fish_super_bomb_2 = true,
	-- prop_fish_super_bolt_2 = true,

	prop_fish_super_bomb_3 = true,
	-- prop_fish_super_bolt_3 = true,
}


BROADCAST_LIMIT_TYPE =
{
	critical  = 1,
	major     = 2,
	minor     = 3,
}

----- vip权益的类型
VIP_RIGHTS_TYPE =
{
	every_relief_rights_1 = "every_relief_rights_1",      ---- 每日第一次转运金加成
	every_relief_rights_2 = "every_relief_rights_2",      ---- 每日第二次转运金加成
	buy_jingbi_rights = "buy_jingbi_rights",              ---- 买鲸币加成
	lucky_lottery_rights_1 = "lucky_lottery_rights_1",	      ---- 普通 幸运抽奖加成
	lucky_lottery_rights_2 = "lucky_lottery_rights_2",	      ---- 贵族 幸运抽奖加成
	lucky_lottery_rights_3 = "lucky_lottery_rights_3",	      ---- 至尊 幸运抽奖加成
}


------ 捕鱼鱼死亡时的分数处理模式
FISH_DEAL_SCORE_DEAL_MODEL = {
	normal = "normal",
	yingjin_to_money = "ranking_to_money",    ----- 赢金 转 钱
	money_to_yingjin = "money_to_yingjin",    ----- 钱   转 赢金
	only_yingjin = "only_yingjin",    ----- 只要赢金(没有赢金就把钱转换为赢金)
}


---- player_agnet的模块名对应的启动路径
PLAYER_AGENT_MODULE_PATH = {
	xiaoxiaole = "player_agent.xiaoxiaole_agent.xiaoxiaole_agent",
	jing_yu_kuai_pao = "player_agent.jing_yu_kuai_pao_agent",
	xiaoxiaole_xiyou = "player_agent.xiaoxiaole_xiyou_agent.xiaoxiaole_xiyou_agent",
	xiaoxiaole_shuihu = "player_agent.xiaoxiaole_shuihu_agent.xiaoxiaole_shuihu_agent",
	xiaoxiaole_caishen = "player_agent.xiaoxiaole_caishen_agent.xiaoxiaole_caishen_agent",
	tantanle = "player_agent.tantanle_agent.tantanle_agent",
	guess_apple = "player_agent.guess_apple_agent",
	zajindan = "player_agent.zajindan_agent",
	fishing_game = "player_agent.fishing_game",
	freestyle_game = "player_agent.freestyle_game",
	fishing_match_game = "player_agent.fishing_match_game",
	
}

---- agent游戏模块进入消息 和 游戏模块名的 对应表
PLAYER_AGENT_MODULE_ENTER = {
	xxl_enter_game = "xiaoxiaole",
	fishing_dr_enter_room = "jing_yu_kuai_pao",
	xxl_xiyou_enter_game = "xiaoxiaole_xiyou",
	xxl_shuihu_enter_game = "xiaoxiaole_shuihu",
	xxl_caishen_enter_game = "xiaoxiaole_caishen",
	tantanle_enter_game = "tantanle",
	guess_apple_enter_room = "guess_apple",
	zjd_get_game_status = "zajindan",

	fsg_signup = "fishing_game",
	fg_signup = "freestyle_game",
	fsmg_signup = "fishing_match_game",
	fsmg_match_rank_data = "fishing_match_game",

}

return {
	main=
	{
		[1]=
		{
			no = 1,
			key = "tag_new_player",
			name = "新人用户",
			condi = 1,
		},
		[2]=
		{
			no = 2,
			key = "tag_free_player",
			name = "免费用户(1~5元)",
			condi = 2,
		},
		[3]=
		{
			no = 3,
			key = "tag_stingy_player",
			name = "小额用户（6~47元）",
			condi = 3,
		},
		[4]=
		{
			no = 4,
			key = "tag_vip_low",
			name = "V1~3",
			condi = 4,
		},
		[5]=
		{
			no = 5,
			key = "tag_vip_mid",
			name = "V4~7",
			condi = 5,
		},
		[6]=
		{
			no = 6,
			key = "tag_vip_high",
			name = "V8~12",
			condi = 6,
		},
		[7]=
		{
			no = 7,
			key = "charge_rebate_for_old_player_1",
			name = "V1",
			condi = 0,
		},
		[8]=
		{
			no = 8,
			key = "charge_rebate_for_old_player_2",
			name = "V2",
			condi = 0,
		},
		[9]=
		{
			no = 9,
			key = "charge_rebate_for_old_player_3",
			name = "V3",
			condi = 0,
		},
		[10]=
		{
			no = 10,
			key = "charge_rebate_for_old_player_4",
			name = "V4",
			condi = 0,
		},
		[11]=
		{
			no = 11,
			key = "charge_rebate_for_old_player_5",
			name = "V5",
			condi = 0,
		},
		[12]=
		{
			no = 12,
			key = "charge_rebate_for_old_player_6",
			name = "V6",
			condi = 0,
		},
		[13]=
		{
			no = 13,
			key = "charge_rebate_for_old_player_7",
			name = "V7",
			condi = 0,
		},
		[14]=
		{
			no = 14,
			key = "charge_rebate_for_old_player_8",
			name = "V8",
			condi = 0,
		},
		[15]=
		{
			no = 15,
			key = "charge_rebate_for_old_player_9",
			name = "V9",
			condi = 0,
		},
		[16]=
		{
			no = 16,
			key = "charge_rebate_for_old_player_10",
			name = "V10",
			condi = 0,
		},
		[17]=
		{
			no = 17,
			key = "tag_class_new_player",
			name = "新人用户",
			condi = 1,
		},
		[18]=
		{
			no = 18,
			key = "tag_class_free_player",
			name = "免费用户(1~5元)",
			type = "charge_class",
			condi = 7,
		},
		[19]=
		{
			no = 19,
			key = "tag_class_stingy_player",
			name = "小额用户（6~47元）",
			type = "charge_class",
			condi = 8,
		},
		[20]=
		{
			no = 20,
			key = "tag_class_big_player",
			name = "大额用户（48元+）",
			type = "charge_class",
			condi = 9,
		},
		[21]=
		{
			no = 21,
			key = "2020_neibuyuangong",
			name = "竞娱内部员工名单",
			condi = 0,
		},
		[22]=
		{
			no = 22,
			key = "tag_newplayer_buy_activation_gift",
			name = "购买新人福卡6元激活礼包",
			condi = 0,
		},
	},
	condi=
	{
		[1]=
		{
			no = 1,
			id = 0,
			var = "vip_level",
			value = -1,
			judge = 4,
			group = 1,
		},
		[2]=
		{
			no = 2,
			id = 1,
			var = "acount_age",
			value = 604800,
			judge = 4,
			group = 1,
		},
		[3]=
		{
			no = 3,
			id = 2,
			var = "acount_age",
			value = 604801,
			judge = 3,
			group = 1,
		},
		[4]=
		{
			no = 4,
			id = 2,
			var = "pay_sum",
			value = 599,
			judge = 4,
			group = 1,
		},
		[5]=
		{
			no = 5,
			id = 2,
			var = "vip_level",
			value = 0,
			judge = 4,
			group = 1,
		},
		[6]=
		{
			no = 6,
			id = 3,
			var = "acount_age",
			value = 604801,
			judge = 3,
			group = 1,
		},
		[7]=
		{
			no = 7,
			id = 3,
			var = "pay_sum",
			value = 600,
			judge = 3,
			group = 1,
		},
		[8]=
		{
			no = 8,
			id = 3,
			var = "pay_sum",
			value = 4799,
			judge = 4,
			group = 1,
		},
		[9]=
		{
			no = 9,
			id = 3,
			var = "vip_level",
			value = 0,
			judge = 4,
			group = 1,
		},
		[10]=
		{
			no = 10,
			id = 4,
			var = "acount_age",
			value = 604801,
			judge = 3,
			group = 1,
		},
		[11]=
		{
			no = 11,
			id = 4,
			var = "vip_level",
			value = 1,
			judge = 3,
			group = 1,
		},
		[12]=
		{
			no = 12,
			id = 4,
			var = "vip_level",
			value = 3,
			judge = 4,
			group = 1,
		},
		[13]=
		{
			no = 13,
			id = 5,
			var = "acount_age",
			value = 604801,
			judge = 3,
			group = 1,
		},
		[14]=
		{
			no = 14,
			id = 5,
			var = "vip_level",
			value = 4,
			judge = 3,
			group = 1,
		},
		[15]=
		{
			no = 15,
			id = 5,
			var = "vip_level",
			value = 7,
			judge = 4,
			group = 1,
		},
		[16]=
		{
			no = 16,
			id = 6,
			var = "acount_age",
			value = 604801,
			judge = 3,
			group = 1,
		},
		[17]=
		{
			no = 17,
			id = 6,
			var = "vip_level",
			value = 8,
			judge = 3,
			group = 1,
		},
		[18]=
		{
			no = 18,
			id = 6,
			var = "vip_level",
			value = 12,
			judge = 4,
			group = 1,
		},
		[19]=
		{
			no = 19,
			id = 7,
			var = "pay_sum",
			value = 599,
			judge = 4,
			group = 1,
		},
		[20]=
		{
			no = 20,
			id = 8,
			var = "pay_sum",
			value = 600,
			judge = 3,
			group = 1,
		},
		[21]=
		{
			no = 21,
			id = 8,
			var = "pay_sum",
			value = 4799,
			judge = 4,
			group = 1,
		},
		[22]=
		{
			no = 22,
			id = 9,
			var = "pay_sum",
			value = 4800,
			judge = 3,
			group = 1,
		},
	},
}
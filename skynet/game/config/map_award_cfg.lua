return {
	main=
	{
		[1]=
		{
			id = 1,
			map_id = -1,
			name = "新手引导-1",
			mapAward_createInfo_cfg = "obj_createInfo_cfg_1",
			mapAward_init_rule = "init_map_res_fun_1",
			mapAward_init_cfg = "map_award_init_cfg_2",
			groupObj_gourp_cfg = "groupObj_gourp_cfg_1",
			road_refresh_event = 1,
			fix_move_list = 1,
			first_player_seat = 1,
		},
		[2]=
		{
			id = 2,
			map_id = 1,
			name = "段位赛-1",
			mapAward_createInfo_cfg = "obj_createInfo_cfg_1",
			mapAward_init_rule = "init_map_res_fun_1",
			mapAward_init_cfg = "map_award_init_cfg_1",
			groupObj_gourp_cfg = "groupObj_gourp_cfg_1",
			road_refresh_event = 1,
			tool_award_event = 1,
		},
		[3]=
		{
			id = 3,
			map_id = 2,
			name = "段位赛-2",
			mapAward_createInfo_cfg = "obj_createInfo_cfg_1",
			mapAward_init_rule = "init_map_res_fun_1",
			mapAward_init_cfg = "map_award_init_cfg_1",
			groupObj_gourp_cfg = "groupObj_gourp_cfg_1",
			road_refresh_event = 1,
			tool_award_event = 1,
		},
		[4]=
		{
			id = 4,
			map_id = 3,
			name = "段位赛-3",
			mapAward_createInfo_cfg = "obj_createInfo_cfg_1",
			mapAward_init_rule = "init_map_res_fun_1",
			mapAward_init_cfg = "map_award_init_cfg_1",
			groupObj_gourp_cfg = "groupObj_gourp_cfg_1",
			road_refresh_event = 1,
			tool_award_event = 1,
		},
		[5]=
		{
			id = 5,
			map_id = 4,
			name = "段位赛-4",
			mapAward_createInfo_cfg = "obj_createInfo_cfg_1",
			mapAward_init_rule = "init_map_res_fun_1",
			mapAward_init_cfg = "map_award_init_cfg_1",
			groupObj_gourp_cfg = "groupObj_gourp_cfg_1",
			road_refresh_event = 1,
			tool_award_event = 1,
		},
	},
	tool_award_event=
	{
		[1]=
		{
			no = 1,
			id = 1,
			event_key = "on_road_pass",
			event_data = 25,
			award_rule = 1,
			trigger_limit = 1,
		},
		[2]=
		{
			no = 2,
			id = 1,
			event_key = "on_road_pass",
			event_data = 50,
			award_rule = 1,
			trigger_limit = 1,
		},
		[3]=
		{
			no = 3,
			id = 1,
			event_key = "on_road_pass",
			event_data = 75,
			award_rule = 1,
			trigger_limit = 1,
		},
	},
	tool_award_rule=
	{
		[1]=
		{
			no = 1,
			id = 1,
			car_id = 1,
			award_num = 1,
			group_cfg_name = "award_group_1",
			group = 23,
		},
		[2]=
		{
			no = 2,
			id = 1,
			car_id = 2,
			award_num = 1,
			group_cfg_name = "award_group_1",
			group = 22,
		},
		[3]=
		{
			no = 3,
			id = 1,
			car_id = 3,
			award_num = 1,
			group_cfg_name = "award_group_1",
			group = 30,
		},
		[4]=
		{
			no = 4,
			id = 1,
			car_id = 4,
			award_num = 1,
			group_cfg_name = "award_group_1",
			group = 34,
		},
	},
	award_group_1=
	{
		[1]=
		{
			no = 1,
			name = "加攻击",
			type_id = 3,
			group_id = 1,
			weight = 18,
			max = 3,
		},
		[2]=
		{
			no = 2,
			name = "加血",
			type_id = 5,
			group_id = 1,
			weight = 18,
			max = 3,
		},
		[3]=
		{
			no = 3,
			name = "加圈数",
			type_id = 1,
			group_id = 1,
			weight = 18,
			max = 3,
		},
		[4]=
		{
			no = 4,
			name = "冲刺",
			type_id = 36,
			group_id = 1,
			weight = 30,
			max = 3,
		},
		[5]=
		{
			no = 5,
			name = "小型导弹",
			type_id = 7,
			group_id = 1,
			weight = 18,
			max = 3,
		},
		[6]=
		{
			no = 6,
			name = "2级加攻击",
			type_id = 4,
			group_id = 2,
			weight = 18,
			max = 2,
		},
		[7]=
		{
			no = 7,
			name = "2级加血",
			type_id = 6,
			group_id = 2,
			weight = 18,
			max = 2,
		},
		[8]=
		{
			no = 8,
			name = "2级加圈数",
			type_id = 2,
			group_id = 2,
			weight = 18,
			max = 2,
		},
		[9]=
		{
			no = 9,
			name = "2级小型导弹",
			type_id = 8,
			group_id = 2,
			weight = 18,
			max = 2,
		},
		[10]=
		{
			no = 10,
			name = "2级冲刺",
			type_id = 37,
			group_id = 2,
			weight = 30,
			max = 2,
		},
		[11]=
		{
			no = 11,
			name = "路障",
			type_id = 22,
			group_id = 3,
			weight = 40,
			max = 2,
		},
		[12]=
		{
			no = 12,
			name = "红绿灯",
			type_id = 61,
			group_id = 3,
			weight = 0,
			max = 2,
		},
		[13]=
		{
			no = 13,
			name = "护盾",
			type_id = 23,
			group_id = 3,
			weight = 20,
			max = 1,
		},
		[14]=
		{
			no = 14,
			name = "地雷",
			type_id = 63,
			group_id = 3,
			weight = 40,
			max = 2,
		},
		[15]=
		{
			no = 15,
			name = "红绿灯",
			type_id = 61,
			group_id = 4,
			weight = 40,
			max = 2,
		},
		[16]=
		{
			no = 16,
			name = "传送",
			type_id = 28,
			group_id = 4,
			weight = 40,
			max = 2,
		},
		[17]=
		{
			no = 17,
			name = "位置转换器",
			type_id = 45,
			group_id = 4,
			weight = 0,
			max = 1,
		},
		[18]=
		{
			no = 18,
			name = "生命转换器",
			type_id = 46,
			group_id = 4,
			weight = 0,
			max = 1,
		},
		[19]=
		{
			no = 19,
			name = "2级护盾",
			type_id = 73,
			group_id = 4,
			weight = 20,
			max = 1,
		},
		[20]=
		{
			no = 20,
			name = "gjzz_powerRocket",
			type_id = 20,
			group_id = 5,
			weight = 100,
			max = 10,
		},
		[21]=
		{
			no = 21,
			name = "chuansong_bfb",
			type_id = 64,
			group_id = 6,
			weight = 100,
			max = 10,
		},
		[22]=
		{
			no = 22,
			name = "gz_chetou_power",
			type_id = 14,
			group_id = 7,
			weight = 0,
			max = 10,
		},
		[23]=
		{
			no = 23,
			name = "gz_chetou_power",
			type_id = 15,
			group_id = 7,
			weight = 20,
			max = 10,
		},
		[24]=
		{
			no = 24,
			name = "gz_chejia_hp",
			type_id = 16,
			group_id = 7,
			weight = 0,
			max = 10,
		},
		[25]=
		{
			no = 25,
			name = "gz_chejia_hp",
			type_id = 17,
			group_id = 7,
			weight = 20,
			max = 10,
		},
		[26]=
		{
			no = 26,
			name = "gz_dongli_quanshu",
			type_id = 18,
			group_id = 7,
			weight = 0,
			max = 10,
		},
		[27]=
		{
			no = 27,
			name = "gz_dongli_quanshu",
			type_id = 19,
			group_id = 7,
			weight = 20,
			max = 10,
		},
		[28]=
		{
			no = 28,
			name = "gz_chetou_power",
			type_id = 15,
			group_id = 8,
			weight = 0,
			max = 10,
		},
		[29]=
		{
			no = 29,
			name = "gz_chejia_hp",
			type_id = 17,
			group_id = 8,
			weight = 0,
			max = 10,
		},
		[30]=
		{
			no = 30,
			name = "gz_dongli_quanshu",
			type_id = 19,
			group_id = 8,
			weight = 0,
			max = 10,
		},
		[31]=
		{
			no = 31,
			name = "灵巧装置",
			type_id = 9,
			group_id = 8,
			weight = 10,
			max = 3,
		},
		[32]=
		{
			no = 32,
			name = "高级灵巧装置",
			type_id = 10,
			group_id = 8,
			weight = 10,
			max = 3,
		},
		[33]=
		{
			no = 33,
			name = "暴击装置",
			type_id = 11,
			group_id = 8,
			weight = 10,
			max = 3,
		},
		[34]=
		{
			no = 34,
			name = "高级暴击装置",
			type_id = 12,
			group_id = 8,
			weight = 10,
			max = 3,
		},
		[35]=
		{
			no = 35,
			name = "反弹装甲",
			type_id = 34,
			group_id = 8,
			weight = 10,
			max = 3,
		},
		[36]=
		{
			no = 36,
			name = "高级反弹装甲",
			type_id = 65,
			group_id = 8,
			weight = 10,
			max = 3,
		},
		[37]=
		{
			no = 37,
			name = "坦克：子弹容量提升",
			type_id = 57,
			group_id = 9,
			weight = 50,
			max = 3,
		},
		[38]=
		{
			no = 38,
			name = "坦克：高级子弹容量提升",
			type_id = 58,
			group_id = 9,
			weight = 50,
			max = 3,
		},
		[39]=
		{
			no = 39,
			name = "坦克：炮弹强化",
			type_id = 25,
			group_id = 9,
			weight = 0,
			max = 3,
		},
		[40]=
		{
			no = 40,
			name = "坦克：高级炮弹强化",
			type_id = 67,
			group_id = 9,
			weight = 0,
			max = 3,
		},
		[41]=
		{
			no = 41,
			name = "pc_dianjuQh",
			type_id = 24,
			group_id = 10,
			weight = 50,
			max = 6,
		},
		[42]=
		{
			no = 42,
			name = "gj_pc_dianjuQh",
			type_id = 66,
			group_id = 10,
			weight = 50,
			max = 6,
		},
		[43]=
		{
			no = 43,
			name = "平头哥-最大储能增加",
			type_id = 87,
			group_id = 27,
			weight = 50,
			max = 10,
		},
		[44]=
		{
			no = 44,
			name = "平头哥-最大储能增加",
			type_id = 88,
			group_id = 27,
			weight = 50,
			max = 10,
		},
		[45]=
		{
			no = 45,
			name = "安装车-地雷扩容",
			type_id = 94,
			group_id = 31,
			weight = 33,
			max = 10,
		},
		[46]=
		{
			no = 46,
			name = "安装车-地雷扩容",
			type_id = 95,
			group_id = 31,
			weight = 33,
			max = 10,
		},
		[47]=
		{
			no = 47,
			name = "hjzz_night",
			type_id = 26,
			group_id = 11,
			weight = 33,
			max = 10,
		},
		[48]=
		{
			no = 48,
			name = "hjzz_rain",
			type_id = 44,
			group_id = 11,
			weight = 33,
			max = 10,
		},
		[49]=
		{
			no = 49,
			name = "正常天气",
			type_id = 52,
			group_id = 11,
			weight = 0,
			max = 1,
		},
		[50]=
		{
			no = 50,
			name = "恢复天使",
			type_id = 59,
			group_id = 12,
			weight = 60,
			max = 10,
		},
		[51]=
		{
			no = 51,
			name = "清障铲",
			type_id = 54,
			group_id = 12,
			weight = 0,
			max = 10,
		},
		[52]=
		{
			no = 52,
			name = "生命克隆",
			type_id = 60,
			group_id = 12,
			weight = 40,
			max = 10,
		},
		[53]=
		{
			no = 53,
			name = "禁停标志",
			type_id = 32,
			group_id = 13,
			weight = 50,
			max = 10,
		},
		[54]=
		{
			no = 54,
			name = "nixiang_driver",
			type_id = 33,
			group_id = 13,
			weight = 50,
			max = 10,
		},
		[55]=
		{
			no = 55,
			name = "维修工具",
			type_id = 29,
			group_id = 14,
			weight = 50,
			max = 10,
		},
		[56]=
		{
			no = 56,
			name = "维修工具",
			type_id = 68,
			group_id = 14,
			weight = 50,
			max = 10,
		},
		[57]=
		{
			no = 57,
			name = "路障",
			type_id = 22,
			group_id = 15,
			weight = 0,
			max = 0,
		},
		[58]=
		{
			no = 58,
			name = "红绿灯",
			type_id = 61,
			group_id = 15,
			weight = 0,
			max = 10,
		},
		[59]=
		{
			no = 59,
			name = "地雷",
			type_id = 63,
			group_id = 15,
			weight = 0,
			max = 10,
		},
		[60]=
		{
			no = 60,
			name = "位置转换器",
			type_id = 45,
			group_id = 15,
			weight = 0,
			max = 10,
		},
		[61]=
		{
			no = 61,
			name = "生命转换器",
			type_id = 46,
			group_id = 15,
			weight = 0,
			max = 10,
		},
		[62]=
		{
			no = 62,
			name = "传送",
			type_id = 28,
			group_id = 15,
			weight = 100,
			max = 10,
		},
		[63]=
		{
			no = 63,
			name = "跑车-能量储备",
			type_id = 72,
			group_id = 16,
			weight = 50,
			max = 100,
		},
		[64]=
		{
			no = 64,
			name = "坦克:资源补充（子弹补满）",
			type_id = 69,
			group_id = 17,
			weight = 100,
			max = 100,
		},
		[65]=
		{
			no = 65,
			name = "追尾车-储能补充",
			type_id = 86,
			group_id = 28,
			weight = 100,
			max = 10,
		},
		[66]=
		{
			no = 66,
			name = "安装车-地雷补充",
			type_id = 96,
			group_id = 32,
			weight = 100,
			max = 10,
		},
		[67]=
		{
			no = 67,
			name = "双倍奖励",
			type_id = 70,
			group_id = 20,
			weight = 20,
			max = 1,
		},
		[68]=
		{
			no = 68,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 20,
			weight = 20,
			max = 1,
		},
		[69]=
		{
			no = 69,
			name = "连击",
			type_id = 13,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[70]=
		{
			no = 70,
			name = "路障",
			type_id = 22,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[71]=
		{
			no = 71,
			name = "红绿灯",
			type_id = 61,
			group_id = 20,
			weight = 5,
			max = 1,
		},
		[72]=
		{
			no = 72,
			name = "传送",
			type_id = 28,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[73]=
		{
			no = 73,
			name = "导航器",
			type_id = 62,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[74]=
		{
			no = 74,
			name = "护盾",
			type_id = 23,
			group_id = 20,
			weight = 0,
			max = 1,
		},
		[75]=
		{
			no = 75,
			name = "2级护盾",
			type_id = 73,
			group_id = 20,
			weight = 0,
			max = 1,
		},
		[76]=
		{
			no = 76,
			name = "地雷",
			type_id = 63,
			group_id = 20,
			weight = 5,
			max = 1,
		},
		[77]=
		{
			no = 77,
			name = "超能",
			type_id = 30,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[78]=
		{
			no = 78,
			name = "位置转换器",
			type_id = 45,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[79]=
		{
			no = 79,
			name = "生命转换器",
			type_id = 46,
			group_id = 20,
			weight = 10,
			max = 1,
		},
		[80]=
		{
			no = 80,
			name = "能量储备",
			type_id = 72,
			group_id = 20,
			weight = 20,
			max = 1,
		},
		[81]=
		{
			no = 81,
			name = "双倍奖励",
			type_id = 70,
			group_id = 21,
			weight = 20,
			max = 1,
		},
		[82]=
		{
			no = 82,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 21,
			weight = 20,
			max = 1,
		},
		[83]=
		{
			no = 83,
			name = "连击",
			type_id = 13,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[84]=
		{
			no = 84,
			name = "路障",
			type_id = 22,
			group_id = 21,
			weight = 5,
			max = 1,
		},
		[85]=
		{
			no = 85,
			name = "红绿灯",
			type_id = 61,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[86]=
		{
			no = 86,
			name = "传送",
			type_id = 28,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[87]=
		{
			no = 87,
			name = "导航器",
			type_id = 62,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[88]=
		{
			no = 88,
			name = "护盾",
			type_id = 23,
			group_id = 21,
			weight = 0,
			max = 1,
		},
		[89]=
		{
			no = 89,
			name = "2级护盾",
			type_id = 73,
			group_id = 21,
			weight = 0,
			max = 1,
		},
		[90]=
		{
			no = 90,
			name = "地雷",
			type_id = 63,
			group_id = 21,
			weight = 5,
			max = 1,
		},
		[91]=
		{
			no = 91,
			name = "超能",
			type_id = 30,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[92]=
		{
			no = 92,
			name = "位置转换器",
			type_id = 45,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[93]=
		{
			no = 93,
			name = "生命转换器",
			type_id = 46,
			group_id = 21,
			weight = 10,
			max = 1,
		},
		[94]=
		{
			no = 94,
			name = "坦克:资源补充（子弹补满）",
			type_id = 69,
			group_id = 21,
			weight = 20,
			max = 1,
		},
		[95]=
		{
			no = 95,
			name = "双倍奖励",
			type_id = 70,
			group_id = 29,
			weight = 20,
			max = 1,
		},
		[96]=
		{
			no = 96,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 29,
			weight = 20,
			max = 1,
		},
		[97]=
		{
			no = 97,
			name = "连击",
			type_id = 13,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[98]=
		{
			no = 98,
			name = "路障",
			type_id = 22,
			group_id = 29,
			weight = 5,
			max = 1,
		},
		[99]=
		{
			no = 99,
			name = "红绿灯",
			type_id = 61,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[100]=
		{
			no = 100,
			name = "传送",
			type_id = 28,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[101]=
		{
			no = 101,
			name = "导航器",
			type_id = 62,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[102]=
		{
			no = 102,
			name = "护盾",
			type_id = 23,
			group_id = 29,
			weight = 0,
			max = 1,
		},
		[103]=
		{
			no = 103,
			name = "2级护盾",
			type_id = 73,
			group_id = 29,
			weight = 0,
			max = 1,
		},
		[104]=
		{
			no = 104,
			name = "地雷",
			type_id = 63,
			group_id = 29,
			weight = 5,
			max = 1,
		},
		[105]=
		{
			no = 105,
			name = "超能",
			type_id = 30,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[106]=
		{
			no = 106,
			name = "位置转换器",
			type_id = 45,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[107]=
		{
			no = 107,
			name = "生命转换器",
			type_id = 46,
			group_id = 29,
			weight = 10,
			max = 1,
		},
		[108]=
		{
			no = 108,
			name = "追尾车-储能补充",
			type_id = 86,
			group_id = 29,
			weight = 20,
			max = 1,
		},
		[109]=
		{
			no = 109,
			name = "双倍奖励",
			type_id = 70,
			group_id = 33,
			weight = 20,
			max = 1,
		},
		[110]=
		{
			no = 110,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 33,
			weight = 20,
			max = 1,
		},
		[111]=
		{
			no = 111,
			name = "连击",
			type_id = 13,
			group_id = 33,
			weight = 0,
			max = 1,
		},
		[112]=
		{
			no = 112,
			name = "路障",
			type_id = 22,
			group_id = 33,
			weight = 5,
			max = 1,
		},
		[113]=
		{
			no = 113,
			name = "红绿灯",
			type_id = 61,
			group_id = 33,
			weight = 10,
			max = 1,
		},
		[114]=
		{
			no = 114,
			name = "传送",
			type_id = 28,
			group_id = 33,
			weight = 10,
			max = 1,
		},
		[115]=
		{
			no = 115,
			name = "导航器",
			type_id = 62,
			group_id = 33,
			weight = 10,
			max = 1,
		},
		[116]=
		{
			no = 116,
			name = "护盾",
			type_id = 23,
			group_id = 33,
			weight = 0,
			max = 1,
		},
		[117]=
		{
			no = 117,
			name = "2级护盾",
			type_id = 73,
			group_id = 33,
			weight = 0,
			max = 1,
		},
		[118]=
		{
			no = 118,
			name = "地雷",
			type_id = 63,
			group_id = 33,
			weight = 5,
			max = 1,
		},
		[119]=
		{
			no = 119,
			name = "超能",
			type_id = 30,
			group_id = 33,
			weight = 10,
			max = 1,
		},
		[120]=
		{
			no = 120,
			name = "位置转换器",
			type_id = 45,
			group_id = 33,
			weight = 10,
			max = 1,
		},
		[121]=
		{
			no = 121,
			name = "生命转换器",
			type_id = 46,
			group_id = 33,
			weight = 10,
			max = 1,
		},
		[122]=
		{
			no = 122,
			name = "安装车-地雷补充",
			type_id = 96,
			group_id = 33,
			weight = 20,
			max = 1,
		},
		[123]=
		{
			no = 123,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[124]=
		{
			no = 124,
			name = "路障",
			type_id = 22,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[125]=
		{
			no = 125,
			name = "红绿灯",
			type_id = 61,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[126]=
		{
			no = 126,
			name = "传送",
			type_id = 28,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[127]=
		{
			no = 127,
			name = "导航器",
			type_id = 62,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[128]=
		{
			no = 128,
			name = "护盾",
			type_id = 23,
			group_id = 22,
			weight = 5,
			max = 1,
		},
		[129]=
		{
			no = 129,
			name = "2级护盾",
			type_id = 73,
			group_id = 22,
			weight = 5,
			max = 1,
		},
		[130]=
		{
			no = 130,
			name = "地雷",
			type_id = 63,
			group_id = 22,
			weight = 5,
			max = 1,
		},
		[131]=
		{
			no = 131,
			name = "超能",
			type_id = 30,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[132]=
		{
			no = 132,
			name = "位置转换器",
			type_id = 45,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[133]=
		{
			no = 133,
			name = "生命转换器",
			type_id = 46,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[134]=
		{
			no = 134,
			name = "连击装置",
			type_id = 13,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[135]=
		{
			no = 135,
			name = "双倍奖励",
			type_id = 70,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[136]=
		{
			no = 136,
			name = "坦克:资源补充（子弹补满）",
			type_id = 69,
			group_id = 22,
			weight = 10,
			max = 1,
		},
		[137]=
		{
			no = 137,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[138]=
		{
			no = 138,
			name = "路障",
			type_id = 22,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[139]=
		{
			no = 139,
			name = "红绿灯",
			type_id = 61,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[140]=
		{
			no = 140,
			name = "传送",
			type_id = 28,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[141]=
		{
			no = 141,
			name = "导航器",
			type_id = 62,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[142]=
		{
			no = 142,
			name = "护盾",
			type_id = 23,
			group_id = 23,
			weight = 5,
			max = 1,
		},
		[143]=
		{
			no = 143,
			name = "2级护盾",
			type_id = 73,
			group_id = 23,
			weight = 5,
			max = 1,
		},
		[144]=
		{
			no = 144,
			name = "地雷",
			type_id = 63,
			group_id = 23,
			weight = 5,
			max = 1,
		},
		[145]=
		{
			no = 145,
			name = "超能",
			type_id = 30,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[146]=
		{
			no = 146,
			name = "位置转换器",
			type_id = 45,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[147]=
		{
			no = 147,
			name = "生命转换器",
			type_id = 46,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[148]=
		{
			no = 148,
			name = "连击装置",
			type_id = 13,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[149]=
		{
			no = 149,
			name = "双倍奖励",
			type_id = 70,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[150]=
		{
			no = 150,
			name = "能量储备",
			type_id = 72,
			group_id = 23,
			weight = 10,
			max = 1,
		},
		[151]=
		{
			no = 151,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[152]=
		{
			no = 152,
			name = "路障",
			type_id = 22,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[153]=
		{
			no = 153,
			name = "红绿灯",
			type_id = 61,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[154]=
		{
			no = 154,
			name = "传送",
			type_id = 28,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[155]=
		{
			no = 155,
			name = "导航器",
			type_id = 62,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[156]=
		{
			no = 156,
			name = "护盾",
			type_id = 23,
			group_id = 30,
			weight = 5,
			max = 1,
		},
		[157]=
		{
			no = 157,
			name = "2级护盾",
			type_id = 73,
			group_id = 30,
			weight = 5,
			max = 1,
		},
		[158]=
		{
			no = 158,
			name = "地雷",
			type_id = 63,
			group_id = 30,
			weight = 5,
			max = 1,
		},
		[159]=
		{
			no = 159,
			name = "超能",
			type_id = 30,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[160]=
		{
			no = 160,
			name = "位置转换器",
			type_id = 45,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[161]=
		{
			no = 161,
			name = "生命转换器",
			type_id = 46,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[162]=
		{
			no = 162,
			name = "连击装置",
			type_id = 13,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[163]=
		{
			no = 163,
			name = "双倍奖励",
			type_id = 70,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[164]=
		{
			no = 164,
			name = "追尾车-储能补充",
			type_id = 86,
			group_id = 30,
			weight = 10,
			max = 1,
		},
		[165]=
		{
			no = 165,
			name = "单个双倍奖励",
			type_id = 85,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[166]=
		{
			no = 166,
			name = "路障",
			type_id = 22,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[167]=
		{
			no = 167,
			name = "红绿灯",
			type_id = 61,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[168]=
		{
			no = 168,
			name = "传送",
			type_id = 28,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[169]=
		{
			no = 169,
			name = "导航器",
			type_id = 62,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[170]=
		{
			no = 170,
			name = "护盾",
			type_id = 23,
			group_id = 34,
			weight = 5,
			max = 1,
		},
		[171]=
		{
			no = 171,
			name = "2级护盾",
			type_id = 73,
			group_id = 34,
			weight = 5,
			max = 1,
		},
		[172]=
		{
			no = 172,
			name = "地雷",
			type_id = 63,
			group_id = 34,
			weight = 5,
			max = 1,
		},
		[173]=
		{
			no = 173,
			name = "超能",
			type_id = 30,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[174]=
		{
			no = 174,
			name = "位置转换器",
			type_id = 45,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[175]=
		{
			no = 175,
			name = "生命转换器",
			type_id = 46,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[176]=
		{
			no = 176,
			name = "连击装置",
			type_id = 13,
			group_id = 34,
			weight = 0,
			max = 1,
		},
		[177]=
		{
			no = 177,
			name = "双倍奖励",
			type_id = 70,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[178]=
		{
			no = 178,
			name = "安装车-地雷补充",
			type_id = 96,
			group_id = 34,
			weight = 10,
			max = 1,
		},
		[179]=
		{
			no = 179,
			name = "法拉利车升级",
			type_id = 83,
			group_id = 24,
			weight = 10,
			max = 10,
		},
		[180]=
		{
			no = 180,
			name = "坦克-车升级",
			type_id = 84,
			group_id = 25,
			weight = 10,
			max = 10,
		},
		[181]=
		{
			no = 181,
			name = "追尾车-车升级",
			type_id = 89,
			group_id = 26,
			weight = 10,
			max = 10,
		},
		[182]=
		{
			no = 182,
			name = "安装车-车升级",
			type_id = 98,
			group_id = 35,
			weight = 10,
			max = 10,
		},
	},
	groupObj_gourp_cfg_1=
	{
		[1]=
		{
			no = 1,
			type_id = 47,
			car_id = 1,
			name = "起点",
			group_cfg_name = "award_group_1",
			group = {14,15,16},
		},
		[2]=
		{
			no = 2,
			type_id = 47,
			car_id = 2,
			name = "起点",
			group_cfg_name = "award_group_1",
			group = {14,15,17},
		},
		[3]=
		{
			no = 3,
			type_id = 47,
			car_id = 3,
			name = "起点",
			group_cfg_name = "award_group_1",
			group = {14,15,28},
		},
		[4]=
		{
			no = 4,
			type_id = 47,
			car_id = 4,
			name = "起点",
			group_cfg_name = "award_group_1",
			group = {14,15,32},
		},
		[5]=
		{
			no = 5,
			type_id = 48,
			car_id = 1,
			name = "攻击中心",
			group_cfg_name = "award_group_1",
			group = {5,6},
		},
		[6]=
		{
			no = 6,
			type_id = 48,
			car_id = 2,
			name = "攻击中心",
			group_cfg_name = "award_group_1",
			group = {5,6},
		},
		[7]=
		{
			no = 7,
			type_id = 48,
			car_id = 3,
			name = "攻击中心",
			group_cfg_name = "award_group_1",
			group = {5,6},
		},
		[8]=
		{
			no = 8,
			type_id = 48,
			car_id = 4,
			name = "攻击中心",
			group_cfg_name = "award_group_1",
			group = {5,6},
		},
		[9]=
		{
			no = 9,
			type_id = 50,
			car_id = 1,
			name = "改装中心",
			group_cfg_name = "award_group_1",
			group = {7,8,10},
		},
		[10]=
		{
			no = 10,
			type_id = 50,
			car_id = 2,
			name = "改装中心",
			group_cfg_name = "award_group_1",
			group = {7,8,9},
		},
		[11]=
		{
			no = 11,
			type_id = 50,
			car_id = 3,
			name = "改装中心",
			group_cfg_name = "award_group_1",
			group = {7,8,27},
		},
		[12]=
		{
			no = 12,
			type_id = 50,
			car_id = 4,
			name = "改装中心",
			group_cfg_name = "award_group_1",
			group = {7,8,31},
		},
		[13]=
		{
			no = 13,
			type_id = 51,
			car_id = 1,
			name = "雷达中心",
			group_cfg_name = "award_group_1",
			group = {11,12,13},
		},
		[14]=
		{
			no = 14,
			type_id = 51,
			car_id = 2,
			name = "雷达中心",
			group_cfg_name = "award_group_1",
			group = {11,12,13},
		},
		[15]=
		{
			no = 15,
			type_id = 51,
			car_id = 3,
			name = "雷达中心",
			group_cfg_name = "award_group_1",
			group = {11,12,13},
		},
		[16]=
		{
			no = 16,
			type_id = 51,
			car_id = 4,
			name = "雷达中心",
			group_cfg_name = "award_group_1",
			group = {11,12,13},
		},
		[17]=
		{
			no = 17,
			type_id = 55,
			car_id = 1,
			name = "道具箱",
			group_cfg_name = "award_group_1",
			group = 20,
		},
		[18]=
		{
			no = 18,
			type_id = 55,
			car_id = 2,
			name = "道具箱",
			group_cfg_name = "award_group_1",
			group = 21,
		},
		[19]=
		{
			no = 19,
			type_id = 55,
			car_id = 3,
			name = "道具箱",
			group_cfg_name = "award_group_1",
			group = 29,
		},
		[20]=
		{
			no = 20,
			type_id = 55,
			car_id = 4,
			name = "道具箱",
			group_cfg_name = "award_group_1",
			group = 33,
		},
		[21]=
		{
			no = 21,
			type_id = 56,
			car_id = 1,
			name = "车辆升级",
			group_cfg_name = "award_group_1",
			group = 24,
		},
		[22]=
		{
			no = 22,
			type_id = 56,
			car_id = 2,
			name = "车辆升级",
			group_cfg_name = "award_group_1",
			group = 25,
		},
		[23]=
		{
			no = 23,
			type_id = 56,
			car_id = 3,
			name = "车辆升级",
			group_cfg_name = "award_group_1",
			group = 26,
		},
		[24]=
		{
			no = 24,
			type_id = 56,
			car_id = 4,
			name = "车辆升级",
			group_cfg_name = "award_group_1",
			group = 35,
		},
	},
	mapAward_refresh_cfg_1=
	{
		[1]=
		{
			no = 1,
			name = "基础属性组合",
			group_cfg_name = "award_group_1",
			group_id = 1,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 2,
			high_num = 4,
			max = 5,
		},
		[2]=
		{
			no = 2,
			name = "高级基础组合",
			group_cfg_name = "award_group_1",
			group_id = 2,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 2,
			high_num = 4,
			max = 3,
		},
		[3]=
		{
			no = 3,
			name = "功能性道具组合",
			group_cfg_name = "award_group_1",
			group_id = 3,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 2,
			high_num = 3,
			max = 3,
		},
		[4]=
		{
			no = 4,
			name = "高能道具",
			group_cfg_name = "award_group_1",
			group_id = 4,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 1,
			high_num = 2,
			max = 3,
		},
		[5]=
		{
			no = 5,
			name = "再来一次",
			type_id = 53,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 1,
			high_num = 2,
			max = 3,
		},
		[6]=
		{
			no = 6,
			name = "道具箱",
			type_id = 55,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 2,
			high_num = 3,
			max = 4,
		},
		[7]=
		{
			no = 7,
			name = "车升级",
			type_id = 56,
			nor_weight = 15,
			low_weight = 30,
			high_weight = 5,
			low_num = 2,
			high_num = 3,
			max = 3,
		},
	},
	map_award_init_cfg_1=
	{
		[1]=
		{
			no = 1,
			name = "基础属性组合",
			min = 3,
			max = 5,
			group_cfg_name = "award_group_1",
			group = 1,
			weight = 15,
		},
		[2]=
		{
			no = 2,
			name = "高级基础组合",
			min = 2,
			max = 3,
			group_cfg_name = "award_group_1",
			group = 2,
			weight = 15,
		},
		[3]=
		{
			no = 3,
			name = "功能性道具组合",
			min = 1,
			max = 2,
			group_cfg_name = "award_group_1",
			group = 3,
			weight = 15,
		},
		[4]=
		{
			no = 4,
			name = "高能道具",
			min = 1,
			max = 2,
			group_cfg_name = "award_group_1",
			group = 4,
			weight = 15,
		},
		[5]=
		{
			no = 5,
			name = "再来一次",
			type_id = 53,
			min = 1,
			max = 2,
			weight = 15,
		},
		[6]=
		{
			no = 6,
			name = "道具箱",
			type_id = 55,
			min = 2,
			max = 3,
			weight = 15,
		},
		[7]=
		{
			no = 7,
			name = "车升级",
			type_id = 56,
			min = 1,
			max = 2,
			weight = 15,
		},
	},
	map_award_init_cfg_2=
	{
		[1]=
		{
			no = 1,
			name = "基础属性组合",
			min = 1,
			max = 5,
			group_cfg_name = "award_group_1",
			group = 1,
			weight = 15,
		},
		[2]=
		{
			no = 2,
			name = "高级基础组合",
			min = 1,
			max = 3,
			group_cfg_name = "award_group_1",
			group = 2,
			weight = 15,
		},
		[3]=
		{
			no = 3,
			name = "功能性道具组合",
			min = 1,
			max = 2,
			group_cfg_name = "award_group_1",
			group = 3,
			weight = 15,
		},
		[4]=
		{
			no = 4,
			name = "高能道具",
			min = 1,
			max = 2,
			group_cfg_name = "award_group_1",
			group = 4,
			weight = 15,
		},
		[5]=
		{
			no = 5,
			name = "再来一次",
			type_id = 53,
			min = 1,
			max = 2,
			weight = 15,
		},
		[6]=
		{
			no = 6,
			name = "道具箱",
			type_id = 55,
			min = 1,
			max = 3,
			weight = 15,
		},
		[7]=
		{
			no = 7,
			name = "车升级",
			type_id = 56,
			min = 2,
			max = 2,
			weight = 15,
		},
		[8]=
		{
			no = 8,
			name = "加攻击",
			type_id = 4,
			min = 1,
			max = 1,
			road_id = 5,
		},
		[9]=
		{
			no = 9,
			name = "车辆升级",
			type_id = 56,
			min = 1,
			max = 1,
			road_id = 14,
		},
		[10]=
		{
			no = 10,
			name = "冲刺",
			type_id = 37,
			min = 1,
			max = 1,
			road_id = 13,
		},
		[11]=
		{
			no = 11,
			name = "冲刺",
			type_id = 37,
			min = 1,
			max = 1,
			road_id = 16,
		},
	},
	obj_createInfo_cfg_1=
	{
		[47]=
		{
			type_id = 47,
			name = "起点",
			create_type = "skill",
			choose_type = "3_c_1_fl",
			award_create_rule = "zjUse_Nc1_by_item_refresh",
			context_type = "skill",
		},
		[48]=
		{
			type_id = 48,
			name = "攻击中心",
			create_type = "skill",
			choose_type = "2_c_1_fl",
			award_create_rule = "zjUse_Nc1_by_item_refresh",
			context_type = "skill",
		},
		[50]=
		{
			type_id = 50,
			name = "改装中心",
			create_type = "skill",
			choose_type = "3_c_1_fl",
			award_create_rule = "zjUse_Nc1_by_item_refresh",
			context_type = "skill",
		},
		[51]=
		{
			type_id = 51,
			name = "雷达中心",
			create_type = "skill",
			choose_type = "3_c_1_fl",
			award_create_rule = "huanjingCenter_refresh",
			context_type = "skill",
		},
		[55]=
		{
			type_id = 55,
			name = "道具箱",
			create_type = "skill",
			choose_type = "random",
			award_create_rule = "daojuxiang_refresh",
			context_type = "prop",
		},
		[56]=
		{
			type_id = 56,
			name = "车辆升级",
			create_type = "skill",
			choose_type = "random",
			award_create_rule = "cheshenji_refresh",
			context_type = "skill",
		},
	},
	road_refresh_event=
	{
		[1]=
		{
			no = 1,
			id = 1,
			event_key = "round_delay",
			event_data = 1,
			refresh_type = "fill_empty",
			refresh_num = 1,
			mapAward_refresh_rule = "mapAward_refresh_fun_1",
			mapAward_refresh_cfg = "mapAward_refresh_cfg_1",
		},
	},
	fix_move_list=
	{
		[1]=
		{
			no = 1,
			id = 1,
			move_step = 4,
		},
		[2]=
		{
			no = 2,
			id = 1,
			move_step = 14,
			youmen_type = "big",
		},
		[3]=
		{
			no = 3,
			id = 1,
			move_step = 5,
		},
		[4]=
		{
			no = 4,
			id = 1,
			move_step = 3,
		},
		[5]=
		{
			no = 5,
			id = 1,
			move_step = 3,
		},
	},
}
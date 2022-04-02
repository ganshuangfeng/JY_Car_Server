return {
	main=
	{
		[1]=
		{
			id = 1,
			enable = 1,
			rank_type = "pvp_jing_biao_sai_rank_1",
			name = "pvp竞标赛排行榜1期",
			begin_time = 1623121512,
			end_time = 1629388800,
			data_deal_type = "nor_set",
			data_save_type = "single",
			score_source = 1,
			show_model = 1,
			settle_model = 1,
		},
	},
	score_source=
	{
		[1]=
		{
			id = 1,
			source_id = 1,
			source_type = "pvp_jifen_award",
		},
	},
	source_condition=
	{
	},
	join_condition=
	{
		[1]=
		{
			id = 1,
			condition_id = 1,
			condition_name = "is_new_player",
			condition_value = 1,
			judge_type = 2,
		},
		[2]=
		{
			id = 2,
			condition_id = 1,
			condition_name = "vip_level",
			condition_value = 1,
			judge_type = 3,
		},
		[3]=
		{
			id = 3,
			condition_id = 2,
			condition_name = "player_id",
			condition_value = 0,
			judge_type = 4,
		},
	},
	show_model=
	{
		[1]=
		{
			id = 1,
			show_limit = 10000,
			max_show_num = 100,
			max_rank_num = 300,
			max_award_num = 100,
			show_refresh_delay = 180,
			show_refresh_self_delay = 10,
		},
	},
	settle_model=
	{
		[1]=
		{
			id = 1,
			settle_time_model = 5,
			is_clear = 0,
			award_model = 1,
		},
	},
	settle_time_model=
	{
		[1]=
		{
			id = 1,
			reset_type = "day",
			reset_value = 1,
		},
		[2]=
		{
			id = 2,
			reset_type = "second",
			reset_value = 86400,
		},
		[3]=
		{
			id = 3,
			reset_type = "week",
			reset_value = 1,
		},
		[4]=
		{
			id = 4,
			reset_type = "month",
			reset_value = 1,
		},
		[5]=
		{
			id = 5,
			reset_type = "fix_time",
			reset_value = 1629388800,
		},
	},
	award_model=
	{
		[1]=
		{
			id = 1,
			model_id = 2,
			start_rank = 1,
			end_rank = 1,
			award_id = 1,
			award_type = "nor",
		},
		[2]=
		{
			id = 2,
			model_id = 2,
			start_rank = 2,
			end_rank = 10,
			award_id = 2,
			award_type = "nor",
		},
		[3]=
		{
			id = 3,
			model_id = 2,
			start_rank = 11,
			end_rank = 20,
			award_id = 3,
			award_type = "nor",
		},
		[4]=
		{
			id = 4,
			model_id = 2,
			start_rank = 21,
			end_rank = 50,
			award_id = 4,
			award_type = "nor",
		},
		[5]=
		{
			id = 5,
			model_id = 2,
			start_rank = 51,
			end_rank = 100,
			award_id = 5,
			award_type = "nor",
		},
	},
	awards=
	{
		[1]=
		{
			id = 1,
			award_id = 1,
			award_name = "10000福卡",
			asset_type = "shop_gold_sum",
			asset_count = 1000000,
			get_weight = 1,
		},
	},
}
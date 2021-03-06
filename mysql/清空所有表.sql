-- 生成表清单
SELECT  concat('TRUNCATE table ',table_name,'; ')  FROM information_schema.tables 
WHERE table_schema = '数据库名'  AND table_type = 'base table'
order by table_name

-- 当前表清单
TRUNCATE table activity_cumulate_data; 
TRUNCATE table admin_decrease_asset_log; 
TRUNCATE table admin_op_log; 
TRUNCATE table bind_phone_number; 
TRUNCATE table bind_phone_number_opt_log; 
TRUNCATE table dwq_cdkey; 
TRUNCATE table dwq_cdkey_use_log; 
TRUNCATE table dwq_use_log; 
TRUNCATE table emails; 
TRUNCATE table emails_admin_opt_log; 
TRUNCATE table emails_log; 
TRUNCATE table emails_opt_log; 
TRUNCATE table freestyle_nmjxl_race_log; 
TRUNCATE table freestyle_nmjxl_race_player_log; 
TRUNCATE table freestyle_race_log; 
TRUNCATE table freestyle_race_player_log; 
TRUNCATE table freestyle_tyddz_race_log; 
TRUNCATE table freestyle_tyddz_race_player_log; 
TRUNCATE table friendgame_history_record; 
TRUNCATE table friendgame_player_history; 
TRUNCATE table friendgame_room_log; 
TRUNCATE table friendgame_room_race_log; 
TRUNCATE table game_profit; 
TRUNCATE table game_profit_statistics; 
TRUNCATE table gift_bag_data; 
TRUNCATE table goods_exchange_log; 
TRUNCATE table load_and_close_ser_cfg; 
TRUNCATE table match_nor_log; 
TRUNCATE table match_nor_player_log; 
TRUNCATE table million_ddz_bonus_week; 
TRUNCATE table million_ddz_log; 
TRUNCATE table million_ddz_player_log; 
TRUNCATE table million_ddz_race_log; 
TRUNCATE table million_ddz_race_player_log; 
TRUNCATE table million_ddz_shared_status; 
TRUNCATE table naming_match_rank; 
TRUNCATE table nor_ddz_nor_race_log; 
TRUNCATE table nor_ddz_nor_race_player_log; 
TRUNCATE table nor_mj_xzdd_race_log; 
TRUNCATE table nor_mj_xzdd_race_player_log; 
TRUNCATE table player_asset; 
TRUNCATE table player_asset_log; 
TRUNCATE table player_asset_refund; 
TRUNCATE table player_block_status; 
TRUNCATE table player_block_status_log; 
TRUNCATE table player_broke_subsidy; 
TRUNCATE table player_change_type_refund; 
TRUNCATE table player_consume_statistics; 
TRUNCATE table player_device_info; 
TRUNCATE table player_dressed; 
TRUNCATE table player_dress_info; 
TRUNCATE table player_dress_info_log; 
TRUNCATE table player_duiju_hongbao_award; 
TRUNCATE table player_everyday_shared_status; 
TRUNCATE table player_gift_bag_status; 
TRUNCATE table player_glory; 
TRUNCATE table player_goldpig_info; 
TRUNCATE table player_info; 
TRUNCATE table player_ji_pai_qi; 
TRUNCATE table player_ji_pai_qi_log; 
TRUNCATE table player_login; 
TRUNCATE table player_login_log; 
TRUNCATE table player_login_stat; 
TRUNCATE table player_lottery; 
TRUNCATE table player_merchant_order; 
TRUNCATE table player_other_base_info; 
TRUNCATE table player_other_base_info_change_log; 
TRUNCATE table player_pay_order; 
TRUNCATE table player_pay_order_detail; 
TRUNCATE table player_pay_order_detail_log; 
TRUNCATE table player_pay_order_log; 
TRUNCATE table player_pay_order_stat; 
TRUNCATE table player_prop; 
TRUNCATE table player_prop_log; 
TRUNCATE table player_prop_refund; 
TRUNCATE table player_register; 
TRUNCATE table player_shop_order; 
TRUNCATE table player_shop_order_log; 
TRUNCATE table player_stepstep_money; 
TRUNCATE table player_task; 
TRUNCATE table player_task_log; 
TRUNCATE table player_verify; 
TRUNCATE table player_vip; 
TRUNCATE table player_vip_buy_record; 
TRUNCATE table player_vip_generalize; 
TRUNCATE table player_vip_generalize_extract_record; 
TRUNCATE table player_vip_reward_task; 
TRUNCATE table player_vip_reward_task_record; 
TRUNCATE table player_withdraw; 
TRUNCATE table player_withdraw_log; 
TRUNCATE table player_xsyd_status; 
TRUNCATE table player_zajindan_info; 
TRUNCATE table player_zajindan_log; 
TRUNCATE table player_zajindan_round_log; 
TRUNCATE table prop_type; 
TRUNCATE table real_name_authentication; 
TRUNCATE table redeem_code_log; 
TRUNCATE table sczd_activity_info; 
TRUNCATE table sczd_gjhhr_info; 
TRUNCATE table sczd_gjhhr_info_change_log; 
TRUNCATE table sczd_gjhhr_settle_log; 
TRUNCATE table sczd_gjhhr_ticheng_cfg; 
TRUNCATE table sczd_income_deatails_log; 
TRUNCATE table sczd_player_all_achievements; 
TRUNCATE table sczd_player_base_info; 
TRUNCATE table sczd_player_day_achievements_log; 
TRUNCATE table sczd_relation_data; 
TRUNCATE table shipping_address; 
TRUNCATE table statistics_player_ddz_win; 
TRUNCATE table statistics_player_freestyle_mjxl; 
TRUNCATE table statistics_player_freestyle_tyddz; 
TRUNCATE table statistics_player_match_ddz; 
TRUNCATE table statistics_player_match_rank; 
TRUNCATE table statistics_player_million_ddz; 
TRUNCATE table statistics_player_mj_win; 
TRUNCATE table statistics_system_realtime; 
TRUNCATE table system_error; 
TRUNCATE table system_variant; 
TRUNCATE table vip_sc_buy_record; 
TRUNCATE table vip_sc_data; 
TRUNCATE table vip_sc_days; 
TRUNCATE table zy_city_match_fs_lose; 
TRUNCATE table zy_city_match_hx_lose; 
TRUNCATE table zy_city_match_rank_fs; 
TRUNCATE table zy_city_match_rank_hx; 
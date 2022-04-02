--[[
-- Created by lyx.
-- User: hare
-- Date: 2018/6/4
-- Time: 1:47
-- sczd 过滤器
-- 使用中的创建用户 接口
--      /sczd/wechat_create_player 高级合伙人扫码
--      /hermos/wechat_create_user （登录 后台）
--  其他接口
    //创建玩家与关系     "/sczd/wechat_create_player"
    //绑定关系           "/sczd/init_bind_parent"
    //改变绑定关系       "/sczd/change_player_relation"
    //获取openid         "/sczd/get_player_openid"
    //添加openid         "/sczd/add_player_openid"
--]]

local skynet = require "skynet_plus"
local cjson = require "cjson"
local basefunc = require "basefunc"
require "printfunc"

local hlib = require "websever_service.handle_lib"

-----------------------------------------------------------
-- 处理器函数映射： ret=返回值处理函数, svr=调用的服务, param=参数名数组

local cmd_defines = 
{
    ---------------------- ↓ web 通用管理接口 ↓ ----------------------    

    getApiDefine                ={ret=hlib.return_single_string  ,svr="collect_service",param={"op_user"}},

    hot_fix_sys_service_code    ={ret=hlib.return_web_admin ,svr="collect_service"},
    --hot_fix_sys_service_file    ={ret=hlib.return_web_admin ,svr="collect_service"},
    hot_fix_dyna_service_code    ={ret=hlib.return_web_admin ,svr="collect_service"},
    hot_fix_dyna_service_file    ={ret=hlib.return_web_admin ,svr="collect_service"},
    cpl_get_player_info          ={ret=hlib.return_web_admin ,svr="collect_service"},
    cpl_set_device_id            ={ret=hlib.return_web_admin ,svr="collect_service"},
    cpl_begin_new_phase_data     ={ret=hlib.return_web_admin ,svr="collect_service"},
    cpl_back_phase_list     ={ret=hlib.return_web_admin ,svr="collect_service"},
    cpl_restore_back_phase_data    ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_set_player_day_limit     ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_query_player_day_limit   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_query_player_info        ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_query_player_info2        ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_del_verify_info        ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_query_deled_verify_info   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_add_verify_info   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_add_test_user   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_del_test_user   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_view_test_user   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_add_gm_user   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_del_gm_user   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_view_gm_user   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_reload_config   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_update_config   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_get_config   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_get_server_info   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_set_shutdown_time   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_set_wechat_pay_limit   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_set_player_pay_channel   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_query_wechat_pay_config   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_query_op_log   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_watch_history   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_get_appoint   ={ret=hlib.return_web_admin ,svr="collect_service"},
    admin_cancel_appoint   ={ret=hlib.return_web_admin ,svr="collect_service"},
    
    ---------------------- ↑ web 通用管理接口 ↑ ----------------------    

    debug_pay                   ={ret=hlib.encode_data_code  ,svr="data_service"         ,param={"player_id","goods_id","money"}},
    get_player_debug_game_info  ={ret=hlib.encode_data_code  ,svr="debug_console_service",param={"player_id"}},
    force_break_room_table      ={ret=hlib.encode_code  ,svr="debug_console_service",param={"room_id","table_id"}},

    wechat_create_player       ={ret=hlib.encode_data_code  ,svr="sczd_center_service"  ,param={"platform","weixinUnionId","market_channel","parentUserId","share_sources"}},

    init_bind_parent            ={ret=hlib.encode_code       ,svr="sczd_center_service"  ,param={"player_id","parent_id"}},

    change_gjhhr_info           ={ret=hlib.encode_code       ,svr="sczd_center_service"  ,param={"player_id","create_or_delete","gjhhr_status","real_name","phone","weixin","shengfen","chengshi","qu","op_player",}},
                                               
    get_gjhhr_achievements_data ={ret=hlib.encode_data_code  ,svr="sczd_gjhhr_service"   ,param={"player_id"}},

    verify_gjhhr_info           ={ret=hlib.encode_data_code  ,svr="sczd_gjhhr_service"   ,param={"player_id","platform","weixinUnionId"}},
    
    change_player_relation      ={ret=hlib.encode_code       ,svr="sczd_center_service"  ,param={"player_id","new_parent","op_player"}},
    
    exec_all_plan               ={ret=hlib.encode_data_single,svr="sczd_gjhhr_service"  ,param={}},

    get_player_openid           ={ret=hlib.encode_data_code  ,svr="data_service"         ,param={"player_id","app_id"}},
    add_player_openid           ={ret=hlib.encode_code       ,svr="data_service"         ,param={"player_id","app_id","open_id"}},
    add_alipay_account          ={ret=hlib.encode_code       ,svr="data_service"         ,param={"player_id","name","account"}},
    get_alipay_account          ={ret=hlib.encode_data_code  ,svr="data_service"         ,param={"player_id"}},

    get_all_gjhhr_base_data     ={ret=hlib.encode_data_code  ,svr="sczd_gjhhr_service"   ,param={}},

    withdraw_gjhhr              ={ret=hlib.encode_data_code  ,svr="sczd_gjhhr_service"   ,param={"player_id","channel_type","channel_receiver_id","money"}},

    player_refund_msg           ={ret=hlib.encode_code  ,svr="sczd_gjhhr_service"   ,param={"player_id","num"}},

    change_ticheng_config       ={ret=hlib.encode_code  ,svr="sczd_gjhhr_service"   ,method="post"  , param={"data"}},

    query_jicha_cash            ={ret=hlib.encode_data_code  ,svr="sczd_gjhhr_service"   , param={"player_id"}},

    -- 高级合伙人 周期结算
    period_settle_by_web        ={ret=hlib.encode_code  ,svr="sczd_gjhhr_service"   , param={}},

    --  sczd的各种开关
    set_activate_sczd_profit   = {ret=hlib.encode_code  ,svr="sczd_center_service"   , param={"user_id","tgy_tx_profit" , "xj_profit" , "xj_profit2" , "xj_profit3" , "tglb_profit" , "basai_profit" }},

    -- web 增加兑换码
    add_redeem_code_data       ={ret=hlib.encode_data_code  ,svr="redeem_code_center_service" ,method="post"  , param={"data"}},
    
    -- web 删除兑换码
    delete_redeem_code_data       ={ret=hlib.encode_data_code  ,svr="redeem_code_center_service" ,method="post"  , param={"data"}},

    -- 米大师 支付回调
    cymj_midaspay_notify          ={ret=hlib.encode_data_single  ,svr="pay_service"         ,param={"..."}},
    -- 华为 支付回调
    cymj_huaweipay_notify          ={ret=hlib.encode_code  ,svr="pay_service",method="post"          ,param={"..."}},
    
    -- pc蛋蛋 cpl 调用 用户等级信息
    pceggs_get_player_info       ={ret=hlib.encode_data_single  ,svr="cpl_pceggs_service" ,method="get"  , param={"player_id","device_id","keycode"}},
    record_player_ios_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_pceggs_service" ,method="get"  , param={"device_id","keycode"}},
    pceggs_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_pceggs_service" ,method="get"  , param={"userid","keycode"}},
    pceggs_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_pceggs_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 玩棋牌 pc蛋蛋 cpl 调用 用户等级信息
    wqp_pceggs_get_player_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_pceggs_service" ,method="get"  , param={"player_id","device_id","keycode"}},
    wqp_pceggs_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_pceggs_service" ,method="get"  , param={"userid","keycode"}},
    wqp_pceggs_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_pceggs_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 闲玩 cpl
    xianwan_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_service" ,method="get"  , param={"deviceid","keycode"}},
    xianwan_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_service" ,method="get"  , param={"userid","keycode"}},
    xianwan_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_service" ,method="get"  , param={"userid","keycode"}},
    xianwan_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 玩棋牌 闲玩 cpl
    wqp_xianwan_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_xian_wan_service" ,method="get"  , param={"deviceid","keycode"}},
    wqp_xianwan_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_xian_wan_service" ,method="get"  , param={"userid","keycode"}},

    -- 闲玩 cpl （潮流捕鱼）
    xianwan_clby_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_clby_service" ,method="get"  , param={"deviceid","keycode"}},
    xianwan_clby_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_clby_service" ,method="get"  , param={"userid","keycode"}},
    xianwan_clby_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_clby_service" ,method="get"  , param={"userid","keycode"}},
    xianwan_clby_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_xian_wan_clby_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 趣味星球 cpl
    qwxq_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_qwxq_service" ,method="get"  , param={"deviceid","keycode"}},
    qwxq_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_qwxq_service" ,method="get"  , param={"userid","keycode"}},
    qwxq_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_qwxq_service" ,method="get"  , param={"userid","keycode"}},
    qwxq_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_qwxq_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 聚享玩 cpl
    juxiang_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_juxiang_service" ,method="get"  , param={"deviceid","keycode"}},
    juxiang_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_juxiang_service" ,method="get"  , param={"userid","keycode"}},
    juxiang_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_juxiang_service" ,method="get"  , param={"userid","keycode"}},
    juxiang_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_juxiang_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 玩棋牌 聚享玩 cpl
    wqp_juxiang_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_juxiang_service" ,method="get"  , param={"deviceid","keycode"}},
    wqp_juxiang_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_juxiang_service" ,method="get"  , param={"userid","keycode"}},

    -- 聚聚玩 cpl
    juju_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_juju_service" ,method="get"  , param={"deviceid","keycode"}},
    juju_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_juju_service" ,method="get"  , param={"userid","keycode"}},
    juju_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_juju_service" ,method="get"  , param={"userid","keycode"}},
    juju_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_juju_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 小啄 cpl
    xiaozhuo_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_xiaozhuo_service" ,method="get"  , param={"deviceid","keycode"}},
    xiaozhuo_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_xiaozhuo_service" ,method="get"  , param={"userid","keycode"}},
    xiaozhuo_mgr_user_info       ={ret=hlib.encode_data_single  ,svr="cpl_xiaozhuo_service" ,method="get"  , param={"userid","keycode"}},
    xiaozhuo_mgr_modify_device_id       ={ret=hlib.encode_data_single  ,svr="cpl_xiaozhuo_service" ,method="get"  , param={"userid","deviceid","keycode"}},

    -- 玩棋牌 小啄 cpl
    wqp_xiaozhuo_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_xiaozhuo_service" ,method="get"  , param={"deviceid","keycode"}},
    wqp_xiaozhuo_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_xiaozhuo_service" ,method="get"  , param={"userid","keycode"}},

    -- 蛋蛋赚 cpl
    dandanzhuan_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_dandanzhuan_service" ,method="get"  , param={"deviceid","keycode"}},
    dandanzhuan_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_dandanzhuan_service" ,method="get"  , param={"userid","keycode"}},

    -- 每天赚点 cpl aibianxian
    wqp_mtzd_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_mtzd_service" ,method="get"  , param={"deviceid","keycode"}},
    wqp_mtzd_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_wqp_mtzd_service" ,method="get"  , param={"userid","keycode"}},

    -- 爱变现 cpl 
    aibianxian_get_register_info       ={ret=hlib.encode_data_single  ,svr="cpl_aibianxian_service" ,method="get"  , param={"deviceid","keycode"}},
    aibianxian_get_game_info       ={ret=hlib.encode_data_single  ,svr="cpl_aibianxian_service" ,method="get"  , param={"userid","keycode"}},

    -- web 新增幸运宝箱抽奖 low 用户列表
    add_player_lottery_luck_box_low   ={ret=hlib.encode_data_code  ,svr="lottery_center_service" ,method="post"  , param={"data"}},

    -- web 删除 幸运宝箱抽奖 low 用户列表
    delete_player_lottery_luck_box_low  ={ret=hlib.encode_data_code  ,svr="lottery_center_service" ,method="post"  , param={"data"}},

    query_player_lottery_luck_box_low   ={ret=hlib.encode_data_code  ,svr="lottery_center_service" ,method="post"  , param={"data"}},



    -- web 增加排行榜玩家名单
    add_rank_server_player_list_data       ={ret=hlib.encode_data_code  ,svr="rank_center_service" ,method="post"  , param={"data"}},
    
    -- web 删除排行榜玩家名单
    delete_rank_server_player_list_data       ={ret=hlib.encode_data_code  ,svr="rank_center_service" ,method="post"  , param={"data"}},
    
    -- 存取 web 辅助变量
    get_extend_var = {ret=hlib.encode_data_single  ,svr="collect_service"   , param={"name","type"}},
    set_extend_var = {ret=hlib.encode_data_single  ,svr="collect_service"   , param={"name","type","value"}},

    get_player_by_id       ={ret=hlib.encode_data_code  ,svr="collect_service" , param={"player_id"}},

    get_player_list_by_login_info       ={ret=hlib.return_string  ,svr="verify_service" , param={"login_channel","login_id"}},

    get_player_by_login_info       ={ret=hlib.encode_data_code  ,svr="verify_service" , param={"platform","login_channel","login_id"}},

    get_withdraw_info ={ret=hlib.encode_data_code  ,svr="data_service"         ,param={"withdraw_id"}}, 
    query_one_user ={ret=hlib.encode_data_code  ,svr="data_service"         ,param={"user_id","platform","verify_channel","weixin_union_id"}}, 

    del_verify_info   ={ret=hlib.encode_data  ,svr="verify_service" , param={"player_id","channel_type","login_id"}},
    add_verify_info   ={ret=hlib.encode_data  ,svr="verify_service" , param={"player_id","channel_type","login_id","verify_data"}},

    -- 发短信
    send_phone_message   ={ret=hlib.encode_code  ,svr="third_agent_service" , param={"phone","message"}},

    getPlayerWithdrawInfo   ={ret=hlib.encode_data_code  ,svr="data_service" , param={"player_id"}},
    
    getAllTagList ={ret=hlib.return_string  ,svr="tag_center" ,param={}}, 
    getAllAuthList ={ret=hlib.return_string  ,svr="tag_center" ,param={}}, 
    checkExchangeStatus={ret=hlib.encode_data_single  ,svr="tag_center" ,method="post"  , param={"data"}},
    getPlayerTagList ={ret=hlib.return_string  ,svr="tag_center" ,param={"player_id"}}, 

    shoping_gold_pay ={ret=hlib.encode_bool_code,method="post",svr="data_service" ,param={"data"}}, 

    ---------------------- ↓ 道具碎片 ↓ ----------------------
    ---- 获取所有的兑换规则的（当前碎片个数 和 需要的碎片个数）
    -- query_chip_keys_info_for_web ={ret=hlib.encode_data_single,method="get",svr="data_service" ,param={"player_id"}}, 
    ---- 使用碎片兑换
    -- use_key_chip_for_web ={ret=hlib.encode_data_single,method="get",svr="data_service" ,param={"player_id" , "rule_key" }}, 

    ---------------------- ↑ 道具碎片 ↑ ----------------------

    getPlayerAppScheme ={ret=hlib.encode_data_code  ,svr="third_agent_service"   ,param={"player_id"}}, 

    recordNoBindAlipayReason={ret=hlib.encode_code,svr="collect_service"  ,param={"player_id","reason"}},
    get_player_sum_win ={ret=hlib.encode_data_code  ,svr="collect_service"   ,param={"player_id"}}, 

    --- add by wss -- 在欢乐捕鱼第一次游戏
    hlby_first_game ={ret=hlib.encode_code  ,svr= "task_center_service" ,method="get"  , param={"phone_number"}},

}

-----------------------------------------------------------

return hlib.handler(cmd_defines)
--[[ web api 的接口定义

充值限额
	"设置玩家每日充值限额",
	"查询玩家每日充值限额",

CPL 相关
	"CPL-查询玩家信息",
	"CPL-修改玩家设备ID",
	"CPL-清除数据（新一期开始）",
	"CPL-查找往期备份记录",
	"CPL-恢复往期备份数据",

基本查询
	"查询玩家基本信息",
	"查询玩家基本信息2",

账号删除恢复
	"删除玩家账号绑定信息",
	"查询已删除账号绑定信息",
	"增加账号绑定信息",

内部测试玩家管理
	"加入内部测试玩家",
	"删除内部测试玩家",
	"查看全部内部测试玩家",

高风险
	"加入GM玩家",
	"删除GM玩家",
	"查看全部GM玩家",


程序员专用
	"解锁卡死用户_匹配场_step1_得到玩家信息",
	"解锁卡死用户_匹配场_step2_解散桌子",
	"重新加载配置文件",
	"热更新代码_静态服务",
	"热更新代码_动态服务",
	"热更新文件_动态服务",

--------------------------------------
-- api 定义格式    

    {
        name_ch = "api中文名字",
        name = "/sczd/api名字",
        method = "post"/"get",
        params = { -- 参数列表
            {
                name_ch = "参数中文描述",
                name = "参数名",
                default = "默认值"/"func:取得默认值的函数名",
                type = "string"/"date"/"datetime"/"time"/"bool",
                select ={选项表}/"取得选项表的函数名",
            },

            ...
            
        },
    },


--]]
return {

    -- 角色
    role = {
        -- 开发人员
        developer = {
            env={"*"},
            api={"*"},
        },
        -- 超级管理员
        admin = {
            env={"release","test4"},
            api={"*"},
        },
        -- 普通管理员
        manager = {
            env={"release","test4","test_hl"},
            api={
                "/sczd/admin_query_player_info",
                "/sczd/admin_query_player_info2",
                "/sczd/admin_del_verify_info",
                "/sczd/admin_query_deled_verify_info",
                "/sczd/admin_add_verify_info",
                "/sczd/admin_add_test_user",
                "/sczd/admin_del_test_user",
                "/sczd/admin_view_test_user",
                "/sczd/admin_add_gm_user",
                "/sczd/admin_del_gm_user",
                "/sczd/admin_view_gm_user",
                "/sczd/admin_set_wechat_pay_limit",
                "/sczd/admin_set_player_pay_channel",
                "/sczd/admin_query_wechat_pay_config",
                "/sczd/admin_query_op_log",
                "/sczd/admin_watch_history",
                "/sczd/admin_get_appoint",
                "/sczd/admin_cancel_appoint",
            },
        },
        -- 策划
        cehua = {
            env={"release"},
            api={
                "/sczd/admin_query_player_info",
                "/sczd/admin_query_player_info2",
                "/sczd/admin_del_verify_info",
                "/sczd/admin_query_deled_verify_info",
                "/sczd/admin_add_verify_info",
                "/sczd/admin_set_player_day_limit",
                "/sczd/admin_query_player_day_limit",
            },
        },
        -- 运维
        yunwei = {
            env={"release","test4"},
            api={
                "/sczd/admin_get_server_info",
                "/sczd/admin_set_shutdown_time",
                "/sczd/admin_add_test_user",
                "/sczd/admin_del_test_user",
                "/sczd/admin_view_test_user",
                "/sczd/hot_fix_sys_service_code",
                "/sczd/hot_fix_dyna_service_code",
                "/sczd/hot_fix_dyna_service_file",
                "/sczd/admin_reload_config",
                "/sczd/admin_update_config",
                "/sczd/admin_query_op_log",
                "/sczd/admin_get_appoint",
                "/sczd/admin_cancel_appoint",
            },
        },
        -- 运营
        yunyin = {
            env={"release"},
            api={
                "/sczd/admin_query_player_info",
                "/sczd/admin_query_player_info2",
                "/sczd/cpl_get_player_info",
                "/sczd/cpl_set_device_id",
                "/sczd/cpl_begin_new_phase_data",
                "/sczd/cpl_back_phase_list",
                "/sczd/admin_get_appoint",
                "/sczd/admin_cancel_appoint",
            },
        },
        -- 运营2
        yunyin2 = {
            env={"release"},
            api={
                "/sczd/admin_set_player_day_limit",
                "/sczd/admin_query_player_day_limit",
            },
        },
        -- 运营3 ： 管理人员
        yunyin3 = {
            env={"release"},
            api={
                "/sczd/admin_query_player_info",
                "/sczd/admin_query_player_info2",
                "/sczd/admin_del_verify_info",
                "/sczd/admin_query_deled_verify_info",
                "/sczd/admin_add_verify_info",
            },
        },
    },

    -- 用户
    user = {
        longyuanxian = {
            role={"developer"},
        },
        zlh = {
            role={"developer"},
        },
        zch = {
            role={"developer"},
        },
        hewei = {
            role={"admin"},
        },
        weishishun = {
            role={"admin"},
        },
        yangyang = {
            role={"admin"},
        },
        liudaming = {
            role={"manager"},
        },
        yuhongming = {
            role={"yunyin"},
        },
        pengjie = {
            role={"yunyin"},
        },
        zengyan = {
            role={"yunyin2"},
        },
        zhangyi = {
            role={"yunyin3"},
        },
        wanghaitao = {
            role={"yunyin3"},
        },
        songtao = {
            role={"cehua"},
        },
        peiyanfei = {
            role={"yunwei"},
        },
        zhaojunfu = {
            role={"manager"},
        },
    },
    
    -- 环境
    env = {
        {
            name = "release",
            name_ch = "正式环境",
            ipAndProt = "172.18.107.235:8000",
        },
        {
            name = "test4",
            name_ch = "预发布环境",
            ipAndProt = "172.18.107.241:8004",
        },
        {
            name = "lyx",
            name_ch = "隆元线本机测试", 
            --ipAndProt = "171.88.165.249:5211",
            ipAndProt = "171.221.254.69:5211",
        },
        {
            name = "wss",
            name_ch = "魏世顺本机测试", 
            ipAndProt = "171.221.254.69:5216",
        },
        {
            name = "lyx_hl",
            name_ch = "隆元线本机(欢乐捕鱼)", 
            ipAndProt = "171.221.254.69:5212",
        },
        {
            name = "test_hl",
            name_ch = "测试环境(欢乐捕鱼)", 
            ipAndProt = "47.115.32.238:8112",
        },
    },

    -- api 定义
    api = {
        --------------------------
        {
            name_ch = "查询操作日志",
            name = "/sczd/admin_query_op_log",
            method = "post",
            params = {
                {
                    name_ch = "操作人",
                    name = "log_op_user",
                    default = "",
                    type = "string",
                    select = "op_user_list",
                },
                {
                    name_ch = "操作类型",
                    name = "log_op_type",
                    default = "",
                    type = "string",
                    select = "op_type_list",
                },
                {
                    name_ch = "开始时间",
                    name = "start_time",
                    default = "",
                    type = "datetime"
                },
                {
                    name_ch = "结束时间",
                    name = "end_time",
                    default = "",
                    type = "datetime"
                },
            },
        },
        --------------------------
        {
            name_ch = "查看已预约的操作",
            name = "/sczd/admin_get_appoint",
            method = "post",
            params = {
            },
        },
        --------------------------
        {
            name_ch = "取消已预约的操作",
            name = "/sczd/admin_cancel_appoint",
            method = "post",
            params = {
                {
                    name_ch = "要取消的预约",
                    name = "appoint_desc",
                    default = "",
                    type = "string",
                    select = "appoint_list"
                },
            },
        },
        --------------------------
        {
            name_ch = "查看监控项历史数据",
            name = "/sczd/admin_watch_history",
            method = "post",
            params = {
                {
                    name_ch = "监控项名称",
                    name = "watch_name",
                    default = "",
                    type = "string",
                    select = "watch_name_list",
                },
                {
                    name_ch = "开始时间",
                    name = "start_time",
                    default = "",
                    type = "datetime"
                },
                {
                    name_ch = "结束时间",
                    name = "end_time",
                    default = "",
                    type = "datetime"
                },
            },
        },
        --------------------------
        {
            name_ch = "设置玩家每日充值限额",
            name = "/sczd/admin_set_player_day_limit",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "限额",
                    name = "limit",
                    default = "",
                    type = "string"
                },
            },
        },
        --------------------------
        {
            name_ch = "修改微信充值限额",
            name = "/sczd/admin_set_wechat_pay_limit",
            method = "post",
            params = {
                {
                    name_ch = "微信每天限次",
                    name = "wechat_max_count_day",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "微信单笔限额",
                    name = "wechat_max_once",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "微信每天限额",
                    name = "wechat_max_day",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "微信每月限额",
                    name = "wechat_max_month",
                    default = "",
                    type = "string"
                },
            },
        },
        --------------------------
        {
            name_ch = "修改玩家支付渠道",
            name = "/sczd/admin_set_player_pay_channel",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "微信",
                    name = "weixin",
                    default = "",
                    type = "bool"
                },
                {
                    name_ch = "支付宝",
                    name = "alipay",
                    default = "",
                    type = "bool"
                },
            },
        },
        --------------------------
        {
            name_ch = "查询微信充值配置信息",
            name = "/sczd/admin_query_wechat_pay_config",
            method = "post",
            params = {
                {
                    name_ch = "玩家id(可选)",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
            },
        },
        --------------------------
        {
            name_ch = "查询玩家每日充值限额",
            name = "/sczd/admin_query_player_day_limit",
            method = "post",
            params = {
                {
                    name_ch = "玩家id(可选)",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
            },
        },
        --------------------------
        {
            name_ch = "热更新代码_静态服务",
            name = "/sczd/hot_fix_sys_service_code",
            method = "post",
            params = {
                {
                    name_ch = "服务名称",
                    name = "service_name",
                    default = "",
                    type = "string",
                    select = "static_services",
                },
                {
                    name_ch = "输入代码",
                    name = "src_code",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "选择文件",
                    name = "src_file",
                    default = "",
                    type = "file"
                },
            },
        },
        ---------------------------
        {
            name_ch = "热更新代码_动态服务",
            name = "/sczd/hot_fix_dyna_service_code",
            method = "post",
            params = {
                {
                    name_ch = "更新节点",
                    name = "node_name",
                    default = "",
                    type = "string",
                    select ="nodes",
                },
                {
                    name_ch = "更新标识",
                    name = "dyna_fix_name",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "代码内容",
                    name = "src_code",
                    default = "",
                    type = "string"
                },
            },
        },
        -------------------------- 
        {
            name_ch = "热更新文件_动态服务",
            name = "/sczd/hot_fix_dyna_service_file",
            method = "post",
            params = {
                {
                    name_ch = "更新节点",
                    name = "node_name",
                    default = "",
                    type = "string",
                    select ="nodes",
                },
                {
                    name_ch = "选择文件",
                    name = "src_code",
                    default = "",
                    type = "file"
                },
            },
        },
        -------------------------- 
        {
            name_ch = "重新加载配置文件(作用于 query_global_config)",
            name = "/sczd/admin_reload_config",
            method = "post",
            params = {
                {
                    name_ch = "选择文件",
                    name = "config_data",
                    default = "",
                    type = "file"
                },
            },
        },
        -------------------------- 
        {
            name_ch = "更新配置文件(作用于 get_global_config)",
            name = "/sczd/admin_update_config",
            method = "post",
            params = {
                {
                    name_ch = "选择文件",
                    name = "config_data",
                    default = "",
                    type = "file"
                },
                {
                    name_ch = "操作",
                    name = "optype",
                    default = "upload",
                    type = "string",
                    select ={"upload","check","apply"},
                },
            },
        },
        -------------------------- 
        {
            name_ch = "查看配置内容",
            name = "/sczd/admin_get_config",
            method = "post",
            params = {
                {
                    name_ch = "节点(可选)",
                    name = "node_name",
                    default = "",
                    type = "string",
                    select ="nodes",
                },
                {
                    name_ch = "配置类型",
                    name = "config_type",
                    default = "get_global_config",
                    type = "string",
                    select ={"getcfg","getenv","get_global_config","query_global_config"},
                },
                {
                    name_ch = "配置名称",
                    name = "config_name",
                    type = "string",
                },
            },
        },
        --------------------------  
        {
            name_ch = "CPL-查询玩家信息",
            name = "/sczd/cpl_get_player_info",
            method = "post",
            params = {
                {
                    name_ch = "CPL名称",
                    name = "cpl_name",
                    default = "",
                    type = "string",
                    select ="cpl_names"
                },
                {
                    name_ch = "设备ID",
                    name = "device_id",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "账号ID",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
            },
        },
        --------------------------
        {
            name_ch = "CPL-修改玩家设备ID",
            name = "/sczd/cpl_set_device_id",
            method = "post",
            params = {
                {
                    name_ch = "CPL名称",
                    name = "cpl_name",
                    default = "",
                    type = "string",
                    select ="cpl_names"
                },
                {
                    name_ch = "玩家账号ID",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "设备ID",
                    name = "device_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "CPL-清除数据（新一期开始）",
            name = "/sczd/cpl_begin_new_phase_data",
            method = "post",
            params = {
                {
                    name_ch = "CPL名称",
                    name = "cpl_name",
                    default = "",
                    type = "string",
                    select ="cpl_names",
                },
                {
                    name_ch = "系统类型",
                    name = "os",
                    default = "",
                    type = "string",
                    select = {"ios","android"},
                },
                {
                    name_ch = "平台标识",
                    name = "platform",
                    default = "",
                    type = "string",
                    select = "platforms",
                },
                {
                    name_ch = "预约时间",
                    name = "appoint_time",
                    default = "",
                    type = "datetime"
                },
            },
        },
        --------------------------
        {
            name_ch = "CPL-查找往期备份记录",
            name = "/sczd/cpl_back_phase_list",
            method = "post",
            params = {
                {
                    name_ch = "CPL名称",
                    name = "cpl_name",
                    default = "",
                    type = "string",
                    select ="cpl_names",
                },
            },
        },
        --------------------------
        {
            name_ch = "CPL-恢复往期备份数据",
            name = "/sczd/cpl_restore_back_phase_data",
            method = "post",
            params = {
                {
                    name_ch = "CPL名称",
                    name = "cpl_name",
                    default = "",
                    type = "string",
                    select ="cpl_names",
                },
                {
                    name_ch = "备份id",
                    name = "bakup_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "查询玩家基本信息",
            name = "/sczd/admin_query_player_info",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "查询玩家基本信息2",
            name = "/sczd/admin_query_player_info2",
            method = "post",
            params = {
                {
                    name_ch = "平台标识",
                    name = "platform",
                    default = "",
                    type = "string",
                    select = "platforms",
                },
                {
                    name_ch = "绑定类型",
                    name = "channel_type",
                    default = "wechat",
                    type = "string",
                    select = "login_channel_types",
                },
                {
                    name_ch = "绑定id",
                    name = "login_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------        
        {
            name_ch = "删除玩家账号绑定信息",
            name = "/sczd/admin_del_verify_info",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
                {
                    name_ch = "绑定类型",
                    name = "channel_type",
                    default = "wechat",
                    type = "string",
                    select = "login_channel_types",
                },
            },
        },
        --------------------------        
        {
            name_ch = "查询已删除账号绑定信息",
            name = "/sczd/admin_query_deled_verify_info",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
                {
                    name_ch = "绑定id",
                    name = "login_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "增加账号绑定信息",
            name = "/sczd/admin_add_verify_info",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
                {
                    name_ch = "绑定类型",
                    name = "channel_type",
                    default = "wechat",
                    type = "string",
                    select = "login_channel_types",
                },
                {
                    name_ch = "绑定id",
                    name = "login_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "加入内部测试玩家",
            name = "/sczd/admin_add_test_user",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
                {
                    name_ch = "真实姓名",
                    name = "real_name",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "删除内部测试玩家",
            name = "/sczd/admin_del_test_user",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "查看全部内部测试玩家",
            name = "/sczd/admin_view_test_user",
            method = "post",
            params = {
            },
        },
        --------------------------
        {
            name_ch = "加入GM玩家",
            name = "/sczd/admin_add_gm_user",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
                {
                    name_ch = "真实姓名",
                    name = "real_name",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "删除GM玩家",
            name = "/sczd/admin_del_gm_user",
            method = "post",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string",
                },
            },
        },
        --------------------------
        {
            name_ch = "查看全部GM玩家",
            name = "/sczd/admin_view_gm_user",
            method = "post",
            params = {
            },
        },
        --------------------------
        {
            name_ch = "参数类型测试用",
            name = "/sczd/paramtest",
            method = "post",
            params = {
                {
                    name_ch = "日期",
                    name = "param1",
                    default = "",
                    type = "date",
                },
                {
                    name_ch = "时间",
                    name = "param2",
                    default = "",
                    type = "time",
                },
                {
                    name_ch = "日期时间",
                    name = "param3",
                    default = "",
                    type = "datetime",
                },
                {
                    name_ch = "布尔类型",
                    name = "param4",
                    default = "",
                    type = "bool",
                },
            },
        },
        --------------------------
        {
            name_ch = "查看服务器信息",-- 启动时间；停服时间；数据写入
            name = "/sczd/admin_get_server_info",
            method = "post",
            params = {
            },
        },
        --------------------------
        {
            name_ch = "设置停服时间",
            name = "/sczd/admin_set_shutdown_time",
            method = "post",
            params = {
                {
                    name_ch = "停服时间",
                    name = "shutdown_time",
                    default = "",
                    type = "datetime",
                },
            },
        },
        --------------------------
        {
            name_ch = "解锁卡死用户_匹配场_step1_得到玩家信息",
            name = "/sczd/get_player_debug_game_info",
            method = "get",
            params = {
                {
                    name_ch = "玩家id",
                    name = "player_id",
                    default = "",
                    type = "string"
                },
            },
        },
        --------------------------
        {
            name_ch = "解锁卡死用户_匹配场_step2_解散桌子",
            name = "/sczd/force_break_room_table",
            method = "get",
            params = {
                {
                    name_ch = "房间id",
                    name = "room_id",
                    default = "",
                    type = "string"
                },
                {
                    name_ch = "桌子id",
                    name = "table_id",
                    default = "",
                    type = "string"
                },
            },
        }        
        --------------------------
    },


}
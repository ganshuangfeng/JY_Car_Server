--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:13
-- 说明：数据服务
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local mysql = require "skynet.db.mysql"
local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.is_dbsvr = true

DATA.msg_tag = "data_service"

-- ！！！注意：设置版本标志，避免在 旧版上执行 相关操作，会导致产品严重错误！！
DATA.is_data_service_2 = true

require "data_func"

local monitor_lib = require "monitor_lib"

local db_exec_man = require "data_service.db_exec_man"

local player_info = require "data_service.player_info"

local player_block_data = require "data_service.player_block_data"

local shop_info = require "data_service.shop_info"

local admin_info = require "data_service.admin_info"

local player_task_data = require "data_service.player_task_data"

local player_login_log_data = require "data_service.player_login_log_data"

local variant_data = require "data_service.variant_data"

local variant_data_store = require "data_service.variant_data_store"

local variant_payment = require "data_service.variant_payment"

local player_object_data = require "data_service.player_object_data"

local module_init = require "data_service.data_module_init"

require "printfunc"

DATA.sql_queue_names = {"fast","slow"}

--------------------------------------------------------
-- 快慢队列（直接加队列方式已废弃，为兼容而存在）

DATA.class_fake_sql_queue = basefunc.create_hot_class("class_fake_mysql")
function DATA.class_fake_sql_queue:ctor(_queue_name)
	self.queue_name = _queue_name or "slow"
	self.last_sql_id = 0
end
function DATA.class_fake_sql_queue:push_back(_sql)
	self.last_sql_id = db_exec_man.push_sql(self.queue_name,_sql)
end
function DATA.class_fake_sql_queue:back_id()
	
	return self.last_sql_id
end

DATA.sql_queue_fast = DATA.sql_queue_fast or DATA.class_fake_sql_queue.new("fast")
DATA.sql_queue_slow = DATA.sql_queue_slow or DATA.class_fake_sql_queue.new("slow")

--------------------------------------------------------
-- 数据库连接（直接使用数据库连接的方式已废弃，为兼容而存在）

DATA.class_fake_mysql = basefunc.create_hot_class("class_fake_mysql")
function DATA.class_fake_mysql:query(_sql)
	return CMD.db_query(_sql)
end

DATA.db_mysql = DATA.db_mysql or DATA.class_fake_mysql.new()

DATA.error_write_queue = DATA.error_write_queue or {}

-- 正在检查超时的 sql id  状态
DATA.sql_timeout_check_data = DATA.sql_timeout_check_data or {}
local LD = base.LocalData("data_service",{
	--定点时刻调用回调函数集合
	fixed_point_callbacks={},

	-- sql 语句报错的记录文件
	sql_error_file_handle = nil,

	_flush_counter = 0,
	_error_data_dirty = false,
})

local LF = base.LocalFunc("data_service")

--- add by wss 在延迟插入sql队列的缓存中的个数
DATA.delay_push_sql_queue_num = DATA.delay_push_sql_queue_num or 0

DATA.delay_push_sql_queue_num_vec = DATA.delay_push_sql_queue_num_vec or {}

-- update 信号
--DATA.update_signal = basefunc.signal.new()



function PUBLIC.open_sql_error_file()

	if LD.sql_error_file_handle then

		return LD.sql_error_file_handle ~= "open error"

	else
		local err
		LD.sql_error_file_handle,err = io.open("./logs/sql_error.txt","a")
		if not LD.sql_error_file_handle then
			LD.sql_error_file_handle = "open error"
			print(string.format("open './logs/sql_error.txt' error:%s!", tostring(err)))
			return false
		end

		return true
	end
end

function PUBLIC.flush_sql_error()

	if LD.sql_error_file_handle and LD.sql_error_file_handle ~= "open error" then

		LD.sql_error_file_handle:close()

		LD.sql_error_file_handle = nil
	end
end


-- 记录 sql 执行错误（如果有的话）
function PUBLIC.write_sql_error_file()

	LD._flush_counter = LD._flush_counter + 1
	if LD._error_data_dirty and LD._flush_counter % 10 == 0 then
		PUBLIC.flush_sql_error()
		LD._error_data_dirty = false
	end

	if next(DATA.error_write_queue) and PUBLIC.open_sql_error_file() then

		local _tmp = DATA.error_write_queue
		DATA.error_write_queue = {}

		LD.sql_error_file_handle:write(table.concat(_tmp,"\n"))
		LD._error_data_dirty = true
	end

end

function PUBLIC.record_sql_error(_ret,_sql,_queue_name,_sql_conn_proc)

	monitor_lib.add_data("sql_error",1)

	-- 仅 提取错误信息
	local _errinfo = {
		mulitresultset=_ret.mulitresultset,
		multi_count=#_ret,
		errno=_ret.errno,
		err=_ret.err,
		sqlstate=_ret.sqlstate,
		badresult=_ret.badresult,
	}

	local _error_text = string.format(
[[
%s === %s sql error ===
error info:
%s
sql text #%s:
%s

]],os.date("[%Y-%m-%d %H:%M:%S]"),_queue_name,basefunc.tostring( _errinfo ),tostring(_sql_conn_proc),tostring(_sql))

	DATA.error_write_queue[#DATA.error_write_queue + 1] = _error_text
	print(_error_text)

end

-- 状态检查
function LF.check_sql_status()

	print(

		"\n==== 数据写入状态 =====\n" ..
		table.concat(db_exec_man.get_queue_status_string(),"\n") .. "\n" ..
		"=======================\n"
	)

end

-- 增长服务器实例 id
function CMD.inc_instance_id()
	DATA.system_variant.current_instance_id = DATA.system_variant.current_instance_id + 1
	return DATA.system_variant.current_instance_id
end

-- 得到服务实例 id
function CMD.get_instance_id()
	return DATA.system_variant.current_instance_id
end

function PUBLIC.get_delay_sql_queue_num()
	local delay_push_sql_queue_num = 0
	for key,num in pairs(DATA.delay_push_sql_queue_num_vec) do
		delay_push_sql_queue_num = delay_push_sql_queue_num + num
	end

	return delay_push_sql_queue_num
end

function CMD.debug_get_status()


	--local task_center_service_cache_num = skynet.call( DATA.service_config.task_center_service , "lua" , "get_cache_data_num" )


	local _info = {}

	

	basefunc.array_copy(db_exec_man.get_queue_status_string(true),_info)
	_info[#_info + 1] = ""
	basefunc.array_copy(db_exec_man.get_group_sql_string(),_info)
	_info[#_info + 1] = ""
	--_info[#_info + 1] = "task_center_service cache_count:" .. task_center_service_cache_num
	_info[#_info + 1] = "delay_push_sql_queue_num:" .. PUBLIC.get_delay_sql_queue_num()


	return _info
end

--[[添加一个定点时刻调用
	每天这个时刻都会被调用 并不保证准时，基本上是在这个时刻后的数秒后
	目前只支持 0点 4点
	一般放进来后，就不能取消
]]
function PUBLIC.add_fixed_point_callback(time,func)
	local funcs = LD.fixed_point_callbacks[time]
	if funcs then
		funcs[#funcs+1]=func
	end
end


-- 初始化定点时刻调用
function LF.init_fixed_point_callback()
	LD.fixed_point_callbacks[0]={}
	LD.fixed_point_callbacks[4]={}

	local function cbk_0()
		
		for i,func in ipairs(LD.fixed_point_callbacks[0]) do
			func()
			skynet.sleep(5)
		end

		skynet.timeout(24*3600*100,cbk_0)
	end

	local function cbk_4()
		
		for i,func in ipairs(LD.fixed_point_callbacks[4]) do
			func()
			skynet.sleep(5)
		end

		skynet.timeout(24*3600*100,cbk_4)
	end

	local t_0=basefunc.get_diff_target_time(0)
	local t_4=basefunc.get_diff_target_time(4)

	skynet.timeout(t_0*100,cbk_0)
	skynet.timeout(t_4*100,cbk_4)

end

-- 每日例行的数据库清理
function LF.daily_clearup_data()

	-- 数据库清理
	DATA.sql_queue_slow:push_back("CALL daily_clearup_data();")

end

-- 每分钟例行的数据库清理
function LF.per_minute_clear_data()

	DATA.sql_queue_slow:push_back("call minute_clear_data();")	
end

-- 初始化系统数据
function LF.init_system_data()

	local _init_sqls = {
		
		[[insert into prop_type(prop_type,prop_group,`value`) values ('diamond','diamond',1) on duplicate key update prop_type='diamond',prop_group='diamond',`value`=1 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('jing_bi','jing_bi',1) on duplicate key update prop_type='jing_bi',prop_group='jing_bi',`value`=1 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('cash','cash',1) on duplicate key update prop_type='cash',prop_group='cash',`value`=1 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('match_ticket','match_ticket',1) on duplicate key update prop_type='match_ticket',prop_group='match_ticket',`value`=1 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('hammer','hammer',1) on duplicate key update prop_type='hammer',prop_group='hammer',`value`=1 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('bomb','bomb',1) on duplicate key update prop_type='bomb',prop_group='bomb',`value`=1 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('shop_gold_10','shop_gold',10) on duplicate key update prop_type='shop_gold_10',prop_group='shop_gold',`value`=10 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('shop_gold_100','shop_gold',100) on duplicate key update prop_type='shop_gold_100',prop_group='shop_gold',`value`=100 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('shop_gold_1000','shop_gold',1000) on duplicate key update prop_type='shop_gold_1000',prop_group='shop_gold',`value`=1000 ;]],
		[[insert into prop_type(prop_type,prop_group,`value`) values ('shop_gold_10000','shop_gold',10000) on duplicate key update prop_type='shop_gold_10000',prop_group='shop_gold',`value`=10000 ;]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('freestyle_signup','freestyle_cancel_signup') on duplicate key update change_type_refund='freestyle_cancel_signup';]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('lz_freestyle_signup','lz_freestyle_cancel_signup') on duplicate key update change_type_refund='lz_freestyle_cancel_signup';]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('ty_freestyle_signup','ty_freestyle_cancel_signup') on duplicate key update change_type_refund='ty_freestyle_cancel_signup';]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('million_signup','million_cancel_signup') on duplicate key update change_type_refund='million_cancel_signup';]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('majiang_freestyle_signup','majiang_freestyle_cancel_signup') on duplicate key update change_type_refund='majiang_freestyle_cancel_signup';]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('mjxl_majiang_freestyle_signup','mjxl_majiang_freestyle_cancel_signup') on duplicate key update change_type_refund='mjxl_majiang_freestyle_cancel_signup';]],
		[[insert into player_change_type_refund(change_type,change_type_refund) values ('match_signup','match_cancel_signup') on duplicate key update change_type_refund='match_cancel_signup';]],
		[[insert into system_variant(`name`,`value`) values ('minute_clear_count','0')  on duplicate key update `value` = `value` + 0;]],
	}

	for _,v in ipairs(_init_sqls) do
		DATA.sql_queue_fast:push_back(v)
	end
end

function PUBLIC.check_sql_timeout()

	local _now = os.time()

	-- 依此检查 状态
	for _queue_name,_data in pairs(db_exec_man.get_queue_status()) do

		local _check_data = DATA.sql_timeout_check_data[_queue_name] or 
		{
			sql_id_checking = nil, -- 正在检查的语句 id
			check_time = nil, -- 开始检查的时间
		}

		if _check_data.sql_id_checking then
			if _data.serial_sql_min_id and (_data.serial_sql_min_id >= _check_data.sql_id_checking) then
				-- 已执行 sql_id_checking 则清除
				_check_data.sql_id_checking = nil
				_check_data.check_time = nil
			else
				-- 未执行，加入监控值
				monitor_lib.add_data("sql_wait_time",_now - _check_data.check_time)
			end
		else
			-- 当前没有监控，则加入监控
			_check_data.sql_id_checking = _data.last_sql_push
			_check_data.check_time = _now
		end
	end

	monitor_lib.add_data("sql_wait_count",db_exec_man.get_waiting_sql_count())
	monitor_lib.add_data("delay_sql_wait_count",PUBLIC.get_delay_sql_queue_num())
end

-- 初始化函数（数据库连接成功后调用）
function PUBLIC.on_dbconnected()

	print("PUBLIC.on_dbconnected start!")

	-- sql 快队列执行时钟
	--skynet.timer(0.02,function() LF.exec_queue_sql_fast() end)

	-- sql 慢队列执行时钟
	--skynet.timer(0.02,function() LF.exec_queue_sql_slow() end)

	skynet.timer(5,function() PUBLIC.check_sql_timeout() end)

	-- sql 状态检查时钟（用于诊断）
	skynet.timer(10,function() LF.check_sql_status() end)

	-- 数据 连接 刷新，防止断开
	--skynet.timer(3600,function() LD.refresh_db_connections() end)

	-- 写入 sql 错误日志
	skynet.timer(0.1,function() PUBLIC.write_sql_error_file() end)

	LF.init_fixed_point_callback()

	-- 初始化系统数据
	LF.init_system_data()

	-- 初始化 系统变量
	PUBLIC.init_system_variant()

	-- 初始化玩家信息
	player_info.init_player_info()

	player_login_log_data.init_data()

	variant_data.init()

	player_block_data.init_data()

	player_task_data.init_data()
	
	admin_info.init_admin_info()

	shop_info.init()

	variant_data_store.init()

	variant_payment.init()

	module_init.init()

	-- 每日的数据库清理动作
	PUBLIC.add_fixed_point_callback(4,LF.daily_clearup_data)

	-- 每分钟的数据库清理动作
	skynet.timer(60,LF.per_minute_clear_data)

	-- 增长服务器 实例 id
	CMD.inc_instance_id()

	DATA.service_started = true

	print("PUBLIC.on_dbconnected complete!")
end

-- 检查是否可以停止服务
function PUBLIC.try_stop_service(_count,_time)

	-- 还有 sql 未执行，则不能结束
	if not DATA.sql_queue_fast:empty() then
		return "wait","fast queue is writing : " .. tostring(DATA.sql_queue_fast:front())
	end
	if not DATA.sql_queue_slow:empty() then
		return "wait","slow queue is writing : " .. tostring(DATA.sql_queue_slow:front())
	end

	-- 等待已退出 应用 更新状态数据，避免 gather_services_status 访问无效地址
	skynet.sleep(100)

	-- 检查除自己和center 之外的所有服务，他们都退出了（都可能还要保存数据），自己才能停。
	local _services = skynet.call(DATA.service_config.center_service,"lua","gather_services_status",3)
	for _,_service in pairs(_services) do
		-- 排除 自己和center
		if _service.arg and _service.addr ~= skynet.self() and "free" ~= _service.status and "stop" ~= _service.status then
			return "wait",string.format("service ':%08x' maybe using me!",_service.addr)
		end
	end

	return "stop"
end

--- add by wss 增加或减少在延迟插入sql队列的缓存数量
function CMD.add_or_reduce_delay_push_sql_num( change_value )
	DATA.delay_push_sql_queue_num = DATA.delay_push_sql_queue_num + change_value
end

function CMD.set_delay_push_sql_num(_type , num)
	DATA.delay_push_sql_queue_num_vec[_type] = num
end

--- add by wss  系统变量自增
function CMD.auto_inc_id(_name)
	return PUBLIC.auto_inc_id(_name)
end

function CMD.start(_service_config)

	DATA.service_config = _service_config

	db_exec_man.init()

	-- 等待初始化完成，否则 其他服务 访问数据时 将导致问题
	print("wait db connect init ...")
	repeat
		skynet.sleep(50)
	until DATA.service_started
	print("db connect init ok.")
end

-- 启动服务
base.start_service()




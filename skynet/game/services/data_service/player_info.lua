--
-- Author: lyx
-- Date: 2018/3/26
-- Time: 8:58
-- 说明：玩家信息数据
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
require "data_func"
require "normal_enum"
require "printfunc"
require "common_data_manager_lib"

local monitor_lib = require "monitor_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LF = base.LocalFunc("player_info")

local LD = base.LocalData("player_info",{


	-- 后台数据需要拉取日志的财富类型
	back_sys_log_assets =
	{
	},

	-- 面额数组，从大到小排序
	shop_gold_faces = nil,

	creating_login_id = {}, -- 正在创建的 login_id

	query_user_assets_from_db_clock = {},
	query_user_detail_info_from_db_clock = {},
	admin_decrease_player_asset_clock = {},
	query_user_give_award_info_from_db_clock = {},
	player_init_loaded = false,

})


local sql_strv = PUBLIC.sql_strv

function LF.get_asset_log_id(_asset_type)
	if not LD.back_sys_log_assets[_asset_type] then
		return -1 -- 不更新
	end

	return PUBLIC.auto_inc_id("last_asset_log_seq")
end

DATA.player_info_protect = {}

local PROTECTED = DATA.player_info_protect -- {}

--[[
-- 玩家的信息数据： userId -> 数据
-- 数据结构说明：
	userId = {
		--玩家信息
		player_info = {
			id = ,
			login_channel = ,
			...
 		},
 		--玩家设备
		player_device_info = {
			...
 		}
 		--玩家财务
		player_asset = {
			match_ticket = ,
			room_card = ,
			...
 		}
 		--玩家道具（一 对 多）
		player_prop = {
			prop_type1 = { prop_count=,... },
			prop_type2 = { prop_count=,... },
			...
 		}
 		--玩家open_id
 		open_id={
				[key=app_id]=open_id
 		}
 		--玩家alipay_account
 		alipay_account={
 			name
 			account
 		}
	}
--]]
----------------------------------------------------------------------------------------------------------------- player_info  ↓↓↓↓↓↓↓↓↓
--PUBLIC.player_info = {}
--local player_info = PUBLIC.player_info

PROTECTED.player_info = PROTECTED.player_info or basefunc.server_class.data_manager_cls.new( {} , tonumber(skynet.getenv("data_man_cache_size")) or 40000 )



----------------------------------------------------------------------------------------------------------------------- ↑↑↑↑↑↑↑↑↑

-- 验证表 player_verify 中的数据。
-- ###_warning 注意： 始终保证这里是全量数据！新注册用户必须加进来
-- channel_type,login_id 两层映射： channel_type -> {login_id -> {行数据} }
-- 并且附带一个总数 count
-- PUBLIC.player_verify_data = {}
-- local player_verify_data = PUBLIC.player_verify_data

--[[ 所有玩家状态： id => {
	status="off"/"on"(离线/在线),
	channel=登录渠道,time=上线/离线时间,
	first_login_time=首次登录时间（惰性加载）
 }
--]]
PUBLIC.all_player_status = {}

----------------------------------------------------------------------------------------------------------------- wechat_open_id_cache  ↓↓↓↓↓↓↓↓↓
-- 微信的 open id 缓存
--local wechat_open_id_cache = {}
function PROTECTED.load_wechat_open_id_cache_data(player_id)
	local _sql = PUBLIC.format_sql( [[ select extend_1 from player_verify where channel_type = 'wechat' and id=%s; ]] , player_id )

	local ret = PUBLIC.query_data( _sql )
	if( ret.errno ) then
		print(string.format("query_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	--dump( ret , "xxx------------load_wechat_open_id_cache_data__"..player_id .. ":" )
	return ret[1] and ret[1].extend_1
end

PROTECTED.wechat_open_id_cache = PROTECTED.wechat_open_id_cache or
											basefunc.server_class.data_manager_cls.new( { load_data = PROTECTED.load_wechat_open_id_cache_data } , tonumber(skynet.getenv("data_man_cache_size")) or 20000 )
----------------------------------------------------------------------------------------------------------------------- ↑↑↑↑↑↑↑↑↑
-- 玩家在线人数： channel => 数量
PUBLIC.onine_player_count = {}

----------------------------------------------------------------------------------------------------------------- player_ext_status  ↓↓↓↓↓↓↓↓↓
--local player_ext_status = {}

function PROTECTED.load_player_ext_status_data(player_id)
	local _sql = PUBLIC.format_sql( [[ select player_id,type,`status`,UNIX_TIMESTAMP(time) time from player_ext_status where player_id = %s; ]] , player_id )

	local ret = PUBLIC.query_data( _sql )
	if( ret.errno ) then
		print(string.format("query_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	--dump(ret , "xxx--------------load_player_ext_status_data__".. player_id ..":")
	local ret_vec = {}
	if ret and type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			ret_vec[data.type] = data
		end
	end

	return ret_vec
end

PROTECTED.player_ext_status = PROTECTED.player_ext_status or basefunc.server_class.data_manager_cls.new( { load_data = PROTECTED.load_player_ext_status_data } , tonumber(skynet.getenv("data_man_cache_size")) or 20000 )
----------------------------------------------------------------------------------------------------------------------- ↑↑↑↑↑↑↑↑↑
----------------------------------------------------------------------------------------------------------------- player_everyday_shared_status  ↓↓↓↓↓↓↓↓↓
--local player_everyday_shared_status = {}
function PROTECTED.load_player_everyday_shared_status_data(player_id)
	local _sql = PUBLIC.format_sql( [[ select * from player_everyday_shared_status where player_id = %s; ]] , player_id )

	local ret = PUBLIC.query_data( _sql )
	if( ret.errno ) then
		print(string.format("query_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	--dump(ret , "xxx--------------load_player_everyday_shared_status_data__".. player_id ..":")
	local ret_vec = {}
	if ret and type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			ret_vec[data.type] = data
		end
	end

	return ret_vec
end

PROTECTED.player_everyday_shared_status = PROTECTED.player_everyday_shared_status or
												basefunc.server_class.data_manager_cls.new( { load_data = PROTECTED.load_player_everyday_shared_status_data } ,tonumber(skynet.getenv("data_man_cache_size")) or  20000 )
----------------------------------------------------------------------------------------------------------------------- ↑↑↑↑↑↑↑↑↑


------------------------------------------------------------------------- alipay_account_statistic  ↓↓↓↓↓↓↓↓↓
--local alipay_account_statistic = {}

function PROTECTED.load_alipay_account_statistic_data(alipay_account)
	local _sql = PUBLIC.format_sql( [[ select * from alipay_account_statistic where alipay_account = %s; ]] , alipay_account )

	local ret = PUBLIC.query_data( _sql )

	if( ret.errno ) then
		print(string.format("query_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	local ret_vec = {}
	if type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			ret_vec[data.platform] = data.num
		end
	end

	return ret_vec
end

PROTECTED.alipay_account_statistic = PROTECTED.alipay_account_statistic or
											basefunc.server_class.data_manager_cls.new(
												{ load_data = PROTECTED.load_alipay_account_statistic_data }
												,200
												)
------------------------------------------------------------------------------ ↑↑↑↑↑↑↑↑↑


-----------------------------------------------------------
-- 内部函数
--

-- 初始化用户清单
local function init_player_list()

	-- 加载用户 id 清单

	local _now = os.time()

	-- 加载用户状态 ###_temp 可能要 将不活跃用户定期清理到历史表！！
	local sql = "select id from player_info"
	local ret = DATA.db_mysql:query(sql)
	if( ret.errno ) then
		skynet.fail(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
	else
		for i = 1,#ret do
			PUBLIC.all_player_status[ret[i].id] = {status="off",time=_now,channel=nil}
		end
	end

end


-- 加载指定的表
-- 参数：
--		_userId,_table_name 用户id，数据表名；
--				特殊情况： 如果 _userId 是一个表，则为 {字段名,值} 的格式
--		_field_names 需要载入的字段，默认载入所有字段值
--		_sub_key_name 子键名，如果不为空，则数据放在 以此字段为键 的 lua 表中
-- 返回：数据行数，出错返回 nil
function PROTECTED.load_player_table(_data_out,_userId,_table_name,_field_names,_sub_key_name)

	local fields
	if _field_names then
		fields = table.concat(_field_names,",")
	else
		fields = "*"
	end

	local sql
	if type(_userId) == "table" then
		sql = string.format("select %s from %s where %s='%s'",fields,_table_name,_userId[1],_userId[2])
	else
		sql = string.format("select %s from %s where id='%s'",fields,_table_name,_userId)
	end
	local ret = DATA.db_mysql:query(sql)
	if( ret.errno ) then
		skynet.fail(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
		return nil
	end
	PUBLIC.gen_cache_data(_data_out,ret,_table_name,_sub_key_name)

	return #ret
end

-- 加载玩家信息
function PUBLIC.load_player_info(_userId)

	if PROTECTED.player_info:get_data(_userId) then return PROTECTED.player_info:get_data(_userId) end

	local user = {}

	local info_result = PROTECTED.load_player_table(user,_userId,"player_info")
	if not info_result or info_result == 0 then
		return nil -- 没有用户数据
	end
	if PROTECTED.player_info:get_data(_userId) then return PROTECTED.player_info:get_data(_userId) end

	PROTECTED.load_player_table(user,_userId,"player_prop",nil,"prop_type")
	if PROTECTED.player_info:get_data(_userId) then return PROTECTED.player_info:get_data(_userId) end
	
	PROTECTED.load_player_table(user,_userId,"player_register")
	if PROTECTED.player_info:get_data(_userId) then return PROTECTED.player_info:get_data(_userId) end
	--- add by wss
	PROTECTED.load_player_table(user,_userId,"player_login",{"login_time" , "logout_time"})
	if PROTECTED.player_info:get_data(_userId) then return PROTECTED.player_info:get_data(_userId) end

	PROTECTED.load_player_table(user,_userId,"player_login_stat",{"first_login_time" , "last_login_time"})
	if PROTECTED.player_info:get_data(_userId) then return PROTECTED.player_info:get_data(_userId) end

	-- 初始化道具
	user.object_data = CMD.query_player_object_data(_userId)

	PROTECTED.player_info:add_or_update_data( _userId , user )

	return user
end

-- 初始化玩家信息
function PROTECTED.init_player_info()

	--初始化用户清单
	init_player_list()

	-- 在这里载入活跃用户 ###_temp 应该是放一个列表中，或者一个 专门的lua 文件中，作为配置文件
	-- PUBLIC.load_player_info("userid_1")
	-- PUBLIC.load_player_info("userid_2")

	--PROTECTED.init_player_ext_status()

	--PROTECTED.init_shared_award_status()

	--PROTECTED.init_broke_subsidy_data()

	-- 每分钟写入在线统计数据
	skynet.timer(60,function ()

		if "wait" == DATA.current_service_status then
			return false
		end

		for _channel,_count in pairs(PUBLIC.onine_player_count) do
			DATA.sql_queue_slow:push_back(string.format("insert into statistics_system_realtime(time,channel,player_count) values(now(),'%s',%u);\n",_channel,_count))
		end
	end)
	-- 在线数据监控（更精确）
	skynet.timer(5,function ()

		if "wait" == DATA.current_service_status then
			return false
		end

		local _real_count = 0
		for _channel,_count in pairs(PUBLIC.onine_player_count) do
			if _channel ~= "robot" and _channel ~= "test" then
				_real_count = _real_count + _count
			end
		end

		monitor_lib.add_data("online_count",_real_count)
	end)

	LD.player_init_loaded = true
	return true
end


-- 根据金额拆分 面额
-- 返回表 type => 数量
function LF.regroup_shop_gold(_gold)

	if not LD.shop_gold_faces then
		LD.shop_gold_faces = {}
		for _value,_ in pairs(SHOP_GOLD_PROPTYPES) do
			LD.shop_gold_faces[#LD.shop_gold_faces + 1] = _value
		end

		table.sort(LD.shop_gold_faces,function (v1,v2)
			return v1 > v2
		end)
	end

	local _ret = {}

	for _,_v in ipairs(LD.shop_gold_faces) do
		if _v <= _gold then
			local _count = math.modf(_gold/_v)
			_gold = math.fmod(_gold,_v)

			local _type = SHOP_GOLD_PROPTYPES[_v]
			_ret[_type] = (_ret[_type] or 0) + _count
		end
	end

	return _ret
end

-- 重组 面额
function LF.regroup_shop_gold_face(_userId,_user,_new_value)

	-- 新的面额： prop_type -> prop_count
	local _new_golds = LF.regroup_shop_gold(_new_value)

	-- 重组现有的面额，注意：因为总金额已有日志，这里没有日志，强制设置！
	for _type,_value in pairs(SHOP_GOLD_FACEVALUES) do
		local prop = _user.player_prop[_type] or {prop_type=_type}
		_user.player_prop[_type] = prop
		prop.prop_count = _new_golds[_type] or 0

		if prop.prop_count > 0 then
			DATA.sql_queue_fast:push_back(string.format("INSERT INTO player_prop(id,prop_type,prop_count)VALUES('%s','%s',%f) on duplicate key update prop_count=%f;",
				_userId,_type,_new_golds[_type],_new_golds[_type]))
		else
			DATA.sql_queue_fast:push_back(string.format("DELETE FROM player_prop where id = '%s' and prop_type = '%s';",
				_userId,_type))
		end
	end

end

-- 修改玩家的财富值
--	_table_name 表名字
--	_field_name 字段名字
--	_inc_value 要修改的值
--	_sql_fast 是否插入到高速 sql 队列，默认插入到 低速 队列
-- 返回：
--	成功，则返回新的值； 失败返回 nil
-- 注意：此函数不支持更新带有子键的 表
function PROTECTED.change_player_asset(_userId,_table_name,_field_name,_inc_value,_sql_fast)

	-- 从数据库载入到缓存
	local user = PUBLIC.load_player_info(_userId)

	if not user then
		print(string.format("change_player_asset %s error:not found player '%s'",tostring(_table_name),tostring(_userId)))
		return nil
	end

	if not _table_name then
		skynet.fail("_table_name cannt be nil !")
		return nil
	end

	local tdata = user[_table_name]
	if not tdata then
		skynet.fail(string.format("change_player_asset error:table %s,field %s data not found!",_table_name,_field_name))
		return nil
	end

	local new_value = tdata[_field_name] + _inc_value

	-- 修改缓存值
	tdata[_field_name] = new_value

	-- 插入到 sql 队列
	local sql = string.format("update %s set %s=%s where id='%s'",
		_table_name,_field_name,PUBLIC.value_to_sql(tdata[_field_name]),_userId)

	local _qtype,_sql_id = CMD.db_exec(sql,_sql_fast and "fast" or "slow")
	PROTECTED.player_info:update_sql_queue_data(_userId,_qtype,_sql_id)

	-- 重组
	if _field_name == "shop_gold_sum" then
		LF.regroup_shop_gold_face(_userId,user,tdata[_field_name])
	end

	return tdata[_field_name]
end

---------------------------------------------------
-- 供外部服务调用的命令
--


-- 收集一组用户的设备 token
function CMD.get_users_device_token(_user_ids)

	-- 这是临时方案，一次性发送大量用户时，要 通过 列表实现（一次性加载大量用户 可能导致性能问题）
	assert(#_user_ids < 10,"too many users!!")

	local ret = {ios={},android={}}
	for _,_user_id in ipairs(_user_ids) do
		local user = PUBLIC.load_player_info(_user_id)
		local di = user and user.player_device_info
		if di and di.device_token and di.device_type and ret[di.device_type] then

			table.insert(ret[di.device_type],di.device_token)
		end
	end

	return ret
end


-- 更新用户基础数据（如果没改变则不会更新）
function PUBLIC.update_base_player_info(_userId,_data)

	local user = PUBLIC.load_player_info(_userId)

	if not user then
		print(string.format("update_base_player_info error:not found player '%s'",tostring(_userId)))
		return false
	end

	-- 检查是否有改变
	local _changed = false
	local is_name_change = false
	for _name,_value in pairs(_data) do


		if _data[_name] ~= user.player_info[_name] then
			_changed = true
			if _name == "name" then
				is_name_change = true
			end
			break
		end
	end

	if not _changed then
		print("player info not change old:",basefunc.tostring(user.player_info))
		print("player info not change new:",basefunc.tostring(_data))
		return
	end

	if is_name_change then
		skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "trigger_msg" , {name = "player_name_change"} , _userId , _data.name )
	end
	-- 增长同步序号
	_data.sync_seq = PUBLIC.auto_inc_id("last_player_info_seq")

	-- sql 的 set 子句
	local _set_sql = PUBLIC.gen_update_fields_sql(_data,function(_name)
		if _data[_name] ~= user.player_info[_name] then
			user.player_info[_name] = _data[_name]
			return true
		else
			return false
		end
	end)

	if _set_sql ~= "" then
		print("update_base_player_info:",_set_sql,_userId)
		local _qtype,_sql_id = CMD.db_exec("update player_info set " .. _set_sql .. string.format(" where id='%s';",_userId))
		PROTECTED.player_info:update_sql_queue_data(_userId,_qtype,_sql_id)
	else

		print("player info sql not change old:",basefunc.tostring(user.player_info))
		print("player info sql not change new:",basefunc.tostring(_data))

	end

	return true
end

-- 验证用户修改
-- 注意：新用户首次登录不会调用此函数
-- 返回 0 或 错误号
function CMD.verify_user(_channel_type,_userId,_user_data)


	-- 检查是否被临时禁止登录
	if DATA.reject_login_users[_userId] then
		if DATA.reject_login_users[_userId] > os.time() then
			return 2158
		end

		DATA.reject_login_users[_userId] = nil
	end

	if DATA.player_block_status[_userId] then
		return 2158
	end

	local _user = PUBLIC.load_player_info(_userId)

	if not _user then
		return 1004
	end

	if _user.is_block == 1 then
		return 2158
	end

	if _user_data then
		PUBLIC.update_base_player_info(_userId,_user_data)
	else
		print("_user_data is nil,not update user info:",_channel_type,_userId,basefunc.tostring(_user_data))
	end

	--PUBLIC.update_verify_data(_channel_type,_verify_data.login_id,_verify_data)

	if not _user.player_info.name or "" == _user.player_info.name then
		print("error ,user name is nil:",_channel_type,_userId,basefunc.tostring(_user_data))
	end

	return 0
end

--math.randomseed( os.time() + os.clock() * 100000 ) -- 随机种子
function LF.gen_user_id(_login_id)

	if string.sub(_login_id,1,5) == "robot" or string.sub(_login_id,1,4) == "test" then
		return _login_id
	else
		local sysvar = DATA.system_variant

		sysvar.last_user_index = sysvar.last_user_index + math.random(3)

		-- 前2位暂时保留为 服务器id，以便以后分服
		return "10" .. tostring(sysvar.last_user_index)
	end
end

--[[
	创建玩家信息（新注册玩家时 使用）
	先检查 登录 id ，如果已经存在， 则直接直接返回 id
	参数：
	  	_register_data : （必须）用户注册数据。
			{
				channel_type=, (必须)渠道类型，参见 verify_service.lua
				introducer=, (可选) 推荐人的用户 id
				register_os=, (可选) 注册的操作系统
				register_ip=, (可选)注册的ip
			}
	  	_verify_data : （必须）验证结果数据，如果失败，则为错误号。
			{
				login_id=, (必须)登录id
				password=, (可选) 用户密码
				refresh_token=, (可选) 刷新凭据，某些渠道需要，比如微信
				extend_1=, (可选)扩展数据1
				extend_2=, (可选)扩展数据2
			}
	  	_user_data : （可选）用户数据
			{
				name=, (可选)昵称
				head_image=, (可选)头像
				sex = (可选)性别
				sign=, (可选)签名
			}
	多个返回值：
		userId      成功返回用户 id；失败 返回 nil
		error_code  错误代码（用户 id 为 nil 时）；
]]
function CMD.create_player_info(_register_data,_user_data)


	if basefunc.from_keys(LD.creating_login_id,_register_data.platform,_register_data.channel_type,_register_data.login_id) then
		print("channel login id is creating:",_register_data.login_id)
		return nil,1038
	end

	-- 开始创建，锁定 login_id
	basefunc.to_keys(LD.creating_login_id,true,_register_data.platform,_register_data.channel_type,_register_data.login_id)

	local userId = LF.gen_user_id(_register_data.login_id)

	-- 添加到用户数据缓存
	_user_data = _user_data or {}
	_user_data.id = userId
	_user_data.sync_seq = PUBLIC.auto_inc_id("last_player_info_seq")
	--_user_data.introducer = _register_data.introducer
	_user_data.kind = _register_data.channel_type=="robot" and "robot" or "normal"
	_user_data.name = _user_data.name or "未登录用户"
	local player_info = {
		player_info = _user_data,
		player_prop = {},
		object_data = {},
		player_device_info = {},
		--player_verify = _verify_data,
		player_match_water = {},
		player_login_stat = {},
	}

	PROTECTED.player_info:add_or_update_data( userId , player_info )

	-- 更新到数据库
	local sqls = {"start transaction;"}

	-- 表 player_info
	sqls[#sqls + 1] = PUBLIC.gen_insert_sql("player_info",_user_data)
	-- 表 player_register register_time
	local _reg_db_data =
	{
		id = userId,
		platform = _register_data.platform,
		register_channel = _register_data.channel_type,
		login_id = _register_data.login_id,
		introducer = _register_data.introducer,
		market_channel = _register_data.market_channel,
		register_ip = _register_data.register_ip,
		register_os = _register_data.register_os,
		share_sources = _register_data.share_source,
		device_id = _register_data.device_id,
		register_time = os.date("%Y-%m-%d %H:%M:%S"),
	}
	sqls[#sqls + 1] = PUBLIC.gen_insert_sql("player_register",_reg_db_data)

	sqls[#sqls + 1] = "commit;"

	DATA.sql_queue_fast:push_back(table.concat(sqls,"\n"))

	-- 解除锁定
	basefunc.to_keys(LD.creating_login_id,nil,_register_data.platform,_register_data.channel_type,_register_data.login_id)

	PUBLIC.all_player_status[userId] = {status="off",time=os.time(),channel=_register_data.channel_type}

	local login_config = nodefunc.get_global_config("login_config")
	if _register_data.channel_type and login_config.real_channel[_register_data.channel_type] then
		monitor_lib.add_data("register",1)
	end

	if _register_data.channel_type == "phone" then
		PUBLIC.add_bind_phone_number_base(userId,_register_data.login_id,_register_data.platform)
	end

	--- 注册表的缓存
	--PUBLIC.player_info[userId].player_register = _reg_db_data
	player_info.player_register = _reg_db_data

	--_reg_db_data.register_time = os.date("%Y-%m-%d %H:%M:%S")

	return userId
end

-- 得到玩家信息
-- 参数：
--	_table_name 表名字，可选； 如果没给出，则返回所有数据
--	_field_name 字段名字，字符串 或 lua 表（多个字段名）； 如果为 nil ，则返回表的所有字段；
-- 返回
--	如果 _field_name 是一个字段名，则直接返回 值
--	如果 _field_name 是多个字段名的数组，则返回一个 键-值 表
--	出错则返回一个 nil
function CMD.get_player_info(_userId,_table_name,_field_name)
	local user = PUBLIC.load_player_info(_userId)

	if not user then
		warning(string.format("get_player_info %s error:not found player '%s'",tostring(_table_name),tostring(_userId)))
		return nil
	end

	-- 表名为空，返回所有数据
	if not _table_name then
		return user
	end

	local tdata = user[_table_name]
	if not tdata then
		warning(string.format("get user '%s' data error: table '%s' not found!",tostring(_userId),tostring(_table_name)))
		return nil
	end

	-- 字段名为空，返回表的所有字段
	if not _field_name then
		return tdata
	end

	-- 返回多个字段值
	if "table" == type(_field_name) then
		local ret = {}
		for _,fname in pairs(_field_name) do
			ret[fname] = tdata[fname]
		end
		return ret
	end

	-- 返回单一的值
	return tdata[_field_name]

end

-- 函数保存到 local ，会快一点
local get_player_info = CMD.get_player_info
local change_player_asset = PROTECTED.change_player_asset

function CMD.query_asset(_palyer_id,_asset_type)
	-- 从数据库载入到缓存
	local user = PUBLIC.load_player_info(_palyer_id)

	if not user then
		warning("CMD.query_asset error,not found player id:",_palyer_id)
	end

	local obj_num = user.player_prop[_asset_type] and user.player_prop[_asset_type].prop_count or nil

	if not obj_num then
		obj_num = 0

		if user.object_data and type(user.object_data) == "table" then
			for obj_id , data in pairs(user.object_data) do
				if data.object_type == _asset_type then
					obj_num = obj_num + 1
				end
			end
		end
	end

	return obj_num
end

-- 修改玩家信息
-- 参数：
--	_table_name 表名字
--	_values 字段名-值的 映射： {name1 = value1,...} 。注意：这些字段必须是同一个表的
--	_sql_fast 是否插入到高速 sql 队列，默认插入到 低速 队列
--	_not_inc_seq 不增长更新序号
-- 注意：此函数不支持更新带有子键的 表
-- 返回值： 0 或 错误号
function CMD.modify_player_info(_userId,_table_name,_values,_sql_fast,_not_inc_seq)

	local fname1 = next(_values)
	if not fname1 then
		return 1001
	end

	if not _table_name then
		skynet.fail("_table_name cannt be nil !")
		return 1001
	end

	-- 不允许对财富、道具直接修改
	if _table_name == "player_prop" then
		return 1001
	end

	-- 从数据库载入到缓存
	local user = PUBLIC.load_player_info(_userId)

	if not user then
		print(string.format("modify_player_info %s error:not found player '%s'",tostring(_table_name),tostring(_userId)))
		return 1004
	end

	local tdata = user[_table_name]
	if not tdata then
		skynet.fail(string.format("update_player_info error:table %s data not found!",_table_name))
		return 1001
	end

	local sql

	if tdata.id then	-- id 存在，则为更新

		local up_set_sql = {}
		for k,v in pairs(_values) do
			-- 修改缓存值

			if tdata[k] ~= v then
				tdata[k] = v

				-- 生成 sql
				up_set_sql[#up_set_sql + 1] = string.format("%s=%s",k,PUBLIC.value_to_sql(v))
			end

		end

		if not up_set_sql[1] then
			return 0
		end

		if not _not_inc_seq then
			up_set_sql[#up_set_sql + 1] = string.format("sync_seq=%d",PUBLIC.auto_inc_id("last_player_info_seq"))
		end

		sql = string.format("update %s set %s where id='%s';",
			_table_name,table.concat(up_set_sql,","),_userId)

	else 			-- id 不存在，则为 新增

		local sql_fields = {"id"}
		local sql_values = {"'" .. _userId .. "'"}

		tdata.id = _userId
		for k,v in pairs(_values) do
			tdata[k] = v

			sql_fields[#sql_fields + 1] = "`" .. k .. "`"
			sql_values[#sql_values + 1] = PUBLIC.value_to_sql(v)
		end

		sql = string.format("insert into %s(%s) values(%s)",
			_table_name,table.concat(sql_fields,","),table.concat(sql_values,","))

	end

	local _qtype,_sql_id = CMD.db_exec(sql,_sql_fast and "fast" or "slow")
	PROTECTED.player_info:update_sql_queue_data(_userId,_qtype,_sql_id)

	return 0
end


-- 记牌器改变
function CMD.change_jipaiqi(_userId,_assetType,_change,...)

	-- 从数据库载入到缓存
	local user = PUBLIC.load_player_info(_userId)

	if not user then
		print(string.format("change_jipaiqi error:not found player '%s'",tostring(_userId)))
		return nil -- 玩家数据加载失败
	end

	if not _change then
		return nil
	end

	local object_data = user.object_data

	local jipaiqi_data = {}

	for object_id,d in pairs(object_data) do

		if d.object_type == "jipaiqi" then

			jipaiqi_data.object_id = object_id
			jipaiqi_data.valid_time = 0

			if d.attribute.valid_time then
				jipaiqi_data.valid_time = tonumber(d.attribute.valid_time)
			elseif d.attribute.always then
				-- 暂无
			end

		end

	end

	local time = 0

	if jipaiqi_data.object_id then

		time = os.time() + math.floor(_change*3600*24)

		if jipaiqi_data.valid_time > os.time() then
			time = jipaiqi_data.valid_time + math.floor(_change*3600*24)
		end

	else
		time = os.time() + math.floor(_change*3600*24)
	end

	local _obj_data =
	{
		player_id = _userId,
		object_id = jipaiqi_data.object_id,
		object_type = "jipaiqi",
		attribute = {valid_time=time},
	}
	CMD.change_object(_userId,_obj_data,true,...)

	return _obj_data
end



-- 修改财物和道具
function CMD.change_asset(_userId,_assetType,_change_value,...)

	local func = nil

	func = CMD.change_prop
	
	print("xxx------------------change_asset__1")

	if not func then
		skynet.fail(string.format("change asset error:not found asset type '%s'",_assetType))
		return false
	end

	print("xxx------------------change_asset__2")

	return func(_userId,_assetType,_change_value,...)
end

-- 修改财物和道具并且向玩家发送消息(通常是其他外部服务对玩家资产进行操作)
-- 记牌器还是普通资产一样调用 按数量计算一天的时间多个的时候进行累加
-- 不支持obj类型的道具 走(multi_change_asset_and_sendMsg 函数)
function CMD.change_asset_and_sendMsg(_userId,_assetType,_change_value,_change_type,...)

	-- 折扣资产转换
	local da = basefunc.get_discount_asset(_assetType)
	if da then
		skynet.send(DATA.service_config.asset_discount_record_center_service,"lua"
												,"add_player_discount_asset"
												,_userId
												,da
												,_change_value)
		_assetType = da
	end

	local ret = CMD.change_asset(_userId,_assetType,_change_value,_change_type,...)
	if ret then
		local jpq_id = nil
		if _assetType == "jipaiqi" then
			jpq_id = ret.object_id
		end
		nodefunc.send(_userId,"multi_asset_on_change_msg",{[1]={asset_type=_assetType,value=_change_value,object_id=jpq_id}},_change_type)
	end
end

--[[修改财物和道具并且向玩家发送消息(通常是其他外部服务对玩家资产进行操作)
-- 记牌器还是普通资产一样调用 按数量计算一天的时间多个的时候进行累加
_asset_data={
		{asset_type=jing_bi,value=100},
		{asset_type=object_tick,value=o20125a1d21s,attribute={valid_time=123}},(增加减少道具都只能一个一个来)
	}
]]
function CMD.multi_change_asset_and_sendMsg(_userId,_asset_datas,_change_type,...)

	--[[折扣资产合并
		local discount_asset_hash = {}
		-- 折扣资产剔出
		for i=#_asset_datas,1,-1 do
			local asset = _asset_datas[i]
			local da = basefunc.get_discount_asset(asset.asset_type)
			if da then
				skynet.send(DATA.service_config.asset_discount_record_center_service,"lua"
														,"add_player_discount_asset"
														,_userId
														,da
														,asset.value)
				table.remove(_asset_datas,i)
				discount_asset_hash[da] = (discount_asset_hash[da] or 0) + asset.value
			end
		end

		-- 折扣资产转进行合并或追加
		if next(discount_asset_hash) then

			for i,asset in ipairs(_asset_datas) do
				if discount_asset_hash[asset.asset_type] then
					asset.value = asset.value + discount_asset_hash[asset.asset_type]
					discount_asset_hash[asset.asset_type] = nil
				end
			end

			for k,v in pairs(discount_asset_hash) do
				table.insert(_asset_datas,{asset_type=k,value=v,})
			end

		end
	]]

	-- 折扣资产转换
	for i,asset in ipairs(_asset_datas) do
		local da = basefunc.get_discount_asset(asset.asset_type)
		if da then
			skynet.send(DATA.service_config.asset_discount_record_center_service,"lua"
													,"add_player_discount_asset"
													,_userId
													,da
													,asset.value)
			asset.asset_type = da
		end
	end


	local asset_datas_result = {}

	for i,asset in ipairs(_asset_datas) do

		if tonumber(asset.value) then

			local ret = CMD.change_asset(_userId,asset.asset_type,asset.value,_change_type,...)

			if not ret then
				error("CMD.multi_change_asset_and_sendMsg".._userId)
				--dump(_asset_datas)
				return
			end

			local jpq_id = nil
			if asset.asset_type == "jipaiqi" then
				jpq_id = ret.object_id
			end
			asset.object_id = jpq_id

			table.insert(asset_datas_result,asset)
		else

			if asset.asset_type == "jipaiqi" then
				error("error add jipaiqi error")
			end

			local obj_num = 1
			-- 新增obj道具时考虑数量
			if not asset.value and asset.attribute then
				obj_num = asset.num or 1
			end

			local as = basefunc.copy(asset)
			as.num = nil

			for i=1,obj_num do

				local _obj_data =
				{
					player_id = _userId,
					object_type = as.asset_type,
					object_id = as.value,
					attribute = as.attribute,
				}

				CMD.change_object(_userId,_obj_data,true,_change_type,...)

				local ao = basefunc.copy(as)
				ao.value = _obj_data.object_id

				table.insert(asset_datas_result,ao)
			end

		end

	end

	if next(asset_datas_result) then
		nodefunc.send(_userId,"multi_asset_on_change_msg",asset_datas_result,_change_type,...)
	end

end


----------------------------------------------------------------------------------------------------
-- 修改不可重叠的物品道具 内部实现仍然是调用的 multi_asset_on_change_msg 接口

--[[
{
	object_id = xx21s2aw,
	object_type = _type, --新增时需要
	attribute = _data, -- nil 代表删除此物品
}
]]
function CMD.change_object(_userId,_obj_data,_not_send_msg,...)

	local user = PUBLIC.load_player_info(_userId)

	if not user then
		print(string.format("change_object error:not found player '%s'",tostring(_userId)))
		return nil -- 玩家数据加载失败
	end

	user.object_data = user.object_data or {}

	local obj = user.object_data[_obj_data.object_id]

	if obj then

		if _obj_data.attribute then

			if type(_obj_data.attribute)~="table"
				or not next(_obj_data.attribute) then

					print("update object error attribute is error or empty ")
					return
			end

			user.object_data[_obj_data.object_id].attribute = _obj_data.attribute
			local d = {
				player_id = _userId,
				object_id = _obj_data.object_id,
				object_type = _obj_data.object_type,
				attribute = _obj_data.attribute,
			}
			CMD.update_object_data(d,...)

		else

			user.object_data[_obj_data.object_id] = nil
			local d = {
				player_id = _userId,
				object_id = _obj_data.object_id,
				object_type = _obj_data.object_type,
			}
			CMD.delete_object_data(d,...)

		end

	else

		if not _obj_data.attribute
			or not _obj_data.object_type
			or type(_obj_data.attribute)~="table"
			or not next(_obj_data.attribute) then

				print("add object error attribute is nil or empty 1 ")
				return
		end

		local d = {
			player_id = _userId,
			object_type = _obj_data.object_type,
			attribute = _obj_data.attribute,
		}
		_obj_data.object_id = CMD.insert_object_data(d,...)

		user.object_data[_obj_data.object_id] = _obj_data

	end

	if not _not_send_msg then
		nodefunc.send(_userId,"multi_asset_on_change_msg",{[1]={
				asset_type = _obj_data.object_type,
				value = _obj_data.object_id,
				attribute = _obj_data.attribute,
			}}
			,...)
	end

	return _obj_data
end


function CMD.multi_change_object(_userId,_obj_datas,_not_send_msg,...)

	local asset_datas = {}

	for i,_obj_data in pairs(_obj_datas) do
		CMD.change_object(_userId,_obj_data,true,...)

		if not _not_send_msg then
			asset_datas[#asset_datas+1] =
			{
				asset_type = _obj_data.object_type,
				value = _obj_data.object_id,
				attribute = _obj_data.attribute,
			}
		end

	end

	if not _not_send_msg then
		nodefunc.send(_userId,"multi_asset_on_change_msg",asset_datas,...)
	end

end



----------------------------------------------------------------------------------------------------



-- 修改财物和道具并且向玩家发送消息 为 兑换码设计的
function CMD.give_assets_packet_by_redeem_code(_userId,_code,_change_type,_asset_datas)

	CMD.multi_change_asset_and_sendMsg(_userId,_asset_datas
				,ASSET_CHANGE_TYPE.REDEEM_CODE_AWARD,_change_type,"redeem_code",_code)

end



-- 得到道具数量
--	出错则返回一个 nil
function CMD.get_prop(_userId,_prop_type)
	local user = PUBLIC.load_player_info(_userId)
	if not user then
		print(string.format("get_prop %s error:not found player '%s'",tostring(_prop_type),tostring(_userId)))
		return nil
	end

	local prop_data = user.player_prop[_prop_type]
	return prop_data and prop_data.prop_count or 0 -- 没有道具数据 则为 0
end

-- 修改  面额
--	成功，则返回新的值； 失败返回 nil
function CMD.change_shop_gold_face(_userId,_prop_type,_change,_change_type,_change_id,_change_way,_change_way_id)

	return CMD.change_shop_gold_sum(_userId,"shop_gold_sum",SHOP_GOLD_FACEVALUES[_prop_type] * _change,
		_change_type,_change_id,_change_way,_change_way_id)
end

-- 修改道具
--	成功，则返回新的值； 失败返回 nil
function CMD.change_prop(_userId,_prop_type,_change,_change_type,_change_id,_change_way,_change_way_id)
	print("xxx------------------change_prop__1",_userId,_prop_type,_change,_change_type,_change_id,_change_way,_change_way_id)
	-- 从数据库载入到缓存
	local user = PUBLIC.load_player_info(_userId)

	if not user then
		print(string.format("change_prop %s error:not found player '%s'",tostring(_prop_type),tostring(_userId)))
		print("xxx------------------change_prop__2")
		return nil -- 玩家数据加载失败
	end

	print("xxx------------------change_prop__3")
	if not _change then
		return nil
	end
	print("xxx------------------change_prop__4")
	if 0 == _change then
		return true -- 不用改变 也认为是成功
	end
	print("xxx------------------change_prop__5")

	local prop_data = user.player_prop[_prop_type]
	if not prop_data then
		prop_data = {prop_count = 0,id=_userId,prop_type=_prop_type }
		user.player_prop[_prop_type] = prop_data
	end

	local new_value = prop_data.prop_count + _change
	if new_value < 0 then
		skynet.fail(string.format("change_prop %s error:player '%s' ,cur %s,inc %s,less zero!!",
			tostring(_prop_type),tostring(_userId),prop_data.prop_count , _change))
		return nil
	end

	print("xxx------------------change_prop__6")

	prop_data.prop_count = new_value

	-- 对值的修改加到快速队列
	local sql = string.format("INSERT INTO player_prop(id,prop_type,prop_count)VALUES('%s','%s',%f) on duplicate key update prop_count=prop_count + %f;",
		_userId,_prop_type,prop_data.prop_count,_change)
	--DATA.sql_queue_fast:push_back(sql)
	---- 更新内存管理器
	local _qtype,_sql_id = CMD.db_exec(sql)
	PROTECTED.player_info:update_sql_queue_data(_userId,_qtype,_sql_id)

	-- 日志 加到慢速队列
	sql = string.format("insert into player_prop_log(id,prop_type,change_value,change_type,current,change_id,shop_gold_sync_seq,change_way,change_way_id) values ('%s','%s',%f,'%s',%f,'%s',%s,'%s','%s')",
		_userId,_prop_type,_change or 0,_change_type,prop_data.prop_count,_change_id,tostring(LF.get_asset_log_id(_prop_type)),_change_way or "",_change_way_id or 0)
	DATA.sql_queue_slow:push_back(sql)

	print("xxx------------------change_prop__7")

	return true
end


-- 判断用户是否存在： 返回 true/false
-- 参数 _userId 可以是 一个 id  或数组；是数组 则任何一个不存在 均返回 false
function CMD.is_player_exists(_userId)

	if not _userId then
		return false
	elseif "string" == type(_userId) then
		return PUBLIC.all_player_status[_userId] and true or false
	else
		for _,_id in ipairs(_userId) do
			if not PUBLIC.all_player_status[_id] then
				return false
			end
		end

		return true
	end
end

-- 玩家是否在线： 返回 true/false
-- 参数 _userId 可以是 一个 id  或数组；是数组 则任何一个不在线 均返回 false
function CMD.is_player_online(_userId)
	if "string" == type(_userId) then
		return PUBLIC.all_player_status[_userId] and PUBLIC.all_player_status[_userId].status == "on" and true or false
	else
		for _,_id in ipairs(_userId) do
			if PUBLIC.all_player_status[_id] and PUBLIC.all_player_status[_id].status ~= "on" then
				return false
			end
		end

		return true
	end
end

--- add by wss
-- 获得一个玩家的最后一次登录的时间
function CMD.get_player_status_time( player_id )
	return PUBLIC.all_player_status[player_id] and PUBLIC.all_player_status[player_id].time or nil
end

-- 查询用户列表
function CMD.get_player_status_list()

	-- status = on / off

	return PUBLIC.all_player_status

end

--[[筛选 用户列表
	_online ： 0-离线的 1-在线的 other-不限
	_tuoguan - 0-不要托管 1-只要托管 other-不限
	_only_id - true-只要id other-原始数据
]]
function CMD.select_players_list(_online,_tuoguan,_only_id)

	-- status = on / off
	local players_list = {}

	for player_id,data in pairs(PUBLIC.all_player_status) do

		local ok = true

		if _online == 0 then
			if data.status ~= "off" then
				ok = false
			end
		elseif _online == 1 then
			if data.status ~= "on" then
				ok = false
			end
		end

		if _tuoguan == 0 then
			if not basefunc.is_real_player(player_id) then
				ok = false
			end
		elseif _tuoguan == 1 then
			if basefunc.is_real_player(player_id) then
				ok = false
			end
		end


		if ok then

			if _only_id then
				players_list[#players_list+1] = player_id
			else
				players_list[#players_list+1] = data
			end

		end

	end

	return players_list

end


-- 用户登录：记录日志
function CMD.player_login(_userId,_login_ip,_login_os)

	local pstatus = PUBLIC.all_player_status[_userId]
	if not pstatus then
		print("data service login error, user not exists:",_userId,_login_ip,_login_os)
		return
	end

	local login_config = nodefunc.get_global_config("login_config")

	local _vs_data = skynet.call(DATA.service_config.verify_service,"lua","get_verify_status_data",_userId,"verify")
	local _channel = _vs_data and _vs_data.verify_channel or "unknow"
	if login_config.real_channel[_channel] then
		monitor_lib.add_data("login",1)
	end

	if "on" == pstatus.status then
		if pstatus.channel ~= _channel then -- 切换了渠道，原渠道计数减 1
			PUBLIC.onine_player_count[pstatus.channel] = (PUBLIC.onine_player_count[pstatus.channel] or 1) - 1
		end
	else
		PUBLIC.onine_player_count[_channel] = (PUBLIC.onine_player_count[_channel] or 0) + 1
	end

	pstatus.status = "on"
	pstatus.channel = _channel
	pstatus.time = os.time()

	local sql = string.format("CALL sp_login('%s','%s','%s');",_userId,_login_ip or "",_login_os or "") ..

			-- 增长更新序号
			string.format("update player_info set sync_seq=%d where id='%s';",PUBLIC.auto_inc_id("last_player_info_seq"),_userId)

	DATA.sql_queue_slow:push_back(sql)

end

function CMD.get_online_count()
	return PUBLIC.onine_player_count
end

-- 用户登出： 记录日志
function CMD.player_logout(_userId)

	local pstatus = PUBLIC.all_player_status[_userId]
	if not pstatus then
		print("data service logout error, user not exists:",_userId)
		return
	end

	if "on" == pstatus.status then
		local _channel = pstatus.channel or "unknown"
		PUBLIC.onine_player_count[_channel] = math.max((PUBLIC.onine_player_count[_channel] or 0) - 1,0)
	end

	local _login_time = pstatus.time or os.time()
	---- 更新内存
	local user = PUBLIC.load_player_info(_userId)
	local di = user and user.player_login_stat
	if di and di.last_login_time then
		di.last_login_time = _login_time
	end

	CMD.set_orig_variant(_userId,"last_login_time",_login_time)

	pstatus.status = "off"
	pstatus.channel = nil
	pstatus.time = os.time()

	skynet.call(DATA.service_config.verify_service,"lua","clear_verify_status_data",_userId)

	local sql = string.format("CALL sp_logout('%s',FROM_UNIXTIME(%d));",_userId,_login_time)
	DATA.sql_queue_slow:push_back(sql)

end


-------------------------------------------------- 玩家的额外数据的处理 ↓ ------------------------------------------------
-- 玩家的扩展活动清理内存中
function CMD.clear_player_ext_data_in_memory(_userId,_type)

	local player_data = PROTECTED.player_ext_status:get_data( _userId )

	if _type and player_data and player_data[_type]then
		--- 如果压根就没有这个数据
		player_data[_type] = nil
	end
end

-- 玩家的扩展活动完成
function CMD.update_player_ext_data(_userId,_type,_value,_time)

	local s = CMD.query_player_ext_status(_userId,_type)

	if s.status == _value then

		if not _time or s.time == _time then

			-- 数据相同 不需要更新
			return

		end

	end

	s.status = _value
	s.time = _time or os.time()

	local sql = string.format([[
								SET @_player_id = '%s';
								SET @_type = '%s';
								SET @_status = %s;
								SET @_time = FROM_UNIXTIME(%u);
								insert into player_ext_status(player_id,type,status,time)
								values(@_player_id,@_type,@_status,@_time)
								on duplicate key update
								status = @_status,
								time = @_time;
								]]
								,_userId
								,_type
								,_value
								,s.time)
	--DATA.sql_queue_fast:push_back(sql)

	local _queue_type , _queue_id = CMD.db_exec(sql , "fast")

	PROTECTED.player_ext_status:update_sql_queue_data( _userId , _queue_type , _queue_id  )

end


--[[
	请求一个玩家的 扩展 数据
]]
function CMD.query_player_ext_status(_userId,_type)

	local player_data = PROTECTED.player_ext_status:get_data( _userId )

	if not player_data then
		player_data = {}
		PROTECTED.player_ext_status:add_or_update_data(_userId , player_data)
	end

	if _type then
		--- 如果压根就没有这个数据
		if not player_data[_type] then
			player_data[_type] = {}
			player_data[_type].player_id = _userId
			player_data[_type].type = _type
			player_data[_type].status = 0
			player_data[_type].time = 0

			--- 内存中已经修改，不用改数据库
			--CMD.update_player_ext_data(_userId,_type,0)
		end
		return player_data[_type]
	else
		return player_data
	end

end
-------------------------------------------------- 玩家的额外数据的处理 ↑ ------------------------------------------------


return PROTECTED









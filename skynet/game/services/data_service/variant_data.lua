--
-- Author: lyx
-- Date: 2019/12/6
-- Time: 19:59
-- 说明：用于标签，权限计算 的数据存储
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require "common_data_manager_lib"

local CMD = base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LF = base.LocalFunc("variant_data")

function LF.load_base_data(_player_id)
	---- vip_level
	--local vip_level = skynet.call( DATA.service_config.new_vip_center_service , "lua" , "query_player_vip_level" , _player_id )
	local vip_level = 0
	---- first_login_time 
	local first_login_time = 0
	---- pay_sum
	local pay_sum = CMD.get_orig_variant(_player_id,"pay_sum") or 0
	---- max_pay
	local max_pay = CMD.get_orig_variant(_player_id,"max_pay") or 0
	---- 回归时间
	local regress_time = CMD.get_orig_variant(_player_id,"regress_time") or 0
	--[[---- tag_vec
	local tag_vec = skynet.call( DATA.service_config.tag_center , "lua" , "get_player_tag_list" , _player_id )
	dump(tag_vec,"xxx--------------tag_vec:".._player_id)--]]
	
	local last_login_time = CMD.get_player_info(_player_id,"player_login_stat","last_login_time")
	if type(last_login_time) == "string" and #last_login_time > 0 then
		last_login_time = basefunc.get_time_by_date(last_login_time) or 0
	else
		last_login_time = 0
	end

	return {
		vip_level = vip_level,
		first_login_time = first_login_time,
		pay_sum = pay_sum,
		max_pay = max_pay,
		regress_time = regress_time,
		--tag_vec = tag_vec,
		register_time = basefunc.get_time_by_date(CMD.get_player_info(_player_id,"player_register","register_time")),
		market_channel = CMD.get_player_info(_player_id,"player_register","market_channel"),

		last_login_time = last_login_time,
	}
end

local LD = base.LocalData("variant_data",{
	---- 基础数据的内存管理
	base_data = basefunc.hot_class.data_manager_cls.new( { 
															load_data = function(...) return LF.load_base_data(...) end , 
														} 
														, tonumber(skynet.getenv("data_man_cache_size")) or 40000 ) ,


})

------ 用于计算 参考变量的函数
local VarFuncs = base.LocalFunc("variant_data_VarFuncs")

--- vip等级
function VarFuncs.vip_level(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.vip_level
end
---- 距离第一次登录的秒数
function VarFuncs.acount_age(_player_id)
	local player_data = LD.base_data:get_data(_player_id)
	local now_time = os.time()
	return now_time - player_data.first_login_time
end
---- 第一次登录时间
function VarFuncs.first_login_time(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.first_login_time
end
---- 总共的支付金额
function VarFuncs.pay_sum(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.pay_sum
end
---- 最大的支付金额
function VarFuncs.max_pay(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.max_pay
end
---- 渠道
function VarFuncs.market_channel(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.market_channel
end
---- 注册时间
function VarFuncs.register_time(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.register_time
end
---- 上次登录时间
function VarFuncs.last_login_time(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.last_login_time
end
---- 距离上次登录时间的秒数
function VarFuncs.last_login_time_dist(_player_id)
	local player_data = LD.base_data:get_data(_player_id)
	local now_time = os.time()
	return now_time - player_data.last_login_time
end
---- 回归时间
function VarFuncs.regress_time(_player_id)
	local player_data = LD.base_data:get_data(_player_id)

	return player_data.regress_time
end

---- 当前距离回归时间的秒数
function VarFuncs.regress_time_dist(_player_id)
	local player_data = LD.base_data:get_data(_player_id)
	local now_time = os.time()
	return now_time - VarFuncs.regress_time(_player_id)
end

--[[function VarFuncs.tag_vec(_player_id)
	local player_data = LD.base_data:get_data(_player_id )

	if not player_data.tag_vec then
		local tag_vec = skynet.call( DATA.service_config.tag_center , "lua" , "get_player_tag_list" , _player_id )
		player_data.tag_vec = tag_vec
	end

	return player_data.tag_vec
end--]]


function CMD.get_player_variants(_player_id , _exclude_variants )
	local ret = {}

	for k,v in pairs(VarFuncs) do

		if not _exclude_variants or not _exclude_variants[k] then
			ret[k] = v(_player_id )
		end
	end
	return ret
end

---------------------------------- 处理一个基础参考量的改变
function LF.on_base_data_change(_player_id , _old_variants , _change_variant_key)
	local new_variants = CMD.get_player_variants(_player_id)
	--dump(_old_variants , "xxx-----------on_base_data_change,_old_variants " .. _change_variant_key)
	--dump(new_variants , "xxx-----------on_base_data_change,new_variants " .. _change_variant_key)
	--print("xxx--------------on_base_data_change:",_player_id , _old_variants , _change_variant_key)
	local is_same = basefunc.compare_vaule_same( _old_variants , new_variants )
	
	if not is_same then
		--print("xxx--------------on_base_data_change22:",_player_id , _old_variants , _change_variant_key)
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , 
			{ name = "tag_data_variants_change_msg" , send_filter = { player_id = _player_id } } , 
			_player_id , new_variants , _change_variant_key)
	end
end

function CMD.trigger_base_data_change(_player_id , _old_variants , _change_variant_key)
	LF.on_base_data_change(_player_id , _old_variants , _change_variant_key)
end

------------------------------------------------------------------------------- ↓↓ 改变处理函数 ↓↓ ----------------------------------------------

function LF.deal_var_change(_player_id,_var_name,_value)
	local old_variants = CMD.get_player_variants(_player_id)
	--dump(old_variants , "xxx-----------deal_var_change,old")
	local player_data = LD.base_data:get_data(_player_id)
	player_data[_var_name] = _value

	LF.on_base_data_change(_player_id , old_variants , _var_name)
end

function CMD.notify_var_change(_player_id,_value,_back_param)
	LF.deal_var_change(_player_id,_back_param,_value)
end

function CMD.on_vip_level_upgrade_msg(_player_id,_now_level,_old_level)
	--print("xxx------------on_vip_level_upgrade_msg:",_player_id,_now_level,_old_level)
	LF.deal_var_change(_player_id,"vip_level",_now_level)
end

function CMD.notify_common_orig_change(_player_id,_name,_value,_old_value)
	LF.deal_var_change(_player_id,_name,_value)
end

------------------------------------------------------------------------------ ↑↑ 改变处理函数 ↑↑ ----------------------------------------------

function LF.init()

	---- 监听所有的基础数据的改变

	--- vip等级改变
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "vip_level_upgrade" ,{
			msg_tag = DATA.msg_tag,    --- DATA.msg_tag  定义在data_service.lua 中
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "on_vip_level_upgrade_msg" , 
		})

	--- 标签改变
	--[[skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "player_tag_vec_changed" ,{
			msg_tag = DATA.msg_tag,    --- DATA.msg_tag  定义在data_service.lua 中
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "notify_var_change" , 
			back_param="tag_vec",
		})--]]

	-- 通用的 原始变量改变
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "variant_orig_changed" ,{
		msg_tag = DATA.msg_tag,    --- DATA.msg_tag  定义在data_service.lua 中
		node = skynet.getenv("my_node_name"),
		addr = skynet.self(),
		cmd = "notify_common_orig_change" , 
	})
end

return LF












--
-- Author: lyx
-- Date: 2019/12/6
-- Time: 19:59
-- 说明：变量存储管理（读取、存入数据库）
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require "common_data_manager_lib"
require "data_func"

local CMD = base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local LD = base.LocalData("variant_orig_data",{

	-- 变量数据： player_id => {var name => 值}
	variants = basefunc.server_class.data_manager_cls.new( {} , tonumber(skynet.getenv("data_man_cache_size")) or 80000 ),

})

local LF = base.LocalFunc("variant_orig_data")

function LF.init()
	
end

function LF.load_player_variants(_player_id)
	
	if LD.variants:get_data(_player_id) then return LD.variants:get_data(_player_id) end

	local _data = {}
	
	local ret = PUBLIC.db_query_va("select * from player_variant where player_id=%s",_player_id)
	if( ret.errno ) then
		error(string.format("load_player_variants sql error:%s\n",basefunc.tostring( ret )))
	end
	for _,v in ipairs(ret) do
		if v.int_value then
			_data[v.orig_variant] = v.int_value
		elseif v.str_value then
			_data[v.orig_variant] = v.str_value
		end
	end

	if LD.variants:get_data(_player_id) then return LD.variants:get_data(_player_id) end
	
	LD.variants:add_or_update_data( _player_id , _data )

	return _data
end

function CMD.get_orig_variant(_player_id,_name)

	local _data = LF.load_player_variants(_player_id)
	if not _data then
		print("get_orig_variant error:",_player_id,_name)
		return nil
	end

	if _name then
		return _data[_name]
	else
		return _data
	end
end

-- 设置变量值
-- 	_value 为 nil 表示删除
function CMD.set_orig_variant(_player_id,_name,_value,_no_trigger)
	local _data = LF.load_player_variants(_player_id)
	if not _data then
		print("set_orig_variant error:",_player_id,_name,_value)
		return
	end

	-- 不用修改
	if _data[_name] == _value then
		return
	end

	local _old_value = _data[_name]
	_data[_name] = _value

	local _sql
	if _value then
		local _up_data = {player_id=_player_id,orig_variant=_name}
		if type(_value) == "string" then
			_up_data.str_value = _value
		elseif type(_value) == "number" then
			_up_data.int_value = math.floor(_value + 0.5)
		else
			print("set_orig_variant value type error:",_player_id,_name,_value,type(_value))
			return
		end

		_sql = PUBLIC.safe_insert_sql("player_variant",_up_data,{"player_id","orig_variant"})
	else
		_sql = PUBLIC.format_sql("delete from player_variant where player_id=%s and orig_variant=%s;",_player_id,_name)
	end

	-- 写入数据库
	local _qtype,_sql_id = CMD.db_exec(_sql)
	LD.variants:update_sql_queue_data(_player_id,_qtype,_sql_id)

	-- 触发事件
	if not _no_trigger then
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , { 
			name = "variant_orig_changed" , 
			send_filter = { player_id = _player_id } } , 
			_player_id , 
			_name,
			_value,
			_old_value
		)
	end
end

return LF












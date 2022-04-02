--
-- Author: lyx
-- Date: 2018/4/19
-- Time: 19:59
-- 说明：斗地主的数据存储
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require"printfunc"
require "data_func"
require "common_data_manager_lib"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("player_object_data",{

	player_object_data = nil,

	object_attribute_data = nil,

	object_seq_id = 0,
})

local LF = base.LocalFunc("player_object_data")


function LF.load_one_player_object(_player_id)
	local sql = PUBLIC.format_sql( [[ select * from player_object where player_id = %s; ]] , _player_id )

	local ret = PUBLIC.query_data( sql )

	local tar_ret = {}

	if ret and type(ret) == "table" then
		for key,data in pairs(ret) do
			tar_ret[data.object_id] = data.object_type
		end
	end

	return tar_ret
end

LD.player_object_data = LD.player_object_data or basefunc.hot_class.data_manager_cls.new( { 
																load_data = function(...) return LF.load_one_player_object(...) end, 
															} 
														, tonumber(skynet.getenv("data_man_cache_size")) or 10000 ) 

--------------------------------------------------------------------------------------------
function LF.load_one_object_attribute_data(_object_id)
	local sql = PUBLIC.format_sql( [[ select * from object_attribute where object_id = %s; ]] , _object_id )

	local ret = PUBLIC.query_data( sql )

	local tar_ret = {}

	if ret and type(ret) == "table" then
		for key,data in pairs(ret) do
			tar_ret[data.attribute_name] = data.attribute_value
		end
	end

	return tar_ret
end

LD.object_attribute_data = LD.object_attribute_data or basefunc.hot_class.data_manager_cls.new( { 
																load_data = function(...) return LF.load_one_object_attribute_data(...) end, 
															} 
														, tonumber(skynet.getenv("data_man_cache_size")) or 10000 ) 

function LF.init_data()

	--[[local sql = "select * from player_object;"
	local ret = base.DATA.db_mysql:query(sql)
	if( ret.errno ) then
		skynet.fail(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
		return false
	end

	for i = 1,#ret do
		local row = ret[i]
		local pod = LD.player_object_data[row.player_id] or {}
		LD.player_object_data[row.player_id] = pod
		pod[row.object_id]=row.object_type
	end--]]


	--[[local sql = "select * from object_attribute;"
	local ret = base.DATA.db_mysql:query(sql)
	if( ret.errno ) then
		skynet.fail(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
		return false
	end

	for i = 1,#ret do
		local row = ret[i]
		local oad = LD.object_attribute_data[row.object_id] or {}
		LD.object_attribute_data[row.object_id] = oad
		oad[row.attribute_name] = row.attribute_value
	end--]]

	return true
end


-- 产生新的物品ID号
function LF.gen_object_id()

	LD.object_seq_id = LD.object_seq_id + 1

    if LD.object_seq_id > 999 then
    	LD.object_seq_id = 1
    end

    local ts = os.date("%Y%m%d%H%M%S")

    return string.format("o%s%s%s",ts,skynet.random_str(3),LD.object_seq_id)
end


--[[
	{
		"2018123456987xzsaf"={
			object_type = "prop_xzad",
			attribute={
				name=value,
				time=1254201364,
			}
		},
		"2018123456987xzsaf"={
			object_type = "prop_xzad",
			attribute={
				name=value,
				time=1254201364,
			}
		},
	}
]]
function CMD.query_player_object_data(_player_id)

	local d = {}
	--local pod = LD.player_object_data[_player_id]
	local pod = LD.player_object_data:get_data(_player_id)

	if pod then
		for object_id,object_type in pairs(pod) do
			local obj_attribute = LD.object_attribute_data:get_data( object_id )


			d[object_id]=
			{
				object_type = object_type,
				attribute = obj_attribute -- LD.object_attribute_data[object_id]
			}
		end
	end
	--dump(d,"d++++++")
	return d
end



--[[增加一个道具物品 (返回 object_id)
	_data = 
	{
		player_id = "1016524",
		object_type = "prop_xzad",

		attribute={
			name=value,
			time=1254201364,
		}
	}
]]
function CMD.insert_object_data(_data,...)
	
	_data.object_id = LF.gen_object_id()

	--local pod = LD.player_object_data[_data.player_id] or {}
	--LD.player_object_data[_data.player_id] = pod
	local pod = LD.player_object_data:get_data( _data.player_id )

	pod[_data.object_id] = _data.object_type

	
	--LD.object_attribute_data[_data.object_id] = _data.attribute
	LD.object_attribute_data:add_or_update_data( _data.object_id , _data.attribute )

	-- 只记录真人的
	if not basefunc.chk_player_is_real(_data.player_id) then
		return _data.object_id
	end

	local sql = PUBLIC.format_sql([[
					insert into player_object
					(player_id,object_id,object_type)
					values(%s,%s,%s);
				]]
				,_data.player_id,_data.object_id,_data.object_type)
	-----
	local queue_type,queue_id = PUBLIC.db_exec_call(sql)
	LD.player_object_data:update_sql_queue_data( _data.player_id , queue_type , queue_id)

	for k,v in pairs(_data.attribute) do
		
		local sql = PUBLIC.format_sql([[
						insert into object_attribute
						(object_id,attribute_name,attribute_value)
						values(%s,%s,%s);
					]]
		,_data.object_id,k,v)

		local queue_type,queue_id = PUBLIC.db_exec_call(sql)
		LD.object_attribute_data:update_sql_queue_data( _data.object_id , queue_type , queue_id)
	end

	LF.object_opt_log(_data.player_id,_data.object_id,_data.object_type,"add"
								,_data.attribute,nil,...)

	return _data.object_id
end



--[[修改一个道具物品(属性)
	_data = 
	{
		object_id = "2018123456987xzsaf",
		player_id = "1016524",
		object_type = "xcx",

		attribute={
			name=value,
			time=1254201364,
		}
	}
]]
function CMD.update_object_data(_data,...)

	-- 只记录真人的
	if not basefunc.chk_player_is_real(_data.player_id) then
		return
	end

	local obj_attribute = LD.object_attribute_data:get_data(_data.object_id)

	LF.object_opt_log(_data.player_id,_data.object_id,_data.object_type,"update"
								, obj_attribute ,_data.attribute,...)

	local delete_attribute = {}
	for k,v in pairs(obj_attribute) do
		if not _data.attribute[k] then
			delete_attribute[k]=true
		end
	end

	--LD.object_attribute_data[_data.object_id] = _data.attribute
	LD.object_attribute_data:add_or_update_data( _data.object_id , _data.attribute )

	for k,v in pairs(_data.attribute) do
		
		local sql = PUBLIC.format_sql([[
						SET @_object_id = %s;
						SET @_attribute_name = %s;
						SET @_attribute_value = %s;
						insert into object_attribute
						(object_id,attribute_name,attribute_value)
						values(@_object_id,@_attribute_name,@_attribute_value)
						on duplicate key update
						attribute_value = @_attribute_value;
					]]
		,_data.object_id,k,v)
		---
		local queue_type,queue_id = PUBLIC.db_exec_call(sql)
		LD.object_attribute_data:update_sql_queue_data( _data.object_id , queue_type , queue_id)
	end

	for k,v in pairs(delete_attribute) do
		
		local sql = PUBLIC.format_sql([[
						delete from object_attribute where object_id=%s and attribute_name=%s;
					]]
		,_data.object_id,k)

		local queue_type,queue_id = PUBLIC.db_exec_call(sql)
		LD.object_attribute_data:update_sql_queue_data( _data.object_id , queue_type , queue_id)
	end

end



--[[删除一个道具物品
	_data = 
	{
		object_id = "2018123456987xzsaf",
		player_id = "1016524",
		object_type = "xcx",
	}
]]
function CMD.delete_object_data(_data,...)

	-- 只记录真人的
	if not basefunc.chk_player_is_real(_data.player_id) then
		return
	end

	local obj_attribute = LD.object_attribute_data:get_data(_data.object_id)

	LF.object_opt_log(_data.player_id,_data.object_id,_data.object_type,"delete"
								, obj_attribute ,nil,...)

	--LD.player_object_data[_data.player_id][_data.object_id] = nil
	local player_object_data = LD.player_object_data:get_data( _data.player_id )
	player_object_data[_data.object_id] = nil

	--LD.object_attribute_data[_data.object_id] = nil
	LD.object_attribute_data:force_recover_data( _data.object_id )

	local sql = PUBLIC.format_sql([[
					delete from player_object where player_id=%s and object_id=%s;
				]]
	,_data.player_id,_data.object_id)
	-------
	local queue_type,queue_id = PUBLIC.db_exec_call(sql)
	LD.player_object_data:update_sql_queue_data( _data.player_id , queue_type , queue_id)

	local sql2 = PUBLIC.format_sql([[
					delete from object_attribute where object_id=%s;
				]]
	,_data.object_id)

	-------
	local queue_type,queue_id = PUBLIC.db_exec_call(sql2)
	LD.object_attribute_data:update_sql_queue_data( _data.object_id , queue_type , queue_id)

end

--[[

	player_id
	object_id
	object_type
	object_opt
	ori_attribute
	final_attribute
	time
	change_type
	change_id
	change_way
	change_way_id

]]

function LF.object_opt_log(_player_id,_object_id,_object_type,_object_opt,_ori_attribute,_final_attribute,_change_type,_change_id,_change_way,_change_way_id)
	
	if _ori_attribute then
		_ori_attribute = cjson.encode(_ori_attribute)
	end

	if _final_attribute then
		_final_attribute = cjson.encode(_final_attribute)
	end
	
	local sql = PUBLIC.format_sql([[
					insert into player_object_log
					(player_id,object_id,object_type,object_opt,ori_attribute,final_attribute
						,time,change_type,change_id,change_way,change_way_id)
					values(%s,%s,%s,%s,%s,%s,FROM_UNIXTIME(%s),%s,%s,%s,%s);
				]]
				,_player_id,_object_id,_object_type,_object_opt,_ori_attribute,_final_attribute
				,os.time(),_change_type,_change_id,_change_way,_change_way_id)
	

	base.DATA.sql_queue_slow:push_back(sql)

end




return LF
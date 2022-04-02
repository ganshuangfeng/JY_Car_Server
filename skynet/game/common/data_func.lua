--
-- Author: lyx
-- Date: 2018/3/22
-- Time: 16:06
-- 说明：玩家相关的基础数据

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local mysql = require "skynet.db.mysql"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- 处理 sql 的字符串值，避免被注入
function PUBLIC.sql_strv(_str)
	local _r = string.gsub(tostring(_str),"['\"\\]","\\%0")
	return _r
end
local sql_strv = PUBLIC.sql_strv

function PUBLIC.db_exec(_sql,_queue_name)
	if DATA.is_dbsvr then
		CMD.db_exec(_sql,_queue_name)
	else
		skynet.send(DATA.service_config.data_service,"lua","db_exec",_sql,_queue_name)
	end
end

function PUBLIC.db_exec_call(_sql,_queue_name)
    if DATA.is_dbsvr then
        return CMD.db_exec(_sql,_queue_name)
    else
	    return skynet.call(DATA.service_config.data_service,"lua","db_exec",_sql,_queue_name)
    end
end

function PUBLIC.db_exec_va(_fmt,...)
	PUBLIC.db_exec(PUBLIC.format_sql(_fmt,...))
end

--[[ 构造缓存数据
 参数：
 	_data_out 一个 lua 表，用于容纳输出的数据
	_rows 数据库中的行数据
	_table_name 数据表名称
	_sub_key_name 子健名

 说明：
 在 _data_out 中填充一个整理后的数据表，结构如下：
		table_name1 = {
			field_name1 = ,
			field_name2 = ,
			...
 		},
		table_name2 = {
			field_name1 = ,
			field_name2 = ,
			...
 		}
 		--多行的情况（ 必须给出 _sub_key_name）
		table_name3 = {
			_sub_key1 = { field_name1=,... },
			_sub_key2 = { field_name1=,... },
			...
 		}

--]]
function PUBLIC.gen_cache_data(_data_out,_rows,_table_name,_sub_key_name)

	local table_data = _data_out[_table_name] or {}
	_data_out[_table_name] = table_data

	if _sub_key_name then
		for _,row in ipairs(_rows) do
			local subkey = row[_sub_key_name]

			local sub_data = table_data[subkey] or {}
			table_data[subkey] = sub_data

			for k,v in pairs(row) do
				sub_data[k] = v
			end
		end

	elseif _rows[1] then

		for k,v in pairs(_rows[1]) do
			table_data[k] = v
		end

		if _rows[2] then
			skynet.fail(string.format("multi rows,must has sub key name:%s",_table_name))
		end
	end

end

-- 为 sql 结尾安全的加上分号
function PUBLIC.safe_sql_semicolon(_sql)
	if string.find(_sql,";%s*$") then
		return _sql
	else
		return _sql .. ";"
	end
end

--[[ 返回 sql 元数据信息：
    {
       type= "custom"/"insert"/"delete" ...
       name =  组/数据表/存储过程 名
       on_dup = 是否有 on duplicate key update 子句
       sql = 最终的 sql 
    }
    type,_info
--]]
function PUBLIC.get_sql_metadata(_sql)

    -- 自定义分类 ： 优先处理自定义分类。格式： {自定义分类名字} sql语句
    local _name,_real_sql = string.find(_sql,"^%s*{%s*([a-zA-Z0-9_]+)%s*}%s*(.*)")
    if _name then
        return {
            type = "custom",
            name = _name,
            sql = _real_sql,
        }
    end
    
    -- insert into
    _name = string.match(_sql,"[iI][nN][sS][eE][rR][tT]%s+[iI][nN][tT][oO][%s`]+([a-zA-Z0-9_]+)")
    if _name then
        return {
            type = "insert",
            name = _name,
            on_dup = string.find(_sql,"[oO][nN][%s`]+[dD][uU][pP][lL][iI][cC][aA][tT][eE][%s`]+[kK][eE][yY][%s`]+[uU][pP][dD][aA][tT][eE]"),
            sql = _sql,
        }
    end

    -- delete
    _name = string.match(_sql,"[dD][eE][lL][eE][tT][eE][%s`][fF][rR][oO][mM][%s`]+([a-zA-Z0-9_]+)")
    if _name then
        return {
            type = "delete",
            name = _name,
            sql = _sql,
        }
    end
    
    -- update ，注意：不支持多表 联合更新
    _name = string.match(_sql,"[uU][pP][dD][aA][tT][eE][%s`]+([a-zA-Z0-9_]+)[%s`]+[sS][eE][tT][%s`]+")
    if _name then
        return {
            type = "update",
            name = _name,
            sql = _sql,
        }
    end

    -- 存储过程
    _name = string.match(_sql,"[cC][aA][lL][lL][%s`]+([a-zA-Z0-9_]+)[%s`]*%(")
    if _name then
        return {
            type = "proc",
            name = _name,
            sql = _sql,
        }
    end

    return {
        type = "sql_chunk", -- 其他不可识别的 sql 语句块
        sql = _sql,
    }
end

-- 转换值为 sql 语句各式
function PUBLIC.value_to_sql(v)

	if not v then return "null" end

	if type(v) == "number" then
		return tostring(v)
	end

	-- 存在 __sql_expr 域
	if type(v) == "table" and v.__sql_expr then
		return type(v.__sql_expr) == "string" and v.__sql_expr or v.__sql_expr()
	end

	return table.concat({"'",sql_strv(v),"'"})
end
local value_to_sql = PUBLIC.value_to_sql

-- 格式化 sql 语句，会自动处理 空值、数据类型等
-- 注意：变量全用 %s 占位，并且不要加引号！！
function PUBLIC.format_sql(_str,...)
	local _param = {...}
	local _count = select("#",...)

	for i=1,_count do
		_param[i] = value_to_sql(_param[i])
	end
	
	return string.format(_str,table.unpack(_param,1,_count))
end

local function _is_prefix_letter(_str)
	if type(_str) ~= "string" or string.len(_str) < 1 then
		return false
	end

	local c = string.byte(_str)
	
end

-- 返回： true 要处理； false 不处理
-- 参数 _filter 明确返回 false 的才不会被处理（注意： 返回 nil 也会被处理）
-- 说明： 如果没有过滤器，下划线打头的不处理
local function check_field_filter(_name,_filter)
	if _filter then -- 有过滤器，按 过滤器处理
		if "table" == type(_filter) then
			return false ~= _filter[_name]
		else
			return false ~= _filter(_name)
		end 
	else
		return "_" ~= string.sub(_name,1,1)
	end
end

-- 根据给定的 键-值 对生成 sql 的 update set 子句
-- 参数 _filter ： （可选）过滤器表 或 函数;如果 返回 false，则不处理该字段; 注意：返回 nil 也会处理
-- 说明：下划线打头的字段不会处理
-- 返回值：如果没有字段更新，则返回空串 ""
function PUBLIC.gen_update_fields_sql(_fields,_filter)

	local _set_sql = {}

	for _name,_value in pairs(_fields) do
		if check_field_filter(_name,_filter) then
			_set_sql[#_set_sql + 1] = _name .. "=" .. value_to_sql(_value)
		end
	end

	return table.concat(_set_sql,",")
end

-- 根据给定的字段表，构造数据库插入语句
-- 说明：下划线打头的字段不会处理
function PUBLIC.gen_insert_sql(_table_name,_fields,_filter)
	local _names = {}
	local _values = {}

	for k,v in pairs(_fields) do
		if check_field_filter(k,_filter) then
			_names[#_names + 1] = tostring(k)
			_values[#_values + 1] = value_to_sql(v)
		end
	end

	return string.format("insert into %s (%s) values(%s);",tostring(_table_name),table.concat(_names,","),table.concat(_values,","))
end

-- 在 gen_insert_sql 基础上 增加 重复键 容错
-- 说明：下划线打头的字段不会处理
-- 参数 _pri_keys ： 主键名称，如果是多个，则为数组，格式： {key1,key2}
-- 参数 _addup_keys ： 更新行时，需要累计的 字段（而不是直接修改）
function PUBLIC.safe_insert_sql(_table_name,_fields,_pri_keys,_addup_keys,_filter)
	local _names = {}
	local _values = {}

	local _up_set = {}

	_pri_keys = _pri_keys or {}
	
	local _pks
	if "table" == type(_pri_keys) then
		_pks = {}
		for _,v in ipairs(_pri_keys) do
			_pks[v] = 1
		end
	elseif "string" == type(_pri_keys) then
		_pks = {[_pri_keys]=1}
	else
		error(string.format("'gen_safe_insert_sql' ,table '%s' primary key error:%s",tostring(_table_name),tostring(_pri_keys)))
	end

	for k,v in pairs(_fields) do
		if check_field_filter(k,_filter) then
			_names[#_names + 1] = tostring(k)
			_values[#_values + 1] = value_to_sql(v)

			if not _pks[k] then
				if _addup_keys and _addup_keys[k] then
					_up_set[#_up_set + 1] = string.format("%s=ifnull(%s,0)+%s",tostring(k),tostring(k),_values[#_values])
				else
					_up_set[#_up_set + 1] = string.format("%s=%s",tostring(k),_values[#_values])
				end
			end
		end
	end

	return string.format("insert into %s (%s) values(%s) on duplicate key update %s;",
		tostring(_table_name),table.concat(_names,","),table.concat(_values,","),table.concat(_up_set,","))
end

-- 执行查询语句
-- 参数：
--	_sql : sql 语句
function PUBLIC.db_query(_sql )

	local ret

	if DATA.is_dbsvr then
		ret = CMD.db_query(_sql)
	else
		ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	end

	if ret.errno then
		return ret,string.format("PUBLIC.db_query sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret ))
	end

	return ret,nil
end

function PUBLIC.db_query_va( _sql_fmt,...)

	return PUBLIC.db_query(PUBLIC.format_sql(_sql_fmt,...))

end

local system_variant

-- 数据库中原始值，用于判断是否需要 写库保存
local system_variant_orig = {}

-- 得到一个自增长 id
function PUBLIC.auto_inc_id(_name)
	system_variant[_name] = system_variant[_name] + 1
	return system_variant[_name]
end

function PUBLIC.init_system_variant()

	system_variant = DATA.system_variant

	if not system_variant then
		return  -- 未定义系统变量
	end

	local sql = "select * from system_variant"
	local ret = PUBLIC.db_query(sql)
	if( ret.errno ) then
		skynet.fail(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
		return false
	end

	for i = 1,#ret do

		local var = system_variant[ret[i].name]
		if var and type(var) == "number" then
			system_variant[ret[i].name] = tonumber(ret[i].value)
		else
			system_variant[ret[i].name] = ret[i].value
		end

		system_variant_orig[ret[i].name] = system_variant[ret[i].name]
	end

	-- ###_temp 临时 写数据库方案，以后 可以使用全局 update 事件
	skynet.timer(1,function()
		if "wait" == DATA.current_service_status then
			return false
		end

		for name,var in pairs(system_variant) do
			if system_variant_orig[name] ~= var then
				local sql = string.format("INSERT INTO system_variant(name,value)VALUES('%s','%s') on duplicate key update value='%s';",
					name,tostring(var),tostring(var))
				PUBLIC.db_exec(sql,"fast")

				system_variant_orig[name] = var
			end
		end
	end)

	return true
end

--- add by wss
function PUBLIC.query_data(_sql)
	local ret = PUBLIC.db_query(_sql)  -- by lyx: db_query 已经兼容 本地 和远程
	if( ret.errno ) then
		fault(string.format("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
		return nil
  	end
  
	return ret
end

---- 检查数据写队列的状态(这个函数为固定样式函数)
--[[function PUBLIC.chk_data_queue_write_status(_queue_type)
	if DATA.service_config.sql_id_center and _queue_type and type(_queue_type) == "string" then
		return skynet.call( DATA.service_config.sql_id_center , "lua" , "get_sql_info" , _queue_type )
	end
	return nil
end--]]

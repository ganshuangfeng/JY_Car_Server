

--
-- Author: lyx
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：通用数据库表的 数据管理，支持内存加载/释放 管理（基于 common_data_manager_lib 实现）

local basefunc = require "basefunc"
local skynet = require "skynet_plus"
local base = require "base"
require "data_func"
require "common_data_manager_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local db_table_manager = basefunc.create_hot_class("db_table_manager")

--[[ 
	_table_name ：表名
	_pri_key_name ： 主键，如果有多个 则为数组
	_other_key_name : 辅助键 ，如果有多个 则为数组（但每个独立，非联合主键）
	_where ： 数据 筛选条件， nil 表示 加载整个表
--]]
function db_table_manager:ctor(_table_name,_pri_key_name,_other_key_name,_where)

	self.table_name = _table_name
	self.pri_key_name = nil -- key name 数组
	self.pri_key_map = {} -- key name => true

	self.pri_key_status = {} 	-- 主键状态表： key_name=>value ； 有 表示存在，否则不存在
	self.other_key_status = nil	-- 辅助键 映射到主键 ，每个键一个组。 key name => {key value => pri_key}

	-- 数据动态加载器
	self.data_man = basefunc.hot_class.data_manager_cls.new({
		load_data = function(_key) return self:_on_data_man_load(_key) end,
	})

	local _all_key_name = {}

	-- 主键数据

	if type(_pri_key_name) == "string" then
		self.pri_key_name = {_pri_key_name}
		_all_key_name[_pri_key_name] = true
		self.pri_key_map[_pri_key_name] = true
	elseif type(_pri_key_name) == "table" then
		self.pri_key_name = {}
		for _,_n in ipairs(_pri_key_name) do
			self.pri_key_name[#self.pri_key_name + 1] = _n
			_all_key_name[_n] = true
			self.pri_key_map[_n] = true
		end
	else
		error("db_table_manager pri key not set!")
	end

	-- 辅助键数据

	if type(_other_key_name) == "string" then

		_all_key_name[_other_key_name] = true

		self.other_key_status = {[_other_key_name]={}}

	elseif type(_other_key_name) == "table" then

		self.other_key_status = {}

		for _,_n in ipairs(_other_key_name) do

			_all_key_name[_n] = true

			self.other_key_status[_n] = {}

		end
	end

	-- 需要选出数据的字段： 主键 和 辅助键
	local _field_list = {}
	for _name,_ in pairs(_all_key_name) do
		_field_list[#_field_list + 1] = _name
	end

	local _sql = string.format("select %s from %s ",table.concat(_field_list,","),_table_name)
	if _where then
		_sql = _sql .. " where " .. _where
	end
	
	local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	if( ret.errno ) then
		error(string.format("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
  	end
	for _,v in ipairs(ret) do 
		self:_update_key_status(self:_gen_pri_key(v),v)
	end
end

-- 遍历所有的 key
-- 用法： for _key_data in dbman:keys() do 
--		 _key : 每个 key 的值（包含辅助key）， keyname => keydata
function db_table_manager:keys()
	local _next,_t = pairs(self.pri_key_status)
	local _k,_v
	return function()
		_k,_v = _next(_t,_k)
		return _v
	end
end

-- 批量加载数据；参数 _condi ： 条件字段
function db_table_manager:batch_load(_condi)

	local _sql = string.format("select * from %s ")

	if _condi then
		local _where = {}
		for k,v in ipairs(_condi) do
			_where[#_where + 1] = string.format("%s=%s",k,PUBLIC.value_to_sql(v))
		end

		if next(_where) then
			_sql = _sql .. "where " .. table.concat(_where," and ")
		end
	end

	_sql = _sql .. ";"

	local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	if( ret.errno ) then
		error(string.format("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
  	end
	for _,v in ipairs(ret) do 
		self.data_man:add_data(self:_gen_pri_key(v),v)
	end
end

-- 根据 key 取得数据；如果 多个key ，则以 k/v 方式给出
function db_table_manager:get_data(_key)
	
	if type(_key) == "table" then
		_key = self:_gen_pri_key(_key)
	end

	return self.data_man:get_data(_key)
end

-- 根据 主键 判断数据是否存在（不会触发数据加载）
function db_table_manager:key_exists(_key)

	if type(_key) == "table" then
		_key = self:_gen_pri_key(_key)
	end	

	if self.pri_key_status[_key] then
		return true
	else
		return false
	end
end

-- 根据 other key 查询数据
function db_table_manager:query_data(_key_name,_key_value)

	if not self.other_key_status or not self.other_key_status[_key_name] then
		error("db_table_manager find_other_key error,key name not exists:" .. tostring(_key_name))
	end

	local _pri_key = self.other_key_status[_key_name][_key_value]
	if _pri_key then
		return self:get_data(_pri_key)
	end

	return nil
end

-- 根据 辅助键 判断数据是否存在（不会触发数据加载）
function db_table_manager:other_key_exists(_key_name,_key_value)

	if not self.other_key_status or not self.other_key_status[_key_name] then
		error("db_table_manager find_other_key error,key name not exists:" .. tostring(_key_name))
	end

	local _pri_key = self.other_key_status[_key_name][_key_value]
	if _pri_key then
		return true
	else
		return false
	end
end

-- 加入数据
function db_table_manager:add_data(_data)

	local _key = self:_gen_pri_key(_data)
	self:_update_key_status(_key,_data)

	self.data_man:add_data(_key,_data)

	--dump({self.table_name,_data,self.pri_key_name,PUBLIC.safe_insert_sql(self.table_name,_data,self.pri_key_name)},"xxxxxxxxxxxxxxxxxxxxxxxx add_data:")
	PUBLIC.db_exec(PUBLIC.safe_insert_sql(self.table_name,_data,self.pri_key_name))
end

-- 修改数据： 根据 key 修改数据
-- 注意： 不支持 修改 key 中的字段本身
--		 如果数据不存在，会插入新的数据！！！
function db_table_manager:change_data(_key,_data)

	-- 将 key 和 data 合并在一起
	local _data_merge = {}

	if type(_key) == "table" then
		for _,_name in ipairs(self.pri_key_name) do
			_data_merge[_name] = _key[_name]
		end

		_key = self:_gen_pri_key(_key)
	else
		_data_merge[self.pri_key_name[1]] = _key
	end

	local _data_old = self.data_man:find_data(_key)

	for k,v in pairs(_data) do
		if not self.pri_key_map[k] then
			_data_merge[k] = v

			-- 更新数据
			if _data_old then
				_data_old[k] = v
			end
		end
	end

	self:_update_key_status(_key,_data_merge)

	PUBLIC.db_exec(PUBLIC.safe_insert_sql(self.table_name,_data_merge,self.pri_key_name))
end

-- 删除数据
function db_table_manager:del_data(_key)

	if type(_key) == "table" then
		_key = self:_gen_pri_key(_key)
	end

	-- 从数据卸载
	self.data_man:recover_data(_key)

	local _where = self:_get_pri_where_sql(_key)
	if not _where then
		return nil
	end

	-- 清空 key
	self:_clear_key_status(_key)
		
	PUBLIC.db_exec(string.format("delete from %s where %s;",self.table_name,_where))
end


-- 更新 key 信息
function db_table_manager:_update_key_status(_pri_key,_data)

	local _status = self.pri_key_status[_pri_key] or {}
	self.pri_key_status[_pri_key] = _status

	-- 主键
	for _,_name in ipairs(self.pri_key_name) do
		_status[_name] = _data[_name]
	end

	-- 辅助键： 注意 pri_key_status  中也要保存 辅助键的值，以便找到 辅助键中的列表项
	if self.other_key_status then

		for _name,_other_status in pairs(self.other_key_status) do

			if _data[_name] ~= nil and _status[_name] ~= _data[_name] then

				-- 先清除 旧的 
				if _status[_name] ~= nil then
					_other_status[_status[_name]] = nil
				end
				
				_status[_name] = _data[_name]

				if _data[_name] ~= nil then
					_other_status[_data[_name]] = _pri_key
				end
			end
		end
	end
end

-- 清除 key 信息
function db_table_manager:_clear_key_status(_pri_key)
	local _status = self.pri_key_status[_pri_key]
	if _status then
		if self.other_key_status then
			for _name,_other_status in pairs(self.other_key_status) do
				if _status[_name] ~= nil then
					_other_status[_status[_name]] = nil
				end
			end
		end

		self.pri_key_status[_pri_key] = nil
	end
end

function db_table_manager:_gen_pri_key(_row)
	if self.pri_key_name[2] then -- 有两个 以上

		-- 构造key 时使用的缓存，避免频繁创建表
		self._cache_key_con = self._cache_key_con or {}

		for i,_name in ipairs(self.pri_key_name) do
			self._cache_key_con[i] = tostring(_row[_name])
		end
		
		return table.concat(self._cache_key_con,"_")
	else
		return _row[self.pri_key_name[1]]
	end
end

function db_table_manager:_get_pri_where_sql(_pri_key)

	local _key_status = self.pri_key_status[_pri_key]

	if _key_status then
		if _key_status._where then
			return _key_status._where
		end
		local _where = {}
		for i,_name in ipairs(self.pri_key_name) do
			_where[#_where + 1] = string.format("%s=%s",_name,PUBLIC.value_to_sql(_key_status[_name]))
		end

		_key_status._where = table.concat(_where," and ")

		return _key_status._where
	end

	return nil
end

function db_table_manager:_on_data_man_load(_key)

	local _where = self:_get_pri_where_sql(_key)
	if not _where then
		return nil
	end

	local _sql = string.format("select * from %s where %s;",self.table_name,_where)
	local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	if( ret.errno ) then
		error(string.format("sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
	end
	if ret[2] then
		error(string.format("error:db_table_manager pri key has multi row, sql=%s\n",_sql))
	end

	return ret[1]

end

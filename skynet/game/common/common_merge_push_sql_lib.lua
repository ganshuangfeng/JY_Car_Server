
------------------ 通用 延迟插入sql队列 的组件

--[[

--]]

local basefunc = require "basefunc"
local skynet = require "skynet_plus"
require "data_func"
local base = require "base"
local DATA = base.DATA
local CMD = base.CMD
local REQUEST = base.REQUEST
local PUBLIC = base.PUBLIC

local C = basefunc.create_hot_class("common_merge_push_sql_lib")

local server_manager_lib = require "server_manager_lib"

-- by lyx：为了兼容而存在；  新的方式可直接 访问 basefunc.hot_class.data_manager_cls
basefunc.server_class = basefunc.server_class or {}
basefunc.server_class.common_merge_push_sql_lib = basefunc.hot_class.common_merge_push_sql_lib

--[[ 
	_deal_delay        延迟多久更新一下
	_data_manager_com  对应的内存管理器的对象(可以不传，如果要在更新数据后给内存管理器同步sql队列中信息时要传)
	_sql_deal_data     sql处理的数据
	{
		tab_name = "",     --- 数据库表名
		queue_type = "",   --- sql队列类型 slow or fast
		push_type = "",    --- push到sql队列方式 update | insert	
		field_data = {
			[field_name] = {
				is_primary = true ,   --- 是否是主键，可以不填
				value_type = "",      --- 赋值类型  equal | num_add | str_add ...
			},
			[field_name2] = {
				is_primary = false ,   --- 是否是主键，可以不填
				value_type = "",   --- 赋值类型  equal | num_add | str_add ...
			},
		}
	}
	
	
--]]
function C:ctor( _deal_delay , _data_manager_com , _sql_deal_data  )
	--- 存放所有缓存数据的[[ key 值为你要更新的多级可以的string组合 ]]
	self.cache_data = {}

	--- 每个多久处理一下 , 处理延迟
	self.deal_delay = _deal_delay
	self.deal_delay_const = self.deal_delay
	self.deal_delay_count = 0

	---- 如果不是正式的服，都不用 延迟缓存 ，延迟缓存时间间隔小一点
	if skynet.getcfg("server_name") ~= "zs" then
		self.deal_delay = 2
		self.deal_delay_const = self.deal_delay
	end

	--- sql_deal_data sql处理的数据，包括在哪个表;字段是哪些;是使用插入还是更新
	self.sql_deal_data = _sql_deal_data

	--- 对应的 内存管理组件
	self.data_manager_com = _data_manager_com

	self.data_manager_key_vec = {}

	--self.timer = nil

	---- 个数的timer
	--self.num_timer = nil
	--self.num_timer_delay = 10
	
	---- 关机的处理数据,十分钟以内处理
	self.shutdown_time_count_down = 600


	----- 上报个数的数据
	self.report_cache_num_delay = 10
	self.report_cache_num_delay_const = self.report_cache_num_delay
	self.report_cache_num_count = 0

	---- 一上来就开一个update
	self.update_dt = 1
	skynet.timeout( math.random(500 , 2500) , function() 
		print("xxxx-----------------------strat merge_push_sql timer:" , (DATA.msg_tag or "other") .. "_" .. tostring(self))
		self.update_timer = skynet.timer( self.update_dt ,function() self:update() end )
	end )
	

end

--- 开始一个timer
function C:start_timer()
	if self.update_timer then
		self.update_timer:stop()
	end

	self.update_timer = skynet.timer( self.update_dt ,function() self:update() end )



	--[[if self.timer then
		self.timer:stop()
	end

	if self.num_timer then
		self.num_timer:stop()
	end

	self.timer = skynet.timer( skynet.getcfg_2number( "common_merge_push_lib_debug_delay" ) or self.deal_delay , function() self:deal_merge_push_sql() end )

	self.num_timer = skynet.timer( self.num_timer_delay , function() self:report_cache_num() end )--]]
end

function C:stop_timer()
	if self.update_timer then
		self.update_timer:stop()
	end
end

---- 更新函数
function C:update()
	self.deal_delay_count = self.deal_delay_count + self.update_dt
	self.report_cache_num_count = self.report_cache_num_count + self.update_dt

	----- 处理延迟插入
	if self.deal_delay_count >= self.deal_delay then
		self.deal_delay_count = 0
		self:deal_merge_push_sql()
	end

	------ 处理上报数量
	if self.report_cache_num_count >= self.report_cache_num_delay then
		self.report_cache_num_count = 0
		self:report_cache_num()
	end

	------- 处理关机事宜
	local shutdown_time = server_manager_lib.get_shutdown_cd()

	if shutdown_time and type(shutdown_time) == "number" then
		if shutdown_time <= self.shutdown_time_count_down then
			self.deal_delay = 1
			self.report_cache_num_delay = 1
		else
			self.deal_delay = self.deal_delay_const
			self.report_cache_num_delay = self.report_cache_num_delay_const
		end
	else
		self.deal_delay = self.deal_delay_const
		self.report_cache_num_delay = self.report_cache_num_delay_const
	end

end

function C:report_cache_num()
	local deal_vec = self.cache_data
	local t_num = basefunc.key_count(deal_vec)
	--print("xxx----------------report_cache_num:", (DATA.msg_tag or "other") .. "_" .. tostring(self) , t_num)
	skynet.send( DATA.service_config.data_service , "lua" , "set_delay_push_sql_num" , (DATA.msg_tag or "other") .. "_" .. tostring(self) , t_num )
end

--- 获得更新类型的sql
function C:get_update_sql( _cache_data )

	local pri_keys = {}
	local _field_value_vec = {}

	for field_key,field_data in pairs( self.sql_deal_data.field_data ) do
		if field_data.is_primary then
			pri_keys[#pri_keys + 1] = field_key
		end
		_field_value_vec[ field_key ] = _cache_data[ field_key ] or nil
	end

	local sql = PUBLIC.safe_insert_sql( self.sql_deal_data.tab_name ,_field_value_vec,pri_keys)
	--print("xxx------------get_update_sql:",sql)
	return sql
end

--- 获得插入类型的sql
function C:get_insert_sql(_cache_data)

	local _field_value_vec = {}

	for field_key,field_data in pairs( self.sql_deal_data.field_data ) do
		_field_value_vec[ field_key ] = _cache_data[ field_key ] or nil
	end

	local sql = PUBLIC.gen_insert_sql( self.sql_deal_data.tab_name ,_field_value_vec)
	--print("xxx------------get_insert_sql:",sql)
	return sql
end

----- 处理合并插入sql
function C:deal_merge_push_sql()
	--print("xxx----------------deal_merge_push_sql:" , self.sql_deal_data.tab_name )
	--dump(self.cache_data , "xx----------------------self.cache_data:" .. self.sql_deal_data.tab_name )
	local deal_vec = self.cache_data
	self.cache_data = {}
	
	--local t_num = basefunc.key_count(deal_vec)
	---- 发送减少在缓存push中的个数
	--skynet.send( DATA.service_config.data_service , "lua" , "add_or_reduce_delay_push_sql_num" , -t_num )

	for key_str,data in pairs(deal_vec) do
		local format_sql = nil
		if self.sql_deal_data.push_type == "update" then
			format_sql = self:get_update_sql( data )
		elseif self.sql_deal_data.push_type == "insert" then
			format_sql = self:get_insert_sql( data )
		end
		--- 一条一条写，(如果合成一个大条，容易出错全部跳出)
		if format_sql then
			local _queue_type,_queue_id = skynet.call( DATA.service_config.data_service , "lua" , "db_exec" , format_sql , self.sql_deal_data.queue_type )
		
			if self.data_manager_com and self.data_manager_key_vec[key_str] then
				self.data_manager_com:update_sql_queue_data( self.data_manager_key_vec[key_str] , _queue_type , _queue_id )
			end
		end

	end
end



---- 根据赋值类型更新数据
function C:value_data_by_type( _cache_data , _field_key , _new_value , _vaule_type )
	local _old_value = _cache_data[_field_key]

	if not _old_value then
		_cache_data[_field_key] = _new_value
	else
		if _vaule_type == "equal" then
			_cache_data[_field_key] = _new_value
		elseif _vaule_type == "num_add" then
			if not tonumber(_old_value) or not tonumber(_new_value) then
				print("xx-----error num_add value_data_by_type:", self.sql_deal_data and self.sql_deal_data.tab_name , _old_value , _field_key , _new_value , _vaule_type)
				return
			end

			_cache_data[_field_key] = tonumber(_old_value) + tonumber(_new_value)
		elseif _vaule_type == "str_add" then
			if not tostring(_old_value) or not tostring(_new_value) then
				print("xx-----error str_add value_data_by_type:", self.sql_deal_data and self.sql_deal_data.tab_name , _old_value , _field_key , _new_value , _vaule_type)
				return
			end

			_cache_data[_field_key] = tostring(_old_value) .. tostring(_new_value)
		end
	end
end

function C:get_key_str_by_key_vec(_key_vec)
	if not _key_vec or type(_key_vec) ~= "table" or not next(_key_vec) then
		return nil
	end

	return table.concat( _key_vec , "_" )
end

--[[
	
加入缓存数据
	参数：
	_key_vec 是你的多级key的vec
	_data 是要存放的缓存数据
	
	_data_manager_key 内存管理里面的主键，当你不需要更新内存管理器里面的队列数据时 可不传

--]]
function C:add_to_sql_cache( _key_vec , _data , _data_manager_key )
	local key_str = self:get_key_str_by_key_vec(_key_vec)
	if not key_str then
		return
	end

	----- 内存管理器里面的主键
	self.data_manager_key_vec[key_str] = _data_manager_key
	----- 刚传入缓存数据时，设为很大，避免被清理了
	if self.data_manager_com and self.data_manager_key_vec[key_str] then
		self.data_manager_com:update_sql_queue_data( self.data_manager_key_vec[key_str] , self.sql_deal_data.queue_type or "slow" , 99999999 )
	end

	local cache_data = self.cache_data[ key_str ]

	if not cache_data then
		--- 没有就直接赋值
		--self.cache_data[ key_str ] = _data

		---- 只处理在传进来的字段里面的
		local tar_data = nil
		for _key,new_value in pairs(_data) do
			if self.sql_deal_data.field_data and self.sql_deal_data.field_data[_key] then
				tar_data = tar_data or {}
				tar_data[ _key ] = new_value
			end
		end

		self.cache_data[ key_str ] = tar_data

		---- 发送增加在缓存push中的个数
		--skynet.send( DATA.service_config.data_service , "lua" , "add_or_reduce_delay_push_sql_num" , 1 )
	else
		---- 遍历新来的缓存数据
		for _key,new_value in pairs(_data) do
			---- 查找执行模式
			for _field_name,_field_data in pairs(self.sql_deal_data.field_data ) do
				if _field_name == _key then
					--- 找到要处理的字段了
					self:value_data_by_type( cache_data , _field_name , new_value , _field_data.value_type )
					break
				end
			end
		end
	end

end

----- 清掉某个缓存数据
function C:delete_sql_cache(_key_vec)
	local key_str = self:get_key_str_by_key_vec(_key_vec)
	if not key_str then
		return
	end

	self.cache_data[ key_str ] = nil
end

---- q清掉所有数据
function C:delete_all_sql_cache()
	self.cache_data = {}

end

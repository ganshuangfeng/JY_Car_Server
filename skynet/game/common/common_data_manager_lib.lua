
------------------ 通用内存数据管理

--[[
加载：
	1:惰性加载
	2：热度加载
	3：全加载（仅限于数据有限时使用）
	4：强制加载

回收：
	1：固定回收
	2：超限折半回收
	3：冷回收
	4：强制回收

--]]

local basefunc = require "basefunc"
local skynet = require "skynet_plus"
local base = require "base"
local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC


local data_manager = basefunc.create_hot_class("data_manager_cls")

-- by lyx：为了兼容而存在；  新的方式可直接 访问 basefunc.hot_class.data_manager_cls
basefunc.server_class = basefunc.server_class or {}
basefunc.server_class.data_manager_cls = basefunc.hot_class.data_manager_cls

--[[ 
	参数 _callbacks ， 一个回调函数表：
		load_data 		(必须)数据加载
		recover_data	(可选)释放数据
		chk_write_status  检查数据在队列中的写入状态
--]]
function data_manager:ctor(_callbacks, _max_load_limit)
	-- 回调列表，其中包括了载入数据函数...避免热更新 函数不能修改
	self.callbacks = _callbacks
	--数据池 必须 k,v键值对
	self.data = {}
	-- 上一次访问的时间
	self.last_visit_time = basefunc.list.new()
	-- 最大的数据载入个数
	self.max_load_limit = _max_load_limit or 10000

	--- 最大载入数据量的百分比限制 , 0.01~1
	self.max_load_limit_percent = nil

	-- 当前的数据载入个数
	self.cur_load_count = 0

	-- 上次清理的时间
	self.last_clear_time = 0
	-- 两次清理之间必须要有的间隔时间
	self.clear_data_delay = 60

	---- 清理的总次数
	self.clear_num = 0
	---- 清理日志
	self.clear_log = {}
end

---- 获取最大的载入量的打折比
function data_manager:get_max_load_limit_percent()
	local max_load_limit_percent = self.max_load_limit_percent or skynet.getcfg_2number("data_manager_max_load_limit_percent")
	if max_load_limit_percent then
		if max_load_limit_percent < 0.01 then
			max_load_limit_percent = 0.01
		elseif max_load_limit_percent > 1 then
			max_load_limit_percent = 1
		end
		return max_load_limit_percent
	end
	return 1
end

--- 获得数据
function data_manager:get_data(_key)
	return self:load_data(_key)
end

--- by lyx 查找：没加载 就返回 nil
function data_manager:find_data(_key)

	local _item = self.data[_key]
	if _item then
		self.last_visit_time:erase(_item)
		self:add_data( _key , _item[1] )

		-- 这个可能为空（原因未知）(好像是当时是在预发布测得，而预发布的最大载入数为2)
		if not self.data[_key] then
			print("data_manager:find_data() error:",tostring(_key),basefunc.tostring(_item))
			return nil
		end

		return self.data[_key][1] 
	end	

	return nil
end

--- 新增or更新数据
function data_manager:add_or_update_data(_key , _data , _queue_type , _queue_id)
	local old_data = self:get_data(_key)
	if not old_data then
		self:add_data( _key , _data)
	else
		self.data[_key][1] = _data

	end

	if self.data[_key] and _queue_type and _queue_id then
		self.data[_key]._data_queue_type = _queue_type
		self.data[_key]._data_queue_id = _queue_id
	end

end

--- 只更新数据 要插入的队列&队列id
function data_manager:update_sql_queue_data( _key , _queue_type , _queue_id )
	-- body
	if self.data[_key] and _queue_type and _queue_id then
		self.data[_key]._data_queue_type = _queue_type
		self.data[_key]._data_queue_id = _queue_id
	end
end

--- 载入数据
function data_manager:load_data(_key)

	local _data = self:find_data(_key)
	if _data then
		return _data
	end

	--加载数据
	local info_result = nil

	if self.callbacks and self.callbacks.load_data then
		info_result = self.callbacks.load_data(_key)
	end

	--!!!!!!!!! 防止挂起
	if self.data[_key] then 
		return self.data[_key][1] 
	end

	if not info_result or info_result == "CALL_FAIL" then
		return nil -- 没有用户数据
	end

	-- 组装数据
	self:add_data( _key , info_result)
	-- 检查回收
	--self:check_and_recover()

	
	return self.data[_key][1]
end

---- 增加一个数据
function data_manager:add_data( _key , _data )

	-- 检查回收
	self:check_and_recover()

	if not self.data[_key] then
		self.cur_load_count = self.cur_load_count + 1
		--print("xxxx--------------------cur_load_count:" ,self.cur_load_count )
	end

	self.last_visit_time:push_front(_data)
	self.data[_key] = self.last_visit_time:front_item()
	self.data[_key]._d_key = _key

end

---- 回收检查
function data_manager:check_and_recover()
	--print("xxx-------------data_man_delay_time:", skynet.getcfg_2number("data_man_delay_time") )
	local max_load_limit = skynet.getcfg_2number("data_manager_force_max_load") or self.max_load_limit

	if not max_load_limit then
		max_load_limit = 10000
	end

	---- 乘上打折率
	local max_load_limit_percent = self:get_max_load_limit_percent()
	max_load_limit = math.floor( max_load_limit * max_load_limit_percent )
	if max_load_limit_percent ~= 1 and max_load_limit < 200 then  --- 如果打折了，至少有个两百,避免打太狠，数量过少；但又要保证自身本来就少于200时的正确性。
		max_load_limit = 200
	end

	if max_load_limit > -1 and self.cur_load_count > max_load_limit then
		--print("xxxx-----------recover" , self.cur_load_count , self.max_load_limit)
		---- 检查清理时间
		local now_time = os.time()
		if now_time - self.last_clear_time < (skynet.getcfg_2number("data_man_delay_time") or self.clear_data_delay) then
			--print("xxxx-----------in clear_data_delay" , self.cur_load_count , self.max_load_limit)
			return 
		end

		self.last_clear_time = now_time

		local recover_before_num = self.cur_load_count
		--超限回收 , 回收1/2
		self:recover_data_by_cold( math.floor( self.cur_load_count / 2 ) )

		self.clear_num = self.clear_num + 1
		self.clear_log[#self.clear_log + 1] = { before = recover_before_num , after = self.cur_load_count }

		print("xxxx-----------recover after" , self.cur_load_count , max_load_limit)
	end
end

-- 强制载入数据
function data_manager:force_load_data(_key)
	local is_not_have = 1
	if self.data[_key] then is_not_have = 0 end

	local info_result = nil

	if self.callbacks and self.callbacks.load_data then
		info_result = self.callbacks.load_data(_key)
	end

	if info_result == "CALL_FAIL" then
		return nil 
	end
	
	if info_result then 
		-- 组装数据
		self:add_data( _key , info_result )

		-- 检查回收
		--self:check_and_recover()
	else
		self.data[_key] = nil
		self.cur_load_count = self.cur_load_count - (1 - is_not_have)
	end
end

--- 批量载入数据
function data_manager:load_data_by_group(group)
	for _,key in pairs(group) do
		self:load_data(key)
	end
end

--- (外部接口)强制卸载一个key的内存(data_queue_check_vec 这个参数可以避免频繁请求数据队列的信息,但后续使用的可能不是及时的队列信息)
function data_manager:force_recover_data(_key , _data_queue_check_vec)
	if self.data[_key] then
		local data_queue_check_vec = _data_queue_check_vec or {}
		self:recover_data_item(self.data[_key] , data_queue_check_vec)
	end
end

--- 基础 回收数据
function data_manager:recover_data(_key)

	if self.data[_key] then

		-- by lyx ： 释放时回调
		if self.callbacks.recover_data then
			self.callbacks.recover_data(_key,self.data[_key][1])
		end

		self.data[_key] = nil
		self.cur_load_count = self.cur_load_count - 1
	end

end

---- 回收一个内存，带检查的
function data_manager:recover_data_item(_item , data_queue_check_vec)
	----- 检查队列和执行时的队列id
	local _is_clear_data = true
	local _item_queue_type = _item._data_queue_type
	local _item_queue_id = _item._data_queue_id

	if _item_queue_type and type(_item_queue_type) == "string" and _item_queue_id and type(_item_queue_id) == "number" then
		----------- 如果有检查函数，并且还没有检查数据
		--if self.callbacks.chk_write_status and data_queue_check_vec and not data_queue_check_vec[_item_queue_type] then
		if PUBLIC.chk_data_queue_write_status and data_queue_check_vec and not data_queue_check_vec[_item_queue_type] then

			data_queue_check_vec[_item_queue_type] = { }

			local data_status = PUBLIC.chk_data_queue_write_status(_item_queue_type)

			data_queue_check_vec[_item_queue_type].complete_id = data_status and data_status.last_id
			data_queue_check_vec[_item_queue_type].error_id_map =	data_status and data_status.fail_ids
		end


		local data_queue_check = data_queue_check_vec and data_queue_check_vec[_item_queue_type]

		if data_queue_check then
			if data_queue_check.error_id_map and type(data_queue_check.error_id_map) == "table" then
				---- 如果在错误队列里面，不清理
				if data_queue_check.error_id_map[_item_queue_id] then
					--print("xxx----------- _is_clear_data false in error_id_map")
					_is_clear_data = false
				end
			end
			----- 如果还没有处理到这个id，不清理
			--print("xxx------------- ", data_queue_check.complete_id , _item_queue_id )
			if _is_clear_data and data_queue_check.complete_id and type(data_queue_check.complete_id) == "number" then
				if data_queue_check.complete_id < _item_queue_id then
					--print("xxx----------- _is_clear_data false complete_id < _item_queue_id ")
					_is_clear_data = false
				end
			end
		end 
	end
	if _is_clear_data then
		self.last_visit_time:erase( _item )
		self:recover_data(_item._d_key)
	end

end

--- 冷回收数据
---- PS:如果最后一个不能清理，这个循环清理会一直清最后一个，导致执行count次清理最后一个，但是不成功
function data_manager:recover_data_by_cold(count)

	local data_queue_check_vec = {}

	local _count = 0
	while not self.last_visit_time:empty() do
		if _count >= count then
			break
		end

		--local _item = self.last_visit_time:pop_back_item()
		local _item = self.last_visit_time:back_item()


		self:recover_data_item(_item , data_queue_check_vec)
		----- 检查队列和执行时的队列id
		--[[local _is_clear_data = true
		local _item_queue_type = _item._data_queue_type
		local _item_queue_id = _item._data_queue_id

		if _item_queue_type and type(_item_queue_type) == "string" and _item_queue_id and type(_item_queue_id) == "number" then
			----------- 如果有检查函数，并且还没有检查数据
			if self.callbacks.chk_write_status and not data_queue_check_vec[_item_queue_type] then

				data_queue_check_vec[_item_queue_type] = { }

				local data_status = self.callbacks.chk_write_status(_item_queue_type)

				data_queue_check_vec[_item_queue_type].complete_id = data_status and data_status.last_id
				data_queue_check_vec[_item_queue_type].error_id_map =	data_status and data_status.fail_ids
			end


			local data_queue_check = data_queue_check_vec[_item_queue_type]

			if data_queue_check then
				if data_queue_check.error_id_map and type(data_queue_check.error_id_map) == "table" then
					---- 如果在错误队列里面，不清理
					if data_queue_check.error_id_map[_item_queue_id] then
						_is_clear_data = false
					end
				end
				----- 如果还没有处理到这个id，不清理
				if _is_clear_data and data_queue_check.complete_id and type(data_queue_check.complete_id) == "number" then
					if data_queue_check.complete_id < _item_queue_id then
						_is_clear_data = false
					end
				end
			end 
		end

		if _is_clear_data then
			self.last_visit_time:erase( _item )
			self:recover_data(_item._d_key)
		end--]]

		_count = _count + 1

	end
end

----全回收数据
function data_manager:recover_data_all()
	while not self.last_visit_time:empty() do

		local _item = self.last_visit_time:pop_back_item()

		self:recover_data(_item._d_key)

	end
end


---- 检查数据写队列的状态(这个函数为固定样式函数)
function PUBLIC.chk_data_queue_write_status(_queue_type)
	if DATA.service_config.sql_id_center and _queue_type and type(_queue_type) == "string" then
		return skynet.call( DATA.service_config.sql_id_center , "lua" , "get_sql_info" , _queue_type )
	end
	return nil
end

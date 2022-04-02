---- 通用的数据模块，用来ecs中统计 实体组件数据，房间与agent的数据同步，agent 与 客户端的同步。

local basefunc = require "basefunc"
local ecs_data_module = basefunc.create_hot_class( "ecs_data_module" )

local C = ecs_data_module

function C:ctor(_keep_data_num)
	--- 当前索引的数据缓存 , 
	self.now_data = nil

	--- 数据的改变 流水帐
	--[[
		自增key = { 
			data_index = xx ,   -- 数据索引
			total_data = xx ,   -- 全数据
			data_diff = xxx ,   -- 数据差异
		},
		...
	--]]
	self.data_change_list = {}

	--- 当前的数据 索引值
	self.now_data_index = 0

	--- 保留 差异的多少 帧数
	self.keep_data_num = _keep_data_num or 100
end


--- 清理
function C:clear()
	self.now_data = nil

	self.now_data_index = 0

	self.data_change_list = {}
end

---- 获得 与 老数据 的差异
function C.get_data_diff(_old_data , _new_data , _tar_diff , _tar_key )
	local is_change = false
	if _tar_key then
		_tar_diff[_tar_key] = {}
	end

	--- 新增
	if not _old_data and _new_data then
		if _tar_key then
			_tar_diff[_tar_key] = { __diff_type__ = "add" , __data__ = _new_data }
		else
			_tar_diff = { __diff_type__ = "add" , __data__ = _new_data }
		end
		is_change = true
		return _tar_diff , is_change
	end

	--- 删除
	if _old_data and not _new_data then
		if _tar_key then
			_tar_diff[_tar_key] = { __diff_type__ = "delete" , __data__ = _new_data }
		else
			_tar_diff = { __diff_type__ = "delete" , __data__ = _new_data }
		end
		is_change = true
		return _tar_diff , is_change
	end


	---- 更新
	local is_update = false
	if type(_old_data) ~= type(_new_data) then
		is_update = true
	else
		-- 类型相同，但不是table
		if type(_old_data) ~= "table" and _new_data ~= _old_data then
			is_update = true
		end
	end

	if is_update then
		if _tar_key then
			_tar_diff[_tar_key] = { __diff_type__ = "update" , __data__ = _new_data }
		else
			_tar_diff ={ __diff_type__ = "update" , __data__ = _new_data }
		end
		is_change = true
		return _tar_diff , is_change
	end

	--- 下面肯定两个数据类型一致
	if type(_new_data) == "table" then
		for key,data in pairs(_new_data) do
			local _t_d , _is_change = C.get_data_diff( _old_data[key] , data , _tar_key and _tar_diff[_tar_key] or _tar_diff , key )
			if not is_change then
				is_change = _is_change
			end
		end

		for key,data in pairs(_old_data) do
			local _t_d , _is_change = C.get_data_diff( data , _new_data[key] , _tar_key and _tar_diff[_tar_key] or _tar_diff , key )
			if not is_change then
				is_change = _is_change
			end
		end
	end

	if _tar_key and not next(_tar_diff[_tar_key]) then
		_tar_diff[_tar_key] = nil
	end

	return _tar_diff , is_change
end

---- 使用差异 和 老数据 还原当前数据
function C.restore_data_by_diff( _old_data , _data_diff )
	
	if _data_diff and type(_data_diff) == "table" then
		if _data_diff.__diff_type__ and _data_diff.__data__ then
			local diff_type = _data_diff.__diff_type__
			local diff_data = _data_diff.__data__

			if diff_type == "add" or diff_type == "update" then
				_old_data = diff_data
			elseif diff_type == "delete" then
				_old_data = nil
			end
		else
			for _key , data in pairs(_data_diff) do
				if data.__diff_type__ then
					local diff_type = data.__diff_type__
					local diff_data = data.__data__

					if diff_type == "add" or diff_type == "update" then
						_old_data[_key] = data.__data__
					elseif diff_type == "delete" then
						_old_data[_key] = nil
					end

				else
					_old_data[_key] = _old_data[_key] or {}
					C.restore_data_by_diff( _old_data[_key]  , data )
				end
			end
		end
	end

	return _old_data
end

--- 加入数据，房间 ecs 系统每次update的时候调用
function C:add_data(_data)
	self.now_data_index = self.now_data_index + 1

	local last_data = self.now_data

	self.now_data = basefunc.deepcopy( _data )

	local data_diff , is_change = C.get_data_diff(last_data , self.now_data , {} )

	if is_change then
		return { data_diff = data_diff , data_index = self.now_data_index }
	else
		return nil
	end
end

function C:restore_data( _data_diff )
	if not _data_diff or type(_data_diff) ~= "table" then
		return
	end

	self.now_data = C.restore_data_by_diff( self.now_data , _data_diff.data_diff )

	local data = {
		data_index = _data_diff.data_index ,
		total_data = basefunc.deepcopy( self.now_data ) ,
		data_diff = _data_diff.data_diff , 
	}

	self.data_change_list[#self.data_change_list + 1] = data

	if #self.data_change_list > self.keep_data_num then
		table.remove( self.data_change_list , 1 )
	end

	return data
end


return C
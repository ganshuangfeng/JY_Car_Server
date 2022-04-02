---- ecs 世界

local base = require "base"
local basefunc = require "basefunc"
require "printfunc"
local ecs_func = require "ecs.ecs_func"
require "ecs.ecs_data_module"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- require "common.ecs.ecs_config"
-- local ecs_base_func = require "common.ecs.ecs_base_func"

local C = basefunc.create_hot_class( "ecs_world" )

--[[
	ecs 配置表 _ecs_config 结构：
	{
		components = {
			组件类型 = lua代码文件位置（例如： services.game_xxxx.xxxx）
			。。。
		},

		systems = {
			系统类型 = lua代码文件位置（例如： services.game_xxxx.xxxx）
			。。。
		},
	}

	说明：
		组件的创建函数: create(...) ，返回组件的初始数据结构
		系统的创建函数: create(...) , 返回系统的初始数据结构
--]]
function C:ctor( _d , _ecs_config)
	self.d = _d

	self.ecs_config = _ecs_config
	self:trans_sys_config()

	self.last_entity_id = 0

	-- 实体集合： id => 实体
	-- 实体： 组件类型名 => 组件
	self.entities = {}

	--- 实体： 实体 => id
	self.entities_id_map = {}
	
	--- 加入世界的系统
	self.systems_list = {} -- list,更新顺序保持： {module=,data=}
	self.systems = {}  -- 系统 映射： _type => 序号

	---- 数据模块
	self.data_module = basefunc.hot_class.ecs_data_module.new()


	---- 创建一个单例组件 的 实体容器，这个用来存，单例组件的
	self:add_entity()
	dump( self.entities_id_map , "xxxx--------------------------self.entities_id_map:" )
	---- 消息触发器
	self.msg_dispatcher = basefunc.dispatcher.new()
end

---- 转换system配置
function C:trans_sys_config()
	if self.ecs_config and self.ecs_config.systems_list then
		local sys_config = {}

		for key,data in pairs(self.ecs_config.systems_list) do
			sys_config[data.sys_name] = data.path
		end

		self.ecs_config.systems = sys_config
	end
end

---- 触发消息
function C:trriger_msg( _msg_name , ... )
	PUBLIC.trriger_msg( self.d , _msg_name , ... )
end

function C:add_msg_listener( _obj , _msgtable )
	PUBLIC.add_msg_listener( self.d , _obj , _msgtable )
	--self.msg_dispatcher:register( _obj , _msgtable)
end

function C:delete_msg_listener( _obj )
	--self.msg_dispatcher:unregister( _obj )

	PUBLIC.delete_msg_listener( self.d , _obj )
end

--- 添加实体,
-- 参数 _entity 实体（其实是个组件表）,可选，默认为空实体
-- 返回： id + 实体
function C:add_entity(_entity)

	_entity = _entity or {}

	assert(not self.entities_id_map[_entity],"entity is added!")

	self.last_entity_id = self.last_entity_id + 1

	self.entities[self.last_entity_id] = _entity

	self.entities_id_map[_entity] = self.last_entity_id

	return self.last_entity_id,_entity
end

--- 删除实体
-- 参数 _entity 实体 或 id
function C:delete_entity(_entity)

	local _e,_id = self:get_entity(_entity)
	if _e then
		self.entities_id_map[_e] = nil
	end
	if _id then
		self.entities[_id] = nil
	end

end

-- 得到实体
-- 参数 _id ： 实体 id ； 也可以传入实体
-- 返回： 实体 + id
-- 如果 系统中不存在 实体 或 id，则返回 nil
function C:get_entity(_id)

	if type(_id) == "table" then
		if self.entities_id_map[_id] then
			return _id,self.entities_id_map[_id]
		else
			return nil,nil
		end
	end

	if self.entities[_id] then
		return self.entities[_id],_id
	else
		return nil,nil
	end
	
end

----- 获得一个 单例组件（单例组件，全局只有一个，放在单例实体中）
function C:get_singleton_com(_com_type , ...)
	local singleton_com_entity = self.entities[1]

	if singleton_com_entity then
		if singleton_com_entity[_com_type] then
			return singleton_com_entity[_com_type]
		else
			self:add_component(singleton_com_entity , _com_type , ...)
			return singleton_com_entity[_com_type]
		end
	end
	return nil
end

---- 给实体添加组件 self.entities_id_map
-- 参数  _entity ： 实体 或 id
--      _component ： 名字或组件数据
function C:add_component(_entity , _component_type,...)

	local _e = self:get_entity(_entity)
	assert(_e,"add_component error:not found entity")

	local _tmp = assert(self.ecs_config.components[_component_type],"error:not found component")
	
	if type(_tmp) == "table" then
		if _tmp.is_simple then
			---- 处理简单类型的数据，不用新加文件
			_e[_component_type] = _tmp.data and basefunc.deepcopy(_tmp.data) or {}
			---- 用参数赋值。
			local par = table.pack(...)

			---- 按 第一个参数 为表来传递 参数
			if par and type(par) == "table" and par[1] then
				for key,value in pairs(par[1]) do
					if _e[_component_type][key] then
						_e[_component_type][key] = value
					end
				end
			end
		elseif _tmp.path then
			_e[_component_type] = require(_tmp.path).create(self,...)
		end
	elseif type(_tmp) == "string" then
		_e[_component_type] = require(_tmp).create(self,...)
	end

	--- 检查各系统 的实体
	self:check_system_entity(_e)
end

---- 删除组件
function C:delete_component(_entity , _component_type)

	local _e = self:get_entity(_entity)
	assert(_e,"delete_component error:not found entity")
	_e[_component_type] = nil

		--- 删除组件，检查
	self:check_system_entity(_e)
end


--- 添加系统
function C:add_system( _system_name,...)
	assert(not self.systems[_system_name],"error:system '" .. tostring(_system_name),"' added!")
	
	local _tmp = assert(self.ecs_config.systems[_system_name],"error:not found system")
	local _module = require(_tmp)
	
	local _d = _module.create(self,...)
	if _d then
		self.systems_list[#self.systems_list + 1] = {module=_module,data=_d}
		self.systems[_system_name] = #self.systems_list
		
		---- 给这个系统 加上 消息处理
		--self:add_msg_listener( _d , _module.msg_deal )
		--
		PUBLIC.add_msg_listener( _d , _d.data , _module.msg_deal )
	end
end

--- 检查满足系统处理的组件
function C:check_system_entity(_entity)

	local _e,_id = self:get_entity(_entity)
	assert(_e,"check_system_entity error:not found entity")
	
	for _, system in ipairs(self.systems_list) do
		
		if ecs_func.check_entity_is_for_system( _e , system.data.components ) then
			if not system.data.entities[_id] then
				system.data.entities[_id] = _e
				system.module.on_entity_add(system.data , _id)
			end
		else
			if system.data.entities[_id] then
				system.module.on_entity_del(system.data , _id)
				system.data.entities[_id] = nil
			end
		end
	end
end

--- 对所有系统进行一次调用
function C:dispatch(_func_name,...)
	for system_index , system in ipairs(self.systems_list) do
		local _f = system.module[_func_name]
		if _f then
			_f(system.data,...)
		end
	end
end

--- 对所有系统进行一次调用（外部调用）
--[[function C:dispatch_extern(_func_name,...)
	for system_index , system in ipairs(self.systems_list) do
		local _f = system.module.extern and system.module.extern[_func_name]
		if _f then
			return _f(system.data,...)
		end
	end
end--]]

--- update ，需要先和客户端约定 每次update的时间间隔，比如 1/50 秒，房间服务可以不用严格按间隔调用，可以1/10秒调用
function C:update(_dt)
	--print("xxx--------------world_upadte")
	for key , sys_data in ipairs(self.systems_list) do
		if sys_data.module.update then
			sys_data.module.update( sys_data.data , _dt )
		end
	end
end


return C
---- 状态管理器的 逻辑 模板
local basefunc = require "basefunc"
local fsm_logic = require "fsm_logic"

local base = require "base"
local DATA = base.DATA
local CMD = base.CMD
local PUBLIC = base.PUBLIC


local status_logic_base = basefunc.create_hot_class("status_logic_base")
local C = status_logic_base

function C:ctor( _obj ,  _data )
	--[[
		状态逻辑控制器的 状态值。
	--]]
	self.logic_status = fsm_logic.logic_status_type.none

	self.obj = _obj
	---
	self.data = _data

	---
	self.ecs_world = _data and _data.ecs_world
	

	self:init()
end

--- 初始化
function C:init()

	self.logic_status = fsm_logic.logic_status_type.ready
end

--- 当进入状态栈
function C:begin()
	self.logic_status = fsm_logic.logic_status_type.running
end

--- 当结束,出状态列表 调用
function C:finish()

end

---- 强制停掉（外部或自己调用）
function C:stop()
	self.logic_status = fsm_logic.logic_status_type.finish
end

--- 暂停
function C:pause()
	self.logic_status = fsm_logic.logic_status_type.pause
end

--- 继续暂停
function C:resume()
	self.logic_status = fsm_logic.logic_status_type.running
end

function C:update(_dt)
	if self.logic_status ~= fsm_logic.logic_status_type.running then
		return
	end


end

return C
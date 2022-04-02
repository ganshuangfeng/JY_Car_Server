---- 车的 移动的状态
local basefunc = require "basefunc"
local fsm_logic = require "fsm_logic"

local running_status_logic = basefunc.create_hot_class("running_status_logic")
local C = running_status_logic

function C:ctor( _obj , _data )
	--[[
		状态逻辑控制器的 状态值。
	--]]
	self.logic_status = fsm_logic.logic_status_type.none

	self.obj = _obj
	---
	self.data = _data

	---
	self.ecs_world = _data and _data.ecs_world

	self.run_step = _data and _data.run_step or 0

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

	if self.run_step > 0 then
		self.run_step = self.run_step - 1

		---- 移动一次 车
		local _d = self.ecs_world.d

		PUBLIC.move_car( _d ,  self.obj , 1 , self.run_step == 0 )

		
	else
		self:stop()
	end

end

return C
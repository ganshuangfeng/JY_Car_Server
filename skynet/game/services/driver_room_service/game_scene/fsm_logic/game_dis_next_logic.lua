----  调度到下一个 权限 的 状态处理
local basefunc = require "basefunc"
local fsm_logic = require "fsm_logic"

local game_dis_next_logic = basefunc.create_hot_class("game_dis_next_logic")
local C = game_dis_next_logic

function C:ctor( _obj , _data )
	--[[
		状态逻辑控制器的 状态值。
	--]]
	self.logic_status = fsm_logic.logic_status_type.none

	self.obj = _obj
	---
	self.data = _data

	self:init()
end

--- 初始化
function C:init()

	self.logic_status = fsm_logic.logic_status_type.ready
end

--- 当进入状态栈
function C:begin()
	self.logic_status = fsm_logic.logic_status_type.running

	---- 只要一运行，就发出 切换 消息
	if self.data and self.data.ecs_world then
		self.data.ecs_world:trriger_msg( "change_game_dis_msg" )
	end

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
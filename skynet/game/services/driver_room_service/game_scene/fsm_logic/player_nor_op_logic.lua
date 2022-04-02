---- 状态管理器的 逻辑 模板
local basefunc = require "basefunc"
local fsm_logic = require "fsm_logic"

local base = require "base"
local DATA = base.DATA
local CMD = base.CMD
local PUBLIC = base.PUBLIC

local youmen_nor_logic = basefunc.create_hot_class("youmen_nor_logic")
local C = youmen_nor_logic

--- 处理消息的 函数表
C.msg_table = {}

function C:ctor( _obj ,  _data )
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

--- 当进入状态栈 , 并开始工作
function C:begin()
	self.logic_status = fsm_logic.logic_status_type.running

	
	
	if self.data and self.data.ecs_world then
		self.data.ecs_world:add_msg_listener( self , C.msg_table )
	end

end

--- 当玩家点了 油门 操作
function C.msg_table.player_click_youmen(self , _seat_num , _youmen_type )
	
	--- 确定移动 多少格
	local run_step = 10

	---- 加入 运动状态
	PUBLIC.add_fsm_wait_status( self.obj , "running" , self.obj , { ecs_world = self.data.world , run_step = run_step }  )

	self:stop()
end

--- 当结束,出状态列表 调用
function C:finish()
	if self.data and self.data.ecs_world then
		self.data.ecs_world:delete_msg_listener( self )
	end

end

---- 强制停掉（外部或自己调用）
function C:stop()
	self.logic_status = fsm_logic.logic_status_type.finish
end

--- 暂停
function C:pause()
	self.logic_status = fsm_logic.logic_status_type.pause

	if self.data and self.data.ecs_world then
		self.data.ecs_world:delete_msg_listener( self )
	end
end

--- 继续暂停
function C:resume()
	self.logic_status = fsm_logic.logic_status_type.running

	if self.data and self.data.ecs_world then
		self.data.ecs_world:add_msg_listener( self , C.msg_table )
	end

end

function C:update(_dt)
	if self.logic_status ~= fsm_logic.logic_status_type.running then
		return
	end


end

return C
----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("clear_sys_skill_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)

	
end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	
	if self.d.system_obj and self.d.system_obj.skill then
		for skill_id , skill_obj in pairs(self.d.system_obj.skill) do
			PUBLIC.delete_skill( skill_obj )
		end
	end

	self:destroy()
end

return C


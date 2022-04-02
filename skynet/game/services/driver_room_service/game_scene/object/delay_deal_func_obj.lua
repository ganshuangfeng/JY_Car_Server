----- 延迟 处理 函数的 obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("delay_deal_func_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.func = _config.func

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
	if self.func and type(self.func) == "function" then
		self.func()
	end

	self:destroy()
end

return C


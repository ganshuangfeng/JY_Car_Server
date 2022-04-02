----- 创建 并使用 道具

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("create_and_use_tools_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	--- 道具id
	self.tool_id = _config.tool_id

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
	self:destroy()

	----- 创建道具
	PUBLIC.create_tools( self.d , self.owner.seat_num , self.tool_id )

	PUBLIC.use_tools( self.d , self.owner.seat_num , self.tool_id )
	
end

return C


----- 创建 道具

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("create_tools_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	
	---------------------------------------------------- 特殊项 ↓
	self.seat_num = self.owner.seat_num
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
	PUBLIC.create_tools( self.d , self.seat_num , self.tool_id , self.father_process_no)

	------ 如果 道具 类型数量 大于 4 了 ，自动使用
	if self.d.tools_info[ self.seat_num ] and basefunc.key_count( self.d.tools_info[ self.seat_num ] ) > 4 then
		--- 直接使用
		PUBLIC.use_tools( self.d , self.seat_num , self.tool_id )

	end

end

return C


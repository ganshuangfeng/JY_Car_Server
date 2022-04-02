----- ptg 触发 基础技能的obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("ptg_trigger_base_skill_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	---- ptg 基础技能id
	self.base_skill_id = 1007

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
	----- 找到
	if self.owner and self.owner.skill and self.owner.skill[ self.base_skill_id ] then

		self.owner.skill[ self.base_skill_id ]:trigger_zhudong_skill()
	end

	self:destroy()
end

return C


----- 杀掉 父obj   （这个需要 改 common task  的一个条件触发，导致多种对象的操作）

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("kill_father_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

function C:init()
	---- 基类处理
	self.super.init(self)
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	----- 
	-------- 现阶段 只能删除 路障
	if self.skill_owner and self.skill_owner.kind_type == DATA.game_kind_type.road_barrier then
		print("xxxx-------------------delete_map_barrier")
		PUBLIC.delete_map_barrier(self.d , self.skill_owner )
	end

	self:destroy()
end

return C



----- 杀掉技能 (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("kill_skill_obj" , "object_class_base" )

--[[
	油门种类：
		big_youmen
		small_youmen
--]]
--[[
	_config={
		type
		owner
		car_id
	}
--]]

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
	---- 删掉技能
	PUBLIC.delete_skill( self.skill )

	self:destroy()
end

return C


----- 触发 车辆大技能 的技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_big_skill_trigger_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	---- 基类处理
	self.super.init(self)

end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	
	local skill_data = nil -- self.owner.skill_tag["big"]


	---- 找到大技能
	if self.owner.skill then
		for skill_id , skill_obj in pairs( self.owner.skill ) do
			local skill_tag = skill_obj.tag

			if skill_tag[ "big_skill" ] then
				skill_data = skill_obj

				break
			end
		end
	end


	if skill_data then
		skill_data:trigger_zhudong_skill()
	end

	self:destroy()
end

return C


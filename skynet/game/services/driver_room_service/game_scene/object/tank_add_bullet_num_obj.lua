----- 坦克专属  ， 增加子弹个数 的obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("tank_add_bullet_num_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	self.add_num = _config.add_num

	---- 坦克的基础技能
	self.tank_base_skill_id = 1003

end

---- 当 obj 创建之后调用
function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )

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
	---- 如果 owner 的类型不是坦克
	if self.owner.id ~= 2 then
		self:destroy()
		return
	end

	local skill_obj = PUBLIC.get_skill_by_id( self.owner , self.tank_base_skill_id )

	if skill_obj and skill_obj.add_extra_bullet_num then
		skill_obj.add_extra_bullet_num( self.add_num )
	end

	self:destroy()
end

return C


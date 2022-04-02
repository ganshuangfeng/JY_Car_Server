----- 车辆停止 obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_stop_obj" , "object_class_base" )
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
	self:destroy()
	----- 触发停止 车辆移动消息 ; 被路障拦截停下来，不能
	PUBLIC.trriger_msg( self.d , "force_stop_car" , { stay_road_award = true } )

	
end

return C


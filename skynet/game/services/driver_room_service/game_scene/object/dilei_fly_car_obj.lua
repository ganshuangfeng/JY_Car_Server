----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("dilei_fly_car_obj" , "object_class_base" )
C.msg_deal = {}
C.fly_dis = 2

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)

	self.fly_dis = C.fly_dis
end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end



function C:run()

	--local random = math.random、
	local old_pos = self.owner.pos
	self.owner.pos = self.owner.pos + math.random(-self.fly_dis,self.fly_dis)
	
	--发送消息给client
	self.d.running_data_statis_lib.add_game_data( self.d , {
		obj_car_transfer = {
			car_no = self.owner.car_no ,
			pos = old_pos ,
			end_pos = self.owner.pos ,
		} } , self.father_process_no
	)

	
	PUBLIC.trriger_msg( self.d , "dilei_fly_car" , { trigger = self.owner , down_pos = self.owner.pos , skill_owner = self.skill_owner } )

	
	self:destroy()
end

return C


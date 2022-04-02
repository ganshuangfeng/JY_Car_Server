-----  创建障碍 obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("create_barrier_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.barrier_id = _config.barrier_id

end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)
	
	---- 强行转成 车辆
	--self.owner = PUBLIC.get_car_info_by_data( self.d , self.owner)
end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	
	---- 选择一个空的 位置
	local tar_vec = self.d.single_obj["driver_map_manager"]:get_map_road_vec( 
		"empty"  
	)

	----- 位置随机 
	if tar_vec and next( tar_vec ) then
		PUBLIC.create_map_barrier( self.d , self.barrier_id , tar_vec[ math.random(#tar_vec ) ] , nil , self.owner )
	end

	self:destroy()

end

return C


-----  导航器的 设置位置的 obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("induce_set_pos_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	---- 范围几格
	self.range_num = _config.range_num or 3

end

---- 当 obj 创建之后调用
function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.road_barrier )

	---- 基类处理
	self.super.init(self)
	
	---- 找到 导航器 对应的 我的车
	self.owner_car = PUBLIC.get_car_info_by_data( self.d , self.owner.owner )
	if not self.owner_car then
		print( string.format("xxxx------------- error run_obj__%s not self.owner_car !! " , "induce_set_pos_obj" ) )
		return
	end

	self.seat_num = self.owner_car.seat_num

end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	print("xxx-------------- induce_sest_pos_obj run")
	local rand = math.random( - math.ceil( (self.range_num - 1) / 2 ) , math.floor( (self.range_num - 1) / 2 ) )   -- math.random( -self.range_num , self.range_num )
	local owner_road_id = self.owner.road_id

	local tar_road_id = owner_road_id + rand

	tar_road_id = (tar_road_id > self.d.map_length) and (tar_road_id - self.d.map_length) or tar_road_id
	tar_road_id = (tar_road_id < 0) and (self.d.map_length + tar_road_id) or tar_road_id

	local owner_car_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner_car.pos ) 

	---- 获取目标点，在我前方多少格，考虑了正反向
	local move_num = PUBLIC.get_road_id_dir_dis( self.d , owner_car_road_id , tar_road_id , PUBLIC.get_tag( self.owner_car , "move_reverse") ) 

	self.d.debug_move_num = self.d.debug_move_num or {}
	self.d.debug_move_num[self.seat_num] = math.abs( move_num )

	self:destroy()

end

return C


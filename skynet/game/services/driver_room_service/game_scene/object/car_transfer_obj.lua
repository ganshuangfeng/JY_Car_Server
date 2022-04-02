
----- 玩家 传送  的  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local move_skill_lib = require "driver_room_service.game_scene.object.car_move_skill_lib"

local C = basefunc.create_hot_class("car_transfer_obj" , "object_class_base" )


function C:ctor(_d  , _config)

		---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num
	--- 传送 多少格
	self.transfer_num = _config.transfer_num

	--self.transfer_circle = 3	 --_config.transfer_circle

	--- 
	
	------------------------ 组装自己的数据 ↑

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

	---- 传送
	local old_pos = self.owner.pos


	self.owner.pos = self.owner.pos + self.transfer_num

	---- 搜集数据
	print("7777777777777777777777777777777777777777777777")
	self.d.running_data_statis_lib.add_game_data( self.d , {
		obj_car_transfer = {
			car_no = self.owner.car_no ,
			pos = old_pos ,
			end_pos = self.owner.pos ,
		} } , self.father_process_no
	)
	self.owner.is_move = true
	------ 触发 开奖
	
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_before_-2" , { trigger = self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_before_-1" , { trigger = self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_before" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_award_before" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_after" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_award_after" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_after_2" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num , move_type = "transfer" } )

	self.owner.is_move = false

	self:destroy()
end

return C


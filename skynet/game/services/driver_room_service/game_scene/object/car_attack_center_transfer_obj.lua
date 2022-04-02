
----- 玩家 传送  的  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local move_skill_lib = require "driver_room_service.game_scene.object.car_move_skill_lib"

local C = basefunc.create_hot_class("car_attack_center_transfer_obj" , "object_class_base" )


function C:ctor(_d  , _config)

		---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num
	--- 传送 多少格
	self.transfer_circle_xishu = _config.transfer_circle_xishu


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

	local transfer_circle = self.transfer_circle_xishu/100 * self.d.map_game_over_circle
	--local tar_pos = self.owner.pos + self.transfer_num
	self.owner.pos = self.owner.pos +  transfer_circle * self.d.map_length + math.random(0,21)

	----- 避免停在相同位置
	local canot_stay_road_id_map = {}
	local other_cars = PUBLIC.get_game_obj_by_type( self.d , self.owner , "other" )
	if other_cars and type(other_cars) == "table" then
		for key,car_data in pairs( other_cars ) do
			canot_stay_road_id_map[#canot_stay_road_id_map + 1] = PUBLIC.get_grid_id_quick( self.d , car_data.pos )
		end
		dump(canot_stay_road_id_map,"canot_stay_road_id_map")
		--canot_stay_road_id_map = basefunc.list_to_map( canot_stay_road_id_map )
	end
	local my_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos )
	for i=1,#canot_stay_road_id_map do
		print("tttttttttttttttttttttttttt",canot_stay_road_id_map[i])
		if canot_stay_road_id_map[i] == my_road_id then
			self.owner.pos = self.owner.pos + 1
			break
		end
	end

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
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_before" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_after" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num } )
	PUBLIC.trriger_msg( self.d , "position_relation_stay_road_after_2" , { trigger =  self.owner , road_id = self.owner.pos , seat_num = self.seat_num } )

	self.owner.is_move = false

	self:destroy()
end

return C


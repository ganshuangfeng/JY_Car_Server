----- 车辆移动 操作 ，(处理单元)

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA
DATA.car_move_skill_lib = {}
local C = DATA.car_move_skill_lib

--[[
	_donot_act 表示 不能做的操作
--]]
function C.move(obj , _d , _move_num , _donot_act )
	local move_num = _move_num or 1
	local donot_act = _donot_act or {}

	if obj.move_step > 0 then
		obj.owner.is_move = true
	end

	local old_pos = obj.owner.pos

	--print("xxx------------------ move_car_" , obj.type)
	if obj.move_step > 0 and move_num > 0 then
		---- 移动 步骤 减
		obj.move_step = obj.move_step - move_num

	
		--------------------------------------------- 移动 操作

		--local now_pos = 
		--local will_move_pos = obj.owner.pos

		local pos_move = (PUBLIC.get_tag( obj.owner , "move_reverse") and -1 or 1) * move_num

		
		----- 位置 改变
		obj.owner.pos = obj.owner.pos + pos_move

		------ 如果终点关闭，每次经过起点时，删除一圈的长度
		local is_close_destination = DATA.car_prop_lib.get_car_prop( obj.owner , "is_close_destination") 
		if is_close_destination and is_close_destination == 1 and obj.owner.pos % _d.map_length == 1 then
			obj.owner.virtual_circle = obj.owner.virtual_circle or 0
			obj.owner.virtual_circle = obj.owner.virtual_circle + pos_move --(is_move_reverse and -1 or 1)
		end

		----- 发送 经过起点 消息。
		if not donot_act["moveIn_start_point"] then

			if PUBLIC.get_grid_id_quick( _d , obj.owner.pos ) == 1 then
				PUBLIC.trriger_msg( obj.d , "position_moveIn_start_point" , { trigger = obj.owner , move_type = obj.type } ) 
			end
		end


		if not donot_act["moveIn"] then
			PUBLIC.trriger_msg( obj.d , "position_relation_moveIn_before" , { trigger = obj.owner , road_id = obj.owner.pos , old_pos = old_pos , move_type = obj.type } )
			--- 处理 进入 当前格
			PUBLIC.trriger_msg( obj.d , "position_relation_moveIn" , { trigger = obj.owner , road_id = obj.owner.pos , old_pos = old_pos ,  move_type = obj.type , move_step = obj.move_step} )

			PUBLIC.trriger_msg( obj.d , "position_relation_moveIn_after" , { trigger = obj.owner , road_id = obj.owner.pos , old_pos = old_pos ,  move_type = obj.type } )
		end
		
		---- 发出 已经经过路程 消息
		PUBLIC.trriger_msg( obj.d , "position_road_pass" , { trigger = obj.owner , car_id = obj.owner.id , old_pos = old_pos , now_pos = obj.owner.pos , move_type = obj.type } )

	end

	--- 当移动完成，发出 停留 事件 ( 考虑非正常停留 是否会触发事件 )
	if obj.move_step <= 0 then
		local stay_data = { trigger = obj.owner , road_id = obj.owner.pos , old_pos = old_pos , seat_num = obj.seat_num , move_type = obj.type}

		if not donot_act["stay_road"] then
			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_before_-2" , stay_data )

			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_before_-1" , stay_data )

			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_before" , stay_data )
		end
		if not donot_act["stay_road_award"] then 
			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_award_before" , stay_data )
		end
		if not donot_act["stay_road"] then
			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road" , stay_data )
		
			----- 
			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_after" , stay_data )
		end
		if not donot_act["stay_road_award"] then 
			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_award_after" , stay_data )
		end
		if not donot_act["stay_road"] then
			PUBLIC.trriger_msg( obj.d , "position_relation_stay_road_after_2" , stay_data )
			
		end

		obj:destroy()
	
		obj.owner.is_move = false

	elseif obj.move_step > 0 then
		----- 发送，将要移进去 的消息

 		local pos_move = (PUBLIC.get_tag( obj.owner , "move_reverse") and -1 or 1) * 1

 		local will_move_pos = obj.owner.pos + pos_move

		if not donot_act["will_moveIn"] then
			PUBLIC.trriger_msg( obj.d , "position_relation_will_moveIn" , { trigger = obj.owner , trigger_pos = will_move_pos ,  } )
		end
	end

end


return C
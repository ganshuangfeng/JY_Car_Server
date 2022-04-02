
----- 等待 车辆移动   的  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"
local skynet = require "skynet_plus"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local move_skill_lib = require "driver_room_service.game_scene.object.car_move_skill_lib"


local C = basefunc.create_hot_class("youmen_obj" , "object_class_base")
C.msg_deal = {}
--[[
	油门种类：
		big_youmen
		small_youmen
		sprint
		
--]]
--[[
	_config={
		type
		owner
		car_id
	}
--]]

function C:ctor(_d  , _config)
	print("xxx---------------------new__youmen_skill")
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	self.type = _config.type
	
	self.seat_num = self.owner.seat_num

	----
	self.move_step = _config.move_step

	---- 是否第一次移动
	self.is_first_move = true

	-----
	self.not_msg_act = basefunc.list_to_map( _config.not_msg_act )

	--self.is_ptg_move = 0

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	---- 基类处理
	self.super.init(self)
	
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )

	--查看是否有双倍奖励
	local is_double = false
	if PUBLIC.get_tag( self.owner , "double_award" ) then
		is_double = true
	end
	local extra_award_num =  DATA.car_prop_lib.get_car_prop( self.owner , "n2o_award_extra_num" )

	----- 设置标签，已经创建了 冲刺 obj
	if self.type == "sprint" then
		PUBLIC.add_tag( self.owner , "create_sprint_obj" )
		if is_double then
			extra_award_num = extra_award_num + 1
		end
		self.move_step = self.move_step * extra_award_num + self.move_step
	end



	------------- 大油门，sp 作用  , sp   10  是基础值，相当于1
	if self.type == "big_youmen" then
		local speed = DATA.car_prop_lib.get_car_prop( self.owner , "sp" )
		print("xxx---------------youmen_obj___speed:" , speed)

		--local add_bei = speed / 10

		self.move_step = math.floor( self.move_step + speed * self.d.map_length )

		--拿到是否有能量储备增加的移动步数
		self.owner.extra_move_step = DATA.car_prop_lib.get_car_prop( self.owner , "extra_move_step" )
		--1.ptg大油门移动加上蓄力时加的额外移动步数    2.车加上自己能量储备增加的移动步数
		if self.owner.extra_move_step ~= nil then
			self.move_step = self.move_step + self.owner.extra_move_step
			self.owner.extra_move_step = 0
		end
		--if self.owner.id == 3 then
		--	if self.move_step % self.d.map_length ~= 0 then
		--		self.move_step = self.move_step - math.fmod(self.move_step,self.d.map_length) + self.d.map_length
		--	end
		--end

	end



	--if self.type == "ptg_big_youmen" then
	--	self.is_ptg_move = 1
	--end

	--if self.type == "ptg_attack" then
	--	self.is_ptg_move = 0
	--end

	----- 导航器的强行 设置



	----- 避免停在相同位置
	local other_cars = PUBLIC.get_game_obj_by_type( self.d , self.owner , "other" )
	local dir = 1
	if other_cars and type(other_cars) == "table" then
		local canot_stay_road_id_map = {}
		for key,car_data in pairs( other_cars ) do
			canot_stay_road_id_map[#canot_stay_road_id_map + 1] = PUBLIC.get_grid_id_quick( self.d , car_data.pos )
		end
		canot_stay_road_id_map = basefunc.list_to_map( canot_stay_road_id_map )

		--is_move_reverse = PUBLIC.get_tag( self.owner , "move_reverse") 

		for i = 1, self.d.map_length do
			local owner_end_road_id = nil
			if PUBLIC.get_tag( self.owner , "move_reverse") then                ----处理逆向行驶重叠问题
				owner_end_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos - self.move_step )
			else
				owner_end_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos + self.move_step )
			end

			if not canot_stay_road_id_map[owner_end_road_id] then
				break
			else
				self.move_step = self.move_step + 1 * dir
			end
			if self.move_step == 6 then
				dir = -1
			end
		end

	end


	
end

---- 第一次在 run_system中唤醒时调用 
function C:wake()
	print("xxx----youmen wake self.type" , self.type)
	----- 设置标签
	PUBLIC.add_tag( self.owner , "move_type_" .. self.type )

	----- 强制移动步数 (客户端设置的)
	if self.d.debug_move_num and self.d.debug_move_num[self.seat_num] then
		local move_num = self.d.debug_move_num[self.seat_num]
		self.d.debug_move_num[self.seat_num] = nil

		local move_circle = math.floor( self.move_step / self.d.map_length )

		self.move_step = move_circle * self.d.map_length + move_num
	end

	----- 强行测试
	--if skynet.getcfg("is_open_drive_move_test") then
		
		if self.d.test_move_list and type(self.d.test_move_list) == "table" and next(self.d.test_move_list) then
			if self.d.test_move_list[1] and type(self.d.test_move_list[1]) == "number" then
				
				local move_circle = math.floor( self.move_step / self.d.map_length )

				--self.move_step = self.d.test_move_list[1]

				self.move_step = move_circle * self.d.map_length + self.d.test_move_list[1]

				table.remove( self.d.test_move_list , 1 )
			end
		end

	--end


	------ 处理正常和倒车移动
	local move_nums = self.move_step
	print("xxx-------------youmen___wake 111")
	if PUBLIC.get_tag( self.owner , "move_reverse") then
		print("xxx-------------youmen___wake 222")
		move_nums = -self.move_step
	end

	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , {
		obj_car_move = {
			car_no = self.owner.car_no ,
			pos = self.owner.pos ,
			type = self.type ,
			move_nums = move_nums ,
		} } , self.father_process_no
	)
	
	PUBLIC.trriger_msg( self.d , "will_move_before" , { move_step = self.move_step , move_type = self.type , trigger = self.owner } )
	--print("youmengei pu tong gongji fa xiao xi pppppppppppppppppppppppppppppppppp222222")
	
	--增加监听消息，大油门时给平头哥普通攻击传车辆move_step
end

function C:destroy()
	PUBLIC.delete_msg_listener( self.d , self )
	self.is_run_over = true

	PUBLIC.delete_tag( self.owner , "move_type_" .. self.type )

	PUBLIC.delete_tag( self.owner , "create_sprint_obj" )
end

function C:run()

	print("xxx---------------------run__youmen_obj" , self.type , self.is_run_over and "true" or "false")
	if self.is_first_move then
		move_skill_lib.move(self , self.d , 0, self.not_msg_act )
		self.is_first_move = false
	else
		move_skill_lib.move(self , self.d , nil, self.not_msg_act )
	end
	
end

---- 强制停掉车辆
function C.msg_deal:force_stop_car( _not_msg_act_map )
	self:destroy()
	self.move_step = 0

	---- 合并 不处理的消息
	local not_msg_act_tem = basefunc.deepcopy( self.not_msg_act )
	if _not_msg_act_map and type(_not_msg_act_map) == "table" then
		not_msg_act_tem = basefunc.merge( _not_msg_act_map , not_msg_act_tem )
	end

	move_skill_lib.move(self , self.d , nil , not_msg_act_tem )

end

return C 


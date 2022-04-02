----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("radar_set_hp_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)
	local enemy_vec = PUBLIC.get_game_obj_by_type( self.d , self.owner , "enemy" )
	self.tar_enemy = enemy_vec[1]
end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end



function C:run()
	
	local my_hp_max = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" ) 
	local enemy_hp_max = DATA.car_prop_lib.get_car_prop( self.tar_enemy , "hp_max" ) 
	--self.owner.hp=my_hp_max/2
	--self.tar_enemy.hp=enemy_hp_max/2

	local data = { owner = self.tar_enemy , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
			level = 1 , 
			obj_enum = "car_modify_property_obj",
			modify_key_name = "hp",
			modify_type = 3,
			modify_value = enemy_hp_max/2 ,
			modify_tag = {"kelongtianshi"},
			--percent_base_value = now_hp_max_value ,
			--percent_base_type = "hp_max" ,
		}

	local run_obj = PUBLIC.create_obj( self.d , data )
	if run_obj then
		---- 加入 运行系统
		self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
	end


	local data = { owner = self.owner , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
			level = 1 , 
			obj_enum = "car_modify_property_obj",
			modify_key_name = "hp",
			modify_type = 3,
			modify_value = my_hp_max/2 ,
			modify_tag = {"kelongtianshi"},
			--percent_base_value = now_hp_max_value ,
			--percent_base_type = "hp_max" ,
		}

	local run_obj = PUBLIC.create_obj( self.d , data )
	if run_obj then
		---- 加入 运行系统
		self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
	end

	self:destroy()
end

return C


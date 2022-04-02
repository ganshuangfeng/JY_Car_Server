------ 平头哥 大技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.ptg_big_skill_protect = {}
local D = DATA.ptg_big_skill_protect

---- 召唤的车辆数量
D.call_car_num = { min = "$min_value" , max = "$max_value" } -- { min = "$zh_count_min" , max = "$zh_count_max" }

--- 最小成功个数
D.success_min = "$value"

---- 普通攻击倍数
D.damage_time = "$at_factor"
--- 固定伤害
D.fix_damage = "$fix_at_value"



function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	function C:init( _father_process_no )
		
		PUBLIC.convert_chehua_config( self.d , D.call_car_num , self.id , self.owner and self.owner.seat_num)
		self.success_min = PUBLIC.convert_chehua_config( self.d , D.success_min , self.id , self.owner and self.owner.seat_num)
		self.fix_damage = PUBLIC.convert_chehua_config( self.d , D.fix_damage , self.id , self.owner and self.owner.seat_num)
		self.damage_time = PUBLIC.convert_chehua_config( self.d , D.damage_time , self.id , self.owner and self.owner.seat_num)

		--self.success_min = D.success_min
		--self.fix_damage = D.fix_damage
		--self.damage_time = D.damage_time


		---- 加入obj的技能列表
		self.create_skill_process_no = PUBLIC.add_skill( self , _father_process_no )

		--- 处理 消息监听
		self:deal_msg()

		--self:deal_on_create_msg()
		---- 处理消息
		self:common_deal_on_msg( "on_create" )

		---- 处理消息
		self:common_deal_on_msg( "on_create_after" )
	end

	------ 创建 运行 obj
	function C:create_run_obj( _work_module , skill_target )
		print("xxx---------------ptg_big_skill ")
		---- 创建多少辆车
		local create_num = math.random( D.call_car_num.min , D.call_car_num.max )

		---- 真正命中的数量
		local real_hit_num = math.random( math.min( self.success_min , create_num ) , create_num )
		local miss_num = create_num - real_hit_num

		for i = 1, miss_num do
			for key, target in pairs(skill_target) do
				local data = { owner = target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
					level = 1 , 
					obj_enum = "car_modify_property_obj",
					modify_key_name = "hp",
					modify_type = 1,
					modify_value = 0 ,
					modify_tag = { "miss" } ,
				}

				local run_obj = PUBLIC.create_obj( self.d , data )
				if run_obj then
					---- 加入 运行系统
					self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
				end
			end
		end

		for i = 1 , real_hit_num do
			for key, target in pairs(skill_target) do
				
				local data = { owner = target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
					level = 1 , 
					obj_enum = "car_attack_obj",
					base_at_time = self.damage_time ,
					fix_at_value = self.fix_damage ,

					can_deal_act = { "bj_act" , } , 
					modify_tag = { "act_can_damage_rebound"  } ,  --- 能反伤
				}

				local run_obj = PUBLIC.create_obj( self.d , data )
				if run_obj then
					---- 加入 运行系统
					self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
				end
			end
		end


	end


	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
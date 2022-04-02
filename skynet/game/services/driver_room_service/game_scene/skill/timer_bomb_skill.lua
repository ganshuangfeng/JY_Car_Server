------ 定时炸弹的 技能 ， 有技能倒计时，

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.timer_bomb_skill_protect = {}
local D = DATA.timer_bomb_skill_protect

---- 基础攻击的系数
D.at_factor = "$at_factor"
---- 固定的伤害值
D.fix_at_value = "$fix_at_value"


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	
	function C:init(_father_process_no)

		self.at_factor = PUBLIC.convert_chehua_config( self.d , D.at_factor , self.id , self.owner and self.owner.seat_num )
		self.fix_at_value = PUBLIC.convert_chehua_config( self.d , D.fix_at_value , self.id , self.owner and self.owner.seat_num )

		local timer_bomb = self.owner
		self.timer_bomb_owner_car = timer_bomb.owner

		---- 如果有定时炸弹的创建车
		if self.timer_bomb_owner_car and self.timer_bomb_owner_car.kind_type == DATA.game_kind_type.car then
			local at_value = DATA.car_prop_lib.get_car_prop( self.timer_bomb_owner_car , "at" )

			self.tar_at_value = math.floor( at_value * self.at_factor + self.fix_at_value )

		end

		
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

	------ 创建 运行 obj   用定时炸弹的创建者的 基础攻击力的%多少 和 固定伤害值之和
	function C:create_run_obj( _work_module , skill_target )
		
		if self.tar_at_value then
			for key, target in pairs(skill_target) do
				
				---- 加减血
				local data = { owner = target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
					level = 1 , 
					obj_enum = "car_modify_property_obj",
					modify_key_name = "hp",
					modify_type = 1,
					modify_value = -self.tar_at_value ,
				}

				local run_obj = PUBLIC.create_obj( self.d , data )
				if run_obj then
					---- 加入 运行系统
					self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
				end

			end

			---- 最后加一个删除 主体
			local data = { owner = self.owner , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
				level = 1 , 
				obj_enum = "kill_father_obj",
			}

			local run_obj = PUBLIC.create_obj( self.d , data )
			if run_obj then
				---- 加入 运行系统
				self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
			end


		end
	end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
------ 坦克大技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.tank_big_skill_protect = {}
local D = DATA.tank_big_skill_protect

D.fire_num = { min = 2 , max = 3 } -- { min = "$min_value" , max = "$max_value" }
--- 固定伤害
D.fix_damage = "$fix_at_value"
--- 自身伤害倍数
D.damage_time = "$at_factor"

---
D.tank_base_skill_id = 1003

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	--- 初始化 ， 当技能创建之后调用
	function C:init( _father_process_no )

		--PUBLIC.convert_chehua_config( self.d , D.fire_num , self.id , self.owner and self.owner.seat_num )
		self.fix_damage = PUBLIC.convert_chehua_config( self.d , D.fix_damage , self.id , self.owner and self.owner.seat_num )
		self.damage_time = PUBLIC.convert_chehua_config( self.d , D.damage_time , self.id , self.owner and self.owner.seat_num )
		print("xxx------------------tank_big_skill:" , self.fix_damage , self.damage_time)
		dump(D.fire_num , "xxxx---------------D.fire_num:")

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

	--- 处理操作
	function C:deal_work( _work_module , _arg_table)
		---- 处理 前置条件检查
		if not self:deal_work_condition(_work_module.work_condition)  then
			return false
		end

		local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

		if skill_target then

			----------------------------------- 记录过程数据
			local trigger_data = _arg_table.trigger and { PUBLIC.get_game_owner_data( _arg_table.trigger ) } or {}
			-----
			---- 记录一下
			self.skill_target = skill_target

			local receive_data = {}
			for key,data in pairs(skill_target) do
				receive_data[#receive_data+1] = PUBLIC.get_game_owner_data( data )
			end

			----- 收集数据 , 技能触发
			------------- 忽略不必要的 过程数据
			if not DATA.process_ignore_skill_key[ self.config.key ] then
				self.last_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
					skill_trigger = {
						owner_data = PUBLIC.get_game_owner_data( self.owner )  ,

						skill_data =  DATA.game_info_center.get_one_skill_data( self ) ,
						
						trigger_data = trigger_data ,
						receive_data = receive_data ,

						skill_name = self.config.name ,
						
					} } , self.create_skill_process_no
				)
			end

			------------------------------------------- 执行操作
			local skill_owner_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos) 

			----- 如果有普通攻击技能 ， 获得他的最大子弹数量
			local tank_base_skill = PUBLIC.get_skill_by_id( self.owner , D.tank_base_skill_id )
			local tank_base_skill_max_bullet = nil
			if tank_base_skill then
				tank_base_skill_max_bullet = tank_base_skill:get_max_bullet_num()
			end

			for key, target in pairs(skill_target) do
				------
				repeat

				------ 被打目标 和 技能车辆 在同一位置不能开炮
				local target_road_id = PUBLIC.get_grid_id_quick( self.d , target.pos) 
				if skill_owner_road_id == target_road_id then
					break
				end

				local attck_num = math.random( D.fire_num.min , D.fire_num.max )

				if tank_base_skill_max_bullet then
					attck_num = tank_base_skill_max_bullet
				end

				--local real_damage_value = D.fix_damage + self.owner.at * D.damage_time

				for i = 1,attck_num do
					print("xxxxxxx---------------------big_skill__modify__hp")
					local data = { owner = target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
						level = 1 , 
						obj_enum = "car_attack_obj",
						base_at_time = self.damage_time ,
						fix_at_value = self.fix_damage ,
						not_deal_act = { "lj_act" } ,     --- 不能连击
						can_deal_act = { "bj_act" } ,	  --- 能暴击 , 不能连击
						modify_tag = { "act_can_damage_rebound"  } ,  --- 能反伤
					}

					local run_obj = PUBLIC.create_obj( self.d , data )
					if run_obj then
						---- 加入 运行系统
						self.d.game_run_system:create_add_event_data(
							run_obj , 1 , "next"
						) 
					end
				end

				until true
			end
			
			------ 清掉普通攻击的子弹
			if tank_base_skill then
				tank_base_skill:add_extra_bullet_num( -9999 )
			end

			--------------------------------------------- 生命周期处理
			if self.life_type and self.life_value and self.life_type == "trigger_num" then
				self.life_value = self.life_value - 1

				if self.life_value <= 0 then
					---- 删掉
					PUBLIC.delete_skill( self )
				end
			end

		end

		return true
	end


	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
------ 这个暂时废掉

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.ptg_nor_attack_skill_protect = {}
local D = DATA.ptg_nor_attack_skill_protect

--D.attack_damage = 50    --基础攻击
D.attack_radius = "$range"
D.attack_coefficient = "$value_bfb"   --伤害系数
D.attack_enemy_extra_pos = "$value"    --攻击敌人使其在我前面move_circle除以这个值的位置
--D.circle_coefficient = 2   --圈数系数


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
		--- 初始化 ， 当技能创建之后调用
	function C:init()

		--PUBLIC.convert_chehua_config( self.d , D.call_car_num , self.id , self.owner and self.owner.seat_num )
		self.attack_radius = PUBLIC.convert_chehua_config( self.d , D.attack_radius , self.id , self.owner and self.owner.seat_num )
		self.attack_coefficient = PUBLIC.convert_chehua_config( self.d , D.attack_coefficient , self.id , self.owner and self.owner.seat_num )
		self.attack_enemy_extra_pos = PUBLIC.convert_chehua_config( self.d , D.attack_enemy_extra_pos , self.id , self.owner and self.owner.seat_num )
		--self.circle_coefficient = PUBLIC.convert_chehua_config( self.d , D.circle_coefficient , self.id , self.owner and self.owner.seat_num )
		
		--self.attack_radius = D.attack_radius
		--self.attack_coefficient = D.attack_coefficient
		--self.circle_coefficient = D.circle_coefficient
		--self.attack_damage = D.attack_damage
		self.will_attack = 1
		self.is_move_reverse = false
		self.real_attack_radius = 0

		self.move_step = 0
		---- 加入obj的技能列表
		self.create_skill_process_no = PUBLIC.add_skill( self )

		print("xx-------------------------------create ptg_nor_attack_skill")

		--- 处理 消息监听
		self:deal_msg()

		--self:deal_on_create_msg()
		---- 处理消息
		self:common_deal_on_msg( "on_create" )

		---- 处理消息
		self:common_deal_on_msg( "on_create_after" )
	end

	function C:deal_other_msg()
		---- 监听油门发送的move_step 并保存
		self.msg_deal["will_move_before"] = function(_self , _arg )
			self.move_type = _arg.move_type
			self.move_step = _arg.move_step
			self.will_attack = 1
		end
		self.msg_deal["force_stop_car"] = function(_self )
			self.will_attack = 0
		end
	end

	function C:deal_work( _work_module , _arg_table)
		if self.move_type == "big_youmen" then
			if self.will_attack == 1 then
				--print("ptg_deal_work_stat ppppppppppppppppppppppppppppppppppppppppppppppppppppp")
				if not self:deal_work_condition(_work_module.work_condition)  then
					return false
				end
				--是否逆向行驶
				if PUBLIC.get_tag( self.owner , "move_reverse") then
					self.is_move_reverse = true
				end

				local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

				if skill_target then
					----------------------------- 先找出 可以 触发的 对象
					local can_trigger_target = {}

					local skill_owner_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos) 

					-- 前面用接受消息拿到车的move_step
					local move_circle = math.floor( self.move_step / self.d.map_length )
					local car_at = DATA.car_prop_lib.get_car_prop( self.owner , "at" )

					local real_attack_radius = self.attack_radius  + move_circle
					local real_attack_damage = car_at  * move_circle * self.attack_coefficient / 100
					self.real_attack_radius = real_attack_radius
					print("99999999999999999999999999999999999999999999999999999999999,", real_attack_radius,real_attack_damage,move_dir)
					for key, target in pairs(skill_target) do
						------ 被打目标 和 技能车辆 在同一位置不能攻击
						 --[[local target_road_id = PUBLIC.get_grid_id_quick( self.d , target.pos) 
						if skill_owner_road_id == target_road_id then
							print("xxxx--------------ptg_nor_attack_skill______ same road_id")
							break
						end

						------- 判断 目标 在 范围内
						if target_road_id > skill_owner_road_id  and target_road_id - skill_owner_road_id > real_attack_radius then
							print("xxxx--------------ptg_nor_attack_skill______out dis")
							break
						end
						if skill_owner_road_id > target_road_id and target_road_id + self.d.map_length - skill_owner_road_id > real_attack_radius then
							print("xxxx--------------ptg_nor_attack_skill______out dis")
							break
						end
						--]]


						if PUBLIC.check_pos_range(self.d,self.owner.pos,self.is_move_reverse,target.pos,2,real_attack_radius) == true then
							can_trigger_target[#can_trigger_target + 1] = target
						end
						print("123")

					end

					if next(can_trigger_target) then
						print("1111111111111111111111111111")
						self:deal_skill_trigger_process_data(skill_target,_arg_table , _work_module.trigger_msg )


						for key, target in pairs(can_trigger_target) do
							------
							repeat
								
							------ 真正的攻击
							--local real_damage_value = self.fix_damage + at_value * self.damage_time
							local data = { owner = target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
								level = 1 , 
								obj_enum = "car_attack_obj",
								--base_at_time = 10 ,
								fix_at_value = real_attack_damage , 
								--not_deal_act = { "lj_act" } ,

								can_deal_act = { "bj_act" , "lj_act" , "extra_lj_act" } ,               --- 能暴击 , 能连击
								modify_tag = { "act_can_damage_rebound"  } ,  --- 能反伤
							}

							local run_obj = PUBLIC.create_obj( self.d , data )
							if run_obj then
								---- 加入 运行系统
								self.d.game_run_system:create_add_event_data(
									run_obj , 1 , "next"
								) 
							end

							local enemy_old_pos = target.pos
							target.pos = target.pos + (move_circle // self.attack_enemy_extra_pos)	

							self.d.running_data_statis_lib.add_game_data( self.d , {
								obj_car_transfer = {
									car_no = target.car_no ,
									pos = enemy_old_pos ,
									end_pos = target.pos ,
								} } , self.father_process_no
							)	

							local old_pos = self.owner.pos
							self.owner.pos = enemy_old_pos 
							self.d.running_data_statis_lib.add_game_data( self.d , {
								obj_car_transfer = {
									car_no = self.owner.car_no ,
									pos = old_pos ,
									end_pos = self.owner.pos ,
								} } , self.father_process_no
							)	

							until true
						end
					else
						self:deal_skill_trigger_process_data(skill_target,_arg_table , _work_module.trigger_msg )
						local old_pos = self.owner.pos
						self.owner.pos = self.owner.pos + move_circle + self.attack_radius
						self.d.running_data_statis_lib.add_game_data( self.d , {
							obj_car_transfer = {
								car_no = self.owner.car_no ,
								pos = old_pos ,
								end_pos = self.owner.pos ,
							} } , self.father_process_no
						)					
					end
				end
			end
		end
		return true
	end

	function C:deal_msg ()
		self.msg_deal = {}
		self.msg_deal_func = {}

		if self.config and self.config.work_module then
			--- 这里 用 ipairs 确保顺序
			for key,data in ipairs(self.config.work_module) do

				self:deal_one_work_module(data)

			end
		end

		----- 把消息处理函数列表，连接给消息处理
		self:connect_msg_deal_func()

		self:deal_other_msg()

		PUBLIC.add_msg_listener( self.d , self , self.msg_deal )
	end

	function C:get_other_data()
		local tar_data = {}

		tar_data[#tar_data+1] = { key = "attack_radius", value = self.real_attack_radius }
		return tar_data
	end


	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
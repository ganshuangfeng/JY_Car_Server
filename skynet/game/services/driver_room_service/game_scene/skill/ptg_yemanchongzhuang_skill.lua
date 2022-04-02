----- 平头哥 的野蛮冲撞
--[[
		先确定圈数：原本圈数 + 能量储备的格数，最终是停在 冲撞开始点。
		确定攻击范围： 圈数 + 额外增加格数
		确定伤害：圈数 * 系数 * 攻击力
		确定平头哥最终位置： 没撞到停在最远处；撞到停在被撞车处
		确定被撞车最终位置： 被撞停在 圈数/ 系数处

--]]

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.ptg_yemanchongzhuang_skill_protect = {}
local D = DATA.ptg_yemanchongzhuang_skill_protect

D.extra_attack_radius = "$range"               -- 冲撞范围 额外增加的格数 ，冲撞范围为 旋转圈数 + 这个值
D.attack_coefficient = "$value_bfb"      --伤害系数
D.attack_enemy_extra_pos = "$value"      --攻击敌人使其在我前面move_circle除以这个值的位置

----储能的技能id
D.storage_skill_id = 1017

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
		--- 初始化 ， 当技能创建之后调用
	function C:init()

		self.extra_attack_radius = PUBLIC.convert_chehua_config( self.d , D.extra_attack_radius , self.id , self.owner and self.owner.seat_num )
		self.attack_coefficient = PUBLIC.convert_chehua_config( self.d , D.attack_coefficient , self.id , self.owner and self.owner.seat_num )
		self.attack_enemy_extra_pos = PUBLIC.convert_chehua_config( self.d , D.attack_enemy_extra_pos , self.id , self.owner and self.owner.seat_num )


		self.first_move_step = 0

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


	end

	---- 获取储能技能
	function C:get_storage_skill()
		return self.owner.skill and self.owner.skill[D.storage_skill_id]
	end

	---- 获取 冲撞 距离
	function C:get_chongzhuang_range( _is_spend_storage )

		local storage_skill = self:get_storage_skill()
		local storage_value = 0
		if storage_skill then
			storage_value = storage_skill:get_storage_value( _is_spend_storage )
		end

		local range = math.floor( storage_value + self.extra_attack_radius )

		return range
	end


	function C:deal_work( _work_module , _arg_table)
		
		--print("ptg_deal_work_stat ppppppppppppppppppppppppppppppppppppppppppppppppppppp")
		if not self:deal_work_condition(_work_module.work_condition)  then
			return false
		end

		local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

		if skill_target then

			----处理 消息
			self:deal_skill_trigger_process_data(skill_target , _arg_table , _work_module.trigger_msg )

			--[[self.move_step= self:get_can_move_step_num( true )
					
			self.first_move_step = self.move_step	
			print("qwe,")
			self.d.game_run_system:create_add_event_data(
				----- 平头哥的大油门移动不触发停留消息
				PUBLIC.create_obj( self.d , { obj_enum = "youmen_obj" , type = "ptg_big_youmen" , owner = self.owner , move_step = self.move_step , not_msg_act = { "stay_road" } , father_process_no = self.last_process_no }  )
			 ,1 , "next")--]]

			self.d.game_run_system:create_delay_func_obj(function() 
				self:real_attack(skill_target ,  _arg_table)
			end)

		end

		return true
	end


	function C:real_attack(skill_target)
		
		local can_trigger_target = {}

		--- 冲撞范围
		local real_attack_radius = self:get_chongzhuang_range( true )

		local car_at = DATA.car_prop_lib.get_car_prop( self.owner , "at" )
		local real_attack_damage = car_at * real_attack_radius * self.attack_coefficient / 100

		local ptg_attack_move_step = 0

		print("99999999999999999999999999999999999999999999999999999999999,", real_attack_radius,real_attack_damage,move_dir)
		for key, target in pairs(skill_target) do

			if PUBLIC.check_pos_range(self.d,self.owner.pos, PUBLIC.get_tag( self.owner , "move_reverse") , target.pos , 2 , real_attack_radius) then
				can_trigger_target[#can_trigger_target + 1] = target
			end

		end

		------------- 先撞
		local _ , target = next( can_trigger_target )
		if target then
			local my_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos)  
			local enemy_old_road_id = PUBLIC.get_grid_id_quick( self.d , target.pos )  
			---- 获得 敌人的road_id 在我的 road_id 前方多少格 ，考虑了是否逆向
			ptg_attack_move_step = PUBLIC.get_road_id_dir_dis( self.d , my_road_id , enemy_old_road_id , PUBLIC.get_tag( self.owner , "move_reverse") )
		else
			ptg_attack_move_step = real_attack_radius
		end

		-------- 在计算伤害
		if next(can_trigger_target) then
			print("1111111111111111111111111111")
			--self:deal_skill_trigger_process_data(skill_target,_arg_table)

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
					--can_deal_act = { "lj_act" , "extra_lj_act" } ,	  --- 能连击

					can_deal_act = { "bj_act" , "lj_act" , "extra_lj_act" } ,	  --- 能暴击 ，能连击
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
				target.pos = target.pos + (real_attack_radius // self.attack_enemy_extra_pos)	

				self.d.running_data_statis_lib.add_game_data( self.d , {
					obj_car_transfer = {
						car_no = target.car_no ,
						pos = enemy_old_pos ,
						end_pos = target.pos ,
					} } , self.last_process_no
				)

				------ 发出一个消息，被追尾车 冲撞，停下
				PUBLIC.trriger_msg( self.d , "be_ptg_chongzhuang_move" , { trigger = target , new_pos = target.pos , old_pos = enemy_old_pos } )
				
				until true
			end

		end

		

		self.d.game_run_system:create_add_event_data(
					PUBLIC.create_obj( self.d , { obj_enum = "youmen_obj" , type = "ptg_attack" , owner = self.owner , move_step = ptg_attack_move_step , father_process_no = self.last_process_no }  ) 
				, 1 , "now")
		

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

		local chongzhuang_range = self:get_chongzhuang_range()

		tar_data[#tar_data+1] = { key = "attack_radius", value = chongzhuang_range }
		return tar_data
	end


	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D






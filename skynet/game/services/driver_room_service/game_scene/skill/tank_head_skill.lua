------ 坦克车头技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.tank_head_skill_protect = {}
local D = DATA.tank_head_skill_protect

---- 攻击范围
D.attack_circle_radius = "$range"

D.fix_damage = "$fix_at_value"

D.damage_time = "$at_factor"

--- 基础攻击次数 ， 暂时没用
D.base_hit_num = "$min_value"

D.max_extra_bullet_num = "$max_value"

---- 经过起点 加的子弹数量
D.start_point_add = "$value_bfb"

---- 自己回合开始，加的子弹数量
D.round_start_add = "$value"

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	
	function C:deal_other_msg()
		self.msg_deal["position_moveIn_start_point"] = function(_self , _arg )
			print("xxxx----------------tank_head_skill___position_moveIn_start_point 1")
			if _self.owner == _arg.trigger then
				print("xxxx----------------tank_head_skill___position_moveIn_start_point 2")
				self:add_extra_bullet_num( self.start_point_add )
			end
		end
		---- 自己 的轮次开始 ，子弹加一
		self.msg_deal["round_start"] = function(_self , _arg )
			if _self.owner.seat_num == _arg.seat_num then
				self:add_extra_bullet_num( self.round_start_add  )
			end
		end
		---- 资源补充卡
		self.msg_deal["zybc_tank_bullet_max"] = function(_self , _arg )
			if self.owner == _arg.skill_owner then
				self:zybc_add_extra_bullet( _arg )
			end
		end


	end



	---- 资源补充卡
	function C:zybc_add_extra_bullet(_arg)
		local real_max_extra_bullet_num = DATA.car_prop_lib.get_skill_buff_value( self , "bullet_max" , self.max_extra_bullet_num ) 
		self.extra_bullet_num = real_max_extra_bullet_num
		self:on_skill_change()
	end
	---- 增加自动数量
	function C:add_extra_bullet_num(_add )
		local old_value = self.extra_bullet_num

		self.extra_bullet_num = self.extra_bullet_num + _add

		----- 计算最大子弹数
		local real_max_extra_bullet_num = DATA.car_prop_lib.get_skill_buff_value( self , "bullet_max" , self.max_extra_bullet_num ) 

		if self.extra_bullet_num > real_max_extra_bullet_num then
			self.extra_bullet_num = real_max_extra_bullet_num
		elseif self.extra_bullet_num < 0 then
			self.extra_bullet_num = 0
		end

		----- 当技能改变
		self:on_skill_change()
	end

	----- 获得最大的子弹数量
	function C:get_max_bullet_num()
		return DATA.car_prop_lib.get_skill_buff_value( self , "bullet_max" , self.max_extra_bullet_num ) 
	end

	function C:get_attack_range()
		return DATA.car_prop_lib.get_skill_buff_value( self , "attack_radius" , self.attack_circle_radius ) 
	end


	--- 初始化 ， 当技能创建之后调用
	function C:init( _father_process_no )

		------- 额外的子弹数量 ( 每次经过起点，+1 ) ， 就是真正的 攻击 子弹 个数 
		self.extra_bullet_num = 0

		self.attack_circle_radius = PUBLIC.convert_chehua_config( self.d , D.attack_circle_radius , self.id , self.owner and self.owner.seat_num )
		self.fix_damage = PUBLIC.convert_chehua_config( self.d , D.fix_damage , self.id , self.owner and self.owner.seat_num )
		self.damage_time = PUBLIC.convert_chehua_config( self.d , D.damage_time , self.id , self.owner and self.owner.seat_num )
		self.base_hit_num = PUBLIC.convert_chehua_config( self.d , D.base_hit_num , self.id , self.owner and self.owner.seat_num ) 
		self.max_extra_bullet_num = PUBLIC.convert_chehua_config( self.d , D.max_extra_bullet_num , self.id , self.owner and self.owner.seat_num )

		self.start_point_add = PUBLIC.convert_chehua_config( self.d , D.start_point_add , self.id , self.owner and self.owner.seat_num ) 
		self.round_start_add = PUBLIC.convert_chehua_config( self.d , D.round_start_add , self.id , self.owner and self.owner.seat_num ) 
		
		print("xx----------------tank_head_skill:" , self.max_extra_bullet_num , self.attack_circle_radius , self.fix_damage , self.damage_time , self.start_point_add , self.round_start_add )

		----- 额外的 buff 修改字段
		self.buff_prop = self.buff_prop or {}
		self.buff_prop.attack_radius = 0

		self.buff_prop.bullet_max = 0

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

	--- 处理 消息监听
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

	--- 处理操作
	function C:deal_work( _work_module , _arg_table)
		---- 处理 前置条件检查
		if not self:deal_work_condition(_work_module.work_condition)  then
			return false
		end

		local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

		if skill_target then

			----------------------------------- 记录过程数据
			--local trigger_data = _arg_table.trigger and { PUBLIC.get_game_owner_data( _arg_table.trigger ) } or {}
			-----
			---- 记录一下
			self.skill_target = skill_target

			--local receive_data = {}
			--for key,data in pairs(skill_target) do
			--	receive_data[#receive_data+1] = PUBLIC.get_game_owner_data( data )
			--end

			----------------------------- 先找出 可以 触发的 对象
			local can_trigger_target = {}

			local skill_owner_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos) 

			----- 计算半径 
			local real_attack_circle_radius = DATA.car_prop_lib.get_skill_buff_value( self , "attack_radius" , self.attack_circle_radius ) 
			

			for key, target in pairs(skill_target) do
				------
				repeat
				------ 被打目标 和 技能车辆 在同一位置不能开炮
				local target_road_id = PUBLIC.get_grid_id_quick( self.d , target.pos) 
				if skill_owner_road_id == target_road_id then
					print("xxxx--------------tank_head_skill______ same road_id")
					break
				end

				------- 判断 目标 在 范围内
				if PUBLIC.get_map_road_dis( self.d , skill_owner_road_id , target_road_id) > real_attack_circle_radius then
					print("xxxx--------------tank_head_skill______out dis")
					break
				end

				can_trigger_target[#can_trigger_target + 1] = target

				until true
			end


			----- 收集数据 , 技能触发
			------------- 忽略不必要的 过程数据
			--[[if next(can_trigger_target) and not DATA.process_ignore_skill_key[ self.config.key ] then
				self.last_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
					skill_trigger = {
						owner_data = PUBLIC.get_game_owner_data( self.owner )  ,

						skill_data =  DATA.game_info_center.get_one_skill_data( self ) ,
						
						trigger_data = trigger_data ,
						receive_data = receive_data ,

						skill_name = self.config.name ,
					} } , self.create_skill_process_no
				)
			end--]]

			---- 用新版的 技能触发 数据整理
			if next(can_trigger_target) then
				self:deal_skill_trigger_process_data( skill_target , _arg_table , _work_module.trigger_msg )
			end
			------------------------------------------- 执行操作
			--local skill_owner_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos) 
			local hit_num = self.extra_bullet_num    -- + self.base_hit_num

			for i = 1 , hit_num do
				for key, target in pairs(can_trigger_target) do
					------
					repeat
					
					------ 真正的攻击
					--local real_damage_value = self.fix_damage + at_value * self.damage_time
					local data = { owner = target , skill = self , skill_owner = self.owner , father_process_no = self.last_process_no ,
						level = 1 , 
						obj_enum = "car_attack_obj",
						base_at_time = self.damage_time ,
						fix_at_value = self.fix_damage ,
						not_deal_act = {  } ,     --- 不能连击
						can_deal_act = { "bj_act" , "lj_act" , "extra_lj_act" } ,	  --- 能暴击
						modify_tag = { "act_can_damage_rebound"  } ,  --- 能反伤
					}

					local run_obj = PUBLIC.create_obj( self.d , data )
					if run_obj then
						---- 加入 运行系统
						self.d.game_run_system:create_add_event_data(
							run_obj , 1 , "next"
						) 
					end

					until true
				end
			end

			if next(can_trigger_target) then
				self:add_extra_bullet_num( -self.extra_bullet_num ) 
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

	function C:get_other_data()
		local tar_data = {}

		---- 攻击范围
		tar_data[#tar_data+1] = { key = "attack_circle_radius", 
									value = DATA.car_prop_lib.get_skill_buff_value( self , "attack_radius" , self.attack_circle_radius )  }
		
		---- 这个就是真正的攻击 的子弹个数
		tar_data[#tar_data+1] = { key = "extra_bullet_num", value = self.extra_bullet_num }
		---- 最大的额外子弹数
		tar_data[#tar_data+1] = { key = "max_extra_bullet_num", 
									value =  DATA.car_prop_lib.get_skill_buff_value( self , "bullet_max" , self.max_extra_bullet_num )  }

		return tar_data
	end



	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
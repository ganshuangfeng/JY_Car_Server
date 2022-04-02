------ 重写 技能 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.dileiche_nor_attack_skill_protect = {}
local D = DATA.dileiche_nor_attack_skill_protect

---- 加 地雷的 技能的id
D.mine_num_skill_id = 1018

D.dilei_map_barrier_id_list = {
	[1] = 8,
	[2] = 9,
	[3] = 10,
}

D.dilei_map_barrier_id_map = {
	[ D.dilei_map_barrier_id_list[1] ] = 1,
	[ D.dilei_map_barrier_id_list[2] ] = 2,
	[ D.dilei_map_barrier_id_list[3] ] = 3,
}

----- 地雷的伤害系数
D.dilei_attack_factor = {
	[1] = "$value",
	[2] = "$value_bfb",
	[3] = "$gailv_bfb",
}



function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
		--- 初始化 ， 当技能创建之后调用
	function C:init()
		---- 默认是 2 级的地雷的数量
		self.up_mine_num = 0

		PUBLIC.convert_chehua_config( self.d , D.dilei_attack_factor , self.id , self.owner and self.owner.seat_num )

		---- 加入obj的技能列表
		self.create_skill_process_no = PUBLIC.add_skill( self )

		print("xx-------------------------------create dileiche_nor_attack_skill")

		--- 处理 消息监听
		self:deal_msg()

		--self:deal_on_create_msg()
		---- 处理消息
		self:common_deal_on_msg( "on_create" )

		---- 处理消息
		self:common_deal_on_msg( "on_create_after" )
		
	end

	---- 获得 地雷 安装移动的移动距离
	function C:get_anzhuang_move_step()
		local max_step = self.d.map_length
		local now_move = 0

		local mine_num = 0
		local mine_num_skill = PUBLIC.get_skill_by_id( self.owner , D.mine_num_skill_id )
		if mine_num_skill then
			mine_num = mine_num_skill:get_mine_num()
		end
		print("xxx---------------total__mine_num:" , mine_num)
		--max_step = math.min( mine_num , max_step )

		---- 至少移动一格，但是没有移动步数，不能移动
		--now_move = math.min( now_move , max_step )

		local now_road_id = PUBLIC.get_grid_id_quick( self.d , self.owner.pos)
		local is_move_reverse = PUBLIC.get_tag( self.owner , "move_reverse")

		for i = 1 , max_step do
			if mine_num <= 0 then
				break
			end

			local tar_road_id = now_road_id + (is_move_reverse and -1 or 1) * (i - 1)
			--- 再转一次
			tar_road_id = PUBLIC.get_grid_id_quick( self.d , tar_road_id )
			local map_barriers = self.d.map_barrier[tar_road_id]
			local map_barrier_no = nil
			local map_barrier = nil

			if map_barriers then
				map_barrier_no , map_barrier = next( map_barriers )
			end

			

			--- 如果这个位置没有路面障碍 ， 或者有我自己的 （非地雷） 障碍
			--if not map_barriers or not next(map_barriers) or (map_barriers[1] and map_barriers[1].group == self.owner.group and not D.dilei_map_barrier_id_map[ map_barriers[1].id ] ) then
			--	now_move = now_move + 1
			--end

			---- 找到要消耗 地雷数的情况
			--- 如果没有，或者有我的一二级地雷， （或者有敌人的障碍） 得减地雷数
			if not map_barrier or 
				(map_barrier and map_barrier.group == self.owner.group and ( D.dilei_map_barrier_id_map[ map_barrier.id ] == 1 or D.dilei_map_barrier_id_map[ map_barrier.id ] == 2 ) )
			 or (map_barrier and map_barrier.group ~= self.owner.group) then

				mine_num = mine_num - 1

				print("xxx---------------total 11 __mine_num:" , mine_num , now_move)
			end

			---- 移动直接加
			now_move = now_move + 1

			print("xxx---------------total 22 __mine_num:" , mine_num , now_move)
		end

		return now_move
	end

	function C:deal_other_msg()
		---- 监听油门情况
		self.msg_deal["position_relation_moveIn"] = function(_self , _arg )
			if _arg.trigger == self.owner then
				if _arg.move_type == "dlc_anzhuang_move" then
					print("5555555555555552222222")
					self:set_dilei(_arg , "position_relation_moveIn" )
				end
			end
		end


		--self.msg_deal["position_relation_stay_road"] = function(_self , _arg )

		self.msg_deal["position_relation_stay_road_before_-1"] = function(_self , _arg )
			if _arg.trigger == self.owner then
				if (_arg.move_type == "big_youmen" or _arg.move_type == "small_youmen" or _arg.move_type == "sprint") and PUBLIC.get_map_road_award_type( _d , _arg.road_id ) ~= "big" then
					self:set_dilei(_arg , "position_relation_stay_road_before_-1" )
				end
			end
		end

		---- 如果是 使用了 地雷车 安装技能 ， 开始移动
		self.msg_deal["player_nor_op_over"] = function(_self , _arg )
			if _arg.trigger == self.owner and _arg.op_type == DATA.player_op_type.dlc_anzhuang then
				local move_step = self:get_anzhuang_move_step()

				----- 移动 22 格 ，如果没有了地雷就会停下来
				self.d.game_run_system:create_add_event_data(
					----- 平头哥的大油门移动不触发停留消息
					PUBLIC.create_obj( self.d , { obj_enum = "youmen_obj" , type = "dlc_anzhuang_move" , owner = self.owner , move_step = move_step , father_process_no = self.last_process_no }  )
				 ,1 , "next")
			end
		end

		----- 接下来N 颗提升一级
		self.msg_deal["dlc_up_mine_msg"] = function(_self , _arg )
			if self.owner == _arg.skill_owner then
				self.up_mine_num = self.up_mine_num + _arg.up_mine_num
			end
		end
	
		self.msg_deal["dileiche_big_skill_up_base_dilei"] = function(_self , _arg )
			if self.owner == _arg.trigger then

				for road_id,data in pairs( self.d.map_barrier) do        --遍历地图障碍 如果是1,2级地雷 就升级
					--local barriers_owner = PUBLIC.get_barriers_owner( self.d.map_barrier[road_id])            --key 就是 road_id  
					--local barriers_id = PUBLIC.get_barriers_id( self.d.map_barrier[road_id]) 

					local _,one_map_barrier = next( data )

					if one_map_barrier and one_map_barrier.owner == self.owner then
						if D.dilei_map_barrier_id_map[ one_map_barrier.id ] == 1 or D.dilei_map_barrier_id_map[ one_map_barrier.id ] == 2 then
							local tar_barrier_id = one_map_barrier.id + 1
							local dilei_barrier = PUBLIC.create_map_barrier( self.d , tar_barrier_id , road_id , self.last_process_no , self.owner , true ,true)

							if dilei_barrier then
								local at = DATA.car_prop_lib.get_car_prop( self.owner , "at" )
								dilei_barrier.dilei_fix_damage = at * D.dilei_attack_factor[ D.dilei_map_barrier_id_map[ tar_barrier_id ]  ]
							end
						end
					end

					

				end

			end
		end

	end

	

	----  地雷的普通安装
 	function C:set_dilei(_arg , _trigger_msg )
 		print("666666666666666666666666set_dilei")
 		--if self.owner == _arg.trigger then
 			---- 移动之前的那个位置，
			local road_id = PUBLIC.get_grid_id_quick( self.d , _arg.old_pos ) --PUBLIC.get_grid_id_quick( _d , self.owner.pos ) 

			---- 获取地雷数量
			local mine_num = 0
			local mine_num_skill = PUBLIC.get_skill_by_id( self.owner , D.mine_num_skill_id )
			if mine_num_skill then
				print("xxxxx---------------get_mine_num 22",self.mine_num)
				mine_num = mine_num_skill:get_mine_num()
			end

			---- 目标地雷id ，一级地雷
			local tar_barrier_id = D.dilei_map_barrier_id_list[1]
			if self.up_mine_num > 0 then
				tar_barrier_id = D.dilei_map_barrier_id_list[2]
			end

			if self.d.map_barrier[road_id] and next(self.d.map_barrier[road_id]) then    --有障碍
				---- 拿到第一个障碍
				local _,one_map_barrier = next(self.d.map_barrier[road_id])

				if one_map_barrier.owner == self.owner then    --是我的障碍
					if D.dilei_map_barrier_id_map[ one_map_barrier.id ] == 1 or D.dilei_map_barrier_id_map[ one_map_barrier.id ] == 2 then    --升级地雷
						tar_barrier_id = one_map_barrier.id + ( (self.up_mine_num > 0) and 2 or 1 )
						--- 最多不能升级超过 3 级
						if tar_barrier_id > D.dilei_map_barrier_id_list[3] then
							tar_barrier_id = D.dilei_map_barrier_id_list[3]
						end
					else
						---- 不是 地雷车地雷的，则不创建
						tar_barrier_id = nil
					end
					-- 现在路面是 三级地雷 不管
					--if one_map_barrier.id == D.dilei_map_barrier_id_list[3] then   
					--	tar_barrier_id = 100
					--end
				end
			end

			---- 如果要创建，直接是替换自己，替换他人的障碍
			if mine_num > 0 then
				if tar_barrier_id and tar_barrier_id <= D.dilei_map_barrier_id_list[3] and D.dilei_map_barrier_id_map[ tar_barrier_id ] then
					self:deal_skill_trigger_process_data( { self.owner } , _arg , _trigger_msg )
					local dilei_barrier = PUBLIC.create_map_barrier( self.d , tar_barrier_id , road_id , self.last_process_no , _arg.trigger , true ,true)
					
					if dilei_barrier then
						local at = DATA.car_prop_lib.get_car_prop( self.owner , "at" )
						dilei_barrier.dilei_fix_damage = at * D.dilei_attack_factor[ D.dilei_map_barrier_id_map[ tar_barrier_id ]  ]
					end
					mine_num_skill:add_extra_mine_num( -1 )

					mine_num = mine_num - 1
					if self.up_mine_num > 0 then
						self.up_mine_num = self.up_mine_num - 1
					end
				end
			end

		----- 如果是 安装移动 ， 移动到没雷了，就
		--if _arg.move_type == "dlc_anzhuang_move" then
		--	if mine_num <= 0 then
		--		PUBLIC.trriger_msg( self.d , "force_stop_car" , { stay_road = true } )
		--	end
		--end

		--end
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

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
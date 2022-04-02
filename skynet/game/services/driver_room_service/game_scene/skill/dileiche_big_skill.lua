------ 重写 技能 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.dileiche_big_skill_protect = {}
local D = DATA.dileiche_big_skill_protect

----
D.mine_num_skill_id = 1018

D.dilei_attack_factor = "$value_bfb"
D.add_num = "$value"

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------

	--- 初始化 ， 当技能创建之后调用
	function C:init( _father_process_no )
		---- 伤害系数
		self.dilei_attack_factor = PUBLIC.convert_chehua_config( self.d , D.dilei_attack_factor , self.id , self.owner and self.owner.seat_num )
		self.add_num = PUBLIC.convert_chehua_config( self.d , D.add_num , self.id , self.owner and self.owner.seat_num )
		
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
		
		--[[local dilei_barrier = PUBLIC.create_map_barrier(_d , 11 , PUBLIC.get_grid_id_quick(_d ,self.owner.pos) , self.last_process_no , self.owner , true ,true)  --原地创建大地雷
		if dilei_barrier then
			local at = DATA.car_prop_lib.get_car_prop( self.owner , "at" )
			dilei_barrier.dilei_fix_damage = at * self.dilei_attack_factor
		end--]]

		local for_select_vec = self.d.single_obj["driver_map_manager"]:get_map_road_vec( "empty_not_carpos" )

		---- 如果个数不够，从 有地方障碍的位置补充


		for i = 1 , self.add_num do
			if not next(for_select_vec) then
				break
			end
			local random_index = math.random( #for_select_vec ) 
			local tar_road_id = for_select_vec[random_index]
			table.remove( for_select_vec , random_index )

			local dilei_barrier = PUBLIC.create_map_barrier(_d , 11 , tar_road_id , self.last_process_no , self.owner , true ,true)  --原地创建大地雷
			if dilei_barrier then
				local at = DATA.car_prop_lib.get_car_prop( self.owner , "at" )
				dilei_barrier.dilei_fix_damage = at * self.dilei_attack_factor
			end

		end


		--[[for key,data in pairs(_d.map_barrier) do        --遍历地图障碍 如果是1,2级地雷 就升级
			local barriers_owner = PUBLIC.get_barriers_owner( _d.map_barrier[key])            --key 就是 road_id  
			local barriers_id = PUBLIC.get_barriers_id( _d.map_barrier[key]) 

			if barriers_owner[1] == self.owner then
				if barriers_id[1] == 9 then
					PUBLIC.create_map_barrier(_d , 10 , key , self.last_process_no , self.owner , true ,true)
				end
				if barriers_id[1] == 8 then
					PUBLIC.create_map_barrier(_d , 9 , key , self.last_process_no , self.owner , true ,true)
				end
			end
		end--]]

		----- 发出一个 地雷升级消息
		PUBLIC.trriger_msg( self.d , "dileiche_big_skill_up_base_dilei" , { trigger = self.owner } )

		----- 清地雷数量
		--local mine_num_skill = PUBLIC.get_skill_by_id( self.owner , D.mine_num_skill_id )
		--if mine_num_skill then
		--	mine_num_skill:add_extra_mine_num( -9999 )
		--end
	
	end


	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
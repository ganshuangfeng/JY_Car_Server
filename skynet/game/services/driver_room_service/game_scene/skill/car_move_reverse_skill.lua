------  设置 车辆 倒着移动的技能 ( 暂时不用了， )

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.car_move_reverse_skill_protect = {}
local D = DATA.car_move_reverse_skill_protect


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	
	--- 处理操作
	function C:deal_work( _work_module , _arg_table)
		---- 处理 前置条件检查
		if not self:deal_work_condition(_work_module.work_condition)  then
			return false
		end

		local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

		if skill_target then

			local trigger_data = _arg_table.trigger and { PUBLIC.get_game_owner_data( _arg_table.trigger ) } or {}
			-----
			---- 记录一下
			self.skill_target = skill_target

			local receive_data = {}
			for key,data in pairs(skill_target) do
				receive_data[#receive_data+1] = PUBLIC.get_game_owner_data( data )
			end

			----- 收集数据 , 技能触发
			--local owner_type , owner_id = PUBLIC.get_game_obj_type_id( self.owner )

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


			----- 要做的 obj 列表
			------------ 对所有对象 设置 倒车标志
			print("xxx--------------------add_tag__move_reverse:" )
			for key, target in pairs(skill_target) do
				PUBLIC.add_tag( target , "move_reverse" )
			end
			
			----- 
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


	--- 销毁时 调用
	function C:destroy(_father_process_no)
		self:remove_msg()

		---- 对已经加了的倒车标志的 移除
		print("xxx--------------------delete_tag__move_reverse:" )
		for key,target in pairs(self.skill_target) do
			PUBLIC.delete_tag( target , "move_reverse" )
		end

	end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
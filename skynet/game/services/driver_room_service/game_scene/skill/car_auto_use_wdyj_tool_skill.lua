------ 车上 自动使用维修道具 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.car_auto_use_wdyj_tool_skill_protect = {}
local D = DATA.car_auto_use_wdyj_tool_skill_protect

---
D.auto_use_precent = 10

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	
	--- 初始化 ， 当技能创建之后调用
	function C:init(_father_process_no)
		--self.auto_use_precent = PUBLIC.convert_chehua_config( self.d , D.auto_use_precent , self.id , self.owner and self.owner.seat_num )

		self.auto_use_precent = D.auto_use_precent

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

	function C:deal_other_msg()
		---- 监听血量变化
		self.msg_deal["car_hp_reduce"] = function(_self , _arg )
			print("xxxxxx-------------------- car_hp_reduce 111")
			if _self.owner == _arg.be_attacker then
				print("xxxxxx-------------------- car_hp_reduce 222：" , _self.owner.hp)
				local hp_max = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" )
				if _self.owner.hp <= 0 then
					---- 自动使用道具
					local seat_num = _self.owner.seat_num
					print("xxxxxx-------------------- car_hp_reduce 333")
					if seat_num and self.d.tools_info[ seat_num ] then
						local tool_id = 12
						print("xxxxxx-------------------- car_hp_reduce 444")
						local wxgj_tool_data = self.d.tools_info[ seat_num ][tool_id]

						if wxgj_tool_data and wxgj_tool_data.num > 0  then
							local process_no = PUBLIC.use_tools( self.d , seat_num , tool_id)
							print("xxxxxx-------------------- car_hp_reduce 555")

							_self.owner.hp = 1

							self.prop_change_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
								obj_car_modify_property = {
									car_no = _self.owner.car_no ,
									modify_key_name = "hp" ,
									modify_type = 1 ,
									modify_value = 1 ,
									end_value = _self.owner.hp  ,

								} } , process_no
							)

						end

					end

				end
			end
		end
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

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
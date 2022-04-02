----- 重置 所有车的 位置

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("reset_all_car_pos" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

function C:init()
	---- 基类处理
	self.super.init(self)
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	self:destroy()

	----- 对所有车的位置 重新调整
	if self.d and self.d.car_info then
		for car_no , car_data in pairs(self.d.car_info) do
			---- 圈数
			local quanshu = math.floor( car_data.pos / self.d.map_length )

			local maby_pos = { quanshu * self.d.map_length , (quanshu+1) * self.d.map_length  }

			local tar_pos = math.random( maby_pos[1] , maby_pos[2] )

			-----设置位置
			--car_data.pos = tar_pos

			local data = { owner = self.owner , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
				level = 1 , 
				obj_enum = "car_modify_property_obj",
				modify_key_name = "pos",
				modify_type = 3,
				modify_value = tar_pos ,
			 }

			local run_obj = PUBLIC.create_obj( self.d , data )
			if run_obj then
				---- 加入 运行系统
				self.d.game_run_system:create_add_event_data(
					run_obj , 1 , "next"
				) 
			end

		end
	end

end

return C


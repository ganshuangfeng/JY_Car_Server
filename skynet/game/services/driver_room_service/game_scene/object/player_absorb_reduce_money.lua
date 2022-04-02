
----- 玩家 吸金减金币  的  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local C = basefunc.create_hot_class("player_absorb_reduce_money" , "object_class_base" )


function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	
	---- 要减少的值
	self.absorb_reduce_value = _config.absorb_reduce_value

	self.absorb_reduce_type = _config.absorb_reduce_type or 1

	self.absorb_reduce_percent_base_type = _config.absorb_reduce_percent_base_type


	------------------------ 组装自己的数据 ↑

end

function C:init()
	---- 基类处理
	self.super.init(self)

	----- 将 车owner  找到玩家 (被减的玩家)
	self.owner_player = PUBLIC.get_player_info_by_data( self.d , self.owner )

	self.skill_owner_player = PUBLIC.get_player_info_by_data( self.d , self.skill_owner )

end

function C:destroy()
	self.is_run_over = true
end

function C:run()

	local real_reduce_value = self.absorb_reduce_value

	--- 百分比来减
	if self.absorb_reduce_type == 2 then
		--- 没有就用 被减者 的来做百分比
		if not self.absorb_reduce_percent_base_type then
			real_reduce_value = math.floor( self.owner_player.money * (self.absorb_reduce_value / 100) )

		else
			if type(self.absorb_reduce_percent_base_type) == "string" then
				if string.find( self.absorb_reduce_percent_base_type , "_d%.(%w+)" ) then
					local _s,_e , _key = string.find( self.absorb_reduce_percent_base_type , "_d%.(%w+)" )

					if _key and self.d[ _key ] then
						real_reduce_value = math.floor( self.d[ _key ] * (self.absorb_reduce_value / 100) )
					end
				end

			end

		end

	end


	if real_reduce_value > self.owner_player.money then
		real_reduce_value = self.owner_player.money
	end

	------- 创建 编辑玩家属性
	local data = { owner = self.owner_player , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
		level = 1 , 
		obj_enum = "player_modify_property_obj",
		modify_key_name = "money",
		modify_type = 1,
		modify_value = -real_reduce_value ,
	 }

	local run_obj = PUBLIC.create_obj( self.d , data )
	if run_obj then
		---- 加入 运行系统
		self.d.game_run_system:create_add_event_data(
			run_obj , 1 , "next"
		) 
	end


	local data2 = { owner = self.skill_owner_player , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
		level = 1 , 
		obj_enum = "player_modify_property_obj",
		modify_key_name = "money",
		modify_type = 1,
		modify_value = real_reduce_value ,
	 }

	local run_obj2 = PUBLIC.create_obj( self.d , data2 )
	if run_obj2 then
		---- 加入 运行系统
		self.d.game_run_system:create_add_event_data(
			run_obj2 , 1 , "next"
		) 
	end


	self:destroy()
end

return C



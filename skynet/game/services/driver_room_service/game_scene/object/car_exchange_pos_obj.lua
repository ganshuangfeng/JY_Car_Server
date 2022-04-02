
----- 车 交换 位置  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_exchange_pos_obj" , "object_class_base")

--[[
	油门种类：
		big_youmen
		small_youmen
--]]
--[[
	_config={
		type
		owner
		car_id
	}
--]]

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	

	

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	
	---- 基类处理
	self.super.init(self)
	
	----- 先获得 地方阵营的 一个 "车"
	local enemy_vec = PUBLIC.get_game_obj_by_type( self.d , self.owner , "enemy" )

	self.tar_enemy = enemy_vec[1]

	self.old_owner_pos = self.owner.pos
	self.old_exchanger_pos = self.tar_enemy and self.tar_enemy.pos

	dump( self.tar_enemy ,  "xxx--------------------------self.tar_enemy:")

end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	print(  "xxx--------------------------car_exchange_pos___111:")
	if self.tar_enemy then
		print(  "xxx--------------------------car_exchange_pos___222:")
		self.owner.pos = self.old_exchanger_pos
		self.tar_enemy.pos = self.old_owner_pos

		--- 统计数据
		self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_exchange_pos = {
				car_no = self.owner.car_no ,
				pos = self.old_owner_pos ,
				end_pos = self.owner.pos ,
				exchange_car_no = self.tar_enemy.car_no ,
				exchange_car_pos = self.old_exchanger_pos ,
				exchange_car_end_pos = self.tar_enemy.pos ,
			} } , self.father_process_no
		)
	end


	self:destroy()
end

return C


----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_exchange_hp" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

---- 当 obj 创建之后调用
function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	---- 基类处理
	self.super.init(self)

end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	----- 先获得 地方阵营的 一个 "车"
	local enemy_vec = PUBLIC.get_game_obj_by_type( self.d , self.owner , "enemy" )

	self.tar_enemy = enemy_vec[1]
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	if self.tar_enemy then
		local old_hp = self.owner.hp
		local old_exchange_hp = self.tar_enemy.hp

		self.owner.hp = old_exchange_hp
		self.tar_enemy.hp = old_hp

		---- 限制最大血量
		local my_hp_max = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" ) 
		if self.owner.hp > my_hp_max then
			self.owner.hp = my_hp_max
		end
		local enemy_hp_max = DATA.car_prop_lib.get_car_prop( self.tar_enemy , "hp_max" ) 
		if self.tar_enemy.hp > enemy_hp_max then
			self.tar_enemy.hp = enemy_hp_max
		end


		self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_modify_property = {
				car_no = self.owner.car_no ,
				modify_key_name = "hp" ,
				modify_type = 1 ,
				modify_value = self.owner.hp - old_hp ,
				end_value = self.owner.hp  ,

			} } , self.father_process_no
		)

		self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_modify_property = {
				car_no = self.tar_enemy.car_no ,
				modify_key_name = "hp" ,
				modify_type = 1 ,
				modify_value = self.tar_enemy.hp - old_exchange_hp ,
				end_value = self.tar_enemy.hp  ,

			} } , self.father_process_no
		)
		
	end

	self:destroy()
end

return C


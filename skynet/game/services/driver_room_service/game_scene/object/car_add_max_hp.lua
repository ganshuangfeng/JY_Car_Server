----- 以buff形式 ，提升 最大血量，并回血

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_add_max_hp" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	---- 修改的类型 ( 增加减少  or  设置 )
	self.modify_type = _config.modify_type   ---  1是 增加or减少 固定值 ; 2是  增加or减少 百分比  ;  3是  设置 固定值
	--- 修改的值
	self.modify_value = math.floor( _config.modify_value )
	---- 百分比修改时，的基础值是什么，默认是要编辑的属性自身
	self.percent_base_type = _config.percent_base_type

	---- 加最大血量的 buff id
	self.buff_id = _config.buff_id

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
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	local old_value = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" )   -- self.owner[ "hp_max" ]
	
	-----
	------ 创建一个修改 最大血量的buff
	local _data =  { owner = self.owner , skill = self.skill ,
		id = self.buff_id ,
		buff_enum = "prop_modifier_buff",
		--overlay_rule = { modify_value = "overlay_bei" } ,
		modify_key_name = "hp_max" , 
		modify_type = self.modify_type ,
		modify_value = { arg_value = self.modify_value , value_type = "nor" , overlay_rule = "overlay_bei" }  ,
		percent_base_value = old_value ,      -- 最大血量就是用自身当前值来算的

		--percent_base_type = self.percent_base_type ,  -- 最大血量就是用自身当前值来算的
	}
	local buff_obj = PUBLIC.buff_obj_create_factory( self.d , self.buff_id , _data)

	if buff_obj then
		self.skill:add_buff_to_skill( buff_obj )

	end

	local now_value = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" )

	----- hp_max 改变值
	local change_value = now_value - old_value
	--- hp 的改变值
	local hp_change_value = 0

	if change_value > 0 then
		hp_change_value = change_value
	elseif change_value < 0 then
		hp_change_value = self.owner[ "hp" ] - math.min( now_value, self.owner[ "hp" ] )
	end

	if hp_change_value ~= 0 then
		self.owner[ "hp" ] = self.owner[ "hp" ] + hp_change_value

		self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_modify_property = {
				car_no = self.owner.car_no ,
				modify_key_name = "hp" ,
				modify_type = self.modify_type ,
				modify_value = hp_change_value ,
				end_value = self.owner[ "hp" ]  ,
			} } , self.father_process_no
		)
	end


	--[[if change_value ~= 0 then
		self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_modify_property = {
				car_no = self.owner.car_no ,
				modify_key_name = "hp_max" ,
				modify_type = self.modify_type ,
				modify_value = change_value ,
				end_value = self.owner[ "hp_max" ]  ,

			} } , self.father_process_no
		)
	end--]]

	self:destroy()
end

return C


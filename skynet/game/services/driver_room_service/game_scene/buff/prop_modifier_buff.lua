----- 修改属性buff

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("prop_modifier_buff")

C.msg_table = {}

function C:ctor(_d , _config )
	print("xxxx-----------------prop_modifier_buff ctor")
	---------------------------- 通用属性 ↓
	self.d = _d


	self.d.buff_create_no = self.d.buff_create_no + 1
	self.no = self.d.buff_create_no

	self.id = _config.id
	--- 拥有者
	self.owner = _config.owner
	---- 创建的技能
	self.skill = _config.skill
	----
	self.config = _config
	---- 能起作用的条件
	self.condition = _config.condition
	---- 叠加规则
	self.overlay_rule = _config.overlay_rule
	---------------------------- 通用属性 ↑

	--------------- 特有属性
	self.modify_key_name = _config.modify_key_name

	self.modify_type = _config.modify_type

	self.modify_value = _config.modify_value

	self.percent_base_type = _config.percent_base_type

	self.percent_base_value = _config.percent_base_value

end

------ 影响的改变值
function C:on_owner_prop_change( old_value , new_value , process_no)
	if old_value and new_value and old_value ~= new_value then
		self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_modify_property = {
				car_no = self.owner.car_no ,
				modify_key_name = self.modify_key_name ,
				modify_type = 1 ,
				modify_value = new_value - old_value ,
				end_value = new_value  ,

			} } , process_no
		)

	end
end

function C:init(_father_process_no)
	print("xxxx-----------------prop_modifier_buff init")
	---- 处理叠加规则
	PUBLIC.deal_run_obj_buff_overlay_rule(self)

	local old_value = DATA.car_prop_lib.get_car_prop( self.owner , self.modify_key_name )

	local process_no = PUBLIC.add_buff( self , _father_process_no )

	local new_value = DATA.car_prop_lib.get_car_prop( self.owner , self.modify_key_name )

	self:on_owner_prop_change( old_value , new_value , process_no )

end

function C:destroy(_father_process_no)
	local old_value = DATA.car_prop_lib.get_car_prop( self.owner , self.modify_key_name )

	--local process_no = PUBLIC.delete_buff( self )

	local new_value = DATA.car_prop_lib.get_car_prop( self.owner , self.modify_key_name )

	self:on_owner_prop_change( old_value , new_value , _father_process_no )
end


---- 刷新（因为buff是一直存在的，这个会在创建buff 或 buff存在时动态 调用 ）
function C:refresh( _father_process_no )
	local old_value = DATA.car_prop_lib.get_car_prop( self.owner , self.modify_key_name )
	----- 处理 叠加逻辑
	PUBLIC.deal_run_obj_buff_overlay_rule(self)
	local new_value = DATA.car_prop_lib.get_car_prop( self.owner , self.modify_key_name )

	local process_no = self:on_buff_change( _father_process_no )

	self:on_owner_prop_change( old_value , new_value , process_no )
end

---- 检查能否起作用
function C:check_condition( _arg_table )
	---- 如果有
	if self.condition and self.condition.func then

		local is_cond = self.condition.func( _arg_table )

		return is_cond
	end

	return true
end

function C:on_buff_change( _father_process_no )
	local process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
		buff_change = {
			owner_data = PUBLIC.get_game_owner_data( self.owner )  ,

			buff_data = DATA.game_info_center.get_one_buff_data( self ) , 
		} } , _father_process_no
	)
	return process_no
end


function C:get_other_data()
	local tar_data = {}

	tar_data[#tar_data+1] = { key = "modify_key_name" , value = self.modify_key_name }
	tar_data[#tar_data+1] = { key = "modify_type" , value = self.modify_type }
	tar_data[#tar_data+1] = { key = "modify_value" , value = self.modify_value }
	tar_data[#tar_data+1] = { key = "percent_base_type" , value = self.percent_base_type }

	return tar_data
end

function C:work( _prop_type , _real_prop_value , _percent_base_value )
	local real_prop_value = _real_prop_value

	---- 值针对 这个属性key的有用
	if self.modify_key_name ~= _prop_type then
		return real_prop_value
	end

	--- 如果条件检查不过，则直接返回
	if not self:check_condition( { owner = self.owner } ) then
		return real_prop_value
	end

	if self.modify_type == 1 then
		---- 固定值
		real_prop_value = _real_prop_value + self.modify_value
	elseif self.modify_type == 2 then
		---- 百分比
		local base_value = real_prop_value
		--- 可以用其他数据作为 基础值 加百分比
		if self.percent_base_value and type(self.percent_base_value) == "number" then
			base_value = self.percent_base_value
		elseif self.percent_base_type and self.owner[self.percent_base_type] and type(self.owner[self.percent_base_type]) == "number" then
			base_value = self.owner[self.percent_base_type]     ----- PS: buff 里面不能再调 用buff 的获取值，可能会死循环
		end

		----- 最终强制 用外面传的值
		if _percent_base_value and type(_percent_base_value) == "number" then
			base_value = _percent_base_value
		end

		real_prop_value = real_prop_value + math.floor( base_value * ( self.modify_value / 100 ) )
	elseif self.modify_type == 3 then
		---- 设置
		real_prop_value = self.modify_value
	end
	
	
	return real_prop_value
end

return C
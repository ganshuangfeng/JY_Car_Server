-----  技能 属性修改 buff

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("skill_modifier_buff")

C.msg_table = {}

function C:ctor(_d , _config )
	---------------------------- 通用属性 ↓
	self.d = _d

	----
	self.d.buff_create_no = self.d.buff_create_no + 1
	self.no = self.d.buff_create_no

	self.id = _config.id
	--- 拥有者 （ buff 的 owner 和 要改的 技能的 owner 一致 ）
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

	--------------- 特有属性 , _config传入的值一定是 初始值
	--- 技能id
	self.skill_id = _config.skill_id
	--- 
	self.modify_key_name = _config.modify_key_name

	self.modify_type = _config.modify_type

	self.modify_value = _config.modify_value

	---- 是否使用 arg 参数百分比值

end

function C:init( _father_process_no )
	---- 处理叠加规则
	PUBLIC.deal_run_obj_buff_overlay_rule(self)
	
	local process_no = PUBLIC.add_buff( self , _father_process_no )

	---- 如果owner 有这个技能  ,, 这里是创建
	if self.skill_id and self.owner.skill[ self.skill_id ] then
		self.owner.skill[ self.skill_id ]:on_skill_change( process_no )
	end

end

function C:destroy( _father_process_no )
	--local process_no = PUBLIC.delete_buff( self )

	---- 如果owner 有这个技能  ,, 这里是创建
	if self.skill_id and self.owner.skill[ self.skill_id ] then
		self.owner.skill[ self.skill_id ]:on_skill_change( _father_process_no )
	end
	
end

---- 刷新
function C:refresh( _father_process_no )
	----- 处理 叠加逻辑
	PUBLIC.deal_run_obj_buff_overlay_rule(self)

	------ 这里是改变
	local process_no = self:on_buff_change( _father_process_no )

	---- buff 改变 导致另一个技能改变
	if self.skill_id and self.owner.skill[ self.skill_id ] then
		self.owner.skill[ self.skill_id ]:on_skill_change( process_no )
	end
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

	tar_data[#tar_data+1] = { key = "skill_id" , value = self.skill_id }
	tar_data[#tar_data+1] = { key = "modify_key_name" , value = self.modify_key_name }
	tar_data[#tar_data+1] = { key = "modify_type" , value = self.modify_type }
	tar_data[#tar_data+1] = { key = "modify_value" , value = self.modify_value }

	return tar_data
end

function C:work( _skill_obj , _prop_type , _real_prop_value , _percent_base_value )
	local real_prop_value = _real_prop_value
	if _skill_obj and _skill_obj.id == self.skill_id then
		if self.modify_key_name == _prop_type then

			--- 如果条件检查不过，则直接返回
			if not self:check_condition( { owner = self.owner } ) then
				return real_prop_value
			end
			

			if self.modify_type == 1 then
				---- 固定值
				real_prop_value = _real_prop_value + self.modify_value
			elseif self.modify_type == 2 then
				local base_value = real_prop_value

				if _percent_base_value and type(_percent_base_value) == "number" then
					base_value = _percent_base_value
				end

				---- 百分比
				real_prop_value = real_prop_value + math.floor( base_value * ( self.modify_value / 100 ) )
			elseif self.modify_type == 3 then
				---- 设置
				real_prop_value = self.modify_value
			end

		end
	end
	return real_prop_value
end

return C
----- 修改 标签 buff

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("tag_modifier_buff")

C.msg_table = {}

function C:ctor(_d , _config )
	---------------------------- 通用属性 ↓
	self.d = _d

	----
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
	---- 标签name
	self.tag_name = _config.tag_name
	print("xxxx---------self.tag_name:" , self.tag_name )

	--- 标签值
	self.tag_value = _config.tag_value

end

function C:init( _father_process_no )
	---- 处理叠加规则
	PUBLIC.deal_run_obj_buff_overlay_rule(self)
	
	PUBLIC.add_buff( self , _father_process_no )

	---- 加标签
	PUBLIC.add_tag( self.owner , self.tag_name , self.tag_value )
end

function C:destroy(_father_process_no)
	--PUBLIC.delete_buff( self )


	---- 删除标签
	PUBLIC.delete_tag( self.owner , self.tag_name )
end

function C:get_other_data()
	local tar_data = {}

	tar_data[#tar_data+1] = self.tag_name and { key = "tag_name" , value = self.tag_name }
	tar_data[#tar_data+1] = self.tag_value and { key = "tag_value" , value = self.tag_value }

	return tar_data
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

function C:work(  )
	
end

return C
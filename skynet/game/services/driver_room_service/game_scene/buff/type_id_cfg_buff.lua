----- 对 策划 的 type_id 为主的配置 进行修改的配置

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("type_id_cfg_buff")

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

	self.is_not_send_client = true
	---------------------------- 通用属性 ↑

	--------------- 特有属性
	--- 要修改的 type_id 对应的配置
	self.type_id = _config.type_id
	--- 要编辑 配置字段
	self.modify_key_name = _config.modify_key_name
	--- 怎么编辑
	self.modify_type = _config.modify_type

	self.modify_value = _config.modify_value

	self.percent_base_type = _config.percent_base_type

	self.percent_base_value = _config.percent_base_value

end

function C:init( _father_process_no )
	---- 处理叠加规则
	PUBLIC.deal_run_obj_buff_overlay_rule(self)

	local process_no = PUBLIC.add_buff( self , _father_process_no )

end

function C:destroy()
	local process_no = PUBLIC.delete_buff( self )

end
---- 刷新
function C:refresh( _father_process_no )
	----- 处理 叠加逻辑
	PUBLIC.deal_run_obj_buff_overlay_rule(self)

	
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

function C:work( _type_id , _key , _real_value , _percent_base_value )
	local real_value = _real_value

	--- 不是相同type_id 直接返回
	if self.type_id ~= _type_id or self.modify_key_name ~= _key then
		return real_value
	end

	--- 如果条件检查不过，则直接返回
	if not self:check_condition( { owner = self.owner } ) then
		return real_prop_value
	end

	local type_id_cfg = DATA.chehua_skill_type_id_config[ _type_id ]

	
	if self.modify_type == 1 then
		---- 固定值
		real_value = _real_value + self.modify_value
	elseif self.modify_type == 2 then
		---- 百分比
		local base_value = real_value
		--- 可以用其他数据作为 基础值 加百分比
		if self.percent_base_value and type(self.percent_base_value) == "number" then
			base_value = self.percent_base_value
		elseif self.percent_base_type and type_id_cfg[ self.percent_base_type ] and type( type_id_cfg[ self.percent_base_type ] ) == "number" then
			
			base_value = type_id_cfg[ self.percent_base_type ]     ----- PS: buff 里面不能再调 用buff 的获取值，可能会死循环
		end

		----- 最终强制 用外面传的值
		if _percent_base_value and type(_percent_base_value) == "number" then
			base_value = _percent_base_value
		end

		real_value = real_value + math.floor( base_value * ( self.modify_value / 100 ) )
	elseif self.modify_type == 3 then
		---- 设置
		real_value = self.modify_value
	end
	
	
	return real_value

end

return C
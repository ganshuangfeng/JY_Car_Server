----- 基类

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("object_class_base")

function C:ctor(_d  , _config)

	------------------------------------------------------- 通用项 ↓
	self.d = _d
	self.config = _config

	---- id 如果是走配置会有id ， 不走配置的为 nil
	self.id = _config.id
	---- 父亲 process_id
	self.father_process_no = _config.father_process_no
	---- owner 是车
	self.owner = _config.owner
	---- 释放这个 obj 的 技能的 所有者
	self.skill_owner = _config.skill_owner
	----
	self.skill = _config.skill

	---- 叠加规则
	self.overlay_rule = _config.overlay_rule
	------------------------------------------------------- 通用项 ↑

end

---- 当 obj 创建之后调用
function C:init()
	---- 处理叠加规则
	PUBLIC.deal_run_obj_buff_overlay_rule(self)
	
end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end

---- 检查 owner 的类型，
function C:check_run_obj_owner_type( _owner_type )
	local is_right = false

	if type(_owner_type) ~= "table" and self.owner.kind_type == _owner_type then
		is_right = true
	elseif type(_owner_type) == "table" then
		for key, _type in pairs(_owner_type) do
			if self.owner.kind_type == _type then
				is_right = true
				break
			end
		end
	end

	---- 正式可以 变成 print ↓      
	if not is_right then
		error( string.format("xxxxx----------- error ------------owner_type is error , obj_class:%s , obj_id:%s , hope:%s , now:%s " 
								, self.class.typeinfo.name , self.id , basefunc.tostring( _owner_type ) , self.owner.kind_type) )
	end


end

function C:run()
	
end

return C


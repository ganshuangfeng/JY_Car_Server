----- 车辆 技能 升级 obj

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_skill_level_up_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	---- 升级的  技能 tag
	self.skill_tag = _config.skill_tag

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	
	---- 基类处理
	self.super.init(self)

end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	
	----- 上一次的数据
	local last_skill_data = self.owner.skill_tag[self.skill_tag]
	---- 上一次的 升级索引 和 技能id
	local last_up_index = last_skill_data and last_skill_data.level_up_index or 0
	local last_skill_id = last_skill_data and last_skill_data.skill_id 

	---- 下一个技能 索引 和 技能id
	local next_index = last_up_index + 1
	local config_data = nil
	if self.owner.config and self.owner.config.skill_data and self.owner.config.skill_data[ self.skill_tag ] and self.owner.config.skill_data[ self.skill_tag ].level_up_data then
		config_data = self.owner.config.skill_data[ self.skill_tag ].level_up_data
	end
	
	if not config_data then
		self:destroy()
		return
	end

	local next_skill_config = config_data[ next_index ]

	---- 有配置说明可以升级
	if next_skill_config then
		local new_skill_id = next_skill_config.skill_id
		--- 统计数据
		local process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_skill_up = {
				car_no = self.owner.car_no ,
				skill_tag = self.skill_tag ,
				old_skill_id = last_skill_id ,
				new_skill_id = new_skill_id ,
			} } , self.father_process_no
		)

		----- 删掉之前的技能
		if self.owner.skill and self.owner.skill[ last_skill_id ] then
			PUBLIC.delete_skill( self.owner.skill[ last_skill_id ] ) 
		end

		----- 创建新技能	
		PUBLIC.skill_create_factory( self.d , new_skill_id , { owner = self.owner , father_process_no = process_no } )
		self.owner.skill_tag[ self.skill_tag ] = { level_up_index = next_index , skill_id = new_skill_id }

	end

	self:destroy()
end

return C


----- 地雷车地雷的伤害 obj , 因为 地雷车的地雷的伤害值 在创建地雷时已经确定了

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("dilei_damage_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

---- 当 obj 创建之后调用
function C:init()
	---- 检查 owner 类型
	--self:check_run_obj_owner_type( DATA.game_kind_type.car )
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
	
	---- 创建伤害
	if self.skill_owner and self.skill_owner.dilei_fix_damage then
		local data = { owner = self.owner , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
			level = 1 , 
			obj_enum = "car_modify_property_obj",
			modify_key_name = "hp",
			modify_type = 1,
			modify_value = self.skill_owner.dilei_fix_damage ,

			modify_tag = basefunc.deepcopy( self.modify_tag ),
		}

		local run_obj = PUBLIC.create_obj( self.d , data )
		if run_obj then
			---- 加入 运行系统
			self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
		end

	end

	self:destroy()
end

return C


----- 路上 加hp ，当有车架改装buff时，多加 5 %

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_road_add_hp_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	---- 加hp的百分比的 值
	self.modify_value = _config.modify_value

	---- 额外加的值
	-- self.extra_value = 5

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
	
	----- 加血量，如果有buff  112
	--local extra_add = DATA.car_prop_lib.get_car_prop( self.owner , "map_award_hp_add" ) 


	--self.modify_value = math.floor( self.modify_value * ( 1 + extra_add / 100 ) )


	--local now_hp_max_value = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" )   --拿到现在的血量最大值
	--------- 创建 加血量
	local data = { owner = self.owner , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
			level = 1 , 
			obj_enum = "car_modify_property_obj",
			modify_key_name = "hp",
			modify_type = 2,
			modify_value = self.modify_value ,
			--percent_base_value = now_hp_max_value ,
			percent_base_type = "hp_max" ,
		}

	local run_obj = PUBLIC.create_obj( self.d , data )
	if run_obj then
		---- 加入 运行系统
		self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
	end

	self:destroy()
end

return C


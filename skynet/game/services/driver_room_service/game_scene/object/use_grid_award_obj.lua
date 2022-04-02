----- 发放路面奖励

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("xxxxxxxxxxxxxxxxxxxx" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	self.type_id = _config.type_id

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
	
	local map_award_data = {
		create_type = "skill" ,
		type_id = self.type_id ,
	}
	self.d.single_obj["driver_map_award_manager"]:create_map_award( map_award_data , self.owner.pos , self.owner )

	self:destroy()
end

return C


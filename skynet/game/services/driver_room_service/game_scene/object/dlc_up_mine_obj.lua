----- 地雷车，接下来N颗地雷，提升地雷一级

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
	self.up_mine_num = _config.up_mine_num
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
	self:destroy()

	---- 发出消息
	PUBLIC.trriger_msg( self.d , "dlc_up_mine_msg" , { skill_owner = self.skill_owner , up_mine_num = self.up_mine_num } )
end

return C


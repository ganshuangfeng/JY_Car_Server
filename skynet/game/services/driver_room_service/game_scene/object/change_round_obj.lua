----- 改变 轮次的 （处理单元）

local base = require "base"
local basefunc = require "basefunc"
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("change_round_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

function C:init()
	---- 基类处理
	self.super.init(self)

	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	-- 发出一个 轮次 结束消息
	PUBLIC.trriger_msg( self.d , "change_game_dis_msg" )
	print("xxx---------------------change_round")
	self:destroy()

end


return C
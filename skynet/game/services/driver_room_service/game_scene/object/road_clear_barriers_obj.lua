----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("road_clear_barriers_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

end

---- 当 obj 创建之后调用
function C:init()
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

	if self.d and self.d.map_barrier then
		for key,data in pairs(self.d.map_barrier) do
			for i,j in pairs (data) do
				PUBLIC.delete_map_barrier(self.d , j , nil , "lei da ji neng" , nil)
			end
		end
	end




	self:destroy()

	
end

return C


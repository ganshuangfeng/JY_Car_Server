----- 清除所有地图障碍 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("clear_map_barrier_obj" , "object_class_base" )
C.msg_deal = {}

function C:ctor(_d  , _config)

	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	--self.barrier_ids = _config.barrier_ids or {}

	self.barrier_id_map = basefunc.list_to_map( _config.barrier_ids )



end

function C:init()
	---- 基类处理
	self.super.init(self)

end

function C:destroy()
	self.is_run_over = true
end

function C:run()
	self:destroy()
	----- 找到所有的障碍，清理掉

	if self.d and self.d.map_barrier then
		for key,vec_data in pairs(self.d.map_barrier) do
			for _no , data in pairs(vec_data) do
				if self.barrier_id_map[ data.id ] then

					PUBLIC.delete_map_barrier( self.d , data )
				end
			end
		end
	end
end

return C


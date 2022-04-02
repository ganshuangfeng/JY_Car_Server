
----- 玩家 修改属性  的  (处理单元) 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local C = basefunc.create_hot_class("player_modify_property_obj" , "object_class_base" )


function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	
	---- 修改的属性字段
	self.modify_key_name = _config.modify_key_name
	---- 修改的类型 ( 增加减少  or  设置 )
	self.modify_type = _config.modify_type   ---  1是 增加or减少 固定值 ; 2是  增加or减少 百分比  ;  3是  设置 固定值
	--- 修改的值
	self.modify_value = _config.modify_value
	---- 百分比修改时，的基础值是什么，默认是要编辑的属性自身
	self.percent_base_type = _config.percent_base_type

	------------------------ 组装自己的数据 ↑

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.player )
	---- 基类处理
	self.super.init(self)
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()

	local old_value = self.owner[ self.modify_key_name ]

	---- 执行修改
	if self.modify_type == 1 then
		self.owner[ self.modify_key_name ] = self.owner[ self.modify_key_name ] + self.modify_value
	elseif self.modify_type == 2 then
		local base_value = self.owner[ self.modify_key_name ]
		---- 可以用其他数据作为 基础值 加百分比
		if self.percent_base_type and self.owner[self.percent_base_type] and type(self.owner[self.percent_base_type]) == "number" then
			base_value = self.owner[self.percent_base_type]
		end
		
		self.owner[ self.modify_key_name ] = self.owner[ self.modify_key_name ] + math.floor( base_value * ( self.modify_value / 100 ) )
	elseif self.modify_type == 3 then
		self.owner[ self.modify_key_name ] = self.modify_value
	end

	--- 赋值限制
	if self.owner[ self.modify_key_name ] < 0 then
		self.owner[ self.modify_key_name ] = 0
	end
	
	-----
	local change_value = self.owner[ self.modify_key_name ] - old_value

	---- 搜集数据
	self.d.running_data_statis_lib.add_game_data( self.d , {
		obj_player_modify_property = {
			seat_num = self.owner.seat_num ,
			modify_key_name = self.modify_key_name ,
			modify_type = self.modify_type ,
			modify_value = change_value ,
			end_value = self.owner[ self.modify_key_name ]  ,
		} } , self.father_process_no
	)

	---- 是否触发消息。。。


	self:destroy()
end

return C



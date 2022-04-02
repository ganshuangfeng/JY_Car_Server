
----- 车 修改属性  的  (处理单元) ( 单纯的编辑属性，不会有附加处理 )

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local C = basefunc.create_hot_class("car_modify_property_obj" , "object_class_base")


function C:ctor(_d  , _config)

	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓
	
	---- 修改的属性字段
	self.modify_key_name = _config.modify_key_name
	---- 修改的类型 ( 增加减少  or  设置 )
	self.modify_type = _config.modify_type   ---  1是 增加or减少 固定值 ; 2是  增加or减少 百分比  ;  3是  设置 固定值
	--- 修改的值
	self.modify_value = math.floor( _config.modify_value )

	---- 百分比修改时，的基础值是什么，默认是要编辑的属性自身
	self.percent_base_type = _config.percent_base_type
	---- 修改百分比基础值,是一个数字
	self.percent_base_value = _config.percent_base_value

	---- 传入 list  , key = index , value = tag
	self.modify_tag = _config.modify_tag or {}

	----- 编辑标签 , key = tag , value = bool
	self.modify_tag_map = basefunc.list_to_map( self.modify_tag  )


	----

	---- 给技能拥有者，反伤具体值
	self.rebound_value = nil

	self.prop_change_process_no = nil

	------------------------ 组装自己的数据 ↑

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

----- 车辆无敌的处理
function C:deal_car_invincible( _change_value )
	local change_value = _change_value
	----- 克隆天使，不能被无敌作用
	if self.modify_tag_map["kelongtianshi"] then
		return change_value
	end
	if self.modify_key_name == "hp" and change_value < 0 then
		if PUBLIC.get_tag( self.owner , "invincible") then
			---- 先加回来
			self.owner[ "hp" ] = self.owner[ "hp" ] - change_value
			
			change_value = 0

			self.modify_tag_map["invincible"] = true

			self.modify_tag[#self.modify_tag + 1] = "invincible"
		end
	end

	return change_value
end

---- 车辆护盾的处理
function C:deal_car_hd( _change_value )
	print("",self.rebound_value)
	local change_value = _change_value
	if self.modify_key_name == "hp" and change_value < 0 then
		if self.owner["hd"] and self.owner["hd"] > 0 then
			local hd_dikou = math.floor( math.min( self.owner["hd"] , math.abs(change_value) ) )

			---- 先减掉护盾的抵扣值
			self.owner["hd"] = self.owner["hd"] - hd_dikou
			---- 搜集数据

			self.prop_change_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
				obj_car_modify_property = {
					car_no = self.owner.car_no ,
					modify_key_name = "hd" ,
					modify_type = 1 ,
					modify_value = -hd_dikou ,
					end_value = self.owner["hd"]  ,
					modify_tag = self.modify_tag_map["damage_rebound"] and { "damage_rebound" } or nil ,
				} } , self.father_process_no
			)
			----
			change_value = change_value + hd_dikou

			---- 再加回来
			self.owner[ self.modify_key_name ] = self.owner[ self.modify_key_name ] + hd_dikou
		end
	end

	return change_value
end

---- 处理反伤
function C:deal_car_fan_shang(_change_value)
	local change_value = _change_value
	if self.modify_key_name == "hp" and change_value < 0 then
		---- 如果技能释放者是车，并且和 受伤车不一样，则反伤
		if self.skill_owner and self.skill_owner.kind_type == DATA.game_kind_type.car 
			and self.owner and self.owner.kind_type == DATA.game_kind_type.car and self.owner.car_no ~= self.skill_owner.car_no then

			

			local fanshang = DATA.car_prop_lib.get_car_prop( self.owner , "fanshang" ) 
			---- 如果被打者有反伤
			if fanshang ~= 0 then
				print("7777777777777777777777777777777777777,",fanshang)
				self.rebound_value = math.floor( math.abs( change_value ) * fanshang / 100 )
				print("",self.rebound_value)
			end


			--[[if PUBLIC.get_tag( self.owner , "damage_rebound") then
				local damage_rebound = PUBLIC.get_tag( self.owner , "damage_rebound")

				self.rebound_value = math.floor( math.abs( change_value ) * (damage_rebound / 100) )

			end --]]
		end
	end

	return change_value
end

function C:run()
	
	local old_value = self.owner[ self.modify_key_name ]

	---- 执行修改
	if self.modify_type == 1 then
		self.owner[ self.modify_key_name ] = self.owner[ self.modify_key_name ] + self.modify_value
	elseif self.modify_type == 2 then
		local base_value = self.owner[ self.modify_key_name ]
		---- 可以用其他数据作为 基础值 加百分比
		if self.percent_base_value and type(self.percent_base_value) == "number" then
			base_value = self.percent_base_value
		elseif self.percent_base_type and self.owner[self.percent_base_type] and type(self.owner[self.percent_base_type]) == "number" then
			---- 拿属性的话，都经过一下 buff
			base_value =  DATA.car_prop_lib.get_car_prop( self.owner , self.percent_base_type )  -- self.owner[self.percent_base_type]
		end

		self.owner[ self.modify_key_name ] = self.owner[ self.modify_key_name ] + math.floor( base_value * ( self.modify_value / 100 ) )
	elseif self.modify_type == 3 then
		self.owner[ self.modify_key_name ] = self.modify_value
	end

	

	----- 改变值
	local change_value = self.owner[ self.modify_key_name ] - old_value

	------ 无敌处理
	change_value = self:deal_car_invincible( change_value )

	----- 处理反伤 默认不反 ( 不是反伤过来的才能算反伤 , 并且可以反伤， ) (不是反伤的才能处理反伤，默认只能反一次)
	if not self.modify_tag_map["damage_rebound"] and self.modify_tag_map["act_can_damage_rebound"] then
		change_value = self:deal_car_fan_shang(change_value)
	end

	print("",self.rebound_value)
	----- 如果是 -hp 并且 有护盾
	change_value = self:deal_car_hd( change_value )

	--- 赋值限制 , 
	if self.owner[ self.modify_key_name ] < 0 then
		self.owner[ self.modify_key_name ] = 0
	end
	if self.modify_key_name == "hp" then
		local now_hp_max = DATA.car_prop_lib.get_car_prop( self.owner , "hp_max" ) 

		if self.owner[ self.modify_key_name ] > now_hp_max then
			self.owner[ self.modify_key_name ] = now_hp_max
		end
	end

	---- 搜集数据
	if change_value ~= 0 or ( self.modify_tag_map and (self.modify_tag_map["miss"] or self.modify_tag_map["invincible"] ) ) then
		self.prop_change_process_no = self.d.running_data_statis_lib.add_game_data( self.d , {
			obj_car_modify_property = {
				car_no = self.owner.car_no ,
				modify_key_name = self.modify_key_name ,
				modify_type = self.modify_type ,
				modify_value = change_value ,
				end_value = self.owner[ self.modify_key_name ]  ,

				modify_tag = self.modify_tag ,
			} } , self.father_process_no
		)
	end
	-------  反伤的
	if self.rebound_value then

		local data = { owner = self.skill_owner , skill = self.skill , skill_owner = self.owner , father_process_no = self.prop_change_process_no ,
				level = 1 , 
				obj_enum = "car_modify_property_obj",
				modify_key_name = "hp",
				modify_type = 1,
				modify_value = -self.rebound_value ,

				modify_tag = { "damage_rebound" } ,
			}

		local run_obj = PUBLIC.create_obj( self.d , data )
		if run_obj then
			---- 加入 运行系统
			self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
		end

	end


	---- 是否触发消息。。。
	if self.modify_key_name == "hp" then
		PUBLIC.trriger_msg( self.d , "car_hp_reduce_before" , {attacker = self.skill_owner , be_attacker = self.owner  } )

		PUBLIC.trriger_msg( self.d , "car_hp_reduce" , {attacker = self.skill_owner , be_attacker = self.owner } )

		PUBLIC.trriger_msg( self.d , "car_hp_reduce_after" , {attacker = self.skill_owner , be_attacker = self.owner } )
	end

	self:destroy()
end

return C



------ 重写 技能 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.ptg_storage_skill_protect = {}
local D = DATA.ptg_storage_skill_protect

----- 最能的上限值
D.storage_value_max="$value"

------ 小油门的 储能的系数
D.small_youmen_factor = "$value_bfb"

---- 大油门 经过终点增加的值
D.big_youmen_add_value = "$gailv_bfb"



function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
		--- 初始化 ， 当技能创建之后调用
	function C:init()

		self.storage_value_max = PUBLIC.convert_chehua_config( self.d , D.storage_value_max , self.id , self.owner and self.owner.seat_num ) 
		self.small_youmen_factor = PUBLIC.convert_chehua_config( self.d , D.small_youmen_factor , self.id , self.owner and self.owner.seat_num )
		self.big_youmen_add_value = PUBLIC.convert_chehua_config( self.d , D.big_youmen_add_value , self.id, self.owner and self.owner.seat_num )

		---- 当前储能值 , 可以是小数
		self.storage_value = 0

		---- 加入obj的技能列表
		self.create_skill_process_no = PUBLIC.add_skill( self )


		--- 处理 消息监听
		self:deal_msg()

		--self:deal_on_create_msg()
		---- 处理消息
		self:common_deal_on_msg( "on_create" )

		---- 处理消息
		self:common_deal_on_msg( "on_create_after" )
	end

	function C:deal_other_msg()
		---- 监听油门情况
		self.msg_deal["player_nor_op_over"] = function(_self , _arg )
			if _arg.trigger == self.owner then
				if _arg.op_type ==  DATA.player_op_type.small_youmen then
					----
					self:deal_small_youmen_logic()
				end

			end
		end

		---- 监听每次经过终点消息
		self.msg_deal["position_moveIn_start_point"] = function(_self , _arg )
			if _arg.trigger == self.owner then
				if _arg.move_type == "big_youmen" or  _arg.move_type == "small_youmen" or  _arg.move_type == "sprint" then
					---- 大油门，经过终点，直接加一个值

					self:add_storage_value(self.big_youmen_add_value)
				end
			end
		end

		self.msg_deal["ptg_storage_fill"] = function(_self , _arg )
			if self.owner == _arg.skill_owner then
				local percent = _arg.fill_percent
				local storage_max = self:get_storage_max()

				self:add_storage_value( storage_max * percent / 100 )
			end
		end

	end

	---- 处理小油门逻辑
	function C:deal_small_youmen_logic()
		local sp = DATA.car_prop_lib.get_car_prop( self.owner , "sp" )
		local add_value = sp / self.small_youmen_factor

		if add_value < 1 then
			add_value = 1
		end

		self:add_storage_value(add_value)
	end

	----- 获得最大的 存储值，经过buff 处理的
	function C:get_storage_max()
		return DATA.car_prop_lib.get_skill_buff_value( self , "storage_max" , self.storage_value_max ) 
	end

	----- 获得当前的 储能值
	function C:get_storage_value( _is_spend )
		local storage_value = self.storage_value

		if _is_spend then
			self.storage_value = 0
		end

		return storage_value
	end

	function C:add_storage_value(_add)
		print("add_storage_value 11111111111111111111111111111111111111111111111111")
		self.storage_value = self.storage_value + _add

		local storage_max = self:get_storage_max()

		if self.storage_value > storage_max then
			self.storage_value = storage_max 
		end
		self:on_skill_change()
	end


	function C:deal_msg ()
		self.msg_deal = {}
		self.msg_deal_func = {}

		if self.config and self.config.work_module then
			--- 这里 用 ipairs 确保顺序
			for key,data in ipairs(self.config.work_module) do

				self:deal_one_work_module(data)

			end
		end

		----- 把消息处理函数列表，连接给消息处理
		self:connect_msg_deal_func()

		self:deal_other_msg()

		PUBLIC.add_msg_listener( self.d , self , self.msg_deal )
	end

	function C:get_other_data()
		local tar_data = {}

		local storage_max = self:get_storage_max()
		tar_data[#tar_data+1] = { key = "storage_value_max", value = storage_max }
		---- 最大的额外子弹数
		tar_data[#tar_data+1] = { key = "storage_value", 
									value = self.storage_value  }

		return tar_data
	end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------

	return skill_base
end


return D
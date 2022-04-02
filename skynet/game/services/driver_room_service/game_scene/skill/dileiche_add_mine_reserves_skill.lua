------ 重写 技能 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.dileiche_add_mine_reserves_protect = {}
local D = DATA.dileiche_add_mine_reserves_protect

D.max_mine_num = "$max_value"
D.round_start_add = "$value"
D.start_point_add = "$value_bfb"

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	function C:init(_father_process_no)
		self.mine_num = 0

		self.max_mine_num = PUBLIC.convert_chehua_config( self.d , D.max_mine_num , self.id , self.owner and self.owner.seat_num )
		self.round_start_add = PUBLIC.convert_chehua_config( self.d , D.round_start_add , self.id , self.owner and self.owner.seat_num )
		self.start_point_add = PUBLIC.convert_chehua_config( self.d , D.start_point_add , self.id , self.owner and self.owner.seat_num )

		----  赋值 buff的初始值
		self.buff_prop = self.buff_prop or {}
		self.buff_prop.max_mine_num = 0

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
		self.msg_deal["position_moveIn_start_point"] = function(_self , _arg )
			print("xxxx----------------dileiche_mine_reserves___position_moveIn_start_point 1")
			if self.owner == _arg.trigger then
				print("xxxx----------------dileiche_mine_reserves___position_moveIn_start_point 2")
				self:add_extra_mine_num( self.start_point_add  )
			end
		end
		---- 自己 的轮次开始 ，地雷加一
		self.msg_deal["round_start"] = function(_self , _arg )
			if _self.owner.seat_num == _arg.seat_num then
				--if self.mine_num == 0 then
					self:add_extra_mine_num( self.round_start_add  )
				--end
			end
		end

		---- 地雷补充消息
		self.msg_deal["dlc_storage_fill"] = function(_self , _arg )
			if self.owner == _arg.skill_owner then
				local percent = _arg.fill_percent
				local storage_max = self:get_max_mine_num()

				self:add_extra_mine_num( math.floor( storage_max * percent / 100 ) )
			end
		end
		

	end

	function C:add_extra_mine_num(_add)
		--local old_value = self.extra_mine_num
		print("xxxxx---------------add_extra_mine_num",self.mine_num)
		self.mine_num = self.mine_num + _add

		local max_mine_num = self:get_max_mine_num()

		if self.mine_num > max_mine_num then
			self.mine_num = max_mine_num
		elseif self.mine_num < 0 then
			self.mine_num = 0
		end
		----计算最大地雷数
		--local real_max_extra_mine_num = DATA.car_prop_lib.get_skill_buff_value( self , "mine_max" , self.max_extra_mine_num ) 

		----- 当技能改变
		self:on_skill_change()
	end

	---- 获得地雷数量
	function C:get_mine_num()
		print("xxxxx---------------get_mine_num",self.mine_num)
		return self.mine_num
	end

	function C:get_max_mine_num()
		local max_mine_num = DATA.car_prop_lib.get_skill_buff_value( self , "max_mine_num" , self.max_mine_num ) 

		return max_mine_num
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

		tar_data[#tar_data+1] = { key = "mine_num", value = self.mine_num }
		---- 最大的额外子弹数
		local max_mine_num = self:get_max_mine_num()
		tar_data[#tar_data+1] = { key = "max_mine_num", value = max_mine_num  }

		return tar_data
	end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
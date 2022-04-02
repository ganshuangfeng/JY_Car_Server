------ 双倍资源库技能，次数用完就 over , 每次发奖前就减一，不管中没中奖

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.car_double_ziyuanka_skill_protect = {}
local D = DATA.car_double_ziyuanka_skill_protect

--作用次数
D.work_num = "$duration_round"


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	function C:deal_other_msg()
		----- 当 
		self.msg_deal["use_grid_award_before"] = function(_self , _arg )
			if self.owner.seat_num == _arg.seat_num then
				self.work_num = self.work_num - 1
				print("xxx--------------car_double_ziyuanka_skill ,  ", self.work_num )
				if self.work_num <= 0 then
					PUBLIC.delete_skill( self )
				end

			end
		end
		

	end


	--- 初始化 ， 当技能创建之后调用
	function C:init( _father_process_no )
		self.work_num = PUBLIC.convert_chehua_config( self.d , D.work_num , self.id , self.owner and self.owner.seat_num )

		---- 加入obj的技能列表
		self.create_skill_process_no = PUBLIC.add_skill( self , _father_process_no )

		--- 处理 消息监听
		self:deal_msg()

		--self:deal_on_create_msg()
		---- 处理消息
		self:common_deal_on_msg( "on_create" )

		---- 处理消息
		self:common_deal_on_msg( "on_create_after" )

	end


	--- 处理 消息监听
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



	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
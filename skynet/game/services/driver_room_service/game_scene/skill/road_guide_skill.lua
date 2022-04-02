------  导航器 的身上的技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.road_guide_skill_protect = {}
local D = DATA.road_guide_skill_protect

D.range = "$range"

function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ -----------
	function C:init(_father_process_no)

		self.range = PUBLIC.convert_chehua_config( self.d , D.range , self.id , self.owner and self.owner.seat_num )


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


	function C:get_other_data()
		local tar_data = {}

		---- 检测范围 ，
		tar_data[#tar_data+1] = { key = "range", 
									value = self.range  }
		
		return tar_data
	end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
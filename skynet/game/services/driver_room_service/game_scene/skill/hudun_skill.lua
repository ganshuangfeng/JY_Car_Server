------ 护盾技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.hudun_skill_protect = {}
local D = DATA.hudun_skill_protect


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	--- 初始化 ， 当技能创建之后调用
	function C:init( _father_process_no )
		----- 如果有相同的护盾类型的技能 ， 得先删除
		------------------ 如果是护盾技能，则得删掉之前的 护盾技能
		if self.config.tag and self.config.tag["hudun_skill"] then
			for skill_id , skill_obj in pairs( self.owner.skill ) do
				if skill_obj.config and skill_obj.config.tag["hudun_skill"] then

					PUBLIC.delete_skill( skill_obj )
				end
			end
		end

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


	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
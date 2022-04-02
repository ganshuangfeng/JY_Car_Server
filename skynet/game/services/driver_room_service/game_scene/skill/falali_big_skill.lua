------ 法拉利--大技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.falali_big_skill_protect = {}
local D = DATA.falali_big_skill_protect


function D.new( _d , _config , _data )
	local skill_base = common_skill.new( _d , _config , _data )
	local C = skill_base
	--------------------------------------------------------------------- 重写部分 ↓ --------------------------------------------------------------
	
	------ 主动出发技能，只触发 trigger_msg 是 zhudong 的技能
	function C:trigger_zhudong_skill()
		if self.config and self.config.work_module then
			for key,data in pairs(self.config.work_module) do
				repeat

				if data.trigger_msg == "zhudong" then
					self:deal_work( data , { trigger = self.owner } )

					----- 触发大技能之后，加一个 标签
					PUBLIC.add_tag( self.owner , "falali_big_skill_work" )

				end

				until true
			end
		end
	end

	function C:deal_other_msg()
		---- 停下来之后，要删掉对应的 buff 
		self.msg_deal["position_relation_stay_road"] = function(_self , _arg )
			----- 技能的车在动
			if self.owner == _arg.trigger then
				if PUBLIC.get_tag( self.owner , "falali_big_skill_work" ) then
					PUBLIC.delete_tag( self.owner , "falali_big_skill_work" )

					----- 清掉buff
					self:clear_buff()
				end
			end
		end
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

	--- 处理操作
function C:deal_work( _work_module , _arg_table)
	---- 处理 前置条件检查
	if not self:deal_work_condition(_work_module.work_condition)  then
		----- 发出一个消息，技能 前置条件检查 失败
		PUBLIC.trriger_msg( self.d , "skill_work_condition_false" , { skill_id = self.id , trigger = _arg_table.trigger , false_skill_owner = self.owner } )

		return false
	end

	local skill_target = self:get_skill_target( _work_module.skill_target , _arg_table)

	if skill_target then

		----------------------------------- 记录过程数据
		self:deal_skill_trigger_process_data( skill_target , _arg_table , _work_module.trigger_msg)

		------------------------------------------- 执行操作
		local create_obj_num = 1
		--[[local work_twice_gl = DATA.car_prop_lib.get_skill_buff_value( self , "work_twice_gl" )
		if math.random(100) < work_twice_gl then
			create_obj_num = 2
		end--]]
		----- 延迟创建 buff
		local last_process_no = self.last_process_no
		self.d.game_run_system:create_delay_func_obj(function() 
			self:create_buff( _work_module , skill_target , last_process_no )
		end)

		----- 要做的 obj 列表
		for i = 1,create_obj_num do
			self:create_run_obj( _work_module , skill_target )
		end


		-------- 创建buff , （这个得 用 创 obj 的方式来创。 保证顺序）
		--self:create_buff( _work_module , skill_target )
		
		--------------------------------------------- 生命周期处理
		self:deal_skill_life_data( "trigger_num" )

	end

	return true
end

	--------------------------------------------------------------------- 重写部分 ↑ --------------------------------------------------------------
	return skill_base
end


return D
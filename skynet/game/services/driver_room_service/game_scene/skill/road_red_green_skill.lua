------  红绿灯障碍 的身上的技能

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local common_skill = require "driver_room_service.game_scene.skill.common_skill"

DATA.road_red_green_skill_protect = {}
local D = DATA.road_red_green_skill_protect

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

	----- 获得一个 处理消息的 通用函数
	function C:get_one_msg_deal_func(data)
		return function(_self , _arg_table )
			print("xxxx----------------on_deal_msg wss:" , self.id , data.trigger_msg , _arg_table)
			--dump(_arg_table , "xxxx-----------------------------------_arg_table:")
			local _arg_table = _arg_table
			local _self = _self
			local data = data

		self.d.game_run_system:create_delay_func_obj(function() 
			print("xxxx----------------------on_deal_msg wss 22:" , self.id , data.trigger_msg , _arg_table)
			--- 针对每一个参数 做检查
			local is_all_ok = true
			if _arg_table and type(_arg_table) == "table" then

				------
				--local condition_env = basefunc.deepcopy( _arg_table )
				--local extra_data = { owner = self.owner , _d = self.d , skill_self = self }
				--condition_env = basefunc.merge( extra_data , condition_env )

				

				local condition_env = { owner = self.owner , _d = self.d , skill_self = self } -- basefunc.deepcopy( _arg_table )
				--local extra_data = { owner = self.owner , _d = self.d , skill_self = self }
				condition_env = basefunc.merge( _arg_table , condition_env )

				if data.trigger_msg_condition then
					for key, cond_dsl in pairs(data.trigger_msg_condition) do
						if not self.owner then
							is_all_ok = false
							break
						end
						
						if cond_dsl.func and cond_dsl._env then

							--dump(cond_dsl._env , string.format("xxx----------------------cond_dsl._env:%s" , cond_dsl._env )  )

							local is_true = cond_dsl.func( condition_env )

							print( string.format("xxx----check_condition__%s__%s__%s_is_%s", self.id , data.trigger_msg , cond_dsl.conditon_dsl , is_true and "true" or "false" ) )

							if self.id == 10011 then
								print("xxx----------test 10011 :" ,  _arg_table.trigger.is_move , _arg_table.trigger.pos , self.owner.road_id , _arg_table.trigger.group , self.owner.group)
							end

							if is_true then
								print("xxxx----------------------on_deal_msg wss 33:" , self.id , data.trigger_msg , _arg_table)
								--dump( self.owner , string.format("xxx----------------check_condition skill_id:%s  self.owner:%s", self.id ,data.trigger_msg ) )
								--dump( _arg_table , string.format("xxx----------------check_condition _arg_table skill_id:%s  self.owner:%s", self.id ,data.trigger_msg ) )
							end
							----- 正式版 ↓
							--local is_ok , is_true = pcall( cond_dsl.func , condition_env )
							--if is_ok and not is_true then
							----- 正式版 ↑

							if not is_true then
								is_all_ok = false
								break
							end
						end
					end
				end

			end

			---- 如果全部成立 
			if is_all_ok then
				print("xxxx----------------------on_deal_msg wss 44:" , self.id , data.trigger_msg , _arg_table)
				----- 把 deal_work 放到执行队列中
				--self.d.game_run_system:create_delay_func_obj(function() 
					_self:deal_work( data , _arg_table )
				--end)
			end
		end)

		end
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
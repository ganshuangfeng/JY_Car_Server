
-----车辆 攻击  的  (处理单元) ；
--[[
	会执行 攻击 流程：
		伤害值获取： 基础伤害(可能被buff影响) * _cfg.base_at_time + _cfg.fix_at_value
		
		再 用计算后的伤害值 计算 技能的攻击值受buff 的影响：
			上面的伤害值 -> 经过 获取车技能属性 final_at ->

		判断是否通过他人的miss概率，然后判断是否触发我的连击概率，再判断是否触发我的暴击概率。

		ps：
			*.miss 概率只有基础值(可以受buff影响)，暴击概率，连击概率，都有基础值 + 技能专属值 ，且这两个值都能受buff影响。

		
--]]

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("car_attack_obj" , "object_class_base" )

--[[

--]]

function C:ctor(_d , _config )
	print("xxxx---------------------car_attack_obj__new")

	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	---- 基础攻击的 倍数
	self.base_at_time = _config.base_at_time
	---- 固定伤害值
	self.fix_at_value = _config.fix_at_value

	---- 支持类似 car_modify_property_obj 的传参
	self.modify_type = _config.modify_type
	self.modify_value = _config.modify_value
	self.percent_base_type = _config.percent_base_type
	self.percent_base_value = _config.percent_base_value


	---- 暴击倍数
	self.bj_add = _config.bj_add or self.skill_owner["bj_xishu"] or 1.5
	---- 连击次数
	self.lj_num = 2
	---- 连击后的 伤害加成
	self.lj_add = _config.lj_add or self.skill_owner["lj_xishu"] or 0.75

	--- 编辑标签 , list 
	self.modify_tag = _config.modify_tag or {}

	---- 不会执行的操作 ， 这个是 处理默认 会 执行的
	self.not_deal_act = _config.not_deal_act
	self.not_deal_act = basefunc.list_to_map( self.not_deal_act )

	---- 会执行的操作，这个是 处理默认 不会 执行的
	self.can_deal_act = _config.can_deal_act
	self.can_deal_act = basefunc.list_to_map( self.can_deal_act )

end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )
	
	---- 基类处理
	self.super.init(self)

	---------- 
	if self.modify_type and self.modify_value then
		if self.modify_type == 1 then

			self.fix_at_value = math.abs( self.modify_value )
		elseif self.modify_type == 2 then
			local base_value = self.owner.hp
			if self.percent_base_value and type(self.percent_base_value) == "number" then
				base_value = self.percent_base_value
			elseif self.percent_base_type and self.owner[self.percent_base_type] and type(self.owner[self.percent_base_type]) == "number" then
				---- 拿属性的话，都经过一下 buff
				base_value =  DATA.car_prop_lib.get_car_prop( self.owner , self.percent_base_type )  -- self.owner[self.percent_base_type]
			end

			self.fix_at_value =math.abs(  math.floor( base_value * ( self.modify_value / 100 ) ) )
		end
	end


end

---- 添加修改标签
function C:add_modify_tag( _tag , _bool )
	if _tag == "lj" then
		print("   ",_bool)
	end
	if _bool then
		self.modify_tag[ #self.modify_tag + 1 ] = _tag
	end
end

function C:wake()
	---- 拿到当前 释放车辆的 攻击值 ; 这个 self.skill_owner 可能不是车，可能是地雷
	local attack_value = DATA.car_prop_lib.get_car_prop( self.skill_owner , "at" ) or 0

	------ PS： 技能的 base_at_time , fix_at_value  buff 计算，是放在这里，外面传入默认的就行了 
	local r_base_at_time = DATA.car_prop_lib.get_skill_buff_value( self.skill , "base_at_time" , self.base_at_time )
	local r_fix_at_value = DATA.car_prop_lib.get_skill_buff_value( self.skill , "fix_at_value" , self.fix_at_value )

	--dump(self.skill.owner.buff , "xxx-------------------car_buff")
	print("xxxxx-----------------base_at_time:" , self.base_at_time , r_base_at_time)
	---  算出的 基础伤害
	self.real_attack_value = math.floor(attack_value * r_base_at_time) + r_fix_at_value
end

function C:destroy()
	self.is_run_over = true
end

----- 添加攻击 obj
function C:add_at_obj( _at_value )
	------ 用 编辑属性来 减血
	local data = { owner = self.owner , skill = self.skill , skill_owner = self.skill_owner , father_process_no = self.father_process_no ,
		level = 1 , 
		obj_enum = "car_modify_property_obj",
		modify_key_name = "hp",
		modify_type = 1,
		modify_value = -_at_value ,

		modify_tag = basefunc.deepcopy( self.modify_tag ),
	}

	local run_obj = PUBLIC.create_obj( self.d , data )
	if run_obj then
		---- 加入 运行系统
		self.d.game_run_system:create_add_event_data( run_obj , 1 , "next" ) 
	end
end

function C:run()
	print("xxxx---------------------car_attack_obj__run")

	---- 先计算被攻击者 的 miss 概率
	if not self.not_deal_act["miss_act"] then
		local miss_gl = DATA.car_prop_lib.get_car_prop( self.owner , "miss_gl" )
		if math.random( 100 ) <= miss_gl then

			self:add_modify_tag( "miss" , true )

			self:add_at_obj( 0 )
			self:destroy()
			return 
		end
	end

	---- 再计算 是否有 技能的伤害加成
	--self.real_attack_value = DATA.car_prop_lib.get_skill_buff_value( self.skill , "final_at" , self.real_attack_value )

	local deal_num = 1
	----------------------- 计算 攻击者的 连击
	local is_lj = false

	---- 不会处理连击
	if self.can_deal_act["lj_act"] then
		local base_lj_gl = DATA.car_prop_lib.get_car_prop( self.skill_owner , "lj_gl" ) or 0
		local skill_lj_gl = DATA.car_prop_lib.get_skill_buff_value( self.skill , "lj_gl" )
		local real_lj_gl = base_lj_gl + skill_lj_gl
		if math.random(100) <= real_lj_gl then
			is_lj = true
		end

		deal_num = is_lj and self.lj_num or 1
	end

	----------------------- 计算额外的 连击次数
	if self.can_deal_act["extra_lj_act"] then
		local extra_lj_num = DATA.car_prop_lib.get_car_prop( self.skill_owner , "extra_lj_num" ) or 0

		is_lj = true
		deal_num = deal_num + extra_lj_num
	end

	----------------------- 计算 攻击者的 暴击概率
	local base_bj_gl = DATA.car_prop_lib.get_car_prop( self.skill_owner , "bj_gl" ) or 0
	local skill_bj_gl = DATA.car_prop_lib.get_skill_buff_value( self.skill , "bj_gl" )
	local real_bj_gl = base_bj_gl + skill_bj_gl

	---------------------
	for i = 1 , deal_num do
		---- 是否暴击
		local is_bj = false
		---- 强制设置了的才会 暴击，默认是不暴击
		if self.can_deal_act["bj_act"] and math.random(100) <= real_bj_gl then
			is_bj = true
		end

		------ 第一次的连击 ， 不加成连击系数 , 修改  基础伤害
		if is_lj and i ~= 1 then
			self.real_attack_value = self.lj_add * self.real_attack_value
		end

		----- 额外增加的暴击伤害值, 在算出的攻击力上增加
		local extra_bj_value = 0
		if is_bj then
			extra_bj_value = math.floor( self.real_attack_value * ( self.bj_add - 1) )
		end

		----- 这个车
		local car_final_add_at = 0
		if self.skill_owner.kind_type == DATA.game_kind_type.car then
			car_final_add_at = DATA.car_prop_lib.get_car_prop( self.skill_owner , "final_add_at"  , nil , self.real_attack_value )
		end
		----- 这个技能 额外提升的攻击力
		local skill_final_add_at = DATA.car_prop_lib.get_skill_buff_value( self.skill , "final_add_at"  , nil , self.real_attack_value )


		local real_attack_value = self.real_attack_value + extra_bj_value + car_final_add_at + skill_final_add_at

		self:add_modify_tag( "bj" , is_bj )
		self:add_modify_tag( "lj" , (i ~= 1) and is_lj  )

		self:add_at_obj( real_attack_value )
	end
	--攻击了

	--if self.skill_owner.seat_num == 1 then
	--	print( "xxxx------------car_attack_obj___::",debug.traceback() )
	--end


	self.skill_owner.is_attack = true





	self:destroy()

end

return C


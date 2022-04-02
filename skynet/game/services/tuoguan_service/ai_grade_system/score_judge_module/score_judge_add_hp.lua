
----- 加减血 打分

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("score_judge_add_hp" )
C.msg_deal = {}

function C:ctor(_config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 自己关心的 效果
	self.deal_effect = PROTECT.effect_type.add_hp
end

---- 
function C:init()
	---- 监听消息
	PROTECT.add_msg_listener( self.car_id , self , C.msg_deal )

end

function C:destroy()
	PROTECT.delete_msg_listener( self.car_id , self )
end

function C.msg_deal:deal_score_judge( _effect_score_data , _game_data , _effect , _tar_seat , _effect_value )
	if _effect ~= self.deal_effect then
		return 
	end

	---- 单位效果分数
	local score = 1
	local score_xishu = 1  --分数系数就是受当前血量影响
	if _tar_seat == _game_data.my_seat then
		print("score_xishu:  ",score_xishu)
		score_xishu = 2 - _game_data[_game_data.my_seat].car_hp / _game_data[_game_data.my_seat].car_max_hp
		print("score_xishu:  ",score_xishu)
	end

	score = _effect_value * score * score_xishu

	---- 如果不是改的我自己，分数就取反
	if _tar_seat ~= _game_data.my_seat then
		score = -score

		---- 如果 是减血，并已经打死敌人了
		local enemy_car_hp = _game_data[_tar_seat].car_hp
		if _effect_value < 0 and math.abs( _effect_value ) >= enemy_car_hp then
			score = PROTECT.max_score
		end

	end

	_effect_score_data[_tar_seat] = score

end

return C


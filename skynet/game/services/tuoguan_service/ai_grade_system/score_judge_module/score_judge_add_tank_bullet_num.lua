
----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("score_judge_add_tank_bullet_num" )
C.msg_deal = {}

function C:ctor(_config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 自己关心的 效果
	self.deal_effect = PROTECT.effect_type.add_tank_bullet_num
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

	local score = 5

	score = score * _effect_value

	---- 如果不是改的我自己，分数就取反
	if _tar_seat ~= _game_data.my_seat then
		score = -score
	end

	_effect_score_data[_tar_seat] = score
	
end

return C


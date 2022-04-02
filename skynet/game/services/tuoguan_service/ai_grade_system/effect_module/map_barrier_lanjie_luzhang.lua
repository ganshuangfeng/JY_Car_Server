
----- 已经 放置 在路上的  拦截路障的效果

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local PROTECT = DATA.ai_grade_system_protect

local C = basefunc.create_hot_class("map_barrier_lanjie_luzhang" )
C.msg_deal = {}

function C:ctor( _config)
	--- 所属的车id
	self.car_id = _config.car_id

	--- 类型id
	self.type_id = _config.type_id

	--- 拦截概率
	self.lanjie_gl = _config.lanjie_gl / 100

end

---- 
function C:init()
	---- 监听消息
	PROTECT.add_msg_listener( self.car_id , self , C.msg_deal )

end

function C:destroy()
	PROTECT.delete_msg_listener( self.car_id , self )
end

function C.msg_deal:on_move_in_road( _effect_data , _game_data , _gl , _other_data )
	---- 判断这个位置上是否有 敌人的 拦截路障， 如果有则会改变 移动概率

	local enemy_luzhang = PROTECT.get_road_enemy_luzhang( _game_data , _other_data.road_id )

	if enemy_luzhang then
		---- 总的移动概率 * 上miss 概率
		_game_data.total_move_gl = _game_data.total_move_gl * ( 1 - self.lanjie_gl )

		----- 拦截概率下，的 停留消息
		local map_award_data = PROTECT.get_map_award_data( _game_data , _other_data.road_id )

		if map_award_data and not map_award_data.is_use then
			map_award_data.is_use = true

			PROTECT.trriger_msg( my_car_id , "on_stay_road" , _effect_data , _game_data , map_award_data.type_id , self.lanjie_gl , { road_id = _other_data.road_id } )
		end

		----- 删掉这个路障
		PROTECT.delete_road_barrier( _game_data ,  enemy_luzhang )
	
		
	end


end

return C


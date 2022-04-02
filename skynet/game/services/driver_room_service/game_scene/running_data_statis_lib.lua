------- 用来统计，运行中的数据的模块

local base = require "base"
local basefunc = require "basefunc"
local skynet = require "skynet_plus"

local DATA = base.DATA
DATA.running_data_statis_lib = {}
local C = DATA.running_data_statis_lib



---- 收集 游戏过程数据
function C.add_game_data( _d , _add_data , _father_process_no )--_data_type , ... )

	---- 编号 递增
	_d.running_process_no = _d.running_process_no + 1

	_add_data.process_no = _d.running_process_no
	_add_data.father_process_no = _father_process_no

	--_d.running_process_no
	if next(_add_data) then
		_d.running_data[#_d.running_data + 1] = _add_data

		_d.total_running_data[#_d.total_running_data + 1] = _add_data
	end

	----- 增加预估时间
	_d.game_process_time = _d.game_process_time + C.get_movie_time( _add_data )

	return _add_data.process_no
end


---- 获得 一次 动画时间
function C.get_movie_time( _process_data )
	local time = 0

	for key,data in pairs( _process_data ) do
		if DATA.game_movie_time_config and DATA.game_movie_time_config[ key ] then
			----- 判断条件
			local cfg = DATA.game_movie_time_config[ key ]
			---- 条件 默认成立
			local is_condition = true
			if cfg.condition_data then
				for _key,_cod_data in pairs(cfg.condition_data) do
					if data[_key] and not basefunc.compare_value( data[_key] , _cod_data.condition_value , _cod_data.judge_type ) then
						is_condition = false
						break
					end
				end
			end

			------ 如果条件成立，加时间
			if is_condition then
				time = time + cfg.time
			end
		end
	end

	return time
end

----

return C
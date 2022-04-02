--[[
	通用排行榜服务

	--- other_data 需要 手动处理
	--- 发邮件 需要 手动处理 , 加一个对应的邮件配置就行了。

--]]

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

require "normal_enum"
require "printfunc"
require "data_func"
require "common_data_manager_lib"
require "common_merge_push_sql_lib"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

DATA.service_config = nil

DATA.box_config = nil

---- 总共 同时解锁的数量
DATA.total_unlock_num = 1
---- 总共的宝箱位
DATA.total_box_pos = 4


DATA.msg_tag = "timer_box_center_service"

--- box 数据
DATA.player_box_data = DATA.player_box_data or basefunc.server_class.data_manager_cls.new( { load_data = function(...) return PUBLIC.load_player_box_data(...) end } , 10000 )


function PUBLIC.load_player_box_data( _player_id )
	local _sql = string.format( [[ select * from player_timer_box_data where player_id = '%s'; ]] , _player_id )

	local ret = PUBLIC.db_query(_sql)
	if( ret.errno ) then
		print(string.format("load_player_box_data sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
		return nil
	end
	
	local ret_vec = {}

	if ret and type(ret) == "table" and next(ret) then
		for key,data in pairs(ret) do
			ret_vec[data.pos_id] = data
		end
	end

	dump( ret_vec , "xxx---------------------- load_player_box_data ret: " ) 
		
	return ret_vec
end
-------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
--- 获得 所有的 宝箱数据
function CMD.get_player_box_data(_player_id)
	local player_box_data = DATA.player_box_data:get_data( _player_id )
	
	return player_box_data
end


---- 
function CMD.add_or_update_one_box_data( _player_id , _pos_id , _box_data )
	local player_box_data = DATA.player_box_data:get_data( _player_id )
	--- 更新内存
	player_box_data[ _pos_id ] = _box_data
	--- 更新数据库
	DATA.box_data_pusher:add_to_sql_cache( { _player_id , _pos_id } , player_box_data[ _pos_id ] , _player_id )

	return player_box_data
end

----删掉一个box
function CMD.delete_one_box_data( _player_id , _pos_id )
	local player_box_data = DATA.player_box_data:get_data( _player_id )
	player_box_data[ _pos_id ] = nil

	---- 清掉所有的缓存的数据
	DATA.box_data_pusher:delete_sql_cache( { _player_id , _pos_id } )

	---- 再删除
	local sql = PUBLIC.format_sql("delete from player_timer_box_data where player_id = %s and pos_id=%s;"
								,_player_id,_pos_id)

	print("xxx-------------------------------------delete_one_box_data data: ", _player_id , _pos_id)

	PUBLIC.db_exec(sql)

end

---- 新增一个box
function CMD.add_one_box_data( _player_id , _box_id )
	--local player_base_info = CMD.get_player_base_info( _player_id )
	local player_box_data = DATA.player_box_data:get_data( _player_id )
	
	if basefunc.key_count(player_box_data) >= DATA.total_box_pos then --player_base_info.total_pos then
		return 8007
	end

	---- 找到一个空闲的位置
	local empty_pos_id = nil
	local empty_pos_vec = { }

	for i = 1 , DATA.total_box_pos do
		empty_pos_vec[i] = true
	end

	for pos_id , data in pairs(player_box_data) do
		empty_pos_vec[pos_id] = nil
	end

	if not next(empty_pos_vec) then
		return 8007
	end

	local _pos_id , _  = next(empty_pos_vec)

	local _box_data = {
		player_id = _player_id ,
		pos_id = _pos_id ,
		box_id = _box_id , 
	}

	CMD.add_or_update_one_box_data( _player_id , _pos_id , _box_data )

    return 0 , _box_data
end


--- 载入配置
function PUBLIC.load_drive_game_timer_box_config( _raw_config )
	DATA.box_config = {}

	local award = {}
	if _raw_config.award then
		for key,data in pairs( _raw_config.award ) do
			award[ data.id ] = award[ data.id ] or {}
			local tar_data = award[ data.id ]

			tar_data[#tar_data + 1] = data
		end
	end

	for key,data in pairs( _raw_config.main ) do

		data.award_data = basefunc.deepcopy( award[ data.award ] or {} )

		DATA.box_config[data.id] = data
	end

	---- 发出一个消息改变
	skynet.send( DATA.service_config.msg_notification_center_service , "lua" , "trigger_msg" , { name = "on_timer_box_config_change"  } , DATA.box_config )

end

function CMD.get_timer_box_config()
	return DATA.box_config , DATA.total_unlock_num , DATA.total_box_pos
end

function PUBLIC.init()
	---- 载入配置
	nodefunc.query_global_config( "drive_game_timer_box_server" , function(...) PUBLIC.load_drive_game_timer_box_config(...) end )


	---- 延迟写入
	DATA.box_data_pusher = DATA.box_data_pusher or basefunc.server_class.common_merge_push_sql_lib.new( 60 , DATA.player_box_data , {
		tab_name = "player_timer_box_data",
		queue_type = "slow",
		push_type = "update",
		field_data = {
			player_id = {
				is_primary = true,
				value_type = "equal",
			},
			pos_id = {
				is_primary = true,
				value_type = "equal",
			},
			box_id = {
				value_type = "equal",
			},
			start_time = {
				value_type = "equal",
			},
		},
	} )

end

function CMD.start(_service_config)

	DATA.service_config = _service_config


	PUBLIC.init()

end

-- 启动服务
base.start_service()

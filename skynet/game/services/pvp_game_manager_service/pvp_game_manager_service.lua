
-- pvp游戏管理器 , 管理匹配，全部游戏人数等。

local basefunc = require "basefunc"
require"printfunc"

local skynet = require "skynet_plus"
require "skynet.manager"
local base=require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"

require "normal_enum"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

---- 
DATA.common_matching = require "pvp_game_manager_service.common_matching"
DATA.duanwei_lib = require "pvp_game_manager_service.duanwei_lib"

local LF = base.LocalFunc("pvp_game_manager_service")

-- pvp 游戏的 管理状态
DATA.MANAGER_STATUS =
{
	DISABLE = -1, -- 禁用（已经被 管理员配置为禁用，不允许再报名）
	SIGNUP = 1, -- 报名中

}

----- 从game_center中收到的配置
DATA.game_manager_config = nil
--- 游戏 模式，游戏id, 游戏类型
DATA.game_mode = nil
DATA.game_id = nil
DATA.game_type = nil

----- 消息函数
DATA.func_name = {
	enter_room_msg = "pvp_enter_room_msg",
}

----- 匹配模式
DATA.matching_model = {
	danren = "pvp_game_manager_service.matching_danren" ,
	random = "pvp_game_manager_service.matching_random" ,
	only_tuoguan = "pvp_game_manager_service.matching_only_tuoguan" ,
	pvp = "pvp_game_manager_service.matching_pvp" ,
}

DATA.dt = 0.2

---- 配置
DATA.config = nil
---- 最大游戏人数
DATA.max_game_palyers = 2000

--所有的玩家总数
DATA.all_player_count = 0
--所有的玩家信息 player_id={ id = , status = gaming , room_id , table_id,}
DATA.all_player_info = {}
--- 真人的 数量
DATA.real_player_count = 0
--- 管理器状态
DATA.manager_status = nil



function LF.load_game_config(_raw_config)

	DATA.config = {}

	---- 确定 game_rule
	for _, cfg_data in ipairs(_raw_config.game_rule) do
		if cfg_data.game_id == DATA.game_id then
			DATA.config.game_rule = cfg_data
			break
		end
	end
	--- 确定 进入所需资产
	DATA.config.enter_cfg = {}
	for _, cfg_data in ipairs(_raw_config.enter_cfg) do
		if cfg_data.enter_cfg_id == DATA.config.game_rule.enter_cfg_id then
			DATA.config.enter_cfg[#DATA.config.enter_cfg + 1] =
			{
				asset_type = cfg_data.asset_type,
				value = cfg_data.asset_count,
				condi_type = cfg_data.judge_type,
			}
		end
	end

end


function LF.update()
	while DATA.matching_entity do

		skynet.sleep(DATA.dt*100)

		DATA.common_matching.matching_update(DATA.dt*100)

		DATA.matching_entity.update(DATA.dt*100)

	end
end

---- 检查能否报名
function PUBLIC.check_allow_signup()
	-- 禁用
	if DATA.manager_status == DATA.MANAGER_STATUS.DISABLE then
		return false,1009
	end

	-- 所有玩家数量超过场次的最大人数，显示错误:系统繁忙
	if DATA.all_player_count >= DATA.max_game_palyers then
		--服务器繁忙 请稍后再试
		return false,1008
	end

	return true
end

---- 获得这个 场次的 进入条件 , (模式 agent 调用)
function CMD.get_enter_info()

	-- 判断条件
	local ok,err = PUBLIC.check_allow_signup()
	if not ok then
		return err
	end

	return 0,{
		condi_data = DATA.config.enter_cfg,
		game_type = DATA.game_type,
		game_mode = DATA.game_mode,
		game_id = DATA.game_id,
		map_id = DATA.config.game_rule.map_id , 
	}

end

-- --一局游戏完成 ( 房间调用 )
function CMD.table_finish(_room,_table)
	print("CMD.table_finish!!",_room,_table)

	local players = DATA.common_matching.get_table_info( _room,_table )

	-- dump(players,"table_finish")
	if players then
		local table_id = nil
		for i,_player_id in pairs(players) do
			DATA.all_player_info[_player_id].ready = 0
			DATA.all_player_info[_player_id].status = "waiting"
			table_id = DATA.all_player_info[_player_id].table_id

			---- 发给agent 游戏结束
			nodefunc.send(_player_id,"pvp_gameover_msg")
		end

		DATA.common_matching.table_finish(_room,_table)
	else
		print("error!!! pvp_game_manager_service table_finish running_game[_room][_table] is nil",_room,_table)
	end

end


-- -- 归还桌子 ( 房间调用 )
function CMD.return_table(_room_id,_t_num)

	DATA.common_matching.return_table(_room_id,_t_num )

end

-- 报名 （模式agent 调用）
function CMD.player_signup(player_info)
	if DATA.all_player_info[player_info.id] then
		print("pvp player_signup error "..(player_info.id or ""))
		return {result = 2023}
	end

	local ok,err = PUBLIC.check_allow_signup()
	if not ok then
		return {result = err}
	end

	DATA.all_player_info[player_info.id] = player_info

	DATA.all_player_info[player_info.id].status = "signuped"

	DATA.all_player_count = DATA.all_player_count + 1

	if basefunc.chk_player_is_real(player_info.id) then
		DATA.real_player_count = DATA.real_player_count + 1
	end

	print("pvp player_signup "..player_info.id )

	return DATA.matching_entity.player_signup(player_info.id)

end

-- 玩家退出了 ， （模式agent 调用）
function CMD.player_exit_game(_player_id)

	local player_info = DATA.all_player_info[_player_id]

	if not player_info then
		print("pvp player_exit_game player_info is nil "..(_player_id or "") )		
		return {result = 1002}
	end

	---- 已经在队列里面了，不能强行退出
	if player_info.status == "wait_table" then
		return {result = 2025}
	end

	local ret = DATA.matching_entity.player_exit_game(_player_id)
	
	if ret and ret.result == 0 then

		DATA.all_player_count = DATA.all_player_count - 1
		if not player_info.is_robot then
			DATA.real_player_count = DATA.real_player_count - 1
		end

		DATA.all_player_info[_player_id] = nil
		print("pvp player_exit_game ok ".._player_id )

	end

	dump(ret,"pvp player_exit_game ret ".._player_id)

	return ret
end

------ 当配置改变时，从 game_center_service 调过来
function CMD.reload_config( _game_manager_config )

	PUBLIC.init_manager_config(_game_manager_config)

	DATA.manager_status = DATA.MANAGER_STATUS.SIGNUP

	if _game_manager_config.enable == 0 then
		DATA.manager_status = DATA.MANAGER_STATUS.DISABLE
	end

end


function PUBLIC.init()
	
	----- 在 pvp_game_matching 中
	DATA.common_matching.init()

    DATA.duanwei_lib.init()

	-- 载入游戏配置
	nodefunc.query_global_config("pvp_game_server" , function(...) LF.load_game_config(...) end )
	
	----- 对应的 匹配模式
	DATA.matching_entity = require ( DATA.matching_model[ DATA.config.game_rule.matching_type ] )

	DATA.matching_entity.init()

	--- 数据处理完成，设置状态为可以报名
	DATA.manager_status = DATA.MANAGER_STATUS.SIGNUP


	skynet.fork(LF.update)

end

---- 初始化 游戏管理 配置
function PUBLIC.init_manager_config(_game_manager_config)
	DATA.game_manager_config = _game_manager_config
	DATA.game_mode = _game_manager_config.game_mode
	DATA.game_id = _game_manager_config.game_id
	DATA.game_type = _game_manager_config.game_type

	DATA.seat_count = GAME_TYPE_SEAT[ DATA.game_type ]
end

function CMD.start(_id,_service_config, _game_manager_config )

	DATA.service_config = _service_config
	DATA.my_id = _id

	------------------
	PUBLIC.init_manager_config(_game_manager_config)

	PUBLIC.init()


	
end

-- 启动服务
base.start_service()



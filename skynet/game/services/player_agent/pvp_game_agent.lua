
-- pvp游戏的agent

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
require"printfunc"
require "normal_enum"
require "normal_func"
local nodefunc = require "nodefunc"
local base = require "base"
local DATA=base.DATA
local PUBLIC=base.PUBLIC

local CMD = base.CMD
local REQUEST = base.REQUEST

local cjson = require "cjson"
--- 打开稀疏数组 转换  { [1000] = data }  =>  { "1000":"data" }
cjson.encode_sparse_array(true,1,0)

DATA.pvp_game_agent_protect = {}
local PROTECT = DATA.pvp_game_agent_protect



local LF = base.LocalFunc("pvp_game_agent")
local LD = base.LocalData("pvp_game_agent",{
	game_model = "pvp_game",
	game_name = "",
	all_data=nil,
	now_game_num = 0,
	dt = 1,
	update_timer = nil,

	----- 自动退出的时间
	auto_quit_game_cd = 5*60 ,
	auto_quit_game_time = nil ,

    -- 段位信息： score, grade,level
    duanwei_data = nil,

    -- 段位进度信息（方便客户端，不存数据库）:grade_all_level,level_all_score,level_cur_score
    duanwei_progress = nil,

    -- 连续 输/赢 状态
    win_status = 0,  -- 胜 1， 负 -1， 平 0
    hold_count = 0,  -- 保持局数
})

----- pvp类型游戏 状态枚举
LD.pvp_status = {
	wait_table = "wait_table",      --- 报名之后，new_game 之后的状态，等待匹配桌子
	wait_ready = "wait_ready",       --- 玩家 join 游戏之后，等待准备状态
	gaming = "gaming",              --- 玩家 准备ok之后，开始游戏状态
	settlement = "settlement",
	game_over = "game_over",        --- 游戏结束状态

}


--update 间隔
--[[
	制定协议

	运算出配置（独特）  room   游戏过程配置  游戏规则配置  agent配置

	创建房间               加入游戏（得到游戏配置）
	生成具体的代理			生成具体的代理
	加入具体的游戏房间		  加入具体的游戏房间

		游戏过程

	计算
	结束游戏

	强制结束

--]]

function LF.update()
	if LD.all_data then

		---- 检查自动退出
		LF.check_auto_quit_game()
	end
end

function LF.check_auto_quit_game()
	if LD.all_data then

		if LD.auto_quit_game_time and os.time() > LD.auto_quit_game_time then

			local ret = REQUEST.pvp_quit_game()
			if ret.result == 0 then

				PUBLIC.request_client("pvp_auto_quit_game",{result=0})

			end

		end

	end
end

function LF.add_p_info(_p_info)

	for i,_info in ipairs(LD.all_data.players_info) do
		if _info.seat_num == _p_info.seat_num then
			LD.all_data.players_info[i] = _p_info
			return
		end
	end

	LD.all_data.players_info[#LD.all_data.players_info+1]=_p_info
end

function LF.del_p_info(_seat_num)

	for i,_info in ipairs(LD.all_data.players_info) do
		if _info.seat_num == _seat_num then
			table.remove(LD.all_data.players_info,i)
			return
		end
	end
end

function LF.update_p_info(players_info)

	LD.all_data.players_info = {}

	local _seat_num = 0
	for k,_info in pairs(players_info) do
		LD.all_data.players_info[#LD.all_data.players_info+1] = _info
		if _info.id == DATA.my_id then
			_seat_num = _info.seat_num
		end
	end

	LD.all_data.room_info.seat_num = _seat_num
end

function LF.add_status_no()
	LD.all_data.status_no = LD.all_data.status_no + 1
end

-- ###_test 初始化数据  config 是报名成功后返回的
function LF.new_game(config)
	dump(config, "new_game=1")
	DATA.pvp_game_data = {}
	LD.all_data = DATA.pvp_game_data

	LD.all_data.mode_agent = LF

	LD.all_data.signup_assets=config.signup_assets

	LD.all_data.deduct_assets = basefunc.deepcopy(config.signup_assets)
	for k,v in pairs(LD.all_data.deduct_assets) do
		v.value = -v.value
	end

	LD.all_data.base_info = {}

	LD.all_data.room_info=
	{
		game_id = config.game_id,
		room_id = nil,      -- 房间
		t_num = nil,        -- 桌子
		seat_num = nil,     -- 座位号

	}

	LD.all_data.match_info = {
		signup_service_id = config.signup_service_id , 
	}

	---- 游戏的报名数据
	LD.all_data.car_id = config.car_id

	LD.all_data.car_fujia_data = { [config.car_id] = config.car_fujia_data }

	----- 检查 自动退出的时间
	LD.auto_quit_game_time = os.time() + LD.auto_quit_game_cd

	--- 游戏的 状态
	LD.all_data.status = LD.pvp_status.wait_table
	--- 游戏的 状态id
	LD.all_data.status_no=0

	LD.all_data.players_info={}

	LD.all_data.game_type = config.game_type

	LD.all_data.gameInstance=PUBLIC.require_game_by_type(config.game_type)
	if not LD.all_data.gameInstance then
		error("gameInstance not exist!!!!!!"..config.game_type)
	end

	LD.update_timer = skynet.timer(LD.dt , LF.update)

end


function LF.free_game()

	if LD.update_timer then
		LD.update_timer:stop()
		LD.update_timer=nil
	end

	PUBLIC.unlock(LD.game_name)
	PUBLIC.free_agent(LD.game_name)

	if LD.all_data and LD.all_data.gameInstance then
		LD.all_data.gameInstance.free()
		LD.all_data.gameInstance=nil
	end

	DATA.pvp_game_data = nil
	LD.all_data = nil

	PUBLIC.off_action_lock( "pvp_signup" )

end

function LF.get_signup_service_id(id)
	return string.format("pvp_game_service_%d", id)
end

-- 处理托管 报名时 的 数值调整
-- self.pvp_game_info 和 呼叫托管时传入的 game info 参数 一样
function LF.deal_tuoguan_signup(self)
    if not self.pvp_game_info or not self.pvp_game_info.pvp_real_user_id then
        return
    end

    -- 调整积分
    local _data = skynet.call(DATA.service_config.duanwei_data_center,"lua","scale_tuoguan_for_fight",self.pvp_game_info)
    if _data then
        basefunc.deepcopy(_data,LD.duanwei_data)
    end
    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx LF.deal_tuoguan_signup::",basefunc.tostring(_data))

    -- 调整出战车辆
    --self.pvp_game_info.fight
    -- self.car_id = xxx


    if self.pvp_game_info.fight then
	    local car_id , car_fujia_data = LF.get_car_and_eqpt_data_by_fight( self.pvp_game_info.fight )
	    self.car_id = car_id
	    self.car_fujia_data = car_fujia_data

	    dump( car_fujia_data , "xxx-------------tuoguan_car_fujia_data:" .. self.pvp_game_info.fight )
	end

end

function LF.get_pvp_fight_config()
	local init_fight = skynet.getcfgi("pvp_int_fight",1400)
    local car_lv_fight = skynet.getcfgi("pvp_car_level_fight",100)
    local eqpt_lv_fight = skynet.getcfgi("pvp_eqpt_level_fight",25)
    local pipei_fight_range = skynet.getcfgi("pvp_pipei_fight_range",200)

    return { init_fight = init_fight , car_lv_fight = car_lv_fight , eqpt_lv_fight = eqpt_lv_fight , pipei_fight_range = pipei_fight_range }
end

---- 通过战斗力 获得车辆的升级 装备数据
function LF.get_car_and_eqpt_data_by_fight( _fight )
	local car_base_data = {}
	local eqpt_data = {}

	local pvp_fight_config = LF.get_pvp_fight_config()

	local tar_fight = _fight + math.random( -pvp_fight_config.pipei_fight_range-200 , pvp_fight_config.pipei_fight_range )

	----- 通过目标战斗力，转换成 车辆的等级 和 装备
	local tar_car_id = math.random( 2 )
	local tar_car_level = 0
	local tar_car_star = 0
	local tar_eqpt_data = {}

	---- 多出来的战力
	local more_fight = tar_fight - pvp_fight_config.init_fight
	print("xxx-----------get_car_and_eqpt_data_by_fight 1:" , tar_fight , more_fight)
	if more_fight > 0 then
		local max_car_level = math.floor( more_fight / pvp_fight_config.car_lv_fight )
		---- 车等级最大为 n 级
		max_car_level = math.min( max_car_level , 30 )

		tar_car_level = (max_car_level > 0) and math.random( 1 , max_car_level ) or 1

		print("xxx-----------get_car_and_eqpt_data_by_fight 1:" , tar_fight , more_fight , tar_car_level)

		more_fight = more_fight - tar_car_level * pvp_fight_config.car_lv_fight

		if more_fight > pvp_fight_config.eqpt_lv_fight then
			for i = 1 , 4 do

				if more_fight <= 0 then
					break
				end

				local max_eqpt_level = math.floor( more_fight / pvp_fight_config.eqpt_lv_fight )
				max_eqpt_level = math.min( max_eqpt_level , 40 )

				local tar_level = (max_eqpt_level > 0) and math.random( 1 , max_eqpt_level ) or 1
				if i == 4 and (max_eqpt_level > 0) then
					tar_level = max_eqpt_level
				end

				more_fight = more_fight - tar_level * pvp_fight_config.eqpt_lv_fight

				tar_eqpt_data[i] = {
					no = i , 
					id = math.random( 4 ) ,
		            level = tar_level,
		            star = 0 ,
				}
			end
		end

	end

	-----------------------
	car_base_data.car_id = tar_car_id
	car_base_data.level = tar_car_level
	car_base_data.star = tar_car_star

	eqpt_data = tar_eqpt_data

	local car_fujia_data = PUBLIC.get_drive_in_room_car_fujia_data( car_base_data.car_id , { base_car_data = car_base_data , equipment_data = eqpt_data } )

	return car_base_data.car_id , car_fujia_data
end

-- 得到战斗力数值
function LF.get_player_car_fight(_car_id)

    -- 战斗力 等级权重 配置
    local _pvp_init_fight = skynet.getcfgi("pvp_int_fight",1400)
    local _pvp_car_level_fight = skynet.getcfgi("pvp_car_level_fight",100)
    local _pvp_eqpt_level_fight = skynet.getcfgi("pvp_eqpt_level_fight",25)


    local _car = DATA.car_base_lib.get_car_data(_car_id)
    local _eqpts = DATA.car_equipment_lib.get_car_all_equipment_data(_car_id)

    local _fight = _pvp_init_fight + _car.level * _pvp_car_level_fight
    for _,_d in pairs(_eqpts) do
        _fight = _fight + _d.level * _pvp_eqpt_level_fight
    end

    return _fight
end

function REQUEST.pvp_signup(self)
	local ret = {}
	if not self.id or type(self.id)~="number" then
		return {result=1001}
	end

    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx REQUEST.pvp_signup::",basefunc.tostring({self,my_id=DATA.my_id}))

    -- 处理 托管报名
    LF.deal_tuoguan_signup(self)

	if not self.car_id or type(self.car_id) ~= "number" then
		return {result=1001}
	end

	---- 操作限制
	if PUBLIC.get_action_lock( "pvp_signup" ) then
		return {result=1008}
	end
	PUBLIC.on_action_lock( "pvp_signup" )

	---- 判断如果已经报名了
	if DATA.game_lock then
		ret.result = 1005
		PUBLIC.off_action_lock( "pvp_signup" )
		return ret
	end

	local is_robot=nil
	if not basefunc.chk_player_is_real(DATA.my_id) then
		is_robot=true
	end
	------------------------------------------ ↓↓ 判断参与 限制 条件 ↓↓ ---------------------------------
	if not is_robot then
		local is_can_do , error_des = PUBLIC.judge_permission_is_work_for_agent( "pvp_game_" .. self.id )

		if not is_can_do then
			----处理错误信息
			CMD.notify_client_permission_error_desc( error_des )
			PUBLIC.off_action_lock( "pvp_signup" )
			return {result = -666}
		end
	end
	------------------------------------------ ↑↑ 判断参与 限制 条件 ↑↑ ---------------------------------

	----- 如果已经完成咯新手引导
	if self.id < 0 and basefunc.chk_player_is_real( DATA.my_id ) then
		local ext_status = skynet.call(DATA.service_config.data_service,"lua","query_player_ext_status", DATA.my_id , "xsyd_complete_status_" .. self.id )
		local s = ext_status or {status=0,time=0}
		if s.status == 1 then
			PUBLIC.off_action_lock( "pvp_signup" )
			return {result = 8008}
		end
	end


	local signup_service_id=LF.get_signup_service_id(self.id)

	local signup_assets

	---- 判断 车辆是否拥有
	local car_fujia_data = self.car_fujia_data or PUBLIC.get_drive_in_room_car_fujia_data( self.car_id )
	if type(car_fujia_data) == "number" then
		PUBLIC.off_action_lock( "pvp_signup" )
		return {result = 6401}
	end

	--请求进入条件
	local _result,_data=nodefunc.call(signup_service_id,"get_enter_info")

	if _result=="CALL_FAIL" then

		LF.free_game()
		PUBLIC.off_action_lock( "pvp_signup" )
		return {result=1000}

	elseif _result == 0 then

		LD.game_name = LD.game_model .. "_" .. _data.game_type

		if not PUBLIC.lock(LD.game_name,LD.game_name,self.id) then
			PUBLIC.off_action_lock( "pvp_signup" )
			return {result=1005}
		end

		PUBLIC.ref_agent(LD.game_name)

		--验证所需财务
		local ver_ret = PUBLIC.asset_verify(_data.condi_data)
		if ver_ret.result == 0 then
			signup_assets=_data.condi_data
		else
			PUBLIC.off_action_lock( "pvp_signup" )
			LF.free_game()
			return {
				result=ver_ret.result,
				game_id=self.id
			}
		end

	else
		PUBLIC.off_action_lock( "pvp_signup" )
		LF.free_game()
		return {result=_result}
	end

	local _result=nodefunc.call(signup_service_id,"player_signup"
											,{
												id = DATA.my_id,

                                                -- by lyx 托管 一对一匹配
                                                pvp_real_user_id = self.pvp_game_info and self.pvp_game_info.pvp_real_user_id, 

                                                -- by lyx 2021-6-3 , 临时代码
                                                fight = basefunc.chk_player_is_real(DATA.my_id) and LF.get_player_car_fight(self.car_id) or nil , --  战斗力
                                                pvp_score = LD.duanwei_data.score, -- 段位赛积分
                                                pvp_grade = LD.duanwei_data.grade, -- 段位赛 大阶级
                                                pvp_level = LD.duanwei_data.level, -- 段位赛 小段位
											})
	if _result=="CALL_FAIL" then
		LF.free_game()
	elseif _result and _result.result==0 then

		_result.game_type = _data.game_type
		_result.game_mode = _data.game_mode
		_result.game_id=self.id
		_result.map_id = _data.map_id

		--_result.car_id = self.car_id
		_result.car_id = self.car_id
		_result.car_fujia_data = car_fujia_data

		_result.signup_service_id = signup_service_id
		_result.signup_assets=signup_assets
		
		LF.new_game(_result)

		PUBLIC.off_action_lock( "pvp_signup" )
		return _result
	else

		LF.free_game()
		if _result then
			PUBLIC.off_action_lock( "pvp_signup" )
			return _result
		end
	end

	PUBLIC.off_action_lock( "pvp_signup" )
	return {result=1000}
end

function REQUEST.pvp_quit_game()
	local ret = {}

	--- 没有报名 不能退出
	if not LD.all_data then
		ret.result = 1004
		--PUBLIC.off_action_lock( "pvp_quit_game" )
		return ret
	end

	---- 新手引导的场次不能 取消匹配
	if LD.all_data.room_info.game_id < 0 and LD.all_data.status == LD.pvp_status.wait_table then
		ret.result = 1002
		--PUBLIC.off_action_lock( "pvp_quit_game" )
		return ret
	end

	---- 检查 状态
	if LD.all_data.status ~= LD.pvp_status.wait_table 
		and LD.all_data.status ~= LD.pvp_status.wait_ready 
		and LD.all_data.status ~= LD.pvp_status.game_over
		and LD.all_data.status ~= LD.pvp_status.settlement then
			ret.result = 1002
		--print("xxxx-------pvp_quit_game 1:" , LD.all_data.status)
			return ret
	end

	---- 操作限制
	if PUBLIC.get_action_lock( "pvp_quit_game" ) then
		return {result=1008}
	end
	PUBLIC.on_action_lock( "pvp_quit_game" )

	ret.result = 0
	
	local ret = nodefunc.call(LD.all_data.match_info.signup_service_id,"player_exit_game",DATA.my_id)
	--print("xxxx-------pvp_quit_game 2:" , ret.result )
	if ret=="CALL_FAIL" then
		ret.result=1000
		PUBLIC.off_action_lock( "pvp_quit_game" )
		return ret
	end	

	if ret.result ~= 0 then
		PUBLIC.off_action_lock( "pvp_quit_game" )
		return ret
	end

	LF.free_game()
	
	PUBLIC.off_action_lock( "pvp_quit_game" )
	return ret
end

---- 投降
function REQUEST.pvp_surrender_game()
	local ret = {}

	if not LD.all_data or not LD.all_data.gameInstance then
		ret.result = 1004
		PUBLIC.off_action_lock( "pvp_surrender_game" )
		return ret
	end

	---- 操作限制
	if PUBLIC.get_action_lock( "pvp_surrender_game" ) then
		return {result=1008}
	end
	PUBLIC.on_action_lock( "pvp_surrender_game" )

	ret.result = 0

	----- 调用  游戏实体的  投降
	if LD.all_data.gameInstance then
		local ret_code = LD.all_data.gameInstance.surrender_game()
		ret.result = ret_code
	end

	PUBLIC.off_action_lock( "pvp_surrender_game" )
	return ret
end

---- 获得游戏 实体的 数据信息
function LF.get_game_status_info(_data)
	if LD.all_data and _data then
		local tar_data = nil
		if LD.all_data.gameInstance then
			tar_data = LD.all_data.gameInstance.get_status_info()
		end
		local gta = GAME_TYPE_AGENT[LD.all_data.game_type]
		local gap = GAME_AGENT_PROTO[gta]
		_data[gap] = tar_data -- LD.all_data.game_data
	end
end

function REQUEST.pvp_all_info_req()
	local ret = {}

	--- 操作限制
	if PUBLIC.get_action_lock( "pvp_all_info_req" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "pvp_all_info_req" )

	if not LD.all_data then
		ret.result = -1
		PUBLIC.off_action_lock( "pvp_all_info_req" )
		return ret
	end

	ret.result = 0
    ret.status_no = LD.all_data.status_no
    ret.status = LD.all_data.status
    ret.game_type = LD.all_data.game_type
    ret.room_info = LD.all_data.room_info
    ret.players_info = LD.all_data.players_info

    --## 游戏数据
    --nor_drive_game_info $ : drive_game_all_data
    LF.get_game_status_info(ret)

	PUBLIC.off_action_lock( "pvp_all_info_req" )
	return ret
end

----------- 调了报名之后，玩家在队列中等待匹配，如果匹配成功，会从  匹配中心  调到这里。
function CMD.pvp_enter_room_msg(_room_id , _t_num , _seat_num) 

	if not LD.all_data then
		return false
	end

	---- 房间信息
	LD.all_data.room_info.room_id = _room_id
	LD.all_data.room_info.t_num = _t_num
	
	if not LD.all_data.gameInstance then 
		error("pvp_enter_room_msg error" .. _room_id)
		return false
	end
	
	--扣房费
	CMD.change_asset_multi(LD.all_data.deduct_assets,ASSET_CHANGE_TYPE.PVP_GAME_SIGNUP,LD.all_data.room_info.game_id)
	
	LD.all_data.gameInstance.init(LD.all_data)

	LD.auto_quit_game_time = nil

	--加入房间
	LD.all_data.gameInstance.join_room({
								seat_num = _seat_num,
								id = DATA.my_id,
								name = DATA.player_data.player_info.name,
								head_link = DATA.player_data.player_info.head_image,
								sex = DATA.player_data.player_info.sex,
								car_id = LD.all_data.car_id ,
								duanwei_grade = LD.duanwei_data.grade ,

								car_fujia_data = LD.all_data.car_fujia_data ,
							})

	return true
end



----- 从 具体游戏 调到这里， 别的玩家 加入房间 的处理
function LF.player_join_msg(_info)
	LF.add_p_info(_info)

	LF.add_status_no()
	--通知客户端
	PUBLIC.request_client("pvp_join_msg",{status_no = LD.all_data.status_no ,player_info=_info})
end

-----从 具体游戏 调到这里， 自己的 加入房间 的处理
function LF.my_join_return(_data)

	LD.all_data.status = LD.pvp_status.wait_ready

	if _data.p_info then
		dump(_data.p_info , "xxxx--------------------my_join_return__p_info")
		LF.update_p_info( _data.p_info )
	end

	--通知客户端
	local players_info = basefunc.deepcopy(LD.all_data.players_info)

	LF.add_status_no()

	PUBLIC.request_client("pvp_enter_room_msg",{
							status_no = LD.all_data.status_no ,
							seat_num=LD.all_data.room_info.seat_num,
							players_info=players_info,
							room_info=LD.all_data.room_info,
							})

	--自动ready ； 玩家进入房间之后，直接ready
	LD.all_data.gameInstance.ready()
end

function LF.game_ready_ok_msg()
	LD.all_data.status = LD.pvp_status.gaming
end

---- 从 manager 中心调过来
function CMD.pvp_gameover_msg()
	LD.all_data.status = LD.pvp_status.game_over

	LD.auto_quit_game_time = os.time() + LD.auto_quit_game_cd

	LF.add_status_no()
	PUBLIC.request_client("pvp_game_over_msg",
							{
								status_no = LD.all_data.status_no,
								status = LD.all_data.status,
							})

end

-- by lyx  刷新 计算连续输赢状态
function LF.update_hold_win_status(_win)

    -- 新的输赢状态
    local _w_status = _win > 0 and 1 or _win < 0 and -1 or 0

    if _w_status == LD.win_status then
        LD.hold_count = LD.hold_count + 1
    else
        LD.win_status = _w_status
        LD.hold_count = 1
    end
end

function REQUEST.pvp_duanwei_get_data(self)

    local ret = {
        result = 0,
        score = LD.duanwei_data.score,
        grade = LD.duanwei_data.grade,
        level = LD.duanwei_data.level,
        grade_all_level = LD.duanwei_progress.grade_all_level,
        level_all_score = LD.duanwei_progress.level_all_score,
        level_cur_score = LD.duanwei_progress.level_cur_score,
    }

    return ret
end


function REQUEST.pvp_duanwei_get_award_list(self)

    local _awards = skynet.call(DATA.service_config.duanwei_data_center,"lua","get_duanwei_untake_awards_list",
        DATA.my_id,LD.duanwei_data.grade,LD.duanwei_data.level)

    return {
        result = 0,
        award = _awards,
    }
end

function REQUEST.pvp_duanwei_take_award(self)

    if self.grade > LD.duanwei_data.grade then
        return {
            result=1001
        }
    end
    if self.grade == LD.duanwei_data.grade then
        if self.level > LD.duanwei_data.level then
            return {
                result=1003
            }
        end
    end

    local _awards,_code = skynet.call(DATA.service_config.duanwei_data_center,"lua","add_player_awards_store",
                DATA.my_id,self.grade,self.level,self.asset_type)

    print("pvp_duanwei_take_award call add_player_awards_store result:",basefunc.tostring({_awards,_code}))

    if not _awards then
        return {
            result=_code
        }
    end

    if _awards and next(_awards) then
        CMD.change_asset_multi(PUBLIC.assets_proto2change(_awards),ASSET_CHANGE_TYPE.PVP_UP_DUANWEI_AWARD,self.grade,self.level,self.asset_type)
    end

    return {
        result = 0,
        award = _awards
    }
end

-- 新手引导的 发奖处理
function LF.xsyd_fajiang(_data)
	LD.all_data.status = LD.pvp_status.settlement

    -- by lyx 2021-6-3 : 处理段位赛积分  （临时代码）
    local _win = _data.award[LD.all_data.room_info.seat_num] or 0

    --local _up_award = nil
    local _fight_award = nil

    -- by lyx
    local old_score = LD.duanwei_data.score
    local old_grade = LD.duanwei_data.grade
    local old_level = LD.duanwei_data.level
    local old_cur_score = LD.duanwei_progress.level_cur_score
    
    if _win and basefunc.chk_player_is_real( DATA.my_id ) then
    	
		skynet.send(DATA.service_config.data_service,"lua","update_player_ext_data",DATA.my_id ,"xsyd_complete_status_" .. LD.all_data.room_info.game_id , 1 )

		---- 发奖励 ， 给一个固定宝箱
		if LD.all_data.room_info.game_id == -1 then
            _fight_award = {
                {
                    asset_type = "bao_xiang",
                    asset_value = 4,
                }
            }
			PUBLIC.add_one_timer_box( 4 )
		end

        -- by lyx
        local _pvp_award,_code = skynet.call(DATA.service_config.duanwei_data_center,"lua","settlement_fight_award",DATA.my_id,LD.duanwei_data,1,1)
        if not _pvp_award then
            fault("call settlement_fight_award error:",basefunc.tostring({myid=DATA.my_id,param={LD.duanwei_data,LD.win_status,LD.hold_count},retcode=_code}))
            return
        end

        basefunc.merge(_pvp_award.duanwei,LD.duanwei_data)
        LD.duanwei_progress = _pvp_award.progress

    end

    PUBLIC.request_client("pvp_game_settlement_msg",
        {
        	status_no = LD.all_data.status_no,
            score = LD.duanwei_data.score,
            change_score = LD.duanwei_data.score - old_score ,
            grade = LD.duanwei_data.grade,
            change_grade = LD.duanwei_data.grade  - old_grade ,
            level = LD.duanwei_data.level,
            change_level = LD.duanwei_data.level  - old_level ,
            grade_all_level = LD.duanwei_progress.grade_all_level,
            level_all_score = LD.duanwei_progress.level_all_score,
            level_cur_score = LD.duanwei_progress.level_cur_score,

            change_level_cur_score = LD.duanwei_progress.level_cur_score - old_cur_score ,

            up_award = {},
            win_status = LD.win_status,
            hold_count = LD.hold_count,

            fight_award = _fight_award,
        })
end

-- by lyx 2021-6-3 : 计算段位， （临时实现）
-- 返回  大阶段， 小阶段
-- function LF.calc_duanwei_grade(_score)
--     return math.floor(_score / 500) + 1,math.floor((_score % 500)/100) + 1
-- end
-----
function LF.game_settlement_msg(_data)

    -- 新手引导 特殊处理
	if LD.all_data.room_info.game_id < 0 then
		LF.xsyd_fajiang(_data)
		return 
	end

	LD.all_data.status = LD.pvp_status.settlement

    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx game_settlement_msg 111:",basefunc.tostring(_data))
	
    -- by lyx 2021-6-3 : 处理段位赛积分  （临时代码）
    local _win =  _data.award[LD.all_data.room_info.seat_num] or 0
    LF.update_hold_win_status(_win)

    local _up_award = nil
    local _fight_award = nil

    local old_score = LD.duanwei_data.score
    local old_grade = LD.duanwei_data.grade
    local old_level = LD.duanwei_data.level
    local old_cur_score = LD.duanwei_progress.level_cur_score

    --print("xxx-------------------game_settlement_msg 1 :" , _win)
    if _win ~= 0 then

        local _pvp_award,_code = skynet.call(DATA.service_config.duanwei_data_center,"lua","settlement_fight_award",DATA.my_id,LD.duanwei_data,LD.win_status,LD.hold_count)
        if not _pvp_award then
            fault("call settlement_fight_award error:",basefunc.tostring({myid=DATA.my_id,param={LD.duanwei_data,LD.win_status,LD.hold_count},retcode=_code}))
            return
        end

    	--print("xxx-------------------game_settlement_msg 2")
        --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx game_settlement_msg 222:",basefunc.tostring(_pvp_award))

        _up_award = _pvp_award.up_award

        -- 战斗奖励 暂时 只支持一个
        if _pvp_award.fight_award and _pvp_award.fight_award[1] then

            local _add_asset = nil

            for _,v in ipairs(_pvp_award.fight_award) do
                if v.asset_type == "bao_xiang" then -- 宝箱特殊处理
                    local _code = PUBLIC.add_one_timer_box(v.asset_value) --skynet.call(DATA.service_config.timer_box_center_service,"lua","add_one_box_data",DATA.my_id,v.asset_value)
                    if 0 == _code then
                        _fight_award = _fight_award or {}
                        table.insert(_fight_award,basefunc.deepcopy(v))
                    else
                        print("pvp game game_settlement_msg add_one_box_data error:",_code)
                    end
                else
                    _fight_award = _fight_award or {}
                    table.insert(_fight_award,basefunc.deepcopy(v))

                    _add_asset = _add_asset or {}
                    --for _,_ass in ipairs(v) do
                        table.insert(_add_asset,{
                            asset_type=v.asset_type,
                            value=v.asset_value,
                        })
                    --end
                end
            end

            if _add_asset then
                CMD.change_asset_multi(_add_asset,ASSET_CHANGE_TYPE.PVP_FIGHT_AWARD,0,0,0,true)
            end
        end

        basefunc.merge(_pvp_award.duanwei,LD.duanwei_data)
        LD.duanwei_progress = _pvp_award.progress

        skynet.send(DATA.service_config.duanwei_data_center,"lua","update_duanwei_data",DATA.my_id,LD.duanwei_data)
        
        LF.add_status_no()

        
    end


    PUBLIC.request_client("pvp_game_settlement_msg",
        {
        	status_no = LD.all_data.status_no,
            score = LD.duanwei_data.score,
            change_score = LD.duanwei_data.score - old_score ,
            grade = LD.duanwei_data.grade,
            change_grade = LD.duanwei_data.grade  - old_grade ,
            level = LD.duanwei_data.level,
            change_level = LD.duanwei_data.level  - old_level ,
            grade_all_level = LD.duanwei_progress.grade_all_level,
            level_all_score = LD.duanwei_progress.level_all_score,
            level_cur_score = LD.duanwei_progress.level_cur_score,

            change_level_cur_score = LD.duanwei_progress.level_cur_score - old_cur_score ,

            up_award = _up_award,
            win_status = LD.win_status,
            hold_count = LD.hold_count,

            fight_award = _fight_award,
        })


end

function LF.init()

    -- 初始化段位信息
    LD.duanwei_data = skynet.call(DATA.service_config.duanwei_data_center,"lua","get_duanwei_data",DATA.my_id)
    LD.duanwei_progress = skynet.call(DATA.service_config.duanwei_data_center,"lua","calc_duanwei_progress",
            LD.duanwei_data.score,LD.duanwei_data.grade,LD.duanwei_data.level)

end


function LF.un_init()

end

return LF

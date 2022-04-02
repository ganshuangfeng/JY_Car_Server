---- pvp 的游戏 逻辑

local skynet = require "skynet_plus"
local base = require "base"

local basefunc = require "basefunc"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

---- agent 过来的消息
local MSG = DATA.MSG

DATA.model_pvp_protect = {}
local C = DATA.model_pvp_protect

---- 具体的游戏实体
C.game_instance = nil

C.dt = 0.2

---- 
C.updater = nil

C.status_enum = {
	signup = {},      --- 
	gaming = {},      ---
	game_over = {},
}

C.game_over_quit_delay = 10 --60

for status_name , data in pairs(C.status_enum) do
	data.name = status_name
end

---- 当前状态 信息
C.now_status_data = { now_status = nil }

--- 开始 游戏
function C.start_game()
	
	---- 具体游戏实体
	C.game_instance = require ( TUOGUAN_GAME[ DATA.game_info.game_type ] )

	C.game_instance.start_game()

	if C.updater then
		C.updater:stop()
		C.updater = nil
	end

	C.updater = skynet.timer( C.dt , function() C.update(C.dt) end )

	----- 设置状态为 报名状态
	C.change_status( C.status_enum.signup )
end

---- 销毁时调用
function C.destroy()
	if C.updater then
		C.updater:stop()
		C.updater = nil
	end
	
	if C.game_instance and C.game_instance.destroy then
		C.game_instance.destroy()
	end
end

function C.update(_dt)

	local cur_status = C.now_status_data.now_status
	if cur_status and cur_status.on_update then
		cur_status.on_update(_dt)
	end

end

---- 改变状态
function C.change_status( _status )
	local cur_status = C.now_status_data.now_status

	---- 先退出当前的状态
	if cur_status and cur_status.on_end then
		cur_status.on_end()
	end

	C.now_status_data.now_status = _status
	cur_status = C.now_status_data.now_status

	if cur_status and cur_status.on_begin then
		cur_status.on_begin() 
	end


end

----------------------------------------------------------- 状态处理 ↓ ------------------------------------------------------------
function C.status_enum.signup.on_begin()

    -- 根据 DATA.game_info 中的信息准备车辆 和 自己的段位
    local tar_car_id = math.random(2)
    if DATA.game_info.game_id == -1 then
    	tar_car_id = 1
    end

    --tar_car_id = 2

	----- 开始就报名
    local _signdata = { 
        id = DATA.game_info.game_id , 
        car_id = tar_car_id,

        -- by lyx： 托管呼叫信息， 回传给 agent ，用于 调整积分和选择出战车辆
        pvp_game_info = DATA.game_info, 
    } 

	local ret = PUBLIC.request_agent( "pvp_signup" ,_signdata )

    print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx signup.on_begin::",basefunc.tostring({_signdata,tg_uid=DATA.player_id}))

	dump( ret , "xxxxx---------signup__ret:" )

	---- 如果报名失败的话，就退出agent
	if ret.result ~= 0 then

		PUBLIC.quit_game()

	end

end

---- 游戏结束，
function C.status_enum.game_over.on_begin()

	------ 倒计时 退出
	skynet.timeout( C.game_over_quit_delay * 100 , function() 

		local ret = PUBLIC.request_agent( "pvp_quit_game" , { } )
		--dump( ret , "xxxxx---------game_over__ret:" )
		---- 
		if ret.result == 0 then

			PUBLIC.quit_game()

		end

	end )

	

end

----------------------------------------------------------- 状态处理 ↑ ------------------------------------------------------------

----------------------------------------------------------- agent 消息处理 ↓ ------------------------------------------------------------
---- 自动退出
function MSG.pvp_auto_quit_game(_data)
	if _data and _data.result == 0 then
		--- 退出游戏
		PUBLIC.quit_game()

	end
end

---- 游戏结束，退出游戏
function MSG.pvp_game_over_msg(_data)
	--- 退出游戏
	C.change_status( C.status_enum.game_over )
end


----------------------------------------------------------- agent 消息处理 ↑ ------------------------------------------------------------
return C

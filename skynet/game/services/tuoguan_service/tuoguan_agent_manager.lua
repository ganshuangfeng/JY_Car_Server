--
--[[
	托管分为  自由托管 + 分类托管 ；  每个   分类托管   都保持着一定量的 tuoguan_agent  ； 请求托管时，会根据请求信息 来确定是从分类托管还是自由托管来的。

--]]

-- Author: lyx
-- Date: 2018/10/9
-- Time: 15:14
-- 说明：托管 agent 管理器
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require"printfunc"
require "tuoguan_service.tuoguan_enum"
local nodefunc = require "nodefunc"
local cjson = require "cjson"

--local schedule = require "tuoguan_service.tuoguan_schedule"
local schedule = require "tuoguan_service.tuoguan_schedule_duanwei"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC

local node_name = skynet.getenv("my_node_name")

DATA.tuoguan_agent_manager_protect = {}
local PROTECTED = DATA.tuoguan_agent_manager_protect

---- ai 处理模块 , key = game_type , value = logic_module
PROTECTED.ai_logic_module = {}

local function default_Data()
    return
    {
		-- 托管用户 id 池 ,  自由的托管 的 基础数据池 (未分级的托管数据)
		tuoguan_user_pool = nil,
		---- 冷却 回收池
		cooling_user_pool = basefunc.queue.new(),  -- 冷却中： time , user_data

		-- 托管 agent , 已经创建出来的托管agent （包括保持在 分类托管中常驻托管 和 创出来的自由托管 ） ： player_id => <数据>
		-- <数据> ： {tg_agent_id=,login_id=,grade=,gaming=true/false}
		-- 说明： tg_agent 一定是 和 player_agent 成对的
		-- 		 grade 由 schedule 使用
		tuoguan_agents = {},

		-- 游戏中的托管对象数量
		tuoguan_gaming_count = 0,
		---- 正在创建的 托管数量
		tuoguan_creating_count = 0,

		update_timer = nil,

		assign_tuoguan_player_start = false,
	}
end

DATA.tg_man_data = DATA.tg_man_data or default_Data()
local D = DATA.tg_man_data

---- 回收 托管原始数据
function PUBLIC.recycle_user_data(_user_data)
	---- 如果分类托管未回收，就直接回收
	if not schedule.recycle_user_data(_user_data) then -- schedule 也许会回收
		D.tuoguan_user_pool[#D.tuoguan_user_pool + 1] = _user_data
		print("manaa PUBLIC.recycle_user_data manager :",_user_data and _user_data.id,#D.tuoguan_user_pool,"gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size())
	end
end

function PROTECTED.update(dt)
	while (not D.cooling_user_pool:empty()) and
		(os.time() - D.cooling_user_pool:front().time) >= 2 do
		PUBLIC.recycle_user_data(D.cooling_user_pool:pop_front().user_data)
	end
end

----- 释放托管，
function PUBLIC.free_tg_agent(_player_id)

	local _tg_data = D.tuoguan_agents[_player_id]
	if not _tg_data then
		print(string.format("tuoguan player '%s' not found!",_player_id))
		return
	end

	-- 回收 托管 资源：经过 池 冷却
	D.cooling_user_pool:push_back( { time = os.time() , user_data = _tg_data.user_data } )

	print("manaa manager free_tg_agent  :",_tg_data.player_id,_tg_data.user_data and _tg_data.user_data.dbg_id,_tg_data.gaming,"gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size())

	if _tg_data.gaming then
		D.tuoguan_gaming_count = D.tuoguan_gaming_count - 1
	end
	D.tuoguan_agents[_player_id] = nil

end

-- 托管 agent 退出了（注销登录 , 从登陆服务调过来）
function CMD.tuoguan_agent_kicked(_player_id)
	print("manaa manager tuoguan_agent_kicked  :","gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size(),_player_id)
	PUBLIC.free_tg_agent(_player_id)
end

------ 载入 托管的 原始信息 ，
function CMD.load_tuoguan_id_pool()

	local tuoguan_file = skynet.getcfg "tuoguan_list"
	if not tuoguan_file then
		error("not found tuoguan_file config !")
	end
	----- 由于是 用require 放入了 package.loaded 中，所以后面取一个托管数据之后删除，之后拿到的数据就是已经排除过之前取出的数据的集合。
	local ret = require(tuoguan_file)

	if not ret then
		error("load tuoguan file error : " .. tostring(tuoguan_file))
	end
    
    if skynet.getcfg("tuoguan_name_as_youke")  then
        for _,v in ipairs(ret) do
        	local old_index = v.index
            v.name = "游客" .. tostring(math.random(999,9999))
            v.json = nil
            v.index = nil
            v.json = cjson.encode(v)
            v.index = old_index
        end
    end

	return ret
end

-- 重置所有托管数据（托管 agent 已经崩坏）
function CMD.reload_tuoguan_data()

	PROTECTED.init(true)
end

function PROTECTED.init()

    schedule.init()

	---- 载入托管的原始数据
	local _pool = CMD.load_tuoguan_id_pool()

	------free_tuoguan_count 表示 自由的托管（不限于入场范围）
    --- （注意： 这段逻辑改了 "free_tuoguan_count" 配置 不起作用了）
	--local _free_tuoguan_count  = skynet.getcfg("free_tuoguan_count") or 20

	----- * 表示托管数据，全部都不分类
	-- if _free_tuoguan_count == "*" then
	-- 	D.tuoguan_user_pool = _pool
	-- else

		---- 处理 托管分类
        local _sc_count = skynet.getcfgi("tuoguan_group_count",50)
        local _sc_size = skynet.getcfgi("tuoguan_group_size",60)
		schedule.set_tg_user_pool(_pool,_sc_count,_sc_size)

		-- 一部分不分级（注意： 这段逻辑改了 "free_tuoguan_count" 配置 不起作用了）
		D.tuoguan_user_pool = {}
		for i=_sc_count * _sc_size + 1,#_pool do
			D.tuoguan_user_pool[#D.tuoguan_user_pool + 1] = _pool[#_pool]
			_pool[#_pool] = nil
		end

	-- end

	D.update_timer = skynet.timer(1,function(...) PROTECTED.update(...) end )

	print("tuoguan manager init count:",#D.tuoguan_user_pool)
end

--------- 强制 增加 自由 托管数据 （强制增加可能会和 分类托管的数据有重合）
function CMD.force_extend_free(_free)

    _free = math.floor((tonumber(_free) or 0)+0.5)

    ----- 获取 剩余的 托管的原始数据
    local _pool = CMD.load_tuoguan_id_pool()

    local _add_count = 0

    if _free > 0 then
        for i=1,_free do

            if _pool[1] then
                D.tuoguan_user_pool[#D.tuoguan_user_pool + 1] = _pool[#_pool]
                _pool[#_pool] = nil

                _add_count = _add_count + 1
            else
                break
            end
		end
    end

    return "tuoguan add count:" .. tostring(_add_count) .. ",remain:" .. tostring(#_pool)
end

D.last_tg_index = D.last_tg_index or 0
function PUBLIC.create_tg_agent_id()

	D.last_tg_index = D.last_tg_index + 1

	return "tuoguan_agent_" .. D.last_tg_index
end

function PUBLIC.pop_tuoguan_user_data(_debug_src)

    local ret = basefunc.random_pop(D.tuoguan_user_pool)

    local _dbgid = "nil"
    if ret then
        DATA._tg_agent_debug = (DATA._tg_agent_debug or 0) + 1
        ret.dbg_id="tg_dbgid_" .. tostring(DATA._tg_agent_debug)
    end

    print("manaa PUBLIC.pop_tuoguan_user_data:",#D.tuoguan_user_pool,"gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size(),ret and ret.dbg_id,ret and ret.id,tostring(_debug_src))

	if not D.tuoguan_user_pool[1] then
		print("pop_tuoguan_user_data error,is nil!")
    end

    return ret
end

-- 新建一个 托管 agent
function PUBLIC.create_tuoguan_agent(_user_data,_debug_src)

	-- 取出 login_id
	local _user_data = _user_data or PUBLIC.pop_tuoguan_user_data(_debug_src)

	if not _user_data then
		print("create tuoguan agent error: tuoguan user data use out!")
		return nil
	end
	-- 创建 托管 agent

    local tg_id = PUBLIC.create_tg_agent_id()

    local _time = os.time()

	local ok,tg_result = skynet.call(DATA.service_config.node_service,"lua","create",nil,
                            "tuoguan_service/tuoguan_agent", tg_id , _user_data )

    print("manaa create tuoguan agent :",os.time()-_time,#D.tuoguan_user_pool,"gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size(),
        _user_data and _user_data.dbg_id,tg_result and type(tg_result)=="table" and tg_result.player_id or tg_result)

	if not ok then

		-- 归还托管 资源
		D.cooling_user_pool:push_back( { time = os.time() , user_data = _user_data } )

		print(string.format("create tuoguan agent error: %s,%s!",tostring(tg_result),basefunc.tostring(_user_data)))
		return nil
	end

	-- 出错
	if not tg_result then

		-- 退出 tuoguan agent
		nodefunc.send(tg_id,"exit_client")

		-- 归还托管 资源
		D.cooling_user_pool:push_back({ time = os.time() , user_data = _user_data})

		print(string.format("start tuoguan agent return nil,tg agent id: %s,%s!",tostring(tg_id),basefunc.tostring(_user_data)))
		return nil
	end

	local _tg_data = {
		user_data = _user_data,
		player_id = tg_result.user_id,
		player_data = tg_result,
		tg_agent_id = tg_id,
		gaming = false,
		vip_adjust_count = 0, -- vip 调整次数,用于：默认 vip0 如果满足分组条件，则需要调整一次，避免所有的都在 vip0
	}

	D.tuoguan_agents[tg_result.user_id] = _tg_data

	return _tg_data
end

-- 当前活跃的托管玩家数量
function CMD.tuoguan_gaming_count()
	print("D.tuoguan_gaming_count :",D.tuoguan_gaming_count)
	return D.tuoguan_gaming_count
end

-- 指派指定类型和托管玩家到 给定的服务
function CMD.assign_tuoguan_player(_count,_game_info)

    print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx assign_tuoguan_player:",basefunc.tostring(_game_info))

	if skynet.getcfg("forbid_tuoguan_manager") then
		return
	end

	-- 等待初始化ok 才能开始请求托管
	if not skynet.getcfg("is_server_launched") then
		return
	end

    if not D.assign_tuoguan_player_start then
        D.assign_tuoguan_player_start = true
        print("assign_tuoguan_player start...")
	end

	local _max_count = skynet.getcfg("tuoguan_max_count") or 100

	if (D.tuoguan_creating_count + D.tuoguan_gaming_count) >= _max_count then
		print("CMD.assign_tuoguan_player,count too much:",D.tuoguan_creating_count , D.tuoguan_gaming_count,_max_count)
		return
	end

	if not TUOGUAN_GAME[_game_info.game_type] then
		print("CMD.assign_tuoguan_player,not support game type:",_game_info.game_type)
		return
	end

	print("CMD.assign_tuoguan_player:",_count)

	skynet.fork(function()

		for i=1,_count do

			if (D.tuoguan_creating_count + D.tuoguan_gaming_count) >= _max_count then
				return
			end

			D.tuoguan_creating_count = D.tuoguan_creating_count + 1
			local _tg_data

			local ok,msg = xpcall(function()

                local _time = os.time()

                ---- 自由的托管数据创建，不分类的托管
				if skynet.getcfg("free_tuoguan_count") == "*" then
					_tg_data = PUBLIC.create_tuoguan_agent(nil,"free create 111")
				else
					_tg_data = schedule.pop_tuoguan_agent(_game_info) or  PUBLIC.create_tuoguan_agent(nil,"free create 222")
				end

                print("manaa crate agenet succ:",os.time()-_time,#D.tuoguan_user_pool,"gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size(),
                    _tg_data and _tg_data.user_data and _tg_data.user_data.dbg_id,_tg_data and _tg_data.player_id)

				if not _tg_data then
					print("error: cannt assign_tuoguan player ! ",basefunc.tostring(_game_info))
					return
				end
				if _tg_data.tg_agent_id then

					_time = os.time()
					local ret = nodefunc.call(_tg_data.tg_agent_id,"enter_game",_game_info)
					print("manaa tuoguan enter_game result:",os.time()-_time,ret,#D.tuoguan_user_pool,"gaming",D.tuoguan_gaming_count,"cool:",D.cooling_user_pool:size(),
						_tg_data and _tg_data.user_data and _tg_data.user_data.dbg_id,_tg_data and _tg_data.player_id)

					if "CALL_FAIL" == ret then
						print("error: call tuoguan agent fail ! ",_tg_data.tg_agent_id,basefunc.tostring(_game_info))
						PUBLIC.free_tg_agent(_tg_data.player_id)
					else
						_tg_data.gaming = true
					end
				end
			end,basefunc.error_handle)
			if not ok then
				print("CMD.assign_tuoguan_player error:",msg)
			end

			if _tg_data and _tg_data.gaming then
				D.tuoguan_gaming_count = D.tuoguan_gaming_count + 1
			end
			D.tuoguan_creating_count = D.tuoguan_creating_count - 1
		end
	end)

end

---- 处理 ai 决策
function CMD.deal_ai_logic( _game_type , _decision_name , _game_data , ... )
	if not PROTECTED.ai_logic_module[_game_type] then
		PROTECTED.ai_logic_module[_game_type] = require ( TUOGUAN_AI_MODEL[_game_type] )
		PROTECTED.ai_logic_module[_game_type].init()
	end
	local ai_logic_module = PROTECTED.ai_logic_module[_game_type]

	local ret = ai_logic_module.deal_decision( _decision_name , _game_data , ... )

	return ret
end


return PROTECTED

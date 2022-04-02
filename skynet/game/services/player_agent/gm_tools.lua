--
-- Created by lyx.
-- User: hare
-- Date: 2018/6/8
-- Time: 14:36
-- 商城：管理员工具
--


local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
require "normal_enum"

local error_code = require "error_code"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC = base.PUBLIC
local REQUEST = base.REQUEST

print("gm_tools.lua loaded!!!",DATA.my_id) 

local help_string=[[

★ 给玩家发钱
	give 玩家id,财富类型,财富值,邮件标题,邮件内容
		参数：
			玩家id  ： 玩家 id，一个或多个，例如："10106069",{"10990027","10102157"}
			财富类型： 财富类型("jing_bi" 鲸币,"diamond" 钻石,"shop_gold_sum" 福卡,"room_card" 房卡,"jipaiqi" 记牌器)
			财富值  ： 钱的数量。注意：福卡的单位是 分！
		举例：
			give "10106069","jing_bi",200,"奖励","恭喜你获得 200 鲸币！"
			give {"10990027","10102157"},"shop_gold_sum",300,"奖励","恭喜你获得 300 福卡！"

★ 给玩家发钱 
	money 玩家id,财富类型,财富值 
		例如：
			money "10106069","jing_bi",200
		说明：
			前三个参数 和 give 相同，区别是 不需要收邮件，自动加

★ 给玩家发obj道具 
	obj 玩家id,道具类型,数量,属性
		例如：
			obj "10106069","obj_fish_secondary_bomb",10,{game_id=1,bullet_index=11,rate=200,scene="freestyle"}
		说明：
			只能给单个或多个玩家发送道具

★ 完成支付订单
	pay 订单号
		例如：
			pay "201905140000001gdjid"

★ 给玩家或者所有玩家发送邮件
	email 接收类型,接收数据,接收渠道,接收平台,邮件标题,邮件内容,奖励类型1,奖励数量1,奖励类型2,奖励数量2...
		参数：
			接收类型有 "players","vip","everyone"
			接收数据是表
			接收渠道有 "normal","pceggs"等(nil代表所有)
			接收平台 "normal"等(nil代表所有)
		举例：
			email "players",{"10106069"},"通知","恭喜你进入决赛！","jing_bi",1000
			email "players",{"10990027","10102157"},"通知","恭喜你进入决赛！"
			email "vip",{1,3},"通知","恭喜你进入决赛！","jing_bi",1000,"fish_coin",2000
			email "everyone",{},"通知","恭喜你进入决赛！"

★ 给某个玩家开启n天bbsc权限
	open_bbsc_day_permit 玩家id,开启到第几天
		举例：
		open_bbsc_day_permit "105883",7

★ 给某个玩家的某个任务加进度
	add_task_progress 玩家id,任务id,加的进度
		举例：
		add_task_progress "1013195",8,1

★ 改变上下级
	change_player_relation 玩家id,新上级id,操作人
		举例:
		change_player_relation "1010096","1013137","wss"

★ 开启玩家对的各种收益开关
	set_activate_sczd_profit 玩家id,推广员提现权限,下级玩家奖权限,推广礼包权限,比赛奖权限)
		举例:
		set_activate_sczd_profit "1010052","false","false","false","false"

★ 增加抽奖的分数
 	add_lottery_score 玩家id,抽奖类型,来源类型,增加抽奖的分数
 		举例:
		add_lottery_score "1010052","19_october_lottery","xiaoxiaole_award",100000000000

]]

local function error_handle(msg)
	local _info = string.format("error:\n%s\n%s\n",tostring(msg),debug.traceback())
	print(_info)
	return _info
end	

local gm_cmd = {}


local function parse_lua_line(...)
	local _param = table.pack(...)
	for i=1,_param.n do
		_param[i] = _param[i] and tostring(_param[i]) or ""
	end

	return load("return " .. table.concat(_param),"[gm command param]","bt",{})
end

function gm_cmd.help()
	return help_string
end

function gm_cmd.give(_players,_type,_value,_title,_content)
	
	if not basefunc.is_asset(_type) then
		return "错误：财富类型不正确！"
	end

	if type(_value) ~= "number" then
		return "错误：财富值不正确！"
	end

	if not _players then
		return "错误：玩家 id 不能为 空！"
	end

	if type(_players) == "string" then
		_players = {_players}
	elseif type(_players) == "table" then
		if not next(_players) then
			return "错误：玩家 id 不能为空表！"
		end
	else
		return "错误：没有输入玩家 id！"
	end

	_content = tostring(_content  or "恭喜你获得了{value} {type},尽情享用吧!")
	_content = string.gsub(_content,"\"","\\\"")
	_content = string.gsub(_content,"{value}",tostring(_value))
	_content = string.gsub(_content,"{type}",tostring(_type))

	-- 构造邮件参数
	local arg =
	{
		
		receive_type = "players",
		receive_value = _players,
		email=
		{
			type="native",
			title=tostring(_title or "系统邮件"),
			sender="鲸鱼斗地主官方",
			valid_time=0,
			data = string.format("{\"content\":\"%s\",\"%s\":%d}",_content,_type,_value),
		}
	}

	-- 调用邮件服务
	local errcode = skynet.call(DATA.service_config.email_service,"lua",
											"external_send_email",
											arg,
											DATA.my_id,
											"gm add award")

	if not errcode or errcode == 0 then
		return "成功完成!"
	else
		return "执行失败：" .. (errcode and error_code[errcode] or tostring(errcode))
	end
end

function gm_cmd.email(_receive_type,_receive_value, _market_channel, _platform, _title,_content,...)

    local rt = {
        players = true,
        everyone = true,
        vip = true,
    }
	if not rt[ _receive_type ] then
		return "错误：接收类型 错误！"
	end

	if "everyone" == _receive_type then
		_receive_value = {}
	else
		if type(_receive_value) ~= "table" or not next(_receive_value) then
			return "错误：接收数据 必须为非空表！"
		end
	end


	if type(_content) ~= "string" then
		return "错误：输入的信息内容有误！"
	end

	if _market_channel and type(_market_channel) ~= "string" then
		return "错误：输入的渠道字段不是字符串！"
	end
	if _receive_type ~= "players" and type(_market_channel) == "string" and string.len(_market_channel) > 100 then
		return "错误：输入的渠道字段超过100！"
	end
	if _market_channel and type(_market_channel) == "string" and string.len(_market_channel) < 1 then
		_market_channel = nil
	end

	if _platform and type(_platform) ~= "string" then
		return "错误：输入的平台字段不是字符串！"
	end
	if _receive_type ~= "players" and type(_platform) == "string" and string.len(_platform) > 100 then
		return "错误：输入的平台字段超过100！"
	end
	if _platform and type(_platform) == "string" and string.len(_platform) < 1 then
		_platform = nil
	end
	_content = string.gsub(_content,"\"","\\\"")

	local ad = {}
	local as = {...}
	local al = #as
	if al%2 ~= 0 then
		return "错误：输入的资产内容有误！"
	end
	for i=1,al,2 do
		
		local k = as[i]
		if not basefunc.is_asset(k) then
			return "错误：财富类型不正确！"
		end

		local v = tonumber(as[i+1])
		if not v or v < 1 then
			return "错误：财富数量不正确！"
		end

		ad[k]=v
	end

	-- 构造邮件参数
	local arg =
	{
		receive_type = _receive_type,
        receive_value = _receive_value,
		market_channel = _market_channel,
		platform = _platform,
		email=
		{
			type="native",
			title=tostring(_title or "系统邮件"),
			sender="鲸鱼斗地主官方",
			valid_time=0,
			data = string.format("{\"content\":\"%s\"",_content),
		}
	}

	for k,v in pairs(ad) do
		arg.email.data = arg.email.data .. ",\"" .. k .."\":".. v
	end
	
	arg.email.data = arg.email.data .. "}"
	-- 调用邮件服务
	local errcode = skynet.call(DATA.service_config.email_service,"lua",
											"external_send_email",
											arg,
											DATA.my_id,
											"gm send msg")

	if not errcode or errcode == 0 then
		return "成功完成!"
	else
		return "执行失败：" .. (errcode and error_code[errcode] or tostring(errcode))
	end
end

function gm_cmd.pay(_order_id)

	local ok,errcode = skynet.call(DATA.service_config.pay_service,"lua","modify_pay_order",
	_order_id,"complete","gm shougong complete:" .. tostring(DATA.my_id))
	if ok then
		return "成功完成"
	else
		return "错误 " .. tostring(errcode) .. " :" .. tostring(errcode and error_code[errcode])
	end
end

function gm_cmd.open_bbsc_day_permit(player_id,day_num)
	if not player_id or type(player_id) ~= "string" then
		return "player_id 参数错误"
	end
	if not day_num or type(day_num) ~= "number" then
		return "day_num 参数错误"
	end
	skynet.send(DATA.service_config.task_center_service,"lua","open_bbsc_day_permit",
			player_id , day_num )
end

function gm_cmd.add_task_progress( player_id , task_id , add )
	if not player_id then
		return "错误：参数 players 不能为 nil！"
	end
	if type(player_id) ~= "string" then
		return "player_id 应该为字符串"
	end
	if not task_id or type(task_id) ~= "number" then
		return "task_id 参数错误"
	end
	if not add or type(add) ~= "number" then
		return "add 参数错误"
	end

	skynet.send(DATA.service_config.task_center_service,"lua","add_task_progress",
			player_id , task_id , add )

end

function gm_cmd.add_lottery_score( player_id , lottery_type , source_type , add_score )
	if not player_id then
		return "错误：参数 players 不能为 nil！"
	end
	if type(player_id) ~= "string" then
		return "player_id 应该为字符串"
	end
	if not lottery_type or type(lottery_type) ~= "string" then
		return "task_id 参数错误"
	end
	if not source_type or type(source_type) ~= "string" then
		return "source_type 参数错误"
	end
	if not add_score or type(add_score) ~= "number" then
		return "add_score 参数错误"
	end

	skynet.send(DATA.service_config.common_lottery_center_service,"lua","real_add_lottery_score",
			player_id , lottery_type , source_type , add_score )
end

function gm_cmd.change_player_relation(player_id,new_parent,op_player)
	if not player_id or type(player_id) ~= "string" then
		return "player_id 参数错误"
	end
	if not new_parent or type(new_parent) ~= "string" then
		return "new_parent 参数错误"
	end
	if not op_player or type(op_player) ~= "string" then
		return "op_player 参数错误"
	end
	skynet.send(DATA.service_config.sczd_center_service,"lua","change_player_relation",
			player_id,new_parent,op_player )
end

function gm_cmd.set_activate_sczd_profit(player_id , tgy_tx_profit , xj_profit , tglb_profit , basai_profit)
	if not player_id or not tgy_tx_profit or not xj_profit or not tglb_profit or not basai_profit
		or type(player_id) ~= "string" or type(tgy_tx_profit) ~= "string" or type(xj_profit) ~= "string" or type(tglb_profit) ~= "string" or type(basai_profit) ~= "string" 
		or (tgy_tx_profit ~= "true" and tgy_tx_profit~="false") or (xj_profit ~= "true" and xj_profit~="false") or (tglb_profit ~= "true" and tglb_profit~="false") or (basai_profit ~= "true" and basai_profit~="false") then
		return "参数错误"
	end
	skynet.send(DATA.service_config.sczd_center_service,"lua","set_activate_sczd_profit",
			player_id , tgy_tx_profit , xj_profit , tglb_profit , basai_profit )
end

function gm_cmd.money(_players,_type,_value)

	if not basefunc.is_asset(_type) then
		return "错误：参数 type 不正确！"
	end

	if type(_value) ~= "number" then
		return "错误：参数 value 不正确！"
	end

	if not _players then
		return "错误：参数 players 不能为 nil！"
	end

	if type(_players) == "string" then
		_players = {_players}
	elseif type(_players) == "table" then
		if not next(_players) then
			return "错误：参数 players 不能为空！"
		end
	else
		return "错误：参数 players 错误！"
	end

	for _,_pid in ipairs(_players) do

		skynet.send(DATA.service_config.data_service,"lua","change_asset_and_sendMsg",
			_pid , _type ,_value, "gm user op:" .. tostring(DATA.my_id) , "null" )

	end

end


function gm_cmd.obj(_players,_type,_num,_attr)

	if type(_players) == "string" then
		_players = {_players}
	elseif type(_players) == "table" then
		if not next(_players) then
			return "错误：参数 players 不能为空！"
		end
	else
		return "错误：参数 players 错误！"
	end

	if not basefunc.is_object_asset(_type) then
		return "错误：参数 _type(道具类型) 错误！"
	end

	if type(_num) ~= "number" then
		return "错误：参数 _num(道具数量) 错误！"
	end

	if type(_attr) ~= "table" then
		return "错误：参数 _attr(属性) 错误！"
	end

	for _,_pid in ipairs(_players) do

		skynet.send(DATA.service_config.data_service,"lua","multi_change_asset_and_sendMsg"
			,_pid
			,{
				[1]={
					asset_type=_type,
					num=_num,
					attribute=_attr,
				}
			}
			, "gm user op:" .. tostring(DATA.my_id) , "null" )

	end

end

----- 强行设置要走到的 下面第几个 格子数
function gm_cmd.move(_move_num)
	if not _move_num then
		return "参数错误，_move_num 不能为空"
	elseif type(_move_num) ~= "number" then
		return "参数错误，_move_num 类型不为number"
	end

	---- 判断
	if PUBLIC.LF_driver_game_agent and PUBLIC.LF_driver_game_agent.force_set_move_num then
		local ret = PUBLIC.LF_driver_game_agent.force_set_move_num( _move_num )

		if ret ~= 0 then
			return string.format("调用失败，错误码：%s" , ret )
		end
	end

	return "success"
end

----- 强行设置要走到的 下面第几个 格子数
function gm_cmd.move_enemy(_move_num)
	if not _move_num then
		return "参数错误，_move_num 不能为空"
	elseif type(_move_num) ~= "number" then
		return "参数错误，_move_num 类型不为number"
	end

	---- 判断
	if PUBLIC.LF_driver_game_agent and PUBLIC.LF_driver_game_agent.force_set_ememy_move_num then
		local ret = PUBLIC.LF_driver_game_agent.force_set_ememy_move_num( _move_num )

		if ret ~= 0 then
			return string.format("调用失败，错误码：%s" , ret )
		end
	end

	return "success"
end


----- 强制设置 下一个刷新出来的道具是啥 ， 传入 type_id
function gm_cmd.next_award(_type_id)
	if not _type_id then
		return "_type_id 不能为空"
	elseif type(_type_id) ~= "number" then
		return "参数错误， _type_id 类型不为number"
	end

	---- 判断
	if PUBLIC.LF_driver_game_agent and PUBLIC.LF_driver_game_agent.force_set_move_num then
		local ret = PUBLIC.LF_driver_game_agent.force_set_next_award( _type_id )

		if ret ~= 0 then
			return string.format("调用失败，错误码：%s" , ret )
		end
	end

	return "success"

end

function gm_cmd.get_tool( _tool_id )
	if not _tool_id then
		return "参数错误，_tool_id不能为空"
	elseif type(_tool_id) ~= "number" then
		return "参数错误，_tool_id 类型不为number"
	end

	---- 判断
	if PUBLIC.LF_driver_game_agent and PUBLIC.LF_driver_game_agent.force_get_tool then
		local ret = PUBLIC.LF_driver_game_agent.force_get_tool( _tool_id )

		if ret ~= 0 then
			return string.format("调用失败，错误码：%s" , ret )
		end
	end

	return "success"
end

----- 添加装备
function gm_cmd.add_equipment( _eqp_id )
	if not _eqp_id then
		return "参数错误，_eqp_id 不能为空"
	elseif type(_eqp_id) ~= "number" then
		return "参数错误，_eqp_id 类型不为number"
	end

	---- 判断
	if PUBLIC.add_drive_equipment then
		local ret = PUBLIC.add_drive_equipment( _eqp_id )

		if type(ret) == "number" then 
			return string.format("创建 装备 调用失败！！ error_code:%s" , ret  )
		end
	end

	return "success"
end

---- 添加车
function gm_cmd.add_car( _car_id )
	if not _car_id then
		return "参数错误， _car_id 不能为空"
	elseif type(_car_id) ~= "number" then
		return "参数错误， _car_id 类型不为number"
	end

	---- 判断
	if PUBLIC.add_drive_car then
		local ret = PUBLIC.add_drive_car( _car_id ) -- PUBLIC.LF_car_base_lib.add_car( _car_id )

		if type(ret) == "number" then 
			return string.format("创建车辆调用失败！！ error_code:%s" , ret  )
		end
	end

	return "success"
end

---- 添加宝箱
function gm_cmd.add_box( _box_id )
	if not _box_id then
		return "参数错误， _box_id 不能为空"
	elseif type(_box_id) ~= "number" then
		return "参数错误， _box_id 类型不为number"
	end

	---- 判断
	if PUBLIC.add_one_timer_box then
		local ret = PUBLIC.add_one_timer_box( _box_id ) 

		if ret ~= 0 then 
			return string.format("创建宝箱调用失败！！ error_code:%s" , ret  )
		end
	end

	return "success"
end

-- function gm_cmd.testxx(...)
-- 	return table.concat({...},"--|--")
-- end

function REQUEST.gm_command(_data)

	if not DATA.extend_data.player_level or DATA.extend_data.player_level < 1 then
		return {result="错误：普通用户不能使用此功能！"}
	end

	if not _data.command or "" == _data.command then
		return {result="错误：不能执行空命令！"}
	end

	local _cmd,_args
	local _pos = string.find(_data.command," ") -- 命令和参数 用空格隔开
	if _pos then
		_cmd = string.sub(_data.command,1,_pos-1)
		_args = string.sub(_data.command,_pos+1)
	else
		_cmd = _data.command
	end

	local _allow = skynet.getcfg("allow_gm_command")

	if "off" == _allow then
		return {result="错误：GM 工具已经关闭！"}
	end

	if "help" ~= _cmd then
		if _allow and "*" ~= _allow then
			if not string.find(_allow,_cmd .. ",") then
				return {result="错误：此命令被管理员禁用！"}
			end
		end
	end

	if not gm_cmd[_cmd] then
		return {result=string.format("错误：不支持的命令 '%s' ！",_cmd)}
	end

	local _param_func = parse_lua_line(_args)
	if not _param_func then
		return {result="错误：参数错误！"}
	end

	local ok,ret = xpcall(gm_cmd[_cmd],error_handle,_param_func())
	if ok then
		return {result=ret}
	else
		return {result="错误：" .. tostring(ret)}
	end
end
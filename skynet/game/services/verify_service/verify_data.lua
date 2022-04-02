--
-- Author: yy
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：验证数据管理（加载、访问）

local skynet = require "skynet_plus"
local base = require "base"
require"printfunc"
local md5 = require "md5.core"
require "data_func"
local basefunc = require "basefunc"
require "normal_func"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("verify_data",{

	--[[
		验证数据。
		platform,channel_type,login_id 三层映射： platform => {channel_type => {login_id => 【数据】 } }
		【数据】的结构：
			{
				data =, 验证表表 player_verify 的行数据， true 表示用户存在，但未加载；nil 表示用户不存在
				is_verifying=true/false，是否正在验证
			}
	--]]
	verify_info = {},

	-- 玩家 id 支持的 验证渠道： player_id => {{platform=,channel_type=,login_id=},...}
	player_verify = {},

	-- 验证状态数据，以玩家 id 为 键
	--  player_id => {platform=,verify_channel=,login_id=,ts=,data=}
	verify_status_data = {},

	-- json 模板（web 调用）
	json_templ_player_list =
[[{
	"result": "0",
	"list":[%s]
}]],


})

local LF = base.LocalFunc("verify_data")

function LF.init()

	-- 加载多级清单（不包含行数据）
	local sql = "select platform,channel_type,login_id,id from player_verify"
	local ret = PUBLIC.db_query(sql)
	if( ret.errno ) then
		error(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
	else
		for _,_d in ipairs(ret) do

			basefunc.to_keys(LD.verify_info,{data=true},_d.platform,_d.channel_type,_d.login_id)

			local _pv = LD.player_verify[_d.id] or {}
			LD.player_verify[_d.id] = _pv
			_pv[#_pv + 1] = _d

		end
	end

end

-- LD.player_verify 列表的加入、删除
function LF.append_to_verify_list(_player_id,_platform,_channel_type,_login_id)
	local _d = LD.player_verify[_player_id] or {}
	LD.player_verify[_player_id] = _d
	_d[#_d + 1] = {platform=_platform,channel_type=_channel_type,login_id=_login_id,id=_player_id}
end
function LF.remove_from_verify_list(_player_id,_platform,_channel_type)
	local _d = LD.player_verify[_player_id]
	if _d then
		for i,v in ipairs(_d) do
			if v.platform == _platform and v.channel_type == _channel_type then
				table.remove(_d,i)
				break
			end
		end
	end
end

-- 返回验证信息的状态： 0 不存在； 1 存在； 2 使用中
function PUBLIC.base_has_verify(_platform,_channel_type,_login_id)

	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)

	if not _info or not _info.data then
		return 0
	end

	if _info.is_verifying then
		return 2
	end

	return 1
end

-- 加入验证信息。注意： 不会处理 is_verifying 状态，需要 调用者自行判断
-- 参数 _op_user ：如果不为空，则记录日志
-- 返回加入的验证数据
function PUBLIC.base_add_verify(_platform,_channel_type,_login_id,_verify_data,_op_user)

	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)
	if _info and _info.data then
		return nil -- 已经存在了
	end

	if _info then
		if type(_info.data) == "table" then
			basefunc.merge(_verify_data,_info.data)
		else
			_info.data = _verify_data
		end

	else
		_info = {data = _verify_data}
		basefunc.to_keys(LD.verify_info,_info,_platform,_channel_type,_login_id)
	end

	_info.data.platform = _platform
	_info.data.channel_type = _channel_type
	_info.data.login_id = _login_id

	LF.append_to_verify_list(_verify_data.id,_platform,_channel_type,_login_id)

	LF.write_verify_data(_info.data)

	if _op_user then
		local _log = basefunc.copy(_info.data)
		_log.op = "add"
		_log.op_user = _op_user
		PUBLIC.db_exec(PUBLIC.gen_insert_sql("player_verify_log",_log))
	end

	return _info.data
end

-- 修改验证信息。注意：不能修改 player id
-- 参数 _op_user ：如果不为空，则记录日志
function PUBLIC.base_modify_verify(_platform,_channel_type,_login_id,_verify_data)

	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)
	if not _info or not _info.data then
		return false -- 不存在
	end

	if _verify_data.id and _info.data.id ~= _verify_data.id then
		print("error:cannt modify verify info player id:",_info.data.id , _verify_data.id)
		return false
	end

	_info.data.platform = _platform
	_info.data.channel_type = _channel_type
	_info.data.login_id = _login_id

	basefunc.merge(_verify_data,_info.data)
	LF.write_verify_data(_info.data)

	return true
end

-- 删除验证信息。注意： 不会处理 is_verifying 状态，需要 调用者自行判断
-- 返回删除的验证数据
function PUBLIC.base_del_verify(_platform,_channel_type,_login_id,_op_user)
	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)
	if not _info or not _info.data then
		return nil -- 不存在
	end

	if _op_user then
		local _log = basefunc.copy(_info.data)
		_log.op = "del"
		_log.op_user = _op_user
		PUBLIC.db_exec(PUBLIC.gen_insert_sql("player_verify_log",_log))
	end

	basefunc.to_keys(LD.verify_info,nil,_platform,_channel_type,_login_id)

	LF.remove_from_verify_list(_info.data.id,_platform,_channel_type)

	PUBLIC.db_exec(PUBLIC.format_sql("delete from player_verify where platform=%s and channel_type=%s and login_id=%s",_platform,_channel_type,_login_id))

	return _info.data
end

-- 得到验证信息，并保证 _info.data 从数据库加载
-- 返回：
--	nil 无信息
--	info 验证信息
function PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)

	local _info = basefunc.from_keys(LD.verify_info,_platform,_channel_type,_login_id)
	if not _info or not _info.data then
		return _info -- 无信息 或 有信息无用户
	end

	if type(_info.data) == "table" then
		return _info -- 已加载，直接返回
	end

	-- 有此用户，但未加载
	local sql = PUBLIC.format_sql("select * from player_verify where platform=%s and channel_type=%s and login_id=%s",_platform,_channel_type,_login_id)
	local ret = PUBLIC.db_query(sql)
	if( ret.errno ) then
		error(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
	else

		-- 再次检查（查询挂起时，可能数据有变化）
		if type(_info.data) == "table" then
			return _info -- 已加载，直接返回
		end

		if not ret[1] then
			print("load user verify info fail:",_platform,_channel_type,_login_id)
			return nil  -- 加载数据库出错（可能有异常）
		end

		_info.data = ret[1]

		return _info
	end

end

-- 根据 login id 获得 验证数据
function PUBLIC.get_player_verify_data(_platform,_channel_type,_login_id)
	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)
	--dump(_info,"xxxxxxxxxxxxxxxxx get_player_verify_data ,info:")
	return _info and _info.data or nil
end

-- 写入验证数据到数据库
function LF.write_verify_data(_verify_data)
	local sql = PUBLIC.safe_insert_sql("player_verify",_verify_data,{"platform","channel_type","login_id"})
	PUBLIC.db_exec(sql,"fast")
end

-- 进入验证状态： 设置验证标志，并返回 验证信息
-- 返回 verify_info 或 nil (另一个处理正在进行) + is_new_user
function PUBLIC.enter_verifying_status(_platform,_channel_type,_login_id)

	-- 先获取
	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)

	if _info then
		if _info.is_verifying then
			return nil -- 另一个 连接正在验证
		else
			_info.is_verifying = true
			return _info,not _info.data -- 如果 _info.data 为 nil 表示新用户
		end
	end

	_info = {is_verifying = true}

	basefunc.to_keys(LD.verify_info,_info,_platform,_channel_type,_login_id)

	return _info,true -- 新用户
end

-- 参数 _channel_type 如果为 nil ，则取配置值，否则取 "wechat"
function CMD.userId_from_login_id(_platform,_channel_type,_login_id)

	_platform = PUBLIC.check_platform(_platform)
	_channel_type = PUBLIC.check_verify_channel(_channel_type)

	local _data = PUBLIC.get_player_verify_data(_platform,_channel_type,_login_id)
	return _data and _data.id
end


-- (web使用) 删除用户的 验证信息
function CMD.del_verify_info(_player_id,_channel_type,_login_id,_op_user)

	local _platform = CMD.get_platform_by_id(_player_id)
	_channel_type = PUBLIC.check_verify_channel(_channel_type)

	local _info = PUBLIC.get_player_verify_info(_platform,_channel_type,_login_id)

	if not _info or not _info.data then
		return 1004,"验证信息不存在，无需删除"
	end

	if _info.is_verifying then
		return 1002,"验证信息正在使用中，不能删除"
	end

	if _player_id ~= _info.data.id then
		return 1003,"玩家 id 和验证信息不匹配"
	end

	-- 连带的 ， 删除电话绑定
	skynet.call(DATA.service_config.data_service,"lua","del_bind_phone_number",_player_id,_platform)

	if PUBLIC.base_del_verify(_platform,_channel_type,_login_id,_op_user) then
		return 0,"验证信息删除成功"
	else
		return 1065,"验证信息不存在，无需删除"
	end

end

-- 为用户 增加新的验证信息，如果存在，则返回错误（强行修改 可能影响 别的用户）
function CMD.add_verify_info(_player_id,_channel_type,_login_id,_verify_data,_op_user)

	_channel_type = PUBLIC.check_verify_channel(_channel_type)

	local _platform = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register","platform")

	local _code = PUBLIC.base_has_verify(_platform,_channel_type,_login_id)
	if 1 == _code then
		return 1055,"验证信息已经存在"
	end
	if 2 == _code then
		return 1002,"验证信息正在使用中，不能修改"
	end

	_verify_data = _verify_data or {}

	_verify_data.id = _player_id
	if PUBLIC.base_add_verify(_platform,_channel_type,_login_id,_verify_data,_op_user) then
		return 0,"验证信息添加成功"
	else
		return 2414,"验证信息已经存在"
	end
end

-- 设置自定义验证状态数据
function PUBLIC.set_verify_status_data(_player_id,_platform,_channel_type,_login_id,_data)

	local _vs = LD.verify_status_data[_player_id]
	if _vs then

		_vs.ts = os.time()

		-- 平台(platform) 信息
		_vs.verify.platform = _platform
		_vs.verify.verify_channel = _channel_type
		_vs.verify.login_id = _login_id
		_vs.verify.player_id = _player_id

		-- 状态数据
		_vs.data = _data
	else
		LD.verify_status_data[_player_id] =
		{
			ts = os.time(),

			-- 验证信息
			verify = {
				platform = _platform,
				verify_channel = _channel_type,
				login_id = _login_id,
				player_id = _player_id,
			},

			-- 自定义状态数据
			data = _data,
		}
	end
end

-- 释放未登录用户的 内存
function CMD.free_verify_data()

    local users_map = {}

    -- local qret = PUBLIC.db_query([[
	-- 	select distinct player_id from (
	-- 		select distinct player_id from player_pay_order where create_time >= '2020-4-28' and order_status = 'complete'
	-- 		union
	-- 		select distinct player_id from player_pay_order_log where create_time >= '2020-4-28' and order_status = 'complete'
	-- 	) a    
    -- ]])
    
    -- for _,_d in ipairs(qret) do
    --     users_map[_d.player_id] = true
    -- end
    
    local _ret = {
    	total=0,
    	data=0,
    	using=0,
    	clean=0,
    	cleans={},
    }

    for _plat,_d1 in pairs(LD.verify_info) do
        for _chan,_d2 in pairs(_d1) do
        	for _login_id,_d3 in pairs(_d2) do
        	
            	if type(_d3.data) == "table" then
            		_ret.data = _ret.data + 1
            		if not _d3.is_verifying and not users_map[_d3.data.id] and not LD.verify_status_data[_d3.data.id] then
            			--table.insert(_ret.cleans,_d3.data.id)
            			_d3.data = true
            			_ret.clean = _ret.clean + 1
            		end
            	end 
            	
            	if _d3.is_verifying then
            		_ret.using = _ret.using + 1
            	end
            	
            	_ret.total = _ret.total + 1
            	
            end
        end
    end
    
    return _ret
end

-- （web调用）根据验证 id ，得到用户列表
function CMD.get_player_list_by_login_info(_verify_channel,_login_id)

	local ret = {}

	for _platform,_pf_data in pairs(LD.verify_info) do
		if _verify_channel then
			if _pf_data[_verify_channel] and _pf_data[_verify_channel][_login_id] and _pf_data[_verify_channel][_login_id].data then
				ret[#ret + 1] = {platform=_platform,login_channel=_verify_channel}
			end
		else -- 未提供 _verify_channel ，搜所有
			for _vc,_vc_data in pairs(_pf_data) do
				if _vc_data[_login_id] and _vc_data[_login_id].data then
					ret[#ret + 1] = {platform=_platform,login_channel=_vc}
				end
			end
		end
	end

	-- 获得数据
	if next(ret) then
		local _jsons = {}

		for i,v in ipairs(ret) do
			local _data = PUBLIC.get_player_verify_data(v.platform,v.login_channel,_login_id)
			v.market_channel = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_data.id,"player_register","market_channel")
			v.player_id = _data.id
			v.name = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_data.id,"player_info","name")

			_jsons[#_jsons + 1] = cjson.encode(v)
		end

		return string.format(LD.json_templ_player_list,table.concat(_jsons,","))
	end

	return string.format(LD.json_templ_player_list,"")
end

-- （web调用）根据平台 ，验证 id ，得到用户
function CMD.get_player_by_login_info(_platform,_verify_channel,_login_id)

	if not _login_id then
		return nil,1001
	end

	_platform = PUBLIC.check_platform(_platform)
	local _pf_data = LD.verify_info[_platform]
	if not _pf_data then
		return nil,1001
	end

	local ret
	if _verify_channel then
		if _pf_data[_verify_channel] and _pf_data[_verify_channel][_login_id] and _pf_data[_verify_channel][_login_id].data then
			ret = {platform=_platform,login_channel=_verify_channel}
		end
	else -- 未提供 _verify_channel ，搜所有
		for _vc,_vc_data in pairs(_pf_data) do
			if _vc_data[_login_id] and _vc_data[_login_id].data then
				ret = {platform=_platform,login_channel=_vc}
				break -- 找到，则停止
			end
		end
	end

	if ret then
		local _data = PUBLIC.get_player_verify_data(ret.platform,ret.login_channel,_login_id)
		ret.market_channel = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_data.id,"player_register","market_channel")
		ret.name = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_data.id,"player_info","name")
		ret.player_id = _data.id
		return ret
	else
		return nil,2150
	end
end

-- 得到玩家的所有验证方式
function CMD.get_player_verify_list(_player_id)
	return LD.player_verify[_player_id]
end

-- 根据玩家 id ，得到所在平台
-- 注意： 这里仅限于  有验证信息的 玩家；  没有验证信息的 玩家 要从 data service 的 get_player_info 拿
function CMD.get_platform_by_id(_player_id)

	local _pvd = LD.player_verify[_player_id]
	if not _pvd or not _pvd[1] then
		print("get_platform_by_id error,not found verify info:",_player_id,_channel_type)
		return nil
	end

	return _pvd[1].platform
end

-- 得到玩家在指定渠道的 验证数据
function CMD.get_verify_data_by_id(_player_id,_channel_type)

	local _pvd = LD.player_verify[_player_id]
	if not _pvd or not _pvd[1] then
		print("get_player_verify_data error,not found verify info:",_player_id,_channel_type)
		return nil
	end

	local _chdata
	for _,_d in ipairs(_pvd) do
		if _channel_type == _d.channel_type then
			_chdata = _d
			break
		end
	end

	if not _chdata then
		print("get_player_verify_data error,not found channel:",_player_id,_channel_type,basefunc.tostring(_pvd))
		return nil
	end

	local _info = PUBLIC.get_player_verify_info(_chdata.platform,_channel_type,_chdata.login_id)
	if not _info then
		print("get_player_verify_data error,not found cverify info:",_player_id,_chdata.platform,_channel_type,_chdata.login_id)
		return nil
	end

	return _info.data
end

-- 得到玩家的微信 openid
-- 参数 _verify_channel ： 可能是 "wechat" 或 "yyb_wechat"
function CMD.get_player_wx_openid(_verify_channel,_player_id)

	-- 尝试 wechat 渠道
	local _d = CMD.get_verify_data_by_id(_player_id,_verify_channel)
	if _d then
		if not _d.extend_1 then
			print("get_player_wx_openid error,wechat open id is null:",_verify_channel,_player_id,basefunc.tostring(_d))
		end
		return _d.extend_1
	end

	print("get_player_wx_openid error,verify data is null:",_player_id)
	return nil
end

-- （已登录用户）得到自定义验证状态数据
-- 参数 ... ： 逐级查找参数
function CMD.get_verify_status_data(_player_id,...)

	return basefunc.from_keys(LD.verify_status_data,_player_id,...)

end

-- （已登录用户）清除验证状态数据（用户下线）
function CMD.clear_verify_status_data(_player_id)
	LD.verify_status_data[_player_id] = nil
end


-- （已登录用户）得到本次验证的微信账号的 openid
function CMD.get_cur_wechat_openid(_player_id)
	local _vs = LD.verify_status_data[_player_id]
	return _vs and _vs.data and _vs.data.openid
end

-- 判断玩家在某个平台有无账号， 有，则返回 player id
function CMD.player_own_platform(_player_id,_platform)

	local _pv = LD.player_verify[_player_id or ""]
	if not _pv then
		return nil
	end

	for _,_d in pairs(_pv) do
		local _pd2 = PUBLIC.get_player_verify_info(_platform,_d.channel_type,_d.login_id)
		if _pd2 and _pd2.data then
			return _pd2.data.id
		end
	end
	
	return nil
end

-- 得到玩家在所有平台的账号信息
-- 返回映射表： platform => player_id
function CMD.get_player_all_platform(_player_id)
	local _pv = LD.player_verify[_player_id or ""]
	if not _pv then
		return nil
	end

	local ret = {}

	for _,_d in pairs(_pv) do
		for _platform,_ in pairs(LD.verify_info) do
			local _pd2 = PUBLIC.get_player_verify_info(_platform,_d.channel_type,_d.login_id)
			if _pd2 and _pd2.data then
				ret[_platform] = _pd2.data.id
			end
		end
	end

	return ret
end

return LF
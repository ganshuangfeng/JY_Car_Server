--
-- Author: lyx
-- Date: 2018/4/14
-- Time: 10:31
-- 说明：通用函数
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
require"printfunc"
local md5 = require "md5.core"
require "data_func"
local cjson = require "cjson"
local basefunc = require "basefunc"
require "normal_enum"
local nodefunc = require "nodefunc"

cjson.encode_sparse_array(true,1,0)
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("normal_func",{

	-- 玩家信息缓存： player id => {platform=,market_channel=}
	player_info_cache = {},
})

local LF = base.LocalFunc("normal_func")

--[[ 
	检查参数
	_options 		 -- 用户勾选的
	_onlyone_configs -- 参数的配置
		{ 				-- _onlyone_configs
			{ 			-- _groups
				{ 		-- g
					name1,
					name2,
					...
				},
				...
			},
			...
		}

	返回 0 或 错误号
--]]
function PUBLIC.check_client_option(_options,_onlyone_configs)

	-- 对单选项归组： 分组 id(数组下标) => {name1,name2,...}
	local _onlyone_groups = {}

	-- 名字所在的组： 配置名 => {group_id1,group_id2,...}
	local _onlyone_name2group = {}
	for _,_groups in ipairs(_onlyone_configs) do
		for _,g in ipairs(_groups) do
			local _group_id = #_onlyone_groups + 1 -- 分组 id
			_onlyone_groups[_group_id] = {}
			for _,_name in ipairs(g) do

				-- 分组下的名字
				table.insert(_onlyone_groups[_group_id],_name) 

				-- 名字下的分组
				_onlyone_name2group[_name] = _onlyone_name2group[_name] or {}
				table.insert(_onlyone_name2group[_name],_group_id)
			end
		end
	end

	-- 分组重复记录： group id => true
	local _dupli_groups = {}

	for _,_opt in ipairs(_options) do

		if not _opt.option then
			print("check_client_option error:option name is nil!")
			return 2020
		end

		if _onlyone_name2group[_opt.option] then
			for _,_group_id in ipairs(_onlyone_name2group[_opt.option]) do -- 处理 名字下的 每一个组

				if _dupli_groups[_group_id] then
					print("check_client_option error,option duplication,only:",table.concat(_onlyone_groups[_group_id],","))
					return 2019
				else
					_dupli_groups[_group_id] = true
				end
			end
		end
	end

	for _group_id,_group in ipairs(_onlyone_groups) do
		if not _dupli_groups[_group_id] then -- 至少选一个
			print("check_client_option error:shoould select one from:",table.concat(_group,","))
			return  2021
		end
	end

	return 0
end

-- 检查平台参数，返回一个规范化的值
function PUBLIC.check_platform(_platform)

	if _platform and "" ~= basefunc.string.trim(_platform) then
		return _platform
	end

	return skynet.getcfg("api_default_platform") or "normal"
end

-- 检查验证渠道参数，返回一个规范化的值
function PUBLIC.check_verify_channel(_channel)

	if _channel and "" ~= basefunc.string.trim(_channel) then
		return _channel
	end

	return skynet.getcfg("api_default_verify_channel") or "wechat"
end

-- 检查市场渠道参数，返回一个规范化的值
function PUBLIC.check_market_channel(_channel)

	if _channel and string.len(basefunc.string.trim(_channel)) > 1 then
		return _channel
	end

	return skynet.getcfg("api_default_market_channel") or "normal"
end

-- 检查分享来源标记，返回一个规范化的值
function PUBLIC.check_share_source(_share_source)

	if _share_source and "" ~= basefunc.string.trim(_share_source) then
		return _share_source
	end

	return skynet.getcfg("api_default_share_source") or "normal"
end

-- 转换 分享邀请时，平台、渠道的跟随 结果
function PUBLIC.trans_invite_target(_platform,_market_channel)
	local _invite_config = nodefunc.get_global_config("share_invite_config").invite_config
	local _pcfg = _platform and _invite_config[_platform] or _invite_config.default
	local _mcfg = _market_channel and _pcfg[_market_channel] or _pcfg.default

	return _mcfg[1] or _platform,_mcfg[2] or _market_channel
end

function LF.get_platform_shoping_config_name(_config,_market_channel)

	return _config and (_config[_market_channel] or _config.default)
end

-- 根据玩家的平台、推广渠道，得到支付配置文件名
-- 注意，如果只有一个参数，则为 player_id
function PUBLIC.get_shopcfg_name(_platform,_market_channel)

	if nil == _market_channel then -- 一个参数，则 _platform 为 player_id

		if not _platform then
			return "shoping_config"
		end

		local _d = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_platform,"player_register")
		if not _d then
			return "shoping_config" -- 出错
		end

		_platform = _d.platform
		_market_channel = _d.market_channel
	end
	
	local _config = nodefunc.get_global_config("payment_config").platform_shoping_config

	-- 找具体平台配置
	local _cfg_name = LF.get_platform_shoping_config_name(_config[_platform],_market_channel)

	-- 没有 则 找默认平台
	if not _cfg_name then
		_cfg_name = LF.get_platform_shoping_config_name(_config.default,_market_channel)
	end

	return _cfg_name or "shoping_config"
end

function LF.safe_player_info(_player_id)
	local _pinfo = LD.player_info_cache[_player_id] or {
		platform = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register","platform"),
		market_channel = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register","market_channel"),
	}
	LD.player_info_cache[_player_id] = _pinfo

	return _pinfo
end

function PUBLIC.player_shopcfg_name(_player_id)

	if not _player_id then
		return "shoping_config"
	end

	local _pinfo = LF.safe_player_info(_player_id)

	return PUBLIC.get_shopcfg_name(_pinfo.platform,_pinfo.market_channel)
end

function PUBLIC.get_player_sms_sign(_player_id)

	local _plats = nodefunc.get_global_config("share_invite_config").all_platform
	if not _player_id then
		return _plats.normal.sms_sign
	end

	local _pinfo = LF.safe_player_info(_player_id)

	return _plats[_pinfo.platform] and _plats[_pinfo.platform].sms_sign or _plats.normal.sms_sign
end

--[[ 
	根据 快捷方式 生成服务调用 器
	_svr_shortcut 支持的格式：参见 PUBLIC.service_invoker_help_text
	_method 为调用方式： call 或 send ，默认为 call
--]]
PUBLIC.service_invoker_help_text = [[ 
	1、普通字符串：   服务名字，即 center.lua 中配置的服务
	2、#SVR_ID ：    SVR_ID 为 node_service 创建的服务的 id
	3、NODE:ADDR ：  NODE 为节点名，ADDR 为 16 进制表示的 服务地址
	4、NODE@ADDR ：  NODE 为节点名，ADDR 为 10 进制表示的 服务地址
	5、NODE.name ：  NODE 为节点名，name 为 center.lua 中配置的服务名字
]]
function PUBLIC.get_service_invoker(_svr_shortcut,_method)
	if type(_svr_shortcut) ~= "string" then
		return nil,"service shortcut is invalid!"
	end

	_svr_shortcut = basefunc.string.trim(_svr_shortcut)
	if "" == _svr_shortcut then
		return nil,"service shortcut is invalid!"
	end

	if string.find(_svr_shortcut,"%s") then
		return nil,"service shortcut is invalid!"
	end

	_method = _method or "call" 

	-- #SVR_ID
	if string.sub(_svr_shortcut,1,1) == "#" then
		return function(_cmd,...)
			return nodefunc[_method](string.sub(_svr_shortcut,2),_cmd,...)
		end
	end

	-- NODE:ADDR , NODE@ADDR, NODE.name
	local ok,_node,_spec,_addr = xpcall(string.match,basefunc.error_handle,_svr_shortcut,"(.*)([@:%.])(.*)")
	if _spec then

		if _spec == ":" then
			_addr = tonumber("0x" .. _addr)
		elseif _spec == "@" then
			_addr = tonumber(_addr)
		elseif _spec == "." then
			return function(_cmd,...)
				if "call" == _method then
					return cluster.call(_node,"node_service","call_local_service",_addr,_cmd,...)
				else
					cluster.send(_node,"node_service","send_local_service",_addr,_cmd,...)
				end
			end
		else
			return nil,"service node addr spec is invalid!"
		end

		if not _addr or 0 == _addr then
			return nil,"service addr number is invalid!"
		end

		return function(_cmd,...)
			return cluster[_method](_node,_addr,_cmd,...)
		end
	end

	-- 普通字符串
	if not DATA.service_config[_svr_shortcut] then
		return nil,"service name '" .. tostring(_svr_shortcut) .. "' is not found!"
	end
	return function(_cmd,...)
		return skynet[_method](DATA.service_config[_svr_shortcut],"lua",_cmd,...)
	end
end

function PUBLIC.generate_phone_token()
	return skynet.random_str(15)
end

-- 通过钉钉机器人 发送通知
-- _data 格式 参见： https://developers.dingtalk.com/document/app/custom-robot-access/title-72m-8ag-pqw
function PUBLIC.notify_dingtalk(_url,_data)
	if type(_data) ~= "string" then
		_data = cjson.encode(_data)
	end

	print("====== notify_dingtalk(url,param) ========\n" .. tostring(_url) .. "\n" .. basefunc.tostring(_data))

	local _result = {
		skynet.call(DATA.service_config.webclient_service,"lua","request_post_json", _url,_data)
	}

	print("====== notify_dingtalk(result) ========\n" .. basefunc.tostring(_result))
end

-- 财富的 map => list
function PUBLIC.assets_map2list(_assets,_type_name,_value_name)
    _type_name = _type_name or "asset_type"
    _value_name = _value_name or "asset_value"

    local _ret = {}
    for k,v in pairs(_assets) do
        table.insert(_ret,{
            [_type_name] = k,
            [_value_name] = v,
        })
    end

    return _ret
end

-- 财富的  map => list
function PUBLIC.assets_list2map(_assets,_type_name,_value_name)
    _type_name = _type_name or "asset_type"
    _value_name = _value_name or "asset_value"

    local _ret = {}
    for _,v in ipairs(_assets) do
        _ret[v[_type_name]] = v[_value_name]
    end

    return _ret
end

-- 财富列表转换：消息 格式{asset_value=...} => 修改格式{value=...}
function PUBLIC.assets_proto2change(_assets)
    local _ret = {}
    for _,v in ipairs(_assets) do
        table.insert(_ret,{
            asset_type = v.asset_type,
            value = v.asset_value,
        })
    end

    return _ret
end

-- 财富列表转换：修改格式{value=...} => 消息 格式{asset_value=...}
function PUBLIC.assets_change2proto(_assets)
    local _ret = {}
    for _,v in ipairs(_assets) do
        table.insert(_ret,{
            asset_type = v.asset_type,
            asset_value = v.value,
        })
    end

    return _ret
end


return LF
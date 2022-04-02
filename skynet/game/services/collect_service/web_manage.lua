--
-- Created by lyx.
-- User: hare
-- Date: 2018/7/5
-- Time: 16:21
-- web 后台管理函数
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
require"printfunc"


local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("web_manage",{

})

local LF = base.LocalFunc("web_manage")

--[[ 发送邮件
参数：
    _data_json 数据，json 格式：
    {
        receive_type = "players",
        receive_value = {1234,5134,51233,3123} -- 接收邮件的玩家，  id 数组
        mail = -- 邮件数据
        {
            title=,     -- 标题
            context=,   -- 内容
            reason=,   -- 原因
            op_user=, -- 操作人
            props={},   -- 赠送的道具 ， key-value
        }
    }
--]]

function CMD.send_mail_test()
    local data =     {
        receive_type = "players",
        receive_value = {"109870"}, -- 接收邮件的玩家，  id 数组
        mail = -- 邮件数据
        {
            title="",     -- 标题
            context="",   -- 内容
            reason="111",   -- 原因
            op_user="111", -- 操作人
            props={},   -- 赠送的道具 ， key-value
        },
        --uuids = {"111"},
    }
    CMD.send_mail(cjson.encode(data))

    local data1 = {
        receive_type = "players",
        receive_value = {"109870", "109868"}, -- 接收邮件的玩家，  id 数组
        mail = -- 邮件数据
        {
            title="",     -- 标题
            context="",   -- 内容
            reason="112",   -- 原因
            op_user="111", -- 操作人
            props={},   -- 赠送的道具 ， key-value
        },
        uuids = {"111", "112"},

    }
    CMD.send_mail(cjson.encode(data1))
end

function CMD.send_mail(_data_json)
    local ok,data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return 1001
    end
    local rt = {
        players = true,
        everyone = true,
        vip = true,
    }

    -- 参数判断:
    if not rt[ data.receive_type ] then
        print("send_mail data.receive_type 1 error:",type(data.receive_type),data.receive_type)
        return 1001
    end
    if data.receive_type == "everyone" then
        data.receive_value = data.receive_value or {}
    else
        if type(data.receive_value)~= "table" or not next(data.receive_value) then
            print("send_mail data.receive_value 1 error:",type(data.receive_value))
            return 1001
        end
    end

    if data.receive_type == "players" then
        if data.uuids and (type(data.uuids) ~= "table" or not next(data.uuids) ) then
            print("send_mail data.uuids 1 error:",type(data.uuids))
            return 1001
        end
    end

    if data.market_channel and type(data.market_channel) ~= "string" then
        print("send_mail data.market_channel 1 error:",type(data.market_channel))
        return 1001
    end
    if data.receive_type ~= "players" and type(data.market_channel) == "string" and string.len(data.market_channel) > 100 then
        print("send_mail data.market_channel 1 error:",type(data.market_channel))
        return 1001
    end
    if data.market_channel and type(data.market_channel) == "string" and string.len(data.market_channel) < 1 then
        data.market_channel = nil
    end

    if data.platform and type(data.platform) ~= "string" then
        print("send_mail data.market_channel 1 error:",type(data.platform))
        return 1001
    end
    if data.receive_type ~= "players" and type(data.platform) == "string" and string.len(data.platform) > 100 then
        print("send_mail data.market_channel 1 error:",type(data.platform))
        return 1001
    end
    if data.platform and type(data.platform) == "string" and string.len(data.platform) < 1 then
        data.platform = nil
    end


    -- 处理web的小数问题 能变成整数就能变成整数
    for k,v in pairs(data.receive_value) do
        if type(v) == "number" then
            if math.floor(v) == v then
                data.receive_value[k] = math.floor(v)
            end
        end
    end
    if data.uuids and type(data.uuids) == "table" then
        for k,v in pairs(data.uuids) do
            if type(v) == "number" then
                if math.floor(v) == v then
                    data.uuids[k] = math.floor(v)
                end
            end
        end
    end
    if not data.mail or not next(data.mail) or not data.mail.title or 
            not data.mail.context or not data.mail.reason or not data.mail.op_user then

        dump(data,"send_mail data.xxxxx 2 error:")
        return 1001
    end

    data.mail.context = string.gsub(data.mail.context,"\\","\\\\")
    data.mail.context = string.gsub(data.mail.context,"\"","\\\"")

    local _props = {string.format("\"content\":\"%s\"",data.mail.context)}
    for _name,_value in pairs(data.mail.props) do
        if type(_value) == "number" then
            _props[#_props + 1] = string.format("\"%s\":%s",_name,_value)
        elseif type(_value) == "table" then
            _props[#_props + 1] = string.format("\"%s\":%s",_name,cjson.encode(_value))
        end
    end

    -- 构造参数
    local arg = 
    {
        receive_type = data.receive_type,
        receive_value = data.receive_value,
        market_channel = data.market_channel,
        platform = data.platform,
        uuids = data.uuids,
        email=
        {
            type="native",
            title=data.mail.title,
            sender="system",
            valid_time=os.time() + 3600 * 24, -- x 小时后过期（过期自动领取）
            data = "{" .. table.concat(_props,",") .. "}",
        }
    }

    -- 调用邮件服务
    return skynet.call(DATA.service_config.email_service,"lua",
                                            "external_send_email",
                                            arg,
                                            data.mail.op_user,
                                            data.mail.reason)
    
end


function CMD.block_player(_data_json)
    
    local ok,data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return 1001
    end

    if not data then
        print("web manage block_player 1001.1 error:",_data_json)
        return 1001
    end

    return skynet.call(DATA.service_config.data_service,"lua","block_player",data.player_id,data.reason,data.op_user)
end

function CMD.unblock_player(_data_json)
    
    local ok,data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return 1001
    end

    if not data then
        print("web manage unblock_player 1001.1 error:",_data_json)
        return 1001
    end
    
    return skynet.call(DATA.service_config.data_service,"lua","unblock_player",data.player_id,data.reason,data.op_user)
end

function CMD.broadcast(_data_json)
    
    local ok,data = xpcall(cjson.decode,basefunc.error_handle,_data_json)
    if not ok then
        return 1001
    end

    if not data then
        print("web manage broadcast 1001.1 error:",_data_json)
        return 1001
    end

    skynet.send(DATA.service_config.broadcast_center_service,"lua","broadcast",data.channel,data.data)
    
    return 0
end

function CMD.get_player_by_id(_player_id)
    local _reg = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register")
    if _reg then
        return {
            platform = _reg.platform,
            market_channel = _reg.market_channel,
            vip_level = 0
        }
    else
        return nil,2150
    end
end
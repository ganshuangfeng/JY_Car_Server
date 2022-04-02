--- webclient. (skynet服务).
--
-- @module webclient
-- @usage local webclient = skynet.newservice("webclient")

local skynet = require "skynet_plus"
require "skynet.manager"
local base=require "base"
local webclientlib = require "webclient"
local webclient = webclientlib.create()
local CMD ={}
local requests = nil

-- session ,在 CMD 函数的 开始处 取得 有效
local last_session = 0

local function resopnd(request, result)
    if not request.response then
        return
    end

    local content, errmsg = webclient:get_respond(request.req) 
    local info = webclient:get_info(request.req) 
     
    if result == 0 then
        request.response(true, true, content, info)
    else
        request.response(true, false, errmsg, info)
    end
end

local function query()
    while next(requests) do
        local finish_key, result = webclient:query()
        if finish_key then
            local request = requests[finish_key];
            assert(request)

            xpcall(resopnd, function() print(debug.traceback()) end, request, result)

            webclient:remove_request(request.req)
            requests[finish_key] = nil
        else
            skynet.sleep(1)
        end
    end 
    requests = nil
end

--- 请求某个url
-- @function request
-- @string url url
-- @tab[opt] get get的参数
-- @param[opt] post post参数，table or string类型 
-- @bool[opt] no_reply （by lyx：废弃，改用 session 自动判断） 使用skynet.call则要设置为nil或false，使用skynet.send则要设置为true
-- @cookie[opt] 可传递 cookie ， name => value
-- @treturn bool 请求是否成功
-- @treturn string 当成功时，返回内容，当失败时，返回出错原因
-- @usage skynet.call(webclient, "lua", "request", "http://www.dpull.com")
-- @usage skynet.send(webclient, "lua", "request", "http://www.dpull.com", nil, nil, true)
-- function CMD.request(url, get, post, no_reply)
function CMD.request(url, get, post, cookie)

    if "running" ~= base.DATA.current_service_status then
        print("webclient_service will close refuse request")
        return skynet.retpack(false,"request error")
    end

    if get then
        local i = 0
        for k, v in pairs(get) do
            k = webclient:url_encoding(k)
            v = webclient:url_encoding(v)

            url = string.format("%s%s%s=%s", url, i == 0 and "?" or "&", k, v)
            i = i + 1
        end
    end

    if post and type(post) == "table" then
        local data = {}
        for k,v in pairs(post) do
            k = webclient:url_encoding(k)
            v = webclient:url_encoding(v)

            table.insert(data, string.format("%s=%s", k, v))
        end   
        post = table.concat(data , "&")
    end   

    local _cookie_str
    if cookie then
        if type(cookie) == "string" then
            _cookie_str = cookie
        elseif type(cookie) == "table" and next(cookie) then
            local _strs = {}
            for k,v in pairs(cookie) do
                _strs[#_strs + 1] = webclient:url_encoding(tostring(k)) .. "=" .. webclient:url_encoding(tostring(v))
            end

            --_cookie_str = "Cookie: " .. table.concat(_strs,"; ")
            _cookie_str = table.concat(_strs,"; ")
        end
    end

    local req, key = webclient:request(url, post,nil,_cookie_str)
    if not req then
        return skynet.retpack(false,"request error")
    end
    assert(key)

    local response = nil
    --if not no_reply then
    if last_session ~= 0 then -- by lyx
        response = skynet.response()
    end

    if requests == nil then
        requests = {}
        skynet.fork(query)
    end

    requests[key] = {
        url = url, 
        req = req,
        response = response,
    }

    --if no_reply then
    if last_session == 0 then -- by lyx
        return skynet.retpack(true,"request has send")
    end
end

function CMD.request_post_json(url, json, no_reply)

    if "running" ~= base.DATA.current_service_status then
        print("webclient_service will close refuse request")
        return skynet.retpack(false,"request error")
    end

    local req, key = webclient:request(url, json)
    webclient:set_httpheader(req, "Content-Type:application/json")
    
    if not req then
        return skynet.retpack(false,"request error")
    end
    assert(key)

    local response = nil
    if not no_reply then
        response = skynet.response()
    end

    if requests == nil then
        requests = {}
        skynet.fork(query)
    end

    requests[key] = {
        url = url, 
        req = req,
        response = response,
    }

    if no_reply then
        return skynet.retpack(true,"request has send")
    end
end

function CMD.request_post_json_heads(url, json, heads ,no_reply)

    if "running" ~= base.DATA.current_service_status then
        print("webclient_service will close refuse request")
        return skynet.retpack(false,"request error")
    end

    local req, key = webclient:request(url, json)
    if heads then
        webclient:set_httpheader(req, table.unpack(heads))
    else
        webclient:set_httpheader(req, "Content-Type:application/json")
    end
    
    if not req then
        return skynet.retpack(false,"request error")
    end
    assert(key)

    local response = nil
    if not no_reply then
        response = skynet.response()
    end

    if requests == nil then
        requests = {}
        skynet.fork(query)
    end

    requests[key] = {
        url = url, 
        req = req,
        response = response,
    }

    if no_reply then
        return skynet.retpack(true,"request has send")
    end
end

-- 关机的时候
-- 5 秒后允许关闭 5s都完成不了请求，那么就丢弃了

function CMD.stop_service()
	skynet.retpack(base.CMD.stop_service())
end
function CMD.get_service_status()
	skynet.retpack(base.CMD.get_service_status())
end
function CMD.self()
	skynet.retpack(base.CMD.self())
end

-- by lyx 为接口兼容
function CMD.set_service_name(_service_name)
    skynet.retpack()
end
-- by lyx 为接口兼容
function CMD.sys_start(_service_config)
    return CMD.start(_service_config)
end

function CMD.start(_service_config)

    skynet.ret()
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, command, ...)
        last_session = session
        local f = assert(CMD[command])
        f(...)
    end)
end)

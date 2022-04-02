local skynet = require "skynet_plus"
local cjson = require "cjson"
local basefunc = require "basefunc"
require "printfunc"

cjson.encode_sparse_array(true,1,0)

local this = {}

-- 返回 code
function this.encode_code(code)
    return string.format("{\"result\":\"%s\"}",tostring(code))
end
-- 返回 value 或 nil,code
function this.encode_value_code(value,code)
    if value then
        return cjson.encode({value=value,result = "0"})
    else
        return string.format("{\"result\":\"%s\"}",tostring(code))
    end    
end

-- 返回 true 或 false + code
function this.encode_bool_code(ok,code)
    if ok then
        return cjson.encode({result = "0"})
    else
        return string.format("{\"result\":\"%s\"}",tostring(code))
    end    
end

-- 返回 table 或 nil,code
function this.encode_data_code(data,code)
    if data then
        data.result = data.result or "0" -- 如果 有，则保持原样
        return cjson.encode(data)
    else
        return string.format("{\"result\":\"%s\"}",tostring(code))
    end    
end

-- 返回一个或多个值，不做额外处理
function this.encode_data(...)
    return cjson.encode({...})
end

-- 返回一个值，不做额外处理
function this.encode_data_single(_data)
    return cjson.encode(_data)
end

-- 返回字符串： 原样返回，不处理
function this.return_string(...)
    local _t = table.pack(...)
    if _t.n == 0 then
        return "nil"
    elseif _t.n == 1 then
        return _t[1]
    else
        for i=1,_t.n do
            _t[i] = tostring(_t[i])
        end

        return "[" .. table.concat(_t,",") .. "]"
    end
end

-- 返回单个字符串
function this.return_single_string(_data)
    if "table" == type(_data) then
        return basefunc.tostring(_data)
    else
        return tostring(_data)
    end
end

--[=[ web 后台 api 专用返回函数
    返回 json 对象:
     {
         html = html文本,
         charts = 
         {
             chartname1=
             {
                title=标题,
                style=line / dot,
                axis_name=[横轴名称, 纵轴名称],
                data=[["xxxx",5],["xxxx",7]["xxxx",8]["xxxx",88]],
             },
             chartname2=
         }
     }
--]=]
function this.return_web_admin(_data)
    if "table" == type(_data) then
        return cjson.encode(_data)
    else
        return cjson.encode({
            html = _data
        })
    end
end

function this.call_service(path,fname,host,request,cmd_defines,default_method)

    local cmd_defines = cmd_defines[fname]

    if not cmd_defines then
        return 404,"not found:" .. tostring(path)
    end


    -- 无参数定义  默认为 post 方式
    if (cmd_defines.method or default_method) == "post" or not cmd_defines.param then

        return 200,cmd_defines.ret(skynet.call(host.service_config[cmd_defines.svr],"lua",cmd_defines.cmd or fname,request.body))
        
    else
        local _params = {}

        local _req_data = request.get
        if _req_data and type(_req_data) == "table" then
            for i,v in ipairs(cmd_defines.param) do
                if v == "..." then
                    _params[i] = _req_data  -- ... 表示所有参数
                else
                    _params[i] = _req_data[v]
                end
            end
        end

        return 200,cmd_defines.ret(skynet.call(host.service_config[cmd_defines.svr],"lua",cmd_defines.cmd or fname,table.unpack(_params,1,#cmd_defines.param)))
    end
end


function this.handler(cmd_defines,default_method)

    default_method = default_method or "get"
    
    return function(dir_names,path,host,request,web_filereader)
        local _fname = dir_names[2]

        local ok,code,_text = xpcall(this.call_service,basefunc.error_handle,path,_fname,host,request,cmd_defines,default_method)

        if ok then
            return true,code,_text
        else
            local _info = {
                dir_names=dir_names,
                path=path,
                request=request,
                code=code,
            }
            local _err_str = "sczd api call error:" .. basefunc.tostring(_info)
            print(_err_str)
            return true,500,_err_str
        end
    end
end

return this

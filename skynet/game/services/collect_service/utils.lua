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

require "data_func"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("utils",{
    
    data = {},
    
    cache = basefunc.cache.new()
})

local LF = base.LocalFunc("utils")

function LF.on_load()

    -- 60 秒清理一次
    skynet.timer(60,function() LF.clear_cool_data() end)

end

-- 清理冷数据
function LF.clear_cool_data()

    -- 每次最多清理数量
    local _now = os.time()
    for i=1,2000 do

        -- 最低 保留 1000 条
        if LD.cache.size < 1000 then
            break
        end
        
        local _ts,_name,_type = LD.cache:tail()

        -- 最低保留 1 天
        if _now - _ts < 86400 then
            break
        end

        -- 清除
        basefunc.to_keys(LD.data,nil,_name,_type)
        LD.cache:pop()

    end
end

function CMD.get_extend_var(_name,_type)

    local _value = basefunc.from_keys(LD.data,_name,_type)
    if not _value then
        local sql = PUBLIC.format_sql("select value from web_extend_data where name=%s",_name)
        local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",sql)
        if ret.errno then
            print(string.format("sql error: sql=%s\nerr=%s\n",sql,basefunc.tostring( ret )))
            return {result=1010}
        end

        if not ret[1] then
            return {result=1} -- 不存在
        end

        _value = ret[1].value
        basefunc.to_keys(LD.data,_value,_name,_type)
    end

    LD.cache:hot(_name,_type)
    
    return {result=0,value=_value} 
end

function CMD.set_extend_var(_name,_type,_value)
    basefunc.to_keys(LD.data,_value,_name,_type)

    local data = {
        name=_name,
        type=_type,
        value=_value,
    }

    LD.cache:hot(_name,_type)

    local sql = PUBLIC.safe_insert_sql("web_extend_data",data,{"name","type"})
    skynet.call(DATA.service_config.data_service,"lua","db_exec",sql)

    return {result=0}
end

return LF
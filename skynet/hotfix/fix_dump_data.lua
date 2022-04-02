--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：测试
-- 使用方法：
--  call collect_service exe_file "hotfix/common.lua"
-- 

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
require "normal_enum"
require "printfunc"


local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

local function write_sql_dump(_queue,_file)
    local _data = {}
    
    local _count = 0
    for v in _queue:values() do
        _data[#_data + 1] = v

        _count = _count + 1
        if _count > 3000 then
            break;
        end
    end

    basefunc.path.write(_file,table.concat(_data,"\n"))
end

return function()

    write_sql_dump(DATA.sql_queue_fast,"./fast_sql_dump.sql")
    write_sql_dump(DATA.sql_queue_slow,"./slow_sql_dump.sql")

    
    return "完成!"

end
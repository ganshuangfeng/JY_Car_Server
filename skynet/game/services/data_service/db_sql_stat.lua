--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：sql 语句统计： 内部调试用
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
require"printfunc"
require "data_func"
local mysql = require "skynet.db.mysql"

local monitor_lib = require "monitor_lib"

require "normal_enum"

local data_common = require "data_service.data_common"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


local LF = base.LocalFunc("db_sql_stat")
local LD = base.LocalData("db_sql_stat",{

    -- 统计数据 
    stat_data = {
        begin_time = os.time(), -- 开始统计的时间
        total_count = 0, -- 总条数
        parts = {}, -- 每个部分的条数： [名称]_[类型] => {count=数量,last=最近20条}
    },

    -- 统计数据历史记录：数量最多的20个记录
    stat_data_his = {},
})

function LF.init()
    skynet.timer(30,function() LF.reset_stat_data() end)
end

function LF.reset_stat_data()
    if LD.stat_data.total_count > 0 then
        LD.stat_data_his[#LD.stat_data_his + 1] = LD.stat_data
        LD.stat_data = {
            begin_time = os.time(), -- 开始统计的时间
            total_count = 0, -- 总条数
            parts = {}, -- 每个部分的条数： [名称]_[类型] => {count=数量,last=最近20条}
        }

        table.sort(LD.stat_data_his,function(v1,v2) return v1.total_count > v2.total_count end)
        if #LD.stat_data_his > 20 then
            LD.stat_data_his[#LD.stat_data_his] = nil
        end
    end
end

function LF.stat_sql(_sql,_metadata)

    _metadata = _metadata or PUBLIC.get_sql_metadata(_sql)

    LD.stat_data.total_count = LD.stat_data.total_count + 1

    local _hash = (_metadata.name or "") .. "|" .. (_metadata.type or "")
    local _stat = LD.stat_data.parts[_hash] or {
        count = 0,
        last = {},
    }
    LD.stat_data.parts[_hash] = _stat

    _stat.count = _stat.count + 1
    _stat.last[_stat.count % 20] = _sql
end


return LF
--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：服务器管理函数库： 停机；临时关闭游戏
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local min = math.min
local max = math.max

local LD = base.LocalData("server_manager_lib",{

    -- 关机广播已发送的 最后序号
    last_broadcast = nil,

})

local LF = base.LocalFunc("server_manager_lib")

function LF.init()

    -- 整个系统只能初始化一次（所有节点）
    if skynet.call(DATA.service_config.center_service,"lua","get_data_map","server_manager","is_init") then
        error("module server_manager_lib only can init once!")
    end
    skynet.call(DATA.service_config.center_service,"lua","set_data_map","server_manager","is_init",true)

    -- 全局数据结构（所有节点共享）
    skynet.set_global_data("server_manager_data",{

        -- 服务器启动时间
        server_start_time = os.time(),

        shutdown_time = nil,         -- 关机时间

        -- 关闭的模块
        shutdown_module = {
            freestyle_game = nil, -- 设为 true 为 关闭
            fishing_game = nil,
            fishing_match_game = nil,
            freestyle_qhb_game = nil,
            normal_match_game = nil,
            tyddz_freestyle_game = nil,
        },
     })

     skynet.timer(5,function() LF.check_shutdown_broadcast() end)
end

-- 检查/发送 停服 广播
function LF.check_shutdown_broadcast()

    local _gdata = skynet.get_global_data("server_manager_data")

    if not _gdata or not _gdata.shutdown_time then
        return
    end

    local _cd = _gdata.shutdown_time - os.time()

    local _cfg = nodefunc.get_global_config("server_manager_config")

    local _mock = skynet.getcfg("mock_shutdown_server")

    -- 从之前发送过的 下一个开始
    local _start_i = (LD.last_broadcast or #_cfg.shutdown_broadcast) - 1
    for i=_start_i,1,-1 do
        local v = _cfg.shutdown_broadcast[i]

        if v[1] >= _cd then

            local _content = os.date(v[2],_gdata.shutdown_time)

            if _mock then
                print(string.format("【模拟广播%d,即将停服(倒计时%d)】%s",i,_cd,_content))
            end

            skynet.send(DATA.service_config.broadcast_center_service,"lua","broadcast",1,{
                type=2,
                format_type=1,
                content=_content,
            })

            LD.last_broadcast = i
            break -- 一次（5秒）只发送一个
        end
    end

end

-- 设置关机时间
function LF.set_shutdown_time(_time)

    local _gdata = skynet.get_global_data("server_manager_data")

    if _gdata then

        _gdata = basefunc.deepcopy(_gdata)

        _time = tonumber(_time)

        -- 重新设置了时间，则 清除已发送记录
        if _time ~= _gdata.shutdown_time then
            LD.last_broadcast = nil
        end

        _gdata.shutdown_time = _time

        skynet.set_global_data("server_manager_data",_gdata)

        return true
    end

    return false
end

function LF.get_shutdown_time()
    local _gdata = skynet.get_global_data("server_manager_data")
    return _gdata and _gdata.shutdown_time
end

function LF.get_shutdown_cd()
    local _gdata = skynet.get_global_data("server_manager_data")
    return _gdata and _gdata.shutdown_time and (_gdata.shutdown_time-os.time()) or nil
end

-- 注意，如果不传入 _copy = true，则 不能修改这里面的值
function LF.get_server_manager_data(_copy)
    local _gdata = skynet.get_global_data("server_manager_data")
    if _copy then
        return basefunc.deepcopy(_gdata)
    else
        return _gdata
    end
end

-- 模块是否已关闭
function LF.module_is_shutdown(_module_name)

    local _gdata = skynet.get_global_data("server_manager_data")
    if not _gdata then 
        return false
    end

    -- 先判断关闭模块
    if _gdata.shutdown_module[_module_name] then
        return true
    end

    -- 判断关机准备时间
    if not _gdata.shutdown_time then
        return false
    end

    local _cfg = nodefunc.get_global_config("server_manager_config")
    if not _cfg.shudown_prepare_time[_module_name] then
        return false
    end

    if _gdata.shutdown_time - os.time() <= _cfg.shudown_prepare_time[_module_name] then
        return true
    end
    
    return false
end

return LF	
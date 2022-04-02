--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 装备升星管理器
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "client.crypt"
-- crypt.hmac64_md5
require "data_func"

local md5 = require "md5"
-- md5.hmacmd5

require "normal_enum"
require "printfunc"

require "common_data_manager_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("data_manager",{

    -- 当前段位赛 id 
    current_period_id = nil,

    -- 玩家 段位赛的数据 
    player_data = nil,

    -- 玩家已经领取的段位奖励
    player_awards_store = nil,

})

local LF = base.LocalFunc("data_manager")

function LF.init()

    -- 当期编号，临时处理： 没有则自动开始新的一期
    LD.current_period_id = DATA.system_variant["current_duanwei_period_id"]
    if (LD.current_period_id or 0) == 0 then
        LD.current_period_id = PUBLIC.auto_inc_id("current_duanwei_period_id")
    end

    LD.player_data = basefunc.server_class.data_manager_cls.new({
        load_data = function(_key) return LF.load_player_data(_key)  end
    },tonumber(skynet.getenv("data_man_cache_size")) or 40000)

    LD.player_awards_store = basefunc.server_class.data_manager_cls.new({
        load_data = function(_key) return LF.load_player_awards_store(_key)  end
    },tonumber(skynet.getenv("data_man_cache_size")) or 40000)

end


function LF.load_player_data(_user_id)
    local _ret,_err = PUBLIC.db_query_va("select * from duanwei_player_data where period_id=%s and player_id=%s;",LD.current_period_id,_user_id)
    if _err then
        error(_err)
    end

    return _ret and _ret[1]
end

function LF.load_player_awards_store(_user_id)
    local _ret,_err = PUBLIC.db_query_va("select * from duanwei_awards_store where period_id=%s and player_id=%s;",LD.current_period_id,_user_id)
    if _err then
        error(_err)
    end

    local _data = {}
    for _,v in ipairs(_ret) do
        local ok, _awards = xpcall(cjson.decode,basefunc.error_handle,v.awards)
        if ok then
            basefunc.to_keys(_data,_awards,v.grade,v.level)
        end
    end

    return _data
end


-- 默认的 分数和段位
function LF.player_init_data(_user_id)

    return {
        period_id = LD.current_period_id,
        player_id = _user_id,
        score = 0,
        grade = 1,
        level = 1,
    }
end

function LF.safe_modify_data(_user_id,_data)
    local _old = LD.player_data:get_data(_user_id)

    local _up_data = nil

    if _old then
        _up_data = basefunc.changes(_old,_data,true)

        if not _up_data then
            return
        end
    else
        _old = _data
        _up_data = _old
    end 

    _old.period_id = LD.current_period_id
    _old.player_id = _user_id

    local _sql = PUBLIC.safe_insert_sql("duanwei_player_data",{
        period_id=_old.period_id,  -- 未知原因： _old 表中 有 2,3 这样的数字 key
        player_id=_old.player_id,
        score=_old.score,
        grade=_old.grade,
        level=_old.level,
    },{"period_id","player_id"})

    local _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")
    LD.player_data:add_or_update_data(_user_id,_old,_qname,_qid)
end

-- 得到段位赛数据
function CMD.get_duanwei_data(_user_id)
    local _ret = LD.player_data:get_data(_user_id)
    if _ret and not _ret.score then
        print.duanwei_error("duanwei data center,get_duanwei_data 111, score is nil:",basefunc.tostring({_user_id,_ret}))
    end

    if not _ret then
        _ret = LF.player_init_data(_user_id)
        if not _ret.score then
            print.duanwei_error("duanwei data center,get_duanwei_data 222, score is nil:",basefunc.tostring({_user_id,_ret}))
        end
        LF.safe_modify_data(_user_id,_ret)
        if not _ret.score then
            print.duanwei_error("duanwei data center,get_duanwei_data 333, score is nil:",basefunc.tostring({_user_id,_ret}))
        end
    end

    return _ret
end

-- 修改段位赛数据
function CMD.update_duanwei_data(_user_id,_data)
    LF.safe_modify_data(_user_id,_data)
end

-- 判断奖励是否领取过
function CMD.check_duanwei_awards_is_taked(_user_id,_grade,_level,_asset_name)
    local _taked_awards = LD.player_awards_store:get_data(_user_id)
    if not _taked_awards then
        return false
    end

    local _taked_tmp = _taked_awards and basefunc.from_keys(_taked_awards,_grade,_level,_asset_name)
    if not _taked_tmp then
        return false
    end

    return true
end

-- 得到 还未领取的 段位奖励
-- 返回：数组{grade=_grade,level=,award=数组{asset_type=,asset_value=}}
function CMD.get_duanwei_untake_awards_list(_user_id,_grade,_level)


    local _ret = {}

    while _grade do

        local _duan_d = PUBLIC.get_duanwei_config(_grade,_level)
        if not _duan_d then
            break
        end

        local _award = {}
        for _,v in ipairs(_duan_d.up_award) do
            
            if not CMD.check_duanwei_awards_is_taked(_user_id,_grade,_level,v.asset_type) then
                table.insert(_award,{
                    asset_type = v.asset_type,
                    asset_value = v.asset_count,
                })
            end
        end

        if next(_award) then
            table.insert(_ret,{
                grade = _grade,
                level = _level,
                award = _award,
            })

        end
        
        _grade,_level = PUBLIC.calc_prev_level(_grade,_level)
    end

    return _ret
end

-- 玩家领取奖励：记录为已领取
-- 参数 _asset_type 可选
-- 返回： 实际 记录的已领取财富 或 nil + code
function CMD.add_player_awards_store(_user_id,_grade,_level,_asset_type)

    local _duan_d = PUBLIC.get_duanwei_config(_grade,_level)
    
    if not _duan_d then
        print("add_player_awards_store error,grade level too large:",_user_id,_grade,_level,_asset_type)
        return nil,2401 -- 超出配置允许的级别
    end

    local _cur_take_awards = {}

    local _d = LD.player_awards_store:get_data(_user_id)
    local _taked_awards = basefunc.safe_keys(_d,nil,_grade,_level)

    for _,v in ipairs(_duan_d.up_award) do
            
        if not _taked_awards[v.asset_type] then
            if not _asset_type or _asset_type == v.asset_type then
                _taked_awards[v.asset_type] = v.asset_count
                table.insert(_cur_take_awards,{
                    asset_type = v.asset_type,
                    asset_value = v.asset_count,
                })
            end
        end
    end

    if not next(_cur_take_awards) then
        print("add_player_awards_store ,not to take:",_user_id,_grade,_level,_asset_type)
        return nil,5101
    end

    

    local _dupdate = {
        period_id=LD.current_period_id,
        player_id=_user_id,
        grade=_grade,
        level=_level,
        awards=cjson.encode(_taked_awards),
    }
    local _sql = PUBLIC.safe_insert_sql("duanwei_awards_store",_dupdate,{"period_id","player_id","grade","level"})
    print("add_player_awards_store ,insert info sql:",_sql)
    local _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")
    LD.player_awards_store:add_or_update_data(_user_id,_d,_qname,_qid)

    return _cur_take_awards
end

return LF
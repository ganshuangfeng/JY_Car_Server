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

local LD = base.LocalData("config_manager",{

    --[[
        阶级配置：
        jieji_id => {
            jieji_name=,
            score={起点值,终点值(不含)},
            fight_award = {
                {asset_type=,asset_count,prob=},
                。。。
            },

            -- 段位配置
            duanwei = {
                duanwei_id => {
                    duanwei_name=,
                    score={起点值,终点值(不含)},
                    up_award = {
                        {asset_type=,asset_count},
                        。。。
                    }
                }
            }
        }
    --]]    
    jieduan_config = nil,

    -- 积分规则
    -- 连胜/败 次数 => {win_score=,lost_score=}
    score_rule_config = nil,
})

local LF = base.LocalFunc("config_manager")

function LF.init()
    nodefunc.query_global_config("duanwei_config_server",basefunc.hotfunc(LF,"refresh_config"))
end

function LF.refresh_config(_config)

    -- id => 数组{asset_type=,asset_count,prob=}
    local _fight_award = {}
    for _,_d in pairs(_config.fight_award) do
        local _awards = basefunc.safe_keys(_fight_award,nil,_d.award_config_id)
        table.insert(_awards,basefunc.deepcopy(_d))
    end
    
    -- id => 数组{asset_type=,asset_count}
    local _up_award = {}
    for _,_d in pairs(_config.up_award) do
        local _awards = basefunc.safe_keys(_up_award,nil,_d.award_config_id)
        table.insert(_awards,basefunc.deepcopy(_d))
    end

    -- 阶级数据
    local _last_jieji = nil
    local _jieduan_config = {}
    for _,_d in ipairs(_config.jieji) do
        local _jieji = {
            jieji_id = _d.jieji_id,
            jieji_name = _d.jieji_name,
            score = {_d.score,math.maxinteger},
            fight_award = _fight_award[_d.fight_award],

            duanwei = {}, -- 后续再填写
        }
        _jieduan_config[_d.jieji_id] = _jieji
        if _last_jieji then
            _last_jieji.score[2] =  _jieji.score[1] -- 设置上一个的 上限
        end

        _last_jieji = _jieji
    end

    -- 段位数据
    local _last_duanwei = nil
    for _,_d in ipairs(_config.duanwei) do

        local _jieji = _jieduan_config[_d.jieji_id]

        local _duanwei = {
            jieji_id = _d.jieji_id,
            duanwei_id = _d.duanwei_id,
            duanwei_name = _d.duanwei_name,
            score = {_jieji.score[1] + _d.score,math.maxinteger},
            up_award = _up_award[_d.up_award],
        }
        _jieji.duanwei[_d.duanwei_id] = _duanwei
        if _last_duanwei then
            _last_duanwei.score[2] = _duanwei.score[1] -- 设置上一个的 上限
        end

        _last_duanwei = _duanwei
    end

    -- 积分规则数据
    local _score_rule_config = {}
    for _,_d in pairs(_config.score_rule) do
        _score_rule_config[_d.count] = basefunc.deepcopy(_d)
    end

    LD.jieduan_config = _jieduan_config
    LD.score_rule_config = _score_rule_config
end

-- 计算上一段位， 返回 ： nil(已到最小)  或 _new_grade,_new_level
function PUBLIC.calc_prev_level(_cur_grade,_cur_level)
    
    local _new_grade = _cur_grade
    local _new_level = _cur_level - 1

    -- 本阶级还有
    if _new_level > 0 then
        return _new_grade,_new_level
    end

    -- 跨越阶级 

    _new_grade = _new_grade - 1

    if _new_grade < 1 then
        return nil   -- 已经到了 最低
    end

    return _new_grade,#LD.jieduan_config[_new_grade].duanwei

end

-- 计算下一段位， 返回 ： nil(已到最大)  或 _new_grade,_new_level
function PUBLIC.calc_next_level(_cur_grade,_cur_level)
    
    local _new_grade = _cur_grade
    local _new_level = _cur_level + 1

    -- 本阶级还有
    if LD.jieduan_config[_cur_grade].duanwei[_new_level] then
        return _new_grade,_new_level
    end

    -- 跨越阶级 

    _new_grade = _new_grade + 1
    _new_level = 1

    if LD.jieduan_config[_new_grade] and LD.jieduan_config[_new_grade].duanwei[_new_level] then
        return _new_grade,_new_level
    end
    
    return nil
end

function PUBLIC.get_duanwei_config(_grade,_level)
    return LD.jieduan_config[_grade] and LD.jieduan_config[_grade].duanwei[_level]
end

-- 调整托管的 积分、段位 ，以便和真人对战
-- 参数 _game_info ： 参见 pvp 场调度托管的参数
-- 返回： {score=,grade=,level=}
function CMD.scale_tuoguan_for_fight(_game_info)

    --print.pvp_debug("xxxxxxxxxxpvp_debugxxxxxxxxxxx scale_tuoguan_for_fight::",basefunc.tostring(_game_info))

    if math.random(100) < 70 then -- 取 上下 100 分随机
        local _score = math.max(0,(_game_info.pvp_score - 100) + math.random(200))
        local _grade,_level = CMD.calc_duanwei_of_score(_score)
        return {
            score = _score,
            grade = _grade,
            level = _level,
        }
    else
        -- 先选择段位：取上下 跨一级 随机
        local _func = math.random(100) < 50 and PUBLIC.calc_next_level or PUBLIC.calc_prev_level
        local _grade,_level = _func(_game_info.pvp_grade,_game_info.pvp_level)
        if not _grade then
            _grade,_level = _game_info.pvp_grade,_game_info.pvp_level
        end

        -- 本段位内 调整分数
        local _duan_d = LD.jieduan_config[_grade].duanwei[_level]
        return {
            score = math.random(_duan_d.score[1],_duan_d.score[2]-1),
            grade = _grade,
            level = _level,
        }
    end
    
end

-- 根据积分得到段位
-- 返回：grade,level
function CMD.calc_duanwei_of_score(_score)
    local _cur_grade = 1
    local _cur_level = 1
    while true do

        local _duan_d = LD.jieduan_config[_cur_grade].duanwei[_cur_level]
        if _score < _duan_d.score[2] then
            return _cur_grade,_cur_level
        end

        -- 计算下一段位
        local _new_grade ,_new_level = PUBLIC.calc_next_level(_cur_grade,_cur_level)
        if not _new_grade then
            return _cur_grade,_cur_level
        end

        -- 还有下一个，继续
        _cur_grade,_cur_level = _new_grade ,_new_level
    end

    -- 不可能在这里来
    print("calc_duanwei_of_score error,can not found level:",_score,_cur_grade,_cur_level)
    return _cur_grade,_cur_level
end

--[[
    根据 段位、积分，计算 进度相关信息
    返回： {
        grade_all_level =,   当前大段位 充满需要的小段位数
        level_all_score =,   当前小段位 充满需要的分数
        level_cur_score =,   当前小段位 的当前分数
    }
    失败返回： nil ,_code
--]]
function CMD.calc_duanwei_progress(_score,_cur_grade,_cur_level)
    _cur_grade = _cur_grade or 1
    _cur_level = _cur_level or 1

    local _jieji_d = LD.jieduan_config[_cur_grade]
    local _duan_d = _jieji_d.duanwei[_cur_level]

    return {
        grade_all_level = #_jieji_d.duanwei,  -- 注意：要求 段位必须是从 1 开始连续的
        level_all_score = _duan_d.score[2] - _duan_d.score[1],
        level_cur_score = _score - _duan_d.score[1],
    }
end

--[[
    结算 战斗结果的奖励
    参数：
        _player_duanwei = {
            score =, -- 段位赛积分
            grade =, -- 段位赛 大阶级
            level =, -- 段位赛 小段位
        }
        _win             1 胜； -1 负； 0 平
        _hold_count      连续 输/赢的 局数
    返回：
        {
            duanwei = {
                score =,
                grade =,
                level =,
            },
            up_award = { -- 得到的奖励： 如果领取过了，则不发
                {asset_type=,asset_count},
                。。。
            },
            fight_award = {
                {asset_type=,asset_count},
                。。。
            },
            progress = { -- 进度信息
                grade_all_level =,   当前大段位 充满需要的小段位数
                level_all_score =,   当前小段位 充满需要的分数
                level_cur_score =,   当前小段位 的当前分数
            }
        }

    出错 返回 nil,code
--]]
function CMD.settlement_fight_award(_user_id,_player_duanwei,_win,_hold_count)

    -- 暂时不支持 平局 的情况
    if _win == 0 then
        return nil,1001
    end

    -- 计算积分。注意： 配置 count 必须连续
    local _sr_cfg = LD.score_rule_config[_hold_count] or LD.score_rule_config[#LD.score_rule_config]
    if not _sr_cfg then
        print("settlement_fight_award error,not found win/lost count config:",_hold_count)
        return nil,2401
    end

    local _new_core = math.max(0,_player_duanwei.score + (_win > 0 and _sr_cfg.win_score or (-_sr_cfg.lost_score)))
    local _new_grade,_new_level = CMD.calc_duanwei_of_score(_new_core)

    -- 生成结果
    local _ret = {
        duanwei = {
            score = _new_core,
            grade = _new_grade,
            level = _new_level,
        },
        up_award = {},
        fight_award = {},
        progress = CMD.calc_duanwei_progress(_new_core,_new_grade,_new_level),
    }

    -- up_award 中 当前段位 的奖励
    local _last_duan_d = LD.jieduan_config[_new_grade].duanwei[_new_level]
    if _last_duan_d then
        for _,v in ipairs(_last_duan_d.up_award) do
            if not CMD.check_duanwei_awards_is_taked(_user_id,_new_grade,_new_level,v.asset_type) then
                table.insert(_ret.up_award,{
                    asset_type = v.asset_type,
                    asset_value = v.asset_count,
                })
            end
        end
    end

    -- 战斗奖励
    if _win > 0 then
        local _award,_ = basefunc.random_select(LD.jieduan_config[_new_grade].fight_award,"prob")
        if _award then
            _ret.fight_award[1] = 
            {
                asset_type = _award.asset_type,
                asset_value = _award.asset_count,
            }
        end
    end
    
    return _ret
end


return LF
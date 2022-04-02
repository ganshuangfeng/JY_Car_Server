--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:13
-- 说明：段位赛相关函数库

local skynet = require "skynet_plus"
local base=require "base"
local nodefunc = require "nodefunc"
require "normal_enum"
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LF = base.LocalFunc("duanwei_lib")
local LD = base.LocalData("duanwei_lib",{

    
})


function LF.init()

    -- 
end

-- 判断玩家是否可以匹配在一起
function LF.check_match_players(_player_id1,_player_id2,_score_diff,_fight_diff)

    if skynet.getcfg("pvp_debug_force_real") then -- 强制匹配真人
        return true
    end

    -- 报名信息
    local _signup1 = DATA.all_player_info[_player_id1]
    local _signup2 = DATA.all_player_info[_player_id2]

    -- 不能跨 大段位
    if _signup1.pvp_grade ~= _signup2.pvp_grade then
        return false
    end

    -- 不能跨 2个 小段位
    if math.abs(_signup1.pvp_level-_signup2.pvp_level) > 1 then
        return false
    end

    if math.abs(_signup1.pvp_score-_signup2.pvp_score) > _score_diff then
        return false
    end
    
    if math.abs(_signup1.fight-_signup2.fight) > _fight_diff then
        return false
    end

    -- 匹配信息
    -- local _minfo1 = DATA.matching_entity.get_player_matching_info(_player_id1)
    -- local _minfo2 = DATA.matching_entity.get_player_matching_info(_player_id2)

    return true
end

-- 在池中 搜索匹配的玩家， 返回 池的索引
function LF.seatch_matching_pool_player(_matching_pool,_player_id,_score_diff,_fight_diff)

    for _pool_index , pool_data in pairs(_matching_pool) do
        if #pool_data > 0 and #pool_data < DATA.seat_count then
            -- 注意，假定总是 2 人桌子
            if LF.check_match_players(_player_id,pool_data[1],_score_diff,_fight_diff) then
                return _pool_index
            end
        end
    end
    return nil
end

return LF
 
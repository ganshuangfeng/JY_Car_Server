-- 分类托管 配置表
-- Author: lyx
-- Date: 2018/10/9
-- Time: 15:14
-- 说明：托管 配置
--

return 
{
    -- 托管场次等级。注意：不关服动态修改 不支持 增减，只能改参数
    tuoguan_games = 
    {
        {
            money={3000,300000},
            --vip_level={0,2},
            games =
            {
                {model="pvp",game_id=-1},
                {model="pvp",game_id=1},
                {model="pvp",game_id=2},
                {model="pvp",game_id=3},
                {model="pvp",game_id=4},
            }
        },
    }
}
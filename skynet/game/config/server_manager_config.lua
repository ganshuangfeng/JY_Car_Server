--
-- Author: lyx
-- Date: 2018/9/10
-- Time: 15:13
-- 说明：服务器管理配置
--

return 
{
	-- 各模块停服准备时间（秒），停服前的该时间关闭
	shudown_prepare_time = {
		freestyle_game = 180, -- 自由场，3分钟
		freestyle_lhd_game = 180, -- 金蛋大乱斗(龙虎斗)自由场，3分钟
		fishing_game = 0, -- 捕鱼， 10 秒
		fishing_match_game = 0, -- 捕鱼比赛，10 秒
		freestyle_qhb_game = 0, -- 抢红包，10 秒
		normal_match_game = 600, -- 比赛场，10 分钟
		tyddz_freestyle_game = 180, -- 听用斗地主, 3 分钟

		xiaoxiaole_game = 0,            -- 水果消消乐
		xiaoxiaole_shuihu_game = 0,     -- 水浒消消乐
		xiaoxiaole_caishen_game = 0,    -- 财神消消乐
		zajindan_game = 0,              -- 砸金蛋
		guess_apple_game = 30,           -- 种苹果
		jykp_game = 30,                  -- 鲸鱼快跑
		tantanle_game = 0,              -- 弹弹乐
},

	-- 计划任务：关机前发布 广播。 格式：倒计时(秒),广播文本
	shutdown_broadcast = {
		{60 ,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{70 ,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{300,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{310,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{600,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{610,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{900,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{910,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{1200,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{1210,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{1800,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
		{1810,"鲸鱼斗地主将于 %H:%M 进行服务器例行维护，届时将无法进行游戏，请大家注意游戏时间以免给您造成损失。"},
	},
}
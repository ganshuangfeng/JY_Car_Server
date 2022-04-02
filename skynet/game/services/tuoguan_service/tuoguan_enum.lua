--
-- Author: lyx
-- Date: 2018/10/9
-- Time: 15:13
-- 说明：配置和定义
--

-- 游戏类型 => 玩法文件
TUOGUAN_GAME =
{
	driver = "tuoguan_service.tuoguan_logic.game_driver",
	
}

-- 游戏模式 => 模式文件
TUOGUAN_MODEL =
{
	pvp = "tuoguan_service.tuoguan_logic.model_pvp",

}

--- ai 模块
TUOGUAN_AI_MODEL = {
	driver = "tuoguan_service.ai_grade_system.ai_grade_system"
}

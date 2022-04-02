---- ecs 组件例子
local base = require "base"

local com_name = "ecs_component_sample"

local LD = base.LocalData(com_name,{
	com_name = com_name,
})

local LF = base.LocalFunc(com_name)

function LF.create(_world)

	-- 组件 的 数据
	return {

	}

end



return LF


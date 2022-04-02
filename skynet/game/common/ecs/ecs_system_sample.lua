---- ecs 系统例子

local base = require "base"
local basefunc = require "basefunc"
require "printfunc"

local system_name = "ecs_system_sample"

local LD = base.LocalData(system_name,{
	sys_name = system_name
})

local LF = base.LocalFunc(system_name)

LF.extern = LF.extern or {}

---- 消息处理模块
LF.msg_deal = LF.msg_deal or {}

--[[
	参数：
		_world : 世界对象（必须）
--]]
function LF.create(_world)

	return {

		type = LD.sys_name,
		world = _world,

		--- 系统要处理点实体： id => 实体{组件列表}
		entities = {},
		
		--- 系统需要的组件： 名字数组
		components = { "com_1" , "com_2" },
	}

end

--- 当实体增加
function LF.on_entity_add(_self , _entity_id)
    
end

--- 当实体删除
function LF.on_entity_del(_self , _entity_id)

end


function LF.update(_self , _dt)

	for _entity_id,_entity in pairs(_self.entities) do

		

	end

end


return LF

local base = require "base"

local LD = base.LocalData("ecs_func",{

})

local LF = base.LocalFunc("ecs_func")


----- 检查实体是否是这个系统可以操作的
function LF.check_entity_is_for_system( _entity , _com_deal )
	if not _entity or not _com_deal then
		return false
	end

	if _entity and type(_entity) == "table" then
		for key,com_type in pairs( _com_deal ) do
			if not _entity[com_type] then
				return false
			end
		end
	end

	return true
end

return LF
------ 标签中心

local basefunc = require "basefunc"
local base = require "base"

local DATA = base.DATA 
local PUBLIC = base.PUBLIC
local CMD = base.CMD

---- 创建标签
function PUBLIC.add_tag( _owner , _tag , _tag_value)
	if _owner and type(_owner) == "table" then
		_owner.tag = _owner.tag or {}

		
		if not _owner.tag[_tag] then
			_owner.tag[_tag] = { value = _tag_value or true , tag_num = 0 }
		end

		local tar_data = _owner.tag[_tag]

		tar_data.value = _tag_value or true
		tar_data.tag_num = tar_data.tag_num + 1

	end
end
----- 删除标签
function PUBLIC.delete_tag(_owner , _tag)
	if _owner and type(_owner) == "table" then
		_owner.tag = _owner.tag or {}

		local tar_data = _owner.tag[_tag]
		if tar_data then
			tar_data.tag_num = tar_data.tag_num - 1
			if tar_data.tag_num <= 0 then
				_owner.tag[_tag] = nil
			end
		end
	end
end

-------
function PUBLIC.get_tag(_owner , _tag)
	if _owner and type(_owner) == "table" and _owner.tag and _owner.tag[_tag] then
		return _owner.tag[_tag].value or false
	end
	return nil
end



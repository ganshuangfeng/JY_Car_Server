----- 车辆  属性  库 

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA
DATA.car_prop_lib = {}
local C = DATA.car_prop_lib


--- 获得 一个车的 攻击属性值 ，没有buff 的时候就直接是 at 属性
function C.get_car_prop(_car , _prop_type , _org_value , _percent_base_value )
	---- 
	if _car.kind_type ~= DATA.game_kind_type.car then
		return _org_value or 0
	end


	local org_value = _org_value
	if not org_value then
		org_value = _car[_prop_type]
	end

	local real_value = org_value

	---- 应用 修改属性 buff
	if _car.buff and _car.buff[ "prop_modifier_buff" ] then
		for key,buff_obj in ipairs( _car.buff[ "prop_modifier_buff" ] ) do
			real_value = buff_obj:work( _prop_type , real_value , _percent_base_value )
		end
	end

	return real_value
end

---- 获得一个车的 技能的 暴击率 or 连击率
function C.get_skill_buff_value(  _skill_obj , _prop_type , _org_value , _percent_base_value )
	local org_value = _org_value
	if not org_value then
		org_value = _skill_obj.buff_prop[_prop_type] or 0
	end

	local real_value = org_value

	local _car = _skill_obj.owner

	---- 应用 buff
	if _car and _car.buff and _car.buff[ "skill_modifier_buff" ] then
		for key,buff_obj in ipairs( _car.buff[ "skill_modifier_buff" ] ) do
			real_value = buff_obj:work( _skill_obj , _prop_type , real_value , _percent_base_value )
		end
	end
	
	return real_value
end

---- 获得 type_id 配置 某个key 的值
function C.get_type_id_cfg_value( _player_info , _type_id , _key , _org_value )
	local org_value = _org_value
	if not org_value then
		org_value = DATA.chehua_skill_type_id_config[_type_id] and DATA.chehua_skill_type_id_config[_type_id][_key] or 0
	end

	local real_value = org_value

	---- 应用 buff
	if _car and _car.buff and _car.buff[ "type_id_cfg_buff" ] then
		for key,buff_obj in ipairs( _car.buff[ "type_id_cfg_buff" ] ) do
			real_value = buff_obj:work( _type_id , _key , real_value )
		end
	end
	
	

	return real_value

end

return C
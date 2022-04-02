------ 通用的权限管理器

local basefunc = require "basefunc"
require "printfunc"

local common_permission_manager = {}

local C = common_permission_manager

--- 是否给服务器用的
C.is_for_server = true
--- 加载的权限或标签的配置文件
C.loaded_cfg_name = nil

--- 权限配置数据
C.permission_cfg_data = {}

--- 共享条件
C.share_condition = {}

-- by lyx: id 动态权限 到名字的映射
C.act_permission_id_map = {}

-- by lyx: 类型 => {name1,name2,...}
C.type_map = {}

--- 用来做比较的原始数据
-- C.for_judge_original_data = {}

function C.load_config(_raw_config)
	if not _raw_config then
		return
	end

	C.permission_cfg_data = {}

	---- 共享条件
	local share_condition = {}
	if  _raw_config.share_condition then
		for key , data in pairs(_raw_config.share_condition) do
			share_condition[data.name] = share_condition[data.name] or {}
			local per_data = share_condition[data.name]

			per_data[#per_data + 1] = data
		end
	end

	C.share_condition = share_condition

	---- 条件
	local condition = {}
	if _raw_config.condi then
		for key , data in pairs(_raw_config.condi) do
			condition[data.id] = condition[data.id] or {}
			local per_data = condition[data.id]

			per_data[#per_data + 1] = data
		end
	end

	---- 处理 活动的权限 的表
	if _raw_config.act_permission then
		for id , data in pairs(_raw_config.act_permission) do
			if data.enable == 1 then

				---- 对应的条件判断集合
				if data.condi then
					data.condition_data = condition[ data.condi ]
				end

				data.is_act_permission = true

				-- by lyx 
				C.act_permission_id_map[data.id] = data.key

				C.permission_cfg_data[data.key] = data
			end
		end
	end

	---- 处理每个权限类型
	if _raw_config.main then
		for _key , data in pairs(_raw_config.main) do

			---- 对应的条件判断集合
			if data.condi then
				data.condition_data = condition[ data.condi ]

			end

			-- by lyx
			if type(data.type) == "string" then

				data.type = basefunc.string.trim(data.type)
				if "" == data.type then
					data.type = nil
				else
					C.type_map[data.type] = C.type_map[data.type] or {}
					C.type_map[data.type][_key] = data.key
				end
			else
				data.type = nil
			end

			C.permission_cfg_data[data.key] = data
		end
	end

	--dump(C.permission_cfg_data , "xxx----C.permission_cfg_data," .. C.loaded_cfg_name )
end

----- 初始化
function C.init( _is_client , _service_cfg , _use_for )
	C.is_for_server = not _is_client

	if C.is_for_server then
		C.loaded_cfg_name = _service_cfg or "permission_server_config"
		C.nodefunc = require "nodefunc"
		if C.nodefunc then
			C.nodefunc.query_global_config( C.loaded_cfg_name , function (...) C.load_config(...) end )
		end
	else
		---- 客户端自己加载权限配置文件
		--C.load_config( require ("xxx_config.lua") )
	end

	if _use_for == "agent" then
		C.asset_judge_module = require "permission_manager.permission_asset_judge_module_for_agnet"
	elseif _use_for == "center_service" then
		C.asset_judge_module = require "permission_manager.permission_asset_judge_module_for_center_service"
	elseif _use_for == "client" then
		C.asset_judge_module = GameButtonManager.ExtLoadLua("sys_qx", "permission_asset_judge_module_for_center_client")
	else
		C.asset_judge_module = require "permission_manager.permission_asset_judge_module_for_center_service"
	end

end

---- 销毁
function C.destroy()
	if C.is_for_server and C.nodefunc then
		C.nodefunc.clear_global_config_cb( C.loaded_cfg_name )
	end
end

-------- 设置 数据源
--[[
	_original_data  =  {
		vip_level	         vip等级
		acount_age	         距离首次登录时间的秒数 
		first_login_time	 首次登录的时间
		pay_sum	             充值累计(不包含礼包)
		max_pay	             最大单笔充值(不包含礼包)
		tag_vec              所有的标签集合
	}

--]]
--[[function C.set_original_data( _original_data )
	C.for_judge_original_data = _original_data
end--]]

---- 判断条件（内部用）
function C.judeg_condition( _original_data , _condition_data )
	local flag = true
	---- 如果没有原始数据，条件不成立
	if not _original_data or not next(_original_data) then
		return false
	end

	local is_asset_judge = string.find( _condition_data.var , "^asset_" )
	
	if not is_asset_judge then
		--- 通用的判断
		local func_name = "judeg_condition_".._condition_data.var

		if C[func_name] then
			flag = C[func_name]( _original_data , _condition_data  )
		else
			flag = C.judeg_condition_default( _condition_data.var , _original_data , _condition_data  )
		end
	else
		local tar_asset_key = string.sub( _condition_data.var , 7 )

		flag = C.asset_judge_module.judeg_condition_asset( tar_asset_key , _condition_data , _original_data.player_id )
	end
	

	return flag
end

--------------- ------------------------------------------------------------------------- ↓↓ 判断条件 ↓↓ -----------------------------------------------------
----- 判断 引用的共享条件
function C.judeg_condition_share_condition( _original_data , _condition_data )
	---- 如果没有共享条件
	if not C.share_condition[ _condition_data.value ] then
		return false
	end
	
	local ret = C.judge_condition_vec( C.share_condition[ _condition_data.value ] , _original_data )

	if _condition_data.judge == 5 then
		ret = not ret
	end

	return ret
end

----- 加一个默认的判断函数，只有原始数据的这个key值的是一个值而不是表时，才能使用这个默认的。
function C.judeg_condition_default(_key , _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data[_key] then
		return false
	end
	--print("xxxx-----------------judeg_condition_vip_level" , _original_data.vip_level , _condition_data.value , _condition_data.judge)
	return basefunc.compare_value( _original_data[_key] , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_vip_level( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.vip_level then
		return false
	end
	--print("xxxx-----------------judeg_condition_vip_level" , _original_data.vip_level , _condition_data.value , _condition_data.judge)
	return basefunc.compare_value( _original_data.vip_level , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_acount_age( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.acount_age then
		return false
	end
	--local acount_second = os.time() - _original_data.first_login_time

	--print("xxxx-----------------judeg_condition_acount_age")
	--return basefunc.compare_value( acount_second , _condition_data.value , _condition_data.judge )
	return basefunc.compare_value( _original_data.acount_age , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_first_login_time( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.first_login_time then
		return false
	end
	--print("xxxx-----------------judeg_condition_first_login_time")
	return basefunc.compare_value( _original_data.first_login_time , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_pay_sum( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.pay_sum then
		return false
	end
	--print("xxxx-----------------judeg_condition_pay_sum")
	return basefunc.compare_value( _original_data.pay_sum , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_max_pay( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.max_pay then
		return false
	end
	--print("xxxx-----------------judeg_condition_max_pay")
	return basefunc.compare_value( _original_data.max_pay , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_register_time( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.register_time then
		return false
	end
	--print("xxxx-----------------judeg_condition_register_time")
	return basefunc.compare_value( _original_data.register_time , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_last_login_time( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.last_login_time then
		return false
	end
	--print("xxxx-----------------judeg_condition_last_login_time")
	return basefunc.compare_value( _original_data.last_login_time , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_market_channel( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.market_channel then
		return false
	end
	--print("xxxx-----------------judeg_condition_market_channel")
	return basefunc.compare_value( _original_data.market_channel , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_tag_type( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.tag_vec or type(_original_data.tag_vec) ~= "table" or not next(_original_data.tag_vec) then
		return false
	end
	--print("xxxx-----------------judeg_condition_tag_type")
	--- 是否
	local value = type(_condition_data.value) == "table" and _condition_data.value or {_condition_data.value}

	for key, cond_value in ipairs(value) do
		local is_find = false
		for o_key , o_value in pairs(_original_data.tag_vec) do
			if cond_value == o_value then
				is_find = true
				break
			end
		end

		if _condition_data.judge == 2 then
			--- 包含
			if is_find then
				return true				
			end
		elseif _condition_data.judge == 5 then
			--- 不包含
			if is_find then
				return false
			end
		end

	end

	if _condition_data.judge == 2 then
		return false
	elseif _condition_data.judge == 5 then
		return true
	end
	return true
end

function C.judeg_condition_last_login_time_dist( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.last_login_time_dist then
		return false
	end
	--print("xxxx-----------------judeg_condition_last_login_time_dist" , _original_data.last_login_time_dist ,_condition_data.value , _condition_data.judge )
	return basefunc.compare_value( _original_data.last_login_time_dist , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_regress_time( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.regress_time then
		return false
	end
	--print("xxxx-----------------judeg_condition_market_channel")
	return basefunc.compare_value( _original_data.regress_time , _condition_data.value , _condition_data.judge )
end

function C.judeg_condition_regress_time_dist( _original_data , _condition_data )
	if not _original_data or not next(_original_data) or not _original_data.regress_time_dist then
		return false
	end
	--print("xxxx-----------------judeg_condition_market_channel")
	return basefunc.compare_value( _original_data.regress_time_dist , _condition_data.value , _condition_data.judge )
end

--------------- ------------------------------------------------------------------------- ↑↑ 判断条件 ↑↑ -----------------------------------------------------
------- 返回所有的权限key值
function C.get_all_permission_key()
	local ret_vec = {}

	if C.permission_cfg_data and type(C.permission_cfg_data) == "table" then
		for permission_key , data in pairs(C.permission_cfg_data) do
			ret_vec[ #ret_vec + 1 ] = permission_key
		end
	end

	return ret_vec
end

------ 返回所有的 act_permission key
function C.get_all_act_permission_cfg_data()
	local ret_vec = {}

	if C.permission_cfg_data and type(C.permission_cfg_data) == "table" then
		for permission_key , data in pairs(C.permission_cfg_data) do
			if data.is_act_permission then
				ret_vec[ data.key ] = data
			end
		end
	end
	--dump(ret_vec , "xxxx------------------------get_all_act_permission_cfg_data___ret_vec")
	return ret_vec
end

-- by lyx: 返回 默认值 ， actp类型的权限的默认的值。
function C.act_permission_default_value(_act_permi_key)

	-- 默认为 false 的前缀
	local _default_false = {
		"^actp_own_task_",
	}

	for _,v in ipairs(_default_false) do
		if string.find(_act_permi_key,v) then
			return false
		end
	end

	return true
end

--[[
---- 变量转换消息函数（客户端使用）
function convert_variant_to_table( _data )
    local ret_vec = {}
    for key,data in pairs(_data) do
        local value_vec = basefunc.string.split( data.variant_value , ",")
        if value_vec then
            for _key,value in pairs(value_vec) do
                if data.variant_type == "string" then
                    value_vec[_key] = tostring( value )
                elseif data.variant_type == "number" then
                    value_vec[_key] = tonumber( value )
                end
            end
        end

        local ret = value_vec
        if data.variant_value_type == "table" then
            if not value_vec or #value_vec == 0 then
                ret = {}
            end
        end
        if data.variant_value_type == "value" then
            ret = value_vec and value_vec[1]
        end
        ret_vec[ data.variant_name ] = ret
  end
  
  -- 转成 map
  _data.diff_act_permission_map = {}
  for _,v in ipairs(_data.diff_act_permission) do
    _data.diff_act_permission_map[v] = true
  end

    return ret_vec
end
--]]

------- 判断某一类的活动权限 的成立的活动key
function C.get_class_act_permission_key( _class_act_permisssion , _original_data )
	local act_permission_data = C.get_all_act_permission_cfg_data()

	--- 这类权限成立的list
	local cod_act_permission = {}

	for act_permission_key , data in pairs(act_permission_data) do
		if data.type and data.type == _class_act_permisssion then
			local is_work = C.judge_permission_effect_client( act_permission_key , _original_data )
			if is_work then
				cod_act_permission[#cod_act_permission + 1] = { act_permission_key = act_permission_key , order = data.order }
			end
		end
	end

	if next(cod_act_permission) then
		table.sort( cod_act_permission , function(a,b) 
			return a.order < b.order
		end)
	end

	return cod_act_permission[1] and cod_act_permission[1].act_permission_key
end

------- by lyx: 判断某个权限 是否成立 (客户端用) C.act_permission_id_map
function C.judge_permission_effect_client( _permission_key , _original_data )

	if string.find(_permission_key,"^actp_") then
		local _cfg = C.permission_cfg_data[_permission_key]

		if not _cfg then -- 未配置 ，用默认值
			return C.act_permission_default_value(_permission_key)
		end

		if not _cfg.id then
			fault("permission config error:" .. tostring(_permission_key))
			error("permission config error:" .. tostring(_permission_key))
		end

		if _original_data.diff_act_permission_map[tostring(_cfg.id)] then
			return not C.act_permission_default_value(_permission_key)   -- 发送了，则为非默认值
		else
			return C.act_permission_default_value(_permission_key) -- 没发送，则为默认值
		end
	else
		return C.judge_permission_effect(_permission_key , _original_data)
	end
end

function C.judge_condition_vec( _condition_vec , _original_data )
	if _condition_vec then
		local condition_group = {}
		for key,data in pairs( _condition_vec ) do
			---
			local is_true = C.judeg_condition( _original_data , data )

			condition_group[ data.group ] = condition_group[ data.group ] or {}
			local tar_data = condition_group[ data.group ]
			tar_data[#tar_data + 1] = { is_true = is_true , error_desc = data.error_desc }
		end

		local error_des = nil
		----- 每个组的判断
		for group_id , group_bool_vec in pairs(condition_group) do
			local is_group_bool_true = true
			---- 这组一个不成立就直接不成立
			for key,bool_data in ipairs(group_bool_vec) do
				if not bool_data.is_true then
					is_group_bool_true = false
					if not error_des then
						error_des = bool_data.error_desc
					end
					break
				end
			end
			--- 一个组成立，就直接成立
			if is_group_bool_true then
				--print("xxx---------------return true 1" , _permission_key)
				return true
			end
		end
		return false , error_des

	end
	return true
end

------- 判断某个权限 是否成立 (外部用)
function C.judge_permission_effect( _permission_key , _original_data )
	--print("xxx------------------judge_permission_effect" , _permission_key)
	----drt开头的， 没有配的，返回false ; 
	if string.find(_permission_key, "^drt_") and not C.permission_cfg_data[ _permission_key ] then
		return false
	end

	if not C.permission_cfg_data[ _permission_key ] then
		--print("xxxx--------------not _permission_key return true" , _permission_key)
		return true
	end

	local permission_cfg = C.permission_cfg_data[ _permission_key ]

	return C.judge_condition_vec( permission_cfg.condition_data , _original_data )
	--print("xxx---------------return true 2" , _permission_key)
	--return true
end


return C 
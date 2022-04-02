require "normal_enum"
local skynet = require "skynet_plus"
require "skynet.manager"
require"printfunc"
local nodefunc = require "nodefunc"
local base=require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA
--地面刷新规则

DATA.map_award_create_lib_protect = {}
local refresh = DATA.map_award_create_lib_protect

------- add by wss
function refresh.init_map_res_fun_2(cfg , all_num)


end

--[[
		{
			[1]={min,max,type_id,group_cfg_name,group}
		}
--]]
function refresh.init_map_res_fun_1(cfg , all_num)
	--map_gz_cfg = map_gz_cfg or 1
	--all_num = all_num or #map_gezi_cfg[ map_gz_cfg ]

	local ad_list = refresh.init_map_res(cfg , all_num)
	return refresh.fengzhuang_mapAward(ad_list)
end
function refresh.init_map_res(cfg,all_num,ad_list)

	ad_list = ad_list or {}

	local max_count={}
	for k,v in pairs(cfg) do
		v.num =  v.min
		all_num = all_num - v.num

		max_count[k]=v.num
		--给个标志物 方便后面计算
		v.hash_flag=k
	end
	if all_num<0 then
		print("xxxx---------------init_map_res create_fial 111111111" , all_num )
		return nil
	end

	----- 先找到有 road_id 的处理了
	local road_id_deal_vec = {}
	for i = #cfg , 1 , -1 do -- in pairs(cfg) do
		local data = cfg[i]
		if data.road_id and type(data.road_id) == "number" then
			road_id_deal_vec[#road_id_deal_vec + 1] = { road_id = data.road_id , type_id = data.type_id }
			table.remove(cfg , i)
		end
	end

	if next(road_id_deal_vec) then
		for key,data in pairs(road_id_deal_vec) do
			ad_list[#ad_list+1]={num=1 , type_id = data.type_id , road_id = data.road_id }
		end
	end


	if all_num>0 then
		print("xxxx----------------------init_map_res 11:" , all_num )
		local rt=refresh.random_notMax_n_for_lib(cfg,all_num,"weight",max_count,"hash_flag","max")
		if rt then
			for k,v in pairs( rt ) do
				cfg[v.hash_flag].num=cfg[v.hash_flag].num+1
				all_num = all_num - 1
			end
		else
			dump(cfg , "xxxx---------------init_map_res create_fial 1111 ")
			return nil
		end

	end
	dump(cfg , "xxxx-------------------- dump init_map_res 22 " )
	print("xxx-------------- init_map_res 22 ", all_num )

	local safe_limit = all_num*10
	while safe_limit > 0 and all_num>0 do
		 
		if safe_limit==0 then
			error("xxxx---------------init_map_res create_fial 222222 maby sum(max) < all_num")
			--创建失败
			return nil
		end

		safe_limit = safe_limit - 1
	end

	for k,v in pairs(cfg) do
		if v.group and v.group_cfg_name then
			local rt=refresh.random_notMax_n_for_lib(DATA.map_road_award_lib[v.group_cfg_name][v.group],v.num,"weight",nil,"type_id","max")
			-- local ad = refresh.random_notMax_n_for_lib( DATA.map_road_award_lib[v.group_cfg_name][v.group] , v.num , "weight" , ad_list )
			if not rt then
				--创建失败
				print("xxxx---------------init_map_res create_fial 12111")
				return nil
			else
				for _,lv in pairs(rt) do 
					ad_list[#ad_list+1]={num=1,type_id=lv.type_id , road_id = v.road_id }
				end
			end

	    else
	    	ad_list[#ad_list+1]={num=v.num,type_id=v.type_id , road_id = v.road_id }
		end
		
	end

	dump(ad_list , "xxxx--------------final__ad_list:")

	return ad_list

end
---- 从一个库里面 随机选 n 个 ， 并受 每个选项的最大值控制。
function refresh.random_notMax_n_for_lib(lib,count,weight_name,max_count,flag_key,max_key,rt)
	if not lib or type(lib) ~= "table" or #lib < 1 then
		return nil
	end
	max_key=max_key or "max"
	rt=rt or {}
	local lib_copy = basefunc.deepcopy( lib )
	max_count=max_count or  {}
	local safe_limit=count*10
	while count>0 do
		local data , r_index = basefunc.get_random_data_by_weight( lib_copy , weight_name )
		if not data then  --- 
			return nil
		end

		max_count[data[flag_key]]=max_count[data[flag_key]] or 0
		if data[max_key] and max_count[data[flag_key]]>=data[max_key] then
			table.remove( lib_copy, r_index)
		else
			rt[ #rt + 1 ] = data
			max_count[data[flag_key]]=max_count[data[flag_key]]+1
			count=count-1
		end

		if #lib_copy <= 0 and count>0 then
			return nil
		end

		safe_limit=safe_limit-1
		if safe_limit==0 then
			return nil
		end
	end
	return rt
end

-- ---- 从一个库里面 随机选 n 个 ， 并受 每个选项的最大值控制。
-- function refresh.random_notMax_n_for_lib(lib,count,weight_name,ad_list,max_count)
-- 	if not lib or type(lib) ~= "table" or #lib < 1 then
-- 		return nil
-- 	end
-- 	local lib_copy = basefunc.deepcopy( lib )
-- 	ad_list=ad_list or {}
-- 	max_count=max_count or {}
-- 	local safe_limit=count*10
-- 	while count>0 do
-- 		local data , r_index = basefunc.get_random_data_by_weight( lib_copy , weight_name )
-- 		max_count[data.type_id]=max_count[data.type_id] or 0
-- 		if data.max and max_count[data.type_id]>=data.max then
-- 			table.remove( lib_copy, r_index)
-- 		else
-- 			ad_list[ #ad_list + 1 ] = {num=1,type_id=data.type_id}
-- 			max_count[data.type_id]=max_count[data.type_id]+1
-- 			count=count-1
-- 		end

-- 		if #lib_copy <= 0 then
-- 			break
-- 		end

-- 		safe_limit=safe_limit-1
-- 		if safe_limit==0 then
-- 			return nil
-- 		end
-- 	end
-- 	return ad_list
-- end



--数量展开
function refresh.num_zhankai(ad_list)
	local list={}
	for k,v in pairs(ad_list) do
		if v.num then
			for i=1,v.num do
				list[#list+1]={type_id=v.type_id , road_id = v.road_id }
			end
		end
	end
	return list
end
--[[
	ad_list={[]={type_id,}}
	
--]]
--封装成mapAward
function refresh.fengzhuang_mapAward(ad_list)
	ad_list=refresh.num_zhankai(ad_list)
	--basefunc.out_of_order(ad_list)
	--封装成对应的数据格式
	--for k,road_id in pairs(map_gz_cfg) do
		
	--end
	return ad_list
end
function refresh.fengzhuang()

end

--map_award  当前地图上的奖励
function refresh.mapAward_refresh_fun_1(cfg, num , _total_type_num , ad_list)
	num = num or 1 
	if not cfg or type(cfg) ~= "table" or not next(cfg) then
		return nil
	end

	--统计type_num数量 *********
	--统计group数量
	local type_num = _total_type_num or {}  --key =type_id  value =sum
	local group_num = {} --key =group_id  value = sum
	local type_group_hash = {}    ---- key = type_id , value = { group_id , group_id2}

	---- 找到第一个 group_cfg_name 
	local group_cfg_name = nil
	for key , data in pairs( cfg ) do
		if data.group_cfg_name then
			group_cfg_name = data.group_cfg_name 
			break
		end
	end

	----- 整理 group_num
	if group_cfg_name and DATA.map_road_award_lib[group_cfg_name] then
		local tar_group_cfg = DATA.map_road_award_lib[group_cfg_name]

		for group_id , group_data in pairs(tar_group_cfg) do
			for key, data in pairs(group_data) do
				if type_num[data.type_id] then
					group_num[group_id] = (group_num[group_id] or 0) + type_num[data.type_id]

					type_group_hash[data.type_id] = type_group_hash[data.type_id] or {}
					local tar_data = type_group_hash[data.type_id]
					tar_data[#tar_data + 1] = group_id
				end
			end
		end
	end


	ad_list = ad_list or {} 
	local all_weight = 0
	for i=1,num do
		--确定weight
		for k,v in pairs(cfg) do
			v.weight = v.nor_weight
			if v.group_id and group_num[v.group_id] and group_num[v.group_id] <= v.low_num then
				v.weight = v.low_weight
			elseif v.group_id and group_num[v.group_id] and group_num[v.group_id] >= v.high_num then
				v.weight = v.high_weight
			elseif v.type_id and type_num[v.type_id] and type_num[v.type_id] <= v.low_num then
				v.weight = v.low_weight
			elseif v.type_id and type_num[v.type_id] and type_num[v.type_id] >= v.high_num then
				v.weight = v.high_weight
			end
			if v.max and v.group_id and group_num[v.group_id] and group_num[v.group_id] >= v.max then
				v.weight = 0
			end
			if v.max and v.type_id and type_num[v.type_id] and type_num[v.type_id] >= v.max then
				v.weight = 0
			end
			all_weight = all_weight + v.weight
		end

		local safe_limit = 20
		while safe_limit > 0 do
			--失败 不符合条件
			if all_weight == 0 then
				return nil  
			end
			--dump(cfg , "xxxx------------------cfgcfgcfgcfg__")
			local data , r_index = basefunc.get_random_data_by_weight( cfg , "weight" )
			if data then
				local _is_suc = true
				local type_id = nil
				--直接是type
				if data.type_id then
					type_id = data.type_id
					ad_list[#ad_list+1]={type_id=data.type_id}
				--group类型
				elseif data.group_cfg_name and data.group_id then
					local _rt = refresh.random_notMax_n_for_lib( DATA.map_road_award_lib[data.group_cfg_name][data.group_id] , 
																	1 ,
																	"weight" , 
																	nil,
																	"type_id",
																	"max", ad_list )
					if not _rt or #_rt < 1 then
						--创建失败 配置不合理
						all_weight = all_weight - data.weight
						data.weight = 0
						_is_suc = false
					end
					type_id = _rt[1].type_id
				end	
				if _is_suc and type_id then
					--*****加入  type_num数量 gourp数量
					type_num[type_id]=type_num[type_id] or 0
					type_num[type_id]=type_num[type_id]+1
					---- 处理 group_num + 1
					if type_group_hash[type_id] then
						for key , group_id in pairs(type_group_hash[type_id]) do
							group_num[group_id] = (group_num[group_id] or 0) + 1
						end
					end
					break
				end
			end
			safe_limit = safe_limit - 1
			--失败 不符合条件
			if safe_limit==0 then
				return nil
			end
		end
	end


	return ad_list

end

--[[
	改装中心，道具中心：  
	选项1：固定库中随机，历史出现不超过配置中的最大值
	选项2：固定库中随机，历史出现不超过配置中的最大值
	选项3：固定库中随机，历史出现不超过配置中的最大值
--]]
--3选1分项 并且创建物是直接使用   num：选项个数   count={type_id=num} 历史最大数量
function refresh.zjUse_Nc1_by_item_refresh(cfg , num , lib_is_only , create_data )
	local ad_list={}

	local old_count = create_data.lib_type_id_num_map

	for i=1,num do 
		local tar_vec = lib_is_only and cfg[1] or cfg[i]
		print("xxxx-----------------zjUse_Nc1_by_item_refresh__i:" , i )
		-- local ad = refresh.random_notMax_n_for_lib(tar_vec ,1,"weight",ad_list,old_count)
		local _rt=refresh.random_notMax_n_for_lib(tar_vec,1,"weight",old_count,"type_id","max")
		if not _rt then
			return nil
		else
			ad_list[#ad_list+1]={num=1,type_id=_rt[1].type_id}
		end
	end
	return ad_list
end
--[[
	环境中心：  
	选项1：天气：只能刷新与当前不同的天气
	选项2：固定库中随机，历史出现不超过配置中的最大值
	选项3：固定库中随机，历史出现不超过配置中的最大值
--]]
function refresh.huanjingCenter_refresh(cfg , num , lib_is_only ,create_data)

	---- 对 第一个选项 特殊 处理 ， 
	local lib_type_id_num_map = create_data.lib_type_id_num_map
	local system_now_skill_id_map = create_data.system_now_skill_id_map

	local skill_id_to_type_id = {
		[5102] = 44,    --- 大雨
		[5103] = 26,    --- 黑夜
		--[5104] = ,
	}
	local qingtian_type_id = 52

	lib_type_id_num_map[qingtian_type_id] = 999999
	----- 如果有的天气，不能出现； 如果一个异常天气都没有，才能有晴天
	if system_now_skill_id_map and type(system_now_skill_id_map) == "table" then
		for skill_id,data in pairs( system_now_skill_id_map ) do
			---- 有异常天气 ， 可以出晴天
			lib_type_id_num_map[qingtian_type_id] = 0

			---- 如果有异常天气，那么这个天气不能出现
			if skill_id_to_type_id[skill_id] then
				lib_type_id_num_map[ skill_id_to_type_id[skill_id] ] = 999999
			end
		end
	end


	return refresh.zjUse_Nc1_by_item_refresh(cfg , num , lib_is_only , create_data)
end

--道具箱  当前身上携带old_count ={type_id=num}
function refresh.daojuxiang_refresh(cfg , num , lib_is_only ,create_data)

	local tool_type_id_map = create_data.tool_type_id_map
	local lib_type_id_num_map = create_data.lib_type_id_num_map

	----- 当前有的道具 ，不能出现
	if cfg and type(cfg) == "table" then
		for key,data in pairs(cfg) do
			if data.type_id and tool_type_id_map[data.type_id] and tool_type_id_map[data.type_id] > 0 then

				lib_type_id_num_map[data.type_id] = 9999999
			end
		end
	end


	return refresh.zjUse_Nc1_by_item_refresh(cfg , num , lib_is_only , create_data)
end
--che升级   --历史最大数量 ={type_id=num}
function refresh.cheshenji_refresh(cfg , num , lib_is_only , create_data)
	return refresh.zjUse_Nc1_by_item_refresh(cfg , num , lib_is_only ,create_data)
end


return refresh



















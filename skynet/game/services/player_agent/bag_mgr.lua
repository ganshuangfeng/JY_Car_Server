--
-- Author: yy
-- Date: 2018/4/14
-- Time: 15:14
-- 说明：背包管理
--[[

	背包有两个种类
	正常的普通背包：客户端可以正常看到的背包道具内容。
	隐藏背包：不发给客户端，用来暂时缓冲溢出背包数量限制的道具。

	记牌器和鱼币虽然在背包显示，但是不应用背包管理(也就是可能会多出来2个物品)
	如果是数据修改通知到玩家，这样增加的道具将直接超过背包上限(但是下次上线会清理)
	(目前礼包购买和邮件领取附件走的是数据增加然后通知玩家)

	1.当背包装满后，道具放入隐藏背包缓存，若隐藏背包已满则直接丢弃。
	3.当背包有空位并且隐藏背包有东西时，从隐藏背包移动物品到背包，直到填满。
	4.背包数据不需要记录数据库，当玩家上线后才开始构建背包内容，删除多余的道具。
	5.背包只关心占用背包格子的道具。
	6.判断某个道具是否占用格子依赖于客户端配置 item_config (需要及时更新)


]]

local skynet = require "skynet_plus"
local nodefunc = require "nodefunc"
local base = require "base"
local basefunc = require "basefunc"
require "normal_enum"
require"printfunc"



local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

local return_msg={result=0}


DATA.bag_cfg = 
{
	bag_max_size = 100,
	hide_bag_max_size = 10,
}


DATA.bag_data = 
{
	init = false,

	--hash
	bag_prop_content = {},		--背包可数内容
	bag_prop_size = 0,

	--list
	bag_obj_content = {},		--背包不可数内容

	--list
	hide_bag_content = {},	--隐藏背包内容
}

-- 记录哪些道具需要进行背包管理
DATA.apply_bag_hash = {}

function PUBLIC.init_apply_bag_hash()
	
	local cfg = nodefunc.get_global_config("item_config")

	for i,v in ipairs(cfg.config) do
		
		if v.is_show_bag == 1 then
			DATA.apply_bag_hash[v.item_key] = true
		end

	end

end


-- 初始化背包数据
function PUBLIC.init_bag_data()

	if not basefunc.chk_player_is_real(DATA.my_id) then
		return
	end

	PUBLIC.init_apply_bag_hash()

	local delete_list = {}

	-- 先检查可数道具
	for k,v in pairs(DATA.asset_manage_data.asset_datas) do
		
		if DATA.apply_bag_hash[k] and v>0 then
			
			if DATA.bag_data.bag_prop_size >= DATA.bag_cfg.bag_max_size then

				delete_list[#delete_list+1] = 
				{
					asset_type = k,
					value = -v,
				}

				if #DATA.bag_data.hide_bag_content < DATA.bag_cfg.hide_bag_max_size then
					
					local len = #DATA.bag_data.hide_bag_content + 1
					DATA.bag_data.hide_bag_content[len] = 
					{
						asset_type = k,
						value = v,
					}

				end

			else

				DATA.bag_data.bag_prop_size = DATA.bag_data.bag_prop_size + 1
				DATA.bag_data.bag_prop_content[k] = v

			end

		end


	end


	-- 再检查不可数道具
	for _object_id,_data in pairs(DATA.player_data.object_data) do

		if DATA.apply_bag_hash[_data.object_type] then

			if #DATA.bag_data.bag_obj_content + DATA.bag_data.bag_prop_size >= DATA.bag_cfg.bag_max_size then

				delete_list[#delete_list+1] = 
				{
					asset_type = _data.object_type,
					value = _object_id,
				}

				if #DATA.bag_data.hide_bag_content < DATA.bag_cfg.hide_bag_max_size then
					local len = #DATA.bag_data.hide_bag_content + 1
					DATA.bag_data.hide_bag_content[len] = 
					{
						asset_type = _data.object_type,
						attribute = _data.attribute,
					}
				end

			else

				local len = #DATA.bag_data.bag_obj_content + 1
				DATA.bag_data.bag_obj_content[len] = 
				{
					asset_type = _data.object_type,
					value = _object_id,
					attribute = _data.attribute,
				}

			end

		end

	end

	-- 进行删除
	if #delete_list > 0 then
		CMD.change_asset_multi(delete_list,"bag_overflow",0)
	end

	DATA.bag_data.init = true

end


-- 检测过期道具处理一下
function PUBLIC.deal_overdue_obj()

	-- 满了才处理
	if #DATA.bag_data.bag_obj_content + DATA.bag_data.bag_prop_size >= DATA.bag_cfg.bag_max_size then
	
		local ct = os.time()
		for object_id,d in pairs(DATA.player_data.object_data) do

			-- 占格子的才处理
			if DATA.apply_bag_hash[d.object_type] and d.attribute then

				local valid_time = tonumber(d.attribute.valid_time)

				if valid_time and ct > valid_time then

					-- 直接删除道具
					PUBLIC.change_obj({
						object_id = object_id,
						object_type = d.object_type,
						},"overdue",0,true)

					local len = #DATA.bag_data.bag_obj_content
					DATA.bag_data.bag_obj_content[len] = nil
					print("deal_overdue_obj",d.object_type,object_id)

				end

			end

		end

	end

end


--[[道具变化 返回可以加的量
	
	_data 增加obj的时候为属性,删除obj的时候为obj_id

]]
function PUBLIC.bag_change(_type,_num,_data)

	if not basefunc.chk_player_is_real(DATA.my_id) then
		return _num
	end

	-- 初始化完成
	if not DATA.bag_data.init then
		return _num
	end


	--print("bag_change o p :" , #DATA.bag_data.bag_obj_content , DATA.bag_data.bag_prop_size)

	--print("bag_change",_type,_num)
	--dump(_data,"_data")

	--dump(DATA.bag_data,"bag_data_____")

	if DATA.apply_bag_hash[_type] then

		if basefunc.is_object_asset(_type) then

			return PUBLIC.bag_add_obj(_type,_num,_data)

		else

			return PUBLIC.bag_add_prop(_type,_num)

		end

	end

	return _num
end



-- 背包增加可数道具
function PUBLIC.bag_add_prop(_type,_num)

	if _num > 0 then

		PUBLIC.deal_overdue_obj()

		if (DATA.bag_data.bag_prop_content[_type] or 0) < 1 then

			if #DATA.bag_data.bag_obj_content + DATA.bag_data.bag_prop_size >= DATA.bag_cfg.bag_max_size then
				-- 隐藏背包 有则加

				local has = false
				for i,v in ipairs(DATA.bag_data.hide_bag_content) do
					if v.asset_type == _type then
						v.value = v.value + _num
						has = true
						break
					end
				end

				if not has and #DATA.bag_data.hide_bag_content < DATA.bag_cfg.hide_bag_max_size then

					local len = #DATA.bag_data.hide_bag_content + 1
					DATA.bag_data.hide_bag_content[len] = 
					{
						asset_type = _type,
						value = _num,
					}

				end

				return 0
			else
				-- 占格子
				DATA.bag_data.bag_prop_content[_type] = _num
				DATA.bag_data.bag_prop_size = DATA.bag_data.bag_prop_size + 1
			end

		else
			-- 加数量
			local n = DATA.bag_data.bag_prop_content[_type]
			DATA.bag_data.bag_prop_content[_type] = n + _num
		end
		
		return _num

	elseif _num < 0 then

		local n = DATA.bag_data.bag_prop_content[_type]
		DATA.bag_data.bag_prop_content[_type] = n + _num

		--print("xxxxxxx:",_type,DATA.bag_data.bag_prop_content[_type])


		if DATA.bag_data.bag_prop_content[_type] < 1 then

		--print("aaaaa",DATA.bag_data.bag_prop_size)

			DATA.bag_data.bag_prop_content[_type] = nil
			DATA.bag_data.bag_prop_size = DATA.bag_data.bag_prop_size - 1

			PUBLIC.reuse_hide_bag_item()

		--print("vvvvv",DATA.bag_data.bag_prop_size)

		end

		return _num
	end

	return 0

end




function PUBLIC.check_obj_in_bag(_type,_attr)

	-- 捕鱼道具分场景
	if string.len(_type)>9 and string.sub(_type,1,9) == "obj_fish_" then
		if _attr and _attr.scene=="matchstyle" then
			return false
		end
	end

	return true
end


-- 背包增加不可数道具
function PUBLIC.bag_add_obj(_type,_num,_data)

	--print("bag_add_obj",_type,_num)
	--dump(_data,"_data")

	if _num > 0 then

		if not PUBLIC.check_obj_in_bag(_type,_data) then
			return _num
		end

		PUBLIC.deal_overdue_obj()

		local sn = 0

		for i=1,_num do
				
			if #DATA.bag_data.bag_obj_content + DATA.bag_data.bag_prop_size >= DATA.bag_cfg.bag_max_size then

				if #DATA.bag_data.hide_bag_content < DATA.bag_cfg.hide_bag_max_size then
					local len = #DATA.bag_data.hide_bag_content + 1
					DATA.bag_data.hide_bag_content[len] = 
					{
						asset_type = _type,
						attribute = _data,
					}
					--print("qqqqqq")
				end
				--print("asdaaaaa")
			else

				local len = #DATA.bag_data.bag_obj_content + 1
				DATA.bag_data.bag_obj_content[len] = 
				{
					asset_type = _type,
					attribute = _data,
				}

				sn = sn + 1
				--print("asdbbbbbb")
			end

		end

		--print("xxxxxxa:",sn)
		return sn

	elseif _num < 0 then

		local od = DATA.player_data.object_data[_data]
		if not PUBLIC.check_obj_in_bag(_type,od.attribute) then
			return _num
		end

		for i=1,-_num do

			local len = #DATA.bag_data.bag_obj_content
			DATA.bag_data.bag_obj_content[len] = nil

			PUBLIC.reuse_hide_bag_item()

		end

		return _num

	end

	return 0

end




-- 强制背包改变(道具已经变化了，数据库通知类的【先斩后奏类型】)
function PUBLIC.force_bag_change(_type,_num,_data)

	--print("force_bag_change",_type,_num)
	--dump(_data,"_dataxxx")

	if not basefunc.chk_player_is_real(DATA.my_id) then
		return _num
	end

	-- 初始化完成
	if not DATA.bag_data.init then
		return _num
	end

	if DATA.apply_bag_hash[_type] then

		if basefunc.is_object_asset(_type) then

			if _num > 0 then

				if not PUBLIC.check_obj_in_bag(_type,_data) then
					return _num
				end

				PUBLIC.deal_overdue_obj()

				-- 直接增加
				local len = #DATA.bag_data.bag_obj_content + 1
				DATA.bag_data.bag_obj_content[len] = 
				{
					asset_type = _type,
					attribute = _data,
				}

				return _num

			elseif _num < 0 then

				-- 减少就正常处理了
				return PUBLIC.bag_add_obj(_type,_num,_data)

			end

		else

			if _num > 0 then

				PUBLIC.deal_overdue_obj()

				-- 直接增加
				if (DATA.bag_data.bag_prop_content[_type] or 0) < 1 then

					-- 占格子
					DATA.bag_data.bag_prop_content[_type] = _num
					DATA.bag_data.bag_prop_size = DATA.bag_data.bag_prop_size + 1
				
				else
					-- 加数量
					local n = DATA.bag_data.bag_prop_content[_type]
					DATA.bag_data.bag_prop_content[_type] = n + _num
				end
				
				return _num

			elseif _num < 0 then

				return PUBLIC.bag_add_prop(_type,_num)

			end

		end

	end

end





-- 背包减少不可数道具
function PUBLIC.reuse_hide_bag_item()
	
	-- 背包有空位 并且 隐藏背包有东西
	if (#DATA.bag_data.bag_obj_content + DATA.bag_data.bag_prop_size < DATA.bag_cfg.bag_max_size )
			and (#DATA.bag_data.hide_bag_content > 0) then
		
		local d = DATA.bag_data.hide_bag_content[1]

		table.remove(DATA.bag_data.hide_bag_content,1)
		
		-- 通过消息延迟点
		nodefunc.send(DATA.my_id,"change_asset_multi",{d},"hide_bag_reuse",0)
		--dump(d,"reuse_hide_bag_item")
	end

end
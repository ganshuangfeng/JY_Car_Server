--
-- Author: yy
-- Date: 2018/4/14
-- Time: 15:14
-- 说明：资产管理
--

local skynet = require "skynet_plus"
local base = require "base"
local cjson = require "cjson"
local nodefunc = require "nodefunc"
cjson.encode_sparse_array(true,1,0)
local basefunc = require "basefunc"
require "normal_enum"
require "normal_func"
require"printfunc"

require "player_agent.bag_mgr"

local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

local return_msg={result=0}

DATA.asset_manage_data = DATA.asset_manage_data or {

	notify_asset_change_msg_no = 0,
	request_query_asset_cache = nil,
	
	service_zero_time = 6,

	shoping_config = {},
	shoping_config_version = 0,

	--用户的所有资产hash
	asset_datas = {},

	player_object_id = {},

	--[[道具的数量
		在lock的时候会提前扣减数量，因此可能会和道具里面的内容不符
		需要每次道具变化的时候进行更新
	]]
	player_object_num = {},

	--用户的所有卡券信息
	-- del by lyx
	-- player_tickets = {}
	-- player_tickets_list = {}
	-- player_tickets_game = {}

	--兑物券激活码
	-- del by lyx
	-- dwq_cdkey={}

	--资产锁定的数据
	--lock_id => data
	asset_locked_datas = {},
	asset_locked_datas_count = 0,

	asset_staging_data = {},
	asset_staging_data_count = 0,

	act_lock = false,

	return_lock_msg={result=0,lock_id=0},

	asset_type_error_enum_map=
	{
		[PLAYER_ASSET_TYPES.DIAMOND] = 1011, 		--钻石
		[PLAYER_ASSET_TYPES.CASH] = 1013, 			--现金
		[PLAYER_ASSET_TYPES.JING_BI] = 1023, --鲸币
		[PLAYER_ASSET_TYPES.SHOP_GOLD_SUM] = 1024, --福卡
		--[PLAYER_ASSET_TYPES.ROOM_CARD] = 1026, -- 房卡
	},
}
local LD = DATA.asset_manage_data

local LF = base.LocalFunc("asset_manage")

--进行资产验证 返回资源不足的错误编号
function LF.asset_verify(_asset_data)

	local error_code = 0
	local deduct_asset = {}
	for i,asset in ipairs(_asset_data) do
		local my_value = LD.asset_datas[asset.asset_type] or LD.player_object_num[asset.asset_type]
		my_value = my_value or 0
		if asset.condi_type == NOR_CONDITION_TYPE.CONSUME then
			if my_value < asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		elseif asset.condi_type == NOR_CONDITION_TYPE.EQUAL then
			if my_value ~= asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		elseif asset.condi_type == NOR_CONDITION_TYPE.GREATER then
			if my_value < asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		elseif asset.condi_type == NOR_CONDITION_TYPE.LESS then
			if my_value > asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		else
			skynet.fail("asset.condi_type error " .. tostring(asset.condi_type))
		end
	end

	return error_code
end

--进行资产验证和消耗 返回资源不足的错误编号
function LF.asset_verify_consume(_asset_data)

	local error_code = 0
	local deduct_asset = {}
	for i,asset in ipairs(_asset_data) do
		local my_value = LD.asset_datas[asset.asset_type] or LD.player_object_num[asset.asset_type]
		my_value = my_value or 0
		if asset.condi_type == NOR_CONDITION_TYPE.CONSUME then
			if my_value < asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			else
				if basefunc.is_object_asset(asset.asset_type) then
					LD.player_object_num[asset.asset_type] = LD.player_object_num[asset.asset_type] - asset.value
				else
					LD.asset_datas[asset.asset_type] = my_value-asset.value
				end
				deduct_asset[asset.asset_type] = (deduct_asset[asset.asset_type] or 0) + asset.value
			end
		elseif asset.condi_type == NOR_CONDITION_TYPE.EQUAL then
			if my_value ~= asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		elseif asset.condi_type == NOR_CONDITION_TYPE.GREATER then
			if my_value < asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		elseif asset.condi_type == NOR_CONDITION_TYPE.LESS then
			if my_value > asset.value then
				error_code = LD.asset_type_error_enum_map[asset.asset_type] or 1012
				break
			end
		else
			skynet.fail("asset.condi_type error " .. tostring(asset.condi_type))
		end
	end

	if error_code ~= 0 then
		for asset_type,value in pairs(deduct_asset) do

			if basefunc.is_object_asset(asset_type) then
				LD.player_object_num[asset_type] = LD.player_object_num[asset_type] + value
			else
				LD.asset_datas[asset_type] = (LD.asset_datas[asset_type] or 0 )+value
				PUBLIC.change_asset_and_msg( asset_type ,value ,LD.asset_datas[asset_type])
			end

		end
	end

	return error_code
end


function LF.create_lock_id()
	return (os.time()%1524130583)+LD.asset_locked_datas_count
end


--[[加载资产从数据库
]]
function PUBLIC.load_asset()

	local is_pay_test = skynet.getcfg("is_pay_test")

	--###test
	--DATA.my_id = "user_10_757928"

	local ori_data = DATA.player_data

	-- by lyx
	if not ori_data then
		skynet.fail(string.format("load_asset error:user '%s' base data is nil!",DATA.my_id))
		return
	elseif not ori_data.player_prop then
		skynet.fail(string.format("load_asset error:user '%s' prop data is nil!",DATA.my_id))
		return
	elseif not ori_data.object_data then
		skynet.fail(string.format("load_asset error:user '%s' object_data is nil!",DATA.my_id))
		return
	end

	--dump(ori_data,"ori_data")
	-- dump(ori_data.player_prop,"/////*-*-/*/-----*-------")
	for prop_type,prop in pairs(ori_data.player_prop) do
		LD.asset_datas[prop_type]=prop.prop_count
	end

	PUBLIC.init_object_data()


	LD.asset_datas["id"] = nil

	--dump(LD.asset_datas,"my LD.asset_datas:")

	local _is_robot = not basefunc.chk_player_is_real(DATA.my_id)

	--###test
	if not _is_robot then
		if is_pay_test then

			-- 测试环境加钱
			LD.asset_datas[PLAYER_ASSET_TYPES.JING_BI] = 0
			if LD.asset_datas[PLAYER_ASSET_TYPES.JING_BI] < 200000 then
				skynet.timeout(10,function ()
						local _asset_data={

							-- {asset_type=PLAYER_ASSET_TYPES.DIAMOND,value=1000000},
							{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=1000000},

							-- {asset_type="prop_fish",value=4},
							-- {asset_type="prop_100y",value=2},

							-- {asset_type=PLAYER_ASSET_TYPES.CASH,value=21000},
							-- {asset_type=PLAYER_ASSET_TYPES.SHOP_GOLD_SUM,value=500},

							-- {asset_type="fish_coin",value=200},

						}
						CMD.change_asset_multi(_asset_data,"init_test",0)
				end)
			end
		end
	end

end


-- 初始化购物配置
function LF.init_shoping_config()

	LD.shoping_config.gift_bag_condition = nil

	-- id 有重复 先行处理
	for k,d in pairs(LD.shoping_config.item) do
		local dt = LD.shoping_config[d.type] or {}
		LD.shoping_config[d.type] = dt
		dt[#dt+1] = d
	end
	LD.shoping_config.item = nil

	-- id 映射
	local tmp = {}
	for k,v in pairs(LD.shoping_config) do
		tmp[k]={}
		for i,d in ipairs(LD.shoping_config[k]) do
			tmp[k][d.id]=d
		end
	end

	LD.shoping_config = tmp

end

function PUBLIC.get_shoping_config()

	PUBLIC.update_shoping_config()

	return LD.shoping_config
end

-- 检查更新商城配置
function PUBLIC.update_shoping_config()

	local _sonfig_name = PUBLIC.get_shopcfg_name(DATA.my_id)
	local c,v = skynet.call(DATA.service_config.shoping_config_center_service,"lua"
												,"get_config",_sonfig_name,LD.shoping_config_version)

	if c then
		LD.shoping_config = c
		LD.shoping_config_version = v
		LF.init_shoping_config()
	else
		-- print("asset manage update_shoping_config error:",DATA.my_id,_sonfig_name)
	end

	--dump(LD.shoping_config,"++++++/*-/*-")
end

--- add by wss  改变资产&发出消息
function PUBLIC.change_asset_and_msg( asset_type , change_value , final_value)

	--DATA.msg_dispatcher:call("asset_change_msg", asset_type
	--							, change_value
	--							, final_value )

	PUBLIC.trigger_msg( {name = "asset_change_msg"} , asset_type , change_value , final_value )

end


--- 把全部的资产类型发一个改变0的消息出去
function PUBLIC.asset_observe()
	for key , asset_type in pairs(PLAYER_ASSET_TYPES) do
		if LD.asset_datas[asset_type] then
			--DATA.msg_dispatcher:call("asset_change_msg", asset_type
			--					, 0
			--					, LD.asset_datas[asset_type] )

			PUBLIC.trigger_msg( {name = "asset_change_msg"} , asset_type , 0 , LD.asset_datas[asset_type] )
		end
	end
end


-- 获取类型中最快失效的n个道具
function PUBLIC.get_lately_object_data(_object_type,_n)

	-- 如果就没有这个道具类型 直接返回
	if not LD.player_object_id[_object_type] then
		return nil
	end

	local ods = {}

	local now = os.time()

	for object_id,d in pairs(DATA.player_data.object_data) do

		if d.object_type == _object_type then

			-- 可能在提前扣减数量的时候先检查过了时间，然后突然过期了
			-- local valid_time = tonumber(d.attribute.valid_time) or 2053509902

			-- if valid_time>now then

				ods[#ods+1] =
				{
					object_type = _object_type,
					object_id = object_id,
				}

			-- end

		end

	end

	if #ods > _n then

		table.sort( ods, function(a,b)
			local av = DATA.player_data.object_data[a.object_id].attribute.valid_time or 0
			local bv = DATA.player_data.object_data[b.object_id].attribute.valid_time or 0
			return tonumber(av) < tonumber(bv)
		end)

		ods[_n+1] = nil

	end

	return ods

end

--[[
{
	object_id = xx21s2aw,
	object_type = _type, --新增时需要
	attribute = _data, -- nil 代表删除此物品
}
]]
function PUBLIC.change_obj(_obj_data,_log_type,_change_id,_save_db,_is_not_change_num)

	--dump(_obj_data,"change_obj++++"..DATA.my_id)

	local obj = DATA.player_data.object_data[_obj_data.object_id]
	if obj then
		if _obj_data.attribute then

			if type(_obj_data.attribute)~="table"
				or not next(_obj_data.attribute) then

					print("update object error attribute is error or empty ")
					return
			end

			if _save_db then
				PUBLIC.update_object(_obj_data.object_id,_obj_data.attribute,_log_type,_change_id)
			end

			DATA.player_data.object_data[_obj_data.object_id].attribute = _obj_data.attribute

			return "update"
		else

			if _save_db then
				PUBLIC.delete_object(_obj_data.object_id,_log_type,_change_id)
			end

			DATA.player_data.object_data[_obj_data.object_id] = nil

			if not _is_not_change_num then
				LD.player_object_num[_obj_data.object_type] = LD.player_object_num[_obj_data.object_type] - 1
			end

			-- 恰好删除的就是id hash
			if LD.player_object_id[_obj_data.object_type] == _obj_data.object_id then

				LD.player_object_id[_obj_data.object_type] = nil

				if LD.player_object_num[_obj_data.object_type] > 0 then
					-- 重新找一个
					-- local ct = os.time()
					for object_id,d in pairs(DATA.player_data.object_data) do

						if d.attribute and d.object_type == _obj_data.object_type then

							-- -- 有效期不进行计算
							-- local valid_time = tonumber(d.attribute.valid_time)

							-- if (not valid_time) or (valid_time > ct) then
								LD.player_object_id[d.object_type] = object_id
								break
							-- end

						end

					end
				end

			end

			return "delete"
		end
	else

		if not _obj_data.attribute
			or not _obj_data.object_type
			or type(_obj_data.attribute)~="table"
			or not next(_obj_data.attribute) then

				print("add object error attribute is nil or empty 2 ",debug.traceback())
				return
		end

		if _save_db then
			_obj_data.object_id = PUBLIC.add_object(_obj_data.object_type,_obj_data.attribute,_log_type,_change_id)
		end

		if not _is_not_change_num then
			LD.player_object_num[_obj_data.object_type] = (LD.player_object_num[_obj_data.object_type]or 0) + 1
		end

		DATA.player_data.object_data[_obj_data.object_id] = _obj_data

		LD.player_object_id[_obj_data.object_type] = _obj_data.object_id

		return "add"

	end

	return nil
end


--[[增减资产

	_asset_data={
		{asset_type=jing_bi,value=100},
		{asset_type=object_tick,value=o20125a1d21s,attribute={valid_time=123},num=2(>0 or nil)},
	}

	是否同步到数据库 如果是下面的参数需要传递
	_log_type - 财物改变类型
	_change_id - 改变原因id  没有为0

	特别的 condi_type 条件类型

	value 可能为道具的 object_id
	attribute 为不可叠加道具属性
]]
function LF.change_asset_multi(_asset_data,_log_type,_change_id,_change_way,_change_way_id,_not_notify,_save_db)

	local _change_asset_data = {}

	for i,asset in ipairs(_asset_data) do

		if not asset.condi_type
			or asset.condi_type == NOR_CONDITION_TYPE.CONSUME then

			if tonumber(asset.value)then

				if asset.value ~= 0 then

					LD.asset_datas[asset.asset_type] = (LD.asset_datas[asset.asset_type] or 0) + asset.value

					PUBLIC.change_asset_and_msg(asset.asset_type,asset.value,LD.asset_datas[asset.asset_type])

					_change_asset_data[#_change_asset_data+1]=
					{
						asset_type = asset.asset_type,
						asset_value = asset.value,
					}

					if _save_db then
						skynet.send(DATA.service_config.data_service,"lua","change_asset",
											DATA.my_id , asset.asset_type
											,asset.value , _log_type , _change_id
											,_change_way , _change_way_id)
						print("xxx---------------send__ob__change_asset")
					end
				end

			end

		end

	end

	-- dump(LD.asset_datas,"//////*-*-*-- 2222:"..DATA.my_id)

	if not _not_notify then
		PUBLIC.notify_asset_change_msg(_change_asset_data,_log_type)
	end
end


--[[增加加资产
	这里只做增加资产，不可以填写负数，也就是不可以进行扣除资产
	-- 记牌器还是普通资产一样调用 按数量计算一天的时间多个的时候进行累加

	_asset_data={
		{asset_type=jing_bi,value=100},
		{asset_type=object_tick,value=o20125a1d21s,attribute={valid_time=123},num=2},
	}

	是否同步到数据库 如果是下面的参数需要传递
	_log_type - 财物改变类型
	_change_id - 改变原因id  没有为0

	特别的 condi_type 条件类型
]]
function CMD.change_asset_multi(_asset_data,_log_type,_change_id,_change_way,_change_way_id,_not_notify)
	LF.change_asset_multi(_asset_data,_log_type,_change_id,_change_way,_change_way_id,_not_notify,true)
end


--[[清除一个资产
	结构和增加资产一样 但是除了 asset_type 之外的值会被忽略，将会被赋值为当前已有的负数量或很多的obj_id
	_asset_data={
		{asset_type=jing_bi,value=100},
		{asset_type=object_tick,value=o20125a1d21s,attribute={valid_time=123},num=2},
	}

]]
function CMD.clear_asset_multi(_asset_data,_log_type,_change_id,_not_notify)

	local dec_asset_data = {}

	for i,v in ipairs(_asset_data) do

		if basefunc.is_object_asset(v.asset_type) then

			for object_id,d in pairs(DATA.player_data.object_data) do

				if d.attribute and v.asset_type == d.object_type then
					table.insert(dec_asset_data ,
							{
								asset_type = v.asset_type,
								value = object_id,
							})
				end

			end

		else
			table.insert(dec_asset_data ,
						{
							asset_type = v.asset_type,
							value = -CMD.query_asset_by_type(v.asset_type),
						})
		end
	end

	CMD.change_asset_multi(dec_asset_data,_log_type,_change_id,_not_notify)

end

--------------------------------------------------------------------------------------------
--数据库通知 刷新 multi_asset
function CMD.multi_asset_on_change_msg(_asset_datas,_log_type)
	LF.change_asset_multi(_asset_datas,_log_type,nil,nil,nil,false,false)
end


--------------------------------------------------------------------------------------------


--[[检测资产可行性 数组
	--这里value不用写成负数
	_asset_data={
		{condi_type,asset_type,value},
		{condi_type,asset_type,value},
	}
]]
function PUBLIC.asset_verify(_asset_data)

	return_msg.result = LF.asset_verify(_asset_data)
	return return_msg
end

--[[资产锁定 数组
	--这里只处理扣除资源操作，即value不用写成负数，本身就是扣除这个值
	_asset_data={
		{condi_type,asset_type,value},
		{condi_type,asset_type,value},
	}
]]
function PUBLIC.asset_lock(_asset_data)

	--检测资产可行性 锁定 并消耗
	local ret = LF.asset_verify_consume(_asset_data)
	if ret > 0  then
		LD.return_lock_msg.result = ret
		LD.return_lock_msg.lock_id = 0
		return LD.return_lock_msg
	end

	local lock_id = LF.create_lock_id()
	LD.asset_locked_datas[lock_id] = _asset_data
	LD.asset_locked_datas_count = LD.asset_locked_datas_count + 1

	LD.return_lock_msg.result = 0
	LD.return_lock_msg.lock_id = lock_id
	return LD.return_lock_msg
end

--[[资产提交
	_lock_id = 锁的id
	_log_type = 修改财产日志类型
]]
function PUBLIC.asset_commit(_lock_id,_log_type,_change_id,_change_way,_change_way_id)

	local data = LD.asset_locked_datas[_lock_id]

	if data then

		local change_asset_list = {}

		local obj_list = nil

		--提交数据库
		for i,asset in ipairs(data) do
			if asset.condi_type == NOR_CONDITION_TYPE.CONSUME then

				if basefunc.is_object_asset(asset.asset_type) then
					obj_list = {}

					local ods = PUBLIC.get_lately_object_data(asset.asset_type,asset.value)

					for i,od in ipairs(ods) do
						obj_list[#obj_list+1]=DATA.player_data.object_data[od.object_id]

						-- 都是扣除没问题
						PUBLIC.bag_change(asset.asset_type,-1,od.object_id)

						PUBLIC.change_obj(od,_log_type,_change_id,true,true)

						change_asset_list[#change_asset_list+1] =
						{
							asset_type = asset.asset_type,
							asset_value = od.object_id,
						}


					end
				else

					change_asset_list[#change_asset_list+1] =
					{
						asset_type = asset.asset_type,
						asset_value = -asset.value,
					}

					if asset.value ~= 0 then
						skynet.send(DATA.service_config.data_service,"lua","change_asset",
											DATA.my_id,asset.asset_type,
											-asset.value,_log_type,_change_id
											,_change_way,_change_way_id)
						-- 都是扣除没问题
						PUBLIC.bag_change(asset.asset_type,-asset.value)
					end

				end

			end

		end

		LD.asset_locked_datas[_lock_id] = nil
		LD.asset_locked_datas_count = LD.asset_locked_datas_count - 1

		PUBLIC.notify_asset_change_msg(change_asset_list,_log_type)

		return
		{
			result = 0,
			obj_list=obj_list,
		}
	else
		LD.return_lock_msg.result = 2100
		LD.return_lock_msg.lock_id = _lock_id
		return LD.return_lock_msg
	end

end

--[[资产解锁
]]
function PUBLIC.asset_unlock(_lock_id)
	local data = LD.asset_locked_datas[_lock_id]
	if data then


		--返还
		for i,asset in ipairs(data) do
			if asset.condi_type == NOR_CONDITION_TYPE.CONSUME then

				if basefunc.is_object_asset(asset.asset_type) then

					LD.player_object_num[asset.asset_type] = (LD.player_object_num[asset.asset_type]or 0) + asset.value

				else

					LD.asset_datas[asset.asset_type]=(LD.asset_datas[asset.asset_type]or 0)+asset.value

				end

			end
		end



		LD.asset_locked_datas[_lock_id] = nil
		LD.asset_locked_datas_count = LD.asset_locked_datas_count - 1

		LD.return_lock_msg.result = 0
		LD.return_lock_msg.lock_id = _lock_id
		return LD.return_lock_msg
	else
		LD.return_lock_msg.result = 2101
		LD.return_lock_msg.lock_id = _lock_id
		return LD.return_lock_msg
	end
end


--[[资产暂存 立刻改变 但是不写数据库
	不支持 特殊独立道具 也不要用 背包占位的道具(占格子太频繁而且还可能为负数)
]]
function PUBLIC.asset_staging(_asset_data)

	LD.asset_staging_data_count = LD.asset_staging_data_count + 1
	local lock_id = LD.asset_staging_data_count

	for i,asset in ipairs(_asset_data) do
		LD.asset_datas[asset.asset_type]=(LD.asset_datas[asset.asset_type]or 0)+asset.value
	end

	LD.asset_staging_data[lock_id] = _asset_data

	return lock_id

end

--[[批量合并提交 暂存资产  写数据库

	合并提交的东西目前只有捕鱼中使用(只管理了鲸币和鱼币)

]]
function PUBLIC.asset_merge_commit(_lock_ids,_log_type,_change_id)

	local assets = {}
	local change_asset = {}
	for k,lock_id in pairs(_lock_ids) do

		local data = LD.asset_staging_data[lock_id]
		if data then

			for i,asset in ipairs(data) do

				-- 变化值
				change_asset[asset.asset_type] = (change_asset[asset.asset_type] or 0) + asset.value

				assets[asset.asset_type]=(assets[asset.asset_type]or 0)+asset.value
			end

			LD.asset_staging_data[lock_id] = nil
		end

	end

	local change_asset_list = {}
	--提交数据库
	for asset_type,value in pairs(assets) do

		change_asset_list[#change_asset_list+1] =
		{
			asset_type=asset_type,
			asset_value=change_asset[asset_type],
		}

		if value ~= 0 then
			PUBLIC.change_asset_and_msg(asset_type,value,LD.asset_datas[asset_type])
			skynet.send(DATA.service_config.data_service,"lua","change_asset"
								,DATA.my_id
								,asset_type
								,value
								,_log_type
								,_change_id)
		end

	end

	PUBLIC.notify_asset_change_msg(change_asset_list,_log_type)

end

function PUBLIC.query_asset()

	local assets_list = {}
	for k,v in pairs(LD.asset_datas) do
		assets_list[#assets_list+1]={asset_type=k,asset_value=v}
	end

	for object_id,d in pairs(DATA.player_data.object_data) do
		local attribute = {}
		for k,v in pairs(d.attribute) do
			attribute[#attribute+1] = {name=k,value=v}
		end
		assets_list[#assets_list+1]={asset_type=d.object_type,asset_value=object_id,attribute=attribute}
	end

	return assets_list
end


function CMD.query_asset_by_type(type)

	local n = LD.asset_datas[type]

	if not n then

		if LD.player_object_id[type] then

			n = LD.player_object_num[type] or 0

		end

	end

	return n or 0
end


--[[向客户端推送资产变化信息
	直接推送所有资产数量（不包含道具）
]]

function PUBLIC.notify_asset_change_msg(_change_asset_list,_type)

	if not _change_asset_list or #_change_asset_list < 1 then
		return
	end

	LD.notify_asset_change_msg_no = LD.notify_asset_change_msg_no + 1
	if LD.notify_asset_change_msg_no > 65000 then
		LD.notify_asset_change_msg_no = 1
	end
	PUBLIC.trigger_msg( {name = "change_asset_multi_msg", send_filter ={ player_id = DATA.my_id }} , _change_asset_list, _type )
	PUBLIC.request_client("notify_asset_change_msg",
			{
			change_asset=_change_asset_list,
			type=_type,
			no = LD.notify_asset_change_msg_no,
			}
		)
end

----------------------------------------------撕毁道具-------------------------------------------------


function REQUEST.destroy_asset(self)

	if not self
		or type(self.asset_type)~="string"
		or type(self.asset_value)~="number"
		or self.asset_value<0 then

		return_msg.result=1001
		return return_msg

	end

	local num = LD.asset_datas[self.asset_type] or 0
	if num < self.asset_value then
		return_msg.result=1012
		return return_msg
	end


	return_msg.result=0
	return return_msg
end

----------------------------------------------撕毁道具-------------------------------------------------


----------------------------------------------客户端请求-------------------------------------------------


function REQUEST.query_asset(self)

	local index = 0
	if type(self.index) == "number" then
		index = math.max(1,self.index)
	end

	if (not LD.request_query_asset_cache) or (index < 2) then
		LD.request_query_asset_cache = PUBLIC.query_asset()
	end

	local assets_list = {}
	if index > 0 then

		for i=(index-1)*100+1,index*100 do

			assets_list[#assets_list+1] = LD.request_query_asset_cache[i]

			if not assets_list[#assets_list] then
				break
			end

		end

	else

		assets_list = LD.request_query_asset_cache

	end

	return {result=0,player_asset=assets_list,no=LD.notify_asset_change_msg_no}
end

function CMD.query_asset(self)
	return LD.asset_datas
end

----------------------------------------------特殊独立道具操作-------------------------------------------------
--[[
	不可折叠，每个道具有独立的属性
	... 跟 change_type change_id change_way change_way_id
]]

function PUBLIC.add_object(_type,_data,...)
	local d = {
		object_type = _type,
		attribute = _data,
	}

	local _obj_data = skynet.call(DATA.service_config.data_service,"lua","change_object",DATA.my_id,d,true,...)

	return _obj_data.object_id
end


function PUBLIC.update_object(_object_id,_data,...)

	local od = DATA.player_data.object_data[_object_id]

	if not od then
		return 1001
	end

	local d = {
		object_id = _object_id,
		object_type = od.object_type,
		attribute = _data,
	}

	skynet.send(DATA.service_config.data_service,"lua","change_object",DATA.my_id,d,true,...)

end

function PUBLIC.delete_object(_object_id,...)

	local od = DATA.player_data.object_data[_object_id]

	if not od then
		return 1001
	end

	local d = {
		object_id = _object_id,
		object_type = od.object_type,
	}

	skynet.send(DATA.service_config.data_service,"lua","change_object",DATA.my_id,d,true,...)

end

----------------------------------------------特殊独立道具操作-------------------------------------------------

function PUBLIC.init_object_data()

	--[[
		如果道具的有效期过了，就删除道具
		过期处理只有第一次初始化的时候处理，其他时候都不处理
		player_object_id,player_object_num 不关心过期问题

		过期的道具仍然可用，需要自行去处理过期不可用问题

		-- 以下下接口也不关心过期问题
		CMD.change_asset_multi
		PUBLIC.asset_lock
		PUBLIC.asset_commit

	]]


	for object_id,d in pairs(DATA.player_data.object_data) do

		local ok = true
		if d.attribute then

			local valid_time = tonumber(d.attribute.valid_time)

			if valid_time and valid_time < os.time() then

				PUBLIC.delete_object(object_id,"overdue")
				DATA.player_data.object_data[object_id] = nil

				ok = false
			end

		end

		if ok then
			LD.player_object_id[d.object_type] = object_id
			LD.player_object_num[d.object_type] = (LD.player_object_num[d.object_type] or 0) + 1
		end

	end

end
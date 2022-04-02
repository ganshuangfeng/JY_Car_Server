--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 标签中心
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "client.crypt"
-- crypt.hmac64_md5

local md5 = require "md5"
-- md5.hmacmd5

require "normal_enum"
require "printfunc"

local tag_inner = require "tag_center.tag_inner"
local tag_store = require "tag_center.tag_store"


local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

DATA.var_data_manager = require "common_variant_data_manager"
DATA.tag_cfg_manager = basefunc.path.reload_lua("game/common/permission_manager/common_permission_manager.lua")

-- 标签计算函数（包括类型，类型和 标签 不能重名 ）
PUBLIC.TAG_FUNC = PUBLIC.TAG_FUNC or {}

local LD = base.LocalData("tag_center",{

	permi_manager = basefunc.path.reload_lua("game/common/permission_manager/common_permission_manager.lua"),

	-- 批量手工设置标签信息
	batch_set_tag_timer = nil,
	batch_tag_file = nil,
	batch_tags = nil,
})

local LF = base.LocalFunc("tag_center")

function LF.compare_tags_is_same(_old_tags , _new_tags)
	if type(_old_tags) ~= "table" or type(_new_tags) ~= "table" then
		--- 返回相同，避免发送消息
		return true
	end

	local _same = true
	if #_old_tags ~= #_new_tags then
		_same = false
	else
		table.sort( _old_tags)
		table.sort( _new_tags)
		for i=1,#_old_tags do
			if _old_tags[i] ~= _new_tags[i] then
				_same = false
				break
			end
		end
	end

	return _same
end

-- 替换模块内的 manager_on_variant_data_change 函数
if not CMD.manager_on_variant_data_change then
	error("file common_variant_data_manager.lua not found CMD.manager_on_variant_data_change")
end
CMD.manager_on_variant_data_change_old = CMD.manager_on_variant_data_change

function CMD.manager_on_variant_data_change(_player_id , _variant_data , _change_variant_key)
	if _change_variant_key == "tag_vec" then
		return
	end
	--dump(_variant_data , "xxx---------------------manager_on_variant_data_change___variant_data")
	local _old_tags = CMD.get_player_tag_list(_player_id)
	--dump(_old_tags , "xxxx-----------------_old_tags,".._player_id  .. "_" ..(_change_variant_key or "nil") )
	CMD.manager_on_variant_data_change_old(_player_id , _variant_data)

	local _new_tags = CMD.get_player_tag_list(_player_id)
	--dump(_new_tags , "xxxx-----------------_new_tags,".._player_id .. "_" .. (_change_variant_key or "nil") )
	-- 比较
	local _same = LF.compare_tags_is_same(_old_tags , _new_tags)
	--print("xxx--------------------manager_on_variant_data_change11:",_player_id , _variant_data , _change_variant_key)
	if not _same then
	--	print("xxx--------------------manager_on_variant_data_change22:",_player_id , _variant_data , _change_variant_key)
		-- 触发事件
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , { 
			name = "player_tag_vec_changed" , 
			send_filter = { player_id = _player_id } } , 
			_player_id , 
			_new_tags
		)
	end

end


function CMD.get_tag(_player_id,_tag_name)

	return PUBLIC.judge_player_tag(_player_id,_tag_name)

end

-- 返回所有 tag ： tag => true/false
function CMD.get_player_tag_map(_player_id)
	local ret = {}
	for _,v in ipairs(PUBLIC.get_player_tags(_player_id)) do
		ret[v] = CMD.get_tag(_player_id,v)
	end

	return ret
end

-- 返回所有 tag 数组
function CMD.get_player_tag_list(_player_id)
	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx CMD.get_player_tag_list 0000:",_player_id)
	local ret = PUBLIC.get_player_tags(_player_id)
	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx CMD.get_player_tag_list 1111:",_player_id,basefunc.tostring(ret))
	return ret
end

-- 返回所有支持的 tag （供web调用）
function CMD.getAllTagList()

	local list = {}
	for k,v in pairs(PUBLIC.get_all_tags()) do
		table.insert(list,k)
	end

	table.sort(list)

	return string.format([[
	{
		"result":0,
		"list":%s
	}
	]],basefunc.jsonEncodeArray(list))

end

-- 返回特定玩家的 tag （供web调用）
function CMD.getPlayerTagList(_player_id)

	local tags = CMD.get_player_tag_list(_player_id) or {}
	
	return string.format([[
	{
		"result":0,
		"list":%s
	}
	]],basefunc.jsonEncodeArray(tags))

end

-- 返回所有支持的权限 （供web调用，仅包含带 web_ 前缀的权限）
function CMD.getAllAuthList()

	local _permis = LD.permi_manager.get_all_permission_key() or {}

	local _permis2 = {}
	
	for _,v in ipairs(_permis) do
		if string.find(v,"^web_") then
			table.insert(_permis2,v)
		end
	end

	-- 3 元礼包特殊权限
	table.insert(_permis2,"web_gift_bag_3_yuan")

	table.sort(_permis2)
	
	return string.format([[
	{
		"result":0,
		"list":%s
	}
	]],basefunc.jsonEncodeArray(_permis2))

end


-- 检查玩家权限 （供web调用）
function base.CMD.checkExchangeStatus(_data)
	
	local ok, arg = xpcall(function ()
			return cjson.decode(_data)
		end,
		function (error)
			print(error)
		end)
	
	if not ok then
		return {result=1001,msg="解析 json 内容出错!"}
	end

	if not arg.player_id then
		return {result=1001,msg="参数错误!"}
	end

	if not skynet.call(DATA.service_config.data_service,"lua","is_player_exists",arg.player_id) then
		return {result=1004,msg="玩家 id 不存在!"}
	end

	-- 空 表示 不要求任何权限
	if not arg.authflags or not next(arg.authflags) then
		return {result=0,msg="成功"} 
	end

	local _variants = skynet.call(DATA.service_config.data_service,"lua","get_player_variants",arg.player_id)

	-- 任意一个满足即可
	local _fail_desc
	for _,v in ipairs(arg.authflags) do

		-- 3 元礼包特殊权限
		if v == "web_gift_bag_3_yuan" then

			-- 必须满是 vip0
			local _yes,_desc = LD.permi_manager.judge_permission_effect("web_vip0",_variants)
			if _yes then

				local _pay6_count = skynet.call(DATA.service_config.data_service,"lua","get_orig_variant",arg.player_id,"pay_6_yuan") or 0
				local _shop_count = skynet.call(DATA.service_config.data_service,"lua","get_orig_variant",arg.player_id,"gift_bag_3_yuan") or 0
				local _allow_count = math.min(_pay6_count,skynet.getcfgi("max_gift_bag_3_yuan_shop") or 8)
				if _shop_count < _allow_count then
					return {result=0,msg="成功"}   -- 满足一个即可
				else
					if not _fail_desc then
						_fail_desc = "每单笔充值达6元可兑换1次！"
					end
				end
			else
				_fail_desc = "该商品为 VIP0 专享！"
			end
			
		else
			local _yes,_desc = LD.permi_manager.judge_permission_effect(v,_variants)
			if _yes then
				return {result=0,msg="成功"}   -- 满足一个即可
			else
				if not _fail_desc then
					_fail_desc = _desc
				end
			end
		end
	end

	return {result=3406,msg=_fail_desc}
end

-- 强制设定 标签
-- 参数 _period ： 更新周期 ， 0 手动更新，1 小时，2 天，3 周
function CMD.force_set_player_tag(_player_id,_tag,_period)
	return PUBLIC.set_player_tag(_player_id,_tag,_period)
end

--- add by wss 强行设置标签& 发送标签改变消息
function CMD.force_set_player_tag_and_msg(_player_id,_tag,_period)
	local _old_tags = CMD.get_player_tag_list(_player_id)
	PUBLIC.set_player_tag(_player_id,_tag,_period)
	local _new_tags = CMD.get_player_tag_list(_player_id)

	

	local _same = LF.compare_tags_is_same(_old_tags , _new_tags)
	if not _same then
	--	print("xxx--------------------manager_on_variant_data_change22:",_player_id , _variant_data , _change_variant_key)
		-- 触发事件
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , { 
			name = "player_tag_vec_changed" , 
			send_filter = { player_id = _player_id } } , 
			_player_id , 
			_new_tags
		)
	end
end

--[[ 强制设定：通过文件 批量 设置
	-- 先生成sql
	-- 在启服之前执行sql
	-- 一般用于处理项较多的情况
--]]
function CMD.batch_force_set_player_tag_strong(_file)

	local batch_tags = basefunc.path.reload_lua(_file)
	batch_tags = batch_tags and batch_tags.main or {}
	
	local _count = skynet.getcfg("batch_force_set_player_tag_count") or 20000

	local all_tags_cfg = PUBLIC.get_all_tags()

	local sqls = {}

	for i=1,_count do
		local _data = batch_tags[#batch_tags]
		if not _data then
			batch_tags = nil
			break
		end
		batch_tags[#batch_tags] = nil

		local tag_cfg = all_tags_cfg[_data.tag]

		local sql_data = nil

		if tag_cfg then
			if tag_cfg.type then
				sql_data = {
					player_id = _data.player_id,
					tag = tag_cfg.type,
					is_type = 1,
					value = _data.tag,
					period = _data.period,
					time = os.time(),
				}
			else
				sql_data = {
					player_id = _data.player_id,
					tag = _data.tag,
					is_type = 0,
					value = "y",
					period = _data.period,
					time = os.time(),
				}
			end
		end

		if sql_data then
			sqls[#sqls + 1] = PUBLIC.safe_insert_sql("player_tag",sql_data,{"player_id","tag"}) 
		end
			--print("xxx--------------------deal___",tostring( _data.player_id) ,_data.tag,_data.period)
			--PUBLIC.set_player_tag( tostring( _data.player_id) ,_data.tag,_data.period)
	end

	basefunc.path.write("./tag_insert.sql",table.concat(sqls,"\n"))
	
end

-- 强制设定：通过文件 批量 设置
--[[
	-- 服务器运行过程中设置
]]
function CMD.batch_force_set_player_tag(_file)

	if LD.batch_set_tag_timer then
		return "last batch is doing:" .. tostring(LD.batch_tag_file)
	end

	local ok,msg = pcall(function()
		LD.batch_tags = basefunc.path.reload_lua(_file)
		LD.batch_tags = LD.batch_tags and LD.batch_tags.main or {}
	end)
	if not ok then
		return msg
	end
	--dump(LD.batch_tags , "xxx--------------------LD.batch_tags:")
	LD.batch_tag_file = _file
	LD.batch_set_tag_timer = skynet.timer(2,function()
		--print("xxx-------------LD.batch_set_tag_timer")
		local _count = skynet.getcfg("batch_force_set_player_tag_count") or 200

		for i=1,_count do
			local _data = LD.batch_tags[#LD.batch_tags]
			if not _data then
				LD.batch_set_tag_timer:stop()
				LD.batch_set_tag_timer = nil
				LD.batch_tags = nil
				LD.batch_tag_file = nil
				break
			end
			LD.batch_tags[#LD.batch_tags] = nil
			--print("xxx--------------------deal___",tostring( _data.player_id) ,_data.tag,_data.period)
			PUBLIC.set_player_tag( tostring( _data.player_id) ,_data.tag,_data.period)
		end
	end)
end

---add by wss
-- stop 强制设定：通过文件 批量 设置
function CMD.stop_batch_force_set_player_tag()
	if LD.batch_set_tag_timer then
		LD.batch_set_tag_timer:stop()
		LD.batch_set_tag_timer = nil
		LD.batch_tags = nil
		LD.batch_tag_file = nil
	end
end

function CMD.start(_service_config)
	DATA.service_config = _service_config

	-- 变量管理器
	DATA.var_data_manager.init("tag_center_msg")
	----避免 循环
	--[[DATA.var_data_manager.load_player_variant_data = function(_player_id)
		return skynet.call( DATA.service_config.data_service , "lua" , "get_player_variants" , _player_id , { tag_vec = true } )
	end--]]

	-- 标签管理器
	DATA.tag_cfg_manager.init(false,"tag_server_config")

	-- 权限管理器
	LD.permi_manager.init(false,"permission_server_config")

	tag_inner.init()
	tag_store.init()

end

-- 启动服务
base.start_service()
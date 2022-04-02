--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 标签持久化（仅对非即时运算的标签）
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "client.crypt"
-- crypt.hmac64_md5
require "data_func"

local md5 = require "md5"
-- md5.hmacmd5

require "normal_enum"
require "printfunc"

require "common_data_manager_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

-- 标签计算函数（包括类型，类型和 标签 不能重名 ）
PUBLIC.TAG_FUNC = PUBLIC.TAG_FUNC or {}


local LD = base.LocalData("tag_store",{

	player_tag_db = nil,

	-- 所有的标签类别： type => {tags={tag1,tag2,...},inner=true/false}
	all_types = {},

	-- 所有的标签：tag => {inner=true/false,type=}
	all_tags = {},

	-- 需要更新的标签： player id,tag => true
	hour_update_tags = {},
	day_update_tags = {},
	week_update_tags = {},

	-- 重新计算的队列
	update_tag_queue = basefunc.queue.new(),
})

local LF = base.LocalFunc("tag_store")

function LF.load_player_tags(_player_id)

	local _sql = PUBLIC.format_sql( "select * from player_tag where player_id=%s",_player_id)
	local ret = PUBLIC.db_query(_sql)
	if( ret.errno ) then
		error(string.format("load_player_tags sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
	end

	local _tags = {}

	for _,_tag in ipairs(ret) do
		_tags[_tag.tag] = _tag
	end

	return _tags
end

-- 刷新所有标签信息
function LF.refresh_tag_configs()

	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx tag store refresh_tag_configs")

	-- 标签类别
	local _types = {}
	for k,v in pairs(PUBLIC.get_inner_tag_types()) do
		_types[k] = {
			tags = v,
			inner = true,
		}
	end
	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx tag store refresh_tag_configs 222:",basefunc.tostring(_types))

	for k,v in pairs(DATA.tag_cfg_manager.type_map) do
		if _types[k] then
			error("refresh_tag_configs tag type conflict.1:",k)
		end
		_types[k] = {
			tags = v,
		}
	end

	-- 标签
	local _tags = {}
	for k,v in pairs(PUBLIC.get_inner_tags()) do
		if _types[k] then
			error("refresh_tag_configs tag name , type conflict.2:",k)
		end
		if _tags[k] then
			error("refresh_tag_configs tag name ,inner conflict.3:",k)
		end
		_tags[k] = {
			inner=true,
			type=v.type,
		}
	end
	for k,v in pairs(DATA.tag_cfg_manager.permission_cfg_data) do
		if _types[k] then
			error("refresh_tag_configs tag name , type conflict.4:",k)
		end
		if _tags[k] then
			error("refresh_tag_configs tag name ,inner conflict.5:",k)
		end
		_tags[k] = {
			type=v.type,
		}
	end

	LD.all_types = _types;
	LD.all_tags = _tags;
end

function LF.update_tag_base(_player_tags,_interval)

	local _now = os.time()

	for _player_id,v in pairs(_player_tags) do
		local _data = LD.player_tag_db:get_data(_player_id)
		if _data and next(_data) then
			for _tag,_ in pairs(v) do

				local _tag_data = _data[_tag]
				if _tag_data and _tag_data.time then
					if _now - _tag_data.time >= _interval then
						_tag_data.time = _now
						LD.update_tag_queue:push_back({
							player_id=_player_id,
							tag = _tag, -- 这个 tag 可能是 type
						})
					end
				else
					print("update_tag_base error,not found tag in db:",_player_id,_tag)
				end
			end
		else
			print("update_tag_base error,not found player id in tag db:",_player_id)
		end
	end
end

function LF.update_tag_hour()

	LF.update_tag_base(LD.hour_update_tags,3500)
end

function LF.update_tag_day()
	LF.update_tag_base(LD.day_update_tags,86000)
end

function LF.update_tag_week()
	LF.update_tag_base(LD.week_update_tags,604000)
end

-- 重新计算标签类型
function LF.recalc_tag_type(_player_id,_type)
	if PUBLIC.TAG_FUNC[_type] then
		--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx LF.recalc_tag_type 111 :",_player_id,_type)
		return PUBLIC.TAG_FUNC[_type](_player_id)
	else
		local _tdata = LD.all_types[_type]
		--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx LF.recalc_tag_type 222 :",_player_id,_type,basefunc.tostring(_tdata))
		if _tdata then
			local _orig_var = DATA.var_data_manager.get_ori_player_variant_data(_player_id )
			for _,_tag in pairs(_tdata.tags) do
				if DATA.tag_cfg_manager.judge_permission_effect(_tag,_orig_var) then
					return _tag
				end
			end
		else
			print("recalc_tag_type error,type not found:",_type)
		end

		return nil
	end
end

-- 重新计算标签值
function LF.recalc_tag_value(_player_id,_tag)

	if PUBLIC.TAG_FUNC[_tag] then
		return PUBLIC.TAG_FUNC[_tag](_player_id)
	else

		local _d = LD.all_tags[_tag]
		if _d and _d.inner then
			return PUBLIC.inner_tag_func(_player_id,_tag)
		else
			local _orig_var = DATA.var_data_manager.get_ori_player_variant_data(_player_id )
			return DATA.tag_cfg_manager.judge_permission_effect(_tag,_orig_var)
		end
	end
end

function LF.deal_update_tag_queue()

	local _count = skynet.getcfg("update_tag_queue_count") or 500
	for i=1,_count do

		if LD.update_tag_queue:empty() then
			break
		end

		local _q_data = LD.update_tag_queue:pop_front()
		local _db_data = LD.player_tag_db:get_data(_q_data.player_id)
		if _db_data and next(_db_data) then
			local _tag_data = _db_data[_q_data.tag] -- 这个 tag 可能是类型
			if 1 == _db_data.is_type then
				_tag_data.value = LF.recalc_tag_type(_q_data.player_id,_q_data.tag)
			else
				if LF.recalc_tag_value(_q_data.player_id,_q_data.tag) then
					_tag_data.value = "y"
				else
					_tag_data.value = "n"
				end
			end
			local _qname,_sqlid = PUBLIC.db_exec_call(PUBLIC.format_sql([[update player_tag set value=%s,time=%s where player_id=%s and tag=%s;]],
					_tag_data.value,_q_data.player_id,_q_data.tag))
			LD.player_tag_db(_q_data.player_id,_qname,_sqlid)
		else
			print("deal_update_tag_queue error,player not found:",_q_data.player_id)
		end

	end
end

-- 载入周期更新的数据
function LF.load_update_tags()

	local _sql = "select * from player_tag where period>0 and period <= 3"
	local ret = PUBLIC.db_query(_sql)
	if( ret.errno ) then
		error(string.format("load_update_tags sql error: sql=%s\nerr=%s\n",_sql,basefunc.tostring( ret )))
	end

	LD.hour_update_tags = {}
	LD.day_update_tags = {}
	LD.week_update_tags = {}

	for _,v in ipairs(ret) do
		if v.period == 1 then
			basefunc.to_keys(LD.hour_update_tags,true,v.player_id,v.tag)
		elseif v.period == 2 then
			basefunc.to_keys(LD.day_update_tags,true,v.player_id,v.tag)
		elseif v.period == 3 then
			basefunc.to_keys(LD.week_update_tags,true,v.player_id,v.tag)
		end
	end
end

function LF.init()

	-- 初始化数据对象
	LD.player_tag_db = basefunc.hot_class.data_manager_cls.new( {
		load_data = function(_player_id) return LF.load_player_tags(_player_id) end,
	} , tonumber(skynet.getenv("data_man_cache_size")) or 20000 )

	-- 载入周期更新的数据
	LF.load_update_tags()

	-- 刷新标签配置信息
	skynet.timer(60,function() LF.refresh_tag_configs() end,true)

	-- 处理 重新计算 周期性标签 的 队列
	skynet.timer(5,function() LF.deal_update_tag_queue() end,true)

	-- 重新计算标签值
	skynet.timer2_hour(function() LF.update_tag_hour() end,0,true)
	skynet.timer2_day(function() LF.update_tag_day() end,9000,true) -- 每天 2:30
	skynet.timer2_week(function() LF.update_tag_week() end,9000,true) -- 每周一 2:30
end

-- 得到所有标签
function PUBLIC.get_all_tags()
	return LD.all_tags
end

-- 得到所有类别
function PUBLIC.get_all_types()
	return LD.all_types
end

-- 得到某个标签类型（外部调用）
function PUBLIC.get_player_tag_type(_player_id,_type)
	local _db_data = LD.player_tag_db:get_data(_player_id)
	local _tag
	if _db_data and _db_data[_type] then -- 先找数据记录
		--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx PUBLIC.get_player_tag_type 111 :",_player_id,_type)
		_tag = _db_data[_type].value
	else
		--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx PUBLIC.get_player_tag_type 222 :",_player_id,_type)
		_tag = LF.recalc_tag_type(_player_id,_type)
	end

	if _tag and _tag ~= "" then
		return _tag
	else
		return nil
	end
end

-- 判断玩家是否具有某个标签（不考虑类型）
function PUBLIC.judge_player_tag_base(_player_id,_tag)

	local _db_data = LD.player_tag_db:get_data(_player_id)
	if _db_data and _db_data[_tag] then  -- 先找数据记录
		if _db_data[_tag].value == "y" then
			return true
		end
	else
		if LF.recalc_tag_value(_player_id,_tag) then
			return true
		end
	end

	return false
end

-- 判断玩家是否具有某个标签（外部调用）
function PUBLIC.judge_player_tag(_player_id,_tag)
	local _tagdata = LD.all_tags[_tag]
	if _tagdata.type then
		return PUBLIC.get_player_tag_type(_player_id,_tagdata.type) == _tag
	else
		return PUBLIC.judge_player_tag_base(_player_id,_tag)
	end
end

-- 得到玩家拥有的标签（外部调用）
function PUBLIC.get_player_tags(_player_id)
	--dump(LD.all_types , "xxxx----------------------------LD.all_types:")
	local _tags = {}

	--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx PUBLIC.get_player_tags 111:",_player_id,basefunc.tostring(LD.all_types))

	-- 处理带 类型的
	for _type,_ in pairs(LD.all_types) do

		local _tag = PUBLIC.get_player_tag_type(_player_id,_type)
		--print.tag_debug("22xxxxxxxxxxxxxxxxxxxxxxxx PUBLIC.get_player_tags 222:",_player_id,_type,_tag)
		if _tag then
			table.insert(_tags,_tag)
		end
	end


	--dump(_tags , "xxx-------------------------------_tags__1")
	-- 处理不带类型的
	for _tag,_d in pairs(LD.all_tags) do
		if not _d.type then
			local _db_data = LD.player_tag_db:get_data(_player_id)
			if _db_data and _db_data[_tag] then  -- 先找数据记录
				if _db_data[_tag].value == "y" then
					table.insert(_tags,_tag)
				end
			else
				if LF.recalc_tag_value(_player_id,_tag) then
					table.insert(_tags,_tag)
				end
			end
		end
	end
	--dump(_tags , "xxx-------------------------------_tags__2")
	return _tags
end

-- 强制贴标签 或 类型
-- 参数 _period ： 更新周期 ， 0 手动更新，1 小时，2 天，3 周
function PUBLIC.set_player_type_tag(_player_id,_type,_name,_value,_period)

	if 1 == _period then
		basefunc.to_keys(LD.hour_update_tags,true,_player_id,_name)
	elseif 2 == _period then
		basefunc.to_keys(LD.day_update_tags,true,_player_id,_name)
	elseif 3 == _period then
		basefunc.to_keys(LD.week_update_tags,true,_player_id,_name)
	end

	local _data = {
		player_id = _player_id,
		tag = _name,
		is_type = _type,
		value = _value,
		period = _period,
		time = os.time(),
	}

	local _tag_data = LD.player_tag_db:get_data(_player_id) or {}
	_tag_data[_name] = _data

	local _qname,_sqlid = PUBLIC.db_exec_call(PUBLIC.safe_insert_sql("player_tag",_data,{"player_id","tag"}))

	LD.player_tag_db:add_or_update_data(_player_id,_tag_data,_qname,_sqlid)

end

-- 强制贴标签（外部调用）
-- 参数 _period ： 更新周期 ， 0 手动更新，1 小时，2 天，3 周
function PUBLIC.set_player_type(_player_id,_type,_tag,_period)

	PUBLIC.set_player_type_tag(_player_id,1,_type,_tag,_period)

end

-- 强制贴标签（外部调用）
-- 参数 _period ： 更新周期 ， 0 手动更新，1 小时，2 天，3 周
function PUBLIC.set_player_tag(_player_id,_tag,_period)

	local _tagdata = LD.all_tags[_tag]
	if _tagdata.type then
		PUBLIC.set_player_type_tag(_player_id,1,_tagdata.type,_tag,_period)
	else
		PUBLIC.set_player_type_tag(_player_id,0,_tag,"y",_period)
	end
end

return LF
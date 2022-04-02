--[[
	通用排行榜服务

	--- other_data 需要 手动处理
	--- 发邮件 需要 手动处理 , 加一个对应的邮件配置就行了。

--]]

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

require "data_func"
require "normal_enum"
require "printfunc"
require "rank_center_service.rank_center_interface"
require "common_merge_push_sql_lib"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

DATA.service_config = nil

---- 玩家的系统参考量的管理器
DATA.variant_data_manager = require "common_variant_data_manager"
--- 权限判断模块
DATA.permission_manager = require "permission_manager.common_permission_manager"


DATA.msg_tag = "rank_center_service"

----- 分数来源类型
DATA.source_type = {
	xiaoxiaole_award = "xiaoxiaole_award",
	
	pvp_jifen_total_set = "pvp_jifen_total_set" ,
}

----- 分数来源对应监听的消息名&处理函数
DATA.source_type_deal_vec = {
	xiaoxiaole_award = { msg_name = "xiaoxiaole_award" , deal_func = "deal_xiaoxiaole_award" },
	
	pvp_jifen_award = { msg_name = "pvp_jifen_award" , deal_func = "deal_pvp_jifen_award" },
}


DATA.config = {}
----- 所有的排行榜活动
DATA.running_rank_data = {}


DATA.valid_day_num = 7
--- 玩家的第一次登陆时间
DATA.player_first_login_time = {}
--- 玩家的vip等级数据
DATA.player_vip_level_vec = {}

----- 所有的结算的处理的timeout的取消器
DATA.settle_timeout_canclers = {}

----- 所有的玩家的排行榜数据 [rank_type][player_id] = { [1] = {xx} , [2] = {xx} } -- 支持多个数据  --- 这个里面只存在运行中的排行榜数据
DATA.rank_player_data = {}

--自动增加分数的玩家信息列表
DATA.auto_add_vec = {}

DATA.player_name_vec = {}
DATA.player_head_image_vec = {}

DATA.name_head_refresh_delay = 3600

-- 玩家名单数据(是hash)
DATA.player_list_data = {}

--更新间隔
DATA.update_dt = 1




----- 执行sql
function PUBLIC.query_data(_sql)
	local ret = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)
	if( ret.errno ) then
		print(PUBLIC.format_sql("query_data sql error: sql=%s\nerr=%s\n" , _sql , basefunc.tostring( ret )))
		return nil
  	end
	return ret
end

--- 把sql插入队列中
function PUBLIC.db_exec(_sql , _queue_name)
  	skynet.send(DATA.service_config.data_service,"lua","db_exec",_sql , _queue_name)
end

----- 从数据库中载入某种类型的排行榜的玩家数据
function PUBLIC.load_ob_data( _rank_type )
	local _sql = PUBLIC.format_sql( [[ select A.data_id , A.other_data, A.player_id,A.rank_type,A.score,A.player_name,B.head_image,ifnull(A.time,0) time
											from player_rank_data A inner join player_info B on A.player_id = B.id where A.rank_type = %s; ]] , _rank_type )

	--print(_sql)

	local ret = PUBLIC.query_data(_sql)

	--dump(ret , "xxxx-----------------------load_ob_data , ret")

	------ 从数据库载入时，把每个人的所有数据组装到一个表里
	local result = {}
	if ret then
		for key,data in pairs(ret) do
			result[data.player_id] = result[data.player_id] or {}
			local tar_data = result[data.player_id]

			tar_data[#tar_data + 1] = data
		end
	end

	--dump(result , "xxx--------------load_ob_data , result")

	return result
end


function PUBLIC.load_player_list_data()

	local _sql = [[select * from rank_server_player_list_data;]]
	local pld = skynet.call(DATA.service_config.data_service,"lua","db_query",_sql)

	DATA.player_list_data = {}
	for i,v in ipairs(pld) do

		local rtd = DATA.player_list_data[v.rank_type] or {}
		DATA.player_list_data[v.rank_type] = rtd

		rtd[v.player_id] = v.status

	end

end

-- 特殊玩家名单操作
function PUBLIC.add_player_list_data(_player_id,_rank_type,_status)

	local rtd = DATA.player_list_data[_rank_type] or {}
	DATA.player_list_data[_rank_type] = rtd

	rtd[_player_id] = _status

	local _sql = string.format([[
					SET @_player_id = '%s';
					SET @_rank_type = '%s';
					SET @_status = %s;
					insert into rank_server_player_list_data
					(player_id,rank_type,status,time)
					values(@_player_id,@_rank_type,@_status,FROM_UNIXTIME(%u))
					on duplicate key update
					status = @_status;
					]]
					,_player_id
					,_rank_type
					,_status
					,os.time())

	skynet.send(DATA.service_config.data_service,"lua","db_query",_sql)

end

-- 特殊玩家名单操作
function PUBLIC.delete_player_list_data(_player_id,_rank_type)

	local rtd = DATA.player_list_data[_rank_type]
	if rtd then

		rtd[_player_id] = nil

		local _sql = string.format([[DELETE FROM rank_server_player_list_data WHERE player_id = '%s' AND rank_type = '%s';]]
									,_player_id
									,_rank_type)

		skynet.send(DATA.service_config.data_service,"lua","db_query",_sql)

	end

end


----- 载入配置
function PUBLIC.load_config(_raw_config)
	local config = _raw_config

	DATA.running_rank_data = {}
	---- 清掉结算timeout
	PUBLIC.clear_all_settle_timeout()
	---- 清掉消息监听
	PUBLIC.clear_all_msg_listener()

	--奖励列表
	local aws = {}
	for i,ad in ipairs(config.awards) do

		aws[ad.award_id] = aws[ad.award_id] or {}
		local len = #aws[ad.award_id]+1

		local target_asset_type = ad.asset_type
		---- 处理限时道具
		local str_split_vec = basefunc.string.split(ad.asset_type, "_")

		local obj_lifetime = nil
		if str_split_vec and type(str_split_vec) == "table" and next(str_split_vec) then
			if str_split_vec[1] == "obj" then
				obj_lifetime = 86400
				if tonumber(str_split_vec[#str_split_vec]) then
					target_asset_type = ""
					for i=1,#str_split_vec - 1 do
						target_asset_type = target_asset_type .. str_split_vec[i]
						if i ~= #str_split_vec - 1 then
							target_asset_type = target_asset_type .. "_"
						end
					end

					obj_lifetime = tonumber( str_split_vec[#str_split_vec] )
				end
			end
		end

		aws[ad.award_id][len] = {
			asset_type = target_asset_type,
			value = ad.asset_count,
			weight = ad.get_weight or 1,
			award_name = ad.award_name,
			award_id = ad.award_id,
		}

		if obj_lifetime then
			aws[ad.award_id][len].value = nil
			aws[ad.award_id][len].lifetime = obj_lifetime
		end
	end

	--奖励模式表
	local award_model = {}
	for i,model in ipairs( config.award_model ) do
		award_model[model.model_id] = award_model[model.model_id] or {}
		local len = #award_model[model.model_id] + 1

		model.award_data = model.award_id and aws[model.award_id] or {}

		award_model[model.model_id][len] = model
	end

	--结算模式
	local settle_model = {}
	for i,model in pairs(config.settle_model) do
		settle_model[model.id] = {
			is_clear = model.is_clear,
			award_model = model.award_model and award_model[model.award_model] ,
			settle_time_model = config.settle_time_model[model.settle_time_model],
		}
	end

	--来源条件
	local source_condition = {}
	for id,data in pairs(config.source_condition) do
		source_condition[ data.condition_id ] = source_condition[ data.condition_id ] or {}
		local cond = source_condition[ data.condition_id ]
		cond[data.condition_name] = {
			condition_value = data.condition_value,
			judge_type = data.judge_type,
		}
	end

	--分数来源
	local score_source = {}
	for i,source in pairs(config.score_source) do
		score_source[source.source_id] = score_source[source.source_id] or {}
		--local len = #score_source[source.source_id] + 1
		score_source[source.source_id][source.source_type] = {
			source_condition = source.condtion_id and source_condition[source.condtion_id] ,
		}

	end

	--参与条件
	local join_condition = {}
	for id,data in pairs(config.join_condition) do
		join_condition[ data.condition_id ] = join_condition[ data.condition_id ] or {}
		local cond = join_condition[ data.condition_id ]
		cond[data.condition_name] = {
			condition_value = data.condition_value,
			judge_type = data.judge_type,
		}
	end

	--[[local show_model = {}
	for id,data in pairs(config.show_model) do
		if data.max_show_num == -1 then
			data.max_show_num = 9999999
		end
		if data.max_rank_num == -1 then
			data.max_rank_num = 9999999
		end

		show_model[ data.id ] = data
	end--]]

	DATA.show_model_config = {}

	if config and config.main and next(config.main) then
		for key,data in pairs(config.main) do
			if data.enable == 1 then
				data.score_source = score_source[data.score_source] or {}
				data.join_condition = data.join_condition and join_condition[data.join_condition]
				data.show_model = config.show_model[data.show_model]
				data.settle_model = settle_model[data.settle_model]

				DATA.show_model_config[data.rank_type] = data.show_model

				DATA.running_rank_data[data.rank_type] = data

				------- 根据来源类型加监听
				--for source_type,data in pairs(data.score_source) do
				--	PUBLIC.add_msg_listener_by_rank_source( source_type )
				--end
				------- 根据结算数据，处理结算数据
				PUBLIC.deal_settle_model( data.rank_type , data.settle_model , data.begin_time )

			end
		end

	end

	--dump(DATA.running_rank_data , "xxxx----------------------DATA.running_rank_data:")

	PUBLIC.add_msg_listener_by_rank_source( )

	-------------- 根据运行中的排行榜数据来载入数据库中的数据，只需要运行中的排行榜数据
	--- 先清空(别清空，如果频繁重载配置，可能会有问题)
	--DATA.rank_player_data = {}
	for rank_type , rank_data in pairs(DATA.running_rank_data) do
		---- 如果内存中沒有载入，再载入，有的就不动
		if not DATA.rank_player_data[ rank_type ] then
			DATA.rank_player_data[ rank_type ] = PUBLIC.load_ob_data( rank_type )
		end
	end

--	PUBLIC.load_player_list_data()

end

function PUBLIC.load_auto_add_config(_raw_config)
	local config = _raw_config

	local now_time = os.time()
	DATA.auto_add_vec = {}

	if config and config.main then
		for key,data in pairs(config.main) do
			local player_id = tostring( data.player_id )
			local player_name = tostring(data.player_name)
			local rank_type = tostring(data.rank_type)

			DATA.auto_add_vec[ player_id ] = DATA.auto_add_vec[ player_id ] or {}
			local target_player_vec = DATA.auto_add_vec[ player_id ]
			target_player_vec[rank_type] = target_player_vec[rank_type] or {}

			local target_vec = target_player_vec[rank_type]
			target_vec.player_id = player_id
			target_vec.player_name = player_name
			target_vec.rank_type = data.rank_type
			target_vec.deal_model = {}

			if config[ data.deal_model ] and type(config[ data.deal_model ]) == "table" then

				for key,model_data in pairs(config[ data.deal_model ]) do
					if model_data.deal_time > now_time then

						local _other_data = nil
						if model_data.other_data and type( model_data.other_data ) == "table" then
							_other_data = model_data.other_data[1]
						end

						target_vec.deal_model[#target_vec.deal_model + 1] = {
							add_value = model_data.add_value,
							other_data = _other_data,
							source_type = model_data.source_type ,
							deal_time = model_data.deal_time,
							is_deal = false,
						}
					end
				end

			end

		end
	end
	--dump( DATA.auto_add_vec , "xxxx-------------------------DATA.auto_add_vec:" )
end
---- 检查


---- 名单更新进行移除某个玩家的排行数据(名单加减人都可能需要操作)
function PUBLIC.delete_list_player_rank_data(_player_id , _rank_type)

	local rrd = DATA.running_rank_data[_rank_type]
	if not rrd then
		return
	end

	local now_time = os.time()

	----- 如果排行榜不在活动时间内
	if now_time < rrd.begin_time or now_time > rrd.end_time then
		return
	end

	-- 检查 参与条件
	local is_cond = PUBLIC.check_join_condition( _player_id , rrd.join_condition , _rank_type)
	if is_cond then
		return
	end

	-- 对玩家排行的分数归零
	local rpds = DATA.rank_player_data[_rank_type]
	if rpds then
		local rpd = rpds[_player_id]
		if rpd then
			CMD.real_add_rank_score( _player_id , _rank_type , nil , -rpd.score )
		end
	end
end


-- -- 移除玩家某个类型的排行榜数据
-- function CMD.recover_player_rank( _player_id , _rank_type )
-- 	local rrd = DATA.running_rank_data[_rank_type]
-- 	if not rrd then
-- 		return
-- 	end

-- 	local now_time = os.time()

-- 	----- 如果排行榜不在活动时间内
-- 	if now_time < rrd.begin_time or now_time > rrd.end_time then
-- 		return
-- 	end

-- 	-- 对玩家排行的分数归零
-- 	local rpds = DATA.rank_player_data[_rank_type]
-- 	if rpds then
-- 		local rpd = rpds[_player_id]
-- 		if rpd then
-- 			CMD.real_add_rank_score( _player_id , _rank_type , nil , -rpd.score )
-- 			PUBLIC.save_player_rank_remove_log(  _player_id , _rank_type , "remove" , -rpd.score)
-- 		end
-- 	end
-- end


-- 移除玩家某个类型的排行榜数据
function CMD.remove_player_rank( _player_id , _rank_type )
	local rrd = DATA.running_rank_data[_rank_type]
	if not rrd then
		return
	end

	local now_time = os.time()

	----- 如果排行榜不在活动时间内
	if now_time < rrd.begin_time or now_time > rrd.end_time then
		return
	end

	-- 对玩家排行的分数归零
	local rpds = DATA.rank_player_data[_rank_type]
	if rpds then
		local rpd = rpds[_player_id]
		if rpd then
			local is_change = false
			for k,data in pairs(rpd) do
				is_change = true
				local score = data.score
				local other_data = basefunc.deepcopy(data.other_data)
				data.score = 0
				PUBLIC.save_player_rank_remove_log(  _player_id , _rank_type , "remove" , score , other_data )
			end
			if is_change then
				PUBLIC.add_or_update_rank_data( _player_id , _rank_type )
			end
		end

	end
end

function PUBLIC.save_player_rank_remove_log(  _player_id , _rank_type , _op_type , _score , _other_data )
	local sql_str = PUBLIC.format_sql( [[ insert into player_rank_remove_or_recover_log (player_id , rank_type , op_type , score , other_data) values(%s,%s,%s,%s,%s); ]] ,_player_id , _rank_type , _op_type , _score , _other_data)
	PUBLIC.db_exec(sql_str )
end

---- 创建一个默认的排行榜数据
function PUBLIC.create_defalut_rank_data(_player_id , _rank_type)
	local player_data = {}

	player_data.data_id = skynet.call( DATA.service_config.data_service , "lua" , "auto_inc_id" , "common_rank_data_id" )
	player_data.player_id = _player_id
	player_data.rank_type = _rank_type
	player_data.score = 0
	player_data.player_name = "*"
	player_data.head_image = ""
	player_data.time = os.time()
	player_data.other_data = ""

	return player_data
end


---- 获得某个玩家的某种排行榜类型的数据
function PUBLIC.get_player_rank_data(_player_id , _rank_type)
	local is_first_data = false
	---- 如果没有这个排行榜运行
	if not DATA.running_rank_data[_rank_type] then
		return nil
	end

	DATA.rank_player_data[_rank_type] = DATA.rank_player_data[_rank_type] or {}

	---- 如果一个数据都没有，则会创建一个数据
	if not DATA.rank_player_data[_rank_type][_player_id] or not DATA.rank_player_data[_rank_type][_player_id][1] then
		DATA.rank_player_data[_rank_type][_player_id] = DATA.rank_player_data[_rank_type][_player_id] or {}
		local tar_data = DATA.rank_player_data[_rank_type][_player_id]

		local player_data = PUBLIC.create_defalut_rank_data(_player_id , _rank_type)
		--player_data.is_first_data = true   --- 这句话不知道谁写的
		is_first_data = true

		tar_data[1] = player_data

		PUBLIC.add_or_update_rank_data( _player_id , _rank_type )
	end

	---- 排一次序
	--table.sort( DATA.rank_player_data[_rank_type][_player_id] , PUBLIC.rank_data_sort_func )

	PUBLIC.sort_rank_data( _rank_type , DATA.rank_player_data[_rank_type][_player_id] )

	return DATA.rank_player_data[_rank_type][_player_id] , is_first_data
end

---- 新增or更新数据
function PUBLIC.add_or_update_rank_data( _player_id , _rank_type )
	local player_rank_data = PUBLIC.get_player_rank_data(_player_id , _rank_type)
	if player_rank_data and next(player_rank_data) and player_rank_data[1] then
		--local sql_str = PUBLIC.format_sql([[
		--					SET @_player_id = %s;
		--					SET @_rank_type = %s;
		--					SET @_score = %s;
		--					SET @_player_name = %s ;
		--					SET @_time = %s ;
		--					insert into player_rank_data
		--					(player_id , rank_type , score , player_name , time)
		--					values(@_player_id,@_rank_type,@_score,@_player_name , @_time)
		--					on duplicate key update
		--					player_id = @_player_id,
		--					rank_type = @_rank_type,
		--					score = @_score,
		--					player_name = @_player_name,
		--					time = @_time;
		--				]] , rank_data.player_id , rank_data.rank_type , rank_data.score , rank_data.player_name , rank_data.time )

		--PUBLIC.db_exec(sql_str)

		---- 这里分排行榜的类型处理，
		local rank_cfg = DATA.running_rank_data[_rank_type]
		local data_save_type = "single"
		if rank_cfg and rank_cfg.data_save_type then
			data_save_type = rank_cfg.data_save_type
		end

		if data_save_type == "single" then
			--- 一个人只有一个数据
			DATA.update_merge_sql_pusher:add_to_sql_cache( { player_rank_data[1].data_id } , player_rank_data[1] )

		elseif data_save_type == "more" then
			--- 一个人多个数据
			-- 这里直接存
			for key,data in pairs(player_rank_data) do
				DATA.update_merge_sql_pusher:add_to_sql_cache( { data.data_id } , data )
			end
		end

	end

end

----- 检查来源条件
function PUBLIC.check_source_condition(_source_type , _source_condition , ... )
	local flag = true

	local _condition_data = _source_condition and _source_condition.source_condition

	if _source_type == DATA.source_type.buyu_award then
		flag = PUBLIC.check_source_cond_buyu_award( _condition_data , ...)

	end

	return flag
end



----- 检查参与条件
function PUBLIC.check_join_condition(_player_id , _join_condition_data , _rank_type)
	local flag = true

	if not _join_condition_data then
		return flag
	end

	for cond_name , cond_data in pairs(_join_condition_data) do
		if cond_name == "is_new_player" then
			flag = PUBLIC.check_join_cond_is_new_player(_player_id , cond_data )
		elseif cond_name == "vip_level" then
			flag = PUBLIC.check_join_cond_vip_level( _player_id , cond_data )
		elseif cond_name == "player_id" then
			flag = PUBLIC.check_join_cond_player_id( _player_id , cond_data , _rank_type)
		end

		if not flag then
			return false
		end
	end

	return flag
end

function PUBLIC.get_other_data(_rank_type , _source_type , ...)
	local other_data_vec = {}
	local other_data = ""

	

	return other_data
end

----- 增加分数
function CMD.add_rank_score(_player_id , _source_type , _add_score , ... )
	local now_time = os.time()
	------
	for rank_type , rank_data in pairs(DATA.running_rank_data) do
		repeat

		---------------------------------- ↓ 判断 限制条件 ↓ ------------------------------------
		----- 旧版，实时算
		--[[local is_can_do , error_desc = DATA.permission_manager.judge_permission_effect( "rank_" .. rank_type ,  DATA.variant_data_manager.get_player_variant_data(_player_id) )
		if not is_can_do then
			break
		end--]]
		----- 新版
		local variant_data = DATA.variant_data_manager.get_player_variant_data(_player_id)
		if variant_data and variant_data.act_permission and variant_data.act_permission["actp_rank_" .. rank_type]
			and variant_data.act_permission["actp_rank_" .. rank_type].is_work == 0 then
			----PS 没有配，是可以直接玩的
			break
		end
		---------------------------------- ↑ 判断 限制条件 ↑ ------------------------------------

		----- 如果排行榜不在活动时间内
		if now_time < rank_data.begin_time or now_time > rank_data.end_time then
			break
		end

		---- 默认规则 ，source_type 为 <<rank_type>> 时 可以通过给这个类型的排行榜加分数
		local force_add = false
		if string.find( _source_type , "^<<.+>>$" ) then
			local force_add_rank_type = string.sub( _source_type , 3 , -3 )
			if force_add_rank_type == rank_type then
				force_add = true
			end
		end
		--print("xxx-------------add_rank_score" , rank_type , _source_type , force_add and "true" or "false" )
		---- 如果这个排行榜没有这个来源
		if not rank_data.score_source or not rank_data.score_source[_source_type] then
			if not force_add then
				break
			end
		end

		---- 检查 来源条件
		local is_cond = PUBLIC.check_source_condition(_source_type , rank_data.score_source[_source_type] , ... )
		if not is_cond then
			break
		end

		---- 检查 参与条件
		is_cond = PUBLIC.check_join_condition( _player_id , rank_data.join_condition , rank_type)
		if not is_cond then
			break
		end

		local other_data = PUBLIC.get_other_data(rank_type , _source_type , ...)

		----- 所有条件通过，增加分数
		CMD.real_add_rank_score( _player_id , rank_type , _source_type , _add_score , nil , other_data )

		until true
	end
end

---- 获取某个人的名称
function PUBLIC.get_player_name(_player_id)
	local now_time = os.time()
	if not DATA.player_name_vec[_player_id] or now_time - DATA.player_name_vec[_player_id].last_time > DATA.name_head_refresh_delay then
		DATA.player_name_vec[_player_id] = DATA.player_name_vec[_player_id] or {}
		DATA.player_name_vec[_player_id].last_time = now_time
		DATA.player_name_vec[_player_id].player_name = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_info","name")
	end

	return DATA.player_name_vec[_player_id].player_name
end

---- 获取某个人的头像
function PUBLIC.get_player_head_image(_player_id)
	local now_time = os.time()
	if not DATA.player_head_image_vec[_player_id] or now_time - DATA.player_head_image_vec[_player_id].last_time > DATA.name_head_refresh_delay then
		DATA.player_head_image_vec[_player_id] = DATA.player_head_image_vec[_player_id] or {}
		DATA.player_head_image_vec[_player_id].last_time = now_time
		DATA.player_head_image_vec[_player_id].head_image = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_info","head_image")
	end

	return DATA.player_head_image_vec[_player_id].head_image
end


---- 真正的加分
function CMD.real_add_rank_score( _player_id , _rank_type , _source_type , _add_score , _player_name , _other_data)
	local rank_cfg = DATA.running_rank_data[_rank_type]
	if not rank_cfg then
		return
	end
	local other_data = _other_data or ""

	---- 这个会返回，没有数据的话会默认带一个
	local player_data = PUBLIC.get_player_rank_data(_player_id , _rank_type)

	---- 按照不同的数据类型来处理
	local data_deal_type = "nor_add"
	if rank_cfg and rank_cfg.data_deal_type then
		data_deal_type = rank_cfg.data_deal_type
	end

	local function set_value_for_player_data(_player_data)
		_player_data.score = _add_score

		---- 名字处理
		local tar_player_name = _player_name
		if not tar_player_name then
			tar_player_name = PUBLIC.get_player_name(_player_id)
		end
		_player_data.player_name = tar_player_name
		------ 头像处理
		_player_data.head_image = PUBLIC.get_player_head_image(_player_id)
		_player_data.time = os.time()
		_player_data.other_data = other_data
	end

	---- 给一个表增加分数
	local function add_value_for_player_data(_player_data)
		_player_data.score = _player_data.score + _add_score

		---- 名字处理
		local tar_player_name = _player_name
		if not tar_player_name then
			tar_player_name = PUBLIC.get_player_name(_player_id)
		end
		_player_data.player_name = tar_player_name
		------ 头像处理
		_player_data.head_image = PUBLIC.get_player_head_image(_player_id)
		_player_data.time = os.time()
		_player_data.other_data = other_data
	end

	if data_deal_type == "nor_add" then
		---- 单数据的增加的方式
		--[[player_data[1].score = player_data[1].score + _add_score

		---- 名字处理
		local tar_player_name = _player_name

		if not tar_player_name then
			tar_player_name = PUBLIC.get_player_name(_player_id)
		end

		player_data[1].player_name = tar_player_name

		------ 头像处理
		player_data[1].head_image = PUBLIC.get_player_head_image(_player_id)

		player_data[1].time = os.time()

		player_data[1].other_data = other_data--]]

		add_value_for_player_data( player_data[1] )

		PUBLIC.add_or_update_rank_data( _player_id , _rank_type )

	elseif data_deal_type == "nor_set" then
		---- 单数据的增加的方式
		set_value_for_player_data( player_data[1] )

		PUBLIC.add_or_update_rank_data( _player_id , _rank_type )

	elseif data_deal_type == "free_bigger" then
		---- 多数据的存更大的情况
		--[[
			每个人的数据，按分数的从大到小排列
			如果没有达到最大的排名个数，就直接加上
			如果达到了最大的排名个数，就
		--]]


		--- 最大的排名个数（排名或显示个数）
		local max_num = PUBLIC.get_max_rank_show_num(_rank_type)

		local total_rank_data = CMD.query_rank_data( _rank_type , false )

		---- 如果所有的数据，还没有达到最大排名个数
		if #total_rank_data < max_num then
			if player_data[#player_data].score == 0 then
				set_value_for_player_data( player_data[#player_data] )
			else

				local add_data = PUBLIC.create_defalut_rank_data(_player_id , _rank_type)

				---
				set_value_for_player_data(add_data)

				player_data[#player_data + 1] = add_data
			end

		else   ---- 如果所有的数据，已经达到最大排名个数
			-- 所有排名数据的最后一个
			local total_last_data = total_rank_data[#total_rank_data]
			-- 所有排名数据的最小分数
			local total_low_score = total_last_data and total_last_data.score or 0

			---- 如果这次的数据 没有大于 所有排名数据的最小分数
			if _add_score <= total_low_score then
				--- 如果比自己的第一个数据都大，则赋值
				if _add_score > player_data[1].score then
					set_value_for_player_data( player_data[1] )
				end
			else ---- 这次数据，大于了 所有排名数据的最小分数

				--- 自己的最小的数据也大于 所有排名数据的最小分数
				if player_data[#player_data].score > total_low_score then
					--- 加一个数据
					local add_data = PUBLIC.create_defalut_rank_data(_player_id , _rank_type)

					---
					set_value_for_player_data(add_data)

					player_data[#player_data + 1] = add_data
				else --- 最后一个小于 所有排名数据的最小分数
					--- 把最后一个数据赋值
					set_value_for_player_data( player_data[#player_data] )
				end
			end


			------ 清理这个人的，所有的不在排名之内的数据,第一个数据不管
			for i = #player_data , 2 , -1 do
				if player_data[i].score < total_low_score then
					--- 清掉延迟更新的缓存
					DATA.update_merge_sql_pusher:delete_sql_cache( { player_data[i].data_id } )
					table.remove(player_data ,i )
				end
			end

		end

		PUBLIC.add_or_update_rank_data( _player_id , _rank_type )


	elseif data_deal_type == "source_add" then
		---- 分 来源的增加数据，每个来源的分数加到一起
		local is_deal = false
		for key, data in pairs( player_data ) do
			local other_data_vec = {}
			if type( data.other_data ) == "string" and #data.other_data > 0 then
				other_data_vec = cjson.decode( data.other_data )
			end

			if _source_type and other_data_vec.source_type and _source_type == other_data_vec.source_type then
				add_value_for_player_data( player_data[ key ] )

				is_deal = true
				break
			end
		end

		---- 如果没有处理，直接，加一个数据
		if not is_deal then
			local add_data = PUBLIC.create_defalut_rank_data(_player_id , _rank_type)
			---
			add_value_for_player_data(add_data)

			player_data[#player_data + 1] = add_data
		end

		PUBLIC.add_or_update_rank_data( _player_id , _rank_type )

	end

end


-------- 根据分数来源监听消息源头()
function PUBLIC.add_msg_listener_by_rank_source( )
	for key , data in pairs(DATA.source_type_deal_vec) do

		--if DATA.source_type_deal_vec[_source_type] then
			--local data = DATA.source_type_deal_vec[_source_type]

			skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , data.msg_name ,{
				msg_tag = DATA.msg_tag,
				node = skynet.getenv("my_node_name"),
				addr = skynet.self(),
				cmd = data.deal_func
			})
		--end
	end
end
-------- 清空所有消息监听
function PUBLIC.clear_all_msg_listener()

	for key,data in pairs(DATA.source_type_deal_vec) do
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "delete_msg_listener" , data.msg_name , DATA.msg_tag )
	end

end

----- 处理结算时间
-- 返回 等待时间 & 再次调用处理函数的等待时间
function PUBLIC.deal_settle_time_model(_settle_time_model_data , _is_first , _start_time )
	local now_time = os.time()
	local wait_time = nil

	if _settle_time_model_data and _settle_time_model_data.reset_type and _settle_time_model_data.reset_value then
		local reset_type = _settle_time_model_data.reset_type
		local reset_value = _settle_time_model_data.reset_value

		if _is_first then
			-------- 第一次请求的等待时间
			local dif_time = now_time - _start_time

			if reset_type == "second" then
				local past_time = dif_time % reset_value
				wait_time = reset_value - past_time
			end

			if reset_type == "day" then
				--- 距离开始时间已经过了多少天
				local dif_day = math.floor( dif_time / 86400 )
				--- 到下一个刷新点还需要的时间
				wait_time = (reset_value - (dif_day % reset_value))*86400 - dif_time % 86400
			end

			if reset_type == "week" then
				----- 没到一个周期执行一次处理函数
				local week_elapse_time = basefunc.get_week_elapse_time()

				local refresh_seconds = basefunc.get_today_past_time(_start_time)
				--- 每周的刷新时间
				local week_refresh_time = (reset_value - 1) * 86400 + refresh_seconds

				local wait_time = 7 * 86400
				if week_elapse_time < week_refresh_time then
					wait_time = week_refresh_time - week_elapse_time
				else
					wait_time = 7 * 86400 - (week_elapse_time - week_refresh_time)
				end
			end

			if reset_type == "fix_time" then
				wait_time = reset_value - now_time
				if wait_time <= 0 then
					wait_time = nil
				end
			end
		else
			-------- 不是第一次请求的等待时间
			if reset_type == "second" then
				wait_time = reset_value
			end

			if reset_type == "day" then
				wait_time = reset_value*86400
			end

			if reset_type == "week" then
				wait_time = 7 * 86400
			end

			if reset_type == "fix_time" then
				wait_time = nil
			end

		end

	end


	return wait_time
end

---- 真的结算
function PUBLIC.settle( _rank_type , _award_dodel , _is_clear , _settle_time_model , _start_time )

	----- 处理发奖
	local need_deal_data = CMD.query_rank_data( _rank_type , true )

	if need_deal_data and type(need_deal_data) == "table" then

		---- 奖励的处理数据 [award_type][award_id] = { player_id , player_id2 }
		local awards_deal_data = {}


		for rank_id , rank_data in ipairs(need_deal_data) do
			local award_id = nil
			local award_data = nil
			local award_type = nil

			if _award_dodel and next(_award_dodel) then
				for key,data in pairs(_award_dodel) do
					if data.start_rank and data.end_rank then
						if rank_id >= data.start_rank and rank_id <= data.end_rank then
							award_id = key
							award_data = data.award_data
							award_type = data.award_type
							break
						end
					elseif data.start_score and data.end_score then
						---- 第一个档位的分数，不限制上限
						if key == 1 and rank_data.score >= data.start_score then
							award_id = key
							award_data = data.award_data
							award_type = data.award_type
							break
						end
						if rank_data.score >= data.start_score and rank_data.score < data.end_score then
							award_id = key
							award_data = data.award_data
							award_type = data.award_type
							break
						end
					end
				end
			end

			----- 找到了要发的奖
			if award_id and award_data and award_type then
				awards_deal_data[award_type] = awards_deal_data[award_type] or {}
				awards_deal_data[award_type][award_id] = awards_deal_data[award_type][award_id] or {}

				local deal_data = awards_deal_data[award_type][award_id]
				deal_data.award_data = award_data
				deal_data.player_vec = deal_data.player_vec or {}

				local len = #deal_data.player_vec + 1
				deal_data.player_vec[len] = { rank_type = _rank_type , player_id = rank_data.player_id , rank_id = rank_id , award_id = award_id , stage_rank = len }
			end

		end

		-------- 处理发奖
		PUBLIC.deal_fajiang( awards_deal_data )

	end

	------ 每次结算都加一下日志
	if need_deal_data and type(need_deal_data) == "table" then
		for rank_id , rank_data in ipairs(need_deal_data) do
			---- 插入日志
			local sql_str = PUBLIC.format_sql([[
						insert into player_rank_log (player_id, player_name , rank_type ,rank ,score , other_data )
						values(%s,%s,%s,%s,%s,%s);
					]] , rank_data.player_id , rank_data.player_name , _rank_type , rank_id , rank_data.score , rank_data.other_data )

			PUBLIC.db_exec(sql_str )
		end

	end


	----- 处理清理
	if _is_clear == 1 then
		PUBLIC.clear_rank_data( _rank_type )

	end

	----- 周期性调结算
	local second_wait_time = PUBLIC.deal_settle_time_model(_settle_time_model , false , _start_time )
	if second_wait_time then
		local timeout_cancler = nodefunc.cancelable_timeout( second_wait_time * 100 , function()
			PUBLIC.settle( _rank_type , _award_dodel , _is_clear , _settle_time_model )
		end)

		DATA.settle_timeout_canclers[_rank_type] = timeout_cancler
	end
end

---- 清理某种排行榜类型
function PUBLIC.clear_rank_data( _rank_type )
	DATA.rank_player_data[ _rank_type ] = {}

	local _sql = PUBLIC.format_sql( [[ update player_rank_data set score = 0 where rank_type = %s ;]] , _rank_type )
	PUBLIC.db_exec(_sql)
end

------ 处理结算模式
function PUBLIC.deal_settle_model( _rank_type , _model_data , _start_time )
	if _model_data and _model_data.settle_time_model then
		local wait_time = PUBLIC.deal_settle_time_model(_model_data.settle_time_model , true , _start_time )
		print("xxxx---------------deal_settle_model , wait_time:" , wait_time )
		if wait_time then
			local timeout_cancler = nodefunc.cancelable_timeout( wait_time * 100 , function()
				PUBLIC.settle( _rank_type , _model_data.award_model , _model_data.is_clear , _model_data.settle_time_model , _start_time )
			end )

			DATA.settle_timeout_canclers[_rank_type] = timeout_cancler
		end
	end

end


------ 清掉所有的结算timeout
function PUBLIC.clear_all_settle_timeout()
	for key,cancler in pairs(DATA.settle_timeout_canclers) do
		cancler()
	end
end

function CMD.deal_vip_level_upgrade(_player_id , _vip_level)
	DATA.player_vip_level_vec[_player_id] = _vip_level
end

function CMD.query_rank_base_info( _player_id , _rank_type )
	local base_info = PUBLIC.get_player_rank_data(_player_id , _rank_type)
	if base_info == nil then
		return 2412
	end
	return base_info
end

function PUBLIC.rank_data_sort_func(a,b)
	if a.score > b.score then
		return true
	elseif a.score == b.score then
		return a.time < b.time
	end
	return false
end

function PUBLIC.sort_rank_data( _rank_type , _rank_data )
	local sort_20_5_buyu_rate_rank = function(a,b)
		if a.score > b.score then
			return true
		elseif a.score == b.score then
			if a.other_data and type(a.other_data) == "string" and b.other_data and type(b.other_data) == "string" and #a.other_data > 0 and #b.other_data > 0 then
				local a_ok , a_o_d_vec = pcall( cjson.decode , a.other_data )
				local b_ok , b_o_d_vec = pcall( cjson.decode , b.other_data )
				if a_ok and b_ok and a_o_d_vec.gun_rate and b_o_d_vec.gun_rate then
					if a_o_d_vec.gun_rate > b_o_d_vec.gun_rate then
						return true
					elseif a_o_d_vec.gun_rate == b_o_d_vec.gun_rate then
						return a.time < b.time
					end
					return false
				else
					return false
				end
			else
				return false
			end
		end
		return false
	end

	if _rank_type == "20_5_buyu_rate_rank" then
		table.sort( _rank_data , sort_20_5_buyu_rate_rank )
	else
		table.sort( _rank_data , PUBLIC.rank_data_sort_func )
	end

end

---- 获得排行榜最大排名，或显示的个数
function PUBLIC.get_max_rank_show_num(_rank_type)
	if not DATA.running_rank_data[_rank_type] then
		return 0		--请求的资源不存在
	end
	local show_model = DATA.running_rank_data[_rank_type].show_model

	local max_num = math.max( show_model.max_rank_num , show_model.max_show_num )

	return max_num
end

function CMD.query_rank_data( _rank_type , _is_fa_jiang )
	if not DATA.running_rank_data[_rank_type] then
		return {}		--请求的资源不存在
	end

	DATA.rank_player_data[_rank_type] = DATA.rank_player_data[_rank_type] or {}

	local show_model = DATA.running_rank_data[_rank_type].show_model

	local max_num = PUBLIC.get_max_rank_show_num(_rank_type) --math.max( show_model.max_rank_num , show_model.max_show_num )

	if _is_fa_jiang then
		max_num = show_model.max_award_num
	end

	local ret = {}
	for player_id , data_vec in pairs(DATA.rank_player_data[_rank_type]) do
		for key,data in pairs(data_vec) do
			if data.score >= show_model.show_limit then
				ret[#ret + 1] = basefunc.deepcopy( data )
			end
		end
	end

	--table.sort( ret , PUBLIC.rank_data_sort_func )

	PUBLIC.sort_rank_data( _rank_type , ret )

	local target_ret = {}
	for i = 1,max_num do
		if ret[i] then
			target_ret[i] = ret[i]
		else
			break
		end
	end

	return target_ret
end

function CMD.query_rank_show_model_base_info( _rank_type )
	if _rank_type and DATA.show_model_config[_rank_type] then
		return DATA.show_model_config[_rank_type]
	end

	return DATA.show_model_config
end





--[[外部直接调用 增加玩家名单数据

	status: 0-no 1-ok

	{
		"rank_type" : "xxxxx"
		"status" : 0
		"player_ids" : {"as4521346","as4521346","as4521346","as4521346","as4521346"}
	}
]]
function CMD.add_rank_server_player_list_data(_data)

	local ok, arg = xpcall(function ()
			return cjson.decode(_data)
		end,
		function (error)
			print(error)
		end)

	if not ok or not arg then
		return nil,1001
	end

	if type(arg.rank_type) ~= "string"
		or type(arg.player_ids) ~= "table"
		or type(arg.status) ~= "number" then

		return nil,1001

	end

	for i,v in ipairs(arg.player_ids) do
		local player_id = tostring(v)
		if player_id then
			PUBLIC.add_player_list_data(player_id,arg.rank_type,arg.status)
			PUBLIC.delete_list_player_rank_data(player_id , arg.rank_type)
		end
	end

	print(basefunc.tostring(arg),"***add_rank_server_player_list_data****")

	return {result=0}
end

--[[
	删除一部分玩家名单数据
]]
function CMD.delete_rank_server_player_list_data(_data)

	local ok, arg = xpcall(function ()
			return cjson.decode(_data)
		end,
		function (error)
			print(error)
		end)

	if not ok or not arg then
		return nil,1001
	end

	if type(arg.rank_type) ~= "string"
		or type(arg.player_ids) ~= "table"then

		return nil,1001

	end

	for i,v in ipairs(arg.player_ids) do
		local player_id = tostring(v)
		if player_id then
			PUBLIC.delete_player_list_data(player_id,arg.rank_type)
			PUBLIC.delete_list_player_rank_data(player_id , arg.rank_type)
		end
	end

	print(basefunc.tostring(arg),"*****delete_rank_server_player_list_data*********")

	return {result=0}

end






function PUBLIC.update()
	local now_time = os.time()
	if DATA.auto_add_vec and type(DATA.auto_add_vec) == "table" then
		for player_id , p_data in pairs(DATA.auto_add_vec) do
			for _rank_type , data in pairs(p_data) do

				if data and data.deal_model and data.player_id and data.player_name and data.rank_type then
					for _,model_data in pairs( data.deal_model ) do
						if not model_data.is_deal and now_time > model_data.deal_time then
							model_data.is_deal = true
							--CMD.get_prop_zongzi(_player_id , _add_value , _player_name)
							CMD.real_add_rank_score( data.player_id , data.rank_type , model_data.source_type , model_data.add_value , data.player_name , model_data.other_data )
						end
					end
				end
			end
		end
	end
end

function PUBLIC.init()
	------------- 通用 排行榜  合并插入sql队列的组件
	DATA.update_merge_sql_pusher = DATA.update_merge_sql_pusher or basefunc.server_class.common_merge_push_sql_lib.new( 60 , nil , {
		tab_name = "player_rank_data",
		queue_type = "slow",
		push_type = "update",
		field_data = {
			data_id = {
				is_primary = true,
				value_type = "equal",
			},
			rank_type = {
				is_primary = true,
				value_type = "equal",
			},
			player_id = {
				value_type = "equal",
			},
			score = {
				value_type = "equal",
			},
			player_name = {
				value_type = "equal",
			},
			time = {
				value_type = "equal",
			},
			other_data = {
				value_type = "equal",
			},
		},
	} )

	--- 动态加载配置
	nodefunc.query_global_config( "rank_server" , PUBLIC.load_config )
	nodefunc.query_global_config( "rank_auto_add_server" , PUBLIC.load_auto_add_config )

	skynet.timer( DATA.update_dt , PUBLIC.update )

	---- 注册监听vip_level改变
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "vip_level_upgrade" ,{
			msg_tag = DATA.msg_tag,
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "deal_vip_level_upgrade" ,

		})


	---- 给一个开始的随机值，避免一个时间点爆发
 	--skynet.timeout( math.random(0,1000) , function()
 	--	print("xxx--------- start__update_merge_sql_pusher:start_timer rank_center")
 	--	DATA.update_merge_sql_pusher:start_timer()
 	--end)

	DATA.variant_data_manager.init( DATA.msg_tag )

	DATA.permission_manager.init(false)

end

function CMD.start(_service_config)

	DATA.service_config = _service_config

	PUBLIC.init()

end

-- 启动服务
base.start_service()

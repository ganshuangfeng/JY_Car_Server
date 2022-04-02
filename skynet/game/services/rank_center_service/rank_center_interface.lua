
local base=require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local skynet = require "skynet_plus"
require "normal_enum"
require "printfunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA


---------------------------------------------------------------------------↓ 监听的消息的处理函数 ↓---------------------------------------------------------

function CMD.deal_xiaoxiaole_award( _player_id , _profit , _total_bet_money)
	CMD.add_rank_score(_player_id , DATA.source_type.xiaoxiaole_award , _profit , _total_bet_money )

	local rate = math.floor(_profit / _total_bet_money * 100)

	CMD.add_rank_score(_player_id , DATA.source_type.xiaoxiaole_award_rate , rate , _total_bet_money , rate )
end

function CMD.deal_pvp_jifen_award( _player_id , _change_jifen , _total_jifen )
	
	CMD.add_rank_score(_player_id , DATA.source_type.pvp_jifen_total_set , _total_jifen )
	
end


---------------------------------------------------------------------------↑ 监听的消息的处理函数 ↑---------------------------------------------------------


---------------------------------------------------------------------------↓ 检查分数来源的处理函数 ↓---------------------------------------------------------

function PUBLIC.check_source_cond_buyu_award( _condition_data , _game_level )
	if not _condition_data then
		return true
	else
		if not _condition_data.game_level or basefunc.compare_value( _game_level , _condition_data.game_level.condition_value , _condition_data.game_level.judge_type ) then
			return true
		end
	end
	return false
end


---------------------------------------------------------------------------↑ 检查分数来源的处理函数 ↑---------------------------------------------------------

---------------------------------------------------------------------------↓ 检查参与条件的处理函数 ↓---------------------------------------------------------



--------- 检查是否是新玩家
function PUBLIC.check_join_cond_is_new_player(_player_id , _condition_data )
	local now_time = os.time()
	local first_login_time=nil

	if not DATA.player_first_login_time[_player_id] then
		first_login_time = skynet.call( DATA.service_config.data_service , "lua" , "get_first_login_time" , _player_id )
		DATA.player_first_login_time[_player_id] = first_login_time or now_time
	end

	--检查当前玩家是否为新玩家
	local is_new_player = false
	if now_time - DATA.player_first_login_time[_player_id] < 86400 * DATA.valid_day_num then
		is_new_player = true
	end

	return basefunc.compare_value( is_new_player and 1 or 0 , _condition_data.condition_value , _condition_data.judge_type )

end

function PUBLIC.check_join_cond_vip_level( _player_id , _condition_data )
	if not DATA.player_vip_level_vec[_player_id] then
		local vip_info = skynet.call( DATA.service_config.new_vip_center_service , "lua" , "query_player_vip_base_info" , _player_id )
		DATA.player_vip_level_vec[_player_id] = vip_info.vip_level
	end
	local vip_level = DATA.player_vip_level_vec[_player_id]

	return basefunc.compare_value( vip_level , _condition_data.condition_value , _condition_data.judge_type )

end

function PUBLIC.check_join_cond_player_id( _player_id , _condition_data , _rank_type)
	
	local rtd = DATA.player_list_data[_rank_type]
	
	if _condition_data.judge_type == 3 then

		if rtd and rtd[_player_id] > 0 then
			return true
		else
			return false
		end

	elseif _condition_data.judge_type == 4 then

		if rtd and rtd[_player_id] < 1 then
			return false
		end
		
		return true

	end

	print(" check_join_cond_player_id player_id error : ", _rank_type , _condition_data.judge_type)
	return true

end


---------------------------------------------------------------------------↑ 检查参与条件的处理函数 ↑---------------------------------------------------------

---------------------------------------------------------------------------↓ 发奖的处理函数 ↓---------------------------------------------------------

DATA.deal_fajiang_func_vec = {
	nor = "deal_fajiang_nor",
	random = "deal_fajiang_random",
	ave_divide = "deal_fajiang_ave_divide",
	rand_divide = "deal_fajiang_rand_divide",
}

function PUBLIC.deal_fajiang( _awards_deal_data )
	for award_type , deal_data in pairs(_awards_deal_data) do
		if DATA.deal_fajiang_func_vec[award_type] and PUBLIC[ DATA.deal_fajiang_func_vec[award_type] ] then
			PUBLIC[ DATA.deal_fajiang_func_vec[award_type] ]( deal_data )
		end

	end
end

function PUBLIC.deal_fajiang_nor(_deal_data)
	for award_id , award_deal_data in pairs(_deal_data) do
		local award_data = award_deal_data.award_data
		local player_vec = award_deal_data.player_vec
		for key , data in pairs(player_vec) do
			PUBLIC.send_awards_by_email( award_data , data.rank_type , data.player_id , data.rank_id , data.award_id, data.stage_rank  )
		end
	end
end

function PUBLIC.deal_fajiang_random(_deal_data)
	for award_id , award_deal_data in pairs(_deal_data) do
		local award_data = award_deal_data.award_data
		local player_vec = award_deal_data.player_vec
		for key , data in pairs(player_vec) do
			PUBLIC.send_awards_by_email( basefunc.get_random_data_by_weight( award_data , "get_weight" ) , data.rank_type , data.player_id , data.rank_id , data.award_id, data.stage_rank  )
		end
	end
end

---- 平均分奖
function PUBLIC.deal_fajiang_ave_divide(_deal_data)
	for award_id , award_deal_data in pairs(_deal_data) do
		local award_data = award_deal_data.award_data
		local player_vec = award_deal_data.player_vec
		local player_num = #player_vec

		local ave_award_data = {}
		for key,data in pairs(award_data) do
			if data.value then
				local tar_value = math.floor( data.value / player_num )

				---- 避免人数大于奖励个数，出现都没领到奖的情况
				if tar_value == 0 then
					tar_value = 1
				end

				local tar_data = basefunc.deepcopy(data)	
				tar_data.value = tar_value
				ave_award_data[#ave_award_data + 1] = tar_data
			else
				ave_award_data[#ave_award_data + 1] = data
			end
		end

		for key , data in pairs(player_vec) do
			PUBLIC.send_awards_by_email( ave_award_data , data.rank_type , data.player_id , data.rank_id , data.award_id , data.stage_rank  )
		end
	end

end

---- 随机分奖
function PUBLIC.deal_fajiang_rand_divide(_deal_data)
	for award_id , award_deal_data in pairs(_deal_data) do
		local award_data = award_deal_data.award_data
		local player_vec = award_deal_data.player_vec
		local player_num = #player_vec

		---- 把奖励的多少分之一拿来做基本的奖励
		local base_factor = 1/4

		----- 每个人的基本的奖励数据
		local every_one_base_award_data = {}

		for key,data in pairs(award_data) do
			if data.value then
				local tar_value = math.floor( data.value * base_factor / player_num )

				if tar_value == 0 then
					tar_value = 1
				end

				local tar_data = basefunc.deepcopy(data)	
				tar_data.value = tar_value
				every_one_base_award_data[key] = tar_data
			else
				--- obj 类型奖励
				every_one_base_award_data[key] = data
			end
		end

		----- 最终的奖励数据
		local final_award_data = {}
		for key,player_data in pairs( player_vec ) do
			final_award_data[ player_data.player_id ] = final_award_data[ player_data.player_id ] or {}

			final_award_data[ player_data.player_id ] = basefunc.deepcopy( every_one_base_award_data )
		end

		------ 剩余的 随机的奖励
		local remain_award_data = {}
		for key,data in pairs(award_data) do
			if data.value and every_one_base_award_data[key] then
				local tar_data = basefunc.deepcopy(data)
				tar_data.value = data.value - every_one_base_award_data[key].value * player_num

				if tar_data.value < 0 then
					tar_data.value = 0
				end

				remain_award_data[key] = tar_data
			end
		end

		------- 把剩下的分了
		local max_divide_rat = 2

		for key,data in pairs(remain_award_data) do
			local remain_value = data.value
			local ave_value = remain_value / player_num

			local while_num = 0
			local max_while_num = 99999

			while remain_value > 0 do
				while_num = while_num + 1
				if while_num > max_while_num then
					break
				end

				local rand_value = math.random( math.floor( 1/max_divide_rat * ave_value ) , math.floor( max_divide_rat * ave_value ) )

				if rand_value <= 0 then
					rand_value = 1
				end

				if rand_value > remain_value then
					rand_value = remain_value 
				end

				remain_value = remain_value - rand_value

				----- 随机找一个人，塞给他
				local random_index = math.random( #player_vec )
				local player_id = player_vec[random_index].player_id

				final_award_data[ player_id ] = final_award_data[ player_id ] or {}
				if final_award_data[ player_id ][key] and final_award_data[ player_id ][key].value then
					final_award_data[ player_id ][key].value = final_award_data[ player_id ][key].value + rand_value
				end
			end

		end


		for key , data in pairs(player_vec) do
			PUBLIC.send_awards_by_email( final_award_data[data.player_id] or {} , data.rank_type , data.player_id , data.rank_id , data.award_id , data.stage_rank  )
		end
	end
end

------------------------ 发奖
function PUBLIC.send_awards_by_email(_award_data , _rank_type , _player_id , _rank_id , _stage_id , _stage_rank )
	local email_type = _rank_type .. "_email" 
	
	if _rank_type == "zhounianqing_yingjing_rank" and _stage_id == 1 and (_stage_rank == 1 or _stage_rank == 2) then
		email_type = "zhounianqing_yingjing_rank_wangzhe_email"
	end

	local award_name_vec = {}
	local award_name = ""

	----- 发送邮件
	if basefunc.chk_player_is_real(_player_id) then
		local date = os.date("*t")
		--- 真人才发
		local email = {
			type = email_type ,
			receiver = _player_id ,
			sender = "系统",
			data={
				asset_change_data = {
					change_type = _rank_type .. "_email_award" ,--ASSET_CHANGE_TYPE[ string.upper( _rank_type ) .. "_EMAIL_AWARD" ],
					change_id = 0,
				},
				rank_id = _rank_id,
				stage_id = _stage_id,
				stage_rank = _stage_rank,
				month = date.month,
				day = date.day ,
			}
		}

		for i,aw in pairs(_award_data) do
			if aw.award_name then
				award_name_vec[#award_name_vec + 1] = aw.award_name
			end

			if aw.asset_type and aw.value then
				email.data[aw.asset_type] = (email.data[aw.asset_type] or 0) + aw.value
			end
			if aw.asset_type and aw.lifetime then
				email.data[aw.asset_type] = {num=1,attribute={valid_time = aw.lifetime }}
			end

		end

		award_name = table.concat( award_name_vec , "+")
		email.data.award_name = award_name

		skynet.send(DATA.service_config.email_service,"lua","send_email",email)
	end

	-----发奖日志
	---- 插入日志
	local sql_str = PUBLIC.format_sql([[
				insert into player_rank_award_log (player_id , rank_type ,rank_id , stage_rank_id , award_name  ) 
				values(%s,%s,%s,%s,%s)
			]] , _player_id , _rank_type , _rank_id , _stage_rank , award_name )

	PUBLIC.db_exec(sql_str )

end


---------------------------------------------------------------------------↑ 发奖的处理函数 ↑---------------------------------------------------------
---------------------------------------------------------------------------↓ 周年庆赢金争霸赛的处理函数 ↓---------------------------------------------------------

function CMD.query_rank_stage_data( _rank_type )
	if not DATA.running_rank_data[_rank_type] then
		return 2412		--请求的资源不存在
	end

	DATA.rank_player_data[_rank_type] = DATA.rank_player_data[_rank_type] or {}

	local show_model = DATA.running_rank_data[_rank_type].show_model

	local ret = {}
	DATA.running_rank_data[_rank_type].settle_model = DATA.running_rank_data[_rank_type].settle_model or {}
	local award_model = DATA.running_rank_data[_rank_type].settle_model.award_model or {}

	if award_model and next(award_model) then
		for i , model in ipairs( award_model ) do
			ret[i] = ret[i] or {}
			ret[i].stage_id = i
			ret[i].player_num = (ret[i].player_num or 0)

			for player_id , data in pairs(DATA.rank_player_data[_rank_type]) do
				if model.start_score and model.end_score and model.start_score <= data.score and data.score < model.end_score then
					ret[i].player_num = ret[i].player_num + 1
				end
			end	
		end
	end

	return ret
end

function CMD.query_rank_stage_details( _rank_type , _stage_id , _max_num )
	local max_rank_num = _max_num or 100

	if not DATA.running_rank_data[_rank_type] then
		return 2412		--请求的资源不存在
	end
	DATA.rank_player_data[_rank_type] = DATA.rank_player_data[_rank_type] or {}

	local show_model = DATA.running_rank_data[_rank_type].show_model

	local ret = {}
	DATA.running_rank_data[_rank_type].settle_model = DATA.running_rank_data[_rank_type].settle_model or {}
	local award_model = DATA.running_rank_data[_rank_type].settle_model.award_model or {}

	if award_model and next(award_model) then
		for i , model in ipairs( award_model ) do
			if _stage_id == i then
				for player_id , data in pairs(DATA.rank_player_data[_rank_type]) do
					if model.start_score <= data.score and data.score < model.end_score then
						ret[#ret + 1] = basefunc.deepcopy( data )
					end
				end
			end
		end
	end

	table.sort( ret , PUBLIC.rank_data_sort_func )

	local target_ret = {}
	for i = 1,max_rank_num do
		if ret[i] then
			target_ret[i] = ret[i]
		else
			break
		end

	end

	return target_ret
end

---------------------------------------------------------------------------↑ 周年庆赢金争霸赛的处理函数 ↑---------------------------------------------------------

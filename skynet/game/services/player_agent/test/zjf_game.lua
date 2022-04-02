-- friendgame_agent

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
require"printfunc"
require "normal_enum"
local nodefunc = require "nodefunc"
local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST
local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

local LD = base.LocalData("zjf_game",{})
local LF = base.LocalFunc("zjf_game")

-------------------test----------------
-- function CMD.zijianfang_query_gps_info(self)
-- 	local result = REQUEST.zijianfang_query_gps_info(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_send_gps_info(self)
-- 	local result = REQUEST.zijianfang_send_gps_info(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_req_info_by_send(self)
-- 	local result = REQUEST.zijianfang_req_info_by_send(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_get_all_history_record(self)
-- 	local result = REQUEST.zijianfang_get_all_history_record(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_get_history_record(self)
-- 	local result = REQUEST.zijianfang_get_history_record(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_get_history_record_ids(self)
-- 	local result = REQUEST.zijianfang_get_history_record_ids(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_player_vote_cancel_room(self)
-- 	local result = REQUEST.zijianfang_player_vote_cancel_room(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_begin_vote_cancel_room(self)
-- 	local result = REQUEST.zijianfang_begin_vote_cancel_room(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_player_vote_alter_rule(self)
-- 	local result = REQUEST.zijianfang_player_vote_alter_rule(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_begin_rule_alter_vote(self)
-- 	local result = REQUEST.zijianfang_begin_rule_alter_vote(self)
-- 	dump(result,"result--------------->")
-- end
-- function CMD.zijianfang_begin_game()
-- 	local result = REQUEST.zijianfang_begin_game()
-- 	dump(result,"result--------------->")
-- end
function CMD.zijianfang_create_room(self)
	local result = REQUEST.zijianfang_create_room(self)
	dump(result,"result--------------->"..DATA.my_id)
	return result
end
function CMD.zijianfang_ready(self)
	local result = REQUEST.zijianfang_ready(self)
	dump(result,"result--------------->"..DATA.my_id)
	return result
end
function CMD.zijianfang_exit_room()
	local result = REQUEST.zijianfang_exit_room()
	dump(result,"result--------------->"..DATA.my_id)
	return result
end
function CMD.zijianfang_join_room_by_password(self)
	local result = REQUEST.zijianfang_join_room_by_password(self)
	dump(result,"result--------------->"..DATA.my_id)
	return result
end
function CMD.zijianfang_join_room(self)
	local result = REQUEST.zijianfang_join_room(self)
	dump(result,"result--------------->"..DATA.my_id)
	return result
end

function CMD.get_one_type_game_list(self)
	local result = REQUEST.get_one_type_game_list(self)
	dump(result,"result--------------->"..DATA.my_id)
	return result
end

function CMD.zijianfang_get_history_record(self)
	local result = REQUEST.zijianfang_get_history_record(self)
	dump(result,"result--------------->"..DATA.my_id)
	return result
end
----------------test-------------------
LD.status = {
	kongxian = true,-- 创建/加入
	room_owner = true,-- 退出
	player = true,-- 准备/退出
	ready = true,-- 退出/取消准备
}

LD.in_status = "kongxian"
LD.table_list = {}
LD.game_type = {
	-- "nor_mj_xzdd",
	-- "nor_mj_xzdd_er_7",
	"nor_ddz_nor",
	"nor_ddz_lz" ,
	"nor_ddz_er",
	"nor_ddz_boom",
	-- "nor_pdk_nor",
}
LD.options = {
	{game_type="nor_ddz_nor",game_cfg={{option="enter_limit",value=math.random(10),},{option="init_stake",value=math.random(10)*100,},{option="feng_ding_32b",value=1,},{option="aa_pay",value=1},{option="yingfengding",value=0}},password=1},
	{game_type="nor_ddz_lz",game_cfg={{option="enter_limit",value=math.random(10),},{option="init_stake",value=math.random(10)*100,},{option="feng_ding_128b",value=1,},{option="aa_pay",value=1},{option="yingfengding",value=1}},password=1},
	{game_type="nor_ddz_er",game_cfg={{option="enter_limit",value=5,},{option="init_stake",value=5000,},{option="feng_ding_64b",value=1,},{option="fangzhu_pay",value=1},{option="yingfengding",value=1}},password=0},
	{game_type="nor_ddz_boom",game_cfg={{option="enter_limit",value=2,},{option="init_stake",value=16000,},{option="feng_ding_64b",value=1,},{option="fangzhu_pay",value=1},{option="yingfengding",value=1}},password=0},
}

function CMD.quit_zijianfang_msg(p_id)
	if p_id == DATA.my_id then
		dump(result,"---------------->quit_zijianfang_msg-".."------------------->"..DATA.my_id)
		LD.in_status = "kongxian"
	end
end

function LF.update()
	if LD.in_status == "kongxian" then
		if math.random(100) < 30 then
		local rr = LD.options[math.random(#LD.options)]
		rr.game_cfg[1].value = math.random(10)*10
		rr.game_cfg[2].value = math.random(1,10)*1000
		rr.password = math.random(0,1)
			local result = CMD.zijianfang_create_room(rr)
			dump(result,"---------------->zijianfang_create_room-".."------------------->"..DATA.my_id)
			if result.result == 0 then
				LD.in_status = "room_owner"
			end
		else
			local game_type = LD.game_type[math.random(#LD.game_type)]
			local result = CMD.get_one_type_game_list({game_type=game_type,page_index=1})
			dump(result,"---------------->get_one_type_game_list-".."------------------->"..DATA.my_id)
			LD.table_list[game_type] = result.table_list or {}
			if #LD.table_list[game_type]>0 then
				local index = math.random(#LD.table_list[game_type])
				if LD.table_list[game_type][index] then
					dump({room_no=LD.table_list[game_type][index].room_no,password=tonumber(LD.table_list[game_type][index].room_no)},"---------------->zijianfang_join_room_table_list-".."------------------->"..DATA.my_id)
					local result = CMD.zijianfang_join_room({room_no=LD.table_list[game_type][index].room_no,password=tonumber(LD.table_list[game_type][index].room_no)})
					dump(result,"---------------->zijianfang_join_room-".."------------------->"..DATA.my_id)
					if result.result == 0 then
						LD.in_status = "player"
					end
				end
			end
		end
	elseif LD.in_status == "player" then
		if math.random(100) < 50 then
			local result = CMD.zijianfang_exit_room()
			dump(result,"---------------->zijianfang_exit_room-".."------------------->"..DATA.my_id)
			if result.result == 0 then
				LD.in_status = "kongxian"
			end
		else
			local result = CMD.zijianfang_ready({opt=1})
			dump(result,"---------------->zijianfang_ready-".."------------------->"..DATA.my_id)
			if result.result == 0 then
				LD.in_status = "ready"
			end
		end
	elseif LD.in_status == "room_owner" then
		if math.random(100) < 50 then
			local result = CMD.zijianfang_exit_room()
			dump(result,"---------------->zijianfang_exit_room-".."------------------->"..DATA.my_id)
			if result.result == 0 then
				LD.in_status = "kongxian"
			end
		end
	elseif LD.in_status == "ready" then
		if math.random(100) < 50 then
			local result = CMD.zijianfang_exit_room()
			dump(result,"---------------->zijianfang_exit_room-".."------------------->"..DATA.my_id)
			if result.result == 0 then
				LD.in_status = "kongxian"
			end
		else
			local result = CMD.zijianfang_ready({opt=0})
			dump(result,"---------------->zijianfang_cancel_ready-".."------------------->"..DATA.my_id)
			if result.result == 0 then
				LD.in_status = "player"
			end
		end
	end
end



function LF.check_asset()
	local result = PUBLIC.asset_verify({{asset_type = PLAYER_ASSET_TYPES.JING_BI,condi_type = NOR_CONDITION_TYPE.CONSUME,value = 10000000}})
	if result.result ~= 0 then
		local _asset_data={
			{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=10000000},
		}
		CMD.change_asset_multi(_asset_data,"init_test",0)
	end
end

-- 参数 _game_info :{game_id =,game_type = ,service_id = ,}
function LF.init(_game_info)

	skynet.timer(10,function()
		LF.check_asset()
		LF.update()
		-- CMD.zijianfang_get_history_record({page_index = 1})

	end)

end

return LF

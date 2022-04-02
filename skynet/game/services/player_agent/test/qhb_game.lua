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

local LD = base.LocalData("free_game",{

	-- 游戏信息 {game_id =,game_type = ,service_id = ,}
	game_info = nil,

	-- 当前的报名结果信息
	signup_ret = nil,
})

local LF = base.LocalFunc("free_game")

-- function LF.get_condi_range(_condi,_type)

-- 	local m1,m2

-- 	for i,v in ipairs(_condi) do
-- 		if v.asset_type == _type then
-- 			if v.condi_type == NOR_CONDITION_TYPE.GREATER or v.condi_type == NOR_CONDITION_TYPE.CONSUME then
-- 				m1 = math.max(v.value,m1 or v.value)
-- 			elseif v.condi_type == NOR_CONDITION_TYPE.LESS then
-- 				m2 = math.min(v.value,m2 or v.value)
-- 			elseif v.condi_type == NOR_CONDITION_TYPE.EQUAL then
-- 				return v.value,v.value
-- 			end
-- 		end
-- 	end

-- 	return m1,m2
-- end

-- function LF.valid_limit(data)
--     local config = data[LD.game_info.game_level]
--     -- 资产
--     for _, v in pairs(config.asset) do
--         local min_asset = v.value[1]
--         min_asset = min_asset ~= -1 and min_asset or 0
--         local max_asset = v.value[2]
--         max_asset = max_asset ~= -1 and max_asset or (1 << 50)
--         local my_asset = CMD.query_asset_by_type(v.asset_type)
--         if not (my_asset >= min_asset and my_asset <= max_asset) then
--             return false
--         end
--     end

--     return true
-- end

-- 确保托管的 钱在给定的范围
function LF.adjust_money()
	local  ok,condi = nodefunc.call( LD.game_info.service_id,"get_enter_info",LD.game_info.game_id )
	if 0 ~= ok then
		print("player_test get_enter_info error:",tostring(condi))
		return false
	end
	local vip = skynet.call(DATA.service_config.new_vip_center_service,"lua","query_player_vip_level",DATA.my_id)
	if vip < 5 then
		skynet.call(DATA.service_config.new_vip_center_service,"lua","set_vip_level",DATA.my_id,8)
	end
	-- local _money1,_money2 = LF.get_condi_range(condi["condi_data"],PLAYER_ASSET_TYPES.JING_BI)
	--print("player_test freestyle enter condi(game id,player,money1,money2):",LD.game_info.game_id,DATA.my_id,_money1,_money2)

	-- if not _money1 and not _money2 then
	-- 	return true -- 不用调节
	-- end
	-- if not LF.valid_limit(condi.data) then
	-- 	-- LL.act_flag = false
	-- 	-- LF.free_game()
	-- 	return {
	-- 		result = 5801,
	-- 		game_id = LD.game_info.game_id
	-- 	}
	-- end
	-- for _, v in pairs(condi.enter_cfg.asset) do
	-- 	local min_asset = v.value[1]
	-- 	min_asset = min_asset ~= -1 and min_asset or 0
	-- 	local max_asset = v.value[2]
	-- 	max_asset = max_asset ~= -1 and max_asset or (1 << 50)
	-- 	local my_asset = CMD.query_asset_by_type(v.asset_type)
	-- 	if not (my_asset >= min_asset and my_asset <= max_asset) then
	-- 		if my_asset < min_asset or my_asset > max_asset then
	-- 			local _inc_value = math.random(min_asset,max_asset)-my_asset
	-- 			--print("player_test freestyle enter change money(money,player,change):",_jing_bi+_inc_value,DATA.my_id,_inc_value)
	-- 			CMD.change_asset_multi({{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=_inc_value}},
	-- 				ASSET_CHANGE_TYPE.TUOGUAN_ADJUST,"0")
	-- 		end
	-- 		return true
	-- 	else
	-- 		return true
	-- 	end
	-- end
	local my_asset = CMD.query_asset_by_type("jing_bi")
	if my_asset < 10000000 then
		CMD.change_asset_multi({{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=5000000}},
					ASSET_CHANGE_TYPE.TUOGUAN_ADJUST,"0")
	end
	return true
end

LD.hb_info = {}
LD.hb_id_end = 0
LD.hb_id_begin = 0
function CMD.send_hb_msg_test(_hb_info, _hb_id_begin, _hb_id_end)
	dump(_hb_info,"=====================>hb_info")
	for i=_hb_id_begin,_hb_id_end do
		if not LD.hb_info[i] then
			LD.hb_info[i] = 0
		end
	end
	LD.hb_id_end = _hb_id_end
    -- PUBLIC.request_client("qhb_hb_send_msg", {hb_data = _hb_info, hb_id_begin = _hb_id_begin, hb_id_end = _hb_id_end})
end

function LF.qiang()
	LF.adjust_money()
	dump(DATA.my_id,"---------------------------->qiang")
	for k,v in pairs(LD.hb_info) do
		if v==1 then
			LD.hb_info[k]=nil
		end
	end
	local hb_num = basefunc.key_count(LD.hb_info)

	if not hb_num or hb_num == 0 then
		return
	end
	--dump(hb_num,"-------------------------------------->hb_num")
	-- local start = LD.hb_id_end-10 < 0 and 1 or LD.hb_id_end-10
	local hb_index = math.random(hb_num)
	local index = 0
	for key,data in pairs(LD.hb_info) do
		index = index + 1
		if index == hb_index then
			local result = REQUEST.qhb_hb_get({hb_id = key})
			dump(result,"============================result->qiang")
			if result.result == 0 or
			result.result == 5805 or
			result.result == 5805
			then
				LD.hb_info[key] = nil
			end

		end
	end
end

function LF.fa()
	LF.adjust_money()
	dump(DATA.my_id,"---------------------------->fa")
	if math.random(10) < 4 then
		local result = REQUEST.qhb_hb_send({hb_count = 10,asset = {asset_type = "jing_bi", value = 5000000}, boom_num = math.random(0,9),})
		dump(result,"============================result->fa")
	end
end


function LF.status_check()

	-- 在游戏外面，则报名
	if not LD.signup_ret or LD.signup_ret.result ~= 0 then
		dump("---------------------------------->status_check")
		LF.adjust_money()
		LD.signup_ret = REQUEST.qhb_signup({
			id=LD.game_info.game_id,
			-- xsyd=nil,
		})
		dump({LD.game_info,LD.signup_ret},"---------------------------------->signup_ret")
		if LD.signup_ret.result ~= 0 then
			return
		end
	end

	skynet.sleep(100) -- 停一下，避免反复报名

	skynet.timeout(20,function()
		LF.fa()
	end)
	skynet.timeout(10,function()
		LF.qiang()
	end)
end

-- 参数 _game_info :{game_id =,game_type = ,service_id = ,}
function LF.init(_game_info)
	-- dump("---------------------------->init")


	LD.game_info = basefunc.copy(_game_info)

	skynet.timer(1,function() LF.status_check()  end)
end


return LF

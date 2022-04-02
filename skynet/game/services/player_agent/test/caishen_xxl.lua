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

local LD = base.LocalData("caishen_xxl",{

	-- 游戏信息 {game_id =,game_type = ,service_id = ,}
	game_info = nil,

	-- 当前的报名结果信息
	signup_ret = nil,
})

local LF = base.LocalFunc("caishen_xxl")

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
	-- local  ok,condi = nodefunc.call( LD.game_info.service_id,"get_enter_info",LD.game_info.game_id )
	-- if 0 ~= ok then
	-- 	print("player_test get_enter_info error:",tostring(condi))
	-- 	return false
	-- end
	skynet.call(DATA.service_config.new_vip_center_service,"lua","set_vip_level",DATA.my_id,3)
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
				--print("player_test freestyle enter change money(money,player,change):",_jing_bi+_inc_value,DATA.my_id,_inc_value)
				CMD.change_asset_multi({{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=100000}},
					ASSET_CHANGE_TYPE.TUOGUAN_ADJUST,"0")
	-- 		end
	-- 		return true
	-- 	else
	-- 		return true
	-- 	end
	-- end
	return true
end


function LF.kaijiang_caishen()
    local result = REQUEST.xxl_caishen_kaijiang({
        bets = {
            [1] = 100,
            [2] = 100,
            [3] = 100,
            [4] = 100,
            [5] = 100,
        }
    })
    dump(result,"========================>result_canshen")
end

function LF.xxl_caishen_progress_data_kaijiang_test()
    local result = REQUEST.xxl_caishen_progress_data_kaijiang({
        total_bet_money = 120000
    })
    dump(result,"========================>result_canshen")
end



function LF.status_check()
	
	-- 在游戏外面，则报名
	if not DATA.game_id and not DATA.match_game_data then

		LF.adjust_money()

		LD.signup_ret = REQUEST.xxl_caishen_enter_game({
        })
        dump(LD.signup_ret,"-------------------------------->signup_ret")
		-- dump({LD.game_info,LD.signup_ret},"---------------------------------->signup_ret")
		if LD.signup_ret.result == 0 or LD.signup_ret.result == 1005 then

			skynet.sleep(100) -- 停一下，避免反复报名
            -- LF.kaijiang_caishen()
            LF.xxl_caishen_progress_data_kaijiang_test()
		end
	end
end

-- 参数 _game_info :{game_id =,game_type = ,service_id = ,}
function LF.init(_game_info)
	-- dump("---------------------------->init")


	LD.game_info = basefunc.copy(_game_info)
    skynet.sleep(1200)
	skynet.timer(10,function() LF.status_check()  end)
end


return LF

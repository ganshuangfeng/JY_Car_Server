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

function LF.get_condi_range(_condi,_type)

	local _m1,m2

	for i,v in ipairs(_condi) do
		if v.asset_type == _type then
			if v.condi_type == NOR_CONDITION_TYPE.GREATER or v.condi_type == NOR_CONDITION_TYPE.CONSUME then
				m1 = math.max(v.value,m1 or v.value)
			elseif v.condi_type == NOR_CONDITION_TYPE.LESS then
				m2 = math.min(v.value,m2 or v.value)
			elseif v.condi_type == NOR_CONDITION_TYPE.EQUAL then
				return v.value,v.value
			end
		end
	end

	return m1,m2
end

-- 确保托管的 钱在给定的范围
function LF.adjust_money()

	local  ok,condi = nodefunc.call( LD.game_info.service_id,"get_enter_info",LD.game_info.game_id )
	if 0 ~= ok then
		print("player_test get_enter_info error:",tostring(condi))
		return false
	end

	local _money1,_money2 = LF.get_condi_range(condi["condi_data"],PLAYER_ASSET_TYPES.JING_BI)
	--print("player_test freestyle enter condi(game id,player,money1,money2):",LD.game_info.game_id,DATA.my_id,_money1,_money2)

	if not _money1 and not _money2 then
		return true -- 不用调节
	end


	local _jing_bi = CMD.query_asset_by_type(PLAYER_ASSET_TYPES.JING_BI)
	--print("player_test freestyle enter(player,money):",DATA.my_id,_jing_bi)

	if _jing_bi >= (_money1 or 0) and _jing_bi <= (_money2 or math.maxinteger) then
		return true
	end
	
	_money1 = _money1 or 0
	_money2 = _money2 or (_money1 + 300000)

    if _jing_bi < _money1 or _jing_bi > _money2 then
		local _inc_value = math.random(_money1,_money2)-_jing_bi
		--print("player_test freestyle enter change money(money,player,change):",_jing_bi+_inc_value,DATA.my_id,_inc_value)
        CMD.change_asset_multi({{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=_inc_value}},
            ASSET_CHANGE_TYPE.TUOGUAN_ADJUST,"0")
	end
	
	return true
end

function LF.status_check()
	
	-- 在游戏外面，则报名
	if not DATA.game_id and not DATA.match_game_data then

		LF.adjust_money()

		LD.signup_ret = REQUEST.fg_signup({
			id=LD.game_info.game_id,
			xsyd=nil,
		})
		
		if LD.signup_ret.result == 0 then

			skynet.sleep(100) -- 停一下，避免反复报名

			-- 举手
			REQUEST.fg_ready()
		end
	end
	
	
end

-- 参数 _game_info :{game_id =,game_type = ,service_id = ,}
function LF.init(_game_info)

	LD.game_info = basefunc.copy(_game_info)

	skynet.timer(2,function() LF.status_check()  end)
end


return LF


-- 单人匹配 , 来就匹配

local skynet = require "skynet_plus"
local base=require "base"
local nodefunc = require "nodefunc"
require "normal_enum"
local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LF = base.LocalFunc("matching_danren")
local LD = base.LocalData("matching_danren",{

	matching_list = {},
})

--把一组玩家加入桌子进行比赛
function LF.player_join_table( _player_id )
	LD.matching_list[1] = LD.matching_list[1] or {}
	local players = LD.matching_list[1]

	players[#players + 1] = _player_id
	if #players >= DATA.seat_count then
		dump(players, "player_join_table4")
		DATA.common_matching.add_distribution_players(players)
		LD.matching_list[1] = {}
	end

	return 
	{
		result = 0,
	}
end

function LF.player_signup(_player_id)
	return LF.player_join_table(_player_id)
end

function LF.update(dt)

end

function LF.player_exit_game(_player_id)
	---- 退出游戏时，如果已经在匹配中了，得删掉数据 (先简单处理)
	if LD.matching_list and LD.matching_list[1] then
		for key,player_id in pairs( LD.matching_list[1] ) do
			if _player_id == player_id then
				table.remove( LD.matching_list[1] , key )
				break
			end
		end
	end

	return {result = 0}
end

function LF.init()

end



return LF

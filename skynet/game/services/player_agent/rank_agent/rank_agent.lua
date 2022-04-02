--
-- Author: lzm
-- Date: 2019/08/14
-- Time: 09:20

local skynet = require "skynet_plus"
local basefunc=require"basefunc"
local nodefunc = require "nodefunc"
require"printfunc"

local base = require "base"
local CMD=base.CMD
local DATA=base.DATA
local PUBLIC=base.PUBLIC
local REQUEST=base.REQUEST

DATA.rank_agent_protect = {}

local PROTECT = DATA.rank_agent_protect

--显示模式，分排行榜类型
PROTECT.show_model = {}
--排行榜数据，分排行榜类型
PROTECT.rank_data = {}
--玩家相关排行榜数据
PROTECT.my_rank = {}
--上一次查询排行榜数据时间，分排行榜类型
PROTECT.last_query_time = {}
--上一次查询玩家相关排行榜数据时间，分排行榜类型
PROTECT.last_query_self_time = {}
--分页查询每页数量，分排行榜类型
PROTECT.rank_page_num = {
	default = 20,
}

----- 清理缓存数据的延迟
PROTECT.clear_cache_delay = 1800




--查询某一个排行榜榜单
function REQUEST.query_rank_data( self )
	local ret = {}

	--- 参数检查
	if not self or not self.page_index or type(self.page_index) ~= "number" or not self.rank_type or type(self.rank_type) ~= "string" then
		ret.result = 1001
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock("query_rank_data" , self.rank_type) then
		ret.result = 1008
		return ret
	end

	PUBLIC.on_action_lock( "query_rank_data" , self.rank_type)
	

	local rank_data = PROTECT.get_rank_data_cache(self.rank_type , self.page_index )

	if type(rank_data) == "number" then
		ret.result = rank_data
		PUBLIC.off_action_lock( "query_rank_data" , self.rank_type)
		return ret
	end

	if not PROTECT.rank_data[self.rank_type] then -- or not next( PROTECT.rank_data[self.rank_type] ) then
		ret.result = 1004
		PUBLIC.off_action_lock( "query_rank_data" , self.rank_type )
		return ret
	end

	local start_rank = (self.page_index-1) * (PROTECT.rank_page_num[self.rank_type] or PROTECT.rank_page_num["default"]) + 1
	local end_rank = (self.page_index) * (PROTECT.rank_page_num[self.rank_type] or PROTECT.rank_page_num["default"])

	local max_show_num = PROTECT.show_model[self.rank_type] and PROTECT.show_model[self.rank_type].max_show_num or 100

	ret.result = 0
	ret.page_index = self.page_index
	ret.rank_type = self.rank_type
	ret.rank_data = {}
	for i = start_rank, end_rank do
		if PROTECT.rank_data[self.rank_type][i] and i <= max_show_num then
			local tar_data = PROTECT.rank_data[self.rank_type][i]

			ret.rank_data[#ret.rank_data + 1] = { 
				rank = i ,
				player_id = tar_data.player_id ,
				name = basefunc.deal_hide_player_name( tar_data.player_name ) ,
				score = tostring( tar_data.score ) ,
				other_data = tar_data.other_data,
			}
		end
	end

	PUBLIC.off_action_lock( "query_rank_data" , self.rank_type )
	return ret
end


--查询玩家相关排行榜信息
function REQUEST.query_rank_base_info( self )
	local ret = {}

	--- 参数检查
	if not self or not self.rank_type or type(self.rank_type) ~= "string" then
		ret.result = 1001
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock("query_rank_base_info" , self.rank_type) then
		ret.result = 1008
		return ret
	end

	PUBLIC.on_action_lock( "query_rank_base_info" , self.rank_type )


	local rank_data = PROTECT.get_rank_data_cache(self.rank_type , 1 )

	if type(rank_data) == "number" then
		ret.result = rank_data
		PUBLIC.off_action_lock( "query_rank_base_info" , self.rank_type )
		return ret
	end

	local info_result = PUBLIC.get_self_rank_data_cache( self.rank_type )
		
	if type(info_result) == "number" then
		ret.result = info_result
		PUBLIC.off_action_lock( "query_rank_base_info" , self.rank_type )
		return ret
	end


	if not PROTECT.my_rank[self.rank_type] or not next( PROTECT.my_rank[self.rank_type] ) then
		ret.result = 1004
		PUBLIC.off_action_lock( "query_rank_base_info" , self.rank_type )
		return ret
	end

	ret.result = 0
	ret.rank_type = self.rank_type
	ret.rank = -1
	--dump(PROTECT.rank_data[self.rank_type] , "xxx------------------------PROTECT.rank_data[self.rank_type]:")
	if PROTECT.rank_data and PROTECT.rank_data[self.rank_type] and type(PROTECT.rank_data[self.rank_type]) == "table" then
		for rank,data in pairs(PROTECT.rank_data[self.rank_type]) do
			if data.player_id == DATA.my_id and (ret.rank == -1 or rank < ret.rank) then
				ret.rank = rank
			end
		end
	end

	ret.score = tostring( PROTECT.my_rank[self.rank_type].score or 0 )
	ret.other_data = PROTECT.my_rank[self.rank_type].other_data

	PUBLIC.off_action_lock( "query_rank_base_info" , self.rank_type )
	return ret
end



function PUBLIC.get_self_rank_data_cache(_rank_type )
	local now_time = os.time()
	PROTECT.last_query_self_time[_rank_type] = PROTECT.last_query_self_time[_rank_type] or 0

	local delay = PROTECT.show_model[_rank_type] and PROTECT.show_model[_rank_type].show_refresh_self_delay or 10

	if not PROTECT.my_rank[_rank_type] or now_time - PROTECT.last_query_self_time[_rank_type] > delay then
		local info_result = skynet.call( DATA.service_config.rank_center_service , "lua" , "query_rank_base_info" , DATA.my_id , _rank_type )
		
		if type(info_result) ~= "number" and type(info_result) == "table" then
			PROTECT.my_rank[_rank_type] = info_result[1]
			PROTECT.last_query_self_time[_rank_type] = os.time()
			
		end

		return info_result
	end

	return PROTECT.my_rank[_rank_type]
end


function PROTECT.get_rank_data_cache(_rank_type , _page_index )
	local now_time = os.time()
	local delay = PROTECT.show_model[_rank_type] and PROTECT.show_model[_rank_type].show_refresh_delay or 180

	PROTECT.last_query_time[_rank_type] = PROTECT.last_query_time[_rank_type] or 0

	if not PROTECT.rank_data[_rank_type] or (_page_index == 1 and now_time - PROTECT.last_query_time[_rank_type] > delay) then
		local rank_data = skynet.call( DATA.service_config.rank_center_service , "lua" , "query_rank_data" , _rank_type )
		if type(rank_data) ~= "number" then
			PROTECT.rank_data[_rank_type] = rank_data
			PROTECT.last_query_time[_rank_type] = now_time
		end

		return rank_data
	end

	return PROTECT.rank_data[_rank_type]
end


function PROTECT.update(dt)
	local now_time = os.time()

	for _rank_type , data in pairs(PROTECT.rank_data) do

		local delay = PROTECT.clear_cache_delay

		PROTECT.last_query_time[_rank_type] = PROTECT.last_query_time[_rank_type] or 0

		if now_time - PROTECT.last_query_time[_rank_type] > delay then
			PROTECT.rank_data[_rank_type] = nil
		end
	end

end


--agent初始化
function PROTECT.init()
	PROTECT.show_model = skynet.call( DATA.service_config.rank_center_service , "lua" , "query_rank_show_model_base_info" )
	PROTECT.show_model = PROTECT.show_model or {}

end



return PROTECT
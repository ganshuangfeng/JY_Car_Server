----- 客户端请求 的一些活动的假数据，集中处理

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST=base.REQUEST
local PUBLIC = base.PUBLIC

DATA.fake_data_mgr_protect = {}
local PROTECT = DATA.fake_data_mgr_protect

PROTECT.fake_data_type = {
	caihongbao = "get_caihongbao_data",
	summer_super_money = "get_summer_super_money",
	zhounian_lottery = "get_zhounian_lottery",
}

--请求超级彩金池假数据
function REQUEST.query_super_money_fake_data()
	local ret = {}
	--- 操作限制
	if PUBLIC.get_action_lock("query_super_money_fake_data") then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_super_money_fake_data" )

	local super_money = skynet.call(DATA.service_config.data_service,"lua","get_system_variant" , "super_money_pool")

	if not super_money then
		PUBLIC.off_action_lock( "query_super_money_fake_data" )
		ret = 1004
		return ret
	end

	ret.result = 0
	ret.super_money = super_money
	PUBLIC.off_action_lock( "query_super_money_fake_data" )
	return ret
end


------ 统一的请求活动假数据的接口
--[[
	参数：
	data_type   活动类型
--]]
function REQUEST.query_fake_data( self )
	local ret = {}

	if not self or not self.data_type or type(self.data_type) ~= "string" then
		ret.result = 1001
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock("query_fake_data") then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_fake_data" )

	local fake_data = PROTECT.get_one_fake_data( self.data_type) 

	dump(fake_data,"----------query_fake_data")
	if next(fake_data) == nil then
		PUBLIC.off_action_lock( "query_fake_data" )
		ret.result = 1004
		return ret
	end

	ret.result = 0
	ret.player_name = fake_data.player_name
	ret.award_data = fake_data.award_data

	PUBLIC.off_action_lock( "query_fake_data" )
	return ret
end

function PROTECT.get_one_fake_data( _data_type )
	local data = {}

	if PROTECT.fake_data_type[_data_type] and PROTECT[ PROTECT.fake_data_type[_data_type] ] then
		data = PROTECT[ PROTECT.fake_data_type[_data_type] ]()
	end

	return data
end

----------------------------------------------------------------------- 特殊处理逻辑↓
function PROTECT.get_caihongbao_data()

	local random_name = skynet.call(DATA.service_config.little_game_yingjin_broadcast_service , "lua", "get_fork_name",false)

	local activity_probability = math.random(100)
	local award_data = 0 
	if activity_probability <=45 then
		award_data = math.random(1, 10) 
	elseif activity_probability <= 85 then
		award_data = math.random(10, 30) 
	elseif activity_probability <=  95 then
		award_data = math.random(30, 50) 
	else
		award_data = math.random(50, 80) 
	end

	return { player_name = random_name , award_data = award_data }
end


function PROTECT.get_summer_super_money()

	local random_name = skynet.call(DATA.service_config.little_game_yingjin_broadcast_service , "lua", "get_fork_name",false)

	local gl_vec = {
		{ rand_range = { 20,100 } , weight = 10 },
		{ rand_range = { 100,200 } , weight = 15 },
		{ rand_range = { 200,500 } , weight = 20 },
		{ rand_range = { 500,1000 } , weight = 20 },
		{ rand_range = { 1000,2000 } , weight = 20 },
		{ rand_range = { 2000,5000 } , weight = 15 },
	}

	local rand_data = basefunc.get_random_data_by_weight( gl_vec , "weight" )

	local award_value = math.random( rand_data.rand_range[1] , rand_data.rand_range[2] )

	award_value = 10 * math.floor( award_value / 10 )

	--[[local activity_probability = math.random(100)
	local award_data = 0 
	if activity_probability <= 10 then
		award_data = math.random(20, 10) 
	elseif activity_probability <= 25 then
		award_data = math.random(10, 20) 
	elseif activity_probability <=  45 then
		award_data = math.random(20, 50) 
	elseif activity_probability <=  65 then
		award_data = math.random(50, 100) 
	elseif activity_probability <=  85 then
		award_data = math.random(100, 200)
	else
		award_data = math.random(200, 500)
	end--]]

	return { player_name = random_name , award_data = award_value }
end


function PROTECT.get_zhounian_lottery()
	local random_name = skynet.call(DATA.service_config.little_game_yingjin_broadcast_service , "lua", "get_fork_name",false)
	local vec = {
		{ award_name = "美的冰箱",weight = 1 },
		{ award_name = "美的微波炉",weight = 1 },
		{ award_name = "电动牙刷",weight = 3 },
		{ award_name = "海飞丝洗发水",weight = 20 },
		{ award_name = "金龙鱼鸡蛋面",weight = 40 },
		{ award_name = "200元优惠券",weight = 5 },
		{ award_name = "150福卡",weight = 10 },
		{ award_name = "100元话费",weight = 10 },
		{ award_name = "150万金币",weight = 10 },
	}

	local award_name = basefunc.get_random_data_by_weight( vec , "weight" )

	return { player_name = random_name , award_data = award_name }
end

function PROTECT.init()


end

return PROTECT
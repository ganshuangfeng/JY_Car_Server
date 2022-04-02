----- 定时开奖box的agent

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"

local DATA = base.DATA
local CMD = base.CMD
local REQUEST=base.REQUEST
local PUBLIC = base.PUBLIC

DATA.timer_box_agent_protect = {}
local PROTECT = DATA.timer_box_agent_protect

PROTECT.box_config = nil


---
PROTECT.box_data = nil

---- 总共的同时解锁数量
DATA.total_unlock_num = nil
---- 总共的宝箱位
DATA.total_box_pos = nil


---- 
function PROTECT.update_player_box_data( _pos_id )
	local tar_box_data = PROTECT.box_data[_pos_id]

	skynet.call( DATA.service_config.timer_box_center_service , "lua" , "add_or_update_one_box_data" , DATA.my_id , _pos_id , tar_box_data )
	
end

----- 获得正在解锁中的 宝箱数量
function PROTECT.get_unlocking_box_count()
	local count = 0

	if PROTECT.box_data and type(PROTECT.box_data) == "table" then
		for key , data in pairs( PROTECT.box_data ) do
			if data.start_time then
				count = count + 1
			end
		end
	end
	return count
end

----- 请求所有的 box 数据
function REQUEST.query_player_timer_box_data( self )
	local ret = {}
	--- 操作限制
	if PUBLIC.get_action_lock( "query_player_timer_box_data" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "query_player_timer_box_data" )

	ret.result = 0

	ret.box_data = {}

	if PROTECT.box_data and type(PROTECT.box_data) == "table" then
		for key,data in pairs(PROTECT.box_data) do
			ret.box_data[#ret.box_data + 1] = data
		end
	end

	PUBLIC.off_action_lock( "query_player_timer_box_data" )
	return ret
end

---- 解锁一个box , 普通解锁
function REQUEST.unlock_timer_box_by_time( self )
	local ret = {}

	if not self or not self.pos_id or type(self.pos_id ) ~= "number" then
		ret.result = 1001
		return ret
	end

	---- 如果没有对应的 盒子
	if not PROTECT.box_data or not PROTECT.box_data[ self.pos_id ] then
		ret.result = 1004
		return ret
	end

	local tar_box_data = PROTECT.box_data[ self.pos_id ]

	--- 操作限制
	if PUBLIC.get_action_lock( "unlock_timer_box_by_time" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "unlock_timer_box_by_time" )

	---- 当前这个是否在解锁了
	if tar_box_data.start_time then
		ret.result = 8003
		PUBLIC.off_action_lock( "unlock_timer_box_by_time" )
		return ret
	end

	---- 如果 当前正在解锁的数量 大于了 总共解锁数量
	if PROTECT.get_unlocking_box_count() >= DATA.total_unlock_num then 
		ret.result = 8004
		PUBLIC.off_action_lock( "unlock_timer_box_by_time" )
		return ret
	end

	tar_box_data.start_time = os.time()

	---- 同步中心,保存数据
	--PROTECT.update_player_base_info()
	PROTECT.update_player_box_data( self.pos_id )

	PROTECT.on_box_data_change()

	ret.result = 0
	PUBLIC.off_action_lock( "unlock_timer_box_by_time" )
	return ret
end

-----------
function REQUEST.get_award_timer_box( self )
	local ret = {}

	if not self or not self.pos_id or type(self.pos_id ) ~= "number" then
		ret.result = 1001
		return ret
	end
	if self.is_spend_diamond and type(self.is_spend_diamond) ~= "number" then
		ret.result = 1001
		return ret
	end

	---- 如果没有对应的 盒子
	if not PROTECT.box_data or not PROTECT.box_data[ self.pos_id ] then
		ret.result = 1004
		return ret
	end

	local now_time = os.time()
	local tar_box_data = PROTECT.box_data[ self.pos_id ]

	local tar_box_config = PROTECT.box_config[ tar_box_data.box_id ]
	if not tar_box_config then
		ret.result = 1004
		print("xxxx-----------no box_config for box_id:" , tar_box_data.box_id )
		return ret
	end

	--- 操作限制
	if PUBLIC.get_action_lock( "get_award_timer_box" ) then
		ret.result = 1008
		return ret
	end
	PUBLIC.on_action_lock( "get_award_timer_box" )

	if not self.is_spend_diamond then
		--- 如果没有 开始时间
		if not tar_box_data.start_time then
			ret.result = 8005
			PUBLIC.off_action_lock( "get_award_timer_box" )
			return ret
		end
		--- 解锁时间未到
		if now_time < tar_box_data.start_time + tar_box_config.unlock_time then
			ret.result = 8006
			PUBLIC.off_action_lock( "get_award_timer_box" )
			return ret
		end

	else
		local need_diamond = 0
		local remind_time = tar_box_config.unlock_time

		if tar_box_data.start_time then
			remind_time = tar_box_data.start_time + tar_box_config.unlock_time - now_time
			if remind_time < 0 then
				remind_time = 0
			end
		end

		need_diamond = tar_box_config.diamond_rule[1] + math.ceil( remind_time / tar_box_config.diamond_rule[2] )

		---- 检查钻石是否足够
		local asset_data = { [1] = {
				asset_type = PLAYER_ASSET_TYPES.DIAMOND,
				condi_type = NOR_CONDITION_TYPE.CONSUME,
				value = need_diamond , 
		} }
		local ver_ret = PUBLIC.asset_verify( asset_data )
		if ver_ret.result ~= 0 then
			ret.result = ver_ret.result
			PUBLIC.off_action_lock( "get_award_timer_box" )
			return ret
		end

		---- 消耗掉
		 CMD.change_asset_multi( { [1] = { asset_type = PLAYER_ASSET_TYPES.DIAMOND,value = -need_diamond } }
			   												, ASSET_CHANGE_TYPE.OPEN_TIMER_BOX_SPEND , self.pos_id , nil , tar_box_data.box_id )

	end

	---- 先将这个数据给删掉
	PROTECT.box_data[ self.pos_id ] = nil

	skynet.call( DATA.service_config.timer_box_center_service , "lua" , "delete_one_box_data" , DATA.my_id , self.pos_id )

	---- 然后开奖
	local award_data = PROTECT.get_box_award_data( tar_box_data.box_id )

	----- 处理 开奖数据
	PROTECT.deal_box_award_data( award_data , self.pos_id , tar_box_data.box_id )


	ret.result = 0
	ret.award_list = {}

	for key,data in pairs(award_data) do
		ret.award_list[#ret.award_list + 1] = {
			asset_type = data.asset_type ,
			asset_value = data.asset_value ,
		}
	end


	PUBLIC.off_action_lock( "get_award_timer_box" )
	return ret
end


function PROTECT.get_box_award_data( _box_id )
	local tar_box_config = PROTECT.box_config[ _box_id ]
	local award_data = {}

	local nor_award = {}
	local random_award = {}
	local gailv_award = {}

	if tar_box_config and tar_box_config.award_data then
		for key,data in pairs(tar_box_config.award_data) do
			if data.award_type == "nor" then
				nor_award[#nor_award + 1] = data
			elseif data.award_type == "random" then
				random_award[#random_award + 1] = data
			elseif data.award_type == "gailv" then
				gailv_award[#gailv_award + 1] = data
			end
		end
	end

	for key,data in pairs(nor_award) do
		award_data[#award_data + 1] = data
	end

	if next(random_award) then
		local one_award = basefunc.get_random_data_by_weight( random_award , "weight" )
		award_data[#award_data + 1] = one_award
	end

	for key,data in pairs(gailv_award) do
		local s,e,r1 , r2 = string.find( data.weight , "(%d+)/(%d+)" )

		if r1 and r2 then
			r1 = tonumber(r1)
			r2 = tonumber(r2)

			local r_value = math.random(r2)
			if r_value <= r1 then
				award_data[#award_data + 1] = data
			end
		end
	end

	return award_data
end


function PROTECT.deal_box_award_data(_award_data , _pos_id , _box_id )
	local nor_award = {}
	local equipment_award = {}

	for key,data in pairs(_award_data) do
		if not string.find(data.asset_type , "^equipment_%d+" ) then
			nor_award[#nor_award + 1] = {  asset_type = data.asset_type ,value = data.asset_value }
		else
			equipment_award[#equipment_award + 1] = data
		end
	end

	---- 发奖
	CMD.change_asset_multi( nor_award , ASSET_CHANGE_TYPE.OPEN_TIMER_BOX_AWARD , _pos_id , nil , _box_id )

	---- 发装备
	for key,data in pairs(equipment_award) do
		local s,e,eqp_id = string.find( data.asset_type , "^equipment_(%d+)" )
		eqp_id = tonumber(eqp_id)

		for i = 1 , data.asset_value do
			PUBLIC.add_drive_equipment( eqp_id )
		end
	end
	

	return
end


function PROTECT.on_box_data_change()
	local tar_data = {}

	if PROTECT.box_data and type(PROTECT.box_data) == "table" then
		
		for key,data in pairs(PROTECT.box_data) do
			tar_data[#tar_data + 1] = data
		end

	end

	PUBLIC.request_client( "on_timer_box_data_change" , {
		box_data = tar_data ,
	} )
end


---- 加一个box
function PUBLIC.add_one_timer_box(_box_id)
	if not basefunc.chk_player_is_real(DATA.my_id) then
		return 0
	end


	local result , box_data = skynet.call( DATA.service_config.timer_box_center_service , "lua" , "add_one_box_data" , DATA.my_id , _box_id )

	if result == 0 then
		PROTECT.box_data = PROTECT.box_data or {}
		PROTECT.box_data[ box_data.pos_id ] = box_data

		PROTECT.on_box_data_change()
		return 0
	end
end

----------------
function PROTECT.init()
	--- 一上来先把基础数据拿到
	--PROTECT.base_info = skynet.call( DATA.service_config.timer_box_center_service , "lua" , "get_player_base_info" , DATA.my_id )

	---- 获得所有的box 数据
	PROTECT.box_data = skynet.call( DATA.service_config.timer_box_center_service , "lua" , "get_player_box_data" , DATA.my_id )

	PROTECT.box_config ,  DATA.total_unlock_num , DATA.total_box_pos = skynet.call( DATA.service_config.timer_box_center_service , "lua" , "get_timer_box_config" ) 
end


return PROTECT
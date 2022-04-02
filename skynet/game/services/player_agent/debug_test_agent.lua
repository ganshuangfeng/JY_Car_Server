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
local PROTECT={}
local LOCAL={}
local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)

LOCAL.status = 0
LOCAL.game_time = 0
LOCAL.game_time_limit = 2*60

function LOCAL.debug_test_fish_game_signup()
	local gid = math.random(1,4)

	REQUEST.fsg_signup({id=gid})

end



function LOCAL.debug_test_fish_game_exit()

	REQUEST.fsg_quit_game()

end




LOCAL.bullet = {}
LOCAL.sp = {}

function LOCAL.debug_test_fish_game_shoot()

	if not DATA.fish_game_data or not DATA.fish_game_data.game_data then
		return
	end


	local s_info = DATA.fish_game_data.game_data

	local data = {
		shoot = {},
		boom = {},
		fish_explode = {},
	}


	if next(LOCAL.bullet) then

		for b,d in pairs(LOCAL.bullet) do
			if math.random(1,100) < 50 then

				local fc = math.random(1,5)
				local fs = {}

				for k,v in pairs(s_info.fish_data) do
					fc = fc - 1
					fs[#fs+1] = k
					if fc < 1 then
						break
					end
				end

				if next(fs) then
					data.boom[#data.boom+1]=
					{
						id = b,
						fish_ids = fs,
					}
					LOCAL.bullet[b] = nil
				end

			end
		end

	end


	if next(LOCAL.sp) then
		for b,d in pairs(LOCAL.bullet) do
			local fc = math.random(1,5)
			local fs = {}

			for k,v in pairs(s_info.fish_data) do
				fc = fc - 1
				fs[#fs+1] = k
				if fc < 1 then
					break
				end
			end

			if next(fs) then
				data.fish_explode[#data.fish_explode+1]=
				{
					id = b,
					fish_ids = fs,
				}
				LOCAL.sp[b] = nil
			end
		end
	end

	local rd = math.random(1,20)
	for i=1,rd do
		data.shoot[i]={
			y=0,
	        x=0,
	        index=math.random(1,10),
	        id=0,
	        time=0,
	        seat_num=1,
		}
	end


	local ret = REQUEST.nor_fishing_nor_frame_data_test({data=data})

	if ret.data then
		
		if ret.data.shoot then
			for k,v in pairs(ret.data.shoot) do
				LOCAL.bullet[v.id] = v.id
			end
		end

		if ret.data.boom then
			for k,v in pairs(ret.data.boom) do
				
				local fi = 1
				local iii = 1
				if v.data then
					
					while true do
						
						if v.data[iii]==4 then
							LOCAL.sp[v.fish_ids[fi]] = true
						elseif v.data[iii]==5 then
							LOCAL.sp[v.fish_ids[fi]] = true
						end

						if v.data[iii]==0 or v.data[iii]==4 or v.data[iii]==100 or v.data[iii]==10 then
							iii = iii + 1
						else
							iii = iii + 2
						end
						
						fi = fi + 1

						if not v.data[iii] then
							break
						end

					end

				end

			end
		end

		if ret.data.fish_explode then
			for k,v in pairs(ret.data.fish_explode) do
				
				local fi = 1
				local iii = 1
				if v.data then
					
					while true do
						
						if v.data[iii]==4 then
							LOCAL.sp[v.fish_ids[fi]] = true
						elseif v.data[iii]==5 then
							LOCAL.sp[v.fish_ids[fi]] = true
						end

						if v.data[iii]==0 or v.data[iii]==4 or v.data[iii]==100 or v.data[iii]==10 then
							iii = iii + 1
						else
							iii = iii + 2
						end
						
						fi = fi + 1

						if not v.data[iii] then
							break
						end

					end

				end

			end
		end

	end

end



local dt = 1
function LOCAL.update()
	
	while true do

		if LOCAL.status == 1 then

			local rn = math.random(1,10)
			for i=1,rn do
				LOCAL.debug_test_fish_game_shoot()
				skynet.sleep(0)
			end
			print("debug_test_fish_game_shoot...")

			if LOCAL.game_time < os.time() then
				LOCAL.status = 2
				LOCAL.game_time = os.time() + math.random(10,20)
				
				LOCAL.debug_test_fish_game_exit()

				print("debug_test_fish_game_exit...")
			end
		
		elseif LOCAL.status == 2 then

			if LOCAL.game_time < os.time() then
				LOCAL.debug_test_fish_game_signup()
				LOCAL.status = 0
				print("debug_test_fish_game_signup...")
				
				skynet.sleep(100)

				LOCAL.status = 1
				LOCAL.game_time = os.time() + LOCAL.game_time_limit + math.random(10,20)

			end

		end

		skynet.sleep(dt*100)
	end

end



function PROTECT.init()
	
	skynet.timeout(300,function ()
		
		local _asset_data={
			{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=100000000},
		}
		CMD.change_asset_multi(_asset_data,ASSET_CHANGE_TYPE.NEW_USER_LOGINED_AWARD,0)

		LOCAL.debug_test_fish_game_signup()

		print("debug_test_fish_game_signup...")

		skynet.sleep(100)

		LOCAL.status = 1
		LOCAL.game_time = os.time() + LOCAL.game_time_limit + math.random(10,20)

	end)

	skynet.fork(LOCAL.update)

end




return PROTECT

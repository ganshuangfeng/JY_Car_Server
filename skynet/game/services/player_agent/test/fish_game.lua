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

local this = base.LocalData("Local_fish_game")

this.status = 0
this.game_time = 0
this.game_time_limit = 2*60

function this.debug_test_fish_game_signup()
	local gid = math.random(1,4)

	REQUEST.fsg_signup({id=gid})

end



function this.debug_test_fish_game_exit()

	REQUEST.fsg_quit_game()

end




this.bullet = {}
this.sp = {}

function this.debug_test_fish_game_shoot()

	if not DATA.fish_game_data or not DATA.fish_game_data.game_data then
		return
	end


	local s_info = DATA.fish_game_data.game_data

	local data = {
		shoot = {},
		boom = {},
		fish_explode = {},
	}


	if next(this.bullet) then

		for b,d in pairs(this.bullet) do
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
					this.bullet[b] = nil
				end

			end
		end

	end


	if next(this.sp) then
		for b,d in pairs(this.bullet) do
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
				this.sp[b] = nil
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
				this.bullet[v.id] = v.id
			end
		end

		if ret.data.boom then
			for k,v in pairs(ret.data.boom) do
				
				local fi = 1
				local iii = 1
				if v.data then
					
					while true do
						
						if v.data[iii]==4 then
							this.sp[v.fish_ids[fi]] = true
						elseif v.data[iii]==5 then
							this.sp[v.fish_ids[fi]] = true
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
							this.sp[v.fish_ids[fi]] = true
						elseif v.data[iii]==5 then
							this.sp[v.fish_ids[fi]] = true
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
function this.update()
	
	while true do

		if this.status == 1 then

			local rn = math.random(1,10)
			for i=1,rn do
				this.debug_test_fish_game_shoot()
				skynet.sleep(0)
			end
			print("debug_test_fish_game_shoot...")

			if this.game_time < os.time() then
				this.status = 2
				this.game_time = os.time() + math.random(10,20)
				
				this.debug_test_fish_game_exit()

				print("debug_test_fish_game_exit...")
			end
		
		elseif this.status == 2 then

			if this.game_time < os.time() then
				this.debug_test_fish_game_signup()
				this.status = 0
				print("debug_test_fish_game_signup...")
				
				skynet.sleep(100)

				this.status = 1
				this.game_time = os.time() + this.game_time_limit + math.random(10,20)

			end

		end

		skynet.sleep(dt*100)
	end

end



function this.init()

	CMD.change_asset_multi({
		{asset_type=PLAYER_ASSET_TYPES.JING_BI,value=100000000},
	},ASSET_CHANGE_TYPE.NEW_USER_LOGINED_AWARD,0)

	this.debug_test_fish_game_signup()

	print("debug_test_fish_game_signup...")

	skynet.sleep(100)

	this.status = 1
	this.game_time = os.time() + this.game_time_limit + math.random(10,20)

	skynet.fork(this.update)

end




return this

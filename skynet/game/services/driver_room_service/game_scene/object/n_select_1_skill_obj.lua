----- 模板

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("n_select_1_skill_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	self.seat_num = self.owner.seat_num
	---- 技能库 (额外增加的技能列表)
	self.skill_lib = _config.skill_lib
	---- 地图奖励库 id
	self.map_award_id = _config.map_award_id
	---- 地图的奖励库 (优先级最高)
	self.map_award_data = _config.map_award_data

	self.skill_num = _config.skill_num
	---- 是否处理待选技能的 过滤
	--self.is_deal_filt = _config.is_deal_filt



end

function C:init()
	---- 检查 owner 类型
	self:check_run_obj_owner_type( DATA.game_kind_type.car )

	---- 基类处理
	self.super.init(self)
	
	---- 操作类型
	self.op_type = DATA.player_op_type.select_skill
	self.console = DATA.player_op_type.console
	---- 操作倒计时
	self.op_timeout = DATA.player_op_timeout["select_skill"] or 10 

	---- 确定真正待选的技能
	self.real_select_vec = {}
	
	----- map_award_data 优先级最高
	if not self.map_award_data and self.map_award_id and DATA.map_road_award_lib[self.map_award_id] then
		self.map_award_data = self.map_award_data or basefunc.deepcopy( DATA.map_road_award_lib[self.map_award_id] )
	end

	------- 处理技能过滤
	--if self.is_deal_filt == 1 then
	local real_data_lib = {}
	for key, data in pairs(self.map_award_data) do
		local is_can_add = PUBLIC.check_map_award_can_be_select( self.d , data , self.owner )
		----------
		if is_can_add then
			real_data_lib[#real_data_lib + 1] = data
		end
	end


		--self.skill_lib = real_lib
	--end

	---- 分 选择索引的库
	local skill_index_vec = {}

	for i = 1 , self.skill_num do
		skill_index_vec[i] = skill_index_vec[i] or {}
		local tar_data = skill_index_vec[i]

		for key,data in pairs(real_data_lib) do
			local is_add = false

			---- 啥也没有得加上
			if not next(data.refresh_tag) then
				is_add = true
			else
				local is_have_one_index_tag = false
				for tag,value in pairs( data.refresh_tag ) do
					if string.find( tag , "^select_index_%d+" ) then
						is_have_one_index_tag = true
					end
				end

				---- 没有 select_index_数值 开头的得加上
				if not is_have_one_index_tag then
					is_add = true
				else
					--- 有 select_index_数值 得有这两种
					if (data.refresh_tag[ "select_index_0" ] or data.refresh_tag[ "select_index_" .. i ]) then
						is_add = true
					end
				end

			end


			if is_add then
				tar_data[#tar_data + 1] = data
			end
		end
	end
	

	if next(skill_index_vec) then
		for i = 1 , self.skill_num do
			if skill_index_vec[i] and next(skill_index_vec[i]) then
				local data , r_index = basefunc.get_random_data_by_weight( skill_index_vec[i] , "weight" )

				self.real_select_vec[#self.real_select_vec + 1] = data.award_id
			end
		end
	elseif self.skill_lib then
		---- 再选n个
		for i=1,self.skill_num do
			if #self.skill_lib > 0 then
				local random_index = math.random( #self.skill_lib )		
				self.real_select_vec[#self.real_select_vec + 1] = self.skill_lib[random_index]

				table.remove( self.skill_lib , random_index )
			end
		end
	end

	dump(self.real_select_vec , "xxxx---------------------self.real_select_vec:")
	dump(self.skill_lib , "xxxx---------------------self.skill_lib:")
end

function C:wake()
	--监听相关操作返回消息
	PUBLIC.add_msg_listener( self.d , self , C.msg_deal )
end

function C:destroy()
	self.is_run_over = true

	PUBLIC.delete_msg_listener( self.d , self )
end

function C:run()
	print("xxx--------------player_nor_op_skill__run")
	--XXX获取可以做的操作
	local op_permit = {
		[ self.op_type ] = true ,
		[ self.console ] = true ,
	}

	self.op_data = {
		op_type = self.op_type ,
		seat_num = self.seat_num ,
		op_permit = op_permit ,
		for_select_vec = self.real_select_vec ,
		op_timeout = self.op_timeout ,
	}

	--- 统计数据
	self.d.running_data_statis_lib.add_game_data( self.d , { player_op = self.op_data }  ,  self.father_process_no )

	--改变游戏状态
	---- 设置 玩家 操作类型
	PUBLIC.open_player_op_status(self.d , self.seat_num , self.op_type )

	--打包调用发送
	PUBLIC.send_msg_to_agent( self.d , DATA.msg_type.game_progress )


end

function C.msg_deal:player_op_msg(_op_data)

	if _op_data.base_op_type == self.console	then
		self:destroy()
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)
		PUBLIC.close_player_op_status( self.d )
	end


	if _op_data.base_op_type == self.op_type then

		self:destroy()

		local target_skill_id = _op_data.select_index
		print("xxx-----------------player_op_msg__select_skil" , self.seat_num)
		--- 统计数据
		local process_id = self.d.running_data_statis_lib.add_game_data( self.d , {
			player_action = {
				op_type = self.op_type ,
				op_arg_1 = target_skill_id ,
				seat_num = self.seat_num ,
				op_data = self.op_data ,
			} } , self.father_process_no
		)

		----- 创建 技能
		if target_skill_id then
			local data={
				owner = self.owner ,
				father_process_no = process_id ,
			}
			PUBLIC.skill_create_factory(self.d , target_skill_id , data)
		end
		---- 恢复游戏状态
		PUBLIC.close_player_op_status( self.d )
	end
end


return C


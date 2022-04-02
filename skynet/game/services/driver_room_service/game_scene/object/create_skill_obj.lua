----- 技能创建 一个

local base = require "base"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local C = basefunc.create_hot_class("create_skill_obj" , "object_class_base")
C.msg_deal = {}

function C:ctor(_d  , _config)
	---- 基类处理
	self.super.ctor(self , _d  , _config)
	
	---------------------------------------------------- 特殊项 ↓

	---- 技能id  or  技能 列表
	self.skill_id = _config.skill_id
	---- 地图奖励库
	self.map_award_id = _config.map_award_id
	---- 地图奖励库
	self.map_award_data = _config.map_award_data

	---- 是否处理待选技能的 过滤
	--self.is_deal_filt = _config.is_deal_filt

	---- 确定真正待选的技能
	self.real_select_vec = {}
end

---- 当 obj 创建之后调用
function C:init()
	---- 基类处理
	self.super.init(self)
	
	self.real_select_vec = {}

	----- map_award_data 优先级最高
	if not self.map_award_data and self.map_award_id and DATA.map_road_award_lib[self.map_award_id] then
		self.map_award_data = self.map_award_data or basefunc.deepcopy( DATA.map_road_award_lib[self.map_award_id] )
	end

	local real_data_lib = {}
	if self.map_award_data then
		for key, data in pairs(self.map_award_data) do
			local is_can_add = PUBLIC.check_map_award_can_be_select( self.d , data , self.owner )
			----------
			if is_can_add then
				real_data_lib[#real_data_lib + 1] = data
			end
		end
	end

	if next(real_data_lib) then
		for k,data in pairs(real_data_lib) do
			self.real_select_vec[#self.real_select_vec + 1] = data.award_id
		end
	elseif self.skill_id then
		self.real_select_vec = ( type(self.skill_id) == "table") and self.skill_id or { self.skill_id }
	end


end

---- 当 obj 在 run_system 第一次执行之前调用
function C:wake()
	
end

function C:destroy()
	self.is_run_over = true
end

function C:run()

	if type(self.real_select_vec) == "table" then
		local tar_skill_id = self.real_select_vec[ math.random(#self.real_select_vec) ]

		if tar_skill_id then
			PUBLIC.skill_create_factory( self.d , tar_skill_id , { owner = self.owner , father_process_no = self.father_process_no  }  )
		end
	end

	

	self:destroy()
end

return C




local basefunc = require "basefunc"
local base=require "base"
local skynet = require "skynet_plus"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA
local game_run_system = basefunc.create_hot_class("game_run_system")
local C = game_run_system

C.msg_deal = {}

function C:ctor(_d)
	self.d=_d

	self:init()
end

function C:init()
	-- 持续增长
	self.event_id = 0   
	--event_status  事件状态  true or false  方便惰性更新 , 可以控制 操作obj 的删除
	self.event_status = {}
	----正在运行的obj 栈 ， 先进后出，后进先出
	self.event_stack = {}
	---- 等待队列 , 加入时往屁股后面加，出来时，也是从屁股后面出，所以是先来后加入运行栈，但是后加入就是在栈顶，会先执行。
	self.wait_event_list = {} 

end
function C:destroy()
	PUBLIC.delete_msg_listener( self.d , self )
	
end

function C:game_begin()
	--注册监听
	PUBLIC.add_msg_listener(self.d , self , C.msg_deal)
	--调用启动
	--self:run()

	----- for 正式
	xpcall( self.run , basefunc.error_handle , self )
end


function C.msg_deal:deal_gameRunning()
	--self:run()
	
	----- for 正式
	xpcall( self.run , basefunc.error_handle , self )
end
-- function C:deal_notGameRunning()

-- end

function C:remove_notUse_event(evet_list)
	local len = #evet_list
	local k = 1
	for i = 1 , len do
		if self.event_status[evet_list[i].id] and not evet_list[i].obj.is_run_over then
			evet_list[k]=evet_list[i]
			k = k + 1
		else
			evet_list[i]=nil
		end
	end
end
function C:merge_wait_event()
	local len = #self.wait_event_list
	while len > 0 do
		self.event_stack[#self.event_stack+1] = self.wait_event_list[len]
		self.wait_event_list[len] = nil
		len = len - 1
	end
end
function C:sort_by_level()
end
function C:refresh_event_stack()
	self:remove_notUse_event(self.event_stack)
	self:remove_notUse_event(self.wait_event_list)
	self:merge_wait_event()
	-- C:sort_by_level()
end
function C:run()
	--room  status为running时方可运行
	--dump(self.d , "xxxx-------------game_run_system__run__1")
	--print("xxx------- game_run_system__run__1:" , self.d.status)
	while self.d.status == DATA.table_status.running do
		--print("xxx------- game_run_system__run__2", self.d.status)
		self:refresh_event_stack()
		if #self.event_stack > 0 then
			local tar_data = self.event_stack[#self.event_stack]
			local tar_obj = tar_data.obj

			if tar_obj then
				if not tar_obj.is_wake and tar_obj.wake then
					tar_obj.is_wake = true
					tar_obj:wake()

				end

				tar_obj:run()
			end

			--print("xxx------- game_run_system__run__3")
		else
			--特殊或异常情况
		end
	end
end	

----- 执行 

function C:add_event(event_data)
	if type(event_data)~="table" or not event_data.id then
		return  false
	end 
	if event_data.run_type =="next" or not event_data.run_type then
		self.wait_event_list[#self.wait_event_list+1] = event_data
		self.event_status[event_data.id] = true
	end 

	--print("xxx----------------event_data.run_type:" , event_data.run_type)

	if event_data.run_type == "now" then
		--print("xxx----------------event_data.run_type 22:" , event_data.run_type)
		----- 立刻执行，暂不能执行 可以影响游戏流程的逻辑
		local tar_obj = event_data.obj
		xpcall( function()
			--print("xxx----------------event_data.run_type 33:" , event_data.run_type)
			while true do
				--print("xxx----------------event_data.run_type 44:" , event_data.run_type)
				----没有或者 已经完成
				if not tar_obj or tar_obj.is_run_over then
					--print("xxx----------------event_data.run_type 55:" , event_data.run_type)
					break
				end

				if not tar_obj.is_wake and tar_obj.wake then
					--print("xxx----------------event_data.run_type 66:" , event_data.run_type)
					tar_obj.is_wake = true
					tar_obj:wake()
				end
				--print("xxx----------------event_data.run_type 77:" , event_data.run_type)
				tar_obj:run()
			end
		end
		, basefunc.error_handle )
	end 

	return  true
end
function C:remove_event(event_data_id)
	self.event_status[event_data_id] = nil
end
--[[
	创建event数据结构 包
	id
	level
	run_type
			1:next  下一次系统调度
			
			--2:now   立刻run
--]]
function C:creat_event_data(obj,level,run_type)
	print("xxx-----------creat_event_data:" , obj,level,run_type)
	self.event_id = self.event_id + 1
	return {	
				id = self.event_id,
				obj = obj,
				level = level, --or level_cfg[obj.type],
				run_type = run_type, --or run_type_cfg[obj.type]
			}
end

------- 创建 并 添加
function C:create_add_event_data(obj,level,run_type)
	self:add_event( self:creat_event_data(obj,level,run_type) )
end

------ 创建一个 包装成obj 按顺序处理的 函数 obj
function C:create_delay_func_obj(_func)
	local data = { 
			level = 1 , 
			obj_enum = "delay_deal_func_obj",
			
			func = _func
		}

		local run_obj = PUBLIC.create_obj( self.d , data )
		if run_obj then
			---- 加入 运行系统
			self:create_add_event_data(	run_obj , 1 , "next" ) 
		end
end
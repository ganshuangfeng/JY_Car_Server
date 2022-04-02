--[[
	作者：wss 2020-12-31

	fsm状态机
--]]
local basefunc = require "basefunc"
local fsm_table_lib = require "fsm_table_lib"

local fsm_module = basefunc.create_hot_class("fsm_module")


local C = fsm_module

---- 逻辑状态的定义
C.logic_status_type = {
    none = 0,
    ready = 1,
    begin = 2,
    running = 3,
    pause = 4,
    finish = 5,
}

C.FSM_state_type = {
    wait = 1,           --新来的状态继续等待     
    discardNew = 2,     --丢弃新状态 原状态不变
    replace = 3,        --新状态运行 原状态压栈
    discardCur = 4,     --新状态运行 丢弃原状态
    refresh = 5,        --刷新
}

function C:ctor( _fsm_table )

    -- 运行中的 分插槽的 状态 列表，列表末尾的表示正在运行的状态(但又不是唯一的运行态)
    self.state_slot_list = {}

    -- 正在运行的 分插槽的 状态集合
    self.running_slot_state = {}

    --等待队列
    self.waitQueue = basefunc.queue.new()

    --- fsm 关系表
    self.fsm_table = _fsm_table

    
end


--添加一个状态数据包到等待队列,
--参数为
--[[{ 
      stateName = C.getStateName( stateKey ) , 
      slotName = C.getSlotName(stateKey) , 
      className = C.getStatusClassName(stateKey) , 
      other_data = C.getStatusOtherData(stateKey) , 
      data = data , 
    }
--]]
function C:addWaitStatus(newStateData)
       
      self.waitQueue:pushBack(newStateData)

end

function C:update(dt)


    --- 对队列中的所有的状态 ， 进行遍历，处理 完成的情况。
    for slot_name , state_list in pairs(self.state_slot_list) do
        for item_data,_ in state_list:item_values() do
            local logic_ctrl = item_data[1]

            ---- 所有的可以运行的就可以运行。 (控制器内部自己决定 能不能 更新)
            if logic_ctrl and logic_ctrl.update then
                logic_ctrl:update(dt)
            end

            ---- 完成的就 处理 一下
            if logic_ctrl and logic_ctrl.status and logic_ctrl.status == C.logic_status_type.finish then
                if logic_ctrl.finish then
                    logic_ctrl:finish()

                    ---- 从状态列表中删除
                    state_list:erase( item_data )
                end
            end
        end
    end

    self:resumeState(slotName)

    --获得队列长度
    local queueSize = self.waitQueue:size()

    local i=1
	 --遍历等待队列，逐个查询状态表，处理上一帧中的等待队列，处理后等待队列为空
    local lastWaitState=nil
    local flag=true
    while i <= queueSize do

        flag = true

      	local newStateData = self.waitQueue:popFront()

        if newStateData and lastWaitState then 
            if newStateData.className == lastWaitState.className and newStateData.stateName == lastWaitState.stateName then 
                flag = false
            end 
        end 

        if flag then 
            lastWaitState = newStateData
      	    self:dealState(newStateData)
        end

      	i = i + 1
    end

    -- 对列表末尾的 处理
    for key,val in pairs(self.running_slot_state) do

        if val.logic_status == C.logic_status_type.pause then
           val:resume()
        elseif val.logic_status == C.logic_status_type.ready then
           val:begin()
        end 
     end
	
	 
end

--处理新来的状态
function C:dealState(newStateData)
            
           
		  -- 查询状态表
          local type = self:inquireStateTable( self.running_slot_state[newStateData.slotName] , newStateData )
       

          --	1：当前状态不变，新状态继续排队等待
          if type == FSM_state_type.wait then

               self:addWaitStatus(newStateData)

          --	2：当前状态不变，丢弃新状态   
          elseif type == FSM_state_type.discardNew then

          			 return 

          --	3: 新状态运行 老状态压栈
          elseif type == FSM_state_type.replace then

                self:beginState(newStateData)

         --		4: 丢弃当前状态，弹栈
          elseif type == FSM_state_type.discardCur then

                 self:stopState(newStateData.slotName)

                 return self:dealState(newStateData) 

         --		5: 当前状态与新状态融合
          elseif type == FSM_state_type.refresh then
         --test  暂定
     			       self:refreshState(newStateData)

          end



end
 

-- 查询状态表
-- 返回值：
--	1：当前状态不变，新状态继续排队等待
--	2：当前状态不变，丢弃新状态
--	3: 新状态入栈
--	4: 丢弃当前状态，弹栈
--  5: 当前状态与新状态融合
function C:inquireStateTable( curState , newStateData )

--当前状态为nil  直接运行newState
	if not curState then
		return  FSM_state_type.replace 
	end 

  if self.fsm_table and curState.stateName and newStateData.stateName then

      return FSM_state_type[ self.fsm_table:query( curState.slotName , {name = newStateData.stateName })[curState.stateName] ] or FSM_state_type.discardNew
  end

  return FSM_state_type.discardNew
end



--结束一个状态--即丢弃状态，弹栈
--强制结束当前正在运行的状态
function C:stopState(slotName)
    --逻辑控制器外部强行调用 其他控制器的stop()函数
    self.running_slot_state[slotName]:stop()

    self.running_slot_state[slotName]=nil

    ---- 将最后一个给弹出来
    self.state_slot_list[slotName]:pop_back()

    --恢复
    self:resumeState(slotName)
 
end
--自然结束
function C:endState(slotName)

    self.running_slot_state[slotName]:finish()
    self.running_slot_state[slotName] = nil
    --恢复
    self:resumeState(slotName)
end

---- 恢复 状态
function C:resumeState(slotName)
    local back = self.state_slot_list[slotName]:back()

    self.running_slot_state[slotName] = back
end

---- 暂停 状态
function C:pauseState(slotName)
    if self.running_slot_state[slotName] then 
        --调用暂定   如果能被暂停
        if self.running_slot_state[slotName]:pause() then 
          
            
        end   

        self.running_slot_state[slotName]=nil
    end 

end

--开始一个状态
function C:beginState(newStateData)

    local slot_name = newStateData.slotName

    self:pauseState(slot_name)

    local new_state = self:createState(newStateData)
    
    if new_state then
        self.state_slot_list[slot_name] = self.state_slot_list[slot_name] or basefunc.list.new()

        self.state_slot_list[slot_name]:push_back(new_state)

        self.running_slot_state[slot_name] = new_state
    end
end

--刷新一个状态
function C:refreshState(newStateData)
    local slot_name = newStateData.slotName
    if self.running_slot_state[slot_name] and self.running_slot_state[slot_name].refresh then

       self.running_slot_state[slot_name]:refresh(newStateData.data)
    end

end

--创建一个状态
function C:createState(newStateData)
       local ret = nil

       if newStateData and newStateData.className and newStateData.className.new then
          ret = newStateData.className.new( self.ecs_world , newStateData.data )
       end 
       --赋予 fsm 状态名
	     ret.stateName = newStateData.stateName
       ret.other_data = newStateData.other_data

       --为none也是创建失败   
       if ret and ret.logic_status == C.logic_status_type.none then
          ret = nil
       end

	   return ret
end


return C






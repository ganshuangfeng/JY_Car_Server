local basefunc = require "basefunc"
require"printfunc"

local skynet = require "skynet_plus"
require "skynet.manager"

local BraodCastPoll=basefunc.class()




function BraodCastPoll:ctor(channelId,types,broadcast_cfg)
	--- 频道id
	self.m_channelId = channelId
	--- 广播类型
	self.m_braodType=types
	--- 等级队列
	self.m_LevelQueueMap = { } 
	for _,level  in pairs(BROADCAST_LIMIT_TYPE) do
		self.m_LevelQueueMap[level] = basefunc.queue.new()
	end
	--- 遗弃队列
	self.m_abandonQueue = basefunc.queue.new()
	--- 类型每个队列长度默认值
	self.m_queue_length_Limit = broadcast_cfg.default_queue_length
end


--- 获取频道Id
function BraodCastPoll:getChannelId()
	return self.m_channelId 
end


---- 插入到广播队列中
function BraodCastPoll:pushMsgQueue(msg,level)
	
	local levelqueue =  self.m_LevelQueueMap[level]
	--- 超过长度遗弃
	if levelqueue:size()  >= self.m_queue_length_Limit[level]  then 
		self:pushAbandonQueue(msg)
	else
		levelqueue:push_back( msg)
	end
end


--- 插入到遗弃队列中
function BraodCastPoll:pushAbandonQueue(msg)
	if self.m_queue_length_Limit.abandon_pool_count_max <= self.m_abandonQueue:size() then 
		self.m_abandonQueue:pop_front()
	end
	self.m_abandonQueue:push_back(  msg )
end


--- 获取N条广播消息
function BraodCastPoll:getMessage(N)
	local retQueue = basefunc.queue.new()
	local count = 0
	--- 依次从等级队列中取消息
	for level,levelqueue  in ipairs(self.m_LevelQueueMap) do
		while not levelqueue:empty() do
			local obj = levelqueue:pop_front()
			retQueue:push_back(obj)
			count = count + 1
			if count >= N then 
				return retQueue
			end
		end
	end
	
	return retQueue
end


--- 从遗弃队列中获取N条广播消息
function BraodCastPoll:getMessageFromAbandon(N)
	local retQueue = basefunc.queue.new()
	local count = 0
	--- 依次从遗弃队列中取消息
	while not self.m_abandonQueue:empty() do
		local obj = self.m_abandonQueue:pop_front()
		retQueue:push_back(obj)
		count = count + 1
		if count >= N then 
			return retQueue
		end
	end
	return retQueue
end


function BraodCastPoll:getLevelQueueSize()
	local size = 0
	for level,levelqueue  in ipairs(self.m_LevelQueueMap) do
		size = levelqueue:size() + size
	end
	return size
end


function BraodCastPoll:getAbandonQueueSize()
	return self.m_abandonQueue:size()
end



return BraodCastPoll
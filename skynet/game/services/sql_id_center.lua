--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 17:10
-- 说明：sql 序号中心
--


local skynet = require "skynet_plus"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"

require "normal_enum"

require "printfunc"

local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

DATA.service_config = nil

-- 最近执行完成的 sql 序号： queue_name => sql id
DATA.last_sql_id = DATA.last_sql_id or {}

-- 出错 sql ： queue_name => {id => true}
DATA.fail_sql_ids = DATA.fail_sql or {}

function CMD.start(_service_config)

	DATA.service_config = _service_config

	skynet.timer(600,function()
		CMD.clear_fail_ids()
	end)
end

function CMD.clear_fail_ids()

	if not next(DATA.fail_sql_ids) then
		return
	end

	local _new_queue_ids = {}

	for _qname,_fail_ids in pairs(DATA.fail_sql_ids) do

		if next(_fail_ids) then
			local _ids_sort = {}
			for _id,_ in pairs(_fail_ids) do
				_ids_sort[#_ids_sort + 1] = _id
			end

			-- 倒排序
			table.sort(_ids_sort,function(v1,v2)
				return v1 > v2
			end)

			local _max_count = skynet.getcfg_2number("keep_sql_fail_id_count") or 50 -- 保持 最大的错误条数
			local _max_diff = skynet.getcfg_2number("keep_sql_fail_id_diff") or 20000 -- 保留距离当前语句之前 n 条 以内的错误语句

			local _min_id = (DATA.last_sql_id[_qname] or 0) - _max_diff
			
			_fail_ids = {}
			for i,_id in ipairs(_ids_sort) do
				if i > _max_count or _id < _min_id then
					break
				end

				_fail_ids[_id] = true
			end

			_new_queue_ids[_qname] = _fail_ids
		end
	end

	DATA.fail_sql_ids = _new_queue_ids
	
end

function CMD.set_last_id(_queue_name,_id)

	DATA.last_sql_id[_queue_name] = _id
end

function CMD.add_fail_id(_queue_name,_id)
	if DATA.fail_sql_ids[_queue_name] then
		DATA.fail_sql_ids[_queue_name][_id] = true
	else
		DATA.fail_sql_ids[_queue_name] = {[_id]=true}
	end
end

function CMD.add_fail_ids(_queue_name,_ids)
	local _queue = DATA.fail_sql_ids[_queue_name] or {}
	DATA.fail_sql_ids[_queue_name] = _queue

	for _,_id in ipairs(_ids) do
		_queue[_id] = true
	end
end

function CMD.get_last_id(_queue_name)
	return DATA.last_sql_id[_queue_name]
end

function CMD.get_fail_ids(_queue_name)
	return DATA.fail_sql_ids[_queue_name]
end

function CMD.get_sql_info(_queue_name)
	return {
		last_id = DATA.last_sql_id[_queue_name],
		fail_ids = DATA.fail_sql_ids[_queue_name],
	}
end

-- 启动服务
base.start_service()

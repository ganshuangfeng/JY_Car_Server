--
-- Author: hw
-- Date: 2018/3/10
-- Time: 15:13
-- 说明：中心服务
--
local skynet = require "skynet_plus"
require "skynet.manager"
local cluster = require "skynet.cluster"
local basefunc = require "basefunc"
local base = require "base"
require "printfunc"
local lfs = require"lfs"

require "normal_func"
local CMD =base.CMD
local DATA =base.DATA
local PUBLIC =base.PUBLIC

local service_type=	require "service_type"

local PROTECT={}

-- 系统诊断信息
DATA.sysinfo = {
	-- 服务启动时间
	svr_launch_time = {},
	svr_launch_time_sum=0,

	launched = false,
}

DATA.node_info={}
DATA.node_broadcast_info={}
DATA.service_to_nodeName={}
DATA.service_to_addr={}
--服务id锁
DATA.service_id_lock={}

DATA.dyna_hotfix_files = {}

-- 通用 key-value 注册
DATA.common_data_map = {}

--当前服务器组，每个节点的信息
local node_info=DATA.node_info
--当前服务器组，每个节点广播中心的信息
local node_broadcast_info=DATA.node_broadcast_info
--代理或服务所在的node key=id value=node
local service_to_nodeName = DATA.service_to_nodeName
local service_to_addr=DATA.service_to_addr
-- local set_group={}
-- local clear_group={}
--当前center所处的node名字
local node_name=skynet.getenv "my_node_name"
local node_max_id=0

-- 节点的变化列表
local node_change_list = {}

local launched_trigger = {}

-- by lyx ，各节点的部署信息（服务，配置参数）
local deploy_nodes_info = {}

-- by lyx ，中心的配置信息(center.lua)
local deploy_nodes_config = nil

-- 设置 动态热更新的名字
function CMD.add_dyna_hotfix_file(_file)
	DATA.dyna_hotfix_files[_file] = true
end
-- 得到动态热更新列表
function CMD.get_dyna_hotfix_list()
	return DATA.dyna_hotfix_files
end

function CMD.add_launched_trigger(_recv)
	if DATA.sysinfo.launched then -- 已启动，立即触发
		cluster.send(_recv.node,_recv.addr,_recv.cmd)
	else
		table.insert(launched_trigger,_recv)
	end
end

function CMD.set_nodes_cfg(_name,_value)
	for _node_name,_info in pairs(node_info) do
		cluster.send(_node_name,"node_service","update_config",_name,_value)
	end
end

-- 加入 键值映射
-- 如果 key 为 表，则替换整个数据映射
-- 返回：如果之前存在则 false
function CMD.set_data_map(_name,_key,_value)
	if type(_key) == "table" then
		DATA.common_data_map[_name] = _key
	else
		DATA.common_data_map[_name] = DATA.common_data_map[_name] or {}
		local _d = DATA.common_data_map[_name]
		_d[_key] = _value
	end
end

function CMD.get_data_map(_name,_key)
	local _d = DATA.common_data_map[_name]
	if not _d then
		return nil
	end
	if _key then
		return _d[_key] 
	else
		return _d
	end
end

function CMD.query_service_node(id)
	if id then
		return service_to_nodeName[id],service_to_addr[id]
	end
	return nil
end
function CMD.set_service_to_nodeID(id,node_name,addr,res)
	if id and node_name then
		service_to_nodeName[id]=node_name
		service_to_addr[id]=addr
		node_info[node_name].res=node_info[node_name].res+res

		-- 同步列表： op=1 表示 设置， op=2 表示清除
		node_change_list[#node_change_list + 1] = {op=1,node=node_name,id=id,addr=addr}
	end
end
function CMD.clear_service_to_nodeID(id,node_name,res)
	if id then
		service_to_nodeName[id]=nil
		service_to_addr[id]=nil
		CMD.unlock_service_id(id)
		node_info[node_name].res=node_info[node_name].res+res
		
		-- 同步列表： op=1 表示 设置， op=2 表示清除
		node_change_list[#node_change_list + 1] = {op=2,id=id}
	end
end

function CMD.get_res(type)
	
	if service_type[type].node_name then
		return service_type[type].node_name
	end

	--将目前资源剩余量最大的分配给请求方 -- ###_test 目前的资源调配限制只是暂时的
	local max=-100000000
	local node_name=nil
	for _node_name,msg in pairs(node_info) do
		if msg.res>max then
			max=msg.res
			node_name=_node_name
		end		
	end
	return node_name
end
function CMD.lock_service_id(id)
	if id and not DATA.service_id_lock[id] then
		DATA.service_id_lock[id]=true
		return true
	end
	return false
end
function CMD.unlock_service_id(id)
	if id and DATA.service_id_lock[id] then
		DATA.service_id_lock[id]=nil
		return true
	end
	return false
end

local function sync_dispatch()
	if next(node_change_list) then -- by lyx

		for id,msg in pairs(node_info) do
			cluster.send(id, msg.node_service_addr,"sync",node_change_list)
		end

		node_change_list = {}
	end
end
function PROTECT.sync_dispatch_by_time()
	skynet.fork(function ()
		while true do
			skynet.sleep(50)
			sync_dispatch()
		end
	end)
end
function CMD.add_node(_node_name,addr,id,res)

	node_info[_node_name]={}
	node_info[_node_name].node_service_addr=addr
	node_info[_node_name].node_service_id=id
	node_info[_node_name].res=res
	
	service_to_nodeName[id]=_node_name
	service_to_addr[id]=addr
	
	service_to_nodeName[_node_name]=_node_name
	service_to_addr[_node_name]=addr

	for _nm,_ in pairs(node_info) do 
		cluster.send(_nm,"node_service","other_node_joined",_node_name)
	end

	return 0
end
function CMD.get_node_list()
	return node_info
end
function CMD.get_node_id()
	node_max_id=node_max_id+1
	return node_max_id
end
function CMD.add_node_broadcast(_node_name,_addr,_id)
	node_broadcast_info[_node_name]={addr=_addr,id=_id}
end
function CMD.get_node_broadcast_list()
	return node_broadcast_info
end

--[[ 收集所有服务信息服务 (by lyx 2018-4-27)
（此命令供管理控制台 即时获取服务信息 使用）
注意，只收集以下两类服务：
	1、通过 node_service 创建的服务
	2、在 service_config 中的手动 启动的服务
返回数组，每项内容：
	id 		服务的唯一 id ，如果不是 node_service 创建的，则为 nil
	res		服务所需消耗的资源，如果不是 node_service 创建的，则为 nil
	node_name 所在节点的名字
	addr	服务的本地地址
	arg		服务的启动参数
--]]
function CMD.gather_services()
	local ret_data = {}
	for _name,_node in pairs(node_info) do
		local ok,_node_services = pcall(cluster.call,_name,_node.node_service_addr,"gather_services")
		if ok then
			for _,_service in ipairs(_node_services) do
				if _service.addr ~= skynet.self() then
					_service.node_name = _name
					_service.node_id = _node.node_service_id
					ret_data[#ret_data + 1] = _service
				end
			end
		end
	end

	return ret_data
end

--[[ 
	收集服务状态，在 gather_services 的基础上增加 status 值
--]]
function CMD.gather_services_status(_time_out)

	local _local_leave = false
	-- 先收集所有服务
	local _services = CMD.gather_services()
	for _,_service in pairs(_services) do
		_service.status_return = false -- 状态调用是否已经返回
	end

	for _,_service in pairs(_services) do


		skynet.fork(function()

			if _service.arg then

				local ok,status,info = pcall(cluster.call,_service.node_name,_service.addr,"get_service_status")

				if _local_leave then return end

				_service.status_return = true

				if ok then 
					_service.status = status
					_service.info = info or ""
				else
					_service.status = "error"
					_service.info = status
				end
			else
				_service.status = "stop"
				_service.info = ""
			end
		end)

	end

	-- 等待 服务状态返回
	local _time1 = os.time()
	local _done = false
	while not _done and os.time()-_time1 < (_time_out or 5) do
		skynet.sleep(10)
		_done = true
		for _,_service in pairs(_services) do
			if not _service.status_return then
				_done = false
				break
			end
		end
	end

	_local_leave = true

	return _services


end

function PUBLIC.try_stop_service(_count,_time)
	return "free"
end

-- 热启动服务
-- 参数：
--	_node 所在节点
--	_name 服务名； 
--	_launch 源文件，可选，默认为 _name/_name
function CMD.hot_launch_service(_node,_name,_launch)

	if not deploy_nodes_info[_node] then
		return 1,"error:not found node!"
	end
	local _node_addr = deploy_nodes_info[_node].node_addr
	if not _node_addr then
		return 1,"error:node addr is nil!"
	end

	_launch = _launch or (_name .. "/" .. _name)

	-- 创建服务
	local _addr = skynet.call(_node_addr,"lua","create_system_service",_name,_launch)

	-- 更新所有节点的服务地址
	local _svr = {[_name] = {node=_node,addr=_addr}}
	for _,_node_info in pairs(deploy_nodes_info) do
		skynet.call(_node_info.node_addr,"lua","update_services",_svr)
	end
	
	-- 启动服务
	skynet.call(_node_addr,"lua","start_system_service",_addr)

	return 0,"launch succ!"
end

-- 强制终止服务：注意，此前请确保数据已保存
-- 为了避免事故，第一次返回动态密码，第二次 再真正停止
DATA.shutdown_keys = {}
function CMD.hot_shutdown_service(_name,_key)

	-- 密码 是否过期
	local _key_data = DATA.shutdown_keys[_name]
	if not _key_data or 
		(os.time() - _key_data.time) > 30 or
		_key ~= _key_data.key then

		-- 重新生成 key
		DATA.shutdown_keys[_name] = {
			key=skynet.random_str(4),
			time=os.time()
		}

		return 1,"use key shutdown again:" .. DATA.shutdown_keys[_name].key
	end

	DATA.shutdown_keys[_name] = nil

	local _count = 0
	for _,_node_info in pairs(deploy_nodes_info) do
		if skynet.call(_node_info.node_addr,"lua","hot_shutdown_service",_name) then
			_count = _count + 1
		end
	end

	return 0,"shutdown on node count:" .. tostring(_count)
end

local function connect_nodes()

	local _node_names = {}
	for _name,_ in pairs(deploy_nodes_config.nodes) do
		_node_names[_name] = true
	end

	-- 先处理自己
	print(string.format("connect to node '%s' ...",node_name))
	skynet.call(deploy_nodes_info[node_name].node_addr,"lua","node_joined",_node_names,deploy_nodes_info[node_name].node_config)
	print(string.format("connect to node '%s' ok.",node_name))

	local _waiting = {}

	local clusterd = skynet.uniqueservice("clusterd")
	skynet.send(clusterd,"lua","set_silent_try_connect",true)
	skynet.sleep(10)

	-- 连接所有节点服务，并设置参数
	for _name,_ in pairs(deploy_nodes_config.nodes) do

		if _name ~= node_name then -- 本节点 不用查询

			print(string.format("connect to node '%s' ...",_name))
			_waiting[_name] = true

			skynet.timeout(1,function ()
				--for i=1,10 do
				while true do -- 连上为止
					-- if i > 1 then
					-- 	print(string.format("connect to node '%s' fail(%d), retry now ...",_name,i))
					-- end

					local ok,addr = pcall(cluster.query,_name,"node_service")
					if ok and addr then
						deploy_nodes_info[_name].node_addr = cluster.proxy(_name,addr)

						skynet.call(deploy_nodes_info[_name].node_addr,"lua","node_joined",_node_names,deploy_nodes_info[_name].node_config)
						_waiting[_name] = nil

						print(string.format("connect to node '%s' ok.",_name))
						return
					end
				end
			end)
		end
	end

	-- 等待
	while next(_waiting) do
		skynet.sleep(1)
	end

	skynet.send(clusterd,"lua","set_silent_try_connect",false)

	print("all nodes connected !")
end

-- 创建服务，返回数组：{node=,addr=}
local function create_services(services,public_services,private_services)

	print("create services ...")

	local _waiting = {}
	local _service_index = 0

	local function create_service(_pub,_node_name,_service_name,_launch)
		_service_index = _service_index + 1
		_waiting[_service_index] = true

		local _index = _service_index

		print(string.format("create service '%s' -> '%s' ... ",_node_name,_service_name))

		skynet.fork(function ()
			if not deploy_nodes_info[_node_name] then
				error(string.format("center config error:service '%s' deploy on node '%s',but this node not found!",_service_name,_node_name))
			end
			local _addr = assert(skynet.call(deploy_nodes_info[_node_name].node_addr,"lua","create_system_service",_service_name,_launch),
				string.format("create service '%s' -> '%s' fail!",_node_name,_service_name))

			local _serInfo = {node=_node_name,addr = _addr,name=_service_name}
			services[_index] = _serInfo
			if _pub then
				public_services[_service_name] = _serInfo
			else
				private_services[_node_name] = private_services[_node_name] or {}
				private_services[_node_name][_service_name] = _serInfo
			end

			print(string.format("create service '%s' -> '%s' ok!",_node_name,_service_name))

			_waiting[_index] = nil
		end)
	end

	-- 创建每个服务
	--local service_config = {} -- 公共服务表： name => {node=,addr=}
	for _,_service in ipairs(deploy_nodes_config.services) do
		for _service_name,_node_name in pairs(_service.deploy) do

			skynet.sleep(10)

			if "*" == _node_name then
				for _node_name2,_info in pairs(deploy_nodes_info) do
					create_service(false,_node_name2,_service_name,_service.launch)
				end
			elseif type(_node_name) == "table" then 	-- 一个对多个，私有服务
				for _,_node_name2 in ipairs(_node_name) do
					create_service(false,_node_name2,_service_name,_service.launch)
				end
			elseif type(_node_name) == "string" then 	-- 一个对一个名字，公共服务
				create_service(true,_node_name,_service_name,_service.launch)
			else
				error("services config error:" .. basefunc.tostring(_service))
			end
		end
	end

	-- 等待
	while next(_waiting) do
		skynet.sleep(10)
	end

	print("all services created !")	
end

local function on_server_launched()

	-- 执行脚本
	local _sh_name = skynet.getcfg("launch_ok_shell")
	if _sh_name then
		local ok,_exit,_signal = os.execute(_sh_name)
		if ok then
			print("execute " .. _sh_name .. ":",_exit,_signal)
		else
			print("execute " .. _sh_name .. ": not found !")
		end
	else
		print("not config launch ok shell!")
	end

	-- 钉钉通知
	local _dtalk = skynet.getcfg("launch_notify_dingtalk")
	local _content = skynet.getcfg("launch_notify_content")
	if _dtalk and _content then
		skynet.timeout(3000,function()

			local _test_code = skynet.call(DATA.service_config.verify_service,"lua","get_test_code")
			local _send_param = {
				msgtype="text",
				at={
					isAtAll = true,
				},
				text = {
					content=string.format(_content,tostring(_test_code))
				},
			}
		
			PUBLIC.notify_dingtalk(_dtalk,_send_param)	
		end)
	end
end
-- 启动服务
local function start_services(services,public_services,private_services)

	print("start services ...")
	local _ti0 = skynet.now()

	-- 先 start 每个节点的 node_service，并下发配置 CMD.update_config(_name,_value)
	for _name,_info in pairs(deploy_nodes_info) do

		skynet.sleep(10)
		
		local _service_config = basefunc.copy(public_services)

		if private_services[_name] then
			basefunc.merge(private_services[_name],_service_config)
		end

		print("call node start:",_info.node_addr,_name)
		skynet.call(_info.node_addr,"lua","start",_service_config)
	end

	-- 开始每个服务。注意：同步依次 start
	for _,_service in ipairs(services) do
		print(string.format("start service '%s' -> '%s' ... ",_service.node,_service.name))

		local _sti0 = skynet.now()
		skynet.call(deploy_nodes_info[_service.node].node_addr,"lua","start_system_service",_service.addr)
		DATA.sysinfo.svr_launch_time[_service.name] = (skynet.now()-_sti0)/100

		print(string.format("start service '%s' -> '%s' ok! ",_service.node,_service.name))
	end


	DATA.sysinfo.svr_launch_time_sum = (skynet.now()-_ti0)/100

	DATA.sysinfo.launched = true
	local tmp_launch = launched_trigger
	launched_trigger = {}
	for _,v in ipairs(tmp_launch) do
		cluster.send(v.node,v.addr,v.cmd)
	end
	

	DATA.service_config = base.service_visitor()

	-- 全服标志： 服务器已经启动
	CMD.set_nodes_cfg("is_server_launched",true)

	print("all services started. use time:",DATA.sysinfo.svr_launch_time_sum)

	on_server_launched()
end


-- by lyx ： 初始化集群中所有的节点
local function init_nodes()

	-- 连接所有节点
	connect_nodes()

	-- 所有服务信息
	local services = {} -- 数组，按启动顺序： {node=,addr=}

	-- 按名字存放的服务列表（公共、私有）
	DATA.public_services = {} 	-- service_name={node=,addr=}
	DATA.private_services = {} -- node => { service_name={node=,addr=} }

	-- by lyx
	PROTECT.sync_dispatch_by_time()

	-- 中心就是自己
	DATA.public_services.center_service = {node=node_name,addr=skynet.self()}

	-- 创建服务
	create_services(services,DATA.public_services,DATA.private_services)

	-- 开始服务
	start_services(services,DATA.public_services,DATA.private_services)
end
function CMD.get_public_services(_name)

	skynet.timeout(100,function()
		local _node_names = {}
		for _cur_name,_ in pairs(deploy_nodes_config.nodes) do
			_node_names[_cur_name] = true
		end		
		cluster.call(_name,"node_service","node_joined",_node_names,deploy_nodes_config.configs)
	end)

	return DATA.public_services
 
end

function CMD.start(_nodes_config,_node_serive)

	deploy_nodes_config = _nodes_config

	-- 准备节点数据
	for _name,_info in pairs(_nodes_config.nodes) do

		-- 节点数据结构
		local _node_info = 
		{
			node_addr = nil,	-- 节点地址
			node_config = nil,	-- 节点配置
		}

		_node_info.node_config = basefunc.copy(_nodes_config.configs)

		-- 用私有配置覆盖全局配置
		basefunc.merge(_info,_node_info.node_config)

		-- 产生 id
		_node_info.node_config.id = CMD.get_node_id()

		-- 自己节点
		if node_name == _name then
			_node_info.node_addr = _node_serive
		end

		deploy_nodes_info[_name] = _node_info
	end

	skynet.timeout(1,init_nodes)

	cluster.register("center_service",skynet.self())

end

-- 启动服务
base.start_service(nil,"center_service")

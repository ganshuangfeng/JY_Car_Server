--
-- Author: hw
-- Date: 2018/3/10
-- Time: 15:13
-- 说明：节点服务管理器

local skynet = require "skynet_plus"
require "skynet.manager"
local cluster = require "skynet.cluster"
require "printfunc"

local base = require "base"

local sharedata = require "skynet.sharedata"

local basefunc = require "basefunc"

local service_type=	require "service_type"

local clusterd

local CMD = base.CMD

local LD = base.LocalData("node_service",{
	-- 节点共享数据
	node_share = 
	{
		-- 集群中的节点集合： node name => true
		nodes = {},

		-- 本节点的共享配置（替代 skynet.getenv）
		node_configs = {},

		-- 服务的地址表
		service_config = {},

		-- 全局共享数据，支持自动更新。 name => {time=更新时间,data=数据}
		global_data = {},
	},
	--当前服务器剩余资源，当资源不足时就会向其他服务器请求资源
	resource=0,
	--by lyx:可分配的资源类型集合： restype => true
    allow_res_types = nil, -- nil 表示未限制
	--
	--本地的服务或地址 key=id value=addr
    local_service={},
	--本地服务的信息（如：类型，占用资源量等等）
    local_service_msg={},
	--代理或服务所在的node key=id value=nodeName
    service_to_nodeName = {},
	service_to_addr = {},
	
	my_id=nil,
	
    node_name=skynet.getenv "my_node_name",

    node_is_joined = false,
    start_ok = false,

	node_ready = false,
	
	_call_err_count = 0,

	_last_print_call_err = os.time(),
	
})


local LF = base.LocalFunc("node_service")


function LF.refresh_is_ready()
	LD.node_ready = LD.node_is_joined and LD.start_ok
end

function LF.query_service_node(id)
	local _node_name,addr= skynet.call(LD.node_share.service_config.center_service, "lua","query_service_node",id)
	if _node_name then
		LD.service_to_nodeName[id]=_node_name
		LD.service_to_addr[id]=addr
	end
	return LD.service_to_nodeName[id]
end
function CMD.query(id)
	if LD.local_service[id] then
		return true
	else
		return false
	end
end

function CMD.get_service_config()
	return LD.node_share.service_config
end

--hewei 4.25 test
function CMD.query_service_node(id)
	return skynet.call(LD.node_share.service_config.center_service, "lua","query_service_node",id)
end

function LF.return_call_local_service(ok,_msg,...)
	if ok then
		return _msg,...
	else
		return "call node error:" .. tostring(_msg)
	end
end

function CMD.call_local_service(_name,_cmd,...)

	return LF.return_call_local_service(pcall(skynet.call,LD.node_share.service_config[_name],"lua",_cmd,...))
end

function CMD.send_local_service(_name,_cmd,...)
	local ok ,_msg = pcall(skynet.send(LD.node_share.service_config[_name],"lua",_cmd,...))
	if ok then
		return "call node error:" .. tostring(_msg)
	end
end

function CMD.create(is_must,type,id,...)

	-- 没准备好
	if not LD.node_ready then
		return false,1002
	end

	if service_type[type] then 
		-- ###_test 目前的资源调配限制只是暂时的
		if (is_must or (not LD.allow_res_types or LD.allow_res_types[type])
			and LD.resource-service_type[type].resource>=LD.resource*0.2)
			and (not service_type[type].node_name or service_type[type].node_name==LD.node_name) then
			
			if LD.local_service[id] then
				fault("error create LD.local_service id is exist !!",id)
				return false,1066 
			end
			-- lock id
			local lock_status=skynet.call(LD.node_share.service_config.center_service, "lua","lock_service_id",id)
			if not lock_status then
				fault("error create lock id fail !!",id)
				--锁定失败
				return false,1067 
			end


			LD.resource=LD.resource-service_type[type].resource
			local _ser=skynet.newservice(type)
			print("node service created:",LD.node_name,type,_ser,...)
			LD.local_service[id]=_ser
			LD.local_service_msg[id]=type
			--local status,_ser_ret=pcall(skynet.call,_ser, "lua","start",id,LD.node_share.service_config,...)
			local status,_ser_ret=pcall(skynet.call,_ser, "lua","app_start",id,...) -- by lyx 2021-4-22
			if not status then
				fault("error create call start fail!!")
			end
			skynet.call(LD.node_share.service_config.center_service, "lua","set_service_to_nodeID",id,LD.node_name,_ser,-service_type[type].resource)
			return true,_ser_ret
		else

			-- by lyx
			-- local _node_name=skynet.call(LD.node_share.service_config.center_service, "lua","get_res",type)
			local _node_name= service_type[type].node_name or skynet.call(LD.node_share.service_config.center_service, "lua","get_res",type)
			if _node_name then
				if _node_name==LD.node_name then
					return  CMD.create(true,type,id,...)
				elseif LD.service_to_nodeName[_node_name] or LF.query_service_node(_node_name) then
					local status,s1,s2=pcall(cluster.call,_node_name,LD.service_to_addr[_node_name],"create",true,type,id,...)
					if status then
						return s1,s2
					end
					return false,1000
				end
			end
			return false,1007
		end
	end

	return false,1006
end

function CMD.destroy(id)
	if LD.local_service[id] then
		LD.local_service[id]=nil
		LD.resource=LD.resource+service_type[LD.local_service_msg[id]].resource
		skynet.call(LD.node_share.service_config.center_service, "lua","clear_service_to_nodeID",id,LD.node_name,service_type[LD.local_service_msg[id]].resource)
		LD.local_service_msg[id]=nil
		return 0
	else
		local _node_name=LD.service_to_nodeName[id] or LF.query_service_node(id)
		if _node_name then
			local _node_service=LD.service_to_addr[_node_name]
			local status,s1=pcall(cluster.call,_node_name, _node_service,"destroy",id)
			if status then
				return s1
			end
			return 1000
		else
			return 1
		end
	end 
end

-- by lyx 根据地址 destroy
-- 说明：此函数 仅在关机时使用，故不考虑性能
function CMD.destroy_byaddr( _addr)

	if _addr == skynet.self() then
		return
	end

	for _id,_address in pairs(LD.local_service) do
		if _address == _addr then
			--print("CMD.destroy_byaddr succ : ",string.format(":%08x",_addr),_id)
			CMD.destroy(_id)
			return
		end
	end

	--print("CMD.destroy_byaddr : " ,string.format(":%08x",skynet.self()))
	--dump(LD.local_service,"destroy_byaddr : " .. string.format(":%08x",_addr))
end

function CMD.sync(_node_change_list)

	for _,_data in ipairs(_node_change_list) do

		-- op=1 表示 设置， op=2 表示清除
		if _data.op == 1 then
			LD.service_to_nodeName[_data.id]=_data.node
			LD.service_to_addr[_data.id]=_data.addr
		else
			LD.service_to_nodeName[_data.id]=nil
			LD.service_to_addr[_data.id]=nil
		end
	end

end

function CMD.add_node(_node_name,_node_service_addr,_node_service_id)
	LD.service_to_nodeName[_node_name]=_node_name
	LD.service_to_addr[_node_name]=_node_service_addr

	LD.service_to_nodeName[_node_service_id]=_node_name
	LD.service_to_addr[_node_service_id]=_node_service_addr
	return 0
end

--[[ 收集本节点的服务 (by lyx 2018-4-27)
（此命令供管理控制台 即时获取服务信息 使用）
注意，只收集以下两类服务：
	1、通过 node_service 创建的服务
	2、配置 LD.node_share.service_config 中的服务地址（不包括通过 cluster.proxy 得到的服务地址）
返回数组，每项内容：
	id 		服务的唯一 id ，如果是 main 配置文件手工创建，则为名字
	res		服务所需消耗的资源，如果不是 node_service 创建的，则为 nil
	addr	服务的本地地址
	arg		服务的启动参数
--]]
function CMD.gather_services()
	local ret_data = {}

	-- 先得到所有服务信息
	local _svr2arg = {}
	local _list = skynet.call(".launcher", "lua", "LIST")
	if _list then
		for _addr,_arg in pairs(_list) do
			_svr2arg[_addr] = _arg
		end
	end

	-- 得到 node_service 创建的服务
	for _id,_addr in pairs(LD.local_service) do
		ret_data[#ret_data + 1] = {
			id = _id,
			addr = _addr,
			res = service_type[LD.local_service_msg[_id]].resource,
			arg = _svr2arg[skynet.address(_addr)],
		}
	end


	-- 得到手工启动的服务
	for _name,_addr in pairs(LD.node_share.service_config) do
		if _addr ~= skynet.self() then
			local _arg = _svr2arg[skynet.address(_addr)]

			-- 过滤掉代理服务
			if _arg then
				if not string.find(_arg,"clusterproxy") then
					ret_data[#ret_data + 1] = {
						id = _name,
						addr = _addr,
						arg = _arg,
					}
				end
			else
				ret_data[#ret_data + 1] = {
					id = _name,
					addr = _addr, 
					arg = nil,
				}
			end
		end
	end


	return ret_data
end

function CMD.addr_valid(_addr)
    local ok = pcall(skynet.call,_addr,"debug","PING")
    return ok
end

-- 退出进程 by lyx
function CMD.exit()
	os.exit()
end

function LF.init_node()
	--请求node列表
	skynet.call(LD.node_share.service_config.center_service, "lua","add_node",LD.node_name,skynet.self(),LD.my_id,LD.resource)
	local node_list=skynet.call(LD.node_share.service_config.center_service, "lua","get_node_list")
	for _node_name,_data in pairs(node_list) do
		if _node_name~=LD.node_name then
			--通知其他node
			LD.service_to_nodeName[_node_name]=_data._node_name
			LD.service_to_addr[_node_name]=_data.node_service_addr

			LD.service_to_nodeName[_data.node_service_id]=_data._node_name
			LD.service_to_addr[_data.node_service_id]=_data.node_service_addr

			cluster.call(_node_name, LD.service_to_addr[_node_name],"add_node",LD.node_name,skynet.self(),LD.my_id)
		end	
	end	

end

-- by lyx
function CMD.stop_service()
	return "free"
end
-- by lyx 为接口兼容
function CMD.set_service_name(_service_name)

end


-- by lyx ，加入创建好的服务
-- 参数 _type ： 默认为 system_service
function CMD.append(id,_ser,_type)
	LD.local_service[id]=_ser
	LD.local_service_msg[id]=_type or "system_service"
	skynet.call(LD.node_share.service_config.center_service, "lua","set_service_to_nodeID",id,LD.node_name,_ser,0)
end

-- 创建系统服务：不在资源系统的管理中
function CMD.create_system_service(_name,_launch )
	local _addr = skynet.newservice(_launch)
	skynet.call(_addr,"lua","set_service_name",_name)
	return _addr
end


-- 开始系统服务
function CMD.start_system_service(_addr)
	skynet.call(_addr,"lua","sys_start")
end

-- 节点已加入到中心
function CMD.node_joined(_nodes,_configs)

	for _name,_value in pairs(_configs) do
		if type(_value) ~= "table" then -- 不是表的 配置，设置为 skynet 配置
			local ok,err = pcall(skynet.setenv,_name,tostring(_value))
			if not ok then
				print("node_service CMD.node_joined skynet.setenv error:",_name)
			end
		end
	end

	-- 共享数据
	LD.node_share.nodes = _nodes
	LD.node_share.node_configs = _configs
	sharedata.new("node_share",LD.node_share)

	-- 处理某些参数

	LD.my_id=_configs.id
	LD.resource=_configs.resource or tonumber(skynet.getenv("resource")) or 0
	if _configs.resource_types then
		LD.allow_res_types = {}
		for _,_type in ipairs(_configs.resource_types) do
			LD.allow_res_types[_type] = true
		end
	end

	if not skynet.getenv "daemon" then
		skynet.uniqueservice("console")
	end

	local _dcp = skynet.getenv("debug_console_port")
	if _dcp then
		skynet.newservice("debug_console",tonumber(_dcp))
	end

	LD.node_is_joined = true
	LF.refresh_is_ready()
end

-- 其他节点已加入
function CMD.other_node_joined(_node_name)
	LD.node_share.nodes = LD.node_share.nodes or {}
	LD.node_share.nodes[_node_name] = true

	if LD.node_is_joined then
		sharedata.update("node_share",LD.node_share)
	end
end

-- 执行动态热修补
function CMD.perform_hotfix_file(_file,_src_code)
	if type(_file) ~= "string" then
		return false,"hot fix name error"
	end

	-- 写文件
	local ok,err = basefunc.path.write("./hotfix/" .. _file .. ".lua",_src_code,mode)
	if not ok then
		return false,err
	end

	-- 增长版本号
	local _cfg_name = tostring(_file) .. "_ver"

	local _old = tonumber(skynet.getcfg(_cfg_name)) or 0
	skynet.setcfg(_cfg_name,_old + 1)
	skynet.setcfg(tostring(_file) .. "_enable",true)

	return true,string.format("version:%s => %s",tostring(_old),tostring(skynet.getcfg(_cfg_name)))
end

-- 查看热修补信息
function CMD.query_hotfix_info(_file)
	if not _file or "" == _file then
		return "please input file !"
	end

	return string.format("\nversion=%s\nstatus=%s\n",
		skynet.getcfg(tostring(_file) .. "_ver"),
		skynet.getcfg(tostring(_file) .. "_enable"))
end

-- 打开/关闭指定的热修补
-- _enable : true/false
function CMD.enable_disable_hotfix(_file,_enable)
	if not _file or "" == _file then
		return "please input file !"
	end

	local _cfg_name = tostring(_file) .. "_enable"

	local _old = skynet.getcfg(_cfg_name) and "on" or "off"
	skynet.setcfg(_cfg_name,_enable)
	
	return string.format("status:%s => %s",tostring(_old),tostring(skynet.getcfg(_cfg_name) and "on" or "off"))
end

-- 更新配置 
function CMD.update_config(_name,_value)
	LD.node_share.node_configs[_name] = _value

	sharedata.update("node_share",LD.node_share)
end

function CMD.update_global_data(_name,_data,_time)

	LD.node_share.global_data[_name] = {
		time = _time or os.time(),
		data=_data,
	}

	sharedata.update("node_share",LD.node_share)
end

-- 将某节点上的地址转换为本地可用
function CMD.trans_service_addr(_node,_addr)
	if not _node or (_node == LD.node_name) then
		return _addr
	else
		return cluster.proxy(_node, _addr)
	end
end

-- 更新服务地址 
-- 参数 _services： 数组 {node=,addr=}
function CMD.update_services(_services)

	for _name,_service in pairs(_services) do
		LD.node_share.service_config[_name] = CMD.trans_service_addr(_service.node,_service.addr)
	end

	sharedata.update("node_share",LD.node_share)
end

-- 强制终止服务
function CMD.hot_shutdown_service(_name)

	if LD.node_share.service_config[_name] then
		skynet.kill(LD.node_share.service_config[_name])
		LD.node_share.service_config[_name] = nil

		sharedata.update("node_share",LD.node_share)
		return true
	else
		return false
	end

end

-- 查询配置
function CMD.query_config(_name)
	return LD.node_share.node_configs[_name]
end

-- 得到所有配置
function CMD.get_all_config()
	return LD.node_share.node_configs
end

-- 得到 getenv 配置
function CMD.query_env(_name)
	return skynet.getenv(_name)
end

-- 更新共享数据
function CMD.update_share(_name,_data)

	LD.node_share[_name] = _data

	sharedata.update("node_share",LD.node_share)
end


-- 参数：
--	_service_config 服务配置：每个服务的地址，传递给其它服务
function CMD.start(_service_config,_my_id)
	if _my_id then
		LD.my_id=_my_id
	end
	clusterd = skynet.uniqueservice("clusterd")

	-- node service 是自己
	_service_config.node_service = {addr = skynet.self()}

	-- 更新服务地址
	CMD.update_services(_service_config)

	LF.init_node()

	LD.start_ok = true
	LF.refresh_is_ready()

	-- 统一初始化随机数种子
	local _cfg_seed = tonumber(skynet.getenv("random_seed_factor")) or 896589
	local _seed = math.floor(_cfg_seed * os.clock() * 1000)
	math.randomseed(_seed)
end



function LF.call_error_handle(msg)
	LD._call_err_count = LD._call_err_count + 1

	-- 10 秒打印一次错误
	if LD._call_err_count == 1 or os.time() - LD._last_print_call_err > 10 then
		print(tostring(msg) .. " => error count:" .. tostring(LD._call_err_count),debug.traceback())
		LD._last_print_call_err = os.time()
	end
end

local function error_handle(msg)
	print(tostring(msg) .. ":\n" .. tostring(debug.traceback()))
	return msg
end	

--[[
main:
	local _center_service = cluster.query( "center", "center_service" )
	local _center_service_agent = cluster.proxy("center", "center_service")
	local _node_service = skynet.uniqueservice("node_service")
	skynet.call(_node_service, "lua", "start",{
													id=skynet.call(_center_service_agent, "lua", "get_node_id"),
													res=,
													,

													})
--]]

function LF.call(id,msg,sz)

  if LD.local_service[id] then
    local  _ok,_msg,_sz=xpcall(skynet.rawcall,LF.call_error_handle,LD.local_service[id], "lua",msg,sz)
    if _ok then
	  return _msg,_sz
    end
  else
    local _node_name=LD.service_to_nodeName[id] or LF.query_service_node(id)
    if _node_name then 
      local  _ok,_msg,_sz=xpcall(skynet.rawcall,LF.call_error_handle,clusterd, "lua", skynet.pack("req", _node_name,  LD.service_to_addr[id], msg, sz))
      if _ok then
        return _msg,_sz
      end
    end
  end
  return skynet.pack("CALL_FAIL")
end
skynet.register_protocol {
    name = "call",
    id = skynet.PTYPE_JY_CALL,
    unpack = function (...) return ... end,
}
skynet.register_protocol {
    name = "send",
    id = skynet.PTYPE_JY_SEND,
    unpack = function (...) return ... end,
}
local forward_map = {
  [skynet.PTYPE_JY_CALL] = skynet.PTYPE_JY_CALL,
  [skynet.PTYPE_JY_SEND] = skynet.PTYPE_JY_SEND,
  [skynet.PTYPE_RESPONSE] = skynet.PTYPE_RESPONSE,
}

local function merge_center_config(_src,_dest,_name)

	_dest[_name] = _dest[_name] or {}
	basefunc.merge(_src[_name],_dest[_name])

	-- 处理强制设为 nil 的情况
	for k,v in pairs(_dest[_name]) do
		if "__nil__" == v then
			_dest[_name][k] = nil
		end
	end
end

local function launch_center_service()
	local _center_info = skynet.getenv("center")
	if not _center_info then
		return
	end

	local _nodes_config = require(_center_info)
	
	-- 合并到基础配置：如果有的话
	local _base_center_info = skynet.getenv("base_center")
	if _base_center_info then
		local _base_config = require(_base_center_info)

		-- 定义了基础配置，则合并
		if _base_config then  

			merge_center_config(_nodes_config,_base_config,"configs")
			-- merge_center_config(_nodes_config,_base_config,"nodes")
			-- merge_center_config(_nodes_config,_base_config,"services")

			_nodes_config = _base_config
		end
	end

	local _center_service = skynet.uniqueservice("center_service")
	
	skynet.call(_center_service, "lua", "start",_nodes_config,skynet.self())
	  
end


skynet.start(function()
  skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
      local f = CMD[cmd]
	  if f then
		local ok ,err= xpcall(function(...)
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end,error_handle,...)
		if not ok then
			error(string.format("node cmd '%s' error:%s",tostring(cmd),tostring(err)))
		end
      else
        print(subcmd,...)
        error("not found cmd:"..cmd)
        assert(f)
      end
  end)
  
  -- by lyx : 注册名字，以便本节点内，用此名字调用节点服务
  skynet.register "node_service"
  cluster.register("node_service",skynet.self())

  -- 如果配置为中心，则启动
  launch_center_service()

end)

skynet.forward_type( forward_map ,function()
  skynet.dispatch("call", function (session, source, msg, sz)
    local id =skynet.get_jy_id(msg, sz)
    skynet.ret(LF.call(id,msg,sz))
  end)
  skynet.dispatch("send", function (session, source, msg, sz)
    local id =skynet.get_jy_id(msg, sz)
     if LD.local_service[id] then
        pcall(skynet.rawsend,LD.local_service[id], "lua",msg,sz)
    else
      local _node_name=LD.service_to_nodeName[id] or LF.query_service_node(id)
      if _node_name then 
    	xpcall(skynet.rawsend,LF.call_error_handle,clusterd, "lua", skynet.pack("push", _node_name, LD.service_to_addr[id] , msg, sz))
      end
    end
  end)
end)


local skynet = require "skynet_plus"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local base=require "base"
local basefunc = require "basefunc"

local filter = require "websever_service.filter"

require "printfunc"

local nodefunc = require "nodefunc"

local CMD = base.CMD
local DATA = base.DATA
local PUBLIC = base.PUBLIC

local table = table
local string = string

local mode = ...

local orgi_print = print

if mode == "agent" then

	-- 主机对象，可在服务脚本中访问
	local host = {
		CMD=CMD, -- 本服务器的命令
		service_config = nil, -- 服务配置
	}


	function CMD.start()

		local _service_config = base.service_visitor()

		host.service_config = _service_config
		DATA.service_config = _service_config
		
	end

	local function print(p1,...)
		--orgi_print("xxxxxxxxxxxxxxxxxxxxxxxx web print:",p1,...)
		--skynet.send(host.service_config.web_server_service,"lua","web_log",os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(p1) ,...) 
		record_info("web_access",p1,...)
	end

	local root_path = "./game/services/websever_service"

	-- 加载文件，返回：文件内容， 类型
	local function web_filereader(file)

		-- 只有这些文件可以被访问
		local webapi = nodefunc.get_global_config("webserver_api")

		local item = webapi[file]
		if item then

			return basefunc.path.read(root_path .. file .. (item.postfix or "")),item.type or "lweb"
		end

		return nil,404
	end

	-- 解析请求
	local function parse_request(url, method, header, body,addr)
		local path, query = urllib.parse(url)

		local request = {url=url,source=addr,method=method,header=header,body=body }
		if "GET" == method then
			request.get = urllib.parse_query(query)
		end

		print("<" .. tostring(addr) .. "> request:\n" .. basefunc.tostring(request))

		host.is_debug = skynet.getcfg("debug")

		-- 先处理过滤器（过滤器 不需要 request.post ，直接使用 body）
		local handled,code,resp = filter.handle(path,host,request,web_filereader)
		if not handled then

			if "POST" == method then
				if string.find(url,"/http_exe_lua") then -- 调试执行 lua ，不用解码
					request.post = body
				else
					request.post = urllib.parse_query(body)
				end
			end

			code,resp = httpd.parse_htmlua(path,host,request,web_filereader,skynet.getcfg("webserver_disable_cache"))
		end

		print("<" .. tostring(addr) .. "> response:" .. "code=" .. tostring(code) .. ",resp=" .. tostring(resp) .. "\n")

		if 200 == code then
			return code,resp
		elseif 600 == code then
			return parse_request(resp, method, header, body)
		else
			return code,"[file:" .. path .. "]" .. tostring(resp or "empty")
		end
	end

	local function response(fd,addr, ...)
		local ok, err = httpd.write_response(sockethelper.writefunc(fd), ...)
		if not ok then
			-- if err == sockethelper.socket_error , that means socket closed.
			print(string.format("fd = %d,addr=%s, %s", fd,tostring(addr), err))
		end
	end

	function CMD.web_request(fd,addr)

		socket.start(fd)

		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(fd), 819200)
		if code then
			if code == 200 then

				if not skynet.getcfg("is_server_launched") then
					local _allow = false
		
					local _cfg = nodefunc.get_global_config("webserver_config")
					for _,v in ipairs(_cfg.starting_white_list) do
						if string.find(url,v) then
							_allow = true
							break
						end
					end
					
					if not _allow then
						print("web server is launching ,not allow access:",url)
						response(fd,addr, 500,"web server is launching ,not allow access!")
						socket.close(fd)
						return
					end
				end		

				response(fd,addr, parse_request(url, method, header, body,addr) )
			else
				response(fd,addr, code)
			end
		else
			if url == sockethelper.socket_error then
				print("socket closed")
			else
				print(url)
			end
		end
		socket.close(fd)
	end

	-- 启动服务
	base.start_service()
else

	-- DATA.log_queue = {}
	-- DATA.log_file = nil

	-- function CMD.web_log(...)
	-- 	--orgi_print("xxxxxxxxxxxxxxxxxxxxxxxx CMD.web_log:",...)
	-- 	local _count = select("#",...)
	-- 	if _count > 0 then
	-- 		local _tlog = {...}
	-- 		local _tlog2 = {}
	-- 		for i=1,_count do
	-- 			_tlog2[i] = tostring(_tlog[i])
	-- 		end
	-- 		DATA.log_queue[#DATA.log_queue + 1] = table.concat(_tlog2,"\t",1,_count)
	-- 	end
	-- end

	--local print = CMD.web_log

	local function print(p1,...)
		--CMD.web_log(os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(p1) ,...)
		record_info("web_access",p1,...)
	end

	local webserver_port = skynet.getenv "webserver_port"
	local webserver_agent_num = skynet.getenv "webserver_agent_num"

	--处理单元实例
	local agent = {}

	function CMD.start(_service_config)

		for i= 1, webserver_agent_num do
			agent[i] = skynet.newservice(SERVICE_NAME, "agent")
			skynet.call(agent[i], "lua", "start")
		end

		local balance = 1

		print("Listen web port :"..webserver_port)
		local fd = socket.listen("0.0.0.0", webserver_port)
		socket.start(fd , function(accept_fd, addr)

			-- if "running" ~= DATA.current_service_status then
			-- 	print("websever_service will close refuse connect")
			-- 	return
			-- end

			-- if not skynet.getcfg("is_server_launched") then
			-- 	print("web server is launching ,not allow access!")
			-- 	httpd.write_response(sockethelper.writefunc(fd), addr,500)
			-- 	return
			-- end

			print(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
			skynet.send(agent[balance], "lua", "web_request", accept_fd,addr)
			balance = balance + 1
			if balance > #agent then
				balance = 1
			end
		end)
	end


	-----------------------------
	-- 日志写入功能

	-- function PUBLIC.open_log_file()

	-- 	if DATA.log_file then
	
	-- 		return DATA.log_file ~= "open error"
	
	-- 	else
	-- 		local err
	-- 		DATA.log_file,err = io.open("./logs/web_access.log","a")
	-- 		if not DATA.log_file then
	-- 			DATA.log_file = "open error"
	-- 			orgi_print(string.format("open './logs/web_access.log' error:%s!", tostring(err)))
	-- 			return false
	-- 		end
	
	-- 		return true
	-- 	end
	-- end
	
	-- function PUBLIC.flush_log()
	
	-- 	if DATA.log_file and DATA.log_file ~= "open error" then
	
	-- 		DATA.log_file:close()
	
	-- 		DATA.log_file = nil
	-- 	end
	-- end	

	-- DATA.flush_counter = 0
	-- DATA.error_data_dirty = false
	-- skynet.timer(1,function ()

	-- 	DATA.flush_counter = DATA.flush_counter + 1
	-- 	if DATA.error_data_dirty and DATA.flush_counter % 10 == 0 then
	-- 		PUBLIC.flush_log()
	-- 		DATA.error_data_dirty = false
	-- 	end
	
	-- 	if next(DATA.log_queue) and PUBLIC.open_log_file() then
	-- 		local _tmp = "\n" .. table.concat(DATA.log_queue,"\n")
	-- 		DATA.log_queue = {}
	-- 		--orgi_print("xxxxxxxxxxxxxxxxxxxxxxxx web log write:",_tmp)
	-- 		DATA.log_file:write(_tmp)
	-- 		DATA.error_data_dirty = true
	-- 	end
	-- end)

	-- 启动服务
	base.start_service()
end

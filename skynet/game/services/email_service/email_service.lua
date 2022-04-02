--
-- Author: yy
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：邮件服务
--
--[[
	
	1.所有邮件强制永久有效(valid_time = 0)
	2.超过邮箱容量(50)邮件会按时间清理最早的邮件(非立刻进行，在下一次清理时操作)
	3.有附件的邮件需要领取(阅读)后才能删除
	4.普通邮件：任何状态都不会被自动删除(除非清理)
	5.有附件的邮件：普通状态不会被自动删除，领取状态会在一段时间后自动删除(清理会自动领取后删除)
	6.阅读或领取附件后complete_time会被赋值

	7.***创建时间超过1个月的邮件直接删除(忽略附件)!!!


	=======================实现逻辑========================

	普通个人邮件：
	1.普通个人邮件的内存管理：内存有直接拿，否则从数据库拿，最多存储20000玩家的邮件，超量清理一半(按热度)。
	2.普通个人邮件在服务启动时不加载，发送个人邮件时要先加载到内存，然后才能进行进行后续的操作。
	3.对所有人的邮件会进行定时检查和清理，此时会拉起所有邮件，必须缓慢的进行，以免不重要的邮件顶掉太多内存需要的邮件
		(对所有人的邮件进行处理的时间可以放到人少的时候(每天晚上2-6点进行处理，分三天遍历完所有人的邮件))

	全服邮件：
	1.全服邮件直接全部存内存中(量不多)，不使用内存管理组件。
	3.全服邮件在服务启动时读取数据库所有邮件直接放于内存，发送邮件时直接对内存处理，数据库进行存档。
	2.用户上线后对邮件服务发送消息，服务根据用户的读取记录、邮件的适用人群来发放邮件。
	4.全服邮件限制只能读取最近一个月的全服邮件。

]]


local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
local monitor_lib = require "monitor_lib"

require "common_data_manager_lib"
require "data_func"
require "normal_enum"
require "printfunc"

local cjson = require "cjson"
cjson.encode_sparse_array(true,1,0)


local DATA = base.DATA
local CMD = base.CMD
local PUBLIC=base.PUBLIC

DATA.service_config = nil

--玩家邮件持有最大数量
DATA.EMAIL_MAX_NUM = 50

--附件领取后的删除延迟
DATA.ATTACHMENT_DELETE_DELAY = 1*24*3600

-- 邮件强制删除的时间
DATA.EMAIL_FORCE_DELETE_TIME = 30*24*3600

-- 可以领取最近多久的全服邮件
DATA.EVERY_EMAILS_TIME_LIMIT = 7*24*3600

-- 邮件内存池大小(按人头算)
DATA.EMAIL_POOL_SIZE = 20000

-- 邮件 ID
DATA.email_max_id = 0

-- 玩家邮件列表 [receiver] => ids
DATA.email_lists = {}

-- 邮件数据 email_id => data(解析后的lua表)
DATA.email_datas = {}

-- 内存管理器
DATA.data_manager = {}


DATA.every_emails = {}
DATA.player_every_email = {}
DATA.player_every_email_lock = {}

-- 定时更新的进行中的数据和参数
DATA.update_everyone_email_data = {

	config = {
		exec_time = {2,6},	--执行的时间范围(晚上2点-6点)[必须要配置凌晨后]
		batch_num = 3,		--分批处理的批次(分几批处理完所有任务)
	},
	
	execing = false, 	--当前是否正在执行中
	exec_batch = 1, 	--当前进行到第几批了


	exec_index = 1,		--当前执行进行到的位置
	exec_data = nil,	--执行的数据

}


-- 邮件发送队列
DATA.send_email_list = {}


--解析邮件数据(JSON)
function PUBLIC.parse_email_data(email_data)

	local ok, data = xpcall(function ()
			if email_data == "" 
				or email_data == "{}" 
				or email_data == "nil" 
				or email_data == "null" then
				return {}
			end
			local ret = cjson.decode(email_data)
			if type(ret) ~= 'table' then
				print("parse_email_data error 1: ",code)
				ret = {}
			end
			return ret
		end,
		function (error)
			local errStr = "parse_email_data error 2: "..email_data
			print(errStr)
			print(error)
		end)

	if not ok then
		data = {}
	end

	return data or {},ok
end

-- 判断一个玩家是否可以领取一个全服邮件
function PUBLIC.is_every_email_receiver(player_id,every_email)

	local ct = os.time()
	-- 这个全服邮件太过久远，不能领取
	if ct > every_email.create_time + DATA.EVERY_EMAILS_TIME_LIMIT then
		return false
	end

	--------------------------------------- 接收类型判断 ---------------------------------------

	-- 渠道 判断
	local ok = PUBLIC.email_check_player_info(player_id, every_email.market_channel, every_email.platform, every_email.os)
	if ok ~= 0 then
		return false
	end

	if every_email.receive_type == "everyone" then
		return true
	end

	-- vip 判断
	if every_email.receive_type == "vip" then

		local vip_info = skynet.call( DATA.service_config.new_vip_center_service , "lua" 
													, "query_player_vip_base_info" , player_id )
		if type(every_email.receive_value_hash) == "table" 
				and every_email.receive_value_hash[ vip_info.vip_level ] then
			
			return true

		end

	end

	--------------------------------------- 接收类型判断 ---------------------------------------

	return false
end


-- 发送范围型邮件
function PUBLIC.send_every_email(_email)

	local every_email_id = #DATA.every_emails + 1
	DATA.every_emails[every_email_id] = 
	{
		id = every_email_id,
		type = _email.email.type,
		title = _email.email.title,
		sender = _email.email.sender,
		valid_time = 0,--_email.email.valid_time or 0, 强制永久有效
		create_time = os.time(),
		data = _email.email.data,
		receive_type = _email.receive_type,
		receive_value = _email.receive_value,
		market_channel = _email.market_channel,
		platform = _email.platform,
		os = _email.os,
	}

	-- hash data
	if next( DATA.every_emails[every_email_id].receive_value ) then
		DATA.every_emails[every_email_id].receive_value_hash = {}
		for i,v in ipairs(DATA.every_emails[every_email_id].receive_value) do
			DATA.every_emails[every_email_id].receive_value_hash[v]=true
		end
	end

	-- 临时转换为字符串数据存入数据库
	local every_email = DATA.every_emails[every_email_id]

	local ori_email_data = every_email.data
	every_email.data = cjson.encode(ori_email_data)

	local ori_receive_value = every_email.receive_value
	every_email.receive_value = cjson.encode(ori_receive_value)

	skynet.send(DATA.service_config.data_service,"lua","insert_every_email",every_email)

	every_email.data = ori_email_data
	every_email.receive_value = ori_receive_value

	-- 异步慢慢通知
	skynet.fork(function ()

		-- 所有在线的人更新一下全服邮件
		local player_list = skynet.call(DATA.service_config.data_service,"lua"
												,"select_players_list",1,0,true)


		for i,player_id in ipairs(player_list) do

			CMD.update_player_every_email(player_id)
			skynet.sleep(1)

		end

	end)

end


--加载数据
function PUBLIC.load_data(_player_id)
	
	local emails = skynet.call(DATA.service_config.data_service,"lua","get_player_emails",_player_id)
	
	-- 构建玩家的邮件hash
	local email_hash = {}
	
	-- 构建玩家的邮件列表
	DATA.email_lists[_player_id] = {}

	for i,email in ipairs(emails) do

		email_hash[email.id] = email

		table.insert(DATA.email_lists[_player_id],email.id)

		-- 构建邮件的数据
		if email.data and type(email.data) == "string" then
			DATA.email_datas[email.id] = PUBLIC.parse_email_data(email.data)
		end

	end

	return email_hash
end


--卸载数据
function PUBLIC.recover_data(_player_id,_email_hash)
	
	-- 卸载玩家的邮件列表数据
	DATA.email_lists[_player_id] = nil

	-- 卸载玩家邮件的数据
	for email_id,email in pairs(_email_hash) do
		DATA.email_datas[email_id] = nil
	end

end


function PUBLIC.init_data()

	DATA.email_max_id = skynet.call(DATA.service_config.data_service,"lua","get_email_max_id")
	
	-- 这个邮件的id一定是顺序的数组ID即为顺序
	DATA.every_emails = skynet.call(DATA.service_config.data_service,"lua","get_every_emails")
	for i,ee in ipairs(DATA.every_emails) do
		ee.data = PUBLIC.parse_email_data(ee.data)
		ee.receive_value = PUBLIC.parse_email_data(ee.receive_value)

		-- hash data
		if type(ee.receive_value) == 'table' and next( ee.receive_value ) then
			ee.receive_value_hash = {}
			for vi,vv in ipairs(ee.receive_value) do
				ee.receive_value_hash[vv]=true
			end
		end

	end


	DATA.data_manager = basefunc.server_class.data_manager_cls.new( 
							{ 
								load_data = 
									function ( _player_id )
										return PUBLIC.load_data( _player_id )
									end ,
								recover_data = 
									function (_player_id,_email_hash)
										return PUBLIC.recover_data(_player_id,_email_hash)
									end ,
							}
							, DATA.EMAIL_POOL_SIZE )


	-- 注册玩家登陆消息
	skynet.send(DATA.service_config.msg_notification_center_service,"lua", "add_msg_listener" , "logined" ,{
			msg_tag = "every_email",
			node = skynet.getenv("my_node_name"),
			addr = skynet.self(),
			cmd = "update_player_every_email" , 
		})

end


--更新玩家邮件id列表
function PUBLIC.update_email_lists(player_id,emails)

	DATA.email_lists[player_id]={}

	for email_id,email in pairs(emails) do
		table.insert(DATA.email_lists[player_id],email_id)
	end

end


function PUBLIC.check_have_attachment(email_id)
	
	--有财产型附件
	local email_data = DATA.email_datas[email_id]
	if email_data and next(email_data) then
		for key,value in pairs(email_data) do
			if basefunc.is_asset(key) or basefunc.is_object_asset(key) then
				return true
			end
		end
	end

	return false
end


-- 阅读邮件
function PUBLIC.read_email(player_id,email_id)

	local emails = DATA.data_manager:get_data(player_id)

	local email = emails[email_id]

	if email.state == "normal" then
		if email.valid_time > 0 
			and email.valid_time < os.time() then
			return 2302
		end

		--有财产型附件 不能直接阅读
		if PUBLIC.check_have_attachment(email_id) then
			return 2308
		end

		local time = os.time()
		email.state = "read"
		email.complete_time = time
		
		local queue_type,queue_id = skynet.call(DATA.service_config.data_service,"lua",
													"set_email_state_and_complete",email_id,"read",time)

		DATA.data_manager:add_or_update_data(player_id , emails , queue_type , queue_id)

		return 0
	else

		if email.state == "read" then
			return 2307
		end

		return 2303
	end

end



DATA.statistics_asset_key = {
	jing_bi = true,
}

--[[
	-- 发送邮件的统计资产
]]
function PUBLIC.send_email_statistics_asset(_player_id,_email_data)
	
	if _email_data and next(_email_data) then
		
		local jb = 0
		for k,v in pairs(DATA.statistics_asset_key) do
				
			if _email_data[k] then

				jb = jb + basefunc.trans_asset_to_jingbi(k,_email_data[k])

			end

		end

		if jb > 0 then
			skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , 
					        { 
					        	name = "send_email_statistics_asset" ,
					        	send_filter = { player_id = _player_id } 
					        } , 
					        _player_id , jb)
		end

	end

end

--[[
	-- 领取邮件的附件 统计资产
]]
function PUBLIC.get_attachment_statistics_asset(_player_id,_asset_data)
	
	local jb = 0
	for i,as in ipairs(_asset_data) do
				
		if DATA.statistics_asset_key[as.asset_type] then

			jb = jb + basefunc.trans_asset_to_jingbi(as.asset_type,as.value)

		end

	end

	if jb > 0 then
		skynet.send(DATA.service_config.msg_notification_center_service,"lua", "trigger_msg" , 
				        { 
				        	name = "get_email_statistics_asset" ,
				        	send_filter = { player_id = _player_id } 
				        } , 
				        _player_id , jb)
	end

end



--[[
	not_valid_time - 不验证时间

	领取成功后就删除
]]
function PUBLIC.get_attachment(player_id,email_id,not_valid_time)
	
	local email_data = DATA.email_datas[email_id]
	if not email_data or not next(email_data) then
		return 2304
	end

	local emails = DATA.data_manager:get_data(player_id)
	local email = emails[email_id]

	if email.state == "read" then
		return 2305
	elseif email.state ~= "normal" then
		return 2303
	end

	local time = os.time()

	if not not_valid_time then

		if email.valid_time > 0 
			and email.valid_time < time then
			return 2302
		end

	end

	local asset_data = {}
	for key,value in pairs(email_data) do

		if basefunc.is_asset(key) then

			asset_data[#asset_data+1]={asset_type=key,value=value}

		elseif basefunc.is_object_asset(key) then

			if type(value) == "table" then

				if value.attribute then

					-- valid_time 进行初始化调整
					if value.attribute.valid_time then
						value.attribute.valid_time = time + value.attribute.valid_time
					end

					asset_data[#asset_data+1]=
					{
						asset_type = key,
						num = value.num,
						attribute = value.attribute,
					}

				end

			end

		end
	end

	if #asset_data > 0 then

		local asset_change_data = DATA.email_datas[email_id].asset_change_data
		local change_type = nil
		local change_id = nil
		if asset_change_data then
			change_type = asset_change_data.change_type
			change_id = asset_change_data.change_id
		end

		--向数据库进行修改，并且向玩家发送消息
		skynet.send(DATA.service_config.data_service,"lua","multi_change_asset_and_sendMsg"
									,player_id
									,asset_data
									,change_type
									,change_id
									,"email",email_id)

		PUBLIC.get_attachment_statistics_asset(player_id,asset_data)
	else
		return 2304
	end


	-- 进行阅读
	email.state = "read"
	email.complete_time = time
	
	local queue_type,queue_id = skynet.call(DATA.service_config.data_service,"lua",
												"set_email_state_and_complete",email_id,"read",time)

	DATA.data_manager:add_or_update_data(player_id , emails , queue_type , queue_id)

	return 0
end


-- 删除邮件
function PUBLIC.delete_email(player_id,email_id)

	local emails = DATA.data_manager:get_data(player_id)
	local email = emails[email_id]

	if not email then
		return 0
	end

	--已读或者过期可以删除
	if email.state == "read" or email.valid_time < os.time() then

		--未读邮件进行一次领取奖励
		if email.state == "normal" then
			PUBLIC.get_attachment(player_id,email_id,true)
		end

		emails[email_id] = nil
		DATA.email_datas[email_id] = nil
		PUBLIC.update_email_lists(player_id,emails)

		local queue_type,queue_id = skynet.call(DATA.service_config.data_service,"lua","delete_email",email_id)
		DATA.data_manager:add_or_update_data(player_id , emails , queue_type , queue_id)

		return 0
	else

		if email.state == "normal" then
			return 2306
		end

		return 2303
	end
end



--[[检测删除玩家溢出的邮件 
	每次玩家获取邮件IDs的时候进行一次
	PUBLIC.update 中需要进行
]]
function PUBLIC.chk_delete_overflow_emails(player_id)

	if DATA.EMAIL_MAX_NUM < 1 then
		return
	end

	local num = CMD.get_email_count(player_id)
	if num > DATA.EMAIL_MAX_NUM then

		local n = num - DATA.EMAIL_MAX_NUM
		local email_ids = DATA.email_lists[player_id]

		table.sort( email_ids, function (a,b)
			return a<b
		end )

		local emails = DATA.data_manager:get_data(player_id)

		for i=1,n do
			local email_id = email_ids[i]
			local email = emails[email_id]

			if email.state == "normal" then
				--领取附件
				PUBLIC.get_attachment(player_id,email_id,true)
			end

			emails[email_id] = nil
			DATA.email_datas[email_id] = nil
			
			local queue_type,queue_id = skynet.call(DATA.service_config.data_service,"lua","delete_email",email_id,"sys")
			DATA.data_manager:add_or_update_data(player_id , emails , queue_type , queue_id)

		end

		PUBLIC.update_email_lists(player_id,emails)

	end

end


-- 对所有人的邮件进行遍历处理 
function PUBLIC.update_everyone_email()
	
	-- 已经在运行了就不管了，否则检测是否可以开始运行
	if DATA.update_everyone_email_data.execing then
		return
	end

	local ct = os.time()
	local ch = tonumber(os.date("%H",ct))
	local el = DATA.update_everyone_email_data.config.exec_time[1]
	local er = DATA.update_everyone_email_data.config.exec_time[2]
	if ch >= el and ch < er then
		DATA.update_everyone_email_data.execing = true
	else
		return
	end
	
	-- 当前日期
	local exec_date = tonumber(os.date("%Y%m%d",ct))

	-- 分批处理的批次
	local bn = DATA.update_everyone_email_data.config.batch_num

	-- 玩家列表
	local player_list = DATA.update_everyone_email_data.exec_data
	if not player_list then
		player_list = skynet.call(DATA.service_config.data_service,"lua"
											,"select_players_list",nil,0,true)
		DATA.update_everyone_email_data.exec_data = player_list
	end

	--根据配置时间计算速度和个数,执行完个数就结束(可能会和预期完成时间有偏差,通常会晚一点)
	local player_num = #player_list
	local exec_index = DATA.update_everyone_email_data.exec_index
	local exec_batch = DATA.update_everyone_email_data.exec_batch
	local pb = (bn-exec_batch+1)
	if pb <= 0 then
		pb = 1
	end
	local end_exec_index = math.ceil((player_num-exec_index)/pb)+exec_index

	local pb = (end_exec_index-exec_index+1)
	if pb <= 0 then
		pb = 1
	end
	local speed = ((er-el)*3600)/pb

	local delay_time = math.ceil(speed*100)

	print(string.format("begin_update_everyone_email:[dt:%s,index:%s,end_exec_index:%s,exec_batch:%s,player_num:%s]"
							,delay_time
							,exec_index
							,end_exec_index
							,exec_batch
							,player_num))


	while true do

		local player_id = player_list[DATA.update_everyone_email_data.exec_index]

		if player_id then

			ct = os.time()

			local emails = DATA.data_manager:get_data(player_id)

			for email_id,email in pairs(emails) do

				local is_need_delete = false
				--只要过期就删除
				if email.valid_time > 0 and email.valid_time<ct then
					
					PUBLIC.get_attachment(player_id,email_id,true)
					
					is_need_delete = true

				-- 领取过附件的邮件删除 
				elseif email.state == "read" 
						and email.complete_time + DATA.ATTACHMENT_DELETE_DELAY < ct
						and PUBLIC.check_have_attachment(email_id) then
				
					is_need_delete = true

				-- 创建时间超过1个月的邮件直接删除
				elseif email.create_time + DATA.EMAIL_FORCE_DELETE_TIME < ct then
					is_need_delete = true
				end

				if is_need_delete then

					emails[email_id] = nil
					DATA.email_datas[email_id] = nil
					
					local queue_type,queue_id = skynet.call(DATA.service_config.data_service,"lua","delete_email",email_id,"sys")
					DATA.data_manager:add_or_update_data(player_id , emails , queue_type , queue_id)
					PUBLIC.update_email_lists(player_id,emails)

					skynet.sleep(0)

				end

			end

			--清理离线玩家的邮件
			PUBLIC.chk_delete_overflow_emails(player_id)

			skynet.sleep(delay_time)

		end

		skynet.sleep(0)

		DATA.update_everyone_email_data.exec_index = DATA.update_everyone_email_data.exec_index + 1
		if DATA.update_everyone_email_data.exec_index > end_exec_index then
			break
		end

	end



	DATA.update_everyone_email_data.exec_batch = DATA.update_everyone_email_data.exec_batch + 1

	-- 所有批次都完了(重置数据)
	if DATA.update_everyone_email_data.exec_batch > bn then

		DATA.update_everyone_email_data.exec_batch = 1
		DATA.update_everyone_email_data.exec_index = 1

		DATA.update_everyone_email_data.exec_data = nil

	end


	-- 讲道理此时肯定超过了处理时间，以防万一检查一下，避免今天执行下一批
	-- 容错处理，如果都下一天了可以出来了(理论上执行的操作不可能延误到下一天的执行时间)
	while true do
		
		local ct = os.time()
		local cur_date = tonumber(os.date("%Y%m%d",ct))
		local ch = tonumber(os.date("%H",ct))

		if (ch < el or ch >= er) or exec_date ~= cur_date then
			break
		end

		skynet.sleep(100)
	end

	DATA.update_everyone_email_data.execing = false

	print("end_update_everyone_email")

end



local osh = {
	android = "Android",
	ios = "iOS",
}
function PUBLIC.email_check_player_info(_player_id, _market_channel, _platform, _os)
	local player_data = skynet.call(DATA.service_config.data_service,"lua","get_player_info",_player_id,"player_register")

	if _market_channel and player_data.market_channel ~= _market_channel then
		return 2157
	end

	if _platform and player_data.platform ~= _platform then
		return 1072
	end

	if _os and _os ~= 'all' then
		if player_data.register_os and osh[_os] then
			local ok = string.find( player_data.register_os , osh[_os] )
			if not ok then
				return 1004
			end
		end
	end

	return 0
end


function PUBLIC.update(dt)
	
	skynet.fork(PUBLIC.update_everyone_email)

end


--[[外部发送邮件
	data={
		players={1,2,3}
		email={
			data -- 选填(默认{}) 这里是字符串形式的
		}
	}
]]
function CMD.external_send_email(data,opt_admin,reason)
	
	if type(data)~="table" or type(data.email)~="table" then
		print("external_send_email 1001.11 data error:",type(data),data and type(data.email))
		return 1001
	end

	if type(opt_admin)~="string" or string.len(opt_admin)<1 or string.len(opt_admin)>50 then
		print("external_send_email 1001.12 opt_admin error:",type(opt_admin),opt_admin)
		return 1001
	end

	if type(reason)~="string" or string.len(reason)<1 or string.len(reason)>5000 then
		print("external_send_email 1001.13 reason error:",type(reason),reason)
		return 1001
	end

    local rt = {
        -- players = true,
        everyone = true,
        vip = true,
    }
	if rt[data.receive_type] then

		local email_data
		if type(data.email.data)=="string" then
			local data_ok
			email_data,data_ok = PUBLIC.parse_email_data(data.email.data)

			if not data_ok then
				print("external_send_email 1001.14 parse_email_data 1 error:",type(data_ok),data_ok)
				return 1001
			end
		end

		email_data.asset_change_data = {change_type=ASSET_CHANGE_TYPE.MANUAL_SEND,change_id=0}
		
		local emd = basefunc.deepcopy(data)
		emd.email.data = email_data
		emd.receive_type = data.receive_type
		emd.receive_value = data.receive_value
		emd.market_channel = data.market_channel
		emd.platform = data.platform
		emd.os = data.os
		skynet.send(DATA.service_config.data_service,"lua","insert_email_admin_opt_log"
								,"all",cjson.encode(emd),opt_admin,reason)

		PUBLIC.send_every_email(emd)

		local asset_sum = 0
		for key,value in pairs(email_data) do
			if basefunc.is_asset(key) then
				asset_sum = asset_sum + basefunc.trans_asset_to_jingbi( key , value )
			end
		end

		if data.receive_type == "vip" then
			monitor_lib.add_data("email_asset_vip",asset_sum)
		elseif data.receive_type == "everyone" then
			monitor_lib.add_data("email_asset_every",asset_sum)
		else
			print("send email error,unknow type:",data.receive_type)
		end

		return 0

	elseif data.receive_type == "players" then

		local players = data.receive_value

		local ok=skynet.call(DATA.service_config.data_service,"lua","is_player_exists",players)
		if not ok then
			return 2251
		end

		local email_data
		if type(data.email.data)=="string" then
			local data_ok
			email_data,data_ok = PUBLIC.parse_email_data(data.email.data)

			if not data_ok then
				print("external_send_email 1001.15 parse_email_data 2 error:",type(data_ok),data_ok)
				return 1001
			end
		end
		
		email_data.asset_change_data = {change_type=ASSET_CHANGE_TYPE.MANUAL_SEND,change_id=0}

		local error_code = 0
		for i,player_id in ipairs(players) do
			data.email.receiver = player_id
			data.email.data = email_data
			if data.uuids and type(data.uuids) == "table" and next(data.uuids) then
				data.email.uuid = data.uuids[i]
			end
			local em = basefunc.deepcopy(data.email)
			error_code = CMD.send_email(em)

			skynet.send(DATA.service_config.data_service,"lua","insert_email_admin_opt_log"
							,player_id,cjson.encode(data),opt_admin,reason)

			if error_code ~= 0 then
				break
			end
		end

		local asset_sum = 0
		for key,value in pairs(email_data) do
			if basefunc.is_asset(key) then
				asset_sum = asset_sum + basefunc.trans_asset_to_jingbi( key , value )
			end
		end
		
		monitor_lib.add_data("email_asset",asset_sum * #players)

		return error_code
	else
		dump(data,"external_send_email_data")
		print("external_send_email 1001.16 data.players 3 error:",type(data))
		return 1001
	end

end



function PUBLIC.exec_send_email(email)
	
	email.state = email.state or "normal"
	email.valid_time = 0 --email.valid_time or 0 强制永久有效
	email.data = email.data or {}

	email.create_time=os.time()
	email.complete_time=0
	
	DATA.email_max_id = DATA.email_max_id + 1
	email.id=DATA.email_max_id

	local ori_email_data = email.data
	-- 拉取这个人的数据
	local emails = DATA.data_manager:get_data(email.receiver)

	--存入数据库
	email.data=cjson.encode(ori_email_data)
	local queue_type,queue_id = skynet.call(DATA.service_config.data_service,"lua","insert_email",email)

	emails[email.id] = email
	DATA.email_datas[email.id]=ori_email_data
	DATA.data_manager:add_or_update_data(email.receiver , emails , queue_type , queue_id)
	
	table.insert(DATA.email_lists[email.receiver],email.id)

	--通知收件人
	nodefunc.send(email.receiver,"notify_new_email_msg",email.id)

	PUBLIC.send_email_statistics_asset(email.receiver,ori_email_data)

end

function PUBLIC.exec_send_email_list()

	while true do

		local email = DATA.send_email_list[1]

		if email then

			PUBLIC.exec_send_email(email)

			table.remove(DATA.send_email_list,1)

		else
			return
		end

	end

end

--[[发送邮件
	type
		"sys_welcome" -- 系统欢迎邮件
		"native" -- 原生邮件 邮件内容在data中的content中
	type
	title
	sender
	receiver
	state -- 选填(默认"normal")
	valid_time -- 选填(默认0)大于0才有效
	data -- 选填(默认{})
]]
function CMD.send_email(email)

	if not email 
		or not email.type
		or not email.sender
		or not email.receiver
		then 
			dump(email,"send_email error 1001.1:")
			--不合法
			return 1001
	end
	
	if type(email.type)~="string"
		or type(email.sender)~="string"
		or (email.title and type(email.title)~="string")
		or (email.data and type(email.data)~="table")
			then
			dump(email,"send_email error 1001.2:")
			return 1001
	end

	table.insert(DATA.send_email_list,email)

	if #DATA.send_email_list < 2 then
		skynet.fork(PUBLIC.exec_send_email_list)
	end

	return 0
end


-- 玩家获取邮件id列表
function CMD.get_email_list(player_id)

	if not DATA.email_lists[player_id] then
		DATA.data_manager:get_data(player_id)
	end

	return DATA.email_lists[player_id]
end


-- 玩家获取邮件数量
function CMD.get_email_count(player_id)

	if not DATA.email_lists[player_id] then
		DATA.data_manager:get_data(player_id)
	end

	return #DATA.email_lists[player_id]

end


-- 玩家获取邮件
function CMD.get_email(player_id,email_id)

	local emails = DATA.data_manager:get_data(player_id)

	local email = emails[email_id]
	
	if email then
		return 0,email
	else
		return 2301
	end

end


-- 玩家获取所有邮件
function CMD.get_all_email(player_id)

	local emails = DATA.data_manager:get_data(player_id)

	if emails then
		return 0,emails
	else
		return 2301
	end

end


--对邮件进行操作
function CMD.opt_email(player_id,email_id,opt)

	local emails = DATA.data_manager:get_data(player_id)

	local email = emails[email_id]
	if not email then
		return 2301
	end

	if opt == "read" then
		return PUBLIC.read_email(player_id,email_id)
	elseif opt == "delete" then
		return PUBLIC.delete_email(player_id,email_id)
	else
		return 1001
	end

end


--获取一个邮件的附件
function CMD.get_email_attachment(player_id,email_id)
	
	local emails = DATA.data_manager:get_data(player_id)

	local email = emails[email_id]
	if not email then
		return 2301
	end

	local result = PUBLIC.get_attachment(player_id,email_id)

	return result

end


function CMD.get_all_email_attachment(player_id)

	if CMD.get_email_count(player_id) < 1 then
		return 0,{}
	end

	local email_ids = {}
	for i,email_id in ipairs(DATA.email_lists[player_id]) do
		if PUBLIC.get_attachment(player_id,email_id) == 0 then
			email_ids[#email_ids+1]=email_id
		end
	end

	return 0,email_ids
end


-- 更新一次玩家的全服邮件
function CMD.update_player_every_email(player_id)
	
	-- 真人才处理
	if not basefunc.is_real_player(player_id) then
		return
	end

	if DATA.player_every_email_lock[player_id] then
		return
	end

	DATA.player_every_email_lock[player_id] = true

	local led = DATA.player_every_email[player_id]
	if not led then
		local pd = skynet.call(DATA.service_config.data_service,"lua","get_player_every_emails"
													,player_id)
		if pd then
			DATA.player_every_email[player_id] = pd.last_email_id
		else
			
			-- 如果没有数据，那么就当他已经领取过所有的全服邮件了
			local eed = #DATA.every_emails
			DATA.player_every_email[player_id] = eed
			skynet.send(DATA.service_config.data_service,"lua","update_player_every_emails",player_id,eed)
			
		end
		led = DATA.player_every_email[player_id]
	end

	-- 当前全服邮件的最新id
	local eed = #DATA.every_emails

	-- 有可能需要的全服邮件
	if led < eed then

		for i=led+1,eed do
			
			local every_email = DATA.every_emails[i]
			if every_email and PUBLIC.is_every_email_receiver(player_id,every_email) then
				local e = {
					receiver = player_id,
					type = every_email.type,
					title = every_email.title,
					sender = every_email.sender,
					data = every_email.data,
					valid_time = every_email.valid_time,
				}
				CMD.send_email(e)

			end

		end
		
		DATA.player_every_email[player_id] = eed
		skynet.send(DATA.service_config.data_service,"lua","update_player_every_emails",player_id,eed)

	end


	DATA.player_every_email_lock[player_id] = nil

end


-- 检查是否可以停止服务
function base.PUBLIC.try_stop_service(_count,_time)

	-- 还有 执行，则不能结束
	if DATA.send_everyone_email_busy then
		return "wait","send_everyone_email_busy"
	end

	return "stop"
end

-- 用于 调试时 直接调用
function CMD.send_asset_email(_players,_assets,_title,_content,_op_user)
	if not _players or not _players[1] or not next(_assets) then
		return "param error!"
	end

	local _email = {
		type = "native",
		receiver = nil,
		title = _title,
		sender = _op_user or "系统",
		data={ 
				content = _content,
				asset_change_data = {
					change_type = "system send_asset_email",
					change_id = 0,
				},
			}
	}

	for k,v in pairs(_assets) do
		if math.abs(math.floor(v+0.5) - v) <= 0.00000001 then
			v = math.floor(v+0.5)
		end

		_email.data[k] = v
	end

	for _,v in ipairs(_players) do
		local _e = basefunc.deepcopy(_email)
		_e.receiver = v
		CMD.send_email(_e)
	end

	return "ok"
end


function base.CMD.start(_service_config)
	DATA.service_config = _service_config

	PUBLIC.init_data()

	skynet.timer(60,function ( ... )
		PUBLIC.update()
	end)

end

-- 启动服务
base.start_service()

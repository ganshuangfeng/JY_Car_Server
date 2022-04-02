--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 启动文件
--

local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "printfunc"


skynet.start(function()
	
	-- 数据测试
	--local _pai_data = require("ddz_ctor_pai_service.ddz_fapai_data")
	-- local _pai_data = require("ddz_ctor_pai_service.ddz_fapai_data_total")
	-- dump(_pai_data,"xxxxxxxxxxxxxxxx loaded data:")

	-- require("test").main()
	-- skynet.sleep(900000)

	cluster.open(skynet.getenv "my_node_name")

	skynet.uniqueservice("node_service")

	skynet.exit()
end)

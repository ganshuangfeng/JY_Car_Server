--
-- 作者: lyx
-- Date: 2018/3/10
-- Time: 14:48
-- 启动文件
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"


skynet.start(function()

	-- require("test").main()
	-- skynet.sleep(300000)

	cluster.open(skynet.getenv "my_node_name")
	skynet.uniqueservice("node_service")

	-- skynet.timer(10,function()

	-- 	local ser = skynet.newservice("danren_match_service/danren_match_service")
	-- 	skynet.call(ser,"lua","start","fffxxxxxxtest")

		
	-- 	skynet.exit()
	-- end)

end)

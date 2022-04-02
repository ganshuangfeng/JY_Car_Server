--require "ddz_tuoguan.test.test_pai_data"
 
local skynet = require "skynet_plus"
skynet.getcfg = skynet.getenv
 -- require "pdk_tuoguan.test.test_chupai_passive"
 require "pdk_tuoguan.test.test_chupai"

 os.exit(1)

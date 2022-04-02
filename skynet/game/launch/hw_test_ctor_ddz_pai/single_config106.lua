include "../common/config"

harbor = 0

luaservice = luaservice .. "./test/?.lua;"

cluster = "./game/launch/" .. _dir_names[1] .. "/clustername.lua"

start = _dir_names[1] .. "/single_main"	-- main script

--logger = "./logs/ddz_ctor_node_106.log"
--daemon = "./logs/ddz_ctor_node_106.pid"

debug_file = "./debug_ddz_ctor_node_106.log"
debug_file_size = 10	-- 日志文件大小（单位：MB）：超过此大小即分文件

start = _dir_names[1] .. "/single_main"	-- main script

my_node_name="node_106"

strict_transfer=0

thread = 4

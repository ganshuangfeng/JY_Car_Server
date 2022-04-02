include "../common/config"
cluster = "./game/launch/" .. _dir_names[1] .. "/clustername.lua"

start = _dir_names[1] .. "/main"	-- main script

logger = "./logs/lyx_test3_gate.log"
daemon = "./logs/lyx_test3_gate.pid"

debug_file = "./debug_lyx_test3_gate.log"
debug_file_size = 100	-- 日志文件大小（单位：MB）：超过此大小即分文件

my_node_name="gate"

thread = 8

strict_transfer=0

-- 注意：配置了此项，即为中心服务器，集群中仅允许一个中心服务器！
base_center="./game/launch/base_center"
center = "./game/launch/" .. _dir_names[1] .. "/center"

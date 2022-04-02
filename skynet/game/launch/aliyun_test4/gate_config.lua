include "../common/config"
cluster = "./game/launch/" .. _dir_names[1] .. "/clustername.lua"

start = _dir_names[1] .. "/main"	-- main script

logger = "./logs/aliyun_test4_gate.log"
daemon = "./logs/aliyun_test4_gate.pid"

debug_file = "./debug_aliyun_test4_gate.log"
debug_file_size = 100	-- 日志文件大小（单位：MB）：超过此大小即分文件

my_node_name="gate"

thread = 8

strict_transfer=0

random_seed_factor = 2746849846
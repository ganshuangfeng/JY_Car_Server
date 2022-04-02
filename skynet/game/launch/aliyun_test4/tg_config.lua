include "../common/config"
cluster = "./game/launch/" .. _dir_names[1] .. "/clustername.lua"

start = _dir_names[1] .. "/tg_main"	-- main script

logger = "./logs/aliyun_test4_tg.log"
daemon = "./logs/aliyun_test4_tg.pid"

debug_file = "./debug_aliyun_test4_tg.log"
debug_file_size = 100	-- 日志文件大小（单位：MB）：超过此大小即分文件

my_node_name="tg"

thread = 1

resource = 500000

strict_transfer=0

random_seed_factor = 8794839
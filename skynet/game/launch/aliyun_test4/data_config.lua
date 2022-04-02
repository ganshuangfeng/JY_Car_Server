include "../common/config"
cluster = "./game/launch/" .. _dir_names[1] .. "/clustername.lua"

start = _dir_names[1] .. "/main"	-- main script

logger = "./logs/aliyun_test4_data.log"
daemon = "./logs/aliyun_test4_data.pid"

debug_file = "./debug_aliyun_test4_data.log"
debug_file_size = 100	-- 日志文件大小（单位：MB）：超过此大小即分文件

my_node_name="data"

strict_transfer=1

thread = 8

data_man_cache_size = 2
data_man_delay_time = 0

-- 注意：配置了此项，即为中心服务器，集群中仅允许一个中心服务器！
base_center="./game/launch/base_center"
center = "./game/launch/" .. _dir_names[1] .. "/center"

random_seed_factor = 877355
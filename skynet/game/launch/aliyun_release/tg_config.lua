include "../common/config"
cluster = "./game/launch/" .. _dir_names[1] .. "/clustername.lua"

start = _dir_names[1] .. "/tg_main"	-- main script

logger = "./logs/aliyun_release_tg.log"
daemon = "./logs/aliyun_release_tg.pid"

debug_file = "./debug_aliyun_release_tg.log"

my_node_name="tg"

thread = 8

resource = 50000

strict_transfer=0

block_connect_ip_1 = "172.18.107.238"
block_connect_port_1 = 4704

random_seed_factor = 986757+98
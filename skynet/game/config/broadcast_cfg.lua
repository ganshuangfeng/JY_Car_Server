return	 {
		--- 每分钟广播最大值
		per_minute_max_count = 750,
		--- 广播时间间隔
		braodcast_interval = 2,
		--- 类型每个队列长度默认值
		default_queue_length =  
		{
			[1] = 10000,
			[2] = 1500,
			[3] = 750,
			abandon_pool_count_max = 750,
		},
	
	}
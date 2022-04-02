--
-- Author: lyx
-- Date: 2018/5/30
-- Time: 11:09
-- 说明：系统监控 参数配置
--[[
 配置项：
	name  	数据项的名字，目前支持
		register 注册
		login	登录
		pay 	支付
		redshop 红包商城兑换
		diamond 钻石增加
		withdraw 提现
	desc	显示内容
	dur 	数据收集的时长，单位 秒
	degree_inc	监控变量的严重程度增加量 到此值时再次报警：当监控的变量 偏离 报警值 每增加 给定的量，则重复报警一次
			注意：系统会记录 监控变量的最大值，只有手工处理或 重启服务器才会 复位
	comp	数值比较方式
		"greater" 大于
		"less" 小于
	type 	数值类型（在 dur 时段内）
		"count" 次数下限
		"value" 单次数值
		"sum" 	总和(dur 时间内)数值下限
	limit	限制值，意义 由 type 确定

	watch 观察数据，用于生成历史图表（参见数据库表 system_watch）
		{
			name=名称,
			desc=描述,
			axis_name={x轴名称,y轴名称},
		}

	-----------------------------------------

	短信模板： 平台警告：【%1】 在%2内%3 %4，%5临界值！
	举例：平台警告：【充值数额】 在60分钟内达到 1062400，超过临界值1000000！


--]]

return
{
	{
		name="test",
		desc="警报测试-次数",
		dur=5,
		degree_inc=50,
		comp="greater",
		type="count",
		limit=100
	},

	{
		name="test",
		desc="警报测试-数量",
		dur=5,
		degree_inc=50,
		comp="greater",
		type="sum",
		limit=200
	},

	{
		name="email_asset",
		desc="邮件发财富",
		dur=1800,
		degree_inc=1000000,
		comp="greater",
		type="sum",
		limit=20000000,
		watch=
		{
			name="email_asset",
			desc="邮件发财富",
			axis_name={"时间",""},
		}		
	},

	{
		name="profit_lose",
		desc="收益盈亏",
		dur=3600,
		degree_inc=0,
		comp="greater",
		type="sum",
		limit=10000000
	},

	{
		name="sql_error",
		desc="sql执行错误",
		dur=60,
		degree_inc=50,
		comp="greater",
		type="count",
		limit=1,
		email="695223392@qq.com,24090841@qq.com,515216238@qq.com",
	},

	{
		name="sql_wait_time",
		desc="sql语句等待时间",
		dur=10,
		degree_inc=30,
		comp="greater",
		type="value",
		limit=300,
		email="695223392@qq.com,24090841@qq.com,515216238@qq.com",
		watch=
		{
			name="sql_wait_time",
			desc="sql语句等待时间",
			axis_name={"时间","秒"},
		}		
	},

	{
		name="sql_wait_count",
		desc="sql语句等待数量",
		dur=10,
		degree_inc=300,
		comp="greater",
		type="value",
		limit=50000,
		email="695223392@qq.com,24090841@qq.com,515216238@qq.com",
		watch=
		{
			name="sql_wait_count",
			desc="sql语句等待数量",
			axis_name={"时间","条"},
		}		
	},

	{
		name="delay_sql_wait_count",
		desc="延迟sql等待数量",
		dur=10,
		degree_inc=1000,
		comp="greater",
		type="value",
		limit=50000,
		email="695223392@qq.com,24090841@qq.com,515216238@qq.com",
		watch=
		{
			name="delay_sql_wait_count",
			desc="延迟sql等待数量",
			axis_name={"时间","条"},
		}		
	},

	{
		name="write_sql_count",
		desc="写入sql条数",
		dur=30,
		degree_inc=30000000,
		comp="greater",
		type="value",
		limit=1500000000,
		watch=
		{
			name="write_sql_count",
			desc="写入sql条数",
			axis_name={"时间","条/秒"},
		}		
	},

	{
		name="push_sql_count",
		desc="增加sql条数",
		dur=30,
		degree_inc=30000000,
		comp="greater",
		type="value",
		limit=1500000000,
		watch=
		{
			name="push_sql_count",
			desc="增加sql条数",
			axis_name={"时间","条/秒"},
		}		
	},

	{
		name="register",
		desc="注册人数",
		dur=3600,
		degree_inc=50,
		comp="greater",
		type="count",
		limit=200,
		watch=
		{
			name="register",
			desc="注册人数",
			axis_name={"时间","人/小时"},
		}		
	},

	{
		name="login",
		desc="登录次数",
		dur=3600,
		degree_inc=50,
		comp="greater",
		type="count",
		limit=3000,
		watch=
		{
			name="login",
			desc="登录次数",
			axis_name={"时间","次/小时"},
		}		
	},

	{
		name="pay",
		desc="充值数额",
		dur=3600,
		degree_inc=10000,
		comp="greater",
		type="sum",
		limit=500000,
		watch=
		{
			name="pay_value",
			desc="充值数额",
			axis_name={"时间","分/小时"},
		}		
	},

	{
		name="pay",
		desc="充值次数",
		dur=3600,
		degree_inc=10,
		comp="greater",
		type="count",
		limit=700,
		watch=
		{
			name="pay_count",
			desc="充值次数",
			axis_name={"时间","次/小时"},
		}		
	},

	{
		name="redshop",
		desc="红包兑换次数",
		dur=3600,
		degree_inc=10,
		comp="greater",
		type="count",
		limit=400,
		watch=
		{
			name="redshop_count",
			desc="红包兑换次数",
			axis_name={"时间","次/小时"},
		}		
	},

	{
		name="redshop",
		desc="红包兑换金额",
		dur=3600,
		degree_inc=1000,
		comp="greater",
		type="sum",
		limit=300000,
		watch=
		{
			name="redshop_value",
			desc="红包兑换金额",
			axis_name={"时间","分/小时"},
		}		
	},

	{
		name="diamond",
		desc="钻石增加量",
		dur=3600,
		degree_inc=100000,
		comp="greater",
		type="sum",
		limit=500000,
		watch=
		{
			name="diamond",
			desc="钻石增加量",
			axis_name={"时间","个/小时"},
		}		
	},

	{
		name="withdraw",
		desc="提现次数",
		dur=3600,
		degree_inc=10,
		comp="greater",
		type="count",
		limit=400,
		watch=
		{
			name="withdraw_count",
			desc="提现次数",
			axis_name={"时间","次/小时"},
		}		
	},

	{
		name="withdraw",
		desc="提现金额",
		dur=3600,
		degree_inc=5000,
		comp="greater",
		type="sum",
		limit=200000,
		watch=
		{
			name="withdraw_value",
			desc="提现金额",
			axis_name={"时间","分/小时"},
		}		
	},
	{
		name="game_profit_pass_up_line",
		desc="场次统计，超过警报上限。",
		extra_desc = "场次统计超过上警报线，场次id：%s,警报线：%d,当前线：%d",
		dur=600,
		degree_inc=0,
		comp="greater",
		type="value",
		limit = 99999999999,
	},
	{
		name="game_profit_pass_down_line",
		desc="场次统计，超过警报下限。",
		extra_desc = "场次统计超过下警报线，场次id：%s,警报线：%d,当前线：%d",
		dur=600,
		degree_inc=0,
		comp="greater",
		type="value",
		limit = 99999999999,
	},
	{
		name="game_profit_long_time_out_ctrl",
		desc="场次统计，长时间调整失常。",
		extra_desc = "场次统计太长时间调整失常，场次id：%s,目标调整次数：%d,已调整次数：%d",
		dur=600,
		degree_inc=0,
		comp="greater",
		type="value",
		limit = 99999999999,
	},
	{
		name="total_jingbi_change",
		desc="系统金币变化",
		dur=1800,
		degree_inc=3000000,
		comp="greater",
		type="sum",
		limit=150000000,
		watch=
		{
			name="total_jingbi_change",
			desc="系统金币变化",
			axis_name={"时间","个/小时"},
		}		
	},
	{
		name="total_jingbi_sum",
		desc="系统总金币",
		dur=1800,
		degree_inc=9999999999999,
		comp="greater",
		type="value",
		limit=9999999999999,
		watch=
		{
			name="total_jingbi_sum",
			desc="系统总金币",
			axis_name={"时间","个"},
		}		
	},
	{
		name="online_count",
		desc="在线玩家数量",
		dur=60,
		degree_inc=3000000,
		comp="greater",
		type="value",
		limit=150000000,
		watch=
		{
			name="online_count",
			desc="在线玩家数量",
			axis_name={"时间","个"},
		}		
	},
}

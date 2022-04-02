--
-- Created by lyx.
-- User: hare
-- Date: 2018/6/4
-- Time: 1:47
-- 加入高级合伙人测试数据
--

local skynet = require "skynet_plus"
local cjson = require "cjson"
local basefunc = require "basefunc"
require "printfunc"



local function test_data(host,get,post,request)

	local ok,data = xpcall(cjson.decode,basefunc.error_handle,request.body)
	if not ok then
		return data
    end   
    
    -- 参数
    --  data.count1,data.count2  充值次数 下限 上限
    --  data.money1,data.money2  充值数额 下限 上限
    -- data.players 测试账号集合

    --local _month_start = os.time({year=2019,month=1,day=1,hour=5})
    -- 清测试数据： update sczd_player_all_achievements set yesterday_all_achievements=0,all_achievements=0,yesterday_tuikuan=0,tuikuan=0
 

    local ret = {}
    
    for _,_player_id in ipairs(data.players) do
        local _count = math.random(data.count1 or 3,data.count2 or 8)
        for i=1,_count do
            local _d ,code = skynet.call(host.service_config.data_service,"lua","debug_pay",_player_id,nil,math.random(data.money1 or 100,data.money2 or 1000))
            if _d then
                _d.player_id = _player_id
                ret[#ret + 1] = _d
            else
                ret[#ret + 1] =code
            end
        end
    end
    
    return ret

end

return test_data
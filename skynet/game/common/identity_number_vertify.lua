

local cardIDVertify = {}


local wi = { 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1 }; 
-- // verify digit 
local vi= { '1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2' }; 

local function checkSum(idcard)
    local nums = {}
    local _idcard = idcard:sub(1,17)
    for ch in _idcard:gmatch"." do
        table.insert(nums,tonumber(ch))
    end
    local sum = 0
    for i,k in ipairs(nums) do
        sum = sum + k * wi[i]
    end

    return vi [sum % 11+1] == idcard:sub(18,18 )
end

local function isAllNumberOrWithXInEnd( str )
    local ret = str:match("%d+X?") 
    return ret == str 
end

local function isBirthDate(date)
    local year = tonumber(date:sub(1,4))
    local month = tonumber(date:sub(5,6))
    local day = tonumber(date:sub(7,8))
    if year < 1900 or year > 3000 or month >12 or month < 1 then
        return 5
    end

    -- 18岁
    local cy = tonumber(os.date("%Y%m%d")) - 180000
    if cy - tonumber(date) < 0 then
        return 6
    end

    -- //月份天数表
    local month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    local bLeapYear = (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
    if bLeapYear  then
        month_days[2] = 29;
    end

    if day > month_days[month] or day < 1 then
        return 5
    end

    return 0
end


--[[
    0 - OK
    1 - len error
    2 - end x error
    3 - num error
    4 - place error
    5 - date error
    6 - 18 age
]]
function cardIDVertify.verifyIDCard(idcard)
    if string.len(idcard) ~= 18 then
        return 1
    end

    if not isAllNumberOrWithXInEnd(idcard) then
        return 2
    end

    if not checkSum(idcard) then
        return 3
    end

    -- //第1-2位为省级行政区划代码，[11, 65] (第一位华北区1，东北区2，华东区3，中南区4，西南区5，西北区6)
    local nProvince = tonumber(idcard:sub(1, 2))
    if( nProvince < 11 or nProvince > 65 ) then
        return 4
    end

    -- //第3-4为为地级行政区划代码，第5-6位为县级行政区划代码因为经常有调整，这块就不做校验

    -- //第7-10位为出生年份；//第11-12位为出生月份 //第13-14为出生日期
    local ret = isBirthDate(idcard:sub(7,14))
    if ret > 0  then
        return ret
    end

    return 0
end

return cardIDVertify




local loadstring = rawget(_G, "loadstring") or load

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 5 end

    local lookupTable = {}
    local result = {}

    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(description), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, description, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

math.randomseed(os.time()*78415)



local ddz_opt_type = {
    [0] = "过",
    [1] = "单牌",
    [2] = "对子",
    [3] = "三不带",
    [4] = "三带一",
    [5] = "三带一对",
    [6] = "顺子",
    [7] = "连队",
    [8] = "四带2",
    [9] = "四带两对",
    [10] = "飞机带单牌",
    [11] = "飞机带对子",
    [12] = "飞机不带",
    [13] = "炸弹",
    [14] = "王炸",
    [15] = "假炸弹",

    [20] = "叫地主",
    [21] = "加倍",
    [22] = "不加倍",
    [23] = "托管",
    [24] = "取消托管",
    [25] = "二人斗地主抢地主",


    [26] = "闷",
    [27] = "不闷",
    [28] = "抓",
    [29] = "不抓",
    [30] = "倒",
    [31] = "不倒",
    [32] = "拉",
    [33] = "不拉",

}

local ddz_pai_map={
    3,3,3,3,
    4,4,4,4,
    5,5,5,5,
    6,6,6,6,
    7,7,7,7,
    8,8,8,8,
    9,9,9,9,
    10,10,10,10,
    11,11,11,11,
    12,12,12,12,
    13,13,13,13,
    14,14,14,14,
    15,15,15,15,
    16,
    17,
}


local function ddz_opt(opts)
        
    local idx = 1
    while idx < #opts do
        local oper = opts[idx]
        local optm = opts[idx+1]
        local optp = opts[idx+2]
        local opln = opts[idx+3]
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm*0.1,ddz_opt_type[optp]))
        --if optp == 23 or optp == 24 then
        --    print("true")
        --    return
        --end
        if opln > 0 then
            local d = ""
            for i=idx+4,idx+3+opln do
                if optp>0 and optp < 20 then
                    d = d..ddz_pai_map[opts[i]]..","
                elseif optp == 20 then
                    d = opts[i]
                end
            end
            print(d)
        end

        idx = idx + opln + 4
        --idx = idx + 1
    end
    --print("false")
end


local mj_opt_type= {
    [1] =   "定缺",
    [2] =   "出牌",
    [3] =   "过",
    [4] =   "碰",
    [5] =   "杠",
    [6] =   "胡",
    [7] =   "托管",
    [8] =   "取消托管",
    [9] =   "换三张",
    [10] =   "打飘",
    [11] =   "破产",
    [12] =   "摸牌",
}
local function mj_opt(opts)
    
    local idx = 1
    while idx < #opts do
        local oper = opts[idx]
        local optm = opts[idx+1]
        local optp = opts[idx+2]
        local opln = opts[idx+3]
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm*0.1,mj_opt_type[optp]))
        if opln > 0 then
            local d = ""
            for i=idx+4,idx+3+opln do
                if optp == 0 then
                    d = "guo"
                elseif optp < 15 then
                    d = d..opts[i]..","
                end
            end
            print(d)
        end

        idx = idx + opln + 4

    end

end



local gobang_opt_type= {
    [1] =   "下棋",
    [2] =   "过",
    [3] =   "求和",
    [4] =   "悔棋",
    [5] =   "求和反馈",
    [6] =   "悔棋反馈",
    [7] =   "认输",
}
local function gobang_opt(opts)
        
    local idx = 1
    while idx < #opts do
        local oper = opts[idx]
        local optm = opts[idx+1]
        local optp = opts[idx+2]
        local opln = opts[idx+3]
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm,gobang_opt_type[optp]))
        if opln > 0 then
            local d = ""
            for i=idx+4,idx+3+opln do
                if opln > 1 then
                    d = d..opts[i]..","
                else
                    d = opts[i]
                end
            end
            print(d)
        end

        idx = idx + opln + 4

    end

end



local pdk_opt_type = {
    [0] = "要不起",
    [1] = "单牌",
    [2] = "对子",
    [3] = "三不带",
    [4] = "三带一",

    [6] = "顺子",
    [7] = "连队",
    [8] = "四带2",

    [10] = "飞机带单牌",

    [12] = "飞机不带",
    [13] = "炸弹",

    [34] = "三带二",
    [35] = "四带三",
    [36] = "飞机带2*飞机数牌",

}

local pdk_pai_map={
    3,3,3,3,
    4,4,4,4,
    5,5,5,5,
    6,6,6,6,
    7,7,7,7,
    8,8,8,8,
    9,9,9,9,
    10,10,10,10,
    11,11,11,11,
    12,12,12,12,
    13,13,13,13,
    14,14,14,14,
    15,15,15,15,

}

local function pdk_opt(opts)
        
    local idx = 1
    while idx < #opts do
        local oper = opts[idx]
        local optm = opts[idx+1]
        local optp = opts[idx+2]
        local opln = opts[idx+3]
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm*0.1,pdk_opt_type[optp]))
        if opln > 0 then
            local d = ""
            for i=idx+4,idx+3+opln do
                if (optp>0 and optp < 20) or (optp > 33 and optp < 37) then
                    d = d..pdk_pai_map[opts[i]]..","
                elseif optp == 20 then
                    d = opts[i]
                end
            end
            print(d)
        end

        idx = idx + opln + 4

    end

end

----------------------------------------------------------------------------------------
local pai_symbol_map={
    [3]='3',
    [4]='4',
    [5]='5',
    [6]='6',
    [7]='7',
    [8]='8',
    [9]='9',
    [10]='0',
    [11]='J',
    [12]='Q',
    [13]='K',
    [14]='A',
    [15]='2',
    [16]='w',
    [17]='W',
}

local pai_type_map = {
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    6,
    6,
    6,
    6,
    7,
    7,
    7,
    7,
    8,
    8,
    8,
    8,
    9,
    9,
    9,
    9,
    10,
    10,
    10,
    10,
    11,
    11,
    11,
    11,
    12,
    12,
    12,
    12,
    13,
    13,
    13,
    13,
    14,
    14,
    14,
    14,
    15,
    15,
    15,
    15,
    16,
    17
}

--[==[

-- id=58295217
[1]="000A22",
[2]="4456899JJQKKAA 9A2",
[3]="33357788JJQQW",

data.base_info.dz_seat= 2
data.base_info.my_seat= 3

data.base_info.seat_count = 3

data.base_info.seat_type = {
    [1] = 0,
    [2] = 1,
    [3] = 0,
}
data.firstplay = false
[1] = 9
-----------------------------
-- id=58295186
[1]="6778890029",
[2]="33362",
[3]="4567789QQKKA",

data.base_info.dz_seat= 1
data.base_info.my_seat= 2

data.base_info.seat_count = 3

data.base_info.seat_type = {
    [1] = 1,
    [2] = 0,
    [3] = 0,
}
data.firstplay = true
-----------------------------
-- id=58295196
[1]="33444667790KA",
[2]="AA",
[3]="KK22",

data.base_info.dz_seat= 2
data.base_info.my_seat= 2

data.base_info.seat_count = 3

data.base_info.seat_type = {
    [1] = 0,
    [2] = 1,
    [3] = 0,
}
data.firstplay = false
[1] = 5
-----------------------------

-- id=58295214
[1]="45889900J2w",
[2]="3345566777890JQK",
[3]="6690QQQKJ",

data.base_info.dz_seat= 3
data.base_info.my_seat= 3

data.base_info.seat_count = 3

data.base_info.seat_type = {
    [1] = 0,
    [2] = 0,
    [3] = 1,
}
data.firstplay = true
[1] = 
-----------------------------

-- id=58295182
[1]="W",
[2]="68889JJKK",
[3]="3346778900JQQQKAw",

data.base_info.dz_seat= 1
data.base_info.my_seat= 1

data.base_info.seat_count = 3

data.base_info.seat_type = {
    [1] = 1,
    [2] = 0,
    [3] = 0,
}
data.firstplay = true
[1] = 
-----------------------------

-- id=58295187
[1]="347890JJK",
[2]="34448900JQK",
[3]="6666",

data.base_info.dz_seat= 3
data.base_info.my_seat= 1

data.base_info.seat_count = 3

data.base_info.seat_type = {
    [1] = 0,
    [2] = 0,
    [3] = 1,
}
data.firstplay = false
[3] = 11
-----------------------------
--]==]

local pai_data

local opts = {
    1,14,20,1,0,2,10,20,1,0,3,10,20,1,3,3,82,1,1,20,1,17,1,1,22,2,17,1,1,38,3,19,1,1,42,1,10,1,1,50,2,15,0,0,3,9,0,0,1,10,2,2,9,11,2,15,2,2,17,19,3,28,2,2,27,28,1,18,2,2,45,48,2,13,0,0,3,15,2,2,49,51,1,29,0,0,2,19,0,0,3,29,1,1,21,1,12,1,1,30,2,17,1,1,41,3,24,1,1,52,1,34,1,1,53,2,25,0,0,3,8,1,1,54,1,18,0,0,2,16,0,0,3,10,2,2,1,2,1,25,0,0,2,16,2,2,10,12,3,9,2,2,37,39,1,17,0,0,2,15,0,0,3,35,2,2,46,47,1,16,0,0,2,15,0,0,3,10,1,1,36,1,148,1,1,43,2,48,0,0,3,10,13,4,13,14,15,16

} 
local function get_data()
    --file=io.open("C:\\Users\\Admin\\Desktop\\work\\pai.txt","a+")

    local data=[=[[{"34":true,"35":true,"4":true,"7":true,"9":true,"43":true,"45":true,"48":true,"18":true,"53":true,"22":true,"23":true,"25":true,"50":true,"11":true,"30":true,"31":true},{"32":true,"33":true,"3":true,"5":true,"6":true,"40":true,"41":true,"10":true,"44":true,"17":true,"19":true,"24":true,"26":true,"8":true,"29":true,"38":true,"12":true},{"2":true,"36":true,"37":true,"39":true,"42":true,"13":true,"14":true,"15":true,"16":true,"49":true,"51":true,"52":true,"21":true,"54":true,"28":true,"20":true,"47":true}]]=]
    --file:read()
    data=string.gsub(data,"\":","]=")
    data=string.gsub(data,"\"","[")
    data=string.sub(data,2,string.len(data))
    data="{"..data
    data=string.sub(data,1,string.len(data)-1)
    data=data.."}"
    pai_data = data
    -- print(data)
    --file:close()

    return load("return " .. data)()
end

--数据
local map=get_data()
local dz_seat=0

local function  piaID_2_zimu(id)
	return pai_symbol_map[pai_type_map[id]]
end
local pai={"","",""}
local dz_pai=""
local function pai_total()
    local hash={}
    
    for seat,v in ipairs(map) do
        for pai_id=1,54 do
            if v[pai_id] then
                hash[pai_id]=true
                pai[seat]=pai[seat]..piaID_2_zimu(pai_id)
            end
        end
    end
    
    for i=1,54 do
        if not hash[i] then
            dz_pai=dz_pai..piaID_2_zimu(i)
        end
    end
    if dz_seat and  dz_seat>0 then
        pai[dz_seat]=pai[dz_seat]..dz_pai
    end

end

pai_total()

local function print_pai_info()
    print(pai_data)
    print("地主牌")
    print(dz_pai)

    print("玩家牌")
    print("[1]=".."\""..pai[1].."\",")
    print("[2]=".."\""..pai[2].."\",")
    print("[3]=".."\""..pai[3].."\",")
end

------------------------------------------------------------------------------------------
print_pai_info()

-- local opts = {
--     2,48,20,1,3,2,57,1,1,8,3,10,1,1,30,1,12,1,1,48,2,14,1,1,49,3,15,1,1,53,1,29,0,0,2,7,0,0,3,29,4,4,5,26,27,28,1,11,0,0,2,32,4,4,29,31,32,12,3,19,4,4,37,50,51,52,1,19,0,0,2,6,0,0,3,15,6,5,1,6,10,14,17,1,10,0,0,2,15,6,5,7,11,13,18,21,3,19,0,0,1,36,6,5,22,25,9,15,19,2,9,0,0,3,18,0,0,1,18,2,2,3,4,2,36,2,2,41,44,3,11,0,0,1,16,0,0,2,112,1,1,35,3,12,0,0,1,40,1,1,54,2,10,0,0,3,18,0,0,1,13,1,1,16,2,24,1,1,40,3,13,0,0,1,14,1,1,42,2,44,1,1,47,3,18,0,0,1,25,0,0,2,12,1,1,2,3,14,1,1,33,1,17,0,0,2,11,1,1,46,3,13,0,0,1,48,0,0,2,12,1,1,45,3,48,0,0,1,48,0,0,2,10,1,1,20

-- } 
ddz_opt(opts)

-- pdk_opt(opts)

-- gobang_opt(opts)


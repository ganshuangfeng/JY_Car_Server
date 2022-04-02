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

    end

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




local lhd_opt_type = {
    [0] = "系统发牌",
    [1] = "系统产生透明蛋",
    [2] = "投降",
    [3] = "摸牌",
    [4] = "透明",
    [5] = "补齐",
    [6] = "出战",
}

local lhd_mopai_type = {
    [1] = "选择系统透明牌",
    [2] = "选择其他玩家的透明牌",
    [3] = "选择自己的透明牌",
    [4] = "选择随机牌",
}

local lhd_pai_map={
    "8_1","8_2","8_3","8_4",
    "9_1","9_2","9_3","9_4",
    "10_1","10_2","10_3","10_4",
    "J_1","J_2","J_3","J_4",
    "Q_1","Q_2","Q_3","Q_4",
    "K_1","K_2","K_3","K_4",
    "A_1","A_2","A_3","A_4",
}

local function lhd_opt(opts)
        
    local idx = 1
    while idx < #opts do
        local oper = opts[idx]
        local optm = opts[idx+1]
        local optp = opts[idx+2]
        local opln = opts[idx+3]
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm*0.1,lhd_opt_type[optp]))
        if opln > 0 then
            local d = ""
            if optp == 0 then
                --data: 发牌数量,座位,牌 长度n
                local pn = opts[idx+4]
                local sn = math.floor((opln-1)/(pn+1))

                for s=1,sn do
                    local h = idx + 5 + (pn+1)*(s-1)
                    d = d .. string.format("no.%d pai:", opts[h] )
                    for p=1,pn do
                        d = d .. lhd_pai_map[ opts[ h + p ] ] .. "、"
                    end
                    d = d .. "\n"
                end

            elseif optp == 1 or optp == 4 then
                local pai = opts[idx+4]
                d = lhd_pai_map[pai]
            elseif optp == 3 then
                local pai = opts[idx+4]
                d = string.format( "%s 倍数:%d 类型:%s" , lhd_pai_map[pai] , opts[idx+6]*256+opts[idx+7] , lhd_mopai_type[ opts[idx+5] ] )
            elseif optp == 5 then
                d = "是"
                if opts[idx+4] == 0 then
                    d = "否"
                end
            elseif optp == 6 then
                d = opts[idx+4]*256+opts[idx+5]
            end

            print(d)
        end

        idx = idx + opln + 4

    end

end





local opts = {
3,55,20,1,3,3,43,7,6,3,4,6,8,9,11,1,38,7,6,22,23,13,14,17,18,2,15,0,0,3,3,0,0,1,28,6,6,24,26,32,10,15,19,2,19,0,0,3,152,23,0,3,152,0,0,1,13,1,1,20,2,13,1,1,50,3,20,0,0,1,12,0,0,2,11,1,1,16,3,20,0,0,1,24,1,1,40,2,18,1,1,51,3,15,0,0,1,14,1,1,53,2,19,0,0,3,15,0,0,1,13,2,2,41,44
}

-- mj_opt(opts)

ddz_opt(opts)

-- pdk_opt(opts)

-- gobang_opt(opts)

-- lhd_opt(opts)
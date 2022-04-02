--[==[
-- 批量处理    

--]==]

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
    dump_(value, description, " ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

math.randomseed(os.time()*78415)

function string_split(str, sepa)
    if str==nil or str=='' then
        return nil
    end

    sepa = sepa or ","

    local result = {}
    for match in (str..sepa):gmatch("(.-)"..sepa) do
        table.insert(result, match)
    end
    return result
end

--判断玩家是否是真真实玩家
function chk_player_is_real(_player_id)
    if string.sub(_player_id,1,5) == "robot" then
        return false
    end
    return true
end

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
        local oper = opts[idx]      ---- 操作人座位号
        local optm = opts[idx+1]    ---- 操作时间 ， *10 的
        local optp = opts[idx+2]    ---- 操作类型
        local opln = opts[idx+3]    ---- 操作的数据长度
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm*0.1,ddz_opt_type[optp]))
        --if optp == 23 or optp == 24 then
        --    print("true")
        --    return
        --end
        if opln > 0 then
            local d = ""
            for i=idx+4,idx+3+opln do
                if optp>0 and optp < 20 then   ---- 操作除了过和叫地主
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

--打印 玩家牌信息
local function  print_pai_data(data)

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

        local pai_data
        local function get_data()
            --file=io.open("C:\\Users\\Admin\\Desktop\\work\\pai.txt","a+")

            local data=data
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

end 

   
-- pdk_opt(opts)


-- add by wss 
---- 把各个玩家的牌信息，打成一个表
--[[
    {
        [1] = { [pai_type] = num , ... }
    }
--]]    

local function  get_player_init_data(data)
    local player_pai_type_num_vec = {}

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

        local pai_data
        local function get_data()
            --file=io.open("C:\\Users\\Admin\\Desktop\\work\\pai.txt","a+")
             print(data)
              print("xxxx-----------------------------------------↑")
            local data=data
            --file:read()
            data=string.gsub(data,"\":","]=")
            data=string.gsub(data,"\"","[")
            data=string.sub(data,2,string.len(data))
            data="{"..data
            data=string.sub(data,1,string.len(data)-1)
            data=data.."}"
            pai_data = data
            print(data)
            print("xxxx-----------------------------------------↑")
            --file:close()

            return load("return " .. data)()
        end

        --数据
        local map=get_data()
        local dz_seat=0

        local function  piaID_2_zimu(id)
            ---- pai_id 转 pai_type , pai_type 再转 pai_word
            return pai_symbol_map[pai_type_map[id]]
        end
        local pai={"","",""}
        local dz_pai=""
        local function pai_total()
            local hash={}
            
            for seat,v in ipairs(map) do
                player_pai_type_num_vec[seat] = player_pai_type_num_vec[seat] or {}
                local tar_vec = player_pai_type_num_vec[seat]

                for pai_id=1,54 do
                    if v[pai_id] then
                        hash[pai_id]=true

                        tar_vec[ pai_type_map[pai_id] ] = ( tar_vec[ pai_type_map[pai_id] ] or 0 ) + 1

                        --pai[seat]=pai[seat]..piaID_2_zimu(pai_id)
                    end
                end
            end
            
            for i=1,54 do
                player_pai_type_num_vec[4] = player_pai_type_num_vec[4] or {}
                local tar_vec = player_pai_type_num_vec[4]

                if not hash[i] then
                    
                    tar_vec[ pai_type_map[i] ] = ( tar_vec[ pai_type_map[i] ] or 0 ) + 1
                    --dz_pai=dz_pai..piaID_2_zimu(i)
                end
            end
            --if dz_seat and  dz_seat>0 then
            --    pai[dz_seat]=pai[dz_seat]..dz_pai
            --end

        end

        pai_total()

        dump( player_pai_type_num_vec , "xxx------------------------所有玩家的牌的pai_type数量vec" )

        --[[local function print_pai_info()
            print(pai_data)
            print("地主牌")
            print(dz_pai)

            print("玩家牌")
            print("[1]=".."\""..pai[1].."\",")
            print("[2]=".."\""..pai[2].."\",")
            print("[3]=".."\""..pai[3].."\",")
        end--]]

        ------------------------------------------------------------------------------------------
        --print_pai_info()
        return player_pai_type_num_vec
end 

---------- 各个出牌类型，每隔多少次记录一下
local chupai_type_record_vec = {
    [1] = {  -- 1： 单牌
        [1] = { pai_num = 1 , get_type = "max" }  
    },
    [2] = { -- 2： 对子
        [1] = { pai_num = 2 , get_type = "max" }  
    },
    [3] = { -- 3： 三不带
        [1] = { pai_num = 3 , get_type = "max" }  
    },
    [4] = { -- 4： 三带一
        [1] = { pai_num = 3 , get_type = "max" }  ,
        [2] = { pai_num = 1 , get_type = "max" }  ,
    },
    [5] = { -- 5： 三带一对
        [1] = { pai_num = 3 , get_type = "max" }  ,
        [2] = { pai_num = 2 , get_type = "max" }  ,
    },
    [6] = { -- 6： 顺子 
        [1] = { pai_num = 1 , get_type = "min" }  ,
        [2] = { pai_num = 1 , get_type = "max" }  ,
    },
    [7] = { -- 7： 连队
        [1] = { pai_num = 2 , get_type = "min" }  ,
        [2] = { pai_num = 2 , get_type = "max" }  ,
    },
    [8] = { -- 8： 四带2
        [1] = { pai_num = 4 , get_type = "max" }  ,
        [2] = { pai_num = 1 , get_type = "min" }  ,
        [3] = { pai_num = 1 , get_type = "max" }  ,
    },
    [9] = { -- 9： 四带两对
        [1] = { pai_num = 4 , get_type = "max" }  ,
        [2] = { pai_num = 2 , get_type = "min" }  ,
        [3] = { pai_num = 2 , get_type = "max" }  ,
    },
    [10] = { -- 10：飞机带单牌
        [1] = { pai_num = 3 , get_type = "min" }  ,
        [2] = { pai_num = 3 , get_type = "max" }  ,
        [3] = { pai_num = 1 , get_type = "all" }  ,  --- 一次加
    },
    [11] = { -- 11：飞机带对子
        [1] = { pai_num = 3 , get_type = "min" }  ,
        [2] = { pai_num = 3 , get_type = "max" }  ,
        [3] = { pai_num = 2 , get_type = "all" }  ,  --- 一次加
    },
    [12] = { -- 12：飞机  不带
        [1] = { pai_num = 3 , get_type = "min" }  ,
        [2] = { pai_num = 3 , get_type = "max" }  ,
    },
    [13] = { -- 13：炸弹
        [1] = { pai_num = 4 , get_type = "max" }  ,
    },
    [14] = { -- 王炸

    },
}


local function new_ddz_opt(opts , player_pai_type_num_vec , player_id_list)
    local is_tuoguan_delay = false

    ---- 首 出
    local is_real_first_player = true
    --- 超时的时间数,*10的
    local over_time = 140

    local dz_seat = 0

    local guo_num = 0     --- 过的数量
    local last_op = nil   --- 上一把的操作数据

    local delay_my_seat = 0
    --------------------------- 先确定地主
    local idx = 1
    while idx < #opts do
        local oper = opts[idx]      ---- 操作人座位号
        local optm = opts[idx+1]    ---- 操作时间 ， *10 的
        local optp = opts[idx+2]    ---- 操作类型
        local opln = opts[idx+3]    ---- 操作的数据长度
       
        if opln > 0 then
            local d = ""
            for i=idx+4,idx+3+opln do
               if optp == 20 then
                    d = opts[i]
                    dz_seat = oper
                end
            end
        end

        idx = idx + opln + 4
        --idx = idx + 1
    end

    ------------------ 把地主的牌附加到指定人上
    for pai_type , pai_num in pairs( player_pai_type_num_vec[4] ) do

        local tar_vec = player_pai_type_num_vec[dz_seat]

        tar_vec[pai_type] = (tar_vec[pai_type] or 0) + pai_num
    end

    --------------------------------------------------- 计算
    idx = 1
    while idx < #opts do
        local oper = opts[idx]      ---- 操作人座位号
        local optm = opts[idx+1]    ---- 操作时间 ， *10 的
        local optp = opts[idx+2]    ---- 操作类型
        local opln = opts[idx+3]    ---- 操作的数据长度
        print(string.format("\nno.%d time:%.2f opt:%s ",oper,optm*0.1,ddz_opt_type[optp]))
        --if optp == 23 or optp == 24 then
        --    print("true")
        --    return
        --end

        ---- 托管超时再跳出
        if optm >= over_time then
            if not chk_player_is_real( player_id_list[oper] ) then
                is_tuoguan_delay = true

                delay_my_seat = oper
                break
            end
        end

        if optp == 0 then
         ----- 过的时候加过的次数
            guo_num = guo_num + 1
          -- print("xxx-------guo_num:",guo_num)
        end

        --print("xxxx---------------------------opln:",opln)
        if opln > 0 then
            local d = ""
            ---- 操作除了过和叫地主 ， 就记录上一次的操作
            if optp>0 and optp < 20 then 
                is_real_first_player = false
                last_op = { oper , { ["type"] = optp , pai = {} } , {} }
            end
            --print("xxxx-------optp:",optp)
            for i=idx+4,idx+3+opln do
                if optp>0 and optp < 20 then   ---- 操作除了过和叫地主
                    d = d..ddz_pai_map[opts[i]]..","

                    local pai_type = ddz_pai_map[opts[i]]
                    ---- 对应人身上减牌
                    local tar_vec = player_pai_type_num_vec[oper]
                    tar_vec[ pai_type ] = tar_vec[ pai_type ] - 1
                    ---- 只要有人出牌过就清0
                    guo_num = 0
                    --print("xxx-------guo_num:",guo_num)
                    ---- 记录上一次的操作
                    local pp_vec = last_op[3]

                    pp_vec[pai_type] = ( pp_vec[pai_type] or 0 ) + 1

                elseif optp == 20 then   ---叫地主
                    d = opts[i]
                   
                end
            end

            -------- 打到一个 pai_num_list_pai_type 中中
            if last_op then
                local pai_num_list_pai_type = {}
                for pai_type , pai_num in pairs(last_op[3]) do
                    pai_num_list_pai_type[pai_num] = pai_num_list_pai_type[pai_num] or {}
                    local tar_list = pai_num_list_pai_type[pai_num]

                    tar_list[#tar_list + 1] = pai_type
                end

                ---排序
                for pai_num , pai_type_vec in pairs(pai_num_list_pai_type) do
                    table.sort( pai_type_vec , function(a,b) 
                        return a < b
                    end)
                end

                local tar_key_pai_vec = last_op[2].pai
                for key_pai_index , deal_vec in ipairs( chupai_type_record_vec[optp] ) do
                    local deal_pai_num = deal_vec.pai_num
                    local deal_type = deal_vec.get_type

                    if deal_type == "min" then
                        tar_key_pai_vec[#tar_key_pai_vec + 1] = pai_num_list_pai_type[deal_pai_num][1]
                    elseif deal_type == "max" then
                        tar_key_pai_vec[#tar_key_pai_vec + 1] = pai_num_list_pai_type[deal_pai_num][ #pai_num_list_pai_type[deal_pai_num] ]
                    elseif deal_type == "all" then

                        for key,pai_type in ipairs( pai_num_list_pai_type[deal_pai_num] ) do
                            tar_key_pai_vec[#tar_key_pai_vec + 1] = pai_type
                        end

                    end

                end
            end


            print(d)
        end

        idx = idx + opln + 4
        --idx = idx + 1
    end
    --print("false")

    return is_tuoguan_delay , dz_seat , player_pai_type_num_vec , guo_num , is_real_first_player , last_op , delay_my_seat
end

local function tras_pai_type_vec_to_pai_word_vec( pai_type_num_vec )
    local pai_word_vec = {}
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

    for i = 1 , 3 do
        pai_word_vec[i] = ""

        if pai_type_num_vec[i] then

            
            

            for pai_type , pai_num in pairs( pai_type_num_vec[i] ) do
                for k=1,pai_num do
                    pai_word_vec[i] = pai_word_vec[i] .. pai_symbol_map[ pai_type ]

                end
            end

        end
    end

    return pai_word_vec
end

---------------------------------------------------------------------------------------------------------- ↓↓
---- 玩家的id 列表，1就是1号位，2就是2号位(1表示托管)
local player_id_list_str = [[robot_tg7_1_66,robot_tg7_0_245,105411988]]

local player_id_list = string_split( player_id_list_str , "," )

--dump( player_id_list , "xxx---------------------player_id_list:" )

local opts = {
    3,38,20,1,0,1,17,20,1,3,1,19,1,1,4,2,26,1,1,12,3,245,23,0,3,245,0,0,1,16,1,1,36,2,15,1,1,37,3,18,0,0,1,20,1,1,41,2,7,1,1,47,3,19,0,0,1,25,1,1,49,2,8,0,0,3,19,0,0,1,45,11,10,5,6,7,9,10,11,13,14,17,18,2,10,0,0,3,19,0,0,1,12,2,2,25,28,2,17,2,2,29,30,3,19,0,0,1,17,2,2,45,46,2,14,2,2,51,52,3,18,0,0,1,17,0,0,2,32,1,1,1,3,19,0,0,1,12,1,1,50,2,9,0,0,3,19,0,0,1,149,1,1,54
}
--ddz_opt(opts)

local data=[==[[

    {"5":true,"6":true,"7":true,"41":true,"10":true,"11":true,"13":true,"14":true,"49":true,"18":true,"54":true,"25":true,"50":true,"17":true,"46":true,"45":true,"9":true},{"1":true,"47":true,"33":true,"34":true,"51":true,"52":true,"21":true,"22":true,"23":true,"37":true,"42":true,"26":true,"43":true,"12":true,"29":true,"30":true,"15":true},{"32":true,"2":true,"3":true,"38":true,"39":true,"40":true,"44":true,"48":true,"19":true,"20":true,"53":true,"24":true,"27":true,"16":true,"8":true,"35":true,"31":true}

]]==]
--print_pai_data(data)        

local player_pai_type_num_vec = get_player_init_data(data) 
--dump(player_pai_type_num_vec , "xxx----------------------player_pai_type_num_vec 1")

local is_tuoguan_delay , dz_seat , player_pai_type_num_vec , guo_num , is_real_first_player , last_op , delay_my_seat = new_ddz_opt(opts , player_pai_type_num_vec , player_id_list)


if not is_tuoguan_delay then
    print("xxx-----------------------托管未超时")

else
    --[[
        [1]="555588890000QQK22",
        [2]="3344677JQKKAA22wW",
        [3]="44778999JJJQKAA",
        data.base_info.dz_seat= 3（地主座位号）
        data.base_info.my_seat= 1（我的座位号）

        data.base_info.seat_count = 3（这局人数，二人斗地主的话是2）
        data.base_info.seat_type = {
            [1] = 0,
            [2] = 0,
            [3] = 1,
        }
        data.firstplay = false

        [3]=66633
    --]]

    local my_seat = ""
    local dz_seat_vec = {0,0,0}
    dz_seat_vec[dz_seat] = 1

    for seat , player_id in ipairs(player_id_list) do
        if chk_player_is_real(player_id) then
            my_seat = my_seat .. seat .. ","
        end
    end

    print("xxx--------------------------------------------------最终结果 ↓\n")
    --dump(player_pai_type_num_vec , "xxx-------------player_pai_type_num_vec 2")
    local pai_word_vec = tras_pai_type_vec_to_pai_word_vec(player_pai_type_num_vec)
    --dump(pai_word_vec , "xx------------------ 托管超时前的玩家剩余牌情况：")

    print("data.pai_map = {")
        for k,value in ipairs(pai_word_vec) do
            print( string.format("\t[%d] = \"%s\"," , k,value) )
        end
    print("}")

    print( "data.base_info.dz_seat = " .. dz_seat )
    print( "data.base_info.my_seat = " .. delay_my_seat )
    print( "data.base_info.seat_count = " .. #player_id_list )

    print("data.base_info.seat_type = {")
        for k,value in ipairs(dz_seat_vec) do
            print( string.format("\t[%d] = %s," , k,value) )
        end
    print("}")

    local is_firstplay = false
    --print("xxx-------guo_num:",guo_num)
    if is_real_first_player or guo_num == 2 then
        is_firstplay = true
    else

    end

    print( "data.firstplay = " .. (is_firstplay and "true" or "false") )

    if not is_firstplay then
        print("data.last_pai = {")
            print("\tpai = {")
                for k,value in ipairs(last_op[2].pai) do
                    print( string.format("\t\t[%d] = %s," , k,value) )
                end
            print("\t},")
            print("\ttype = " .. last_op[2].type )
        print("}")

        print("data.last_seat = " .. last_op[1] )
    end
end


-- gobang_opt(opts)


--
-- Author: lyx
-- Date: 2019/7/9
-- Time: 18:23
-- 说明： 装备升星管理器
--

local skynet = require "skynet_plus"
local base = require "base"
local basefunc = require "basefunc"
local nodefunc = require "nodefunc"
local cjson = require "cjson"
local crypt = require "client.crypt"
-- crypt.hmac64_md5
require "data_func"

local md5 = require "md5"
-- md5.hmacmd5

require "normal_enum"
require "printfunc"

require "common_data_manager_lib"

local upcfg_trans_lib = require "upgrade.upcfg_trans_lib"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("car_upgrade_data",{

    -- 玩家 车的数据 
    car_data = nil,

    -- 玩家 装备的数据 
    equipment_data = nil,

})

local LF = base.LocalFunc("car_upgrade_data")

function LF.init()
    LD.car_data = basefunc.server_class.data_manager_cls.new({
        load_data = function(_key) return LF.load_car_info(_key)  end
    },tonumber(skynet.getenv("data_man_cache_size")) or 40000)

    LD.equipment_data = basefunc.server_class.data_manager_cls.new({
        load_data = function(_key) return LF.load_equipment_info(_key)  end
    },tonumber(skynet.getenv("data_man_cache_size")) or 40000)
end


function LF.load_car_info(_user_id)
    local _ret,_err = PUBLIC.db_query_va("select * from player_car_data where player_id=%s;",_user_id)
    if _err then
        error(_err)
    end

    local _d = {}

    for _,v in ipairs(_ret) do
        _d[v.car_id] = v
    end

    return _d
end

-- 返回 装备 序列号
function CMD.add_car_info(_user_id,_data)

    _data.player_id = _user_id

    local _old = LD.car_data:get_data(_user_id) or {}
    _old[_data.car_id] = _data

    local _sql = PUBLIC.safe_insert_sql("player_car_data",_data,{"player_id","car_id"})
    local _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")

    LD.car_data:add_or_update_data(_user_id,_old,_qname,_qid)

end

function CMD.modify_car_info(_user_id,_data)

    local _old = LD.car_data:get_data(_user_id)
    _old = _old or {}

    local _qname,_qid
    for _car_id,_d in pairs(_data) do  -- 比较，有变化则更新

        if not _old[_car_id] or not basefunc.compare_vaule_same( _d , _old[_car_id] ) then
          
            _old[_car_id] = basefunc.merge(_d,_old[_car_id])
            _old[_car_id].player_id=_user_id

            local _sql = PUBLIC.safe_insert_sql("player_car_data",_old[_car_id],{"player_id","car_id"})
            _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")
        end
    end
    
    if _qname then  -- 有更新
        LD.car_data:add_or_update_data(_user_id,_old,_qname,_qid)
    end
end

function CMD.query_car_info(_user_id)
    return LD.car_data:get_data(_user_id)
end


function LF.load_equipment_info(_user_id)
    local _ret,_err = PUBLIC.db_query_va("select * from player_equipment_data where player_id=%s;",_user_id)
    if _err then
        error(_err)
    end

    local _d = {}

    for _,v in ipairs(_ret) do
        _d[v.no] = v
    end

    return _d
end

-- 返回 装备 序列号
function CMD.add_equipment_info(_user_id,_eqpt_data)

    _eqpt_data.player_id = _user_id
    _eqpt_data.no = PUBLIC.auto_inc_id("last_equipment_no")

    local _old = LD.equipment_data:get_data(_user_id) or {}
    _old[_eqpt_data.no] = _eqpt_data
    _old[_eqpt_data.no].player_id = _user_id


    local _sql = PUBLIC.safe_insert_sql("player_equipment_data",_old[_eqpt_data.no],"no")
    local _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")

    LD.equipment_data:add_or_update_data(_user_id,_old,_qname,_qid)

    return _eqpt_data.no
end

-- 删除装备
function CMD.del_equipment_info(_user_id,_eqpt_id)


    local _old = LD.equipment_data:get_data(_user_id)
    if not _old or not _old[_eqpt_id] then
        return
    end

    _old[_eqpt_id] = nil
    local _qname,_qid = PUBLIC.db_exec_call(PUBLIC.format_sql("delete from player_equipment_data where no=%s;",_eqpt_id),"slow")

    LD.equipment_data:add_or_update_data(_user_id,_old,_qname,_qid)
end

function CMD.modify_equipment_info(_user_id,_data)

    local _old = LD.equipment_data:get_data(_user_id)
    _old = _old or {
        player_id=_user_id,        
    }

    local _qname,_qid
    for _eqpt_no,_d in pairs(_data) do  -- 比较，有变化则更新

        if not _old[_eqpt_no] or not basefunc.compare_vaule_same( _d , _old[_eqpt_no] ) then
        
            _old[_eqpt_no] = basefunc.merge(_d,_old[_eqpt_no])

            local _sql = PUBLIC.safe_insert_sql("player_equipment_data",_old[_eqpt_no],"no")
            _qname,_qid = PUBLIC.db_exec_call(_sql,"slow")
        end
    end
    
    if _qname then  -- 有更新
        LD.equipment_data:add_or_update_data(_user_id,_old,_qname,_qid)
    end
end

function CMD.query_equipment_info(_user_id)
    return LD.equipment_data:get_data(_user_id)
end

return LF
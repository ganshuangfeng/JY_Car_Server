--
-- Author: yy
-- Date: 2018/3/28
-- Time: 15:39
-- 说明：验证相关函数库

local skynet = require "skynet_plus"
local base = require "base"
require"printfunc"
local md5 = require "md5.core"

local cjson = require "cjson"
local basefunc = require "basefunc"

local CMD=base.CMD
local PUBLIC=base.PUBLIC
local DATA=base.DATA

local LD = base.LocalData("man_gm_user_list",{
	-- 用户列表： id => true
	gm_users = {},
})

local LF = base.LocalFunc("man_gm_user_list")

function LF.init()
	local ret = PUBLIC.db_query("select * from gm_user_list;")
	for _,v in ipairs(ret) do
		LD.gm_users[v.id] = 1
	end

	skynet.set_global_data("gm_user_list",LD.gm_users)
end

function CMD.add_gm_user(_id,_real_name)

	LD.gm_users[_id] = 1

	local _datas = {
		id=_id,
		real_name=_real_name,
	}
	PUBLIC.db_exec(PUBLIC.safe_insert_sql("gm_user_list",_datas,{"id"}))

	skynet.set_global_data("gm_user_list",LD.gm_users)
end

function CMD.del_gm_user(_id)

	LD.gm_users[_id] = nil
	
	PUBLIC.db_exec_va("delete from gm_user_list where id=%s;",_id)

	skynet.set_global_data("gm_user_list",LD.gm_users)
end

return LF


------ 引用 具体的 逻辑代码
--local game_dis_next_logic = require "driver_room_service.fsm_logic.game_dis_next_logic"
--local player_nor_op_logic = require "driver_room_service.fsm_logic.player_nor_op_logic"
--local running_status_logic = require "driver_room_service.fsm_logic.running_status_logic"

-------------------
local basefunc = require "basefunc"
local base = require "base"
local DATA = base.DATA

DATA.fsm_table_lib_protect = {}
local fsm_table_lib = DATA.fsm_table_lib_protect
local C = fsm_table_lib


----- 枚举出 各种状态
C.stateNameToInfo = basefunc.DataTable.new(

		{	"stateKey"            , "stateName"                ,   "slotName"   ,     "className"	    },
	{
		{	"change_game_round"   , "change_game_round"	       ,   "car_main"   ,  game_dis_next_logic  },
		{	"nor_op"              , "nor_op"	               ,   "car_main"   ,  player_nor_op_logic     },
		{	"running"             , "running"	               ,   "car_main"   ,  running_status_logic        },
		{	"select_in_3"         , "select_in_3"	           ,   "car_main"   ,  select_in_3_logic    },
                 
	}

):index("stateName")

---- 列举出各个状态的切换关系
C.stateFsmTable = {
	default = basefunc.DataTableMap.new({

		car_main = basefunc.DataTable.new(
				{	"name"		              ,    "nor_op"	    ,    "running"		,    "select_in_3"    ,  "change_game_round"	},
			{
				{	"change_game_round"	      ,    "wait"	    ,     "wait"	    ,     "wait"	      ,   "refresh"         },
				{	"nor_op"	              ,    "refresh"	,     "discardNew"	,     "discardNew"	  ,   "replace"         },
				{	"running"		          ,    "discardCur"	,     "refresh"	    ,     "wait"	      ,   "replace"	        },
				{	"select_in_3"	          ,    "replace"	,     "replace"	    ,     "refresh"	      ,   "replace"	        },
			}
		),
				
	}),

}




function C.getStateName(stateKey)
	return C.stateNameToInfo:query( { stateKey = stateKey } )["stateName"]
end

function C.getSlotName(stateKey)

    return C.stateNameToInfo:query( { stateKey = stateKey } )["slotName"]
end 

function C.getStatusClassName(stateKey)

    return C.stateNameToInfo:query({stateKey = stateKey})["className"]
end 

function C.getStatusOtherData(stateKey)
	return C.stateNameToInfo:query({stateKey = stateKey})["other_data"]
end

--创建一个状态数据包 acceptObject是数据包的发出者 用来接受消息 必须含有acceptMes(data)函数
function C.createStateData(stateKey , data ) 
	return { 
			stateName = C.getStateName( stateKey ) , 
			slotName = C.getSlotName(stateKey) , 
			className = C.getStatusClassName(stateKey) , 
			other_data = C.getStatusOtherData(stateKey) , 
			data = data , }
end

return C
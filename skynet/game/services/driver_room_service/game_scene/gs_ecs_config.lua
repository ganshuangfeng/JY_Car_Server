--
-- Author: lyx
-- Date: 2018/5/17
-- 说明：ecs 配置
--[[

]]

return {

    -- 组件
    components = 
    {
        --------------------------------------------------------------------------- singleton_com  单例组件
        map_info_com = "driver_room_service/game_scene/components/singleton_com/map_info_com",

        

        --------------------------------------------------------------------------- other
        game_dis_com = "driver_room_service/game_scene/components/game_dis_com",
        money_com = "driver_room_service/game_scene/components/money_com",
        move_com = "driver_room_service/game_scene/components/move_com",
        move_drive_nor_com = "driver_room_service/game_scene/components/move_drive_nor_com",
        owner_com = "driver_room_service/game_scene/components/owner_com",
        position_com = "driver_room_service/game_scene/components/position_com",
        position_relation_com = "driver_room_service/game_scene/components/position_relation_com",
        room_com = "driver_room_service/game_scene/components/room_com",
        
        owner_road_com = "driver_room_service/game_scene/components/owner_road_com",

        --------------------------------------------------------------------------- tag  
        car_com = "driver_room_service/game_scene/components/tag_com/car_com",
        map_item_com = "driver_room_service/game_scene/components/tag_com/map_item_com",
        player_com = "driver_room_service/game_scene/components/tag_com/player_com",
        road_com = "driver_room_service/game_scene/components/tag_com/road_com",
        skill_com = {  is_simple = true  },

        --------------------------------------------------------------------------- event 
        --- 位置移动进入 组件
        event_position_move_in_com = {  is_simple = true  },   --- 进入

        --- 位置移动 停留 组件
        event_position_stay_road_com = {  is_simple = true  },      ---- 停留 路面
        event_position_stay_side_com = {  is_simple = true  },      ---- 停留 路边

        --- 位置 移出
        event_position_move_out_com = {  is_simple = true  },

        --- buffer 创建
        event_buffer_create_com = { is_simple = true },

        --------------------------------------------------------------------------- skill
        skill_add_money_com = "driver_room_service/game_scene/components/skill/skill_add_money_com",
        skill_sprint_com = "driver_room_service/game_scene/components/skill/skill_sprint_com",

        skill_receiver_base_com = "driver_room_service/game_scene/components/skill/skill_receiver_base_com",
        skill_receiver_for_trigger_com = "driver_room_service/game_scene/components/skill/skill_receiver_for_trigger_com",
        skill_trigger_base_com = "driver_room_service/game_scene/components/skill/skill_trigger_base_com",

        --------------------------------------------------------------------------- buffer
        ------------------------------------------- buffer的触发
        buffer_trigger_base_com = "driver_room_service/game_scene/components/buffer/buffer_trigger_base_com",
        --buffer创建时触发
        buffer_trigger_on_create_com = {  is_simple = true  },
        -- 间隔轮次触发
        buffer_trigger_round_interval_com = {  is_simple = true  },

        ------------------------------------------- buffer触发后,是否可以作用
        buffer_trigger_base_com = "driver_room_service/game_scene/components/buffer/buffer_trigger_base_com",

    },

    -- 系统
    --[[systems_list = 
    {
        
        [1] = { sys_name = "game_dis_sys" , path = "driver_room_service/game_scene/systems/game_dis_sys" } ,
        [2] = { sys_name = "move_drive_nor_sys" , path = "driver_room_service/game_scene/systems/move_drive_nor_sys" } ,
        [3] = { sys_name = "move_sys" , path = "driver_room_service/game_scene/systems/move_sys" } ,
        [4] = { sys_name = "position_relation_sys" , path = "driver_room_service/game_scene/systems/position_relation_sys" } ,

        [5] = { sys_name = "skill_trigger_move_in_sys" , path = "driver_room_service/game_scene/systems/skill/skill_trigger_move_in_sys" } ,
        [6] = { sys_name = "skill_trigger_stay_sys" , path = "driver_room_service/game_scene/systems/skill/skill_trigger_stay_sys" } ,
        [7] = { sys_name = "skill_receiver_for_trigger_sys" , path = "driver_room_service/game_scene/systems/skill/skill_receiver_for_trigger_sys" } ,
        
        [8] = { sys_name = "skill_add_money_sys" , path = "driver_room_service/game_scene/systems/skill/skill_add_money_sys" } ,
        [9] = { sys_name = "skill_sprint_sys" , path = "driver_room_service/game_scene/systems/skill/skill_sprint_sys" } ,

        [10] = { sys_name = "skill_trigger_base_sys" , path = "driver_room_service/game_scene/systems/skill/skill_trigger_base_sys" } ,
    },--]]

    --- 实体
    entity = {
        
    },


    --- buffer 定义
    buffer = {
        [1] = {

        },

    }


}

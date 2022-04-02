# pceggs：备份上期数据，并加入新的字段值
insert into cpl_pceggs_data_p1(id,ddz_round_count,device_id,payment,win_jingbi,`name`,old_player)
select a.id,a.ddz_round_count,b.device_id,ifnull(c.sum_money,0) payment,e.process,d.`name`,1 old_player 
from pceggs_player_data a
inner join player_register b on a.id = b.id
left join player_pay_order_stat c on a.id = c.player_id
inner join player_info d on a.id = d.id
left join player_task e on a.id = e.player_id and e.task_id = 108


# pceggs：生成当期数据（延续之前的玩家，但 清空数据）
insert into cpl_pceggs_data(id,ddz_round_count,device_id,payment,win_jingbi,`name`,old_player)
select a.id,0,b.device_id,0 payment,0,d.`name`,1 old_player 
from pceggs_player_data a
inner join player_register b on a.id = b.id
inner join player_info d on a.id = d.id


# xianwan: 升级数据（注意，一定要先备份表）
update cpl_xianwan_data a 
inner join player_info d on a.id = d.id
left join player_task e on a.id = e.player_id and e.task_id = 67
set a.win_jingbi=e.process,a.`name`=d.`name`
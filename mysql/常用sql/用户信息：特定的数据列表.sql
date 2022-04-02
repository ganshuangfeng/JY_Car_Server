select 
a.id,
a.register_time,
to_days(now())-to_days(a.register_time) reg_days,
b._count login_count,
c._count match_count,
d._count free_count,
e._count friend_count,
f.money pay

from player_register a 
left join (select id,count(*) _count from player_login_log group by id ) b on a.id = b.id
left join (select player_id,count(*) _count from (select player_id,match_id from match_nor_player_log group by player_id,match_id) a group by player_id ) c on a.id = c.player_id
left join (select player_id,count(*) _count from (select player_id,match_id from freestyle_race_player_log group by player_id,match_id) a group by player_id ) d on a.id = d.player_id
left join (select player_id,count(*) _count from (
		select p1_id player_id from friendgame_history_record
		union all
		select p2_id player_id from friendgame_history_record
		union all
		select p3_id player_id from friendgame_history_record
		union all
		select p3_id player_id from friendgame_history_record
) a group by player_id ) e on a.id = e.player_id
left join (
	select player_id,sum(money) money from (
	select player_id,money from player_pay_order where order_status='complete'  
	union all 
	select player_id,money from player_pay_order_log where order_status='complete'
) a group by player_id) f on a.id = f.player_id

where a.id in (
'1046458',
'1017833',
'1097864',
'10822456',
'102093149',
'10291004',
'10821473',
'1030700',
'10795214',
'1088742',
'10192749',
'102056784',
'102097435',
'101820237',
'10601772',
'10195185',
'102085139',
'102110939',
'101142123',
'101816225',
'1011721',
'102081332',
'102138250',
'1079814',
'101756250',
'102063379',
'102080218',
'10529189',
'10815433',
'101116542',
'10127348',
'101701031',
'10180953',
'101818373',
'102098063',
'102102659',
'102118109',
'102139620',
'10293304',
'10680179',
'1089878',
'101100416',
'101660913',
'101691183',
'102065635',
'102092837',
'102106127',
'102114420',
'102124369',
'10267902',
'10403389',
'10542201',
'10542627',
'10591088',
'101345678',
'101407191',
'101419180',
'101642683',
'101797475',
'101799621',
'101841875',
'102062023',
'102085671',
'102099135',
'102099393',
'10213363',
'1028464',
'10422688',
'1046778',
'101011634',
'10112133',
'101258473',
'101370792',
'102058263',
'102060582',
'102070986',
'102093992',
'102109544',
'102140742',
'1034573',
'1049265',
'10671924',
'10708132',
'1085868',
'10109200',
'101595084',
'101715144',
'10180605',
'101894027',
'101899879',
'101942126',
'102077987',
'102084227',
'102088815',
'102090358',
'102092049',
'10211155',
'102115471',
'10267533',
'1031002',
'1036385',
'1038491',
'10397341',
'10401461',
'1052368',
'1061680',
'1062667',
'10763438',
'101062461',
'10152502',
'101813608',
'101819355',
'101894068',
'102074127',
'102085853',
'102091360',
'102096676',
'102102213',
'102108253',
'10405546',
'1057839',
'101009825',
'101074680',
'10158438',
'101817542',
'102057050',
'102066465',
'102081105',
'102090971',
'102098826',
'102099985',
'102106239',
'102118255',
'102118971',
'10218461',
'10437629',
'1055275',
'10721349',
'10883133',
'10932105',
'1093770',
'101753536',
'101812638',
'102056744',
'102082921',
'102089834',
'102091635',
'102097285',
'10401791',
'105801',
'1063380',
'10978596',
'1042357',
'1059523',
'10590444',
'10961208',
'1021278'
)









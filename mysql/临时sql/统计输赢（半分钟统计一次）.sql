CREATE DEFINER=`jy`@`%` PROCEDURE `tongji_shuying`(IN player_id varchar(50), IN `start_time` datetime, IN `end_time` datetime)
    SQL SECURITY INVOKER
BEGIN

	declare last_time datetime;
	set last_time = start_time;
	
	delete from tmp_tongji_shuying;

	repeat

		insert into tmp_tongji_shuying(id,date,current,change_value) select id,date,current,change_value from player_asset_log where id = player_id and date > last_time and date <= end_time limit 1;
		
		set last_time = DATE_ADD(last_time,INTERVAL 30 SECOND);
	
	until ROW_COUNT() = 0 end repeat;
	
	select * from tmp_tongji_shuying;

END
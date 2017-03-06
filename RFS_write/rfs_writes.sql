set lines 200
select 	inst_id,round(WAIT_TIME_MILLI/1000,2) wait_secs, 
	last_update_time when, 
	wait_count "How_many_times||since startup"
from GV$EVENT_HISTOGRAM 
where event like 'RFS write%'
--and round(WAIT_TIME_MILLI/1000,2)
order by 2 desc;

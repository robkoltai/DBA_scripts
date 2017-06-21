-- ASH WITH SQL
SELECT  distinct a.sql_id, a.blocking_session,a.blocking_session_serial#,
a.user_id,s.sql_text,a.module
FROM  V$ACTIVE_SESSION_HISTORY a, v$sql s
where a.sql_id=s.sql_id
and blocking_session is not null
and a.user_id <> 0 
and a.sample_time between to_date('17/06/2011 00:00', 'dd/mm/yyyy hh24:mi') 
and to_date('17/06/2011 23:50', 'dd/mm/yyyy hh24:mi');

-- ASH
select sql_id,event, count(1)
from v$active_session_history
where sample_time > to_date('05032015 10:00:00','ddmmrrrr hh24:mi:ss')
and   sample_time < to_date('05032015 11:00:00','ddmmrrrr hh24:mi:ss')
and event like '%TM%'
group by sql_id,event
order by 3 desc;
 
-- DASH
select sql_id,event, count(1)
from dba_hist_active_sess_history
where sample_time > to_date('05032015 10:00:00','ddmmrrrr hh24:mi:ss')
and   sample_time < to_date('05032015 11:00:00','ddmmrrrr hh24:mi:ss')
and event like '%TM%'
group by sql_id,event
order by 3 desc;

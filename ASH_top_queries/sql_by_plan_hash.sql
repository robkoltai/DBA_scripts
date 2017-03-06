-- SQL BY PLAN HASH VALUE
set lines 1111
select count(1),
     --session_id,
     -- event,
     --sql_id, 
     sql_opname,
     --top_level_sql_id, 
     sql_plan_hash_value
from v$active_session_history 
where sample_time > sysdate - 55/(60*24)
group by 
     --session_id,
     -- event,
     --sql_id, 
     sql_opname,
     --top_level_sql_id, 
     sql_plan_hash_value
order by count(1) desc;

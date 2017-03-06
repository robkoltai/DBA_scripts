
break on plan_hash_value on startup_time skip 1
select sql_id, plan_hash_value, sum(execs) execs, sum(etime) etime, sum(etime)/sum(execs) avg_etime, sum(lio)/sum(execs) avg_lio
from (
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
elapsed_time_delta/1000000 etime,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
buffer_gets_delta lio,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','4dqs2k5tynk61')
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
)
group by sql_id, plan_hash_value
order by 5
/
Enter value for sql_id: 0qa98gcnnza7h
 
SQL_ID        PLAN_HASH_VALUE        EXECS          ETIME    AVG_ETIME        AVG_LIO
------------- --------------- ------------ -------------- ------------ --------------
0qa98gcnnza7h       568322376           14          288.7       20.620      172,547.4
0qa98gcnnza7h      3723858078            2          313.4      156.715   28,901,466.0
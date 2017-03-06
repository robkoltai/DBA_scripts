
break on plan_hash_value on startup_time skip 1
 select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
  nvl(executions_delta,0) execs,
  (elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
  (buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
  from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
  where sql_id = nvl('&sql_id','4dqs2k5tynk61')
  and ss.snap_id = S.snap_id
  and ss.instance_number = S.instance_number
  and executions_delta > 0
  order by 1, 2, 3
 /
 
 
 Enter value for sql_id: 0qa98gcnnza7h
  
    SNAP_ID   NODE BEGIN_INTERVAL_TIME            SQL_ID        PLAN_HASH_VALUE        EXECS    AVG_ETIME        AVG_LIO
 ---------- ------ ------------------------------ ------------- --------------- ------------ ------------ --------------
      21857      1 20-MAR-09 04.00.08.872 PM      0qa98gcnnza7h       568322376            1       31.528      173,854.0
      22027      1 27-MAR-09 05.00.08.006 PM      0qa98gcnnza7h                            1      139.141      156,807.0
      22030      1 27-MAR-09 08.00.15.380 PM      0qa98gcnnza7h                            3       12.451      173,731.0
      22031      1 27-MAR-09 08.50.04.757 PM      0qa98gcnnza7h                            2        8.771      173,731.0
      22032      1 27-MAR-09 08.50.47.031 PM      0qa98gcnnza7h      3723858078            1      215.876   28,901,466.0
      22033      1 27-MAR-09 08.57.37.614 PM      0qa98gcnnza7h       568322376            2        9.804      173,731.0
      22034      1 27-MAR-09 08.59.12.432 PM      0qa98gcnnza7h      3723858078            1       97.554   28,901,466.0
      22034      1 27-MAR-09 08.59.12.432 PM      0qa98gcnnza7h       568322376            2        8.222      173,731.5
      22035      1 27-MAR-09 09.12.00.422 PM      0qa98gcnnza7h                            3        9.023      173,807.3
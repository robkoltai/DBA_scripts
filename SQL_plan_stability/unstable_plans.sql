break on plan_hash_value on startup_time skip 1
 select * from (
 select sql_id, sum(execs), min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev
 from (
 select sql_id, plan_hash_value, execs, avg_etime,
 stddev(avg_etime) over (partition by sql_id) stddev_etime
 from (
 select sql_id, plan_hash_value,
 sum(nvl(executions_delta,0)) execs,
 (sum(elapsed_time_delta)/decode(sum(nvl(executions_delta,0)),0,1,sum(executions_delta))/1000000) avg_etime
 -- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
 from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
 where ss.snap_id = S.snap_id
 and ss.instance_number = S.instance_number
 and executions_delta > 0
 and elapsed_time_delta > 0
 group by sql_id, plan_hash_value
 )
 )
 group by sql_id, stddev_etime
 )
 where norm_stddev > nvl(to_number('&min_stddev'),2)
 and max_etime > nvl(to_number('&min_etime'),.1)
 order by norm_stddev
 /

 
SQL_ID        SUM(EXECS)   MIN_ETIME   MAX_ETIME   NORM_STDDEV
------------- ---------- ----------- ----------- -------------
1tn90bbpyjshq         20         .06         .24        2.2039
0qa98gcnnza7h         16       20.62      156.72        4.6669
7vgmvmy8vvb9s        170         .04         .39        6.3705
32whwm2babwpt        196         .02         .26        8.1444
5jjx6dhb68d5v         51         .03         .47        9.3888
71y370j6428cb        155         .01         .38       19.7416
66gs90fyynks7        163         .02         .55       21.1603
b0cxc52zmwaxs        197         .02         .68       23.6470
31a13pnjps7j3        196         .02        1.03       35.1301
7k6zct1sya530        197         .53       49.88       65.2909

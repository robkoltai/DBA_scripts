--https://savvinov.com/2016/04/25/unstable-query-performance-a-case-study/


select sn.begin_interval_time, 
       plan_hash_value, 
       executions_delta, 
       round(elapsed_time_delta/1e6/decode(executions_delta, 0, 1, executions_delta), 3) sec_per_exec, 
       round(disk_reads_delta/decode(executions_delta,0,1, executions_delta),1) reads_per_exec, 
       round(buffer_gets_delta/decode(executions_delta,0,1, executions_delta), 1) gets_per_exec, 
       round(iowait_delta/1000/nullif(disk_reads_delta, 0), 1) avg_read_msec,
       round(100*(1-disk_reads_delta/nullif(buffer_gets_delta, 0)), 6) bchr, 
       round(rows_processed_delta/decode(executions_delta,0, 1, executions_delta), 1) rows_per_exec
from dba_hist_sqlstat st,
    dba_hist_snapshot sn
where st.snap_id = sn.snap_id
and sql_id = nvl(:sql_id, sql_id)
and force_matching_signature = nvl(:sig, force_matching_signature)
order by sn.snap_id desc
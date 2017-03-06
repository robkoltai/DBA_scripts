column force_matching_signature format 99999999999999999999999
col avg_lio for 999,999,999.9
col begin_interval_time heading "Snap|Begin" for a14
col node for 99999
break on plan_hash_value on startup_time skip 1
set lines 500
-- counts
col execs for 999,999,999
-- times
col etime for 999,999,999.999
col cpu for 999,999,999.999
col etime for 999,999.999
col iowait for   999,999,999.999
col clwait for   999,999.999
col apwait for   999,999.999
col ccwait for   999,999.999
column sqlid_count heading "sqlid|count" format 99999999
column example_sql_id heading "example|sql_id" 


SELECT
    --to_char(TRUNC(sample_time,'HH24'),'YYYYMMDD HH24') hour
    to_char(TRUNC(sample_time,'MI'),'YYYYMMDD HH24:MI') minute
    --to_char(sample_time,'YYYYMMDD HH24:MI:SS') sec
  , min (SQL_id) example_sql_id
  , COUNT(distinct sql_id)
  , count(*)
  , force_matching_signature
FROM
    v$active_session_history
    --dba_hist_active_sess_history
WHERE
    force_matching_signature <>0
GROUP BY
    --to_char(TRUNC(sample_time,'HH24'),'YYYYMMDD HH24') 
    to_char(TRUNC(sample_time,'MI'),'YYYYMMDD HH24:MI')
    --to_char(sample_time,'YYYYMMDD HH24:MI:SS') 
  ,force_matching_signature
HAVING  COUNT(distinct sql_id)> 5
ORDER BY
    --hour
    minute 
    --sec
    , count(*)
  ;


select ss.snap_id, ss.instance_number node, 
       to_char(begin_interval_time,'YYYYMMDD HH24:MI') begin_interval_time, force_matching_signature,
-- MAIN
  count(distinct sql_id) sqlid_count, 
  count(*),
  min (sql_id) example_sql_id,
  sum(nvl(executions_delta,0)) execs,
  sum(elapsed_time_delta/1000000) etime,
  sum(CPU_TIME_DELTA/1000000) cpu,
-- WAIT
  sum(IOWAIT_DELTA) iowait,
  sum(CLWAIT_DELTA) clwait,
  sum(APWAIT_DELTA) apwait,
  sum(CCWAIT_DELTA) ccwait
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where executions_delta > 0 
  and ss.snap_id = S.snap_id
  and ss.instance_number = S.instance_number
  and force_matching_signature<>0
group by ss.snap_id, ss.instance_number, 
 to_char(begin_interval_time,'YYYYMMDD HH24:MI'), force_matching_signature
having count(distinct sql_id) > 5
order by 1, 2, 3;



-- TEST DATA
alter system flush shared_pool;
set serveroutput on;

declare
      type rc is ref cursor;
      l_rc rc;
      l_dummy all_objects.object_name%type;
      l_start number default dbms_utility.get_time;
  begin
      for i in 1 .. 500
      loop
          open l_rc for
          'select /* NOBIND */ object_name from all_objects where object_id = ' || i;
          fetch l_rc into l_dummy;
          close l_rc;
          -- dbms_output.put_line(l_dummy);
      end loop;
      dbms_output.put_line
       (round((dbms_utility.get_time-l_start)/100, 2) ||
        ' Seconds...' );
  end;
/

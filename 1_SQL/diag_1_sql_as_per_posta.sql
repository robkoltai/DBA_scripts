-- What do we have in the cursor cache
select * from v$sql where sql_id = 'azgd8vrx5xqkx';

-- What are the recend DASH entries 
-- DETAILED
select sample_time st, session_id, session_serial#, sql_exec_id, sql_plan_hash_value, sql_child_number, 
  dash.* 
from dba_hist_active_sess_history dash
where sql_id = 'azgd8vrx5xqkx'
  and sample_time > to_date('20200123 21:05','YYYYMMDD HH24:MI')
order by st desc;

-- Individual RUNS
select count(1) sample_cnt, 
  session_id, session_serial#, sql_exec_id, sql_plan_hash_value, sql_child_number
from dba_hist_active_sess_history dash
where sql_id = 'azgd8vrx5xqkx'
  and sample_time > to_date('20200123 21:05','YYYYMMDD HH24:MI')
group by session_id, session_serial#, sql_exec_id, sql_plan_hash_value, sql_child_number
order by sample_cnt desc;

-- Individual RUNS more info
select count(1) sample_cnt, 
  session_id, session_serial#, count(distinct sql_exec_id) sampled_executions, 
   to_char(min(sample_time),'YYYYMMDD HH24:MI') start_feldolg, 
   to_char(max(sample_time),'YYYYMMDD HH24:MI') end_feldolg, 
  sql_plan_hash_value, sql_child_number
from dba_hist_active_sess_history dash
where sql_id = 'azgd8vrx5xqkx'
  and sample_time > to_date('20200123 21:05','YYYYMMDD HH24:MI')
group by session_id, session_serial#, sql_plan_hash_value, sql_child_number
order by sample_cnt desc;

-- INDIVIDUAL RUNS no bind, force matching signature, similar queries
select count(1) sample_cnt, 
  session_id, session_serial#, sql_exec_id, sql_plan_hash_value, sql_child_number, dash.force_matching_signature, sql_id,
  to_char(min(dash.sample_time),'MMDD HH24:MI:SS') mintime,
  to_char(max(dash.sample_time),'MMDD HH24:MI:SS') maxtime
from dba_hist_active_sess_history dash
where sql_id = '7yk8xa71z79rr' or force_matching_signature = 13418783525375212701
  --and sample_time > to_date('20200123 21:05','YYYYMMDD HH24:MI')
group by session_id, session_serial#, sql_exec_id, sql_plan_hash_value, sql_child_number,dash.force_matching_signature, sql_id
order by sample_cnt desc;



-- How about the ACTION?
select count(1) sample_cnt, action,
  session_id, session_serial#, count(distinct sql_exec_id) sampled_executions, 
   to_char(min(sample_time),'YYYYMMDD HH24:MI') start_feldolg, 
   to_char(max(sample_time),'YYYYMMDD HH24:MI') end_feldolg, 
  sql_plan_hash_value, sql_child_number
from dba_hist_active_sess_history dash
where sql_id = 'azgd8vrx5xqkx'
  and sample_time > to_date('20200123 21:05','YYYYMMDD HH24:MI')
group by action, session_id, session_serial#, sql_plan_hash_value, sql_child_number
order by sample_cnt desc;

-- Compare child cursor statistics
-- CHILD 1 vs CHILD 0
select child_number,
       executions,
       round(elapsed_time/executions,2) ela_perexe_us,
       round(cpu_time/executions,2) cpu_perexe_us,
       round(user_io_wait_time/executions,2) iowait_perexe_us,
       round(disk_reads/executions,2) diskread_perexe,
       round(buffer_gets/executions,2) gets_perexe_us,
       round(concurrency_wait_time/executions,2) lockwait_perexe_us,
       round(rows_processed/executions,2) rows_processed_perexe,
 vsql.* from v$sql vsql
where sql_id = 'azgd8vrx5xqkx'
order by 1
;


-- CHILD MISMATCH REASONS?
select * from v$sql_shared_cursor where sql_id ='azgd8vrx5xqkx';
/*
<ChildNode><ChildNumber>1</ChildNumber><ID>44</ID><reason>
NLS Settings(2)</reason><size>2x568</size>
<NLS_LANGUAGE>'AMERICAN'->'HUNGARIAN'</NLS_LANGUAGE>
<NLS_DATE_LANGUAGE>'AMERICAN'->'HUNGARIAN'</NLS_DATE_LANGUAGE>
</ChildNode>
*/


select * from v$active_session_history
where sql_id = 'azgd8vrx5xqkx' order by 1 desc;


-- Check a specific SESSION
-- TOP level SQL_ID: as274cpbbyc51
select * 
from dba_hist_active_sess_history dash
where session_id = 3601	and session_serial#=43134
order by sample_time desc;

-- TOP LEVEL
-- CHECKS by TOP_LEVEL_SQL_ID 
-- What is the most important SQL coming from a job or a PLSQL call
select round(count(1)/6,2) perc,ash.sql_id, 
--ash.sql_child_number, --ash.sql_plan_line_id, 
--session_id, sql_exec_id, 
  to_char(max(ash.sample_time),'MMDD HH24:MI:SS') maxtime, to_char(min(ash.sample_time),'MMDD HH24:MI:SS') mintime, --ash.sql_plan_hash_value,
  substr(vsql.sql_text,1,2000)
from dba_hist_active_sess_history ash, v$sqlarea vsql
where ash.sql_id = vsql.sql_id (+) --and ash.sql_child_number = vsql.child_number
  and ash.top_level_sql_id = 'as274cpbbyc51'
  --where sql_id = '73c46cmkkjuzj' 
  group by ash.sql_id, --ash.sql_child_number, --ash.sql_plan_line_id, 
--sql_exec_id, session_id, 
--ash.sql_plan_hash_value,
  substr(vsql.sql_text,1,2000)
order by 1 desc;



-- GROUP BY PLAN HASH VALUE
select count(1),sql_id, sql_child_number, session_id, sql_exec_id, 
  to_char(max(sample_time),'MMDD HH24:MI:SS') maxtime, to_char(min(sample_time),'MMDD HH24:MI:SS') mintime, sql_plan_hash_value, SQL_FULL_PLAN_HASH_VALUE
from v$active_session_history
where sql_id = 'xxx' 
group by sql_id, sql_child_number, sql_exec_id, session_id, sql_plan_hash_value,SQL_FULL_PLAN_HASH_VALUE
order by 1 desc;

-- PLAN LINE ID
select count(1),sql_id, sql_child_number, sql_plan_line_id, 
  --session_id, sql_exec_id, 
  to_char(max(sample_time),'MMDD HH24:MI:SS') maxtime, to_char(min(sample_time),'MMDD HH24:MI:SS') mintime ,sql_plan_hash_value, SQL_FULL_PLAN_HASH_VALUE
from v$active_session_history
where sql_id = 'azgd8vrx5xqkx' 
group by sql_id, sql_child_number, sql_plan_line_id, SQL_FULL_PLAN_HASH_VALUE
  --sql_exec_id, session_id, 
  sql_plan_hash_value
order by 1 desc;


-- PLAN LINE ID and EVENT
select count(1),sql_id, sql_child_number, sql_plan_line_id, event,
--session_id, sql_exec_id, 
to_char(max(sample_time),'MMDD HH24:MI:SS') maxtime, to_char(min(sample_time),'MMDD HH24:MI:SS') mintime ,sql_plan_hash_value, SQL_FULL_PLAN_HASH_VALUE
from v$active_session_history
where sql_id = 'azgd8vrx5xqkx' 
group by sql_id, sql_child_number, sql_plan_line_id, , SQL_FULL_PLAN_HASH_VALUE
--sql_exec_id, session_id, 
sql_plan_hash_value, event
order by 1 desc;

-- SQL MONITOR REPORT
--attekinto URES
SELECT dbms_sqltune.Report_sql_monitor_list(SQL_ID=>'xx', TYPE=>'text',report_level=>'ALL') rep
FROM   dual;

-- reszletes
SELECT dbms_sqltune.Report_sql_monitor(SQL_ID=>'xx', TYPE=>'text',report_level=>'ALL', sql_exec_id => 16777439) rep
FROM   dual;

-- child 
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('azgd8vrx5xqkx', null, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE'))
/

select * from nls_database_parameters;


-- GET SQL TEXT from SQLAREA
-- FILTER FOR TOP LEVEL SQL
select round(count(1)/60,2) perc,ash.sql_id, 
--ash.sql_child_number, --ash.sql_plan_line_id, 
--session_id, sql_exec_id, 
  to_char(max(ash.sample_time),'MMDD HH24:MI:SS') maxtime, to_char(min(ash.sample_time),'MMDD HH24:MI:SS') mintime, --ash.sql_plan_hash_value,
  substr(vsql.sql_text,1,2000)
from v$active_session_history ash, v$sqlarea vsql
where 
  1=1 
  and sample_time>to_date('20200117 11:00','YYYYMMDD hh24:MI')
  and ash.sql_id = vsql.sql_id (+) --and ash.sql_child_number = vsql.child_number
  and ash.top_level_sql_id = '3f3mrnmhxm9wh'
  --where sql_id = '73c46cmkkjuzj' 
  group by ash.sql_id, --ash.sql_child_number, --ash.sql_plan_line_id, 
--sql_exec_id, session_id, 
--ash.sql_plan_hash_value,
  substr(vsql.sql_text,1,2000)
order by 1 desc;


/*
Using the V$SQL_WORKAREA_HISTOGRAM View
Using the V$WORKAREA_ACTIVE View
Using the V$SQL_WORKAREA View
*/

-- OPTIMAL, ONE PASS, MULTIPASS
-- sort statisztika
select * from V$SQL_WORKAREA_ACTIVE;
select * from V$SQL_WORKAREA where sql_id='4vukqbbung1g7';
select * from V$SQL_WORKAREA_HISTOGRAM;
select * from v$pgastat;

select * from dba_objects where object_name like '%WORKAREA%';

-- PGA TEMP EVENT per EXEC ID
select sum(10), sql_exec_id, 
  sql_plan_line_id, 
  sql_plan_hash_value,
  to_char(min(dash.sql_exec_start),'MMDD HH24:MI:SS') startt,
  to_char(min(dash.sample_time),'MMDD HH24:MI:SS') mintime,
  to_char(max(dash.sample_time),'MMDD HH24:MI:SS') maxtime,
  (max(dash.sample_time) - min(dash.sample_time)) dur, --*(24*60*60) dur_sec,
  count(distinct session_id ||session_serial#) sess_count,
  round(max(pga_allocated)/1024/1024,2) pga,
  round(max(temp_space_allocated)/1024/1024,2) tmp
from dba_hist_active_sess_history dash
where sql_id = '6cc5z6m27mfum'
  and sql_exec_id = 16777269
  --and sample_time > to_date('20200123 21:05','YYYYMMDD HH24:MI')
group by sql_exec_id, 
  sql_plan_line_id, 
  sql_plan_hash_value
order by dur desc;


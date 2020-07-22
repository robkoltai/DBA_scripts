set lines 320
set pages 500
column SQL_PLAN_OPERATION format a30
column SQL_PLAN_OPtions format a30
column event format a40
column program format a22
column top5_lines format a42

column object_long_name format a33
column TASK_NAME1 format a25

alter session set nls_date_format='YYYYMMDD HH24:MI:SS';
set heading on
set verify off
set trimspool on
set long 2000000
set longch 2000000

spool &sql_id._run0&test_run._01_APPLICATION.txt

PROMPT TBD

spool off;

-- ************************************************************************************************************************************************************************
spool &sql_id._run0&test_run._02_DISPLAY_AWR.txt

-- xplan
PROMPT ** XPLAN from AWR
PROMPT *****************
select * from TABLE(dbms_xplan.display_awr('&sql_id', format=>'advanced +note -alias +outline +predicate'));

spool off;
-- ************************************************************************************************************************************************************************
spool &sql_id._run0&test_run._03_DISPLAY_CURSOR.txt

SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', NULL, 'ADVANCED ALLSTATS ALL -PROJECTION +ADAPTIVE'))
/

spool off;
-- ************************************************************************************************************************************************************************
/*
spool &sql_id._run0&test_run._04_SQLMON.txt

-- historikus reszletes SQL MONITOR REPORT
PROMPT ** SQLMON REPORT
PROMPT *****************
select --substr(key4,1,instr(key4,'#')-1) as elapsed, 
  dbms_auto_report.Report_repository_detail(rid=>report_id,TYPE=>'TEXT') as z_report 
  --rep.* 
from dba_hist_reports rep 
where key1='&sql_id' order by period_start_time desc;

spool off;
*/
-- ************************************************************************************************************************************************************************

/*
spool &sql_id._run0&test_run._05_OWN.txt


PROMPT ******************************************
PROMPT ** DBA_HIST_ACTIVE_SESS_HISTORY analysis
PROMPT ******************************************
PROMPT ** CNT: SUM(10). ASH Sample count. Each sample is worth 10. So CNT can be interpreted as number of seconds.
PROMPT ** DIST_PRG: COUNT(DISTINCT PROGRAM), that is how many parallel processes were active for that aggregation level
PROMPT ****************************************** 


PROMPT ** Summary
PROMPT **********


-- JUST event for SQL
select sum(10) cnt, event, ash.sql_id
from dba_hist_active_sess_history ash
where 1=1
  and ash.sql_id = '&sql_id'
group by ash.sql_id, ash.event
order by 1 desc;

PROMPT ** By plan line and distinct program
PROMPT *************************************

-- FOCUS on Parallelism by plan line
select ash.sql_plan_line_id,
  sum(10) cnt, 
  count(distinct program) dist_prg, 
  ash.sql_plan_operation, ash.sql_plan_options, sql_id
from dba_hist_active_sess_history ash
where 1=1
  and ash.sql_id = '&sql_id'
group by ash.sql_plan_line_id, ash.sql_plan_operation, ash.sql_plan_options, sql_id
order by 1 nulls first, 2;

PROMPT ** By plan line and wait event		
PROMPT ******************************

-- Event by plan line
select ash.sql_plan_line_id,
  sum(10) cnt, event,
  ash.sql_plan_operation, ash.sql_plan_options, sql_id
from dba_hist_active_sess_history ash
where 1=1
  and ash.sql_id = '&sql_id'
group by ash.sql_plan_line_id, ash.sql_plan_operation, ash.sql_plan_options, sql_id, event
order by 1 nulls first, 2;

PROMPT ** Work Distribution
PROMPT ********************
PROMPT ** TOP5:LINES: TOP 5 PLAN lines and db time spent for the program (px server)

select
  ash.session_id, ash.session_serial#, ash.program,
  round(sum(tm_delta_time/1e6)) time_s, round(sum(tm_delta_cpu_time/1e6)) cpu_s, round(sum(tm_delta_db_time/1e6)) dbtime_s,
  round(sum(delta_read_io_bytes/1e9)) r_gb, round(sum(delta_write_io_bytes/1e9)) w_gb,
  round(max(pga_allocated/1e9)) pga_gb, round(max(temp_space_allocated/1e9)) tmp_gb,
  get_top5_lines (ash.sql_id, ash.program) top5_lines, 
  ash.sql_id
from dba_hist_active_sess_history ash
where 1=1
  and ash.sql_id = '&sql_id'
group by ash.session_id, ash.session_serial#, ash.program, ash.sql_id, get_top5_lines (ash.sql_id, ash.program)
order by 5 desc nulls last;

spool off;
*/

-- ************************************************************************************************************************************************************************
spool &sql_id._run0&test_run._07_XPLAN_ASH_CURR.txt


PROMPT ***********************************************************************************************************************************
PROMPT ** XPLAN_ASH **********************************************************************************************************************
PROMPT ***********************************************************************************************************************************
@xplan_ash_cmdline &sql_id ""  "" ""  "" ""  "" ""  "" "" 

spool off;
-- ************************************************************************************************************************************************************************
spool &sql_id._run0&test_run._08_XPLAN_ASH_AWR.txt


PROMPT ***********************************************************************************************************************************
PROMPT ** XPLAN_ASH **********************************************************************************************************************
PROMPT ***********************************************************************************************************************************
@xplan_ash_cmdline &sql_id ""  "" "HIST"  "" ""  "" ""  "" ""

spool off;


-- *********************************** TEXT MONITOR REPORT ******************************************
spool &sql_id._run0&test_run._09_TEXT_MONITOR.txt

select
dbms_auto_report.Report_repository_detail(rid=>report_id,TYPE=>'TEXT') as z_report
from dba_hist_reports rep
where key1='&sql_id' order by period_start_time desc;

spool off



-- *********************************** ACTIVE MONITOR REPORT ******************************************

set heading off
set pages 0
spool &sql_id._run0&test_run._10_ACTIVE_MONITOR.html

select 
dbms_auto_report.Report_repository_detail(rid=>report_id,TYPE=>'ACTIVE') as z_report
from dba_hist_reports rep 
where key1='&sql_id' order by period_start_time desc;

spool off

-- *********************************** SQL TEXT ******************************************


set heading off
set pages 0
set long   9000000
set longch 9000000
spool &sql_id._run0&test_run._11_SQL_TEXT.txt

select sql_text
from dba_hist_sqltext
where sql_id  = '&sql_id';

spool off;

-- *********************************** SQL TEXT EXPANDED ******************************************

-- Commented out as only selects are supported ...
/*


spool &sql_id._run0&test_run._12_SQL_TEXT_EXPANDED.txt

SET SERVEROUTPUT ON 
DECLARE
  v_clob CLOB;
  l_clob CLOB;
BEGIN
  select sql_text 
  into v_clob
  from dba_hist_sqltext
  where sql_id = '&sql_id';
  
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => v_clob,
    output_sql_text => l_clob
  );

  DBMS_OUTPUT.put_line(l_clob);
END;
/
spool off;
*/

-- *********************************** PLAN BASELINES ******************************************

spool &sql_id._run0&test_run._13_SQL_PLAN_BASELINES.txt

SELECT PLAN_TABLE_OUTPUT
FROM   V$SQL s, DBA_SQL_PLAN_BASELINES b, 
       TABLE(
       DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(b.sql_handle,b.plan_name,'ALL') 
       ) t
WHERE  s.EXACT_MATCHING_SIGNATURE=b.SIGNATURE
AND    b.PLAN_NAME=s.SQL_PLAN_BASELINE
AND    s.SQL_ID='&sql_id';

spool off;


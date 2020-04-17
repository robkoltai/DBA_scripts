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

with 
    MT_X as 
    (
        SELECT a.*, b.SCEN_NAME, b.SCEN_TASK_NO, b.TASK_NAME1, b.TASK_STATUS, b.TASK_DUR, b.TASK_BEG, b.TASK_END, b.NB_INS, b.NB_UPD, b.TASK_ERROR, b.TASK_CODE
        FROM 
            dwms.wrk_AIXPOC_MT_LP_X_LW1025_T&test_run. a
          left outer join
            dwms.wrk_AIXPOC_SesTask_LW1025_T&test_run. b
                on (A.EXTERNAL_SESSION_ID = B.EXTERNAL_SESSION_ID)
        where a.status='DONE'
        and a.object_type_name='SCENARIO'
    ),
    dash as
    (
        select distinct sql_id,  
            nvl(qc_session_id, session_id) session_id, 
            nvl(qc_session_serial#, session_serial#) session_serial#,
            regexp_replace(action, '(\d+)/(\d+)/(\d+)/(\d+)', '\1') external_session_id,
            regexp_replace(action, '(\d+)/(\d+)/(\d+)/(\d+)', '\4') task_id
        --    , qc_session_id, qc_session_serial#, action, count(*), min(sample_time) min_sample_time, max(sample_time) max_sample_time
        from dwms.S_AIXDW_LW1025_T&test_run._DASH a
        where a.SQL_ID in ( '&sql_id')  --Ide kell a keresett SQL_ID-k listaja 
        group by sql_id, session_id, session_serial#, qc_session_id, qc_session_serial#, action
        order by 1,2,3
    )
select x.object_long_name, x.task_name1, X.EXTERNAL_SESSION_ID, X.SCEN_TASK_NO, 
  execution_start_time, execution_end_time, record_count, inserted_count, updated_count, deleted_count, task_beg, task_end
from MT_X x
where (X.EXTERNAL_SESSION_ID, X.SCEN_TASK_NO) in (select EXTERNAL_SESSION_ID, task_id from dash)
order by 1,2;

spool off;
-- ************************************************************************************************************************************************************************
spool &sql_id._run0&test_run._02_XPLAN_AWR.txt

-- xplan
PROMPT ** XPLAN from AWR
PROMPT *****************
select * from TABLE(dbms_xplan.display_awr('&sql_id', format=>'advanced +note -alias +outline +predicate'));

spool off;
-- ************************************************************************************************************************************************************************
spool &sql_id._run0&test_run._03_XPLAN_CURR.txt

SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE'))
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

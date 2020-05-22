-- Monitor info for 1 SQL
-- DASH infot is hasznal
-- V$ es DBA_HIST_REPORT-ot is hasznal

-- ********************************
-- CONFIG SQLMONITOR
-- ********************************
-- /*+ MONITOR */ hint
-- ALTER SYSTEM SET EVENTS 'sql_monitor [sql: 5hc07qvt8v737|sql: 9ht3ba3arrzt3] force=true';

                                           Value    Value    Default
Underscore Parameter                       Session  Instnc   Value    Description                                                                 SESSM SYSMOD
------------------------------------------ -------- -------- -------- --------------------------------------------------------------------------- ----- ---------
_sqlmon_binds_xml_format                   default  default  TRUE     format of column binds_xml in [G]V$SQL_MONITOR                              True  IMMEDIATE
_sqlmon_max_plan                           40       40       TRUE     Maximum number of plans entry that can be monitored. Defaults to 20 per CPU True  IMMEDIATE
_sqlmon_max_planlines                      300      300      TRUE     Number of plan lines beyond which a plan cannot be monitored                True  IMMEDIATE
_sqlmon_recycle_time                       5        5        TRUE     Minimum time (in s) to wait before a plan entry can be recycled             True  IMMEDIATE
_sqlmon_threshold                          5        5        TRUE     CPU/IO time threshold before a statement is monitored. 0 is disabled        True  IMMEDIATE

Szerintem ha a sárgát felvesszük 65-re, akkor elég jól le vagyunk fedve, ha a percenkénti riportolást is beállítjuk.


-- ********************************
-- CONFIG REPORT GENERATION
-- ********************************
DBMS_AUTO_REPORT.START_REPORT_CAPTURE; -- Reports are save every minute
DBMS_AUTO_REPORT.FINISH_REPORT_CAPTURE; -- Back to normal

--status of above full or regular 
select * from dba_hist_reports_control;

-- Unerscore params
_max_queued_report_requests           300 Maximum number of report requests that can be queued in a list
_max_report_flushes_percycle            5 Max no of report requests that can be flushed per cycle
_report_capture_cycle_time             60 Time (in sec) between two cycles of report capture daemon
_report_capture_dbtime_percent_cutoff  50 100X Percent of system db time daemon is allowed over 10 cycles
_report_capture_recharge_window        10 No of report capture cycles after which db time is recharged
_report_capture_timeband_length         1 Length of time band (in hours) in the reports time bands table
_report_request_ageout_minutes         60 Time (in min) after which a report request is deleted from queue

-- ********************************
-- DATA dictionary
-- ********************************

V$SQL_MONITOR 
V$SQL_PLAN_MONITOR
v$sql_monitor_sesstat
v$sql_monitor_statname

dba_hist_reports
dba_hist_reports_details


-- ********************************
-- REPORT 
-- ********************************

-- Searching by SQL text
select * from v$sql_monitor
where  lower(sql_text) like 'insert%'
order by elapsed_time desc;


-- LAST monitored in current session
VARIABLE report CLOB
EXEC :report := dbms_sql_monitor.report_sql_monitor;
PRINT report

-- Using SQL ID
SELECT dbms_sql_monitor.report_sql_monitor(
sql_id => 'f1178wkrba2y9',
type => 'TEXT',
report_level => 'ALL') AS report
FROM dual

-- LIST reports for 1 specific SQL  or ALL SQLS  SQLPLUS (dbms_sqltune is the old package)
-- from v$
set long 20000
column rep format a300
column z_report format a300
--LIST REPORT
SELECT dbms_sqltune.Report_sql_monitor_list(SQL_ID=>'&sql_id', TYPE=>'text',report_level=>'ALL') rep
FROM   dual;

-- SEARCH LIST (key2 exec id)
select * from dba_hist_reports where key1='&sql_id';
select * from dba_hist_reports where component_name ='perf';

-- All details for all executions of an SQL
select substr(key4,1,instr(key4,'#')-1) as elapsed, 
dbms_auto_report.Report_repository_detail(rid=>report_id,TYPE=>'TEXT') as z_report, 
rep.* 
from dba_hist_reports rep 
where key1='&sql_id' order by period_start_time desc;


-- TEXT REPORT
SELECT dbms_sqltune.Report_sql_monitor(SQL_ID=>'&sql_id', TYPE=>'text',report_level=>'ALL', sql_exec_id => &exec) rep
FROM   dual;
select dbms_auto_report.Report_repository_detail(rid=>1114,TYPE=>'TEXT') z_report from dual;

-- ACTIVE REPORT REPORT_SQL_DETAIL GIVES MORE DETAILS!!
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

-- Details for 1 SQL if sql_id is null then the last one
SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => '&sql_id',
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;


-- ********************************
-- PERFHUB REPORT
-- ********************************
$ORACLE_HOME/rdbms/admin/perfhubrpt.sql


-- ********************************
-- CROSSCHECK RUNS FROM OTHER SOURCES
-- ********************************

-- DASH The executions for an SQL ID
select sql_id, session_id, session_serial#,sql_exec_id, min(sample_time), max(sample_time), sum(10) sec, user_id, sql_plan_hash_value, sql_child_number 
from dba_hist_active_sess_history 
where sql_id is not null and sql_id in ('&sql_id')
group by sql_id, session_id, session_serial#, user_id, sql_plan_hash_value, sql_child_number, sql_exec_id
--having sum(10) > 3600
order by  1,5 desc;


-- DASH plan activity
select sum(10) secs, sql_plan_line_id, sql_plan_operation, sql_plan_options
from dba_hist_active_sess_history
where sql_plan_hash_value = '&phv'
group by sql_plan_line_id, sql_plan_operation, sql_plan_options
order by 1 desc;

 
-- XPLAN FROM AWR
select * from TABLE(dbms_xplan.display_awr('&sql_id', format=>'advanced +note -alias +outline +predicate'));















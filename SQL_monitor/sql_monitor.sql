-- Monitor info for 1 SQL
-- DASH infot is hasznal
-- V$ es DBA_HIST_REPORT-ot is hasznal



select * from v$sql_monitor
where report_id =0 and lower(sql_text) like 'insert%'
order by elapsed_time desc;

-- FUTASOK
select sql_id, session_id, session_serial#,sql_exec_id, min(sample_time), max(sample_time), sum(10) sec, user_id, sql_plan_hash_value, sql_child_number 
from dba_hist_active_sess_history 
where sql_id is not null and sql_id in ('&sql_id')
group by sql_id, session_id, session_serial#, user_id, sql_plan_hash_value, sql_child_number, sql_exec_id
--having sum(10) > 3600
order by  1,5 desc;
  
-- VEGREHAJTASI TERVEK
select * from TABLE(dbms_xplan.display_awr('&sql_id', format=>'advanced +note -alias +outline +predicate'));


set long 20000
column rep format a300
column z_report format a300
--attekinto
SELECT dbms_sqltune.Report_sql_monitor_list(SQL_ID=>'&sql_id', TYPE=>'text',report_level=>'ALL') rep
FROM   dual;

-- reszletes
SELECT dbms_sqltune.Report_sql_monitor(SQL_ID=>'&sql_id', TYPE=>'text',report_level=>'ALL', sql_exec_id => &exec) rep
FROM   dual;

-- historikus
select * from dba_hist_reports where key1='&sql_id';

-- historikus reszletes SQL MONITOR REPORT
select substr(key4,1,instr(key4,'#')-1) as elapsed, 
dbms_auto_report.Report_repository_detail(rid=>report_id,TYPE=>'TEXT') as z_report, 
rep.* 
from dba_hist_reports rep 
where key1='&sql_id' order by period_start_time desc;


--select * from DBA_HIST_REPORTS_DETAILS;n850#16194492#9148465#335#10977280

-- ASH plan activity
select sum(10) secs, sql_plan_line_id, sql_plan_operation, sql_plan_options
from dba_hist_active_sess_history
where sql_plan_hash_value = '&phv'
group by sql_plan_line_id, sql_plan_operation, sql_plan_options
order by 1 desc;


select * from dba_hist_reports where component_name ='perf';
select dbms_auto_report.Report_repository_detail(rid=>1114,TYPE=>'TEXT') z_report from dual;

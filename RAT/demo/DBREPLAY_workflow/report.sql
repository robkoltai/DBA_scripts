-- export runs. Export minden! Hatha meg vissza tudjuk importalni
-- check os directory
-- get detailed info


@/home/oracle/RAT/config/setterm.sql

select * from dba_workload_captures;
select * from dba_workload_replays;
set serveroutput on;

-- MI a capture id?
-- Ezzel lehet keresni a dba_workload_replays-ben
-- USE SYS
set serveroutput on
DECLARE
  cap_id         NUMBER;
BEGIN
  cap_id := DBMS_WORKLOAD_REPLAY.GET_REPLAY_INFO(replay_dir => 'CAPDIR');
  dbms_output.put_line (cap_id);
END;
/


-- CHeck status
select * from dba_workload_replays;

-- One can cancel replay at will
-- Ez eltart egy jó kis ideig. Nem mértem, de 20-50 perc is akár
-- ATTENTION !!! COMPARE REPORT-ot bukod!!! Replay with ID 1 has "CANCELLED" status
-- Azert tart sokáig, mert data pump exportot csinal az AWR adatokrol
-- lasd: /opt/oradump/pfup/grb_pf_live_capture0502_replay0508/rep422670824/*log
exec DBMS_WORKLOAD_REPLAY.CANCEL_REPLAY (reason => 'Eleg volt');

/*
-- Compare Period Riportáláshoz majd kell Data Dictionary manual update. 
update sys.wrr$_replays set status='COMPLETED', error_code=null, error_msg=null where id=2;
commit;
*/

/*
-- load divergence.
-- This one is not in the documentation
-- We can skip this
DECLARE
  rep_id         NUMBER;
BEGIN
  DBMS_WORKLOAD_REPLAY.LOAD_DIVERGENCE (replay_id => 2);		-- dba_workload_replay gives the ID
END;
/
*/

-- load details loads divergence and traced commit data
https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_WORKLOAD_REPLAY.html#GUID-DE583F1C-B5EA-423F-8904-9633AE7AF450
set serveroutput on;
DECLARE
  cap_id         NUMBER;
BEGIN
  cap_id := DBMS_WORKLOAD_REPLAY.GET_REPLAY_INFO(replay_dir => 'CAPDIR', load_details => true);
  dbms_output.put_line (cap_id);
END;
/


-- IMPORT AWR to a user
-- import log: /opt/oradump/pfup/grb_clone_capture0404_replay0410/cap/*log
select * from dba_workload_captures; -- Miert van 2???
declare id number;
begin
 id:= DBMS_WORKLOAD_CAPTURE.IMPORT_AWR (
   capture_id  =>1,
   staging_schema => 'SYSTEM'
);
  dbms_output.put_line (id);
end;
/
-- data pump import: logs. /opt/oradump/pfup/grb_pf_live_capture0502_replay0508/cap/wcr_ca.log
746813555

------------REPORTS
-- This works fine with sqldeveloper. Copy paste html
-- I RUN this on the capture directory on REPLAY side
-- First parameter dba_workload_replay.capture_id

cd /home/oracle/remedios/tests/RAT/CAP0502_REPLAY0515_TUNEPOC
@setterm.sql

-- AWR details
/*
Parameters

    top_n_events - number of most significant wait events to be included
    top_n_files - number of most active files to be included
    top_n_segments - number of most active segments to be included
    top_n_services - number of most active services to be included
    top_n_sql - number of most significant SQL statements to be included
    top_n_sql_max - number of SQL statements to be included if their activity is greater than that specified by  top_sql_pct
    top_sql_pct - significance threshold for SQL statements between top_n_sql and top_n_max_sql
    shmem_threshold - shared memory low threshold
    versions_threshold - plan version count low threshold


Example

exec dbms_workload_repository.awr_set_report_thresholds(top_n_sql=>300,top_n_sql_max=>300);


-- I run this on REPLAY DB. Shows little information
spool workload_capture0502_napi_report.html
select DBMS_WORKLOAD_REPLAY.REPORT(1, 'HTML') from dual;
spool off;
/* Text format */
select dbms_workload_capture.report ( 1, 'TEXT') from dual;
/* HTML format */
spool capture01_capture_report.html
select dbms_workload_capture.report ( 1, 'TEXT') from dual;
spool off;



--compare COMPARE_PERIOD_REPORT
/*
Use the replay compare period report to perform a high-level comparison of one workload replay to its capture or to another replay of the same capture. Only workload replays that contain at least 5 minutes of database time can be compared using this report.
*/
-- second parameter null to compare it with capture

@setterm.sql

VAR v_clob CLOB;
BEGIN dbms_workload_replay.COMPARE_PERIOD_REPORT (replay_id1 => 1, replay_id2 => null, format => 'HTML', 
   result => :v_clob ); 
END; 
/ 
spool workload_capture01_replay01_compare.html
PRINT v_clob 
spool off


-- compare period AWR

-- BASIC
@setterm.sql
spool workload_capture0502_replay0515_Tuned_AWR_DIFF.html
select * from 
DBMS_WORKLOAD_REPOSITORY.AWR_DIFF_REPORT_HTML (
   746813555,
   1,
   51607   ,
   51617    ,
   2607718714,
   1,
   172,
   192)
  ;
spool off;

-- Akkor ezt futtassuk, ha nem ment a workload replay compare period
-- DEEPER
exec dbms_workload_repository.awr_set_report_thresholds(top_n_segments =>100, top_n_sql=>300,top_n_sql_max=>300, top_sql_pct=>0.1);


-- COMPARE_SQLSET_REPORT 
set echo off
set long 9900000
set longchunksize 9900000
set pages 0



VAR v_clob CLOB;
declare 
 v varchar2(50);
BEGIN 
   -- after, before or null
   v:= dbms_workload_replay.COMPARE_SQLSET_REPORT (replay_id1 => 1, replay_id2 => null, format => 'HTML', 
   result => :v_clob ); 
END; 
/ 

spool COMPARE_SQLSET_REPORT_CAPTURE0425_REPLAY0429.html;
PRINT v_clob;
spool off;


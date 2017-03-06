set pagesize 0 linesize 500 feedback off verify off
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
undef v_sid
col sql_id new_value v_sql_id noprint
col sql_child_number new_value v_chd_no noprint
col sql_exec_id new_value v_exec_id noprint
--select sql_id, sql_child_number, sql_exec_id from v$session where sid = &v_sid;
spool run_ash_xplan
select * from table(ash_xplan.display_cursor('&v_sql_id',&&v_chd_no));
spool off
set pagesize 100 linesize 130 feedback 6 verify on

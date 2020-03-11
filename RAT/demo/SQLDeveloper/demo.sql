
-- STS
/*select * from dba_objects
where owner='SYS' and
 (object_name like '%SET%' or object_name like '%STS%');
*/ 
 
select * from dba_SQLSET;
select * from dba_SQLSET_STATEMENTS where sqlset_id = 11 ;
select * from dba_SQLSET_BINDS where sqlset_id = 9 ;
select * from dba_SQLSET_PLANS where sqlset_id = 9 ;
select * from dba_SQLSET_REFERENCES where sqlset_id = 9 ;;

-- Cursor cache lekerdezes
SELECT *
FROM table(DBMS_SQLSET.select_cursor_cache('parsing_schema_name = ''RAT'''))
ORDER BY sql_id, plan_hash_value;

-- CAPTURE
SELECT DBMS_WORKLOAD_CAPTURE.get_capture_info('CAPDIR')
FROM   dual;
select to_char(start_time,'YYYYMMDD HH24:MI:SS'), to_char(end_time,'YYYYMMDD HH24:MI:SS'), c.* from dba_workload_captures c order by start_time, id;


-- REPLAY
select * from dba_workload_replays;
select to_char(start_time,'YYYYMMDD HH24:MI:SS'), to_char(end_time,'YYYYMMDD HH24:MI:SS'), c.* from dba_workload_replays c;

-- ACTIVITY
select * from v$active_session_history where session_type <> 'BACKGROUND' order by 1 desc;
select * from v$sql where sql_ID = 'cas36hvx7w7kf';

-- AWR 
select * from dba_hist_snapshot order by 1 desc;

-- SQL baselines
select * from dba_sql_plan_baselines where plan_name='SQL_PLAN_cpg3pys947h99ad5e922e';
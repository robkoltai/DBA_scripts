
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

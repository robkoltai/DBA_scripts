-------------------------------------
--- REPLAY LEPESEK
-------------------------------------
/* most nem masolgatok, mint az elesben 
most
  nem kell shared storage
  nem kell uj directory

*/

-- process
-- Check alert.log tail -f. Nincs ott semmi
-- check OS directory /oradata/RAT_CAPDIR/pp19.3.0.0.0
set timi on
set time on
BEGIN
  DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir => 'CAPDIR',
                             plsql_mode => 'TOP_LEVEL');
END;
/



-- CALIBRATE THE CLIENTS
cd /oradata/RAT_CAPDIR
wrc system mode=calibrate replaydir=/oradata/RAT_CAPDIR
-- wrc system mode=get_tables replaydir=/oradata/RAT_CAPDIR nem is igaz amiket mond
--> ORA-16953: Type of SQL statement not supported


-- REPLAY INIT as SYS
begin
DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY (replay_name => 'RAT_DEMO_CAPTURE01_REPLAY_01',  
                           replay_dir => 'CAPDIR',
                           plsql_mode => 'top_level');
END;
/


-- CHECK
select * from dba_workload_replays;
	

-- VAN ilyen lehetőseg
/*
PROCEDURE SET_SQL_MAPPING (
   sql_id               IN VARCHAR2,
   operation            IN VARCHAR2,
   replacement_sql_text IN VARCHAR2 DEFAULT NULL);
*/
   
begin
 dbms_workload_replay.SET_SQL_MAPPING (
   sql_id         =>  '28zargwmczpk9',
   operation      => 'REPLACE',
   replacement_sql_text => '
declare 
  i_update number;
  stmt varchar2(2000);
  r number;
begin
  for i_update in 1..$RUN_COUNT loop
    -- There are ~70000 records in the table
	r:= ROUND(DBMS_RANDOM.VALUE(1,70000));
	
    stmt := ''UPDATE /*+ TEST_01_UPDATE REPLACED */ update_t ''||
	        ''set text = substr(text,73,100) || substr(text,1,72) ''||
			''where id = :i_update'';
    execute immediate stmt using i_update;
    commit;
  end loop;
end;'
);
end;
/


-- Tegyuk meg amit akarunk
-- SYS WINDOW
conn rat/rat
@/home/oracle/RAT/setup/setup_01_update_table.sql
@/home/oracle/RAT/setup/setup_02_parent_child.sql
@/home/oracle/RAT/setup/setup_03_insert_table.sql
@/home/oracle/RAT/setup/setup_04_select_table.sql
conn / as sysdba
@/home/oracle/RAT/config/config_DBREP_the_change_init_parameters.sql


-- REPLAY prepare
BEGIN
  DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY (synchronization => 'TIME');
end;
/



-- start client on the client!!! connection override kellett
-- replace literals RAT bug miatt kellett
-- RAT Replay Shows Divergence (No Rows) on Queries With Literals When CURSOR_SHARING=FORCE (Doc ID 1918378.1)

wrc system  mode=replay replaydir=/oradata/RAT_CAPDIR connection_override=true replace_literals=true


-- WRC trace fileok leteznek ilyen helyen:
/app/oracle/diag/clients/user_oracle/host_61728193_110/trace
-- pl ilyen üzenetek vannak benne
2019-09-18 16:35:30.444 :keclro.c@5438: Cursor 140674900695896 (oct=26) got ORA-00054. Skip its execution.

-- START
BEGIN
  DBMS_WORKLOAD_REPLAY.START_REPLAY ();
END;
/



2020-03-05T14:53:26.274689+00:00
DBMS_WORKLOAD_REPLAY.START_REPLAY(): Starting database replay at 03/05/2020 14:53:25

Replay client 1 started (14:53:27)
Replay client 1 finished (15:07:07)


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

exec dbms_workload_repository.awr_set_report_thresholds(top_n_sql=>100,top_n_sql_max=>100);
*/
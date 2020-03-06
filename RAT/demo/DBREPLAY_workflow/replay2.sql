-- No need to postprocess anymore

-- REPLAY INIT as SYS
begin
DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY (replay_name => 'RAT_DEMO_REPLAY_02',  
                           replay_dir => 'CAPDIR',
                           plsql_mode => 'top_level');
END;
/


-- CHECK
select * from dba_workload_replays; --11
	


-- Tegyuk meg amit akarunk

conn rat/rat
@/home/oracle/RAT/setup/setup_01_update_table.sql
@/home/oracle/RAT/setup/setup_02_parent_child.sql
@/home/oracle/RAT/setup/setup_03_insert_table.sql
@/home/oracle/RAT/setup/setup_04_select_table.sql
conn / as sysdba
@/home/oracle/RAT/config/config_DBREP_tuned_change_init_parameters.sql

-- config 300 SQLs in AWR
--exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (null,null,100,null);

-- REPLAY prepare
conn / as sysdba
BEGIN
  DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY (synchronization => 'TIME');
end;
/



-- start client on the client!!! connection override kellett
-- replace literals RAT bug miatt kellett
-- RAT Replay Shows Divergence (No Rows) on Queries With Literals When CURSOR_SHARING=FORCE (Doc ID 1918378.1)

wrc system  mode=replay replaydir=/oradata/RAT_CAPDIR connection_override=true replace_literals=true
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
DBMS_WORKLOAD_REPLAY.START_REPLAY(): Starting database replay at 20200306 14:42:36

Replay client 1 started (14:42:37)

Replay client 2 started (14:42:37)




-------------------------------------
--- INNEN JON ROBI FELDOLGOZAS
-------------------------------------
cd /opt/oradump/pfup/
cp -r grb_pf_live_capture_0502_bck grb_pf_live_capture0502_replay0508



-- ezek masolasa egyenkent
 cd /opt/oradump/pfup/grb_pf_live_capture0502_replay0508/cap
 cp /opt/oradump/pfup/grb_pf_live_capture_0502_bck/cap/wcr_ca.dmp .
 cp /opt/oradump/pfup/grb_pf_live_capture_0502_bck/cap/wcr_cap_uc_graph.extb .


-- itt van a capture
create or replace directory GRB_PF_LIVE_RAT_WORK as '/opt/oradump/pfup/grb_pf_live_capture0502_replay0508';

-- process
-- Check alert.log tail -f
-- fel ora másfél perc. 30-40 percre számíthatunk. Valójában 15 perc alatt megcsinálta
set timi on
set time on
BEGIN
  DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir => 'GRB_PF_LIVE_RAT_WORK',
                             plsql_mode => 'TOP_LEVEL');
END;
/


-- VAN ilyen lehetőseg
PROCEDURE SET_SQL_MAPPING (
   sql_id               IN VARCHAR2,
   operation            IN VARCHAR2,
   replacement_sql_text IN VARCHAR2 DEFAULT NULL);
   

-- CSinal egy directoryt a preprocess
-- kb 10-15% mennyiségű új adatfile
/opt/oradump/pfup/grb_pf_live_capture0502_replay0508/pp18.0.0.0.0


-- CALIBRATE THE CLIENTS
cd /opt/oradump/pfup/grb_pf_live_capture0502_replay0508
wrc system mode=calibrate replaydir=/opt/oradump/pfup/grb_pf_live_capture0502_replay0508
sdf234!!HGGG234ss

Report for Workload in: /opt/oradump/pfup/grb_pf_live_capture0502_replay0508
-----------------------

Report for Workload in: /opt/oradump/pfup/grb_pf_live_capture0502_replay0508
-----------------------

Recommendation:
Consider using at least 7 clients divided among 2 CPU(s)
You will need at least 303 MB of memory per client process.
If your machine(s) cannot match that number, consider using more clients.

Workload Characteristics:
- max concurrency: 561 sessions
- total number of sessions: 15988

Assumptions:
- 1 client process per 100 concurrent sessions
- 4 client processes per CPU
- 256 KB of memory cache per concurrent session
- think time scale = 100
- connect time scale = 100
- synchronization = TRUE

/* fel orasnak ez volt az eredmenye
Recommendation:
Consider using at least 4 clients divided among 1 CPU(s)
You will need at least 341 MB of memory per client process.
If your machine(s) cannot match that number, consider using more clients.

Workload Characteristics:
- max concurrency: 364 sessions
- total number of sessions: 1222

Assumptions:
- 1 client process per 100 concurrent sessions
- 4 client processes per CPU
- 256 KB of memory cache per concurrent session
- think time scale = 100
- connect time scale = 100
- synchronization = TRUE
*/



-- CHECKS

wrc system/system mode=list_hosts replaydir=/opt/oradump/pfup/grb_pf_live_capture0502_replay0508

Hosts found:
Capture: PF_LIVE_DAY0502
        axppec03
No replays were found.



wrc system/system mode=get_tables replaydir=/opt/oradump/pfup/grb_pf_live_capture0502_replay0508


-- REPLAY INIT as SYS
--run this on sodb5 and not yet on the clients
begin
DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY (replay_name => 'CAP0502_REP0515_POC1H',  
                           replay_dir => 'GRB_PF_LIVE_RAT_WORK',
                           plsql_mode => 'top_level');
END;
/


-- CHECK
select * from dba_workload_replays;
	

-- scp


-------------------------------------------------------
-- Tegyuk meg amit akarunk
--alter system set optimizer_ignore_hints=true;
@befuttat
-- check parameters
set pages 0
column name format a40
column value format a30
select name, value from v$parameter
where name like '%sga%' or
      name like '%ignore%' or
	  name like '%multiblock%' or 
	  name like '%cache_size%' or
	  name like '%pool_size%' or
	  name like '%area_size%' or
	  name like '%optimizer%' or
	  name like '%cursor%' or
	  name like '%session%' or 
	  name like '%filesystem%' or
	  name like '%recovery%'
order by 1;

_cursor_bind_capture_area_size           400
allow_group_access_to_sga                FALSE
bitmap_merge_area_size                   1048576
client_result_cache_size                 0
create_bitmap_area_size                  8388608
cursor_bind_capture_destination          memory+disk
cursor_invalidation                      IMMEDIATE
cursor_sharing                           force
cursor_space_for_time                    FALSE
data_transfer_cache_size                 0
db_16k_cache_size                        0
db_2k_cache_size                         0
db_32k_cache_size                        0
db_4k_cache_size                         0
db_8k_cache_size                         0
db_cache_size                            3221225472
db_file_multiblock_read_count            128
db_flash_cache_size                      0
db_keep_cache_size                       3221225472
db_recovery_file_dest                    /ora3/fra
db_recovery_file_dest_size               37580963840
db_recycle_cache_size                    0
filesystemio_options                     SETALL
hash_area_size                           131072
java_max_sessionspace_size               0
java_pool_size                           268435456
java_soft_sessionspace_limit             0
large_pool_size                          268435456
license_max_sessions                     0
license_sessions_warning                 0
lock_sga                                 FALSE
memoptimize_pool_size                    0
olap_page_pool_size                      0
open_cursors                             300
optimizer_adaptive_plans                 TRUE
optimizer_adaptive_reporting_only        FALSE
optimizer_adaptive_statistics            FALSE
optimizer_capture_sql_plan_baselines     FALSE
optimizer_dynamic_sampling               2
optimizer_features_enable                18.1.0
optimizer_ignore_hints                   FALSE
optimizer_ignore_parallel_hints          FALSE
optimizer_index_caching                  0
optimizer_index_cost_adj                 100
optimizer_inmemory_aware                 TRUE
optimizer_mode                           all_rows
optimizer_secure_view_merging            TRUE
optimizer_use_invisible_indexes          FALSE
optimizer_use_pending_statistics         FALSE
optimizer_use_sql_plan_baselines         TRUE
pre_page_sga                             TRUE
recovery_parallelism                     0
remote_recovery_file_dest
session_cached_cursors                   50
session_max_open_files                   10
sessions                                 2722
sga_max_size                             14696841216
sga_min_size                             0
sga_target                               12884901888
shared_pool_size                         3221225472
shared_server_sessions
sort_area_size                           65536
streams_pool_size                        0
unified_audit_sga_queue_size             1048576
workarea_size_policy                     AUTO

65 rows selected.



-- archivelog mode;
-- crontab active rman torles
-- check listener setting on client
-------------------------------------------------------

-- config 300 SQLs in AWR
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (null,null,300,null);

-- REPLAY prepare
-- 05.15  14:04
BEGIN
  DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY (synchronization => 'TIME',
                           capture_sts => TRUE,
                           sts_cap_interval => 720);
END;
/



-- start client on the client!!! connection override kellett
-- replace literals RAT bug miatt kellett
-- RAT Replay Shows Divergence (No Rows) on Queries With Literals When CURSOR_SHARING=FORCE (Doc ID 1918378.1)
wrc system/system@pfs mode=replay replaydir=c:\PFUP\grb_pf_live_capture0502_replay0508 connection_override=true replace_literals=true

Replay client 1 started (10:42:56)
Replay client 1 finished (10:49:27)
dba_workload_replay.duration = 290 a fentivel ellentetben.



-- START
BEGIN
  DBMS_WORKLOAD_REPLAY.START_REPLAY ();
END;
/


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
*/
select * from v$sql where sql_id =   'agtmq9nq5ydfy';
select count(1) from v$session s where s.module = 'RK_RUNSTAT'; --and s.action = 'V5';
select * from v$session s where s.module = 'RK_RUNSTAT';-- and s.action = 'V5' order by status,sid;
select * from v$active_session_history where module = 'RK_RUNSTAT';

select * from v$sql_workarea_active;
select * from v$px_session;


-- MONITOR DURING RUN
select * from rk_runstat_control;
select * from RK_RUNSTAT_WORKAREA_ACT_All where 1=1 
   order by snapid,sid,ts;

-- TEMPS
select * from rk_runstat_events_tmp;
select * from rk_runstats_tmp ;
select * from RK_RUNSTAT_WORKAREA_ACT_TMP;

-- PARALLEL RESULTS
select * from RK_RSE_PARALLEL_V --where first_wait_sec+second_wait_sec>5 --order by 2 desc;
    order by decode (event, 'TEST DURATION',1,'direct path read temp',2,'direct path write temp',3,
                 'direct path read',4,
                 'direct path write',5,
                 'local write wait',6,100), 1 desc;
select * from RK_RS_PARALLEL_V where (name like 'physical%byte%' or
                                      name like '%temp%space%alloc%' or
                                      name in ('physical reads direct temporary tablespace','physical writes direct temporary tablespace','physical reads','physical writes','CPU used by this session')) 
    order by 1;
select * from RK_RS_PARALLEL_WORKAREA_V where tablespace is not null;

-- raw data
select * from rk_runstat_ash_anal_v;
select * from rk_runstat_ash_anal_v where event = 'direct path read temp' or event = 'direct path write temp' or event = 'local write wait';
select * from rk_runstat_events order by event, sid, snapid;
select * from rk_runstats;
select * from v$active_session_history where event='local write wait' order by 1 desc;
select * from dba_objects where object_id = 54232;
select * from v$session;

select * from v$active_session_history order by 1 desc;

select * from dba_tablespaces;

select * from V$sess_time_model where sid=295;

-- DEBUG

select * from v$parameter where name like '%flash%';
-- truncate table rk_log;
select * from rk_log order by 2 desc;
select distinct snapid, sid from rk_runstats;


-- MISC
select * from v$mystat;
select * from v$statname where name in ('redo blocks written','redo_size';
select * from v$filestat;
select * from v$tempstat;
select * from v$tempfile;
select * from v$datafile;

select i.leaf_blocks, i.* from user_indexes i;
select t.blocks, t.* from user_tables t;
exec dbms_stats.gather_table_stats('NVME','T1');


select * from v$session;

select sid, serial#, event from rk_runstat_events where snapid=4
   minus
   select sid, serial#, event from rk_runstat_events where snapid=3;
   
select * from  rk_runstat_events
where event = 'direct path read temp';
   
select * from v$active_sess ion_history order by 1 desc;
   
select * from RK_RUNSTAT_WORKAREA_ACT_ALL
where sid in (13,24,1296,317) order by 1;

select testcase, session_id, event, sum(time_waited), count(1) count#
from rk_runstat_ash_anal_v
where event is not null
group by testcase, session_id, event
order by 1,2,3
;

select testcase,  event, sum(time_waited)
from rk_runstat_ash_anal_v
group by testcase, event
order by 1,2;


select * from v$datafile order by 1 desc;
select * from v$tempfile order by 1 desc;
select * from v$parameter where name like '%file%' order by 1;
select * from dba_tablespaces;
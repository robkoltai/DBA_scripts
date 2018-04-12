-- When are the stats in AWR collected? At the end of the snapshot:
        http://blog.orapub.com/20120419/when-are-oracle-database-dba-hist-sysstat-values-correct.html
-- sesstat vs time_model. Time model is newer and more accurate
        https://jonathanlewis.wordpress.com/2009/05/26/cpu-used/
-- AWR or ASH 
        http://oracledoug.com/serendipity/index.php?/archives/1432-Time-Matters-DB-CPU.html
        Active  Sessions: Wait Time = DB Time (measured) - CPU Time (measured)- IO (measured). Top down. Waits include inflated runq
        Average Active Sessions: DB CPU (measured) + Waits (measured). Not top down. Wait is inflated by runq
        Top activity: ASH samples. Anything not wait accounted as CPU. This shows CPU and CPU runq.
-- AIX SMT 
        https://ardentperf.com/2016/07/01/understanding-cpu-on-aix-power-smt-systems/
-- Metalink "DB CPU" / "CPU + Wait for CPU" / "CPU time" Reference Note (Doc ID 1965757.1)
-- https://hoopercharles.wordpress.com/2010/02/22/cpu-usage-monitoring-what-are-the-statistics-and-when-are-the-statistics-updated/


----------------------------
-- SYSSTAT
----------------------------


select distinct stat_name 
from dba_hist_sysstat where lower(stat_name ) like '%cpu%'
order by 1

----------------------------------------
CPU used by LWTs for this session
CPU used by this session
CPU used when call started
IPC CPU used by this session
OS CPU Qt wait time
cell physical IO bytes sent directly to
DB node to balance CPU
gc CPU used by this session
global enqueue CPU used by this session
parse time cpu
recursive cpu usage

10 rows selected.

-- SYSSTAT
-- Itt meg gondok lehetnek ha orankent tobb snapshot van. 
-- Akkor aggregalni kellene
-- Nem eleg gyakori az update JL szerint
-- Es raadasul: CPU used by this session: 
--        Amount of CPU time (in 10s of milliseconds) used by a session from the time a user call starts until it ends. 
--        If a user call completes within 10 milliseconds, the start and end user-call time are the same for purposes of this statistics, and 0 milliseconds are added. A similar problem can exist in the reporting by the operating system, 
--        especially on systems that suffer from many context switches.
-- Expressed in centiseconds
set lines 140
column startup_time format a19
column stat_name format a28
select  i.instance_name, 
        snap.instance_number, 
        to_char(snap.startup_time, 'YYYYMMDD HH24:MI') startup_time, 
        to_char(snap.begin_interval_time,'YYYYMMDD HH24:MI:SS') begin_interval_time, 
        to_char(snap.begin_interval_time,'YYYYMMDD HH24') begin_hour, 
        stat.value,
        round(stat.value /100 - lag(stat.value/100,1,0) over (order by to_char(snap.begin_interval_time,'YYYYMMDD HH24:MI:SS')),2) cpu_seconds,
        stat.stat_name
from dba_hist_sysstat stat,
     dba_hist_snapshot snap,
     v$instance i
where stat.snap_id=snap.snap_id
  and stat.instance_number=snap.instance_number
  and i.instance_number= snap.instance_number
  and stat.stat_name = 'CPU used by this session'
order by to_char(snap.begin_interval_time,'YYYYMMDD HH24');


/*

INSTANCE_NAME    INSTANCE_NUMBER STARTUP_TIME        BEGIN_INTERVAL_TI BEGIN_HOUR       VALUE CPU_SECONDS STAT_NAME
---------------- --------------- ------------------- ----------------- ----------- ---------- ----------- ----------------------------
single                         1 20171024 15:32      20171026 11:00:01 20171026 11      36450         2.9 CPU used by this session
single                         1 20171024 15:32      20171026 12:00:08 20171026 12      36676        2.26 CPU used by this session
single                         1 20171024 15:32      20171026 13:00:14 20171026 13      36959        2.83 CPU used by this session
single                         1 20171024 15:32      20171026 14:00:21 20171026 14      37633        6.74 CPU used by this session
single                         1 20171026 15:28      20171026 15:28:05 20171026 15       2207     -354.26 CPU used by this session
single                         1 20171026 15:28      20171026 16:00:03 20171026 16       2933        7.26 CPU used by this session
single                         1 20171026 15:28      20171027 13:16:07 20171027 13       3290        3.57 CPU used by this session
single                         1 20171026 15:28      20171027 14:00:26 20171027 14       3737        4.47 CPU used by this session
single                         1 20171026 15:28      20171030 09:49:06 20171030 09       4704        9.67 CPU used by this session
single                         1 20171026 15:28      20171030 11:00:24 20171030 11       4949        2.45 CPU used by this session
single                         1 20171026 15:28      20171030 12:00:40 20171030 12       5213        2.64 CPU used by this session
single                         1 20171026 15:28      20171030 13:00:48 20171030 13       6070        8.57 CPU used by this session
single                         1 20171026 15:28      20171030 14:00:54 20171030 14       6746        6.76 CPU used by this session
single                         1 20171026 15:28      20171030 15:01:00 20171030 15     120993     1142.47 CPU used by this session
single                         1 20171101 12:29      20171101 12:29:37 20171101 12       1566    -1194.27 CPU used by this session

*/
-----------------------------------------
-- SYSMETRICS
-----------------------------------------
-- Microseconds
-- IN AIX this is capacity
column stat_name format a44
select distinct stat_name 
from DBA_HIST_SYS_TIME_MODEL where lower(stat_name ) like '%cpu%'
order by 1;

column startup_time format a19
column stat_name format a28
select  i.instance_name, 
        snap.instance_number, 
        to_char(snap.startup_time, 'YYYYMMDD HH24:MI') startup_time, 
        to_char(snap.begin_interval_time,'YYYYMMDD HH24:MI:SS') begin_interval_time, 
        to_char(snap.begin_interval_time,'YYYYMMDD HH24') begin_hour, 
        stat.value,
        round(stat.value/1e6 - lag(stat.value/1e6,1,0) over (order by to_char(snap.begin_interval_time,'YYYYMMDD HH24:MI:SS')),2) cpu_seconds,
        stat.stat_name
from DBA_HIST_SYS_TIME_MODEL stat,
     dba_hist_snapshot snap,
     v$instance i
where stat.snap_id=snap.snap_id
  and stat.instance_number=snap.instance_number
  and i.instance_number= snap.instance_number
  and stat.stat_name = 'DB CPU'
order by to_char(snap.begin_interval_time,'YYYYMMDD HH24');

-- For collecting data
/* -- Create the dump file immediately 
  CREATE TABLE DB_CPU_FROM_AWR ORGANIZATION EXTERNAL (TYPE ORACLE_DATAPUMP
  DEFAULT DIRECTORY workdir LOCATION ('db_cpu_from_awr.dmp'))
  AS */
select  i.instance_name, 
        snap.instance_number, 
        snap.startup_time          startup_time, 
        snap.begin_interval_time   begin_interval_time, 
        stat.value,
        round(stat.value/1e6 - lag(stat.value/1e6,1,0) over (order by to_char(snap.begin_interval_time,'YYYYMMDD HH24:MI:SS')),2) cpu_seconds,
        stat.stat_name
from DBA_HIST_SYS_TIME_MODEL stat,
     dba_hist_snapshot snap,
     v$instance i
where stat.snap_id=snap.snap_id
  and stat.instance_number=snap.instance_number
  and i.instance_number= snap.instance_number
  and stat.stat_name = 'DB CPU'
;

/*
INSTANCE_NAME    INSTANCE_NUMBER STARTUP_TIME        BEGIN_INTERVAL_TI BEGIN_HOUR       VALUE CPU_SECONDS STAT_NAME
---------------- --------------- ------------------- ----------------- ----------- ---------- ----------- ----------------------------
single                         1 20171024 15:32      20171026 11:00:01 20171026 11  236375000         .94 DB CPU
single                         1 20171024 15:32      20171026 12:00:08 20171026 12  236906250         .53 DB CPU
single                         1 20171024 15:32      20171026 13:00:14 20171026 13  237609375          .7 DB CPU
single                         1 20171024 15:32      20171026 14:00:21 20171026 14  242406250         4.8 DB CPU
single                         1 20171026 15:28      20171026 15:28:05 20171026 15    6937500     -235.47 DB CPU
single                         1 20171026 15:28      20171026 16:00:03 20171026 16    9812500        2.88 DB CPU
single                         1 20171026 15:28      20171027 13:16:07 20171027 13   10656250         .84 DB CPU
single                         1 20171026 15:28      20171027 14:00:26 20171027 14   12562500        1.91 DB CPU
single                         1 20171026 15:28      20171030 09:49:06 20171030 09   16687500        4.13 DB CPU
single                         1 20171026 15:28      20171030 11:00:24 20171030 11   16859375         .17 DB CPU
single                         1 20171026 15:28      20171030 12:00:40 20171030 12   17265625         .41 DB CPU
single                         1 20171026 15:28      20171030 13:00:48 20171030 13   23609375        6.34 DB CPU
single                         1 20171026 15:28      20171030 14:00:54 20171030 14   27187500        3.58 DB CPU
single                         1 20171026 15:28      20171030 15:01:00 20171030 15 1162515625     1135.33 DB CPU
single                         1 20171101 12:29      20171101 12:29:37 20171101 12    7312500     -1155.2 DB CPU
*/

-----------------------------------------
-- DASH HOURLY
-----------------------------------------
-- Ebben CPU runqueue wait is benne van
select i.instance_name, i.instance_number, 
       to_char(sample_time,'YYYYMMDD HH24') hour,
       count(1) * 10 as seconds
from dba_hist_active_sess_history ash,
     v$instance i
where i.instance_number = ash.instance_number
  and session_state='ON CPU'
group by i.instance_name, i.instance_number,
       to_char(sample_time,'YYYYMMDD HH24')
order by  to_char(sample_time,'YYYYMMDD HH24') 
;

/*
INSTANCE_NAME    INSTANCE_NUMBER HOUR           SECONDS
---------------- --------------- ----------- ----------
single                         1 20171026 16        320
single                         1 20171027 13        480
single                         1 20171027 14        120
single                         1 20171030 09        130
single                         1 20171030 10        460
single                         1 20171030 11        490
single                         1 20171030 12        500
single                         1 20171030 13        430
single                         1 20171030 14        360
single                         1 20171030 15       1320
single                         1 20171030 16        190
single                         1 20171030 18        120
single                         1 20171101 12        310
single                         1 20171101 13        630
*/


-----------------------------------------
-- DASH DETAILED
-----------------------------------------
-- Ebben CPU runqueue wait is benne van, mert mintavetelezett
/* -- Create the dump file immediately 
  CREATE TABLE waits_from_dash ORGANIZATION EXTERNAL (TYPE ORACLE_DATAPUMP
  DEFAULT DIRECTORY workdir LOCATION ('waits_from_dash.dmp'))
  AS */
select i.instance_name, i.instance_number, 
       ash.sample_time,
       sql_id,
       event,
       wait_class, wait_time, session_state, time_waited
from dba_hist_active_sess_history ash,
     v$instance i
where i.instance_number = ash.instance_number;

-----------------------------------------
-- SYSMETRICS OS
-----------------------------------------
-- Microseconds
-- IN AIX this is capacity
column stat_name format a44
select distinct stat_name 
from dba_hist_osstat where lower(stat_name ) like '%&metric%'
order by 1;

select 'OS Busy Time' series, to_char(snaptime, 'yyyy-mm-dd hh24') snap_time, round(busydelta / (busydelta + idledelta) * 100, 2) "CPU Use (%)"
from (
select s.begin_interval_time snaptime,
os1.value - lag(os1.value) over (order by s.snap_id) busydelta,
os2.value - lag(os2.value) over (order by s.snap_id) idledelta
from dba_hist_snapshot s, dba_hist_osstat os1, dba_hist_osstat os2
where
s.snap_id = os1.snap_id and s.snap_id = os2.snap_id
and s.instance_number = os1.instance_number and s.instance_number = os2.instance_number
and s.dbid = os1.dbid and s.dbid = os2.dbid
and s.instance_number = (select instance_number from v$instance)
and s.dbid = (select dbid from v$database)
and os1.stat_name = 'BUSY_TIME'
and os2.stat_name = 'IDLE_TIME'
and s.snap_id between &beginsnap and &endsnap
)

-- FOR DISPLAYING results
select i.instance_name, 
       snap.instance_number, 
       to_char(snap.startup_time, 'YYYYMMDD HH24:MI') startup_time, 
       to_char(snap.begin_interval_time,'YYYYMMDD HH24:MI:SS') begin_interval_time, 
       to_char(snap.begin_interval_time,'YYYYMMDD HH24') begin_hour, 
       round(obusy.value/100 - lag(obusy.value/100,1,0) over (order by snap.begin_interval_time),2) busy_sec,
       round(oidle.value/100 - lag(oidle.value/100,1,0) over (order by snap.begin_interval_time),2) idle_sec,
       round(ouser.value/100 - lag(ouser.value/100,1,0) over (order by snap.begin_interval_time),2) user_sec,
       round(osys.value/100  - lag(osys.value/100,1,0)  over (order by snap.begin_interval_time),2) sys_sec
from dba_hist_snapshot snap, dba_hist_osstat obusy, dba_hist_osstat oidle, dba_hist_osstat ouser, dba_hist_osstat osys, v$instance i
where snap.snap_id = obusy.snap_id and snap.snap_id = oidle.snap_id and snap.snap_id = ouser.snap_id and snap.snap_id = osys.snap_id
  and i.instance_number= snap.instance_number
and obusy.stat_name = 'BUSY_TIME'
and oidle.stat_name = 'IDLE_TIME'
and ouser.stat_name = 'USER_TIME'
and osys.stat_name =  'SYS_TIME'
order by to_char(snap.begin_interval_time,'YYYYMMDD HH24');
;

-- FOR collecting results
/* -- Create the dump file immediately 
  CREATE TABLE os_stats_from_awr ORGANIZATION EXTERNAL (TYPE ORACLE_DATAPUMP
  DEFAULT DIRECTORY workdir LOCATION ('os_stats_from_awr.dmp'))
  AS */
SELECT i.instance_name, 
       snap.instance_number, 
       snap.startup_time            startup_time, 
       snap.begin_interval_time     begin_interval_time, 
       round(obusy.value/100 - lag(obusy.value/100,1,0) over (order by snap.begin_interval_time),2) busy_sec,
       round(oidle.value/100 - lag(oidle.value/100,1,0) over (order by snap.begin_interval_time),2) idle_sec,
       round(ouser.value/100 - lag(ouser.value/100,1,0) over (order by snap.begin_interval_time),2) user_sec,
       round(osys.value/100  - lag(osys.value/100,1,0)  over (order by snap.begin_interval_time),2) sys_sec
from dba_hist_snapshot snap, dba_hist_osstat obusy, dba_hist_osstat oidle, dba_hist_osstat ouser, dba_hist_osstat osys, v$instance i
where snap.snap_id = obusy.snap_id and snap.snap_id = oidle.snap_id and snap.snap_id = ouser.snap_id and snap.snap_id = osys.snap_id
  and i.instance_number= snap.instance_number
  and obusy.stat_name = 'BUSY_TIME'
  and oidle.stat_name = 'IDLE_TIME'
  and ouser.stat_name = 'USER_TIME'
  and osys.stat_name =  'SYS_TIME'
;


--------------------------------------------------------
--  DDL for Table RK_LOG
--------------------------------------------------------

  CREATE TABLE "RK_LOG" 
   (	"MESS" VARCHAR2(200 BYTE), 
	"ST" TIMESTAMP (6)
   ) ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTAT_CONTROL
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTAT_CONTROL" 
   (	"ID" NUMBER(3,0), 
	"TS" TIMESTAMP (6), 
	"EXPECTED_THREADNUM" NUMBER(3,0), 
	"NOTES" VARCHAR2(50 BYTE)
   )  ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTAT_EVENTS
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTAT_EVENTS" 
   (	"SNAPID" NUMBER, 
	"USERNAME" VARCHAR2(30 BYTE), 
	"SID" NUMBER, 
	"SERIAL#" NUMBER, 
	"EVENT" VARCHAR2(64 BYTE), 
	"TOTAL_WAITS" NUMBER, 
	"TOTAL_TIMEOUTS" NUMBER, 
	"TIME_WAITED" NUMBER, 
	"TIME_WAITED_MICRO" NUMBER, 
	"TS" TIMESTAMP (6)
   ) ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTAT_EVENTS_TMP
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTAT_EVENTS_TMP" 
   (	"SNAPID" NUMBER, 
	"USERNAME" VARCHAR2(30 BYTE), 
	"SID" NUMBER, 
	"SERIAL#" NUMBER, 
	"EVENT" VARCHAR2(64 BYTE), 
	"TOTAL_WAITS" NUMBER, 
	"TOTAL_TIMEOUTS" NUMBER, 
	"TIME_WAITED" NUMBER, 
	"TIME_WAITED_MICRO" NUMBER, 
	"TS" TIMESTAMP (6)
   )  ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTAT_WORKAREA_ACT
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTAT_WORKAREA_ACT" 
   (	"SNAPID" NUMBER, 
	"SQL_ID" VARCHAR2(13 BYTE), 
	"SID" NUMBER, 
	"QCINST_ID" NUMBER, 
	"QCSID" NUMBER, 
	"ACTIVE_TIME" NUMBER, 
	"WORK_AREA_SIZE" NUMBER, 
	"EXPECTED_SIZE" NUMBER, 
	"ACTUAL_MEM_USED" NUMBER, 
	"MAX_MEM_USED" NUMBER, 
	"NUMBER_PASSES" NUMBER, 
	"TEMPSEG_SIZE" NUMBER, 
	"TABLESPACE" VARCHAR2(30 BYTE), 
	"TS" TIMESTAMP (6)
   )  ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTAT_WORKAREA_ACT_ALL
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTAT_WORKAREA_ACT_ALL" 
   (	"P_LOOP_ID" NUMBER, 
	"SNAPID" NUMBER, 
	"SQL_ID" VARCHAR2(13 BYTE), 
	"SID" NUMBER, 
	"QCINST_ID" NUMBER, 
	"QCSID" NUMBER, 
	"ACTIVE_TIME" NUMBER, 
	"WORK_AREA_SIZE" NUMBER, 
	"EXPECTED_SIZE" NUMBER, 
	"ACTUAL_MEM_USED" NUMBER, 
	"MAX_MEM_USED" NUMBER, 
	"NUMBER_PASSES" NUMBER, 
	"TEMPSEG_SIZE" NUMBER, 
	"TABLESPACE" VARCHAR2(30 BYTE), 
	"TS" TIMESTAMP (6)
   ) ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTAT_WORKAREA_ACT_TMP
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTAT_WORKAREA_ACT_TMP" 
   (	"SNAPID" NUMBER, 
	"SQL_ID" VARCHAR2(13 BYTE), 
	"SID" NUMBER, 
	"QCINST_ID" NUMBER, 
	"QCSID" NUMBER, 
	"ACTIVE_TIME" NUMBER, 
	"WORK_AREA_SIZE" NUMBER, 
	"EXPECTED_SIZE" NUMBER, 
	"ACTUAL_MEM_USED" NUMBER, 
	"MAX_MEM_USED" NUMBER, 
	"NUMBER_PASSES" NUMBER, 
	"TEMPSEG_SIZE" NUMBER, 
	"TABLESPACE" VARCHAR2(30 BYTE), 
	"TS" TIMESTAMP (6)
   ) ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTATS
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTATS" 
   (	"SNAPID" NUMBER, 
	"SID" NUMBER, 
	"NAME" VARCHAR2(64 BYTE), 
	"VALUE" NUMBER, 
	"TS" TIMESTAMP (6)
   )  ;
--------------------------------------------------------
--  DDL for Table RK_RUNSTATS_TMP
--------------------------------------------------------

  CREATE TABLE "RK_RUNSTATS_TMP" 
   (	"SNAPID" NUMBER, 
	"SID" NUMBER, 
	"NAME" VARCHAR2(64 BYTE), 
	"VALUE" NUMBER, 
	"TS" TIMESTAMP (6)
   )  ;
--------------------------------------------------------
--  DDL for Table T1
--------------------------------------------------------

  CREATE TABLE "T1" 
   (	"ID" NUMBER, 
	"V" VARCHAR2(200 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Index I
--------------------------------------------------------

  CREATE INDEX "I" ON "T1" ("V")  ;
  
  
  
  
  
  
  
  --------------------------------------------------------
--  DDL for View RK_RS_PARALLEL_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RK_RS_PARALLEL_V" ("NAME", "FIRST_VAL", "SECOND_VAL", "FIRST_THREADS", "SECOND_THREADS", "VALUE_DIFF") AS 
  with first_run as (
  select 
    count(1) threads,
    r1.name, 
    sum(r2.value-r1.value) as value
  from rk_runstats r1,
       rk_runstats r2    
  where r1.snapid=1 and
        r2.snapid=2 and
        r1.name=r2.name and 
        r1.sid=r2.sid
  group by r1.name
),
second_run as (
  select 
    count(1) threads,
    r3.name, 
    sum(r4.value-r3.value) as value
  from rk_runstats r3,
       rk_runstats r4    
  where r3.snapid=3 and
        r4.snapid=4 and
        r3.name=r4.name and
        r3.sid=r4.sid
  group by r3.name
)
select 
  first_run.name, 
  first_run.value first_val,
  second_run.value second_val,
  first_run.threads first_threads,
  second_run.threads second_threads,
  first_run.value-second_run.value as value_diff
from first_run, second_run
where first_run.name=second_run.name
  --and first_run.value-second_run.value>0
order by 4 desc;
--------------------------------------------------------
--  DDL for View RK_RS_PARALLEL_WORKAREA_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RK_RS_PARALLEL_WORKAREA_V" ("SNAPID", "SID", "MAX_TEMPSEG_SIZE", "MAX_ACTUAL_MEM_USED", "MAX_MAX_MEM_USED", "TABLESPACE", "MIN_TS", "MAX_TS") AS 
  select snapid, sid,
  max(tempseg_size) max_tempseg_size, 
  max(ACTUAL_MEM_USED) max_ACTUAL_MEM_USED,
  max(MAX_MEM_USED) max_max_MEM_USED,
tablespace, min(ts) min_ts, max(ts) max_ts
from RK_RUNSTAT_WORKAREA_ACT_ALL
group by snapid, sid, tablespace
order by 1;
--------------------------------------------------------
--  DDL for View RK_RS_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RK_RS_V" ("NAME", "FIRST_VAL", "SECOND_VAL", "VALUE_DIFF") AS 
  with first_run as 
(select r1.name, 
  r2.value-r1.value as value
from rk_runstats r1,
     rk_runstats r2    
where r1.snapid=1 and
      r2.snapid=2 and
      r1.name=r2.name (+)),
second_run as (select r3.name, 
r4.value-r3.value value
from rk_runstats r3,
     rk_runstats r4    
where r3.snapid=3 and
      r4.snapid=4 and
      r3.name=r4.name (+))
select 
  first_run.name, 
  first_run.value first_val,
  second_run.value second_val,
  first_run.value-second_run.value as value_diff
from first_run, second_run
where first_run.name=second_run.name
  --and first_run.value-second_run.value>0
order by 4 desc;
--------------------------------------------------------
--  DDL for View RK_RSE_PARALLEL_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RK_RSE_PARALLEL_V" ("EVENT", "FIRST_WAIT_SEC", "SECOND_WAIT_SEC", "DIFF_SEC", "PERCENTO", "FIRST_THREADS", "SECOND_THREADS", "FIRST_WAITS", "SECOND_WAITS", "COUNT_DIFF", "FIRST_AVG_WAIT_US", "SECOND_AVG_WAIT_US") AS 
  with first_run as (
  select r1.event, 
         count(1) as threads,
         sum(r2.time_waited_micro-r1.time_waited_micro) wait,
         sum(r2.total_waits-r1.total_waits) total_waits
  from rk_runstat_events r1,
       rk_runstat_events r2    
  where r1.snapid =1 and
        r2.snapid =2 and
        r1.event  =r2.event and 
        r1.sid    =r2.sid and
        r1.serial#=r2.serial#
  group by r1.event
),
second_run as ( 
  select r3.event, 
         count(1) as threads,
         sum(r4.time_waited_micro-r3.time_waited_micro) wait,
         sum(r4.total_waits-r3.total_waits) total_waits
  from rk_runstat_events r3,
       rk_runstat_events r4    
  where r3.snapid =3 and
        r4.snapid =4 and
        r3.event  =r4.event and 
        r3.sid    =r4.sid and
        r3.serial#=r4.serial#
  group by r3.event
)
select 
  first_run.event, 
  round(first_run.wait/1e6,2) as first_wait_sec, 
  round(second_run.wait/1e6,2) as second_wait_sec,
  round((first_run.wait-second_run.wait)/1e6,2) as diff_sec, 
  round(first_run.wait/(second_run.wait+0.0001),2) as percento,
  first_run.threads as first_threads,
  second_run.threads as second_threads,
  first_run.total_waits as first_waits, second_run.total_waits as second_waits,
  first_run.total_waits-second_run.total_waits as count_diff,
  round(first_run.wait/(first_run.total_waits+0.0001),2) first_avg_wait_us,
  round(second_run.wait/(second_run.total_waits+0.0001),2) second_avg_wait_us
from first_run, second_run
where first_run.event=second_run.event
order by 4 desc;
--------------------------------------------------------
--  DDL for View RK_RSE_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RK_RSE_V" ("EVENT", "FIRST_WAIT_SEC", "SECOND_WAIT_SEC", "DIFF_SEC", "PERCENTO", "FIRST_WAITS", "SECOND_WAITS", "COUNT_DIFF", "FIRST_AVG_WAIT_US", "SECOND_AVG_WAIT_US") AS 
  with first_run as 
(select r1.event, r2.time_waited_micro-r1.time_waited_micro wait,
r2.total_waits-r1.total_waits total_waits
from rk_runstat_events r1,
     rk_runstat_events r2    
where r1.snapid=1 and
      r2.snapid=2 and
      r1.event=r2.event (+)),
second_run as (select r3.event, r4.time_waited_micro-r3.time_waited_micro wait,
r4.total_waits-r3.total_waits total_waits
from rk_runstat_events r3,
     rk_runstat_events r4    
where r3.snapid=3 and
      r4.snapid=4 and
      r3.event=r4.event (+))
select 
  first_run.event, 
  round(first_run.wait/1e6,2) as first_wait_sec, 
  round(second_run.wait/1e6,2) as second_wait_sec,
  round((first_run.wait-second_run.wait)/1e6,2) as diff_sec, 
  round(first_run.wait/(second_run.wait+0.0001),2) as percento,
  first_run.total_waits as first_waits, second_run.total_waits as second_waits,
  first_run.total_waits-second_run.total_waits as count_diff,
  round(first_run.wait/(first_run.total_waits+0.0001),2) first_avg_wait_us,
  round(second_run.wait/(second_run.total_waits+0.0001),2) second_avg_wait_us
from first_run, second_run
where first_run.event=second_run.event
order by 4 desc;




--- 
create or replace view rk_runstat_ash_anal_v as    
with pivot_control as (     
select * from 
(select id, ts from rk_runstat_control) 
pivot (max(ts) as ts for (id) in (1 as t1, 2 as t2, 3 as t3, 4 as t4))
)
select case when sample_time between t1_ts and t2_ts then 'TEST 1'
            when sample_time between t3_ts and t4_ts then 'TEST 2' end TESTCASE,
     sample_time,
     session_id,
     sql_plan_operation, sql_plan_options, event, delta_time, tm_delta_time, time_waited, delta_read_io_bytes, delta_write_io_bytes, pga_allocated, temp_space_allocated, 
     sql_id, sql_child_number
     --, ash.*
from v$active_session_history ash,
     pivot_control
where (sample_time between t1_ts and t2_ts or sample_time between t3_ts and t4_ts)   
   and module='RK_RUNSTAT'
   and action <> 'MEASURING'
order by 2,3;



  CREATE OR REPLACE  VIEW "RK_RUNSTAT_DASH_ANAL_V" ("TESTCASE", "SAMPLE_TIME", "SESSION_ID", "SQL_PLAN_OPERATION", "SQL_PLAN_OPTIONS", "EVENT", "DELTA_TIME", "TM_DELTA_TIME", "TIME_WAITED", "DELTA_READ_IO_BYTES", "DELTA_WRITE_IO_BYTES", "PGA_ALLOCATED", "TEMP_SPACE_ALLOCATED", "SQL_ID", "SQL_CHILD_NUMBER") AS 
  with pivot_control as (     
select * from 
(select id, ts from rk_runstat_control) 
pivot (max(ts) as ts for (id) in (1 as t1, 2 as t2, 3 as t3, 4 as t4))
)
select case when sample_time between t1_ts and t2_ts then 'TEST 1'
            when sample_time between t3_ts and t4_ts then 'TEST 2' end TESTCASE,
     sample_time,
     session_id,
     sql_plan_operation, sql_plan_options, event, delta_time, tm_delta_time, time_waited, delta_read_io_bytes, delta_write_io_bytes, pga_allocated, temp_space_allocated, 
     sql_id, sql_child_number
     --, ash.*
from dba_hist_active_sess_history ash,
     pivot_control
where (sample_time between t1_ts and t2_ts or sample_time between t3_ts and t4_ts)   
   and module='RK_RUNSTAT'
   and action <> 'MEASURING'
order by 2,3;

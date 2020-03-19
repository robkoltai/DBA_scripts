
-- This select should be tuned to use less CPU
-- 9zrknukqjrb65
SELECT COUNT(*) FROM V$PX_PROCESS WHERE STATUS = 'IN USE';


-- SETUP
create tablespace px datafile '/oradata/UNI/px01.dbf' size 500m autoextend on maxsize 1g;

-- create px user 
drop user px cascade;
create user px identified by px
default tablespace px;

-- Grants
grant dba to px;

-- TEst table 
conn px/px

create table px as select * from dba_objects;
insert into px select * from px;
r
r
r
r
r

-- until 2M records present in px;
commit;





-- with sys

alter session set statistics_level= all;
SELECT COUNT(*) FROM V$PX_PROCESS WHERE STATUS = 'IN USE';

-- with px dba user
--19c 12.2.0.3
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE +HINT_REPORT'))
/
save xplan;


-----------------------------------------------
-- TESTS
-----------------------------------------------

-- T1 orig query DBA vs SYSDBA
-- Result PHV is the same 3785372079. Exec is the same

-- T2 how about select count(1)
SELECT COUNT(1) FROM V$PX_PROCESS WHERE STATUS = 'IN USE';
-- RESULT: Same stuff

-- T3 IN USE FILTER
select KXFPDPFLG flag,
  BITAND("KXFPDPFLG",8) b8,
  BITAND("A"."KXFPDPFLG",16) b16,
  DECODE(BITAND("A"."KXFPDPFLG",16),0,'IN USE','AVAILABLE')
from X$KXFPDP A;

      FLAG         B8        B16 DECODE(BI
---------- ---------- ---------- ---------
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE
        24          8         16 AVAILABLE


--------------------------------------------------------------------------------------------------
| Id  | Operation        | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| A-Rows |   A-Time   |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |          |      1 |        |       |     1 (100)|      8 |00:00:00.01 |
|   1 |  FIXED TABLE FULL| X$KXFPDP |      1 |      4 |    12 |     0   (0)|      8 |00:00:00.01 |
--------------------------------------------------------------------------------------------------

desc v$pq_slave
desc v$px_process 

select count(1) from v$pq_slave where status='BUSY';

---------------------------------------------------------------------------------------------------
| Id  | Operation         | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| A-Rows |   A-Time   |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |      1 |        |       |     1 (100)|      1 |00:00:00.01 |
|   1 |  SORT AGGREGATE   |          |      1 |      1 |     6 |            |      1 |00:00:00.01 |
|*  2 |   FIXED TABLE FULL| X$KXFPDP |      1 |      1 |     6 |     0   (0)|      0 |00:00:00.01 |
---------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter((BITAND("KXFPDPFLG",8)<>0 AND DECODE(BITAND("KXFPDPFLG",16),0,'BUSY','IDLE')=
              'BUSY' AND "INST_ID"=USERENV('INSTANCE')))



--T4 stresstest

SQL_ID  9zrknukqjrb65, child number 0
-------------------------------------
SELECT COUNT(*) FROM V$PX_PROCESS WHERE STATUS = 'IN USE'

Plan hash value: 3785372079

-------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name            | Starts | E-Rows |E-Bytes| Cost (%CPU)| A-Rows |   A-Time   |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                 |      1 |        |       |     1 (100)|      1 |00:00:00.01 |       |       |          |
|   1 |  SORT AGGREGATE               |                 |      1 |      1 |    35 |            |      1 |00:00:00.01 |       |       |          |
|*  2 |   HASH JOIN                   |                 |      1 |      1 |    35 |     0   (0)|     21 |00:00:00.01 |  2171K|  2171K| 1503K (0)|
|*  3 |    HASH JOIN OUTER            |                 |      1 |      1 |    26 |     0   (0)|     21 |00:00:00.01 |  2171K|  2171K| 1518K (0)|
|*  4 |     FIXED TABLE FULL          | X$KXFPDP        |      1 |      1 |    12 |     0   (0)|     21 |00:00:00.01 |       |       |          |
|   5 |     VIEW                      | V$SESSION       |      1 |     12 |   168 |     0   (0)|     82 |00:00:00.01 |       |       |          |
|   6 |      NESTED LOOPS             |                 |      1 |     12 |   324 |     0   (0)|     82 |00:00:00.01 |       |       |          |
|   7 |       NESTED LOOPS            |                 |      1 |     12 |   276 |     0   (0)|     82 |00:00:00.01 |       |       |          |
|   8 |        FIXED TABLE FULL       | X$KSLWT         |      1 |     51 |   408 |     0   (0)|     82 |00:00:00.01 |       |       |          |
|*  9 |        FIXED TABLE FIXED INDEX| X$KSUSE (ind:1) |     82 |      1 |    15 |     0   (0)|     82 |00:00:00.01 |       |       |          |
|* 10 |       FIXED TABLE FIXED INDEX | X$KSLED (ind:2) |     82 |      1 |     4 |     0   (0)|     82 |00:00:00.01 |       |       |          |
|* 11 |    FIXED TABLE FULL           | X$KSUPR         |      1 |     18 |   162 |     0   (0)|     94 |00:00:00.01 |       |       |          |
-------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."KXFPDPSPID"="KSUPROSID")
   3 - access("A"."KXFPDPSPID"="C"."PROCESS")
   4 - filter((BITAND("KXFPDPFLG",8)<>0 AND DECODE(BITAND("A"."KXFPDPFLG",16),0,'IN USE','AVAILABLE')='IN USE' AND
              "A"."INST_ID"=USERENV('INSTANCE')))
   9 - filter(("S"."INDX"="W"."KSLWTSID" AND BITAND("S"."KSSPAFLG",1)<>0 AND BITAND("S"."KSUSEFLG",1)<>0 AND
              "S"."INST_ID"=USERENV('INSTANCE')))
  10 - filter("W"."KSLWTEVT"="E"."INDX")
  11 - filter(("KSUPROSID" IS NOT NULL AND BITAND("KSSPAFLG",1)<>0 AND "INST_ID"=USERENV('INSTANCE')))



SQL_ID  bzzkfrw9qfk06, child number 0
-------------------------------------
select count(1) from v$pq_slave where status='BUSY'

Plan hash value: 1613399420

---------------------------------------------------------------------------------------------------
| Id  | Operation         | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| A-Rows |   A-Time   |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |      1 |        |       |     1 (100)|      1 |00:00:00.01 |
|   1 |  SORT AGGREGATE   |          |      1 |      1 |     6 |            |      1 |00:00:00.01 |
|*  2 |   FIXED TABLE FULL| X$KXFPDP |      1 |      1 |     6 |     0   (0)|     24 |00:00:00.01 |
---------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter((BITAND("KXFPDPFLG",8)<>0 AND DECODE(BITAND("KXFPDPFLG",16),0,'BUSY','IDLE')=
              'BUSY' AND "INST_ID"=USERENV('INSTANCE')))


-- t5 SQLTRACE

alter system set parallel_max_servers=300;
alter system set parallel_servers_target=128;
alter system set processes=1200 scope=spfile;



alter system set events 'sql_trace[sql:bzzkfrw9qfk06|9zrknukqjrb65] wait=true, bind=true,plan_stat=all_executions';
@new
@new
@new
@orig
@orig
@orig
@new
@new
@new
@orig
@orig
@orig
alter system set events 'sql_trace[sql:bzzkfrw9qfk06|9zrknukqjrb65] off';



alter system set parallel_max_servers=80;
alter system set parallel_servers_target=32;
alter system set processes=300 scope=spfile;

------------------
WHO IS WHO


SELECT COUNT(*) FROM V$PX_PROCESS WHERE STATUS = 'IN USE';
Plan hash value: 3785372079
-------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name            | Starts | E-Rows |E-Bytes| Cost (%CPU)| A-Rows |   A-Time   |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                 |      1 |        |       |     1 (100)|      1 |00:00:00.01 |       |       |          |
|   1 |  SORT AGGREGATE               |                 |      1 |      1 |    35 |            |      1 |00:00:00.01 |       |       |          |
|*  2 |   HASH JOIN                   |                 |      1 |      1 |    35 |     0   (0)|      0 |00:00:00.01 |  1236K|  1236K|  501K (0)|
|*  3 |    HASH JOIN OUTER            |                 |      1 |      1 |    26 |     0   (0)|      0 |00:00:00.01 |  1538K|  1538K|  368K (0)|
|*  4 |     FIXED TABLE FULL          | X$KXFPDP        |      1 |      1 |    12 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|   5 |     VIEW                      | V$SESSION       |      0 |     12 |   168 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|   6 |      NESTED LOOPS             |                 |      0 |     12 |   324 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|   7 |       NESTED LOOPS            |                 |      0 |     12 |   276 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|   8 |        FIXED TABLE FULL       | X$KSLWT         |      0 |     51 |   408 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|*  9 |        FIXED TABLE FIXED INDEX| X$KSUSE (ind:1) |      0 |      1 |    15 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|* 10 |       FIXED TABLE FIXED INDEX | X$KSLED (ind:2) |      0 |      1 |     4 |     0   (0)|      0 |00:00:00.01 |       |       |          |
|* 11 |    FIXED TABLE FULL           | X$KSUPR         |      0 |     18 |   162 |     0   (0)|      0 |00:00:00.01 |       |       |          |
-------------------------------------------------------------------------------------------------------------------------------------------------

X$KSLWT
-- gv$session_wait                x$kslwt - x$ksled	

X$KSUPR
-- gv$process                     x$ksupr

X$KXFPDP
-- gv$pq_slave                    x$kxfpdp
-- gv$px_process                  x$kxfpdp
-- gv$px_session                  x$ksuse - x$kxfpdp
-- gv$px_sesstat                  x$ksuse - x$kxfpdp - x$ksusesta - x$ksusgif

---------------------------------
-- EREDMENYEK
---------------------------------
1) alap lekerdezest SYS es DBA ugyanugy hajtja végre

-- Q: Arra a kérdésre keresem a választ, hogy olyankor is invalidálódik-e a cache tartalma, ha a függvény eredményére hatással nem lévő, de a függvényben szereplő táblát változtatunk.
-- Conclusion:
-- Result cache invalidations depend only on changes that REALLY affect PLSQL results
-- Dependency can be directly queried
	-- the definitions 				from v$result_cache_objects where type='Dependency'
	-- the actual data dependency 	via result_cache_dependencies.sql (v$result_cache_objects,v$result_cache_dependency)


-- RESULT CACHE STATS SQLs
SET SERVEROUTPUT ON
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
COLUMN name FORMAT a35
SELECT name, value
FROM V$RESULT_CACHE_STATISTICS;
show parameter result_cache_max;


-- SETUP tables as normal user
drop table rc_readonly_data purge;
create table rc_readonly_data
as 
select rownum as n, 
       RPAD(rownum,200,'XYZ') t
from dual 
connect by level<=100000;	

drop table rc_log purge;
create table rc_log (d date);

-- SETUP PLSQL code as normal user
-- THIs code uses result cache
create or replace function get_readonly_data_and_log_it (pn number)
  return varchar2
  result_cache
as
  v_t rc_readonly_data.t%type;
begin
	
	-- insert independent data
    insert into rc_log values (sysdate);
	
	-- select static data
	select t into v_t
	from rc_readonly_data
	where n=pn;

	return pn;
  
end;
/

	
SET SERVEROUTPUT ON

-- This code is the calling application code
-- calls the function with start..end numbers in a loop
declare
  t rc_readonly_data.t%type;
  start_number number :=&start_number;
  end_number number :=&end_number;
  i number;
begin
  dbms_output.put_line ('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  for i in start_number..end_number loop
    --dbms_output.put_line (i);
    t:=get_readonly_data_and_log_it(i);
	dbms_output.put_line (t);
  end loop;
end;
/
 

 -------------------------------------------------------
 -- TEST
--------------------------------------------------------

-- step 0. befor the start and after flush
-- exec DBMS_RESULT_CACHE.flush;

R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 167288 bytes [0.045% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 161936 bytes [0.044% of the Shared Pool]
....... Overhead = 129168 bytes
....... Cache Memory = 32K bytes (32 blocks)
........... Unused Memory = 24 blocks
........... Used Memory = 8 blocks
............... Dependencies = 2 blocks (2 count)
............... Results = 6 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                                VALUE
----------------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)                  1024
Block Count Maximum                 3008
Block Count Current                 32
Result Size Maximum (Blocks)        150
Create Count Success                6
Create Count Failure                0
Find Count                          12
Invalidation Count                  0
Delete Count Invalid                0
Delete Count Valid                  0
Hash Chain Length                   1
Find Copy Count                     12
Latch (Share)                       0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                                      HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS   SLEEP1     SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch              1054203712     187468          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch               986859868      44709          6          1              0                0             0                   0 5           0          0          0          0          0          0          0          0          0          0          0         87
0000000060046648        438          2 Result Cache: MB Latch               995186388          0          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0

SQL>                 

                                                                                                                                        
-- step 1 
-- test 10-19		10 new entries


R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 167288 bytes [0.045% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 161936 bytes [0.044% of the Shared Pool]
....... Overhead = 129168 bytes
....... Cache Memory = 32K bytes (32 blocks)
........... Unused Memory = 12 blocks
........... Used Memory = 20 blocks
............... Dependencies = 4 blocks (4 count)
............... Results = 16 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 15 blocks (15 count)			-- increased by 10

PL/SQL procedure successfully completed.


NAME                                VALUE
----------------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)                  1024
Block Count Maximum                 3008
Block Count Current                 32
Result Size Maximum (Blocks)        150
Create Count Success                16						-- increased by 10
Create Count Failure                0
Find Count                          18						-- increased by 6????
Invalidation Count                  0
Delete Count Invalid                0
Delete Count Valid                  0
Hash Chain Length                   1
Find Copy Count                     18						-- increased by 6????
Latch (Share)                       0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                                      HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS   SLEEP1     SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch              1054203712     187529          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch               986859868      44711          6          1              0                0             0                   0 5           0          0          0          0          0          0          0          0          0          0          0         87
0000000060046648        438          2 Result Cache: MB Latch               995186388          0          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0


-- step 2
-- test 20-29		10 new entries

 e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 167288 bytes [0.045% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 161936 bytes [0.044% of the Shared Pool]
....... Overhead = 129168 bytes
....... Cache Memory = 32K bytes (32 blocks)
........... Unused Memory = 2 blocks
........... Used Memory = 30 blocks
............... Dependencies = 4 blocks (4 count)
............... Results = 26 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 25 blocks (25 count)	-- increased by 10

PL/SQL procedure successfully completed.


NAME                                VALUE
----------------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)                  1024
Block Count Maximum                 3008
Block Count Current                 32
Result Size Maximum (Blocks)        150
Create Count Success                26			-- increased by 10
Create Count Failure                0
Find Count                          24			-- increased by 6???
Invalidation Count                  0
Delete Count Invalid                0
Delete Count Valid                  0
Hash Chain Length                   1
Find Copy Count                     24			-- increased by 6???
Latch (Share)                       0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                                      HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS   SLEEP1     SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch              1054203712     187587          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch               986859868      44713          6          1              0                0             0                   0 5           0          0          0          0          0          0          0          0          0          0          0         87
0000000060046648        438          2 Result Cache: MB Latch               995186388          0          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0

-- step 3
-- test 20-29		10 entries already in cache
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 167288 bytes [0.045% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 161936 bytes [0.044% of the Shared Pool]
....... Overhead = 129168 bytes
....... Cache Memory = 32K bytes (32 blocks)
........... Unused Memory = 2 blocks
........... Used Memory = 30 blocks
............... Dependencies = 4 blocks (4 count)
............... Results = 26 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 25 blocks (25 count)		-- no change here

PL/SQL procedure successfully completed.


NAME                                VALUE
----------------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)                  1024
Block Count Maximum                 3008
Block Count Current                 32
Result Size Maximum (Blocks)        150
Create Count Success                26					-- no change here
Create Count Failure                0
Find Count                          34					-- increased by 10
Invalidation Count                  0
Delete Count Invalid                0
Delete Count Valid                  0
Hash Chain Length                   1
Find Copy Count                     34					-- increased by 10
Latch (Share)                       0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                                      HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS   SLEEP1     SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch              1054203712     187599          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch               986859868      44713          6          1              0                0             0                   0 5           0          0          0          0          0          0          0          0          0          0          0         87
0000000060046648        438          2 Result Cache: MB Latch               995186388          0          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0

-- step 4
-- inserting into rc_log
insert into a.rc_log values (sysdate);
commit;


R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 167288 bytes [0.045% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 161936 bytes [0.044% of the Shared Pool]
....... Overhead = 129168 bytes
....... Cache Memory = 32K bytes (32 blocks)
........... Unused Memory = 2 blocks
........... Used Memory = 30 blocks
............... Dependencies = 4 blocks (4 count)
............... Results = 26 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 25 blocks (25 count)

PL/SQL procedure successfully completed.


NAME                                VALUE
----------------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)                  1024
Block Count Maximum                 3008
Block Count Current                 32
Result Size Maximum (Blocks)        150
Create Count Success                26			-- no change
Create Count Failure                0
Find Count                          40			-- increased by 6???
Invalidation Count                  0
Delete Count Invalid                0
Delete Count Valid                  0
Hash Chain Length                   1
Find Copy Count                     40			-- increased by 6???
Latch (Share)                       0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                                      HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS   SLEEP1     SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch              1054203712     187607          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch               986859868      44715          6          1              0                0             0                   0 5           0          0          0          0          0          0          0          0          0          0          0         87
0000000060046648        438          2 Result Cache: MB Latch               995186388          0          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0


-- step 4
-- inserting into rc_readonly_data
insert into a.rc_readonly_data values (-1,'to invalidate or not to invalidate?');
commit;


SQL> @r
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 167288 bytes [0.045% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 161936 bytes [0.044% of the Shared Pool]
....... Overhead = 129168 bytes
....... Cache Memory = 32K bytes (32 blocks)
........... Unused Memory = 2 blocks
........... Used Memory = 30 blocks
............... Dependencies = 4 blocks (4 count)
............... Results = 26 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 5 blocks (5 count)
................... Invalid = 20 blocks (20 count)			-- the 20 blocks got invalidated that we put in the result cache

PL/SQL procedure successfully completed.


NAME                                VALUE
----------------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)                  1024
Block Count Maximum                 3008
Block Count Current                 32
Result Size Maximum (Blocks)        150
Create Count Success                26
Create Count Failure                0
Find Count                          40
Invalidation Count                  20
Delete Count Invalid                0
Delete Count Valid                  0
Hash Chain Length                   1
Find Copy Count                     40
Latch (Share)                       0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                                      HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS   SLEEP1     SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch              1054203712     187611          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch               986859868      44715          6          1              0                0             0                   0 5           0          0          0          0          0          0          0          0          0          0          0         87
0000000060046648        438          2 Result Cache: MB Latch               995186388          0          0          0              0                0             0                   0 0           0          0          0          0          0          0          0          0          0          0          0          0



-- plusz info
select type, status, name, namespace, CREATION_TIMESTAMP
from v$result_cache_objects
where type='Dependency';

TYPE       STATUS    NAME                                NAMES CREATION_TIMESTAMP
---------- --------- ----------------------------------- ----- -------------------
Dependency Published A.RC_READONLY_DATA                        2018-06-29 12:36:04
Dependency Published A.GET_READONLY_DATA_AND_LOG_IT            2018-06-29 12:36:04


-- v$result_cache_objects
-- All columns
-- few rows
        ID TYPE       STATUS     BUCKET_NO       HASH NAME                                NAMES CREATION_TIMESTAMP  CREATOR_UID DEPEND_COUNT BLOCK_COUNT        SCN COLUMN_COUNT  PIN_COUNT SCAN_COUNT        ROW_COUNT ROW_SIZE_MAX ROW_SIZE_MIN ROW_SIZE_AVG BUILD_TIME LRU_NUMBER  OBJECT_NO INVALIDATIONS SPACE_OVERHEAD SPACE_UNUSED CACHE_ID CACHE_KEY                                                                                      DB_   CHECKSUM
---------- ---------- --------- ---------- ---------- ----------------------------------- ----- ------------------- ----------- ------------ ----------- ---------- ------------ ---------- ---------- ---------- ------------ ------------ ------------ ---------- ---------- ---------- ------------- -------------- ------------ --------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------- --- ----------
        10 Dependency Published       1169 2447090833 A.RC_READONLY_DATA                        2018-06-29 12:36:04         102            0           1 8.3482E+12            0          0    0           0            0            0            0          0          0     128222             1              0            0 A.RC_READONLY_DATA A.RC_READONLY_DATA                                                                             No           0
         8 Dependency Published       1284 3179746564 A.GET_READONLY_DATA_AND_LOG_IT            2018-06-29 12:36:04         102            0           1 8.3482E+12            0          0    0           0            0            0            0          0          0     128221             0              0            0 A.GET_READONLY_DATA_AND_LOG_IT A.GET_READONLY_DATA_AND_LOG_IT                                                         No           0

		 
		 
         9 Result     Invalid         3396 2150559044 "A"."GET_READONLY_DATA_AND_LOG_IT": PLSQL 2018-06-29 12:36:04         102            2           1 8.3482E+12            1          0    0           1            4            4            4          2          0          0             0            392          628 ga7czxrtz6j7d68ukx22nsfgnu a789w01s9v1x58r3ph96br5bpv                                                                     No   809924183
                                                      :8."GET_READONLY_DATA_AND_LOG_IT"#7
                                                      62ba075453b8b0d #1

        11 Result     Invalid          233 1508708585 "A"."GET_READONLY_DATA_AND_LOG_IT": PLSQL 2018-06-29 12:36:04         102            2           1 8.3482E+12            1          0    0           1            4            4            4          1          0          0             0            392          628 ga7czxrtz6j7d68ukx22nsfgnu bv603xrjpuwk4fy3swt8fvp7fx                                                                     No  4244147313
                                                      :8."GET_READONLY_DATA_AND_LOG_IT"#7
                                                      62ba075453b8b0d #1

        12 Result     Invalid         3888 1897426736 "A"."GET_READONLY_DATA_AND_LOG_IT": PLSQL 2018-06-29 12:36:04         102            2           1 8.3482E+12            1          0    0           1            4            4            4          2          0          0             0            392          628 ga7czxrtz6j7d68ukx22nsfgnu 4y5nbg1tztdtg1vhb0drsrncr2                                                                     No  1379283782
                                                      :8."GET_READONLY_DATA_AND_LOG_IT"#7
                                                      62ba075453b8b0d #1



-- STATS SQLs
SET SERVEROUTPUT ON
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
COLUMN name FORMAT a40
column value format a30
SELECT name, value
FROM V$RESULT_CACHE_STATISTICS;
show parameter result_cache_max;


-- SETUP SQLs
drop table rc_test purge;
create table rc_test as 
select rownum as n, 
       RPAD(rownum,200,'XYZ') t
from dual 
connect by level<=100000;	

SET SERVEROUTPUT ON

declare
  t rc_test.t%type;
  start_number number :=&start_number;
  end_number number :=&end_number;
  i number;
begin
  dbms_output.put_line ('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  for i in start_number..end_number loop
    dbms_output.put_line (i);
    execute immediate 'select /*+result_cache */ t from rc_test where n=' || i into t;
	dbms_output.put_line (t);
  end loop;
end;
/
 


 -- KIINDULASI allapot
SET SERVEROUTPUT ON
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
COLUMN name FORMAT a25
SELECT name, value
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 2336K bytes (2336 blocks)
Maximum Result Size = 116K bytes (116 blocks)
[Memory]
Total Memory = 1154288 bytes [0.316% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 1148936 bytes [0.315% of the Shared Pool]
....... Overhead = 133128 bytes
....... Cache Memory = 992K bytes (992 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 992 blocks
............... Dependencies = 91 blocks (91 count)
............... Results = 901 blocks
................... SQL     = 804 blocks (768 count)
................... PLSQL   = 93 blocks (76 count)
................... Invalid = 4 blocks (4 count)

PL/SQL procedure successfully completed.

SQL> SQL>   2  FROM V$RESULT_CACHE_STATISTICS;

NAME                 VALUE
-------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)   1024
Block Count Maximum  2336
Block Count Current  992
Result Size Maximum  116
(Blocks)

Create Count Success 960
Create Count Failure 304
Find Count           119926
Invalidation Count   116
Delete Count Invalid 112
Delete Count Valid   0
Hash Chain Length    0-1
Find Copy Count      119864
Latch (Share)        0

13 rows selected.

 AME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 2336K
result_cache_mode                    string      MANUAL

-- STEP 1 futtattam 11 selectet utana:
SQL> @r
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 2336K bytes (2336 blocks)
Maximum Result Size = 116K bytes (116 blocks)
[Memory]
Total Memory = 1187120 bytes [0.325% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 1181768 bytes [0.324% of the Shared Pool]
....... Overhead = 133192 bytes
....... Cache Memory = 1M bytes (1K blocks)						-- kicsit nott 32k-val
........... Unused Memory = 24 blocks							-- nott 24k
........... Used Memory = 1000 blocks							-- nott 8k
............... Dependencies = 92 blocks (92 count)				-- plusz 1 dependency, mert egy uj tabla adata vannak benne
............... Results = 908 blocks
................... SQL     = 815 blocks (779 count)			-- 11 novekedes
................... PLSQL   = 93 blocks (76 count)
																-- invalidok eltuntek
PL/SQL procedure successfully completed.


NAME                 VALUE
-------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)   1024
Block Count Maximum  2336
Block Count Current  1024
Result Size Maximum  116
(Blocks)

Create Count Success 971									-- plus 11
Create Count Failure 304
Find Count           119944
Invalidation Count   116
Delete Count Invalid 116
Delete Count Valid   0
Hash Chain Length    0-1
Find Copy Count      119882
Latch (Share)        0

13 rows selected.

-- STEP 2 futtattam 100 uj selectet utana:
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 2336K bytes (2336 blocks)
Maximum Result Size = 116K bytes (116 blocks)
[Memory]
Total Memory = 1285616 bytes [0.352% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 1280264 bytes [0.351% of the Shared Pool]
....... Overhead = 133384 bytes
....... Cache Memory = 1120K bytes (1120 blocks)
........... Unused Memory = 20 blocks
........... Used Memory = 1100 blocks								-- tovabb nott
............... Dependencies = 92 blocks (92 count)
............... Results = 1008 blocks
................... SQL     = 915 blocks (879 count)				-- nott 100-al
................... PLSQL   = 93 blocks (76 count)

PL/SQL procedure successfully completed.


NAME                 VALUE
-------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)   1024
Block Count Maximum  2336
Block Count Current  1120
Result Size Maximum  116
(Blocks)

Create Count Success 1071
Create Count Failure 304
Find Count           119950
Invalidation Count   116
Delete Count Invalid 116
Delete Count Valid   0
Hash Chain Length    0-1
Find Copy Count      119888
Latch (Share)        0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 2336K


-- STEP 3 meg rakultdok 1500-at, hogy elerjuk a cache maximum meretet es utana:

SQL> @r
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 2336K bytes (2336 blocks)				-- Itt mar kiutottem a max meretet
Maximum Result Size = 116K bytes (116 blocks)
[Memory]
Total Memory = 2533232 bytes [0.694% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 2527880 bytes [0.693% of the Shared Pool]
....... Overhead = 135816 bytes
....... Cache Memory = 2336K bytes (2336 blocks)			-- Itt mar kiutottem a max meretet
........... Unused Memory = 0 blocks
........... Used Memory = 2336 blocks						-- Itt mar kiutottem a max meretet
............... Dependencies = 92 blocks (92 count)
............... Results = 2244 blocks
................... SQL     = 2151 blocks (2119 count)
................... PLSQL   = 93 blocks (76 count)

PL/SQL procedure successfully completed.


NAME                 VALUE
-------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)   1024
Block Count Maximum  2336
Block Count Current  2336
Result Size Maximum  116
(Blocks)

Create Count Success 2571
Create Count Failure 304
Find Count           119956
Invalidation Count   116
Delete Count Invalid 116
Delete Count Valid   260
Hash Chain Length    0-1
Find Copy Count      119894
Latch (Share)        0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 2336K



ADDR                 LATCH#     LEVEL# NAME                       HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETS     SLEEP1     SLEEP2     SLEEP3   SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- -------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Lat 1054203712     134751          0          0              0                0             0                   0          00        0          0          0          0          0          0          0          0          0          0          0
   

-- step 4 meg raengedek 1000-et (uj szamokat)
SQL> @r.sql
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 2336K bytes (2336 blocks)
Maximum Result Size = 116K bytes (116 blocks)
[Memory]
Total Memory = 2533232 bytes [0.686% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 2527880 bytes [0.685% of the Shared Pool]
....... Overhead = 135816 bytes
....... Cache Memory = 2336K bytes (2336 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 2336 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2244 blocks
................... SQL     = 2239 blocks (2239 count)
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                 VALUE
-------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)   1024
Block Count Maximum  2336
Block Count Current  2336
Result Size Maximum  116
(Blocks)

Create Count Success 3571
Create Count Failure 304
Find Count           119968
Invalidation Count   116
Delete Count Invalid 116
Delete Count Valid   1211
Hash Chain Length    0-1
Find Copy Count      119906
Latch (Share)        0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 2336K

-- 5000-rel nott RC LATCH. 5x latch per iras
ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     139767          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39235          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

-- step 5 meg utoljara raengedek 1000-et (uj szamokat)

-- Cache allapota stabil
SQL> @r
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 2336K bytes (2336 blocks)
Maximum Result Size = 116K bytes (116 blocks)
[Memory]
Total Memory = 2533232 bytes [0.686% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 2527880 bytes [0.685% of the Shared Pool]
....... Overhead = 135816 bytes
....... Cache Memory = 2336K bytes (2336 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 2336 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2244 blocks
................... SQL     = 2239 blocks (2239 count)
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       2336
Block Count Current       2336
Result Size Maximum (Bloc 116
ks)

Create Count Success      4571
Create Count Failure      304
Find Count                119974
Invalidation Count        116
Delete Count Invalid      116
Delete Count Valid        2211
Hash Chain Length         0-1
Find Copy Count           119912
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 2336K

-- 5000-rel nott RC LATCH. 5x latch per iras
ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     144769          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39235          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

-- step 6 result cache max size novelese 3000k -ra
alter system set result_cache_max_size= 3000k scope=both;
-- Megjelent az uj memoria

SQL> @r
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)			-- Megjelent az uj memoria
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 2533232 bytes [0.686% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 2527880 bytes [0.685% of the Shared Pool]
....... Overhead = 135816 bytes
....... Cache Memory = 2336K bytes (2336 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 2336 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2244 blocks
................... SQL     = 2239 blocks (2239 count)
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       3008
Block Count Current       2336
Result Size Maximum (Bloc 150
ks)

Create Count Success      4571
Create Count Failure      304
Find Count                119974
Invalidation Count        116
Delete Count Invalid      116
Delete Count Valid        2211
Hash Chain Length         0-1
Find Copy Count           119912
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     144772          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39235          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

-- step 7 kuldok ra meg 200-at
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 2763056 bytes [0.749% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 2757704 bytes [0.747% of the Shared Pool]
....... Overhead = 136264 bytes
....... Cache Memory = 2560K bytes (2560 blocks)			-- cache megnott 224-el
........... Unused Memory = 24 blocks						-- ebbol 24 unused meg
........... Used Memory = 2536 blocks						-- 200 al nott pontosan
............... Dependencies = 92 blocks (92 count)
............... Results = 2444 blocks						-- 200 al nott pontosan
................... SQL     = 2439 blocks (2439 count)		-- 200 al nott pontosan
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       3008
Block Count Current       2560
Result Size Maximum (Bloc 150
ks)

Create Count Success      4771
Create Count Failure      304
Find Count                119992
Invalidation Count        116
Delete Count Invalid      116
Delete Count Valid        2211
Hash Chain Length         0-1
Find Copy Count           119930
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K


-- uj memoria valo iras is 5 latchet igenyel 5x200=1000 RC LATCH
-- SO latch 6 al nott
ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     145792          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39241          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

-- step 8 rakuldok 2000-et es feltoltom tejesen utana:
SQL> @r
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 3222704 bytes [0.873% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 3217352 bytes [0.872% of the Shared Pool]
....... Overhead = 137160 bytes
....... Cache Memory = 3008K bytes (3008 blocks)				-- fel van toltve teljesen
........... Unused Memory = 0 blocks
........... Used Memory = 3008 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2916 blocks
................... SQL     = 2911 blocks (2911 count)
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       3008
Block Count Current       3008
Result Size Maximum (Bloc 150
ks)

Create Count Success      5772
Create Count Failure      304
Find Count                119998
Invalidation Count        116
Delete Count Invalid      116
Delete Count Valid        2740
Hash Chain Length         0-2
Find Copy Count           119936
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     150805          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39243          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

-- step 9   1 sort update-elek a tablaban
update rc_test set n=-1 where n=1;
commit;

 e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 3222704 bytes [0.873% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 3217352 bytes [0.872% of the Shared Pool]
....... Overhead = 137160 bytes
....... Cache Memory = 3008K bytes (3008 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 3008 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2916 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 5 blocks (5 count)
................... Invalid = 2910 blocks (2910 count)			-- minden invalidalodik pedig csak 1 sort update-eltem

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       3008
Block Count Current       3008
Result Size Maximum (Bloc 150
ks)

Create Count Success      5772
Create Count Failure      304
Find Count                120004
Invalidation Count        3026
Delete Count Invalid      116
Delete Count Valid        2740
Hash Chain Length         1
Find Copy Count           119942
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     150819          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39245          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

SQL>                                                                                          

--- step 10 ismet feltoltom 4000 select-teljesen
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 3222704 bytes [0.873% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 3217352 bytes [0.872% of the Shared Pool]
....... Overhead = 137160 bytes
....... Cache Memory = 3008K bytes (3008 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 3008 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2916 blocks
................... SQL     = 2911 blocks (2911 count)				-- cache feltoltve
................... PLSQL   = 5 blocks (5 count)

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       3008
Block Count Current       3008
Result Size Maximum (Bloc 150
ks)

Create Count Success      9773
Create Count Failure      304
Find Count                120010
Invalidation Count        3026
Delete Count Invalid      3026
Delete Count Valid        3831
Hash Chain Length         0-2
Find Copy Count           119948
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     170832          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39247          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0

-- step 11       1 sor insert
insert into rc_test values (1111111,'vauu');
commit;

R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 3008K bytes (3008 blocks)
Maximum Result Size = 150K bytes (150 blocks)
[Memory]
Total Memory = 3222704 bytes [0.873% of the Shared Pool]
... Fixed Memory = 5352 bytes [0.001% of the Shared Pool]
... Dynamic Memory = 3217352 bytes [0.872% of the Shared Pool]
....... Overhead = 137160 bytes
....... Cache Memory = 3008K bytes (3008 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 3008 blocks
............... Dependencies = 92 blocks (92 count)
............... Results = 2916 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 5 blocks (5 count)
................... Invalid = 2910 blocks (2910 count)			-- 1 sor insert is invalidalta az osszes rekordot

PL/SQL procedure successfully completed.


NAME                      VALUE
------------------------- ---------------------------------------------------------------------------------
Block Size (Bytes)        1024
Block Count Maximum       3008
Block Count Current       3008
Result Size Maximum (Bloc 150
ks)

Create Count Success      9773
Create Count Failure      304
Find Count                120010
Invalidation Count        5936
Delete Count Invalid      3026
Delete Count Valid        3831
Hash Chain Length         1
Find Copy Count           119948
Latch (Share)             0

13 rows selected.


NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_max_result              integer     5
result_cache_max_size                big integer 3008K

ADDR                 LATCH#     LEVEL# NAME                            HASH       GETS     MISSES     SLEEPS IMMEDIATE_GETS IMMEDIATE_MISSES WAITERS_WOKEN WAITS_HOLDING_LATCH  SPIN_GETSSLEEP1   SLEEP2     SLEEP3     SLEEP4     SLEEP5     SLEEP6     SLEEP7     SLEEP8     SLEEP9    SLEEP10    SLEEP11  WAIT_TIME
---------------- ---------- ---------- ------------------------- ---------- ---------- ---------- ---------- -------------- ---------------- ------------- ------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
00000000600463B8        436          2 Result Cache: RC Latch    1054203712     170836          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046598        437          2 Result Cache: SO Latch     986859868      39247          2          0              0                0             0                   0          2  0           0          0          0          0          0          0          0          0          0          0          0
0000000060046648        438          2 Result Cache: MB Latch     995186388          0          0          0              0                0             0                   0          0  0           0          0          0          0          0          0          0          0          0          0          0


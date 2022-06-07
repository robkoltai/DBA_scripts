set lines 150
column name format a24
column value format a18
column time_computed format a20
column datum_time format a20
alter session set nls_date_format='HH24:MI:SS';

SELECT name, value, time_computed, datum_time, sysdate
FROM V$DATAGUARD_STATS;

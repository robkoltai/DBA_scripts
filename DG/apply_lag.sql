column name format a30
column value format a18
alter session set nls_date_format='MON-DD HH24:MI:SS';

SELECT name, value, datum_time, time_computed FROM
V$DATAGUARD_STATS WHERE name like 'apply lag';

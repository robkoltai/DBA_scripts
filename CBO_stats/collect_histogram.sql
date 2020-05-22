-- setup
create table META.RK_DO as select object_id, owner
from dba_objects;

set lines 180
set pages 100
column table_name format a25
column column_name format a20
column low_value format a20
column high_value format a20
column data_type format a15

alter session set nls_date_format = 'MMDD HH24:MI';
-- Check
select table_name, column_name, data_type, nullable, num_distinct, high_value, low_value, num_nulls, num_buckets, last_analyzed, histogram
from user_tab_cols
where table_name like upper('%&&table_name_pattern%')
order by table_name;

save hi.sql

-- Collect for object_id
begin
dbms_stats.gather_table_stats('META','RK_DO', cascade=>true,
  method_opt=>'FOR ALL COLUMNS SIZE 1 FOR COLUMNS SIZE 10 OBJECT_ID');
end;
/

@hi

-- Collect for owner
-- removes the histogram for object_owner
begin
dbms_stats.gather_table_stats('META','RK_DO', cascade=>true,
  method_opt=>'FOR ALL COLUMNS SIZE 1 FOR COLUMNS SIZE 10 OWNER');
end;
/

@hi

-- This one keeps the already exisiting ones
begin
dbms_stats.gather_table_stats('META','RK_DO', cascade=>true,
  method_opt=>'FOR COLUMNS SIZE 10 OBJECT_ID');
end;
/

-- WHAT COLUMNS NEED HISTOGRAM?
-- We check all the objects in a query plan

  create table meta.rk_20q_co_usage as
  select o.owner, o.object_name, c.column_name, u.*
from  (select distinct object# from v$sql_plan where sql_id = '20pqa4v4ts7sy') s,
     sys.col_usage$ u,
    dba_objects o,
    dba_tab_cols c
where 1=1
  and s.object# = u.obj#
  and s.object# = o.object_id
  and u.obj#=o.object_id
  and u.intcol# = c.column_id
  and o.owner  = c.owner
  and o.object_name = c.table_name;


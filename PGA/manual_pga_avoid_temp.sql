-- Observations





-- Generate the data
-- create data and temp
create tablespace pga_manual_test datafile '/oradata/UNI/pga_manual_test_01.dbf' size 1g autoextend on maxsize 2g;
alter database datafile '/oradata/UNI/pga_manual_test_01.dbf' autoextend on maxsize 2g;

create temporary tablespace pga_manual_test_temp tempfile '/oradata/UNI/pga_manual_test_temp_01.dbf' size 1g autoextend on maxsize 4g;


-- create user
create user pga identified by pga 
default tablespace pga_manual_test
temporary tablespace pga_manual_test_temp;
grant dba to pga;


-- as pga user
-- create data 
-- 7 1M
drop table small purge;
drop table big purge;

create table big as
with data as (
select 	rownum as id,
		cast(DBMS_RANDOM.string('a',1200) as varchar2(1200)) as v
from dual
connect by level<=100
)
select d1.* from data d1, data, data
where rownum<=1e&exp
;

SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR(null, null, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE'))
/


create table small as 
select b.*, 
       rownum as value
from big b
where id <= 20;


column tablespace_name format a10
column segment_name format a15
select segment_name, tablespace_name, bytes/1024/1024 mb, 
blocks, extents
from dba_segments
where owner = 'PGA';

----------------------- TEST

alter session set statistics_level = all;
set lines 280
set pages 500
set time on 
set timi on

select sum (s.value) sumvalue
from big b, small s
where b.id = s.id;


SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('78adcb85jbq1f', null, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE -OUTLINE'))
/



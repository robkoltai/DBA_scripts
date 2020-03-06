-- This is a demo of a situation what we encountered at a customer

------------------------------------------------
-- Setup
------------------------------------------------
-- User, tablespace, table, index
-- ENV: odmarac db

-- Tablespace
create tablespace latchtest datafile '+DATA' autoextend on maxsize 500m;

-- User
create user la 
identified by la
default tablespace latchtest;

grant dba to la;

-- Tables indexes, data, sequence
conn la/la
drop table big purge;
drop sequence big_cache_noorder;
create table big as
with data as (
select 	rownum as did,
        sysdate - rownum as d1,
		cast(DBMS_RANDOM.string('a',20) as varchar2(20)) as v1,
		cast(DBMS_RANDOM.string('a',20) as varchar2(20)) as v2,
		cast(DBMS_RANDOM.string('a',20) as varchar2(20)) as v3
from dual
connect by level<=100
)
select rownum as id, d1.* from data d1, data, data
where rownum<=1e6
;

-- create some indexes
create sequence big_cache_noorder cache 50 noorder;
create index big_id on big (id) reverse;
create index big_did on big (did);
create index big_v1 on big (v1);


--
drop table t1_normind_nocache_order 	purge;
drop table t2_normind_nocache_noorder 	purge;
drop table t3_normind_cache_order 		purge;
drop table t4_normind_cache_noorder 	purge;
drop table t5_revind_nocache_order	 	purge;
drop table t6_revind_cache_noorder	 	purge;

drop sequence seq_t1_nocache_order ;
drop sequence seq_t2_nocache_noorder ;
drop sequence seq_t3_cache_order ;
drop sequence seq_t4_cache_noorder ;
drop sequence seq_t5_nocache_order ;
drop sequence seq_t6_cache_noorder ;



create table t1_normind_nocache_order as select 0 as id, 	't1_normind_nocache_order' as name from dual;
create sequence seq_t1_nocache_order nocache order;
create index t1_id on t1_normind_nocache_order (id);

create table t2_normind_nocache_noorder as select 0 as id, 	't2_normind_nocache_noorder' as name from dual;
create sequence seq_t2_nocache_noorder nocache noorder;
create index t2_id on t2_normind_nocache_noorder (id);

create table t3_normind_cache_order as select 0 as id, 		't3_normind_cache_order' as name from dual;
create sequence seq_t3_cache_order cache 50 order;
create index t3_id on t3_normind_cache_order (id);

create table t4_normind_cache_noorder as select 0 as id, 	't4_normind_cache_noorder' as name from dual;
create sequence seq_t4_cache_noorder cache 50 noorder;
create index t4_id on t4_normind_cache_noorder (id);

-- REVERSE KEY INDEXES
create table t5_revind_nocache_order as select 0 as id, 	't5_revind_nocache_order' as name from dual;
create sequence seq_t5_nocache_order nocache order;
create index t5_id on t5_revind_nocache_order (id) reverse;

create table t6_revind_cache_noorder as select 0 as id, 	't6_revind_cache_noorder' as name from dual;
create sequence seq_t6_cache_noorder cache 50 noorder;
create index t6_id on t6_revind_cache_noorder (id) reverse;


-- hash index
create table t7_hash as 
select 	level as id
from dual
connect by level<=100
;

create index t7_hash_ind on t7_hash  (id) global partition by hash (id) (partition p1, partition p2, partition p3, partition p4);

alter session set statistics_level=all;
select /*+ index (h t7_hash_ind)*/ * 
from t7_hash h
where id >88;


--19c 12.2.0.3
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE +HINT_REPORT'))
/


SQL_ID  g8a1pktq92za1, child number 0
-------------------------------------
select /*+ index (h t7_hash_ind)*/ * from t7_hash h where id >88

Plan hash value: 3846518377

--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name        | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |             |      1 |        |       |     1 (100)|          |       |       |     12 |00:00:00.01 |       4 |
|   1 |  PARTITION HASH ALL|             |      1 |     12 |    36 |     1   (0)| 00:00:01 |     1 |     4 |     12 |00:00:00.01 |       4 |
|*  2 |   INDEX RANGE SCAN | T7_HASH_IND |      4 |     12 |    36 |     1   (0)| 00:00:01 |     1 |     4 |     12 |00:00:00.01 |       4 |
--------------------------------------------------------------------------------------------------------------------------------------------



-- BIG update with rollback

set timing on;
set time on;

-- big update
declare
  i number;
begin
  for i in 1..10 loop
	update big 
	set did=did+1,
	  d1=d1+1,
      v1='update it'
	where id <50000;
    rollback;
  end loop;
end;
/


set time on;
set timing on;
declare
  i number;
begin
  for i in 1..5000 loop
    
	insert into big values (big_cache_noorder.nextval,17, sysdate,'a','b','c');
	
	insert into t1_normind_nocache_order 	values (seq_t1_nocache_order.nextval,'Blalbalbal');
/*
	insert into t2_normind_nocache_noorder 	values (seq_t2_nocache_noorder.nextval,'Blalbalbal');
	insert into t3_normind_cache_order 		values (seq_t3_cache_order.nextval,'Blalbalbal');
	insert into t4_normind_cache_noorder 	values (seq_t4_cache_noorder.nextval,'Blalbalbal');
	insert into t5_revind_nocache_order 	values (seq_t5_nocache_order.nextval,'Blalbalbal');
*/
	insert into t6_revind_cache_noorder 	values (seq_t6_cache_noorder.nextval,'Blalbalbal');
	
	
  end loop;
  commit;
end;
/	





-- TEST 
-- NODE1
1 admin
exec dbms_workload_repository.create_snapshot;
3 insert

-- NODE2
1 update
3 insert


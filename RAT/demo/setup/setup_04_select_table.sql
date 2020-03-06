conn rat/rat

/*
desc select_t -- 10.000 records
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID                                                 NUMBER					-- 1..10000 Indexed
 DID                                                NUMBER					-- 1..100
 V1                                                 VARCHAR2(20)			-- Random

*/

drop table select_t purge;

create table select_t as
with data as (
select 	rownum as did,
		cast(DBMS_RANDOM.string('a',20) as varchar2(20)) as v1
from dual
connect by level<=100
)
select rownum as id, d1.* from data d1, data, data
where rownum<=1e5
;

create index ind_select_t_id on select_t(id);
exec dbms_stats.gather_table_stats('RAT','SELECT_T') ;





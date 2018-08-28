create table t1 as
with data as (
select  /*+ MATERIALIZE */ rownum as id,
  cast(DBMS_RANDOM.string('a',200) as varchar2(200)) as v
from dual
connect by level<=1000
)
select d1.* from data d1, data, data
where rownum<=1e&exp
;


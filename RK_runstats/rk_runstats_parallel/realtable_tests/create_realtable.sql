drop table RKTEST_RT_UNIT_PROPERTY purge;
Prompt Creating RKTEST_RT_UNIT_PROPERTY on RK_PERM_TAB tablespace
Prompt Table size is defined by two parameters exp and coeff
Prompt 5     1 -> 100m
Prompt 6     1 -> 1g
Prompt 7     1 -> 10g
Prompt 7   0.5 -> 5g
create table RKTEST_RT_UNIT_PROPERTY 
nologging parallel 16 tablespace RK_PERM_TAB
as
select * from eventus.RT_UNIT_PROPERTY 
where rownum<=1e&exp * 24 * &coeff
--where rownum<=1e5 * 24 -- 100m
--where rownum<=1e6 * 24 -- 1g
--where rownum<=1e7 * 24 -- 10g
;

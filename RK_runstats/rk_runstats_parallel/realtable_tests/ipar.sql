prompt dropping index RKTEST_PK_RT_UNIT_PROPERTY
drop index RKTEST_PK_RT_UNIT_PROPERTY;

prompt Creating index on rk_perm_ind tablespace

create index RKTEST_PK_RT_UNIT_PROPERTY
on RKTEST_RT_UNIT_PROPERTY (TICKET_ID, UNIT_NUMBER, PROPERTY_ID)
nologging parallel &1 
tablespace rk_perm_ind pctfree 28
;

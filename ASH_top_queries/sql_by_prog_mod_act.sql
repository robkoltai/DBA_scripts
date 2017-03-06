-- SQL BY program, module, action
set lines 1111
select count(1),
     program, module, action,
     --session_id,
     -- event,
     sql_id
     --, sql_opname,top_level_sql_id, sql_plan_hash_value
from v$active_session_history 
where sample_time > sysdate - 100/(60*24)
group by
      program, module, action,
     --session_id,
     -- event,
     sql_id
     --, sql_opname,top_level_sql_id, sql_plan_hash_value
order by count(1) desc;

  COUNT(1) PROGRAM                                          MODULE                                                           ACTION                                                           SQL_ID
---------- ------------------------------------------------ ---------------------------------------------------------------- ---------------------------------------------------------------- -------------
      3650 sqlplus@ucf-oracle.statlogics.local (TNS V1-V3)  SQL*Plus                                                                                                                          g0z91kndsq2tr
        29 oracle@ucf-oracle.statlogics.local (PSP0)
         8 oracle@ucf-oracle.statlogics.local (CKPT)
         6 sqlplus@ucf-oracle.statlogics.local (TNS V1-V3)  SQL*Plus                                                                                                                          4n5b8hb0m0jk3
         6 sqlplus@ucf-oracle.statlogics.local (TNS V1-V3)  SQL*Plus                                                                                                                          bs3dk9cr4u04p
         3 oracle@ucf-oracle.statlogics.local (MMON)                                                                                                                                          772s25v1y0x8k
         3 sqlplus@ucf-oracle.statlogics.local (TNS V1-V3)  sqlplus@ucf-oracle.statlogics.local (TNS V1-V3)                                                                                   572fbaj0fdw2b

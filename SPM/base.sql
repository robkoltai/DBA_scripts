set lines 300
set pages 100
column signature format 999999999999999999999
column sql format a22
column creator format a15
alter session set nls_timestamp_format='MON DD HH24:MI';
column LAST_EXECUTED format a18
column LAST_VERIFIED format a18
column created format a18


select signature, sql_handle, plan_name,
  substr(sql_text,1,40) sql, creator, origin,
  enabled, accepted, fixed,
  reproduced, autopurge, optimizer_cost, executions,
  created, last_executed, last_verified
from dba_sql_plan_baselines;


/*


           SIGNATURE SQL_HANDLE                     SQL                  CREATOR         ORIGIN         ENA ACC FIX REP AUT OPTIMIZER_COST EXECUTIONS CREATED            LAST_EXECUTED      LAST_VERIFIED
-------------------- ------------------------------ -------------------- --------------- -------------- --- --- --- --- --- -------------- ---------- ------------------ ------------------ ------------------
 6246024806109256341 SQL_56ae5677e26b9a95           SELECT  t.ticket_id, HAVASIZ         MANUAL-LOAD    YES YES NO  YES YES        6358675          1 OKT.   08 17:33
                                                     t.task_number, t.pr

 6246024806109256341 SQL_56ae5677e26b9a95           SELECT  t.ticket_id, HAVASIZ         MANUAL-LOAD    YES YES NO  YES YES              1          1 OKT.   08 17:33


*/
@ getTimeSqlmon.sql
col exec_start format a25
col process    format a10
col status     format a15
select
    -- sql_id
    sql_exec_id   
   ,to_char(sql_exec_start,'dd/mm/yyyy hh24:mi:ss') exec_start
   ,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') current_time  
   ,process_name process
   ,round((sysdate-sql_exec_start) * 60 * 24,2) "minutes"
   ,round(elapsed_time/1e6,3) "elaps(sec)"
   ,round(cpu_time/1e6,3) "cpu(sec)"
   ,sql_plan_hash_value   "plan hash value"
   ,status
from gv$sql_monitor
where
  sql_id = '&sql_id'
order by exec_start,action;

/* 
SQL> @GetTimeSQLMon2
Enter value for sql_id: 94dp7vscw26sf
 
SQL_EXEC_ID EXEC_START            PROCE    mm elaps(sec)   cpu(sec) SQL_PLAN_HASH_VALUE STATUS
----------- --------------------- ----- ----- ---------- ---------- ------------------- ------
   50331648 21/01/2020 13:50:26   p002  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p003  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p008  16.35      3.364       .478        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p000  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p00f  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p007  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p00d  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p005  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p004  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p00c  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p001  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p009  16.35    978.915    136.371        524852868 EXECUTING ---------->>>>>>
   50331648 21/01/2020 13:50:26   p00e  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p006  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   ora   16.35       .152      4.125        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p00b  16.35          0          0        524852868 EXECUTING
   50331648 21/01/2020 13:50:26   p00a  16.35          0          0        524852868 EXECUTIN
                                   
 17 rows selected.   
 
 */
set lines 150

select SQL_TEXT, PX_SERVERS_EXECUTIONS, EXECUTIONS,
      (PX_SERVERS_EXECUTIONS/(EXECUTIONS+0.0000001)) AS AVG_PQ_EXEC
from V$SQL 
where SQL_ID = '&sql_id';

/*
SQL_TEXT                                                           PX_SERVERS_EXECUTIONS EXECUTIONS AVG_PQ_EXEC
------------------------------------------------------------------ --------------------- ---------- -----------
SELECT NVL(TO_NUMBER(EXTRACT(XMLTYPE(:B2 ), :B1 )), 0) FROM DUAL                       0       5634           0

*/
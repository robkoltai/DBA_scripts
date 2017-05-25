col osuser format a11
col program format a25
col module format a25
set lines 1111
select --p.*, 
   p.spid,s.sid,s.serial#,s.username,s.status,s.last_call_et,
   --p.program,
   --p.terminal,--logon_time,
   module,s.osuser,
   sql_id, sql_exec_start,
   prev_sql_id,
    BLOCKING_SESSION_STATUS,                                              
    BLOCKING_INSTANCE     ,                                               
    BLOCKING_SESSION      ,                                               
    FINAL_BLOCKING_SESSION_STATUS,                                        
    FINAL_BLOCKING_INSTANCE      ,                                        
 FINAL_BLOCKING_SESSION   ,
 state, event, p1, p1text, p2, p2text, p3, p3text
from V$process p,V$session s
where s.paddr = p.addr 
  and s.sid=&sid;
/

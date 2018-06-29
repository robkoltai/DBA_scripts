col osuser format a11
col program format a25
col module format a25
set lines 1111
select --p.*, 
   p.spid,
   p.pid, 
   s.sid,s.serial#,s.username,s.status,s.last_call_et,
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
  and s.sid=&sid
;

-- Final blocking what does it do from ASH?


select * from (
select '1. blocked when queried' as bl_status, ash.* from v$active_session_history ash where session_id in (select sid from v$session  where event = 'enq: MS - contention')
  union all
select '2. blocker when queried' as bl_status, ash.* from v$active_session_history ash where session_id in (select blocking_session from v$session  where  event = 'enq: MS - contention')
  union all
select '3. final blocker when queried' as bl_status, ash.* from v$active_session_history ash where session_id in (select FINAL_BLOCKING_SESSION from v$session where  event = 'enq: MS - contention')
) 
where sample_time> sysdate-1
order by sample_time desc, bl_status;

-- Final blocking what does it do from DASH?

select * from (
select '1. blocked when queried' as bl_status, ash.* from dba_hist_active_sess_history ash where session_id in (select sid from v$session  where event = 'enq: MS - contention')
  union all
select '2. blocker when queried' as bl_status, ash.* from dba_hist_active_sess_history ash where session_id in (select blocking_session from v$session  where  event = 'enq: MS - contention')
  union all
select '3. final blocker when queried' as bl_status, ash.* from dba_hist_active_sess_history ash where session_id in (select FINAL_BLOCKING_SESSION from v$session where  event = 'enq: MS - contention')
) 
where sample_time> sysdate-1
order by sample_time desc, bl_status;


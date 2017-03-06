set lines 120
column event format a38
column program format a25
column time format a10
select to_char(sample_time,'HH24:MI:SS') as time, event, program, session_id
from v$active_session_history
where sample_time>sysdate-5/24/60
order by 1, event, program;
select session_id, session_serial#, sql_exec_id, 
       pga_allocated, temp_space_allocated, 
       ash.* 
from v$active_session_history ash
where sql_id = 'batqd2xzz7f30'
  and is_awr_sample= 'Y'
order by sample_id desc;

select * from v$sql_workarea
where sql_id = 'batqd2xzz7f30';

select * from v$sql_workarea_active
where sql_id = 'batqd2xzz7f30';

select * from DBA_SQL_PLAN_DIRECTIVES order by created desc;

select 1 from dual;
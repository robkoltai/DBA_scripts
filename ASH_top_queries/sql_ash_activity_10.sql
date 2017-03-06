-- for one sql
column object_name format a30
column event format a30
select 
        count(*),
        sql_id, 
        event,
        --current_obj#, 
        o.owner, o.object_name, o.object_type,
        blocking_session, 
        session_state
from v$active_session_history ash, dba_objects o
where o.object_id = ash.current_obj#
 AND       sql_id = '&sql_id'
group by        
        sql_id, 
        event,
        o.owner, o.object_name, o.object_type,
        --current_obj#,
        blocking_session, 
        session_state
order by 1 desc;

        
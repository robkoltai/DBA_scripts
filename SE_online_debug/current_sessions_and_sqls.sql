-- RELEVANT SESSIONS AND SQLS
-- This query shows the currently executing a previously executed SQLs joined with v$session

select 
case when ((ses.sql_id = sql.sql_id      and ses.sql_child_number= sql.child_number)) then 'CURR'
     when (ses.prev_sql_id = sql.sql_id and ses.prev_child_number= sql.child_number) THEN 'PREV'
end mikor,
to_char(sql_exec_start,'YYYYMMDD HH24:MI:SS') exec_start, ses.sid, sql.sql_id, sql.child_number, substr(sql.sql_text,1,80) t,
ses.event, p1,p2,p3, ses.row_wait_obj#,row_wait_file#, row_wait_block#,ses.username, ses.status, ses.osuser, ses.machine, ses.program, ses.module,  blocking_session,
sql.*, 'SESS JON' sj, ses.*
from 
v$sql sql,
v$session ses
where ((ses.sql_id = sql.sql_id      and ses.sql_child_number= sql.child_number) 
 or    (ses.prev_sql_id = sql.sql_id and ses.prev_child_number= sql.child_number))
and ses.type <> 'BACKGROUND'
and username <> 'DBSNMP'
and event <>'pipe get'
order by sql_exec_start desc;
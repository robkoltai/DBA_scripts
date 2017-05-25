-- cached sql from v$open_cursor
select c.user_name, c.sid, sql.sql_text
from v$open_cursor c, v$sql sql
where c.sql_id=sql.sql_id
and sql.sql_id='&sql'
order by sql_text
/

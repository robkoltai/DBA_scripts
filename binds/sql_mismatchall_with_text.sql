select c.sql_id, count(*) , nvl(sa.sql_text, '<SQL text not in v$sqlarea>')
from v$sql_shared_cursor c,
 v$sqlarea sa
where sa.sql_id (+) = c.sql_id
group by c.sql_id, nvl(sa.sql_text, '<SQL text not in v$sqlarea>')
having count(*) > 50
order by 2 asc
/

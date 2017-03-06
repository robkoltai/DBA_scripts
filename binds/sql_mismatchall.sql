select sql_id, count(*) 
from v$sql_shared_cursor
group by sql_id
having count(*) > 50
order by 2 asc
/

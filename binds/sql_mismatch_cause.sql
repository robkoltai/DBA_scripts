set lines 1111
select * from  v$sql_shared_cursor where sql_id = '&sql'
/


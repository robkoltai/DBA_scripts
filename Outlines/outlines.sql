set pagesize 999
set lines 155
column owner format a12
column category format a15
column name format a30
column sql_text format a70 trunc
column hints for 99999
break on owner
select category, ol_name name, 
  decode(bitand(flags, 1), 0, 'UNUSED', 1, 'USED') used, 
  decode(bitand(flags, 4), 0, 'ENABLED', 4, 'DISABLED') enabled,
hintcount hints,
sql_text
from outln.ol$
where 
category like nvl('&category',category)
and ol_name like nvl('&name',ol_name)
order by 1, 2, 4, 3
/

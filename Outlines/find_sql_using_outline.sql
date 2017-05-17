set lines 155
set verify off
set pagesize 999
col username format a13
col outline_category for a16
col prog format a22
col sql_text format a55 wrap
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col outline_name format a12
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

select sql_id, child_number, executions execs, 
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, outline_category,
o.name outline_name, plan_hash_value,
s.sql_text
-- from v$sql s, dbs_outlines o
from dba_outlines o left outer join v$sql s
on o.signature = outline_signature(s.sql_fulltext)
where upper(s.sql_text) like upper(nvl('&sql_text',s.sql_text))
-- and s.sql_text not like '%from v$sql where s.sql_text like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
and outline_category is not null
/

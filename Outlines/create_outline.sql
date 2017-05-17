-- The alter session is here to attempt to avoid the "ORA-03113: end-of-file on communication channel" 
-- error (per metalink) to workaround Bug 5454975 fixed 10.2.0.4
-- just in case use_stored_outlines hasn't already been set
alter session set use_stored_outlines=true; 

set serveroutput on
set pagesize 9999
set linesize 155
var hval number
accept sql_id -
       prompt 'Enter value for sql_id: ' 
accept child_number -
       prompt 'Enter value for child_number: ' 
accept o_name -
       prompt 'Enter value for outline_name: ' -
       default 'XOXOXOXO'

DECLARE
-- oname varchar2(30) := 'XOXOXOXO';
name2 varchar2(30);
name1 varchar2(30);
sql_string varchar2(300);
BEGIN

name2 := '&&o_name';
select hash_value into :hval
from v$sqlarea 
where sql_id like '&&sql_id';


  DBMS_OUTLN.create_outline(
    hash_value    => :hval, 
    child_number  => &&child_number);

   select 'alter outline '||name||' rename to '||'&&o_name', name into sql_string, name1
   from dba_outlines 
   where timestamp = (select max(timestamp) from dba_outlines);
   dbms_output.put_line(' ');

if name2 != 'XOXOXOXO' then 
   execute immediate sql_string;
   dbms_output.put_line('Outline '||upper(name2)||' created.');
else
   dbms_output.put_line('Outline '||name1||' created.');
end if;

END;
/
undef sql_id
undef child_number
undef o_name


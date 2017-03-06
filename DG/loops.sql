set serveroutput on;

create table t tablespace users as select object_id from dba_objects;
create table t2 tablespace users as select object_id from dba_objects where object_id <10;

undef i;

declare i number;
begin
 for i in 1..&loops loop
   update t set object_id = object_id + mod(i,3);
   dbms_output.put_line (i);
 end loop;
end;
/


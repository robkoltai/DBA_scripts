set serveroutput on;

create table t2 tablespace users as select object_id from dba_objects where object_id <10;

undef i;

declare i number;
begin
 for i in 1..&x10000_commit * 10000 loop
   update t2 set object_id = object_id + mod(i,3);
   commit; 
 end loop;
end;
/

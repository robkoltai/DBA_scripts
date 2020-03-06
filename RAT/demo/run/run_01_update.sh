#!/bin/bash

echo "  Running the update statement $RUN_COUNT times"

sqlplus ${CONN_STRING} <<__HERE >/dev/null
set timing on
set echo off 
set feedback off

declare 
  i_update number;
  stmt varchar2(2000);
  r number;
begin
  for i_update in 1..$RUN_COUNT loop
    -- There are ~70000 records in the table
	r:= ROUND(DBMS_RANDOM.VALUE(1,70000));
	
    stmt := 'UPDATE /*+ TEST_01_UPDATE */ update_t '||
	        'set text = substr(text,73,100) || substr(text,1,72) '||
			'where id = '|| i_update;
    execute immediate stmt;
    commit;
  end loop;
end;
/

commit;


__HERE


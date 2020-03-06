#!/bin/bash

echo "Running the INSERT $RUN_COUNT times"

sqlplus ${CONN_STRING} <<__HERE >/dev/null

-- We insert one record RUN_COUNT times

set time on;
set timing on;
declare
  i_insert number;
begin
  for i_insert in 1..$RUN_COUNT loop
	insert /*+ TEST_03_INSERT */ into insert_t 	values (insert_t_seq.nextval,'Blalbalbal');	
  end loop;
  commit;
end;
/	


commit;


__HERE




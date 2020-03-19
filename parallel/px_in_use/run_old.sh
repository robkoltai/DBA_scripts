#!/bin/bash

echo "Running the OLD SELECT $RUN_COUNT times"

sqlplus ${CONN_STRING} <<__HERE >/dev/null

-- 

set time on;
set timing on;
declare
  i_select number;
  v1 number;
begin
  for i_select in 1..$RUN_COUNT loop

    select /*+ BUSY_PX_OLD */ cOUNT(1) 
	into v1
	from v\$px_process where status = 'IN USE';


  end loop;
end;
/	

__HERE


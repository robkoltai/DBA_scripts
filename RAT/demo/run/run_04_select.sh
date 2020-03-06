#!/bin/bash

echo "Running the SELECT $RUN_COUNT times"

sqlplus ${CONN_STRING} <<__HERE >/dev/null

-- We select data thru FTS or INDEX RANGE SCAN

set time on;
set timing on;
declare
  i_select number;
  v1 select_t.v1%type;
  n_random number;
begin
  for i_select in 1..$RUN_COUNT loop

    SELECT ROUND(DBMS_RANDOM.VALUE(1,70000)) num 
    into n_random 
    FROM dual;

    select  /*+ TEST_04_SELECT */ max(v1) 
	into v1
    from select_t
    where id between n_random and n_random+31000;

  end loop;
end;
/	

__HERE




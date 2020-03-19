#!/bin/bash

echo "Running the SELECT $RUN_COUNT times with DOP ${DOP}"

sqlplus ${CONN_STRING} <<__HERE >/dev/null

-- 

set time on;
set timing on;
declare
  i_select number;
  v1 number;
begin
  for i_select in 1..$RUN_COUNT loop

    select /*+ parallel(t,$DOP) */ count(1)
	into v1
	/*+ TEST_PX  */
    from px t;

  end loop;
end;
/	

__HERE




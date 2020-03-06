#!/bin/bash

echo "  Running Delete $RUN_COUNT times"

sqlplus ${CONN_STRING} <<__HERE >/dev/null

-- Torlunk egy rekordot, ha van
-- Ha nincs akkor nem torlunk semmit

DECLARE
  i_delete NUMBER;
BEGIN
  FOR i_delete IN 1..$RUN_COUNT LOOP
    DELETE /*+ TEST_02_DELETE */ FROM kirk 
    WHERE LEV_PK = ROUND(DBMS_RANDOM.VALUE(1,1E5));
  END LOOP;
END;
/

commit;


__HERE


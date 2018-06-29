REM Flushes one cursor out of the shared pool. Works on 11g+
REM To create DBMS_SHARED_POOL, run the DBMSPOOL.SQL script.
REM The PRVTPOOL.PLB script is automatically executed after DBMSPOOL.SQL runs.
REM These scripts are not run by as part of standard database creation.
SPO flush_cursor_&&sql_id..txt;
PRO *** before flush ***
SELECT inst_id, loaded_versions, invalidations, address, hash_value
FROM gv$sqlarea WHERE sql_id = '&&sql_id.' ORDER BY 1;
SELECT inst_id, child_number, plan_hash_value, executions, is_shareable
FROM gv$sql WHERE sql_id = '&&sql_id.' ORDER BY 1, 2;
BEGIN
 FOR i IN (SELECT address, hash_value
 FROM gv$sqlarea WHERE sql_id = '&&sql_id.')
 LOOP
 SYS.DBMS_SHARED_POOL.PURGE(i.address||','||i.hash_value, 'C');
 END LOOP;
END;
/
PRO *** after flush ***
SELECT inst_id, loaded_versions, invalidations, address, hash_value
FROM gv$sqlarea WHERE sql_id = '&&sql_id.' ORDER BY 1;
SELECT inst_id, child_number, plan_hash_value, executions, is_shareable
FROM gv$sql WHERE sql_id = '&&sql_id.' ORDER BY 1, 2;
UNDEF sql_id;
SPO OFF;
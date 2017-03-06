--It turns out that the answer was staring right in my face: 
-- v$sql has a SQL_PLAN_BASELINE column, which along with EXACT_MATCHING_SIGNATURE 
-- is a key into dba_sql_plan_baselines view.

-- If v$sql.SQL_PLAN_BASELINE is empty, then the baseline is NOT used, 
-- otherwise the column contains baseline plan name being used at the moment.

column plan_name format a40
column exact_matching_signature format 99999999999999999999999
column signature format 99999999999999999999999

-- egy sql_id baseline-jai
SELECT b.sql_handle, b.plan_name, b.signature,
        s.child_number, s.plan_hash_value,
        s.executions, s.sql_id, s.exact_matching_signature, s.sql_plan_baseline
FROM v$sql s, dba_sql_plan_baselines b
WHERE s.exact_matching_signature = b.signature(+)
  AND s.sql_plan_baseline = b.plan_name(+)
  AND s.sql_id='&SQL_ID'
  ;


SQL_HANDLE                     PLAN_NAME                                             SIGNATURE CHILD_NUMBER PLAN_HASH_VALUE EXECUTIONS SQL_ID        EXACT_MATCHING_SIGNATURE SQL_PLAN_BASELINE
------------------------------ ---------------------------------------- ---------------------- ------------ --------------- ---------- ------------- ------------------------ ------------------------------
                                                                                                          0      2024149275          1 7f6tkgdzhdc1n      6689763777047276509
                                                                                                          1      2529555654          1 7f6tkgdzhdc1n      6689763777047276509
                                                                                                          2      2024149275          1 7f6tkgdzhdc1n      6689763777047276509
                                                                                                          3      4048318059          1 7f6tkgdzhdc1n      6689763777047276509
SQL_5cd6d0b61a2dabdd           SQL_PLAN_5tpqhqsd2vayx7c0cb143              6689763777047276509            4      2529555654         11 7f6tkgdzhdc1n      6689763777047276509 SQL_PLAN_5tpqhqsd2vayx7c0cb143




-- Get index statistics for a table_name pattern

set lines 180
set pages 100

column table_name format a25
column index_name format a25
column index_type format a25
select table_name, index_name, index_type, blevel, 
       leaf_blocks, distinct_keys, clustering_factor , last_analyzed
from user_indexes 
where table_name like upper('%&table_name_pattern%')
order by table_name, index_type, index_name
;


/*

TABLE_NAME                INDEX_NAME                INDEX_TYPE                      BLEVEL LEAF_BLOCKS DISTINCT_KEYS CLUSTERING_FACTOR
------------------------- ------------------------- --------------------------- ---------- ----------- ------------- -----------------
BUILD_FAST                I_BUILD_FAST              NORMAL                               2       15023        961487            961431
FBI_TEST_TAB              FBI_2SALARY_I             FUNCTION-BASED NORMAL                1         163         73477               713
FBI_TEST_TAB              FBI_UPPER_GIVEN2          FUNCTION-BASED NORMAL                2         469         60470             32784
FBI_TEST_TAB              FBI_UPPER_GIVEN           NORMAL                               2         469         60470             32760
FEW_INTERESTING_RECORDS   I_FIR_FBI                 FUNCTION-BASED NORMAL                0           0             0                 0
FEW_INTERESTING_RECORDS   I_FIR_BTREE               NORMAL                               2         614             3              1502
INDEX_EFF                 I_INDEX_EFF               NORMAL                               1           3          1000              1000
IOT_HEAP                  IOT_HEAP_PK               NORMAL                               1         362        100000             99825


*/

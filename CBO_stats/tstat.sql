-- table stats and 
-- column stats

set lines 180
set pages 100
column table_name format a25
column column_name format a20
column low_value format a20
column high_value format a20
column data_type format a15


select table_name, num_rows, blocks, avg_row_len, last_analyzed
from user_tables
where table_name like upper('%&&table_name_pattern%')
order by table_name;


select table_name, column_name, data_type, num_distinct, avg_col_len, 
  --low_value, high_value, 
  density, num_nulls, num_buckets, hidden_column, virtual_column, last_analyzed, histogram
from user_tab_cols 
where table_name like upper('%&&table_name_pattern%')
order by table_name, column_id;


undef table_name_pattern

/*

TABLE_NAME             NUM_ROWS     BLOCKS AVG_ROW_LEN LAST_ANAL
-------------------- ---------- ---------- ----------- ---------
FBI_TEST_TAB              73478        634          61 17-MAY-19


TABLE_NAME           COLUMN_NAME          DATA_TYPE            NUM_DISTINCT AVG_COL_LEN    DENSITY  NUM_NULLS NUM_BUCKETS HID VIR LAST_ANAL
-------------------- -------------------- -------------------- ------------ ----------- ---------- ---------- ----------- --- --- ---------
FBI_TEST_TAB         FAMILY_NAME          VARCHAR2                       27           5 .037037037          0           1 NO  NO  17-MAY-19
FBI_TEST_TAB         GIVEN_NAME           VARCHAR2                    60804          35 .000016446          0           1 NO  NO  17-MAY-19
FBI_TEST_TAB         SALARY               NUMBER                      73477           5  .00001361          1           1 NO  NO  17-MAY-19
FBI_TEST_TAB         EYE_COLOR_CODE       NUMBER                         23           4 .043478261          1           1 NO  NO  17-MAY-19
FBI_TEST_TAB         BIRTH_DATE           DATE                         1761           8 .000567859          0           1 NO  NO  17-MAY-19
FBI_TEST_TAB         SYS_NC00006$         NUMBER                      73477           5    .000014          1          75 YES YES 17-MAY-19
FBI_TEST_TAB         SYS_NC00007$         VARCHAR2                                                                        YES YES


*/
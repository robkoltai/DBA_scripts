/*

Disk Group            Sector   Block   Allocation
Name                    Size    Size    Unit Size State       Type   Total Size (MB) Used Size (MB) Pct. Used
-------------------- ------- ------- ------------ ----------- ------ --------------- -------------- ---------
ASM_BASE                 512   4,096    4,194,304 MOUNTED     EXTERN          51,200            100       .20
PDW2_TOR_ACFS_DG         512   4,096    4,194,304 MOUNTED     EXTERN       2,560,000      2,559,956    100.00
PDW_TOR_DATA_DG          512   4,096    4,194,304 CONNECTED   EXTERN      32,768,000     30,074,340     91.78
PDW_TOR_FRA_DG           512   4,096    4,194,304 CONNECTED   EXTERN       3,072,000        168,044      5.47
PDW_TOR_REDO_DG          512   4,096    4,194,304 CONNECTED   EXTERN          40,960         10,408     25.41
PDW_TOR_TMP_DG           512   4,096    4,194,304 CONNECTED   EXTERN       1,536,000      1,283,760     83.58
PDW_TOR_USERS_DG         512   4,096    4,194,304 CONNECTED   EXTERN         512,000        511,996    100.00
                                                                     --------------- --------------
Grand Total:                                                              40,540,160     34,608,604

7 rows selected.

*/


SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off
COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'



break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb used_mb on report


SELECT
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
FROM
    v$asm_diskgroup
ORDER BY
    name
/
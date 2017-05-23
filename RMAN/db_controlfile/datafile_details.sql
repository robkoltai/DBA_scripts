set lines 220
set pages 1000
col backup_type for a4 heading "TYPE"
col controlfile_included heading "CF?"
col incremental_level heading "INCR LVL"
col pieces for 999 heading "PCS"
col elapsed_seconds heading "ELAPSED|SECONDS"
col device_type for a10 trunc heading "DEVICE|TYPE"
col compressed for a4 heading "ZIP?"
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col input_file_scan_only for a4 heading "SCAN|ONLY"

column INCREMENTAL_CHANGE# format 9999999999999
column CHECKPOINT_CHANGE# format 9999999999999


select btype, SESSION_KEY, SESSION_recid, SESSION_stamp,
FILE#, INCREMENTAL_LEVEL, INCREMENTAL_change#, CHECKPOINT_CHANGE#, tsname
from V$BACKUP_DATAFILE_DETAILS dfd
where file# in (1,2,3)
order by CHECKPOINT_CHANGE#, file#;


/*

BTYPE     SESSION_KEY SESSION_RECID SESSION_STAMP      FILE#   INCR LVL INCREMENTAL_CHANGE# CHECKPOINT_CHANGE# TSNAME
--------- ----------- ------------- ------------- ---------- ---------- ------------------- ------------------ ------------------------------
BACKUPSET      179877        179877     941904001          3          0                   0        43386955973 UNDOTBS
BACKUPSET      179987        179987     942008402          3          1         43388745015        43388745968 UNDOTBS
BACKUPSET      179987        179987     942008402          2          1         43388745399        43388747012 SYSAUX
BACKUPSET      179987        179987     942008402          1          1         43388745579        43388747021 SYSTEM
BACKUPSET      179877        179877     941904001          2          0                   0        43388795103 SYSAUX
BACKUPSET      179877        179877     941904001          1          0                   0        43388795706 SYSTEM
BACKUPSET      180073        180073     942094802          3          1         43389069888        43389070831 UNDOTBS
BACKUPSET      180073        180073     942094802          2          1         43389070297        43389071523 SYSAUX
BACKUPSET      180073        180073     942094802          1          1         43389070392        43389071547 SYSTEM
BACKUPSET      180183        180183     942181202          3          1         43401862360        43401877551 UNDOTBS
BACKUPSET      180183        180183     942181202          2          1         43401875442        43401882639 SYSAUX


*/
@ad
set lines 200
column destination format a27
column id format 999
column target format a7
column seq# format 9999
column proc format a4
column arch format a5
column status format a7
column dest_name format a19
column error format a20
column recovery_mode format a13
col DB_UNIQUE_NAME format a14
col destination format a12
select
 DEST_ID id,  --DEST_NAME                  ,                                         
 STATUS, --TYPE,
 DATABASE_MODE,RECOVERY_MODE,                                         
 PROTECTION_MODE,                                          
 DESTINATION, 
 --STANDBY_LOGFILE_COUNT, STANDBY_LOGFILE_ACTIVE,  
 --ARCHIVED_THREAD#           ,                                         
 ARCHIVED_SEQ#,                                         
 --APPLIED_THREAD#            ,                                         
 APPLIED_SEQ#,  ERROR, SRL, DB_UNIQUE_NAME, SYNCHRONIZATION_STATUS, SYNCHRONIZED,
 GAP_STATUS   --, --CON_ID                                                                  
from v$archive_dest_status where dest_id<3;

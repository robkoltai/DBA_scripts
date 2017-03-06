set lines 150
alter session set nls_date_format='MON-DD HH24:MI:SS';
column recid format 999
column dest_id format 99
column name format a50
column seq# format 9999
column first_CHANGE# heading "FIRST|CHANGE#" format 9999999999
column next_CHANGE# heading "NEXT|CHANGE#" format 9999999999


select recid, dest_id, SEQUENCE# as seq#, FIRST_TIME,CREATOR, REGISTRAR,
  STANDBY_DEST, ARCHIVED, APPLIED, DELETED, STATUS, FAL,
  end_of_redo eor, end_of_redo_type eor_type, first_change#, next_change#
from v$archived_log
where first_time>sysdate-2
order by 3,2;

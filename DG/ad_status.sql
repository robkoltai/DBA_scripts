set lines 120
column destination format a25
column id format 999
column target format a7
column seq# format 9999
column proc format a4
column recovery_mode format a13
column sync_stat format a10
column prot_mode format a20
column db_mode format a8
column gap_stat format a8
select dest_id as id, status, database_mode as db_mode, recovery_mode, protection_mode as prot_mode, srl,
  SYNCHRONIZATION_STATUS as sync_stat, 
  SYNCHRONIZED as sync_ed,
  gap_status as gap_stat
from v$archive_dest_status where dest_id=2;


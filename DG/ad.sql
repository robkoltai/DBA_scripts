set lines 120
column destination format a27
column id format 999
column target format a7
column seq# format 9999
column proc format a4
column arch format a5
column status format a7
select dest_id as id, status , target, archiver as arch, destination, log_sequence as seq#, process as proc, 
register, transmit_mode, 
-- AFFIRM: redo is not acknowledged until it has been written to the standby redo log. 
-- NOAFFIRM: received redo is acknowledged without waiting for being written to the standby redo log.
affirm,
--valid_type, valid_role, db_unique_name, 
applied_scn
from v$archive_dest where dest_id<3;

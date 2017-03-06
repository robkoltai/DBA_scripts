column member format a45
column group# format 9999
column dbid format a12
column status format a14

select group#, status, type, member, is_recovery_dest_file as recdest
from v$logfile 
where type='STANDBY';

column first_CHANGE# heading "FIRST|CHANGE#" format 9999999999
column next_CHANGE# heading "NEXT|CHANGE#" format 9999999999
column last_CHANGE# heading "LAST|CHANGE#" format 9999999999


select group#, dbid, sequence# as seq#, bytes, used, archived, status,
  first_change#, next_change#, last_change#
from v$standby_log;


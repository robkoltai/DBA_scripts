set lines 120
column pid format 9999999999
column client_pid format a8
column process format a8
column client_process format a8
column group# format a6
column status format a15

select process, pid, status, client_process, client_pid, group#, sequence# as seq#, block#, blocks
from v$managed_standby;

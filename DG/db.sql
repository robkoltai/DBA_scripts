set lines 200
column name format a6
column open_mode format a12
column standby_became_primary_scn heading "STANDBY BECAME|PRIMARY SCN"
column switchover_status heading "SWITCHOVER|STATUS" FORMAT A12

select name, i.instance_name, open_mode, database_role,  switchover_status, flashback_on,
  protection_mode, protection_level,
  current_scn, standby_became_primary_scn
from v$database, v$instance i;



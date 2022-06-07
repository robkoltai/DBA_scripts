set lines 180
column name format a6
column open_mode format a12
column standby_became_primary_scn heading "STANDBY BECAME|PRIMARY SCN"
column switchover_status heading "SWITCHOVER|STATUS" FORMAT A12
column flashb_on format a9
column force_log format a9

select name, open_mode, database_role,  switchover_status, 
  protection_mode, protection_level,
  force_logging force_log, flashback_on flashb_on,
  DATAGUARD_BROKER broker, GUARD_STATUS brok_stat,
  current_scn, standby_became_primary_scn
from v$database;



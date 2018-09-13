DG_wrong_config,DG_not_submitted_archivelog_cnt,DG_not_applied_archivelog_cnt,DG_apply_delay


DG_wrong_config.Query=select  'Incorrect DG configuration: ' || \
  (select 'standby_file_management=' || value          || '; ' as retval_1 from v$parameter  where name='standby_file_management' and value='MANUAL'  ) || \
  (select 'flashback_database='      || flashback_on   || '; ' as retval_2 from v$database   where flashback_on='NO' ) \
  as retval_all \
from dual \
where (select count(1) from v$parameter  where name='standby_file_management' and value='MANUAL') =1 OR \
      (select count(1) from v$database   where flashback_on='NO' ) =1
DG_wrong_config.NoDataFound=none

DG_not_submitted_archivelog_cnt.Query=select (select max(SEQUENCE#) from v$managed_standby where process='ARCH') - (select SEQUENCE# from v$managed_standby where process='LNS') +1 as not_submitted_archivelog_cnt from dual
DG_not_submitted_archivelog_cnt.NoDataFound=none

DG_not_applied_archivelog_cnt.Query=select current_seq-last_applied_seq not_applied_archivelog_cnt \
from ( \
  select  \
        max(SEQUENCE#) last_applied_seq,  \
        max((select sequence# from v$log where status='CURRENT')) as current_seq, \
        max(next_change#) last_applied_change,  \
        scn_to_timestamp(max(next_change#)) last_applied_ts,  \
        systimestamp - scn_to_timestamp(max(next_change#))  as applied_delay \
  from v$archived_log \
  where dest_id= 2 and standby_dest='YES' and applied='YES')
DG_not_applied_archivelog_cnt.NoDataFound=none

DG_apply_delay.Query=select applied_delay \
from ( \
  select \
        max(SEQUENCE#) last_applied_seq,  \
        max((select sequence# from v$log where status='CURRENT')) as current_seq, \
        max(next_change#) last_applied_change,  \
        scn_to_timestamp(max(next_change#)) last_applied_ts,  \
        systimestamp - scn_to_timestamp(max(next_change#))  as applied_delay \
  from v$archived_log \
  where dest_id= 2 and standby_dest='YES' and applied='YES') \
where applied_delay> INTERVAL '6:00' HOUR TO MINUTE
DG_apply_delay.NoDataFound=none

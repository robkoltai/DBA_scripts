select space_used_delta /power(1024,3) used_gb_delta, space_allocated_delta  /power(1024,3) allocated_db_delta, snap.snap_id, snap.begin_interval_time, seg.* 
from dba_hist_seg_stat seg, dba_hist_snapshot snap
where 
seg.snap_id = snap.snap_id and
      to_date('2018.11.23 14:00','YYYY.MM.DD hh24:MI')<snap.begin_interval_time and 
      to_date('2018.11.23 17:00','YYYY.MM.DD hh24:MI')>snap.begin_interval_time and 
      ts#=28
and 1=1
--obj# in (
--select object_id from dba_objects 
--where object_name in ('SYS_LOB0000239677C00005$$','SYS_LOB0000045287C00004$$','SYS_LOB0000047947C00002$$','SYS_LOB0000045336C00001$$','LOGMNR_CONTENTS','ACQ_APP_PAYMENT')
--)
--order by 1, obj#
order by 1 desc
--)
;
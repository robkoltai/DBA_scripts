select 
  snap.snap_id, snap_time, --buffer_gets_th, disk_reads_th, seg_log_reads_th, seg_phy_reads_th,
  segobj.owner, segobj.object_name, segobj.object_type,
  sstat.logical_reads,sstat.physical_reads,sstat.direct_physical_reads
from 
 perfstat.STATS$SEG_STAT sstat,
 perfstat.STATS$SEG_STAT_OBJ segobj,
 STATS$SNAPSHOT snap
where
 snap.snap_id = sstat.snap_id and
 sstat.obj#=segobj.obj# and
 logical_reads>10000000
order by 1 desc;


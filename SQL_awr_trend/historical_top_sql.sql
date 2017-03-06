set lines 1111
set pages 25
column BEGIN_INTERVAL_TIME format a25 
select 	ss.begin_interval_time, h.sql_id, h.snap_id, 
	DISK_READS_TOTAL, DISK_READS_DELTA, IOWAIT_DELTA, rows_processed_delta, buffer_gets_delta
from dba_hist_sqlstat h, dba_hist_snapshot ss
where ss.snap_id = h.snap_id and 
	sql_id like  '%' and
	ss.begin_interval_time > sysdate-2
order by disk_reads_delta asc;

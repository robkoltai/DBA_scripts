set lines 160
col begin_interval_time format a30
col event_name format a30
col instance_number format 99 head "Inst"
break on begin_interval_time
SELECT snaps.begin_interval_time,
snaps.instance_number,
hist.event_name,
hist.wait_time_milli,
hist.wait_count
FROM dba_hist_event_histogram hist, DBA_HIST_SNAPSHOT snaps
WHERE snaps.snap_id = hist.snap_id
AND snaps.instance_number = hist.instance_number
AND snaps.begin_interval_time > sysdate-1 -- modify to specify constrained time window
AND hist.event_name = lower('&event_name')
ORDER BY snaps.snap_id ,
instance_number,
wait_time_milli
/

BEGIN_INTERVAL_TIME Inst EVENT_NAME WAIT_TIME_MILLI WAIT_COUNT
------------------------------ ---- -------------------- --------------- ----------
01-NOV-12 05.00.15.638 PM 1 gc cr block 2-way 1 110970
1 gc cr block 2-way 2 3620790
1 gc cr block 2-way 4 1708432
1 gc cr block 2-way 8 15685
1 gc cr block 2-way 16 340
1 gc cr block 2-way 32 26
1 gc cr block 2-way 64 8
1 gc cr block 2-way 128 1
1 gc cr block 2-way 256 1
1 gc cr block 2-way 2048 1
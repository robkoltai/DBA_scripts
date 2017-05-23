set lines 220
set pages 1000
col cf for 9,999
col df for 9,999
col elapsed_seconds heading "ELAPSED|SECONDS"
col i0 for 9,999
col i1 for 9,999
col l for 9,999
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col session_recid for 999999 heading "SESSION|RECID"
col session_stamp for 99999999999 heading "SESSION|STAMP"
col status for a10 trunc
col time_taken_display for a10 heading "TIME|TAKEN"
col output_instance for 9999 heading "OUT|INST"
select
  j.session_recid, j.session_stamp,
  to_char(j.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(j.end_time, 'yyyy-mm-dd hh24:mi:ss') end_time,
  (j.output_bytes/1024/1024) output_mbytes, j.status, j.input_type,
  decode(to_char(j.start_time, 'd'), 1, 'Sunday', 2, 'Monday',
                                     3, 'Tuesday', 4, 'Wednesday',
                                     5, 'Thursday', 6, 'Friday',
                                     7, 'Saturday') dow,
  j.elapsed_seconds, j.time_taken_display,
  x.cf, x.df, x.i0, x.i1, x.l,
  ro.inst_id output_instance
from V$RMAN_BACKUP_JOB_DETAILS j
  left outer join (select
                     d.session_recid, d.session_stamp,
                     sum(case when d.controlfile_included = 'YES' then d.pieces else 0 end) CF,
                     sum(case when d.controlfile_included = 'NO'
                               and d.backup_type||d.incremental_level = 'D' then d.pieces else 0 end) DF,
                     sum(case when d.backup_type||d.incremental_level = 'D0' then d.pieces else 0 end) I0,
                     sum(case when d.backup_type||d.incremental_level = 'I1' then d.pieces else 0 end) I1,
                     sum(case when d.backup_type = 'L' then d.pieces else 0 end) L
                   from
                     V$BACKUP_SET_DETAILS d
                     join V$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
                   where s.input_file_scan_only = 'NO'
                   group by d.session_recid, d.session_stamp) x
    on x.session_recid = j.session_recid and x.session_stamp = j.session_stamp
  left outer join (select o.session_recid, o.session_stamp, min(inst_id) inst_id
                   from GV$RMAN_OUTPUT o
                   group by o.session_recid, o.session_stamp)
    ro on ro.session_recid = j.session_recid and ro.session_stamp = j.session_stamp
where j.start_time > trunc(sysdate)-&NUMBER_OF_DAYS
order by j.start_time;

/*



SESSION      SESSION                                             OUTPUT                                       ELAPSED TIME                                            OUT
  RECID        STAMP START_TIME          END_TIME                MBYTES STATUS     INPUT_TYPE    DOW          SECONDS TAKEN          CF     DF     I0     I1      L  INST
------- ------------ ------------------- ------------------- ---------- ---------- ------------- --------- ---------- ---------- ------ ------ ------ ------ ------ -----
 182534    943747202 2017-05-12 00:00:18 2017-05-12 00:01:08        377 COMPLETED  ARCHIVELOG    Thursday          50 00:00:50        1      0      0      0      1
 182540    943750802 2017-05-12 01:00:24 2017-05-12 01:01:16        370 COMPLETED  ARCHIVELOG    Thursday          52 00:00:52        1      0      0      0      1
 182546    943754402 2017-05-12 02:00:25 2017-05-12 02:01:24        360 COMPLETED  ARCHIVELOG    Thursday          59 00:00:59        1      0      0      0      1
 182552    943758002 2017-05-12 03:00:29 2017-05-12 03:01:26        362 COMPLETED  ARCHIVELOG    Thursday          57 00:00:57        1      0      0      0      1
 182558    943761602 2017-05-12 04:00:31 2017-05-12 04:01:28        360 COMPLETED  ARCHIVELOG    Thursday          57 00:00:57        1      0      0      0      1
 182564    943765202 2017-05-12 05:00:30 2017-05-12 05:01:38        422 COMPLETED  ARCHIVELOG    Thursday          68 00:01:08        1      0      0      0      1
 182570    943768802 2017-05-12 06:00:25 2017-05-12 06:01:31        360 COMPLETED  ARCHIVELOG    Thursday          66 00:01:06        1      0      0      0      1
 182576    943772402 2017-05-12 07:01:00 2017-05-12 07:02:09        379 COMPLETED  ARCHIVELOG    Thursday          69 00:01:09        1      0      0      0      1
 182582    943776002 2017-05-12 08:00:24 2017-05-12 08:01:32        436 COMPLETED  ARCHIVELOG    Thursday          68 00:01:08        1      0      0      0      1
 182588    943779602 2017-05-12 09:00:30 2017-05-12 09:02:02        654 COMPLETED  ARCHIVELOG    Thursday          92 00:01:32        1      0      0      0      1
 182594    943783202 2017-05-12 10:00:29 2017-05-12 10:03:16      1,857 COMPLETED  ARCHIVELOG    Thursday         167 00:02:47        1      0      0      0      1
 182600    943786802 2017-05-12 11:00:29 2017-05-12 11:09:29      7,165 COMPLETED  ARCHIVELOG    Thursday         540 00:09:00        1      0      0      0      1


*/
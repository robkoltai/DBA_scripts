set lines 220
set pages 1000
col backup_type for a4 heading "TYPE"
col controlfile_included heading "CF?"
col incremental_level heading "INCR LVL"
col pieces for 999 heading "PCS"
col elapsed_seconds heading "ELAPSED|SECONDS"
col device_type for a10 trunc heading "DEVICE|TYPE"
col compressed for a4 heading "ZIP?"
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col input_file_scan_only for a4 heading "SCAN|ONLY"

select
  d.session_recid, d.session_stamp, 
  d.bs_key, d.backup_type, d.controlfile_included, d.incremental_level, d.pieces,
  to_char(d.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(d.completion_time, 'yyyy-mm-dd hh24:mi:ss') completion_time,
  d.elapsed_seconds, d.device_type, d.compressed, (d.output_bytes/1024/1024) output_mbytes, s.input_file_scan_only
from V$BACKUP_SET_DETAILS d
  join V$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
where d.incremental_level=&level
--  session_recid = &SESSION_RECID
--  and session_stamp = &SESSION_STAMP
order by d.start_time;


/*
Enter value for level: 0
old   9: where d.incremental_level=&level
new   9: where d.incremental_level=0
Enter value for session_recid:
old  10: --  session_recid = &SESSION_RECID
new  10: --  session_recid =
Enter value for session_stamp:
old  11: --  and session_stamp = &SESSION_STAMP
new  11: --  and session_stamp =

                                                                                                           ELAPSED DEVICE              OUTPUT SCAN
SESSION_RECID SESSION_STAMP     BS_KEY TYPE CF?   INCR LVL  PCS START_TIME          COMPLETION_TIME        SECONDS TYPE       ZIP?     MBYTES ONLY
------------- ------------- ---------- ---- --- ---------- ---- ------------------- ------------------- ---------- ---------- ---- ---------- ----
       179877     941904001     304574 D    NO           0    1 2017-04-22 06:46:38 2017-04-22 07:52:48       3970 SBT_TAPE   NO       32,492 NO
       179877     941904001     304575 D    NO           0    1 2017-04-22 06:46:38 2017-04-22 07:58:38       4320 SBT_TAPE   NO       32,466 NO
       179877     941904001     304576 D    NO           0    1 2017-04-22 07:52:54 2017-04-22 08:23:35       1841 SBT_TAPE   NO       32,767 NO
       179877     941904001     304577 D    NO           0    1 2017-04-22 07:58:39 2017-04-22 08:25:12       1593 SBT_TAPE   NO       32,759 NO
       179877     941904001     304578 D    NO           0    1 2017-04-22 08:23:44 2017-04-22 08:36:45        781 SBT_TAPE   NO       32,698 NO
       179877     941904001     304579 D    NO           0    1 2017-04-22 08:25:19 2017-04-22 08:39:05        826 SBT_TAPE   NO       32,744 NO
       179877     941904001     304580 D    NO           0    1 2017-04-22 08:36:54 2017-04-22 08:52:40        946 SBT_TAPE   NO       32,755 NO
       179877     941904001     304581 D    NO           0    1 2017-04-22 08:39:10 2017-04-22 08:55:59       1009 SBT_TAPE   NO       32,756 NO
       179877     941904001     304587 D    NO           0    1 2017-04-22 08:52:45 2017-04-22 09:07:36        891 SBT_TAPE   NO       32,721 NO
       179877     941904001     304588 D    NO           0    1 2017-04-22 08:56:00 2017-04-22 09:12:30        990 SBT_TAPE   NO       32,516 NO
       179877     941904001     304589 D    NO           0    1 2017-04-22 09:07:45 2017-04-22 09:22:51        906 SBT_TAPE   NO       32,332 NO
       179877     941904001     304590 D    NO           0    1 2017-04-22 09:12:40 2017-04-22 09:28:48        968 SBT_TAPE   NO       32,397 NO


*/
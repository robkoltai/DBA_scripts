-- ON THE primary or the standby
select * from (
SELECT 'Last Applied: ' Logs,
TO_CHAR(next_time,'YYYYMMDD HH24:MI:SS') TIME,thread#,sequence#
FROM v$archived_log
WHERE sequence# =
(SELECT MAX(sequence#) FROM v$archived_log WHERE applied='YES'
)
UNION
SELECT 'Last: ' Logs,
TO_CHAR(next_time,'YYYYMMDD HH24:MI:SS') TIME,thread#,sequence#
FROM v$archived_log
WHERE sequence# =
(SELECT MAX(sequence#) FROM v$archived_log )
union
SELECT 'Last Archived: ' Logs,
TO_CHAR(next_time,'YYYYMMDD HH24:MI:SS') TIME,thread#,sequence#
FROM v$archived_log
WHERE sequence# =
(SELECT MAX(sequence#) FROM v$archived_log WHERE archived='YES'
)
union 
select 'Current Time, LOG SEQUENCE: ',
TO_CHAR(sysdate,'YYYYMMDD HH24:MI:SS') TIME, (select thread# from v$log where status='CURRENT'),  (select sequence# from v$log where status='CURRENT')
from dual
)
order by 2;

/*
LOGS                         TIME                 THREAD#  SEQUENCE#
---------------------------- ----------------- ---------- ----------
Last Applied:                20170523 15:00:08          1      17549
Last:                        20170523 15:01:29          1      17550
Last Archived:               20170523 15:01:29          1      17550
Current Time, LOG SEQUENCE:  20170523 15:01:29          1      17551

*/
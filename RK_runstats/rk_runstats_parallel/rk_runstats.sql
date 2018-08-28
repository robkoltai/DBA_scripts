insert into rk_runstat_events (
select
     &1,
     NVL(s.username, '(oracle)') ,
     s.sid,
     s.serial#,
     'TEST DURATION',
     1,
     0,
     to_number((SYSDATE - TO_DATE('06-08-2018 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60 * 1000000),
     to_number(to_char(systimestamp,'FF6') +
          (SYSDATE - TO_DATE('06-08-2018 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60 * 1000000)
from v$session s
where s.sid = (select distinct sid from v$mystat));

insert into rk_runstat_events (
select
       &1 as snapid,
       NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited,
       --se.average_wait,
       --se.max_wait,
       se.time_waited_micro
FROM   v$session_event se,
       v$session s
WHERE  s.sid = se.sid
AND    s.sid in ((select distinct sid from v$mystat) 
                    union
                 (select sid from v$px_session where qcsid = (select distinct sid from v$mystat)))
);



insert into rk_runstats (
select 
  &1 as snapid, 
  b.sid, 
  name, 
  value 
from v$statname a, v$sesstat b 
where a.statistic# = b.statistic# 
and 1=1
and b.sid in ((select distinct sid from v$mystat)
                    union
                 (select sid from v$px_session where qcsid = (select distinct sid from v$mystat)))
);

commit;

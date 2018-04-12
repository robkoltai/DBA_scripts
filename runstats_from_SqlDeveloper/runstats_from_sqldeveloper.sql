
-- SESSION STATISTICS
drop table mystat_Before purge;
create table mystat_before as
SELECT NAM.NAME, STAT.*
FROM V$SESSTAT STAT,
V$STATNAME NAM
WHERE NAM.STATISTIC#= STAT.STATISTIC# AND SID=459
AND LOWER(NAME) LIKE '%%'
order by 1;
;

select * from mystat_before;

with after_stat as (SELECT NAM.NAME, STAT.*
FROM V$SESSTAT STAT,
V$STATNAME NAM
WHERE NAM.STATISTIC#= STAT.STATISTIC# AND SID=459
AND LOWER(NAME) LIKE '%%'
order by 1)
select after_stat.name, after_stat.value-mystat_before.value
from mystat_before, after_stat
where mystat_before.statistic#=after_stat.statistic#
 and after_stat.value-mystat_before.value <> 0
order by 1;


-- WAIT EVENTS
drop table myevent_Before purge;
create table myevent_Before as
SELECT STAT.*
FROM V$session_event STAT
where SID=459
;


select * from myevent_Before;

with myevent_after as (select STAT.*
FROM V$session_event STAT
WHERE  SID=459)
select myevent_after.event, 
  myevent_after.total_waits-myevent_Before.total_waits total_diff,
  round((myevent_after.time_waited_micro-myevent_Before.time_waited_micro)/1e6) waited_micro_diff
from myevent_after, myevent_before
where myevent_after.event_id=myevent_before.event_id
 and myevent_after.total_waits-myevent_Before.total_waits <> 0
order by 1;
 "

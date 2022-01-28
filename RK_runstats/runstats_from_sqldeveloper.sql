-- WAIT EVENTS
drop table myevent_Before purge;
-- 11g
create table myevent_Before as
SELECT STAT.*
FROM V$session_event STAT
where SID=(select distinct sid from v$mystat)
;

-- SESSION STATISTICS
drop table mystat_Before purge;
-- 11g
create table mystat_before as
SELECT NAM.NAME, STAT.*
FROM V$SESSTAT STAT,
V$STATNAME NAM
WHERE NAM.STATISTIC#= STAT.STATISTIC# AND SID=(select distinct sid from v$mystat )
AND LOWER(NAME) LIKE '%%'
order by 1;

--------------------
--RUN YOUR CODE HERE
--------------------

with after_stat as (SELECT NAM.NAME, STAT.*
FROM V$SESSTAT STAT,
V$STATNAME NAM
WHERE NAM.STATISTIC#= STAT.STATISTIC# 
--AND SID=(select sid from v$mystat fetch first 1 rows only)
AND SID=&sid
AND LOWER(NAME) LIKE '%%'
order by 1)
select after_stat.name, after_stat.value-mystat_before.value
from mystat_before, after_stat
where mystat_before.statistic#=after_stat.statistic#
 and after_stat.value-mystat_before.value <> 0
order by 1;


with myevent_after as (select STAT.*
FROM V$session_event STAT
WHERE  
--SID=(select sid from v$mystat fetch first 1 rows only))
SID=&sid)
select myevent_after.event, 
  myevent_after.total_waits-myevent_Before.total_waits total_diff,
  round((myevent_after.time_waited_micro-myevent_Before.time_waited_micro)) waited_micro_diff
from myevent_after, myevent_before
where myevent_after.event_id=myevent_before.event_id
 and myevent_after.total_waits-myevent_Before.total_waits <> 0
order by 3 desc;


-- Active session history
select * from v$active_session_history 
where session_id = &sid
order by 1 desc;


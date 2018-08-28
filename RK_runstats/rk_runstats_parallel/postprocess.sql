insert into rk_runstat_events
   select 1,'manual',sid, serial#,event,0,0,0,0,null
   from 
   (select sid, serial#, event from rk_runstat_events where snapid=2
   minus
   select sid, serial#, event from rk_runstat_events where snapid=1);

insert into rk_runstat_events
   select 3,'manual',sid, serial#,event,0,0,0,0,null
   from 
   (select sid, serial#, event from rk_runstat_events where snapid=4
   minus
   select sid, serial#, event from rk_runstat_events where snapid=3);

commit;
exit;


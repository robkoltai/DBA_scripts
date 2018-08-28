@env

exec dbms_output.put_line ('Truncating runsats...');
truncate table rk_runstats;
truncate table rk_runstat_events;
truncate table rk_runstats_tmp;
truncate table rk_runstat_events_tmp;
truncate table rk_runstat_workarea_act;
truncate table rk_runstat_workarea_act_tmp;
truncate table rk_runstat_workarea_act_all;

truncate table rk_runstat_control;
insert into rk_runstat_control values (0, systimestamp,-1,'Start of &1 tests');

commit;

exit;

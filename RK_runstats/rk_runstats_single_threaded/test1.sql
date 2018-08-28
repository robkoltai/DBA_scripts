@env

exec dbms_output.put_line ('Truncating runsats...');
truncate table rk_runstats;
truncate table rk_runstat_events;

alter user nvme temporary tablespace RK_temp_orig_nogroup;
@manual_kicsi;


@rk_runstats 1;
exec dbms_output.put_line ('Starting index build on ORIG ts...');
@i;
@rk_runstats 2;

alter user nvme temporary tablespace RK_temp_nvme_nogroup;
@rk_runstats 3;
exec dbms_output.put_line ('Starting index build on NVME ts...');
@i;
@rk_runstats 4;

@rk_runstats_postprocessing.sql

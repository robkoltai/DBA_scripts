spool &1

conn nvme/nvme
@env
@manual_kicsi;

@set_module &1

-- TEST 1
alter user nvme temporary tablespace temp_ts_orig_group;
insert into rk_runstat_control values (1,systimestamp,3,'&1');
commit;
exec dbms_lock.sleep(5);


exec dbms_output.put_line ('Starting index build on ORIG ts...');
@ipar 2
insert into rk_runstat_control values (2,systimestamp,1,'&1');
commit;
exec dbms_lock.sleep(5);



conn nvme/nvme
@env
@manual_kicsi;

@set_module &1

-- TEST 2
alter user nvme temporary tablespace temp_ts_nvme_group;
insert into rk_runstat_control values (3,systimestamp,3,'&1');
commit;
exec dbms_lock.sleep(5);

exec dbms_output.put_line ('Starting index build on NVME ts...');
@ipar 2
insert into rk_runstat_control values (4,systimestamp,1,'&1');
commit;

exec dbms_lock.sleep(5);


exit;

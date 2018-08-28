define p_testlabel=&1
spool &p_testlabel

conn nvme/nvme
@env
@manual_kicsi;

@set_module &p_testlabel

-- TEST 1
@starttrace &p_testlabel TEST1

alter user nvme temporary tablespace temp_ts_orig_group;
insert into rk_runstat_control values (1,systimestamp,9,'&p_testlabel');
commit;
exec dbms_lock.sleep(5);


exec dbms_output.put_line ('Starting index build on ORIG ts...');
@ipar 2
insert into rk_runstat_control values (2,systimestamp,1,'&p_testlabel');
commit;
exec dbms_lock.sleep(5);
@endtrace &p_testlabel


conn nvme/nvme
@env
@manual_kicsi;

@set_module &p_testlabel

-- TEST 2
@starttrace &p_testlabel TEST2
alter user nvme temporary tablespace temp_ts_nvme_group;
insert into rk_runstat_control values (3,systimestamp,9,'&p_testlabel');
commit;
exec dbms_lock.sleep(5);

exec dbms_output.put_line ('Starting index build on NVME ts...');
@ipar 2
insert into rk_runstat_control values (4,systimestamp,1,'&p_testlabel');
commit;

exec dbms_lock.sleep(5);
@endtrace &p_testlabel

exit;

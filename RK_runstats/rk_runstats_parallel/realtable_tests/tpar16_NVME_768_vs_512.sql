define p_testlabel=&1
spool &p_testlabel

conn nvme/nvme
@env
alter session set sort_area_size=805306368;

@set_module &p_testlabel

-- TEST 1
@createawr
--@starttrace &p_testlabel TEST1

alter user nvme temporary tablespace temp_ts_nvme_group;
insert into rk_runstat_control values (1,systimestamp,33,'&p_testlabel');
commit;
exec dbms_lock.sleep(5);


exec dbms_output.put_line ('Starting index build for TEST1...');
@ipar 16
insert into rk_runstat_control values (2,systimestamp,1,'&p_testlabel');
commit;
exec dbms_lock.sleep(5);
--@endtrace &p_testlabel
@createawr

conn nvme/nvme
@env
alter session set sort_area_size=536870912;

@set_module &p_testlabel

-- TEST 2
@createawr
--@starttrace &p_testlabel TEST2
alter user nvme temporary tablespace temp_ts_nvme_group;
insert into rk_runstat_control values (3,systimestamp,33,'&p_testlabel');
commit;
exec dbms_lock.sleep(5);

exec dbms_output.put_line ('Starting index build for TEST2...');
@ipar 16
insert into rk_runstat_control values (4,systimestamp,1,'&p_testlabel');
commit;

exec dbms_lock.sleep(5);
--@endtrace &p_testlabel
@createawr


exit;


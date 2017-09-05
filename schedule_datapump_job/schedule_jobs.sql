teszt:

ALTER SESSION SET TIME_ZONE = 'CET';

begin
 DBMS_SCHEDULER.create_job (
    job_name        => 'BACKUP_GROUP1',
    job_type      => 'PLSQL_BLOCK',
    job_action    => 'BEGIN dbadmin.backup_schemas(''GROUP1''); END;',
    start_date      => NULL,
    repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=6; BYMINUTE=0; BYSECOND=0',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'backup GROUP1 schemas');
end;
/

begin
 DBMS_SCHEDULER.create_job (
    job_name        => 'BACKUP_GROUP2,
    job_type      => 'PLSQL_BLOCK',
    job_action    => 'BEGIN dbadmin.backup_schemas(''GROUP2''); END;',
    start_date      => NULL,
    repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=8; BYMINUTE=0; BYSECOND=0',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'backup GROUP2 schemas');
end;
/
prod:



-- We checked if we need create_job privilege to run a scheduler job created by someone else in our schema.
-- ANSWER: NO


create user nojog identified by nojog;
alter user nojog quota 10m on users;
grant connect to nojog;
grant create job to nojog;
create table nojog.nojog as select sysdate t from dual;



exec  DBMS_SCHEDULER.drop_JOB (   job_name           =>  'JOGOS.R');

exec  DBMS_SCHEDULER.disable ( 'JOGOS.R');
exec  DBMS_SCHEDULER.enable ( 'JOGOS.R');
  

-- JOGOS
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'JOGOS.R',
   job_type                 =>  'PLSQL_BLOCK',
   job_action               =>  'BEGIN insert into JOGOS.JOGOS values (sysdate); commit; END;',
   start_date         =>  systimestamp,
   repeat_interval    =>  'FREQ=SECONDLY;INTERVAL=10', 
   auto_drop          =>   FALSE,
   comments           =>  'My new job');
END;
/

-----------------------------------------------------------------------------------


create user nojog identified by nojog;
alter user nojog quota 10m on users;
grant connect to nojog;
--grant create job to nojog;
create table nojog.nojog as select sysdate t from dual;



exec  DBMS_SCHEDULER.drop_JOB (   job_name           =>  'NOJOG.R');

exec  DBMS_SCHEDULER.disable ( 'NOJOG.R');
exec  DBMS_SCHEDULER.enable ( 'NOJOG.R');
  

-- NOJOG
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'NOJOG.R',
   job_type                 =>  'PLSQL_BLOCK',
   job_action               =>  'BEGIN insert into NOJOG.NOJOG values (sysdate); commit; END;',
   start_date         =>  systimestamp,
   repeat_interval    =>  'FREQ=SECONDLY;INTERVAL=10', 
   auto_drop          =>   FALSE,
   comments           =>  'My new job');
END;
/

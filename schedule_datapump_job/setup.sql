
1. create user
create user dbadmin identified by "xxx"
      DEFAULT TABLESPACE "USERS"
      TEMPORARY TABLESPACE "TEMP";
ALTER USER DBADMIN QUOTA 10M ON USERS;

2. grants
GRANT CONNECT TO DBADMIN;
GRANT RESOURCE TO DBADMIN;
GRANT READ, WRITE on DIRECTORY SYS.ELEMZOI_BACKUP_DIR TO DBADMIN;
GRANT DATAPUMP_EXP_FULL_DATABASE TO DBADMIN;
GRANT DATAPUMP_IMP_FULL_DATABASE TO DBADMIN;

3. create table
create table dbadmin.schema_export
(env varchar2(20),
schema varchar2(30)
);

create table dbadmin.mail_recipients
(mail_type varchar2(20),
recipients varchar2(2000)
);

4a) schemas to export
insert into dbadmin.schema_export(env,schema) values ('GROUP1','SCH1');
insert into dbadmin.schema_export(env,schema) values ('GROUP1','SCH2');
insert into dbadmin.schema_export(env,schema) values ('GROUP2','SCH3');
insert into dbadmin.schema_export(env,schema) values ('GROUP2','SCH4');

4c) recipients
insert into dbadmin.mail_recipients(mail_type,recipients) values ('FINAL','email1@vau.com');
insert into dbadmin.mail_recipients(mail_type,recipients) values ('LOG','email2@vau.com');

5. create procedure
@backup_schemas_pkg.sql

6. backup test manually
exec dbadmin.backup_schemas('GROUP1');
exec dbadmin.backup_schemas('GROUP2');

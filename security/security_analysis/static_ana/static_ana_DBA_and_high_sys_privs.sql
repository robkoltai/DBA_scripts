-- ******************************
-- OVERVIEW
-- ******************************
-- DBA
select * from dba_role_privs
where granted_role = 'DBA'
and (grantee in (select username from dba_users where oracle_maintained = 'N')
or  grantee in (select role from dba_roles where oracle_maintained = 'N'))
order by 1;


-- HIGH SYS PRIVS
select * from dba_sys_privs
where  (grantee in (select username from dba_users where oracle_maintained = 'N')
or  grantee in (select role from dba_roles where oracle_maintained = 'N'))
and privilege NOT in (
'CREATE ASSEMBLY',
'CREATE ATTRIBUTE DIMENSION',
'CREATE CLUSTER',
'CREATE CREDENTIAL',
'CREATE CUBE',
'CREATE CUBE BUILD PROCESS',
'CREATE CUBE DIMENSION',
'CREATE DIMENSION',
'CREATE EVALUATION CONTEXT',
'CREATE EXTERNAL JOB',
'CREATE HIERARCHY',
'CREATE INDEXTYPE',
'CREATE JOB',
'CREATE LIBRARY',
'CREATE MATERIALIZED VIEW',
'CREATE MEASURE FOLDER',
'CREATE MINING MODEL',
'CREATE OPERATOR',
'CREATE PROCEDURE',
'CREATE RULE',
'CREATE RULE SET',
'CREATE SEQUENCE',
'CREATE SESSION',
'CREATE SQL TRANSLATION PROFILE',
'CREATE SYNONYM',
'CREATE TABLE',
'CREATE TRIGGER',
'CREATE TYPE',
'CREATE VIEW'
)
order by 1,2
;

-- HIGH SYS PRIVS with LISTAGG
select grantee, listagg(privilege,', ') within group( order by privilege) list_privs 
from (
select * from dba_sys_privs
where  (grantee in (select username from dba_users where oracle_maintained = 'N')
or  grantee in (select role from dba_roles where oracle_maintained = 'N'))
and privilege NOT in (
'CREATE ASSEMBLY',
'CREATE ATTRIBUTE DIMENSION',
'CREATE CLUSTER',
'CREATE CREDENTIAL',
'CREATE CUBE',
'CREATE CUBE BUILD PROCESS',
'CREATE CUBE DIMENSION',
'CREATE DIMENSION',
'CREATE EVALUATION CONTEXT',
'CREATE EXTERNAL JOB',
'CREATE HIERARCHY',
'CREATE INDEXTYPE',
'CREATE JOB',
'CREATE LIBRARY',
'CREATE MATERIALIZED VIEW',
'CREATE MEASURE FOLDER',
'CREATE MINING MODEL',
'CREATE OPERATOR',
'CREATE PROCEDURE',
'CREATE RULE',
'CREATE RULE SET',
'CREATE SEQUENCE',
'CREATE SESSION',
'CREATE SQL TRANSLATION PROFILE',
'CREATE SYNONYM',
'CREATE TABLE',
'CREATE TRIGGER',
'CREATE TYPE',
'CREATE VIEW'
))
group by grantee
order by 1
;

/*
SCHEMAx		DEBUG CONNECT SESSION
SCHEMAx			DEBUG CONNECT SESSION
SCHEMAx			DEBUG CONNECT SESSION
SCHEMAx			CREATE DATABASE LINK, SELECT ANY TABLE
SCHEMAx		SELECT ANY TABLE
SCHEMAx	UNLIMITED TABLESPACE
SCHEMAx		SELECT ANY DICTIONARY, UNLIMITED TABLESPACE
SCHEMAx			CREATE DATABASE LINK, SELECT ANY DICTIONARY, SELECT ANY SEQUENCE, SELECT ANY TABLE, UNLIMITED TABLESPACE

*/
-- create and setup PA user before starting the analysis
-- This user should hold the list of invalid objects before the analysis starts
-- This user can be used for static analysis

conn / as sysdba 
create tablespace rk_priv_ana datafile '/ora2/oradata/PFSJUT/rk_priv_ana01.dbf' size 5g autoextend on maxsize unlimited;
create user pa identified by pa default tablespace rk_priv_ana;
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO pa;
grant CAPTURE_ADMIN to pa;

grant create session, create table, create procedure to pa;
grant create type to pa;
grant create view to pa;


alter user pa quota unlimited on rk_priv_ana;
grant select on unified_audit_trail to pa;

grant select on dba_UNUSED_SYSprivs_PATH to pa;
grant select on dba_USED_SYSprivs_PATH to pa;

grant select on DBA_UNUSED_PRIVS to pa;
grant select on DBA_USED_PRIVS to pa;

grant select on dba_tab_privs to pa;
grant select on dba_role_privs to pa;
grant select on dba_sys_privs to pa;


grant select on dba_users to pa;
grant select on dba_roles to pa;
grant select on dba_objects to pa;
grant select on dba_synonyms to pa;
grant select on dba_dependencies to pa;
grant select on dba_segments to pa;

grant select on V_$XML_AUDIT_TRAIL to pa;

grant select on UTL_RECOMP_COMPILED to pa;
grant select on dba_scheduler_jobs to pa;
grant select on dba_scheduler_running_jobs to pa;

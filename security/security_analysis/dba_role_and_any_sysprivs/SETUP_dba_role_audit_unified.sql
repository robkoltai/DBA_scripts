-- With this you can audit DBA role with unified audit
-- *******************************************************
-- DBA or ANY
-- *******************************************************


-- drop
noaudit policy audit_dba_role;
drop audit policy audit_dba_role;

-- create
create audit policy audit_dba_role roles dba;
audit policy audit_dba_role;

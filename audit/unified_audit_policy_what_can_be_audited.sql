
https://imhungrysite.wordpress.com/developing-a-unified-audit-policy/
 --Include these in the “privileges” section of the CREATE AUDIT POLICY statement.
 select * from system_privilege_map order by name;
 
 
 --Include these in the “actions” section of the CREATE AUDIT POLICY statement. Note these actions look similar to the privileges in the previous query. But they are not.
  select * from auditable_system_actions order by name;
  select * from auditable_object_actions order by name;
  
 
  CREATE AUDIT POLICY MY_AUDIT_POLICY
  Privileges     /* From system_privilege_map  */
    ALTER SYSTEM
  Actions        /* From auditable_system_actions */
    ALL on SYS.UNIFIED_AUDIT_TRAIL,
    ALL on SYS.AUD$,
    ALTER AUDIT POLICY,
    ALTER DATABASE,
    ALTER TABLE,
    ALTER TABLESPACE,
    ALTER USER,
    AUDIT,
    CREATE INDEX,
    CREATE TABLE,
    CREATE TABLESPACE,
    CREATE USER,
    DROP INDEX,
    DROP TABLE,
    DROP TABLESPACE,
    DROP USER,
    GRANT,
    NOAUDIT
  Actions        /* From auditable_system_actions */
    Component = DataPump  EXPORT, IMPORT;

AUDIT POLICY MY_AUDIT_POLICY;


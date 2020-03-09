-- ==================================
conn / as sysdba
-- ==================================

-- create a tablespace
create tablespace rat datafile '/oradata/UNI/rat01.dbf' size 500m autoextend on maxsize 1g;

-- create a user RAT default tablespace RAT
drop user rat cascade;
create user rat identified by rat
default tablespace rat;

-- Grants
grant create session to rat;
Alter user rat quota unlimited on rat;
grant execute on dbms_xplan to rat;
grant execute on dbms_workload_repository to rat;

grant create table to rat;
grant create sequence to rat;

grant select on dba_objects to rat;

-- ==================================
conn rat/rat
-- ==================================
@/home/oracle/RAT/setup/setup_01_update_table.sql
@/home/oracle/RAT/setup/setup_02_parent_child.sql
@/home/oracle/RAT/setup/setup_03_insert_table.sql
@/home/oracle/RAT/setup/setup_04_select_table.sql

-- SWITCH BACK TO SYSDBA
conn / as sysdba


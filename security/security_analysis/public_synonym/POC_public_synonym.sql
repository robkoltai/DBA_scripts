-- *******************************************************
-- PUBLIC SYNONYM
-- Eszrevetelek
-- Csak traditional audittal lehet szinonimat auditalni. Legalabbis nekem nem sikerult unified-del
-- Ha mar megvan a NEM public synonym, akkor nem tudunk tesztelni ugy mint a DBA role eseten:
-- sajna nem eleg a privat synonym-ot letrehozni, mert a kovetkezo korben az audit rekord akkor is megjelenik
-- ha az objektumot privat szinoniman keresztul ertul el. Tehat drop public synonym is szukseges
-- *******************************************************
-- public synonym lista
column OWNER            format a20                                                                                 
column SYNONYM_NAME     format a30                                                                                 
column TABLE_OWNER      format a20                                                                                 
column TABLE_NAME       format a30                                                                                 
column DB_LINK          format a20
 
select * from dba_synonyms
where owner='PUBLIC' and table_owner in (
  select username 
  from dba_users
  where oracle_maintained = 'N')
order by 1,2,3,4  ;
  
  
-- AUDIT usage of public synonym
-- test

-- UNI adatbázis
create user a identified by a default tablespace users;
grant create session, create table, create public synonym to a;
alter user a quota 5m on users;

create user b identified by b default tablespace users;
grant create session to b;
conn b/b
select * from atable_pubsym;

conn a/a
create table atable (n number);
insert into atable values (17);
commit;
create public synonym atable_pubsym for atable;
grant select on atable to b;

-- ***********************************************************
-- SYS audit traditional
-- ***********************************************************
-- Ezzel tudjuk a synonym használatot auditálni
-- De kell hozzá extended audit, hogy tudjuk a parancsot

audit all on public.atable_pubsym; -- invalid table name
audit all on atable_pubsym;  -- OK.
noaudit all on atable_pubsym;

-- check statement audit configuration
-- NEM a synonym-et, hanem a tablat auditalja !!!
select * from DBA_OBJ_AUDIT_OPTS
where owner='A' or owner='PUBLIC';

-- Extended kell, hogy az SQL-t is elmentse varchar2000-be.
alter system set audit_trail=DB, EXTENDED scope=spfile;
select * from DBA_AUDIT_OBJECT;


generate audit, noaudit scripts

column the_command format a100
set lines 180
set pages 200
select rpad('&no_or_null' || 'audit all on ' || synonym_name || ';',50) 
 --||   ' --' || table_owner || '.' || table_name 
  as the_command 
from dba_synonyms
where owner='PUBLIC' and table_owner in (
  select username 
  from dba_users
  where oracle_maintained = 'N')
order by table_owner, table_name;

-- ***********************************************************
-- SYS audit unified
-- ***********************************************************
-- Nem tudok audit policy-t konfiguralni

select * from unified_audit_trail;


SQL> create audit policy atable_pubsyn_poly actions all on atable_pubsym;
create audit policy atable_pubsyn_poly actions all on atable_pubsym
                                                      *
ERROR at line 1:
ORA-46356: missing or invalid action audit option.


SQL> create audit policy atable_pubsyn_poly actions all on a.atable_pubsym;
create audit policy atable_pubsyn_poly actions all on a.atable_pubsym
                                                        *
ERROR at line 1:
ORA-00942: table or view does not exist

create audit policy atable_pubsyn_poly actions all on public.atable_pubsym;
                                                      *
ERROR at line 1:
ORA-00903: invalid table name



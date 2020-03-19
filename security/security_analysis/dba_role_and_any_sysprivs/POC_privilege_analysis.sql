-- ITT teszteltem ki, hogy privilege-anal mire jo es hogy kell hasznalni.

-- Condition generator
-- hat ez a select nem tudja visszzaadni a 90 usert, de egyparat biztosan.
-- ORA-01489: result of string concatenation is too long
--SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''ANA''
 select listagg('SYS_CONTEXT(''''USERENV'''', ''''SESSION_USER'''') = ''''' || username|| '''''', ' OR ') within group (order by username) as u
 from dba_users
    where oracle_maintained = 'N'
    and (username in ('SCHEMA1','SCHEMA2'))
    order by 1;


-- DBA role
-- find_all_privs2.sql - Pete finnigan tools


-- PRIVILEGE ANALYIS for DBA
-- SETUP 
-- ANA user. DBA ROLE-ban levo privilege-ket analizalunk. Megnezzuk, hogyan detektalja.
create user ana identified by a  default tablespace users;
grant create session to ana;
alter user ana quota 5m on users;
grant create table to ana;

create user ana_owner identified by a default tablespace users;
grant create session to ana_owner;
alter user ana_owner quota 5m on users;
grant create table, create procedure to ana_owner;

conn ana_owner/a
create table t (n number);
insert into t values (17);
commit;

create procedure p as
begin
  null;
end;
/


-- 


------------ TEST 1 ----------------
/*
ANA has 
  DBA ROLE
  select grant ON T;
ACTIONS
  delete from t;
  SELECT FROM T;
RESULT
  DELETE ANY TABLE found twice?
  SELECT NOT FOUND
  ALL OK.
CLEANUP
 revoke dba from ana;
 revoke select on ana_owner.t from ana;
*/
--sys
grant dba to ana;
grant select on ana_owner.t to ana;

begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'TEST1',
   type            => dbms_privilege_capture.g_role_and_context,
   roles           => role_name_list('DBA'),
   condition       =>'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''ANA''' );
end;
/

begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'TEST1',
  'RUN1');
end;
/

-- ANA
select * from ana_owner.t;
delete from ana_owner.t;
rollback;


-- sys
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'TEST1');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'TEST1',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/

------------ TEST 2 ----------------
/*
ANA has 
  grant DBA to ANA;
  grant select any table to ANA;
  grant execute any procedure to ANA;
ACTIONS
  delete from t;
  SELECT FROM T;
  begin
    p();
  end;
/

RESULT
We have select any table, execute_any_procedure. All through DBA role
CLEANUP
  revoke DBA from ANA;
  revoke select any table from ANA;
  revoke execute any procedure from ANA;
*/


--sys grants


begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'TEST2',
   type            => dbms_privilege_capture.g_role_and_context,
   roles           => role_name_list('DBA'),
   condition       =>'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''ANA''' );
end;
/

begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'TEST2',
  'RUN1');
end;
/

-- ANA
select * from ana_owner.t;
delete from ana_owner.t;
rollback;
 
begin
 ana_owner.p();
end;
/

-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'TEST2');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'TEST2',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/



------------ TEST 3 ----------------
/*
ANA has 
  grant select any table to ANA;
  grant execute any procedure to ANA;
  -- BUT NO DBA ROLE !!!
  -- Let us use CONTEXT and not role analysis
ACTIONS
  delete from t;
  SELECT FROM T;
  begin
    p();
  end;
/

RESULT
Found everything: select any table, execute any procedure
also public synonym usage was detected
What if ana has dba role as well? See test 4

CLEANUP
  revoke select any table from ANA;
  revoke execute any procedure from ANA;
*/


--sys grants


begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'TEST3',
   type            => dbms_privilege_capture.g_context,
   condition       =>'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''ANA'' or SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''XXX'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''YYY''' );
end;
/

begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'TEST3',
  'RUN1');
end;
/

-- ANA
select * from ana_owner.t;
delete from ana_owner.t;
rollback;
 
begin
 ana_owner.p();
end;
/

-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'TEST3');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'TEST3',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/


-------------- TEST4
-- Igy megvan minden ezt kell hasznalni
/*
ANA has 
  grant select any table to ANA;
  grant execute any procedure to ANA;
  grant select on SCHEMA1.PF_VERZIOK to ANA;
  grant select on SCHEMA1.PF_VERZIOK_ELFOGAD to ANA;
  grant dba to ANA;   

  
  -- Let us use CONTEXT and not role analysis
  -- let us check public synonym stuff as well
ACTIONS
  delete from t;
  SELECT FROM T;
  begin
    p();
  end;
/
  
  select * from SCHEMA1.PF_VERZIOK where 1=2;
  select * from PF_VERZIOK_ELFOGAD where 1=2;
  select PF_VERZIOK_SEQ.nextval from dual;


RESULT

CLEANUP
  revoke select any table from ANA;
  revoke execute any procedure from ANA;
  revoke select on SCHEMA1.PF_VERZIOK from ANA;
  revoke select on SCHEMA1.PF_VERZIOK_ELFOGAD from ANA;
  revoke dba from ANA;          

*/


--sys 


begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'TEST4',
   type            => dbms_privilege_capture.g_context,
   condition       => 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') > ''A'''  );
end;
/

begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'TEST4',
  'RUN1');
end;
/

-- ANA
select * from ana_owner.t;
delete from ana_owner.t;
rollback;
 
begin
 ana_owner.p();
end;
/

  select * from SCHEMA1.PF_VERZIOK where 1=2;
  select * from PF_VERZIOK_ELFOGAD where 1=2;
  select PF_VERZIOK_SEQ.nextval from dual;

-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'TEST4');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'TEST4',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/


-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DROP_CAPTURE (
  'TEST4');
end;
/

------------------

DBA_UNUSED_OBJPRIVS
DBA_UNUSED_OBJPRIVS_PATH
DBA_UNUSED_PRIVS
DBA_UNUSED_SYSPRIVS
DBA_UNUSED_SYSPRIVS_PATH
DBA_UNUSED_USERPRIVS
DBA_UNUSED_USERPRIVS_PATH


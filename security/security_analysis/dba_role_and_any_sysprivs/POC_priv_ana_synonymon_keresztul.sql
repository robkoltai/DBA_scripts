
-- POC
-- vajon mukodik synonym-on keresztul es view-n keresztul a dependency analysis?
-- Eredmeny egyáltalán NEM! Egy büdös rekordot sem generalt 19.3-on sem.
-- Ezért a static synonym analízist kell megcsinálni rendesen és kézzel.
-- Ehhez a tanulmányok idelent találhatóak, de az éles select-ek itt vannak: static_ana_dependencies_incl_synonyms.sql

/*
C user
		c_table 1 rekord
		c_view as select * from c_table;

B
		b_syn_on_c_table
		b_syn_on_c_view
		
		b_view_on_c_table

A
		a_syn_on_b_viewsyn
		a_syn_on_b_tablesyn

		
public  p_syn_on_c_table
		p_syn_on_c_view
		
		
AP 		
*/

drop user a cascade;
drop user b cascade;
drop user c cascade;
drop user ap cascade;

create user a identified by a;
create user b identified by b;
create user c identified by c;
create user ap identified by ap;

alter user a quota 50m on users;
alter user b quota 50m on users;
alter user c quota 50m on users;

grant create session, create table, create view, create synonym, create procedure to c;
grant create session, create table, create view, create synonym, create procedure to b;
grant create session, create table, create view, create synonym, create procedure to a;
grant create session to ap;

---
-- c user
create table c_table as select 17 as n from dual;
create view  c_view as select * from c_table where n>1;
/*
drop view c_view;
drop table c_table purge;

*/


--b usr
create synonym b_syn_on_c_table for c.c_table;
create synonym b_syn_on_c_view for c.c_view;

select * from b_syn_on_c_table;
select * from b_syn_on_c_view;
ORA-00942: table or view does not exist 
-- PEDIG EXISTS csak nincs ra select joga sem, 
--ezért nem tudhatja ezert van ez a hibauzenet es nem insufficient privileges

-- c user
grant select on c_view to b;
--revoke select on c_table from b;
grant select on c_table to b;
-- Eztan mar b utja olvasni mindkettot


-- a user
-- 2 lepeses szinonima
create synonym a_syn_on_b_viewsyn for b.b_syn_on_c_view;
create synonym a_syn_on_b_tablesyn for b.b_syn_on_c_table;

-- b grantot ad a sajat szinonimjara
grant select on b_syn_on_c_view to a;
grant select on b_syn_on_c_table to a;
ORA-01031: insufficient privileges		
-- Nem tud ra grantot adni. Nincs grant optionnye

-- c user ismet
grant select on c_view to b with grant option;
grant select on c_table to b with grant option;

-- b ujraprobal sikeresen
grant select on b_syn_on_c_view to a;
grant select on b_syn_on_c_table to a;


-- a teszteli sikeresen
select * from a_syn_on_b_viewsyn;
select * from a_syn_on_b_tablesyn;

-- SYS
create public synonym p_syn_on_c_table for c.c_table;
create public synonym p_syn_on_c_view for c.c_view;

-- c
grant select on c_table to ap;
grant select on c_view to ap;

-- ap sikeres teszteli
select * from p_syn_on_c_table;
select * from p_syn_on_c_view;

----- ***************************************************************
-- PRIV ANA
----- ***************************************************************

-- SEMMIT SEM DETEKTAL 19.3


@one_time_dependency_privilege_ana.sql

select * from dba_unused_privs where (username in ('A','B','C','AP','PUBLIC') or object_owner in ('A','B','C','AP','PUBLIC'));
select * from dba_used_privs where (username in ('A','B','C','AP','PUBLIC') or object_owner in ('A','B','C','AP','PUBLIC'));

select * from DBA_USED_OBJPRIVS where (username in ('A','B','C','AP','PUBLIC') or object_owner in ('A','B','C','AP','PUBLIC'));
select * from DBA_UNUSED_OBJPRIVS where (username in ('A','B','C','AP','PUBLIC') or object_owner in ('A','B','C','AP','PUBLIC'));

https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dvadm/performing-privilege-analysis-to-find-privilege-use.html#GUID-77961026-AD82-4BD2-98B0-70A74DD3FAA0
-- This has synonyms and views
select distinct type from ALL_DEPENDENCIES ;


----- ***************************************************************
-- MANUAL DEPENDENCY ANALYSYS
----- ***************************************************************
select * from all_dependencies  
where (owner in ('A','B','C','AP','PUBLIC') or referenced_owner in ('A','B','C','AP','PUBLIC'))
and (referenced_owner not in (select username from dba_users where oracle_maintained = 'Y'))
and (owner            not in (select username from dba_users where oracle_maintained = 'Y'))
and owner <> 'NF' and name <> 'V$XS_SESSION_ROLE'
order by 1,2,4,5;

select * from all_dependencies where referenced_name = 'C_TABLE'; 
select * from all_dependencies where name = 'B_SYN_ON_C_VIEW'; 

drop table deptab purge;
create table deptab as 
select owner, name, type, referenced_owner, referenced_name, referenced_type, dependency_type, 0 as is_it_root
from all_dependencies  
where (owner in ('A','B','C','AP','PUBLIC') or referenced_owner in ('A','B','C','AP','PUBLIC'))
and (referenced_owner not in (select username from dba_users where oracle_maintained = 'Y'))
and (owner            not in (select username from dba_users where oracle_maintained = 'Y'))
and owner <> 'NF' and name <> 'V$XS_SESSION_ROLE'
union all
select distinct referenced_owner, referenced_name, referenced_type, null, null,null,null, 1 as is_it_root
from all_dependencies
where (owner in ('A','B','C','AP','PUBLIC') or referenced_owner in ('A','B','C','AP','PUBLIC'))
and (referenced_owner not in (select username from dba_users where oracle_maintained = 'Y'))
and (owner            not in (select username from dba_users where oracle_maintained = 'Y'))
and owner <> 'NF' and name <> 'V$XS_SESSION_ROLE'
and referenced_type not in ('SYNONYM')
;

select * from deptab;

create or replace view dep_view as
select owner, name, type, referenced_owner as ref_own, referenced_name as ref_name, referenced_type,-- dependency_type,
connect_by_root owner root_owner,
connect_by_root name  root_name,
connect_by_root type  root_type,
connect_by_isleaf as this_is_leaf,
CONNECT_BY_ISCYCLE as this_causes_cycle,
level as d_level
from deptab
start with is_it_root = 1
connect by  NOCYCLE
            referenced_name = prior name 
    and     referenced_owner = prior owner
order by root_owner, root_name,level;

select * from dep_view;

-- Sima egyszintu select
select distinct 'grant select on ' || ref_own || '.' || ref_name || ' to ' || owner || ';'  the_sql
from dep_view
where owner <> 'PUBLIC'
--and root_owner <> owner
  and ref_name is not null
order by 1;

-- Grant option kell a 2 szinthez
-- Tovabbadas eseten grant option kell 2 szintet eleg
select distinct 'grant select on ' || c.ref_own || '.' || c.ref_name || ' to ' || c.owner || ' with grant option;'  the_sql
--select c.*
from dep_view f, dep_view c
where 
-- join
   f.ref_own = c.owner and f.ref_name = c.name
-- semak kozt van a lanc vege
and c.ref_own<>c.owner
-- semak kozt van a lanc eleje
and f.ref_own <> f.owner
--where owner <> 'PUBLIC'
--and root_owner <> owner
 -- and ref_name is not null
and c.type <> 'SYNONYM'
order by 1;

-------------------------------
-- FURCSA USE CASE-ek
-------------------------------
--1. a.a_f1_on_b_f1_view -> b.b_f1_view -> a.a_f1_table
/*
Nem eleg
grant select on A.A_F1_TABLE to B;
grant select on B.B_F1_VIEW to A;

Ez kell helyette
grant select on A.A_F1_TABLE to B with grant option;
grant select on B.B_F1_VIEW to A;

Ha egy B.VIEW viewban használunk más séma objektumát A.TABLE-t és B.VIEW-t akarja egy NEM B séma olvasni, akkor
a B-nek GRANT OPTIONNEL kell adni a select jogot A.TABLE-re
*/

conn a/a
create or replace synonym a_f1_on_b_f1_view for b.b_f1_view;
create table a_f1_table as select 'A_f1' as v from dual;
grant select on a_f1_table to b;


conn b/b
create table b_f1_table as select 'B_f1' as v from dual;
create or replace view b_f1_view as select * from a.a_f1_table;
---------------------------------------------------------------------------

--2 )
conn c/c
create table c_f2_table as select 'C F2' as v from dual;
grant select on c_f2_table to b with grant option;

conn b/b
create or replace view b_f2_view_on_c_f2_table as select * from c.c_f2_table;
create table b_f2_table  as select 'B F2' as v from dual;


grant select on b_f2_view_on_c_f2_table to a;
grant select on b_f2_table to a;


conn a/a

create synonym a_f2_syn_for_b_f2_table for b.b_f2_table;
create synonym a_f2_syn_for_b_f2_view_on_c_f2_table for b.b_f2_view_on_c_f2_table;

create or replace procedure a_f2_func as
v varchar2(200);
n number;
begin
  select count(1) 
  into n 
  from a_f2_syn_for_b_f2_table;

  select count(1) 
  into n 
  from a_f2_syn_for_b_f2_view_on_c_f2_table;
	
  dbms_output.put_line ('Yuhey f2');
  return;
end;
/

-----------------------------------
---------- TESZTESETEK
-------------------------------
-- ha csak mindenkinek a ROOT-ra adunk, akkor megy e a viewra

-- ALAP
--a user)
select * from a_syn_on_b_viewsyn;
select * from a_syn_on_b_tablesyn;

--b user)
select * from b_syn_on_c_table;
select * from b_syn_on_c_view;

-- FURCSA
--F1
-- a user

select * from a_f1_on_b_f1_view;

-- F2
conn c/c
drop table c.c_f2_table purge;
create table c_f2_table as select 'C F2' as v from dual;

grants
conn a/a
set serveroutput on;
exec a_f2_func;
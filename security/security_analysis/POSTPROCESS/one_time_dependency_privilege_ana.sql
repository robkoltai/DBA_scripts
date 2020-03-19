-- COMPILE TIME elemzes

-- Ezt egy statikus DB-n ahol jók a DBlinkek
-- Barmikor le lehet futtatni.
-- DBMS doc: https://docs.oracle.com/en/database/oracle/oracle-database/12.2/arpls/DBMS_PRIVILEGE_CAPTURE.html#GUID-7A5F038A-47FD-4788-8AF3-529D76228254
-- Hasznalat doc: https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dvadm/performing-privilege-analysis-to-find-privilege-use.html#GUID-77961026-AD82-4BD2-98B0-70A74DD3FAA0

-- AZ adatgyujtest es az elemzest lehet a RAT REPLAY-el azaz a dinamikus adatgyujtessel egyutt is csinalni.
-- DE én külon csinaltam es a scriptjeim ehhez vannak belőve.

-- Ennek hatránya, hogy az unused jogosultságok nem egy halmazban vannak, hanem kettőben és valójában csak a metszetük unused.
-- Azonban a módszerünk lényege a USED privilege-ken működik, ahol pedig használhatunk UNIO operátort a dinamikusan és statikusan felvett használatok között


conn / as sysdba
begin
  DBMS_PRIVILEGE_CAPTURE.DROP_CAPTURE (
  'COMPILECAP');
end;
/

-- Doksik aszondja, hogy global capture kell hozza
begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'COMPILECAP',
   type            => dbms_privilege_capture.g_database);
end;
/

-- INDITHATJUK AKAR MOST IS, mert a terminalrol ugysem jo mas
begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'COMPILECAP',
  'CAP_COMP1');
end;
/

-- Ez nem tom mit csinal, de kell.
-- Nem tudjuk mikor kell inditani
exec DBMS_PRIVILEGE_CAPTURE.CAPTURE_DEPENDENCY_PRIVS ();

-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'COMPILECAP');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'COMPILECAP',
   run_name    => 'CAP_COMP1',
   DEPENDENCY  => true); -- ez itt a fontos
end;
/

/*
Because these privileges may not be exercised during run time when a stored procedure is called, 
these privileges are collected when you generate the results for any database-wide capture, 
along with run-time captured privileges. 

A privilege is treated as an UNUSED privilege 
when it is NOT USED in either pre-compiled database objects or run-time capture, and it is saved under the run-time capture name. 
For UNUSED privileges, you only need to query with the run-time capture name.

If a privilege is USED for pre-compiled database objects, then it is saved under the capture name ORA$DEPENDENCY. 
If you want to know what the USED privileges are for both pre-compiled database objects 
and run-time usage, then you must query both the ORA$DEPENDENCY and run-time captures. 


If a privilege is captured during run time, then it is saved under the run-time capture name. 
*/

--***********************************************
-- save tables under pa.
--***********************************************
conn pa/pa

@helper_plsql\priv_ana_util.sql

--Mi a capture
select count(1) ,capture from dba_used_privs group by capture;
-- minden ami nem ORA$DEPENDENCY az a mérés során futó dinamikus jog használat

drop table RK_PRIV_ANA_USED_DEPEND purge;
create table RK_PRIV_ANA_USED_DEPEND tablespace rk_priv_ana as  
select p.* from dba_used_privs p where 1=2;
alter table RK_PRIV_ANA_USED_DEPEND add path_levels number;
alter table RK_PRIV_ANA_USED_DEPEND add path1 varchar2(128);
alter table RK_PRIV_ANA_USED_DEPEND add path2  varchar2(128);
alter table RK_PRIV_ANA_USED_DEPEND add path_last  varchar2(128);

insert into RK_PRIV_ANA_USED_DEPEND 
select p.*,
  priv_ana_util.get_path_info(path,0),
  priv_ana_util.get_path_info(path,1),
  priv_ana_util.get_path_info(path,2),
  priv_ana_util.get_path_info(path,-1)
from dba_used_privs p
where capture = 'ORA$DEPENDENCY'
order by username, used_role, object_owner, object_name, object_type
;
commit;

select count(1) ,capture from dba_unused_privs group by capture;

drop table RK_PRIV_ANA_UNUSED_DEPEND purge;
create table RK_PRIV_ANA_UNUSED_DEPEND tablespace rk_priv_ana as  
select p.* from dba_UNused_privs p where 1=2;
alter table RK_PRIV_ANA_UNUSED_DEPEND add path_levels number;
alter table RK_PRIV_ANA_UNUSED_DEPEND add path1 varchar2(128);
alter table RK_PRIV_ANA_UNUSED_DEPEND add path2  varchar2(128);
alter table RK_PRIV_ANA_UNUSED_DEPEND add path_last  varchar2(128);

insert into RK_PRIV_ANA_UNUSED_DEPEND 
select p.*,
  priv_ana_util.get_path_info(path,0),
  priv_ana_util.get_path_info(path,1),
  priv_ana_util.get_path_info(path,2),
  priv_ana_util.get_path_info(path,-1)
from dba_UNused_privs p
where capture = 'COMPILECAP'
order by username, object_owner, object_name, object_type
;
commit;


create index KR_priv_ana_unused_syspriv_D on RK_PRIV_ANA_UNUSED_DEPEND (sys_priv)
tablespace rk_priv_ana;
--------------------- ANA


-- ************************************
-- EGY SZINTU, azaz DIRECT GRANT HASZNALAT (ez csak objektum lehet)
-- ************************************
-- NEM PUBLICNAK van grantolva: OK hasznalja. Azonban van ahol SYS_PRIV is not null (1)
-- PUBLICNAK:
--   Oracle objektum: OK hasznalja (2)
--   Nem oracle objektumra: vegyuk vissza a PUBLIC grantokat es adjunk direkteket (3)

-- Nezd szemmel NEM PUBLICNAK ADOTT es NEM Oracle sema altal hasznalt
select * from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1<>'PUBLIC'
  and username in (select username from dba_users where oracle_maintained = 'N')
order by username,module, object_name, capture;

-- (1) SYS_PRIV is not null kezelese, ezek objekt privilegiumok
-- and SYS_PRIV is null: Nezd meg szemmel. Ezek mind tutira kellenek DIREKT OBJEKTUM GRANTOK
-- csak hogy minden leforduljon
-- Ezek MEG is vannak hisz egyébként hogy tudná használni
select * from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is null
  and username in (select username from dba_users where oracle_maintained = 'N')
order by username,module, object_name, capture;

-- Generaljuk le oket, ha netalan revoke miatt kellene vissza tudjuk adni
-- dep_ana_01_used_not_public_direct_object.sql
select distinct
'GRANT ' || obj_priv ||' on ' || object_owner || '.' || object_name || ' to ' || username||';' the_sql
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is null
  and username in (select username from dba_users where oracle_maintained = 'N')
order by 1;
--------------------------------------------

-- and SYS_PRIV is NOT null: Na ezeket kell kezelni
select * from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is NOT null
  and username in (select username from sys.dba_users where oracle_maintained= 'N')
order by username,module, object_name, capture;

-- and SYS_PRIV is NOT null: Na ezeket kell kezelni. REVOKE
-- dep_ana_02_revoke_level1_sysprivs.sql
-- UNLIMITED TABLESPACE-t nem kene meg visszavonni, mert nem tudjuk milyen direkt grant vagy quota kene
select distinct 
decode (sys_priv,'UNLIMITED TABLESPACE','--') ||
'Revoke ' || SYS_PRIV || ' from ' || username ||';' the_sql
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is NOT null
  and username in (select username from dba_users where oracle_maintained='N')
order by 1;

-- and SYS_PRIV is NOT null: Na ezeket kell kezelni. GRANT
--dep_ana_03_grant_level1_sysprivs.sql
select distinct
     'grant '  || 
      decode (sys_PRIV, 
      'DELETE ANY TABLE', 'DELETE ',
      'INSERT ANY TABLE', 'INSERT ',
      'READ ANY TABLE', 'READ ',
      'SELECT ANY TABLE', 'SELECT ',
      'UPDATE ANY TABLE', 'UPDATE ',
      'EXECUTE ANY PROCEDURE', 'EXECUTE ',
      'SELECT ANY DICTIONARY', 'SELECT ',
      'SELECT ANY SEQUENCE', 'SELECT ',
      'MERGE ANY VIEW', 'MERGE VIEW ',
      '???:' || sys_PRIV) ||
        ' ON "' || object_owner||'"."' ||object_name || '" TO ' || username || ';' as the_sql 
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is NOT null
  and username in (select username from dba_users where oracle_maintained='N')
order by 1;


-- (2) OK. Ezeket az Oracle corp. grantolta PUBLIC-nak, ezert nem foglalkozunk vele
-- De azert nezzuk meg oket szemmel
select * from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='Y');


-- (3) PUBLIC GRANT NEM ORACLE OBJEKTUMRA
-- Itt érdekes módon a used_role is lehet PUBLIC vagy egyenlo a USERNAME-mel.
-- Ha USED_ROLE='PUBLIC' akkor a hasznalonak nincs sajat joga ES PUBLIC-ot kell hasznaljon
-- Ha USED_ROLE=USERNAME akkor a hasznalonak van sajat joga ES PUBLIC-ot os hasznalhatna
select * 
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N');
  
-- MINDEN PUBLIC JOGOT REVOKE ALL-ozunk
-- priv_ana_01_public_level1_revoke.sql
-- TYPE miatt ket reszre bontjuk: NEM TYPE es TYPE

-- NEM TYPE I
-- dep_ana_04_public_level1_revoke_nontype.sql
select distinct
'Revoke all on ' || object_owner || '.' || object_name || ' from PUBLIC;' the_sql
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N')
  and object_type <>'TYPE'
order by 1;

-- TYPE II -- force -al kell revoke-olni
-- Egy seged viewt hozunk letre
create or replace view rk_priv_ana_pub_type_gr_v as select object_owner, object_name 
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N')
  and object_type ='TYPE';

-- revoke utasitasok generalasa  
-- dep_ana_05_public_level1_revoke.sql
select distinct
'Revoke all on ' || object_owner || '.' || object_name || ' from PUBLIC force;' the_sql
from rk_priv_ana_pub_type_gr_v 
order by 1;


-- Ez mehet ide compile a revoke type ok utan
-- dep_ana_06_public_level1_compile.sql
select distinct 'alter ' ||
  case when type in ('PACKAGE','PACKAGE BODY') then ' PACKAGE ' 
       else type || ' '
  end || owner || '.' ||name || ' compile ;'
from 
    (
        SELECT DISTINCT
            object_name name,
            owner,
            object_type type,
            hier.object_id,
            status
            --DECODE(replace(object_type, ' ', '_'), 'PACKAGE_BODY', 'PACKAGE', replace(object_type, ' ', '_')) type_link
        FROM
            sys.dba_objects o,
            (
                SELECT
                    object_id,
                    level l,
                    ROWNUM ord
                FROM
                    public_dependency
                CONNECT BY NOCYCLE
                    PRIOR object_id = referenced_object_id
                START WITH referenced_object_id in (
                  select o.object_id 
                  from sys.dba_objects o, rk_priv_ana_pub_type_gr_v rk
                  where o.owner = rk.object_owner
                    and o.object_name = rk.object_name
                    and o.object_type = 'TYPE')
            ) hier
        WHERE
            hier.object_id = o.object_id
    )
where type not in ('SYNONYM','TABLE', 'TYPE BODY') 
order by 1;


-- Minden hasznalt jogot kiadunk direktbe, ami eddig publikon keresztul jott
-- itt a type es nem type egyarant benne van
-- dep_ana_07_public_level1_grant.sql
select distinct
'GRANT ' || obj_priv ||' on ' || object_owner || '.' || object_name || ' to ' || username||';' the_sql
from RK_PRIV_ANA_USED_DEPEND 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N')
order by 1;


-- ************************************
-- TOBB szintű
-- ************************************
-- A _UGYFEL_s ROLE-okat hagyjuk békén, azaz csak Oracle role-okat vonogassunk vissza
-- OBJEKTUM eseten PATH2 visszavon es grantol objektum privit
-- SYS_PRIV eseten lasd lentebb
-- Obj full lista szemrevetelezesre:

-- EZ ELVILEG URES LISTA, mert compile time ROLE-on keresztul nem johetett grant
select * from RK_PRIV_ANA_USED_DEPEND 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and (path2 in (select role from dba_roles where oracle_maintained='Y') or used_role in (select role from dba_roles where oracle_maintained='Y'))
  and obj_priv is not null;

-- **********************************
-- NEW Wave analysis - UNUSED ALAPJAN
-- **********************************


create table rk_revoke_priv_list  tablespace rk_priv_ana as 
select distinct sys_priv from RK_PRIV_ANA_USED_DEPEND
where sys_priv not in ('CREATE ANALYTIC VIEW',
'CREATE ASSEMBLY',
'CREATE ATTRIBUTE DIMENSION',
'CREATE CLUSTER',
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
'CREATE LOCKDOWN PROFILE',
'CREATE MATERIALIZED VIEW',
'CREATE PROCEDURE',
'CREATE RULE',
'CREATE RULE SET',
'CREATE SEQUENCE',
'CREATE SESSION',
'CREATE SYNONYM',
'CREATE TABLE',
'CREATE TRIGGER',
'CREATE TYPE',
'CREATE VIEW')
order by 1;


-- REVOKE NEM HASZNALT LEVEL=1
select * from RK_PRIV_ANA_USED_DEPEND 
where sys_priv  is  not null
  and path_levels=1
  and sys_priv in (select sys_priv
  from rk_revoke_priv_list)
  and username not in (select username from dba_users where oracle_maintained='Y')
order by 1,2,3;

-- dep_ana_08_revoke_unused_level1_direct.sql
select distinct
decode (sys_priv,'UNLIMITED TABLESPACE','--') ||
'Revoke ' || SYS_PRIV || ' from ' || username ||';' the_sql
from RK_PRIV_ANA_USED_DEPEND 
where sys_priv  is  not null
  and path_levels=1
  and sys_priv in (select sys_priv
  from rk_revoke_priv_list)
  and username not in (select username from dba_users where oracle_maintained='Y')
order by 1;

-- REVOKE NEM HASZNALT LEVEL sok
-- Ez is definicio szerint ures kell legyen
select  username, path2, count(1) c from (
select * from RK_PRIV_ANA_USED_DEPEND 
where sys_priv  is  not null
  and path_levels>1
  and sys_priv in (select sys_priv
  from rk_revoke_priv_list)
  and username not in (select username from dba_users where oracle_maintained='Y')
)
group by username, path2
order by 2,1;
-- kezzel revoke

-- EXPORT PA user
expdp  directory='NFSDUMP' dumpfile=dependency_anal_pa.dmp logfile=dependency_anal_pa.elog schemas=pa
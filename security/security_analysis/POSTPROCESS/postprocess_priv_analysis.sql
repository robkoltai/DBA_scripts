-- Summary:
/*
1) Ertelmezes
"PATH" os viewk MINDEN UTAT MEGADNAK AHOGY EL LEHET JUTNI a jogosultsaghoz.
select * from dba_used_sysprivs_PATH where username<>used_role order by username, module;

osszesen 142 sor, ebbol egy jo SCHEMA1 pelda:
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	SYS.GRANT_PATH('SCHEMA1', 'DBA', 'EXP_FULL_DATABASE')	RUN1
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	SYS.GRANT_PATH('SCHEMA1', 'DBA', 'DATAPUMP_EXP_FULL_DATABASE', 'EXP_FULL_DATABASE')	RUN1
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	SYS.GRANT_PATH('SCHEMA1', 'DBA', 'DATAPUMP_IMP_FULL_DATABASE', 'IMP_FULL_DATABASE')	RUN1
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	SYS.GRANT_PATH('SCHEMA1', 'DBA')	RUN1
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	SYS.GRANT_PATH('SCHEMA1', 'DBA', 'IMP_FULL_DATABASE')	RUN1
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	SYS.GRANT_PATH('SCHEMA1', 'DBA', 'DATAPUMP_IMP_FULL_DATABASE', 'EXP_FULL_DATABASE')	RUN1


select * from dba_used_sysprivs where username<>used_role order by username, module;

ossesen 12 rekord van ebbol 1 SCHEMA1-os pelda
RATREPLAY03_PRIV	1	localuser	DOMAIN\GB61797	JDBC Thin Client	SCHEMA1	IMP_FULL_DATABASE	EXECUTE ANY PROCEDURE	0	RUN1


2) Tokeletlenseg
Van ilyen rekord is:
RATREPLAY04_PRIV	1	localuser	DOMAIN\GB61797	BIBusTKServerMain@prodapp085.DOMAIN.hu (TNS V1	AKR	DATAPUMP_IMP_FULL_DATABASE	SELECT ANY TABLE			SCHEMA	AJANLAT_ADATLAP	TABLE		0	SYS.GRANT_PATH('AKR')	RUN1	1	AKR		AKR
Mi ezzel a gond? Az, hogy 
USED_ROLE=DATAPUMP_IMP_FULL_DATABASE
SYS_PRIV=SELECT ANY TABLE
PATH=SYS.GRANT_PATH('AKR')
A direkt jog hogy jöhet ROLE-on keresztül? Sehogy...

3) Tokeletlenseg II

Mi van azokkal a userekkel akik be sem léptek a felvétel során????
Na ezek meg sem jelentek sehol...
Sem a used privs-ben
Sem az unused privs-ben

-----------------------
Csomo mindent vissza tudunk vonni a USED alapjan

*/

-- **********************************
-- NEW Wave analysis - USED ALAPJAN
-- **********************************


conn pa/pa
drop table RK_PRIV_ANA_USED purge;
create table RK_PRIV_ANA_USED tablespace rk_priv_ana as  
select p.* from dba_used_privs p where 1=2;
alter table RK_PRIV_ANA_USED add path_levels number;
alter table RK_PRIV_ANA_USED add path1 varchar2(128);
alter table RK_PRIV_ANA_USED add path2  varchar2(128);
alter table RK_PRIV_ANA_USED add path_last  varchar2(128);

insert into rk_priv_ana_used 
select p.*,
  priv_ana_util.get_path_info(path,0),
  priv_ana_util.get_path_info(path,1),
  priv_ana_util.get_path_info(path,2),
  priv_ana_util.get_path_info(path,-1)
from dba_used_privs p
where capture = '&Enter_capture_name'
order by username, used_role, object_owner, object_name, object_type
;
commit;



-- ************************************
-- EGY SZINTU DIRECT GRANT HASZNALAT (ez csak objektum lehet)
-- ************************************
-- NEM PUBLICNAK: OK hasznalja (1)
-- PUBLICNAK:
--   Oracle objektum: OK hasznalja (2)
--   Nem oracle objektumra: vegyuk vissza a PUBLIC grantokat es adjunk direkteket (3)


-- ************************************
-- EGY SZINTU, azaz DIRECT GRANT HASZNALAT (ez csak objektum lehet)
-- ************************************
-- NEM PUBLICNAK van grantolva: OK hasznalja. Azonban van ahol SYS_PRIV is not null (1)
-- PUBLICNAK:
--   Oracle objektum: OK hasznalja (2)
--   Nem oracle objektumra: vegyuk vissza a PUBLIC grantokat es adjunk direkteket (3)

-- (1) OK
-- Ezt csak nezd meg szemmel itt vannak a nem PUBLICnak grantolt direkt jogosultsagok
select * from rk_priv_ana_used 
where path_levels = 1
  and path1<>'PUBLIC'
order by username,module, object_name, capture;

-- (1) SYS_PRIV is not null kezelese
-- and SYS_PRIV is null: Nezd meg szemmel, hogy ignoralhatok-e ezek. Elvart, hogy ignoralhatok legyenek
select * from rk_priv_ana_used 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is null
order by username,module, object_name, capture;

-- and SYS_PRIV is NOT null: Na ezeket kell kezelni
select * from rk_priv_ana_used 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is NOT null
  and username in (select username from sys.dba_users where oracle_maintained= 'N')
order by username,module, object_name, capture;

-- and SYS_PRIV is NOT null: Na ezeket kell kezelni. REVOKE
-- priv_ana_09_revoke_level1_sysprivs.sql
-- UNLIMITED TABLESPACE-t nem kene meg visszavonni, mert nem tudjuk milyen direkt grant vagy quota kene
select distinct 
decode (sys_priv,'UNLIMITED TABLESPACE','--') ||
'Revoke ' || SYS_PRIV || ' from ' || username ||';' the_sql
from rk_priv_ana_used 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is NOT null
  and username in (select username from dba_users where oracle_maintained='N')
order by 1;

-- and SYS_PRIV is NOT null: Na ezeket kell kezelni. GRANT
--priv_ana_10_grant_level1_sysprivs.sql
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
from rk_priv_ana_used 
where path_levels = 1
  and path1<>'PUBLIC'
  and SYS_PRIV is NOT null
  and username in (select username from dba_users where oracle_maintained='N')
order by 1;


-- (2) OK. Ezeket az Oracle corp. grantolta PUBLIC-nak, ezert nem foglalkozunk vele
-- De azert nezzuk meg oket szemmel
select * from rk_priv_ana_used 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='Y');


-- (3) PUBLIC GRANT NEM ORACLE OBJEKTUMRA
-- Itt érdekes módon a used_role is lehet PUBLIC vagy egyenlo a USERNAME-mel.
-- Ha USED_ROLE='PUBLIC' akkor a hasznalonak nincs sajat joga ES PUBLIC-ot kell hasznaljon
-- Ha USED_ROLE=USERNAME akkor a hasznalonak van sajat joga ES PUBLIC-ot os hasznalhatna
select * 
from rk_priv_ana_used 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N');
  
-- MINDEN PUBLIC JOGOT REVOKE ALL-ozunk
-- TYPE miatt ket reszre bontjuk: NEM TYPE es TYPE

-- NEM TYPE I
-- priv_ana_01_public_level1_revoke_nontype.sql
select distinct
'Revoke all on ' || object_owner || '.' || object_name || ' from PUBLIC;' the_sql
from rk_priv_ana_used 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N')
  and object_type <>'TYPE'
order by 1;

-- TYPE II -- force -al kell revoke-olni
-- Egy seged viewt hozunk letre
create or replace view rk_priv_ana_pub_type_gr_v as select object_owner, object_name 
from rk_priv_ana_used 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N')
  and object_type ='TYPE';

-- revoke utasitasok generalasa  
-- priv_ana_01_public_level1_revoke_type_force.sql
select distinct
'Revoke all on ' || object_owner || '.' || object_name || ' from PUBLIC force;' the_sql
from rk_priv_ana_pub_type_gr_v 
order by 1;

/*
DEPRECATED
-- Ha van type akkor force-al kellhet revoke -olni, ha van a type-ot hasznalo package, table, procedure, function.
-- Pelda revoke force
Revoke all on SCHEMA.TY_KEY_VALUE_PAIR_LIST from PUBLIC force; -- HAMMY_INTERFACE-NEK van ra direkt joga es neki vannak dependent tablai
select * from dba_dependencies
where referenced_name = 'TY_KEY_VALUE_PAIR_LIST' order by 1,2,3;

-- Ehhez tartozo recompileok generalasa
 Ez a select nem adott mindent vissza. Ezert SQLDeveloper bol loptam a dependencies lekerdezest. Lasd alabb
select distinct 'alter ' ||
  case when type in ('PACKAGE','PACKAGE BODY') then ' PACKAGE ' 
       else type || ' '
  end || owner || '.' ||name || ' compile ;'
from dba_dependencies
where referenced_name = 'TY_KEY_VALUE_PAIR_LIST' 
and type not in ('SYNONYM','TABLE') 
order by 1;
*/

-- Ez mehet ide  
-- priv_ana_02_public_level1_compile.sql
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


-- Minden hasznalt jogot kiadunk direktbe 
-- itt a type es nem type egyarant benne van
-- priv_ana_02_public_level1_grant.sql
select distinct
'GRANT ' || obj_priv ||' on ' || object_owner || '.' || object_name || ' to ' || username||';' the_sql
from rk_priv_ana_used 
where path_levels = 1
  and path1='PUBLIC' and object_owner in (select username from dba_users where oracle_maintained='N')
order by 1;


-- ************************************
-- TOBB szintű
-- ************************************
-- A Groupamas ROLE-okat hagyjuk békén, azaz csak Oracle role-okat vonogassunk vissza
-- OBJEKTUM eseten PATH2 visszavon es grantol objektum privit
-- SYS_PRIV eseten lasd lentebb
-- Obj full lista szemrevetelezesre:
select * from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and (path2 in (select role from dba_roles where oracle_maintained='Y') or used_role in (select role from dba_roles where oracle_maintained='Y'))
  and obj_priv is not null;

-- OBJEKTUM PRIVILEGIUMOK ESETEN VISSZAVON es direktet ad
--priv_ana_03_obj_revoke.sql
select distinct
'Revoke ' || path2 || ' from ' || username ||';' the_sql
from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and (path2 in (select role from dba_roles where oracle_maintained='Y') or used_role in (select role from dba_roles where oracle_maintained='Y'))
  and obj_priv is not null
order by 1;

--priv_ana_04_obj_grant.sql
select distinct
'GRANT ' || obj_priv ||' on ' || object_owner || '.' || object_name || ' to ' || username||';' the_sql
from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and (path2 in (select role from dba_roles where oracle_maintained='Y') or used_role in (select role from dba_roles where oracle_maintained='Y'))
  and obj_priv is not null
order by 1;

-- SYS PRIVILEGIUMOK ESETEN 
-- Obj full lista szemrevetelezesre:
select * from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and (path2 in (select role from dba_roles where oracle_maintained='Y') or used_role in (select role from dba_roles where oracle_maintained='Y'))
  and SYS_priv is not null;

-- ITT BARMI LEHETETT VISSZA MIND
--priv_ana_05_sys_revoke.sql
select distinct
'Revoke ' || path2 || ' from ' || username ||';' the_sql
from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and (path2 in (select role from dba_roles where oracle_maintained='Y') or used_role in (select role from dba_roles where oracle_maintained='Y'))
  and SYS_priv is not null
union
select distinct
'Revoke ' || used_role || ' from ' || username ||';' the_sql
from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and used_role in (select role from dba_roles where oracle_maintained='Y')
  and SYS_priv is not null
union
select distinct 
'Revoke ' || SYS_PRIV || ' from ' || username ||';' the_sql
from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and used_role in (select role from dba_roles where oracle_maintained='Y')
  and SYS_priv is not null
order by 1;


-- Itt még kérdesesek a sys-es cuccokra való jog
--priv_ana_06_sys_grant.sql
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
      -- https://docs.oracle.com/database/121/SQLRF/statements_9016.htm#SQLRF01605
	  -- The table or view must be in your own schema, or you must have the LOCK ANY TABLE system privilege, 
	  -- or you must have any object privilege (except the READ object privilege) on the table or view.
	  'LOCK ANY TABLE', 'select ',
      '???:' || sys_PRIV) ||
        ' ON ' || object_owner||'.' ||object_name || ' TO ' || username || ';' as the_sql 
from rk_priv_ana_used 
where path_levels > 1
  and username in (select username from dba_users where oracle_maintained='N')
  and used_role in (select role from dba_roles where oracle_maintained='Y')
  and SYS_priv is not null
order by 1;  

-- MI maradt ki??
select * from rk_priv_ana_used 
where obj_priv is null and sys_priv is null;
/*
RATREPLAY05_PRIV	1	localuser	host	xxx.exe	PUBLIC	PUBLIC			INHERIT PRIVILEGES		KUT	USER		0	SYS.GRANT_PATH('PUBLIC')	RUN1	1	PUBLIC		PUBLIC
RATREPLAY05_PRIV	1	localuser	host	TIP	PUBLIC	PUBLIC			INHERIT PRIVILEGES		KUT	USER		0	SYS.GRANT_PATH('PUBLIC')	RUN1	1	PUBLIC		PUBLIC
*/

-- **********************************
-- NEW Wave analysis - UNUSED ALAPJAN
-- **********************************


conn pa/pa
drop table RK_PRIV_ANA_UNUSED purge;
create table RK_PRIV_ANA_UNUSED tablespace rk_priv_ana as  
select p.* from dba_UNUSED_privs p where 1=2;
alter table RK_PRIV_ANA_UNUSED add path_levels number;
alter table RK_PRIV_ANA_UNUSED add path1 varchar2(128);
alter table RK_PRIV_ANA_UNUSED add path2  varchar2(128);
alter table RK_PRIV_ANA_UNUSED add path_last  varchar2(128);

insert into rk_priv_ana_UNused 
select p.*,
  priv_ana_util.get_path_info(path,0),
  priv_ana_util.get_path_info(path,1),
  priv_ana_util.get_path_info(path,2),
  priv_ana_util.get_path_info(path,-1)
from dba_UNused_privs p
order by username, rolename, object_owner, object_name, object_type
;
commit;

create index KR_priv_ana_unused_syspriv on RK_PRIV_ANA_UNUSED (sys_priv)
tablespace rk_priv_ana;

create table rk_revoke_priv_list  tablespace rk_priv_ana as 
select distinct sys_priv from dba_unused_privs
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
select * from rk_priv_ana_UNused 
where sys_priv  is  not null
  and path_levels=1
  and sys_priv in (select sys_priv
  from rk_revoke_priv_list)
  and username not in (select username from dba_users where oracle_maintained='Y')
order by 1,2,3;

-- priv_ana_07_revoke_unused_level1_direct.sql
select distinct
decode (sys_priv,'UNLIMITED TABLESPACE','--') ||
'Revoke ' || SYS_PRIV || ' from ' || username ||';' the_sql
from rk_priv_ana_UNused 
where sys_priv  is  not null
  and path_levels=1
  and sys_priv in (select sys_priv
  from rk_revoke_priv_list)
  and username not in (select username from dba_users where oracle_maintained='Y')
order by 1;

-- REVOKE NEM HASZNALT LEVEL sok
-- priv_ana_08_revoke_unused_multilevel.sql
select  username, path2, count(1) c from (
select * from rk_priv_ana_UNused 
where sys_priv  is  not null
  and path_levels>1
  and sys_priv in (select sys_priv
  from rk_revoke_priv_list)
  and username not in (select username from dba_users where oracle_maintained='Y')
)
group by username, path2
order by 2,1;
-- kezzel revoke

-- **********************************
-- COMPILE CAPTURE
-- **********************************

-- kulon fileban one_time_privilege_ana.sql


-- **********************************
-- DEPRECATED
-- **********************************
select * from DBA_USED_SYSPRIVS where capture= 'RATREPLAY01_PRIV' order by username, used_role, sys_priv;
select * from dba_used_objprivs where capture= 'RATREPLAY01_PRIV' order by username;
select * from dba_used_privs where capture= 'RATREPLAY02_PRIV' order by username;
select * from dba_used_userprivs where capture= 'RATREPLAY01_PRIV' order by username;


select distinct * from table(get_sysprivs);


-- **********************************
-- USED
-- **********************************
-- If username = used_role then sys_priv was used DIRECTLY without ROLE
select distinct
'revoke ' || SYS_PRIV || ' from ' || username ||';'
from dba_USED_SYSprivs_PATH p
where username=used_role 
and capture= 'RATREPLAY02_PRIV' 
order by 1;

-- If username <> used_role then we need to analyse path
-- and get the second element of varray

select distinct * from table(get_unused_sysprivs) order by 1;
select * from dba_UNUSED_SYSprivs_PATH;


-- AHOL OBJ_PRIV is not null ott van direkt object jogosultsag
-- Ezek nem tom mert jelentek meg az analizisben
-- Ja de tudom, mert a DBA role-t nem is adtuk meg
-- csak a GB61797 client terminalt
select * from dba_used_privs where capture= 'RATREPLAY02_PRIV' 
and obj_priv = 'UPDATE'
order by object_owner, object_name;

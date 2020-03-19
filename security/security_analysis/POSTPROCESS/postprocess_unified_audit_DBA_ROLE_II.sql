
-- PROBLEMA 1
-- Mi van azokkal ahol DBA role-t hasznalunk, *** DE SAJAT OBJEKTUMON  ***
select * 
from RK_UNI_AUD_GROUP_RUN1
where object_schema = current_user;
-- Ezek baromi bonyolultak tudnak lenni. 
-- Pl. SCHEMA1 olvas SCHEMA1al viewt ami hivatkozik SCHEMA1 objektumra.
-- Pl. Egy nagy selectben SCHEMA1 futtat van 8 tabla egyik nem a SCHEMA1-e, de a SCHEMA1 objektum jelenik meg
-- Ezért ezeket kulon vizsgaljuk

-- ONE OFF GRANT ELKESZITESE
-- Itt a furcsakat ki kell kommentezni egyesevel es one-off grantkent kiadni
-- NEM SAJAT OBJEKTUMOS AUDIT
create or replace view rk_UNI_AUD_NOT_YET_KNOWN as
select distinct the_sql, object_schema, object_name, object_type, current_user, action_name, min_sql_id, max_sql_id from (
select  
     'grant '  || 
      decode (system_privilege_used, 
      'DELETE ANY TABLE', 'DELETE ',
      'INSERT ANY TABLE', 'INSERT ',
      'READ ANY TABLE', 'READ ',
      'SELECT ANY TABLE', 'SELECT ',
      'UPDATE ANY TABLE', 'UPDATE ',
      'EXECUTE ANY PROCEDURE', 'EXECUTE ',
      'SELECT ANY DICTIONARY', 'SELECT ',
      'SELECT ANY SEQUENCE', 'SELECT ',
      'MERGE ANY VIEW', ' ??? MERGE ANY VIEW MEG GONDOLKOZNI KELL ',
      '???:' || system_privilege_used) ||
        '          ON ' || r.object_schema||'.' ||r.object_name || ' TO ' || current_user || ';' as the_sql, 
      r.object_schema, r.object_name, o.object_type, current_user, action_name, min_sql_id, max_sql_id 
from RK_UNI_AUD_GROUP_DIST_RUN1 r,
    dba_objects o
where o.object_name = r.object_name and o.owner=r.object_schema and o.object_type <> 'SYNONYM' and o.object_type not like  '%PARTI%'
  and r.object_schema <> current_user
  and r.object_name not in ('X$K2GTE2','PENDING_TRANS$') -- DBA_PENDING_TRANSACTIONS
  and r.object_name not in ('X$KSLED','X$KCCDI2','GV$MYSTAT') -- strange ones
  and r.object_name not in ('X$KCCDI','X$KJIDT','X$KSLWT','X$KSPPCV','X$KSPPI','X$KSUMYST','X$KSUSGIF','X$KVIT','X$KZSPR','X$KZSRO','X$QUIESCE') -- strange ones II
  and r.object_name not like '%subquery%' -- ignore for the moment
  and action_name <> 'EXPLAIN' -- Explain plan PRIV ana lehet
  and r.action_name not in ('DELETE','INSERT') -- There were only 6 records I did them manually.  
  and (system_privilege_used <> 'SELECT ANY TABLE, EXECUTE ANY PROCEDURE' or system_privilege_used is null)
  and (system_privilege_used <> 'SELECT ANY TABLE, SELECT ANY DICTIONARY' or system_privilege_used is null)
  and (system_privilege_used <> 'UPDATE ANY TABLE, EXECUTE ANY PROCEDURE' or system_privilege_used is null)
  and (system_privilege_used <> 'MERGE ANY VIEW' or system_privilege_used is null)
 order by current_user, r.object_schema, r.object_name, system_privilege_used
)
where the_sql like '%???%';


--237
select * from rk_UNI_AUD_NOT_YET_KNOWN
order by 2,3,4;

-- NOT YET KNOWN WITH OBJECT TYPE
select notyet.* , o.object_type
from 
rk_UNI_AUD_NOT_YET_KNOWN notyet
left outer join dba_objects o
on o.owner= notyet.object_schema and 
   o.object_name = notyet.object_name
where o.object_type not like '%PARTITION%' or o.object_type is null
order by 2,3;

-- MIUTAN MAR MINDEN FURA KIOLVE JOHETNEK A GRANTOK
-- ONE OFF GRANT UTAN MEG MINDIG A KERDOJELESEK
-- GENERALASA
select distinct 'grant select on ' || object_schema|| '.' ||object_name || ' to '|| current_user ||';'
from rk_UNI_AUD_NOT_YET_KNOWN
where object_schema not in ('SYS') and action_name = 'SELECT'
order by current_user, object_schema, object_name;


-- BASIC ez a lagutolso
-- view feltetelek copy paste ide
select distinct the_sql, object_schema, object_name, current_user, action_name from (
select  
     'grant '  || 
      decode (system_privilege_used, 
      'DELETE ANY TABLE', 'DELETE ',
      'INSERT ANY TABLE', 'INSERT ',
      'READ ANY TABLE', 'READ ',
      'SELECT ANY TABLE', 'SELECT ',
      'UPDATE ANY TABLE', 'UPDATE ',
      'EXECUTE ANY PROCEDURE', 'EXECUTE ',
      'SELECT ANY DICTIONARY', 'SELECT ',
      'SELECT ANY SEQUENCE', 'SELECT ',
      'MERGE ANY VIEW', ' ??? MERGE ANY VIEW MEG GONDOLKOZNI KELL ',
      '???:' || system_privilege_used) ||
      '          ON ' || object_schema||'.' ||object_name || ' TO ' || current_user || ';' as the_sql, object_schema, object_name, current_user, action_name
from RK_UNI_AUD_GROUP_RUN1 r
where object_schema <> current_user
  and r.object_schema <> current_user
  and r.object_name not in ('X$K2GTE2','PENDING_TRANS$') -- DBA_PENDING_TRANSACTIONS
  and r.object_name not in ('X$KSLED','X$KCCDI2','GV$MYSTAT') -- strange ones
  and r.object_name not in ('X$KCCDI','X$KJIDT','X$KSLWT','X$KSPPCV','X$KSPPI','X$KSUMYST','X$KSUSGIF','X$KVIT','X$KZSPR','X$KZSRO','X$QUIESCE') -- strange ones II
  and r.object_name not like '%subquery%' -- ignore for the moment
  and action_name <> 'EXPLAIN' -- Explain plan PRIV ana lehet
  and r.action_name not in ('DELETE','INSERT') -- There were only 6 records I did them manually.  
  and (system_privilege_used <> 'SELECT ANY TABLE, EXECUTE ANY PROCEDURE' or system_privilege_used is null)
  and (system_privilege_used <> 'SELECT ANY TABLE, SELECT ANY DICTIONARY' or system_privilege_used is null)
  and (system_privilege_used <> 'UPDATE ANY TABLE, EXECUTE ANY PROCEDURE' or system_privilege_used is null)
  and (system_privilege_used <> 'MERGE ANY VIEW' or system_privilege_used is null)
  -- 
  and   object_schema not in ('SYS','SYSTEM')
)
where the_sql NOT like '%???%'
order by 1;

----- 04 DO THE WORK ELEMZES azok akik magukra mutatnak
select * from RK_UNI_AUD_GROUP_RUN1
where action_name in ('INSERT','SELECT','UPDATE','DELETE') AND OBJECT_SCHEMA=CURRENT_USER


exec pa.RK_GRANT_STRING_ANA.DO_THE_WORK;
commit;

select count (distinct sql_id)
from RK_UNI_AUD_GROUP_RUN1
where action_name in ('INSERT','SELECT','UPDATE','DELETE') AND OBJECT_SCHEMA=CURRENT_USER;


--select to_char(substr(sql_from_clause,1,80)) su from (
select 
action_name, system_privilege_used, object_schema as obj_sch, object_name as obj_name,
current_user as curr, sql_id, sql_text, SQL_FROM_CLAUSE, SQL_TEXT_EXP, SQL_FROM_CLAUSE_EXP
from RK_UNI_AUD_GROUP_RUN1
where action_name in ('INSERT','SELECT','UPDATE','DELETE') 
      AND OBJECT_SCHEMA=CURRENT_USER
and sql_id not in ('02m8zxf5hmtnr','4bkqq328y8px4','78nnrk610dg28','9mt8b3pk3sngg','4v4bpdkt92y5u','4qbq6kngrjcj4',
    '57rgqkk3860b5','7c5g9rbd5qwm1','9qmk8w7mcb4c4','9vad4hkk4mxy5','5f1ap96d0hpmf','g6p7qzpwfsxqb','44f42u60391za','5mf35vg9vtx24','1n78xtc4021hh','11u5kvbb120tk',
    '7ksczh9vnv2k3','8j0y26jpxqcn8','a4s81x0x3baym','888dqd394v11u','5svpbxs4aj2fg','gdwvasm33hwx5','3g38ptb6hnxqh','50kj3mxc3wvxm','7pq9w37cncvz4','a4c0r3af0u2u3','aaptdgb096gfu','ddnvv9y2phj88'
)
and not (sql_text like '%sph_munkanapig%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
and not (sql_text like '%sph_kod_nev%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
and not (sql_text like '%stringcsere%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
and not (lower(sql_text) like '%coverv01%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
and not (lower(sql_text) like '%pomcs.genber1%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
and not (lower(sql_text) like '%SCHEMA1folio_admin.get_hash%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
...
order by object_schema, sql_id
--order by TO_CHAR(SUBSTR(SQL_FROM_CLAUSE,1,25))
--)
;

-- SZOVEG FILTER
select 
action_name, system_privilege_used, object_schema as obj_sch, object_name as obj_name,
current_user as curr, sql_id, sql_text, SQL_FROM_CLAUSE, SQL_TEXT_EXP, SQL_FROM_CLAUSE_EXP
from RK_UNI_AUD_GROUP_RUN1
where 1=1 
and (lower(sql_text) like lower('%&szoveg%') or lower(sql_text_exp) like lower('%&szoveg%'))
--and (lower(sql_text) like '%SCHEMA1folio_admin.get_hash%' and system_privilege_used = 'EXECUTE ANY PROCEDURE' )
and object_schema=current_user;

--SQLID FILTER
select 
action_name, system_privilege_used, object_schema as obj_sch, object_name as obj_name,
current_user as curr, sql_id, sql_text, SQL_FROM_CLAUSE, SQL_TEXT_EXP, SQL_FROM_CLAUSE_EXP
from RK_UNI_AUD_GROUP_RUN1
where 1=1 
and sql_id = '&sqlid'
and object_schema=current_user;

-- SQL FILTER DETAILS
select d.sessionid, d.* from RK_UNI_AUD_DETAIL_RUN1 d where sql_id ='&sqlid' 
order by 1, 2;


select * from dba_objects where object_name = upper('&oname')
;

select * from dba_synonyms where synonym_name = upper('&syn');
;



--- 05 Mi van az execute action-okkal
select distinct action_name, current_user, object_schema, object_name, to_char(substr( sql_text, 1,35) )
from RK_UNI_AUD_GROUP_RUN1
where action_name not in ('INSERT','SELECT','UPDATE','DELETE') 
and action_name = 'EXECUTE'
and object_name is not null
order by 1,2,3,4;


select distinct 
'grant execute on ' || object_schema || '.' || object_name  || ' to ' || current_user || ';'  
from RK_UNI_AUD_GROUP_RUN1
where action_name not in ('INSERT','SELECT','UPDATE','DELETE') 
and action_name = 'EXECUTE'
and object_name is not null
order by 1;


-- 06  sajat szinonyma legyen grantositva
------------------------------------------------------

-- DEBUG transaction
select distinct object_name, current_user
from RK_UNI_AUD_DETAIL_RUN1
where 
  object_name in ('X$K2GTE2','PENDING_TRANS$')
;

grant select on dba_pending_transactions to bm_feladas;

-- DEBUG X$ and strange objects
-- v$session, v$database, v$mystat
select * from RK_UNI_AUD_DETAIL_RUN1
where (
  (object_name = 'X$KSLED') or
  --(object_name = 'X$KCCDI2') or
  --(object_name = 'GV$MYSTAT') or
  1=2)
 -- and (sql_text not like '%SESSION%')
 -- and (sql_text not like '%MYSTAT%')
--  and (sql_text not like '%DATABASE%')
  ;

/*
SCHEMA1	X$KSLED
POMCS	X$KCCDI2
SCHEMA1	GV$MYSTAT
GEPJARMU_KAR	X$KCCDI2
SCHEMA1	X$KCCDI2
*/
select distinct current_user , object_name
from RK_UNI_AUD_DETAIL_RUN1
where (
  (object_name = 'X$KSLED') or
  (object_name = 'X$KCCDI2') or  --v$database
  (object_name = 'GV$MYSTAT') )
  ;


-- debug strange objects II

grant ???:          ON SYS.X$KCCDI TO SCHEMA;

select * from RK_UNI_AUD_DETAIL_RUN1
where (
  --(object_name = 'X$KCCDI') or -- v$database
  --(object_name = 'X$KJIDT') or -- v$instance
  --(object_name = 'X$KSLWT') or -- v$session
  --(object_name = 'X$KSPPCV') or -- GSMADMIN_INTERNAL.cloud
  --(object_name = 'X$KSPPI') or -- GSMADMIN_INTERNAL.cloud
 -- (object_name = 'X$KSUMYSTA') or  -- v$mystat
  --(object_name = 'X$KSUSGIF') or ---- v$mystat
 -- (object_name = 'X$KVIT') or -- v$instance
 -- (object_name = 'X$QUIESCE') or -- v$instance
  (object_name = 'X$KZSPR') or  
  (object_name = 'X$KZSRO') or
  (object_name = 'X$') or
  (object_name = 'X$') or  
  1=2)
  order by object_name;

select distinct object_name, current_user
 from RK_UNI_AUD_DETAIL_RUN1
where (

  (object_name = 'X$KCCDI') or -- v$database POMCS, GEPJARMU_KAR    -- tobbi SCHEMA1
  (object_name = 'X$KJIDT') or -- v$instance
  (object_name = 'X$KSLWT') or -- v$session
  (object_name = 'X$KSPPCV') or -- GSMADMIN_INTERNAL.cloud
  (object_name = 'X$KSPPI') or -- GSMADMIN_INTERNAL.cloud
  (object_name = 'X$KSUMYSTA') or  -- v$mystat
  (object_name = 'X$KSUSGIF') or ---- v$mystat
  (object_name = 'X$KVIT') or -- v$instance
  (object_name = 'X$QUIESCE') or -- v$instance
  (object_name = 'X$KZSPR') or  
  (object_name = 'X$KZSRO') or
  (object_name = 'X$') or
  (object_name = 'X$') or  
  1=2);


-- DEBUG subquery
select *
-- distinct object_name, current_user
 from RK_UNI_AUD_DETAIL_RUN1
where 
  (object_name like '%subquery%')
;


-- debug grant ???:SELECT ANY TABLE, EXECUTE ANY PROCEDURE          ON POMCS.BEALA TO SCHEMA1;
select *
-- distinct object_name, current_user
 from RK_UNI_AUD_DETAIL_RUN1
where system_privilege_used = 'SELECT ANY TABLE, EXECUTE ANY PROCEDURE'
  --(object_name like '%subquery%')
;




-- DEBUG VIEW MERGE
select * from RK_UNI_AUD_DETAIL_RUN1
where system_privilege_used = 'MERGE ANY VIEW'
and SQL_TEXT not like '%SZ_BANKSZAMLA%';

select owner, object_name, object_type 
from dba_objects
where object_name in ('SZEMELY','S_SZEREP','SZERZODES','KARSZAM');
szemely sz2, s_szerep szer1, SZERZODES, KARSZAM
modozat, szemely sz2, s_szerep szer1, SZERZODES, KARSZAM

-- DEBUG VIEW MERGE RUN2
select * from RK_UNI_AUD_DETAIL_RUN1 where sql_id in ('fs0ttggt3brc3','fs0ttggt3brc3','2k19ukv8pas4s','fz9vc75drnx4c','75wxj2qyjqzxg','38m00j4tfraj7');

-- DEBUG OBJ$, SEG$
select *
--distinct object_name, current_user
 from RK_UNI_AUD_DETAIL_RUN1
where (
  (object_name = 'IND$') or -- 
  (object_name = 'OBJ$') or -- 
  (object_name = 'SEG$') or -- 
1=2
);


--- DEBUG general
select * from RK_UNI_AUD_DETAIL_RUN1
where object_name  = 'OBJ1' and current_user = 'SCHEMA1' and system_privilege_used  is null
;

select * from RK_UNI_AUD_GROUP_RUN1;
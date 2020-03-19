-- A letezo DEPENDENCYk és SYNONYMAk alapjan objektum GRANT-ok kiadasa a cél ezzel az elemzéssel

-- A 2. módszer A DBA_DEPENDENCIES-en alapul.
-- CÉL az alkalmazás sémák által létrejött objektum függőségekből grantok generálása
-- Azért volt erre a módszerre szükség, mert 
--  Run-time analízis baromi sok invalid objektumot hagyott maga után, tehát statikus elemzésre szükség van
--  és a barom privilege analysis nem képes synonyms feltérképezésére 19.3-ban. Lásd: POC_priv_ana_synonymon_keresztul.sql
--  és _UGYFEL_-ban annyi szinonima van mint égen a csillag

-- Fontos gondolatok:
  -- DBA DEPENDENCIES tartalmaz ilyen objektumokat: VIEW, TABLE, TYPE, SYNONYM, PACKAGE, PROCEDURE ... stb
  -- DBA_USERS-ben nem létezik a PUBLIC

-- Gondot okoznak
  -- 1)
  -- rk_ana_dependencies-be 60k rekord került és indexekkel együtt is le kellett lőnöm a hierarchikus lekérdezést, mely felállítja a hierarchiát
  -- Ezért töröltem a rekordokat (függőségeket), melyek egy sémán belüliek (objekt = referenced objekt) és nem szinonímák.
  -- Ezzel a lépéssel egy hosszabb függőségi lánc esetleg megtörik, de a maradék 15k rekordra másodperc tört része alatt lehet hierarchiát készíteni
  -- TODO: Tesztelendő, hogy így a fordítási hibák lényegesen csökkenthetőek-e.
  
  -- 2)
  -- Még nagyobb gond, hogy történelmi okok miatt a _UGYFEL_-ban bevett szokás volt minden objektumra szinonímák gyártása (pontos részletek nem ismertek)
  -- ! akkor is ha esetleg nem volt valódi igény a target objektumhoz hozzáférésre ! (ezt mind a fejlesztői, mind az üzemeltetési csoport megerősítette)
  -- Ennek azonban az az eredménye, hogy a statikus, függőségek alapján GRANT-ok kiadása felesleges objektum szintű hozzáférések kiadását jelentené, melyet
  -- sem az üzemeltetés, sem a fejlesztés sem a Remedios nem támogat.
  
-- Következmény
  -- Statikus elemzéssel nem tudjuk támogatni a PROD környezetben a magas jogok visszavételét.
  -- Más projektekben az itteni tanulságok, scriptek még hasznosak lehetnek.

-- TODO: más szituációban, más projekten végig vinni az elemzést
  
-- ************************
-- 2. GENERATION MÓDSZER
-- ************************
-- A módszer az DBA_dependencies-en alapul
-- Azt is figyelembe vesszük, hogy A.table -> B.view -> C selectál esetben 
--   C a B.view-ra kap select grant-ot, de B usernek grant option-nel kell adni select grant-ot A.table-re.
conn pa/pa

-- csak nézegetésre
select * from dba_dependencies  
where 1=2
and (referenced_owner NOT in (select username from dba_users where oracle_maintained = 'Y'))
and (owner            NOT in (select username from dba_users where oracle_maintained = 'Y'))
order by 1,2,4,5;

drop table rk_ana_dependencies purge;
create table rk_ana_dependencies as
select owner, name, type, referenced_owner, referenced_name, referenced_type, dependency_type, 0 as is_it_root 
from 
(
    -- USER semmabol user semaba
    select * from dba_dependencies  
    where 1=1
      and (referenced_owner NOT in (select username from dba_users where oracle_maintained = 'Y'))
      and (owner            NOT in (select username from dba_users where oracle_maintained = 'Y'))
      -- PUBLIC is NOT present DBA USERS
      and owner NOT in ('PUBLIC')
      and referenced_owner NOT in ('PUBLIC')
    UNION ALL
    (
        -- USERBOL SYS-be. pl. a V_$DATABASE-t lehet, hogy valaki használja a kódban.
        select * from dba_dependencies  
        where 1=1
          and owner NOT in ('PUBLIC')
          and referenced_owner NOT in ('PUBLIC')
          and (owner            NOT in (select username from dba_users where oracle_maintained = 'Y'))
          and (referenced_owner     in (select username from dba_users where oracle_maintained = 'Y'))
        MINUS
        -- USERBOL SYSBE, ahol a SYS-nek van PUBLIC GRANTja
		-- Igy tudjuk kiszűrni pl. a DBMS_STANDARDra való rekordokat
        select dep.* from dba_dependencies dep, 
               dba_tab_privs priv
        where 1=1
          and dep.owner NOT in ('PUBLIC')
          and dep.referenced_owner NOT in ('PUBLIC')
          and (dep.owner            NOT in (select username from dba_users where oracle_maintained = 'Y'))
          and (dep.referenced_owner in (select username from dba_users where oracle_maintained = 'Y'))
          and dep.referenced_owner = priv.owner
          and dep.referenced_name = priv.table_name
          and priv.grantee = 'PUBLIC'
    )
);

-- HIERARCHIA FELÉPÍTÉSE
-- (lehet, hogy pont fordítva kéne felépíteni ezt a gráfot. Így azt tudjuk meg, hogy egy objektumot kik használnak. Fordítva azt tudnánk, hogy egy objektum felépítéséhez milyen objektumra van szükség
--  javasokt nevek: RK_STATANA_ROOTOBJ_USEDBY, fordított megközelítés lenne: RK_STATANA_ROOTOBJ_NEEDS
-- A REFERENCED OBJEKTUM FELŐL közelítem meg a dolgot. A ROOT minden olyan objektum lehet, amire hivatkoznak. 
-- Az fa branch és levél blokkjai hivatkoznak közvetlen a vagy közvetve a root objektumra.


-- RK_STATANA_ROOTOBJ_USEDBY FELEPÍTESE
create table RK_STATANA_ROOTOBJ_USEDBY as select * from rk_ana_dependencies;
-- Vegyuk hozza ROOT kent a NEM szinonima REFERENCED OBJEKT-eket
-- Hiszen egyedul a szinoníma típus az, ami nem lehet egy lánc elején.
insert into RK_STATANA_ROOTOBJ_USEDBY (
select distinct referenced_owner, referenced_name, referenced_type, null, null,null,null, 1 as is_it_root
-- ATGONDOLNI MEGESZER nem ez kéne
-- select distinct null, null,null,referenced_owner, referenced_name, referenced_type, null, 1 as is_it_root
from RK_STATANA_ROOTOBJ_USEDBY
where 1=1
  and referenced_type NOT in ('SYNONYM')
);
commit;
select * from RK_STATANA_ROOTOBJ_USEDBY;

delete from RK_STATANA_ROOTOBJ_USEDBY 
where referenced_name = 'SYS_STUB_FOR_PURITY_ANALYSIS';
commit;

alter table RK_STATANA_ROOTOBJ_USEDBY modify (owner NOT null);
alter table RK_STATANA_ROOTOBJ_USEDBY modify (name NOT null);
alter table RK_STATANA_ROOTOBJ_USEDBY modify (is_it_root NOT null);

create index i_ana_dep_own on RK_STATANA_ROOTOBJ_USEDBY (owner, name);
create index i_ana_dep_ref on RK_STATANA_ROOTOBJ_USEDBY (referenced_owner, referenced_name);
create index i_ana_dep_root on RK_STATANA_ROOTOBJ_USEDBY (is_it_root);

alter table RK_STATANA_ROOTOBJ_USEDBY add (owner_cnt number);
alter table RK_STATANA_ROOTOBJ_USEDBY add (referenced_owner_cnt number);

-- Törő törlés
-- Enélkül kb soha nem futott le a _UGYFEL_ PROD-on a hierarchikus query alabb
delete from RK_STATANA_ROOTOBJ_USEDBY
where owner=referenced_owner and type <>'SYNONYM'
;


-- Csinaljunk hierarchikus tablat
create table RK_STATANA_ROOTOBJ_USEDBY_hier as
select owner, name, type, referenced_owner as ref_own, referenced_name as ref_name, referenced_type,-- dependency_type,
connect_by_root owner root_owner,
connect_by_root name  root_name,
connect_by_root type  root_type,
connect_by_isleaf as this_is_leaf,
CONNECT_BY_ISCYCLE as this_causes_cycle,
level as d_level
from RK_STATANA_ROOTOBJ_USEDBY
start with is_it_root = 1
connect by  NOCYCLE
            referenced_name = prior name 
    and     referenced_owner = prior owner
order by root_owner, root_name,level;

create index i_ana_deph_own on RK_STATANA_ROOTOBJ_USEDBY_hier (owner);
create index i_ana_deph_ref on RK_STATANA_ROOTOBJ_USEDBY_hier (ref_own, ref_name);
create index i_ana_deph_root on RK_STATANA_ROOTOBJ_USEDBY_hier (is_it_root);

ref_own
--******************************************
-- ES MEHENEK A GRANTOK
--******************************************


-- Sima egyszintu select
-- TODO: select vagy execute grant
-- root-tol fugg, hogy mi legyen a TYPE
select distinct 'grant '
    || decode (root_type, 
    'SEQUENCE'  ,' SELECT ', 
    'MATERIALIZED VIEW'  ,' SELECT ',     
    'TABLE'  ,' SELECT ',   
    'VIEW'  ,' SELECT ',      
    'PROCEDURE' ,' EXECUTE ',
    'PACKAGE' ,' EXECUTE ',    
    'FUNCTION' ,' EXECUTE ',
    'TYPE' ,' EXECUTE ',
    'TYPE BODY' ,' EXECUTE ',
    '??? '||root_type ) ||
  ' on ' || ref_own || '.' || ref_name || ' to ' || owner || ';'  the_sql
from RK_STATANA_ROOTOBJ_USEDBY_HIER
where 1=1
  and owner <> ref_own
-- and owner <> 'PUBLIC'
--and root_owner <> owner
  and ref_name is NOT null
order by 1;

-- Grant option kell a 2 szinthez
-- Tovabbadas eseten grant option kell 2 szintet eleg
select distinct 'grant ' || decode (c.root_type, 
    'SEQUENCE'  ,' SELECT ', 
    'MATERIALIZED VIEW'  ,' SELECT ',     
    'TABLE'  ,' SELECT ',   
    'VIEW'  ,' SELECT ',      
    'PROCEDURE' ,' EXECUTE ',
    'PACKAGE' ,' EXECUTE ',    
    'FUNCTION' ,' EXECUTE ',
    'TYPE' ,' EXECUTE ',
    'TYPE BODY' ,' EXECUTE ',
    '??? '||c.root_type ) ||
   ' on ' || c.ref_own || '.' || c.ref_name || ' to ' || c.owner || ' with grant option;'  the_sql
   ,c.*, f.*
from RK_STATANA_ROOTOBJ_USEDBY_HIER f, RK_ANA_DEPENDENCIES_HIER c
where 
-- join
   f.ref_own = c.owner and f.ref_name = c.name
-- semak kozt van a lanc vege
and c.ref_own<>c.owner
-- semak kozt van a lanc eleje
and f.ref_own <> f.owner
--where owner <> 'PUBLIC'
--and root_owner <> owner
 -- and ref_name is NOT null
and c.type <> 'SYNONYM'
order by 1;


/*
-- ************************
-- ElSO, DEPRECATED MODSZER
-- ************************
-- A gond az, hogy több szintű függőséget nem kezel
-- Ezért sokkal általánosabb megoldás kell

-- What kind of grants do we have
-- Inner select: what are those synonyms
select distinct object_type from (

select s.* , o.object_type
from dba_synonyms s, dba_objects o
where s.table_owner=o.owner 
    and s.table_name = o.object_name
    and o.object_type NOT in ('PACKAGE BODY','TYPE BODY')
    and o.object_type NOT like ('%PARTITION%')
    and s.owner in
    (select username from dba_users
        where oracle_maintained = 'N')
    and db_link is null
    and s.owner <> table_owner
  
    )
    ;

   
-- Generate the grants
select 'grant ' ||
decode (object_type, 
    'SEQUENCE'  ,' SELECT ', 
    'MATERIALIZED VIEW'  ,' SELECT ',     
    'TABLE'  ,' SELECT ',   
    'VIEW'  ,' SELECT ',      
    'SYNONYM'  ,' SELECT ',  
    'PROCEDURE' ,' EXECUTE ',
    'PACKAGE' ,' EXECUTE ',    
    'FUNCTION' ,' EXECUTE ',
    'TYPE' ,' EXECUTE ',
    'TYPE BODY' ,' EXECUTE '
)
|| ' on ' || table_owner || '.' || table_name  || ' to ' || owner || ';'  
from 
    ( select s.* , o.object_type
    from dba_synonyms s, dba_objects o
    where s.table_owner=o.owner 
        and s.table_name = o.object_name
        and o.object_type NOT in ('PACKAGE BODY','INDEX', 'TRIGGER')
        and o.object_type NOT like ('%PARTITION%')
        and s.owner in
        (select username from dba_users
            where oracle_maintained = 'N')
        and db_link is null
        and s.owner <> table_owner);
		
*/		

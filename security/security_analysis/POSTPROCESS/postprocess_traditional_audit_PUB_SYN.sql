-- The list of actions where someone was accessing object of other schema
-- CAP01_REP02_SECURITY 108404 rekord
-- CAP01_REP03_SECURITY 236404 rekord
-- CAP01_REP04_SECURITY 109553 rekord - de nem public synonymahoz tartoznak
-- CAP01_REP05 PRIVANA2  74016 rekord -
select at.object_schema, at.object_name, at.current_user, to_char(extended_timestamp,'YYYYMMDD HH24:MI') ts, sql_text, sql_bind ,db_user,
at.* from V$XML_AUDIT_TRAIL at
where current_user <> object_schema
  and extended_timestamp > to_date('20191001 14:48','YYYYMMDD HH24:MI');


-- Ezzel a KET selecttel kell legeneralni a
-- create synonym utasitasokat es a hozza tartozo drop public synonym utasitasokat
-- REPLAY 03 elott meg kene tenni a drop-ot is.
-- Ez a jelenleg letezo PUBLIC SYNONYM-okat es az audit rekordokat veszi figyelembe.
-- REPLAY 04 re eljutottunk oda, hogy nincs ilyen rekord!!!

-- trad_aud_01_create_synonym_instead_of_public.sql
-- trad_aud_02_drop_public_synonym.sql
select
distinct 'create synonym ' ||current_user || '.' || sy.synonym_name || ' for ' || object_schema || '.' || object_name ||';'
--distinct 'drop public synonym '|| sy.synonym_name || ';'
from dba_synonyms sy, V$XML_AUDIT_TRAIL at
where 
  sy.table_owner = at.object_schema and
  sy.table_name = at.object_name and
  sy.owner='PUBLIC' and 
  sy.table_owner in (select username from dba_users where oracle_maintained = 'N') 
  and current_user<>object_schema 
  and extended_timestamp > to_date('20191001 14:48','YYYYMMDD HH24:MI')
  and terminal = 'GB61797'
order by 1;

-- NOT USED PUBLIC SYNONYMS, but USED TARGET OBJECT	
-- TARGET OBJECT WAS USED BY THE OWNER. THAT is WHY we have audited entry
-- current_user=object_schema
-- megfontolando a drop public synonym
-- trad_aud_03_drop_unused_public_synonym.sql
select
distinct 'drop public synonym '|| sy.synonym_name || ';'
from dba_synonyms sy, V$XML_AUDIT_TRAIL at
where 
  sy.table_owner = at.object_schema and
  sy.table_name = at.object_name and
  sy.owner='PUBLIC' and 
  sy.table_owner in (select username from dba_users where oracle_maintained = 'N') 
  and current_user=object_schema 
  and extended_timestamp > to_date('20191001 14:48','YYYYMMDD HH24:MI')
  and terminal = 'GB61797'
order by 1;


-- Maradek rekord kezi elemzese
-- Leginkabb sys bejegyzeseket talaltam
select at.object_schema, at.object_name, at.current_user, to_char(extended_timestamp,'YYYYMMDD HH24:MI') ts, sql_text, sql_bind ,db_user,
at.* from V$XML_AUDIT_TRAIL at
where 1=1
  and (current_user is null or object_schema is null)
  and current_user <>'SYS'
  and extended_timestamp > to_date('20191001 14:48','YYYYMMDD HH24:MI');


-- *****************************************************************************************************
---------------- Just some SQL that were used...
select * from dba_synonyms
where 1=1
--and owner='PUBLIC' 
and table_name = 'PBCATTBL'
;

select * from dba_objects where object_name ='PBCATTBL';


select * from DBA_OBJ_AUDIT_OPTS where object_name = 'PBCATTBL';
select * from DBA_PRIV_AUDIT_OPTS;
select * from DBA_STMT_AUDIT_OPTS;
audit synonym;

select 'noaudit ' || audit_option || ';' from DBA_STMT_AUDIT_OPTS order by 1;


select
distinct 'create synonym ' ||current_user || '.' || object_name || ' for ' || object_schema || '.' || object_name
from V$XML_AUDIT_TRAIL
where current_user<>object_schema;

select rpad('&no_or_null' || 'audit all on ' || synonym_name || ';',50)  as the_command ,
 ' --' || table_owner || '.' || table_name as target,
 case when synonym_name <> table_name then 'MAS A NEV !!!!' end as warrning;
select * 
from dba_synonyms
where owner='PUBLIC' and table_owner in (
  select username 
  from dba_users
  where oracle_maintained = 'N')
order by table_owner, table_name;
 

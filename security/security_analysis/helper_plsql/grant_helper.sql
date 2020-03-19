-- Ezek a select-ek segitenek egy-egy hianyzo grant megerteseben
-- INVALID COMPILE-ban.
-- PA a technikai user akit hasznalunk az analizishez.

-- Find
-- system
select * from dba_objects where lower(object_name) like lower('%&obj%') order by 1,2;	
select * from dba_synonyms where lower(synonym_name) like lower('%&syn%');
select * from dba_tab_privs where lower(table_name) like lower('%&obj%');


-- PA
select count(1) from dba_objects curr where status ='INVALID' ;

select * from dba_objects curr where status ='INVALID' 
and not exists (select * from pa.rk_invalid_objects_pre_test pre where curr.owner=pre.owner and curr.object_name = pre.object_name)
--DB LINKES
and object_name not in ('xxx')
order by 1,2,3;


-- COMPILE utasitasok generalasa
select 'alter package ' || owner ||'.' || object_name || ' compile;' the_sql
from (
select * from dba_objects curr where status ='INVALID' 
and not exists (select * from pa.rk_invalid_objects_pre_test pre where curr.owner=pre.owner and curr.object_name = pre.object_name)
--DB LINKES
and object_name not in ('xxx')
)
where object_type like ('PACKAG%')
UNION
select 'alter ' || OBJECT_TYPE || ' '|| owner ||'.' || object_name || ' compile;' the_sql
from (
select * from dba_objects curr where status ='INVALID' 
and not exists (select * from pa.rk_invalid_objects_pre_test pre where curr.owner=pre.owner and curr.object_name = pre.object_name)
--DB LINKES
and object_name not in ('xxx'))
where object_type in ('FUNCTION','TRIGGER','PROCEDURE','VIEW')
order by 1;

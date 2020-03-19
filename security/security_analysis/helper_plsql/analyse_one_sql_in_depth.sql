select * from dba_workload_replays;
select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_TAB_AUDIT_OPTS;

select * from DBA_PRIV_AUDIT_OPTS;
select * from DBA_OBJ_AUDIT_OPTS;


select * from DBA_OBJ_AUDIT_OPTS;
select * from unified_audit_trail;


select * from DBA_USED_OBJPRIVS;
DBA_USED_OBJPRIVS_PATH;


select * from DBA_UNUSED_SYSPRIVS;
select * from DBA_UNUSED_SYSPRIVS_PATH;
select * from DBA_used_SYSPRIVS_PATH where username = 'SCHEMA66';

select * from DBA_UNUSED_PRIVS where username = 'SCHEMA2';
select * from DBA_USED_PRIVS where username = 'SCHEMA2'; 

select * from DBA_USED_PUBPRIVS;

select * from dba_tab_privs where grantee='PUBLIC' and owner in (select username from dba_users where oracle_maintained='N')
order by 1,2,3;

select * from dba_role_privs where grantee='PUBLIC' ;
and owner in (select username from dba_users where oracle_maintained='N')
order by 1,2,3;

select * from auditable_object_actions;


select * from dba_objects where object_name = 'erzsi';

select * from v$sql where sql_id= 'a4c0r3af0u2u3';
select * from sys.dba_hist_reSCHEMA2s where key1= 'a4c0r3af0u2u3';

-- 1 SQL GROUP
-- a4c0r3af0u2u3
select 
action_name, system_privilege_used, object_schema as obj_sch, object_name as obj_name,
current_user as curr, sql_id, sql_text, SQL_FROM_CLAUSE, SQL_TEXT_EXP, SQL_FROM_CLAUSE_EXP
from RK_UNI_AUD_GROUP_RUN1
where 1=1 
and sql_id = '&sqlid'
--and object_schema=current_user;
;


-- DETAIL
select d.sessionid, d.* from RK_UNI_AUD_DETAIL_RUN1 d where sql_id ='&sqlid' 
and statement_id = '23070'
order by 1, 2;

select * from dba_objects where object_name = upper('&oname');

select * from dba_synonyms where synonym_name = upper('&syn');;

select * from dba_tab_privs where table_name = upper('&object');

select * from DBA_USED_PRIVS where object_name = 'MV_BKL_TB_ALLAMPOLGARSAG_KOD' or sys_priv ='SELECT ANY TABLE';

select * from dba_db_links;

-- megtudtuk
-- policy alapu unified audit tobb adatot tarol, mint amit kertunk, hogy jobban utána lehessen nézni. Teljes kép szerepel
-- Generalni nem tudunk belole, mert egyes rekordok nem teljesek, önnmagukban nem értelmezhetőek

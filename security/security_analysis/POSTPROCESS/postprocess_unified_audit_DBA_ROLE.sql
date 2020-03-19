

CONN pa/pa

-- create summary table on rk_priv_ana tablespace
-- This table contains all SQL_IDs
drop table RK_UNI_AUD_GROUP_RUN1 purge;
create table RK_UNI_AUD_GROUP_RUN1 tablespace rk_priv_ana as    
select count(1) cnt, action_name, system_privilege_used, object_schema, object_name,
  current_user, unified_audit_policies, sys.compute_sql_id(sql_text) sql_id,
  min(event_timestamp) mints, max(event_timestamp) maxts
from 
    (select ut.* from unified_audit_trail ut
    where os_username = 'localuser' 
    and current_user <> 'DBSNMP'
    --and sessionid = 1956759846
    --fetch first 5000 rows only
    )
group by action_name, system_privilege_used, object_schema, object_name, current_user, unified_audit_policies, 
  sys.compute_sql_id(sql_text)
order by 2,3,4
;

create index KR_AUD_GROUP_sqlid on RK_UNI_AUD_GROUP_RUN1 (sql_id)
tablespace rk_priv_ana;



-- GROUP_dist
-- This table contains only 2 sql_ids for the group
-- This table will contain the sql texts as well
drop table RK_UNI_AUD_GROUP_DIST_RUN1 purge;
create table RK_UNI_AUD_GROUP_DIST_RUN1 tablespace rk_priv_ana as    
select sum(cnt) cnt, action_name, system_privilege_used, object_schema, object_name,
  current_user, unified_audit_policies, min(sql_id) min_sql_id, max(sql_id) max_sql_id,
  min(mints) mints, max(maxts) maxts
from RK_UNI_AUD_GROUP_RUN1
group by action_name, system_privilege_used, object_schema, object_name,
  current_user, unified_audit_policies;


-- create details table
-- This table is for detailed analysis
drop table RK_UNI_AUD_DETAIL_RUN1 purge;
create table RK_UNI_AUD_DETAIL_RUN1 tablespace rk_priv_ana  as    
select event_timestamp, system_privilege_used, unified_audit_policies, object_schema, object_name, 
  return_code, sys.compute_sql_id(sql_text) sql_id,  sql_text, sql_binds,
  sessionid, os_username, dbusername, current_user, target_user, role,
  client_program_name, entry_id, statement_id, 
  action_name, os_process, scn, execution_id
from unified_audit_trail
where os_username = 'localuser' 
    and current_user <> 'DBSNMP'
--fetch first 500 rows only
;

create index KR_AUD_DETAIL_SESS on RK_UNI_AUD_DETAIL_RUN1 (sessionid)
tablespace rk_priv_ana;

create index KR_AUD_DETAIL_dbuser on RK_UNI_AUD_DETAIL_RUN1 (dbusername)
tablespace rk_priv_ana;

create index KR_AUD_DETAIL_SYSPRIV on RK_UNI_AUD_DETAIL_RUN1 (system_privilege_used)
tablespace rk_priv_ana;

create index KR_AUD_DETAIL_obj_name on RK_UNI_AUD_DETAIL_RUN1 (object_name)
tablespace rk_priv_ana;

create index KR_AUD_DETAIL_sql_id on RK_UNI_AUD_DETAIL_RUN1 (sql_id)
tablespace rk_priv_ana;


-- PUT the SQL text in table DIST as well
alter table  RK_UNI_AUD_GROUP_DIST_RUN1 add (min_sql_text clob);
alter table  RK_UNI_AUD_GROUP_DIST_RUN1 add (max_sql_text clob);

set time on
set timi on
update RK_UNI_AUD_GROUP_DIST_RUN1 o
  set min_sql_text = (select sql_text from RK_UNI_AUD_DETAIL_RUN1 i
                  where i.sql_id = o.min_sql_id
				  fetch first 1 rows only),
	  max_sql_text = (select sql_text from RK_UNI_AUD_DETAIL_RUN1 i
                  where i.sql_id = o.max_sql_id
				  fetch first 1 rows only); 

				  
alter table  RK_UNI_AUD_GROUP_DIST_RUN1 add (min_sql_froms clob);
alter table  RK_UNI_AUD_GROUP_DIST_RUN1 add (max_sql_froms clob);
alter table  RK_UNI_AUD_GROUP_DIST_RUN1 add (min_sql_froms_noexp clob);
alter table  RK_UNI_AUD_GROUP_DIST_RUN1 add (max_sql_froms_noexp clob);

			
-- REAL ANA TABLE
-- ADD SQL_TEXT
alter table  RK_UNI_AUD_GROUP_RUN1 add (sql_text clob);
alter table  RK_UNI_AUD_GROUP_RUN1 add (sql_from_clause clob);
alter table  RK_UNI_AUD_GROUP_RUN1 add (sql_text_exp clob);
alter table  RK_UNI_AUD_GROUP_RUN1 add (sql_from_clause_exp clob);

set time on
set timi on
update RK_UNI_AUD_GROUP_RUN1 o
  set sql_text = (select sql_text from RK_UNI_AUD_DETAIL_RUN1 i
                  where i.sql_id = o.sql_id
				  fetch first 1 rows only);
commit;				 
update RK_UNI_AUD_GROUP_RUN1 o
  set sql_text_exp = rk_grant_string_ana.expand_sql(sql_text);
commit;

-- Install the package
@string_ana.sql

-- do the work				 
exec pa.RK_GRANT_STRING_ANA.DO_THE_WORK;
commit;

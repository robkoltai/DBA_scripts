
-- Flush directives
exec dbms_spd.flush_sql_plan_directive;

-- select details for a user
select directive_id,type,state,reason,notes,created,last_modified,last_used
from dba_sql_plan_directives where directive_id in(
select directive_id from dba_sql_plan_dir_objects where owner='&USER')
order by created;

/*

SPD NOTE PL: <spd_note>
  <internal_state>NEW</internal_state>
  <redundant>NO</redundant>
  <spd_text>{(IA_STAGE_AREA.PROCESS_MANAGER_JOBS)}</spd_text>
</spd_note>


9,06879916149721E18	DYNAMIC_SAMPLING	USABLE	SINGLE TABLE CARDINALITY MISESTIMATE	<spd_note>
  <internal_state>NEW</internal_state>
  <redundant>NO</redundant>
  <spd_text>{(IA_STAGE_AREA.PROCESS_MANAGER_JOBS)}</spd_text>
</spd_note>
	2018/05/28/ 07:18:51,000000
3,61738698514952E18	DYNAMIC_SAMPLING	USABLE	SINGLE TABLE CARDINALITY MISESTIMATE	<spd_note>
  <internal_state>NEW</internal_state>
  <redundant>NO</redundant>
  <spd_text>{E(IA_STAGE_AREA.PROCESS_MANAGER_STATUS_HIST)[INSERT_DATE]}</spd_text>
</spd_note>
	2018/05/31/ 14:41:06,000000
6,81043042428654E18	DYNAMIC_SAMPLING	USABLE	GROUP BY CARDINALITY MISESTIMATE	<spd_note>
  <internal_state>NEW</internal_state>
  <redundant>NO</redundant>
  <spd_text>{(IA_STAGE_AREA.PROCESS_MANAGER_STATUS_HIST)[INSERT_DATE, WORKFLOW_ID]}</spd_text>
</spd_note>
	2018/06/01/ 22:43:14,000000
8,24921439381641E18	DYNAMIC_SAMPLING	USABLE	SINGLE TABLE CARDINALITY MISESTIMATE	<spd_note>
  <internal_state>NEW</internal_state>
  <redundant>NO</redundant>
  <spd_text>{(IA_STAGE_AREA.PROCESS_MANAGER_STATUS_HIST)[INSERT_DATE]}</spd_text>
</spd_note>
	2018/06/01/ 22:43:14,000000
1,40709188039147E18	DYNAMIC_SAMPLING	USABLE	SINGLE TABLE CARDINALITY MISESTIMATE	<spd_note>
  <internal_state>NEW</internal_state>
  <redundant>NO</redundant>
  <spd_text>{C(IA_STAGE_AREA.PROCESS_MANAGER_STATUS_HIST)[LAST_ERROR, START_DATE]}</spd_text>
</spd_note>
	2018/06/13/ 16:19:22,000000
	
*/

-- GET DIRECTIVE ID WITH EXPLAIN PLAN USE +METRICS
explain plan for select count(*) into :l_row_count from IA_STAGE_AREA.REMEDIOS_IA_MOBILNET_CUST_ACTIVE_V2_V where rownum <= 1;

set pages 200 
set lines 200
select * from table(dbms_xplan.display(null,null,'+metrics'));

/*


Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - 2 Sql Plan Directives used for this statement

...

Sql Plan Directive information:
-------------------------------

  Used directive ids:
    4726664693208918497
    8370416233033386243

*/	



-- Milyen tablakra, milyen oszlopokra milyen feltetellel van direktiva
select * from dba_sql_plan_dir_objects where directive_id in (4726664693208918497,    8370416233033386243);
-- Miért és mikor csinálta
select * from dba_sql_plan_directives where directive_id in (4726664693208918497,    8370416233033386243);
	
	
/*	
--- DIRECTIVE OBJECTS
4,72666469320892E18	ETL_MHC	IA_CONTRACT_ALL_H	SOS	COLUMN		
4,72666469320892E18	ETL_MHC	IA_CONTRACT_ALL_H		TABLE		<obj_note>
  <equality_predicates_only>NO</equality_predicates_only>
  <simple_column_predicates_only>YES</simple_column_predicates_only>
  <index_access_by_join_predicates>NO</index_access_by_join_predicates>
  <filter_on_joining_object>NO</filter_on_joining_object>
</obj_note>

4,72666469320892E18	ETL_MHC	IA_CONTRACT_ALL_H	TENDOFSERVICE	COLUMN		
8,37041623303339E18	ETL_MHC	IA_ADSLINTERNET	PRIMER	COLUMN		
8,37041623303339E18	ETL_MHC	IA_ADSLINTERNET		TABLE		<obj_note>
  <equality_predicates_only>NO</equality_predicates_only>
  <simple_column_predicates_only>YES</simple_column_predicates_only>
  <index_access_by_join_predicates>NO</index_access_by_join_predicates>
  <filter_on_joining_object>NO</filter_on_joining_object>
</obj_note>




-- DIRECTIVES
4,72666469320892E18	ETL_MHC	IA_CONTRACT_ALL_H		TABLE		<obj_note>
  <equality_predicates_only>NO</equality_predicates_only>
  <simple_column_predicates_only>YES</simple_column_predicates_only>
  <index_access_by_join_predicates>NO</index_access_by_join_predicates>
  <filter_on_joining_object>NO</filter_on_joining_object>
</obj_note>

8,37041623303339E18	ETL_MHC	IA_ADSLINTERNET		TABLE
<obj_note>
  <equality_predicates_only>NO</equality_predicates_only>
  <simple_column_predicates_only>YES</simple_column_predicates_only>
  <index_access_by_join_predicates>NO</index_access_by_join_predicates>
  <filter_on_joining_object>NO</filter_on_joining_object>
</obj_note>


*/	
	
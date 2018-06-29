
-- UTILITIES
-- expand sql text
SET SERVEROUTPUT ON ;
DECLARE
  l_clob CLOB;
BEGIN
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => '<put sql here>',
    output_sql_text => l_clob
  );

  DBMS_OUTPUT.put_line(l_clob);
END;
/

-- TEST ASH
select * from v$active_session_history 
where 1=1 
  and session_id=246 and sample_time>sysdate-120/60/24
order by sample_id desc;

-- DISPLAY CURSOR
select * from TABLE(dbms_xplan.display_cursor (sql_id =>'&sql_id', cursor_child_no =>0, format=>'advanced allstats last +note +alias +outline -projection +predicate +adaptive'));

-- FLUSH SQL
-- A directive-kat nem torli ki
SELECT inst_id, loaded_versions, invalidations, address, hash_value
FROM gv$sqlarea WHERE sql_id = '&&sql_id.' ORDER BY 1;
SELECT inst_id, child_number, plan_hash_value, executions, is_shareable
FROM gv$sql WHERE sql_id = '&&sql_id.' ORDER BY 1, 2;

BEGIN
 FOR i IN (SELECT address, hash_value
 FROM gv$sqlarea WHERE sql_id = '&&sql_id.')
 LOOP
 SYS.DBMS_SHARED_POOL.PURGE(i.address||','||i.hash_value, 'C');
 END LOOP;
END;
/



-- MAIN
-- Check all the important fields for a select
select s.sql_id sqlid, child_number,
  s.is_reoptimizable reopt, s.is_resolved_adaptive_plan resolved, 
  is_obsolete, is_bind_sensitive, is_bind_aware, is_shareable, sql_profile, sql_patch, sql_plan_baseline,
  s.* 
from v$sql s 
where 1=1 
  and sql_id in ('yy','xx')
  --and is_reoptimizable <> 'N'
  --and is_resolved_adaptive_plan is not null
order by sqlid, child_number;

-- Why cursor was not shared?
select * from v$sql_shared_cursor where sql_id in ('831m2z9dpbuzx','ahvaz6kj15rkt','4yhrwxkgbzqfy','bssqz82qrgszv');

-- REOPT HINT
select * from V$SQL_REOPTIMIZATION_HINTS where sql_id in ('xxx','yyy') ;

-- Adaptive cursor sharing
select * from V$SQL_CS_HISTOGRAM where sql_id in ('xxx','yyy') order by sql_id;
select * from V$SQL_CS_SELECTIVITY where sql_id in ('xxx','yyy') order by sql_id;
select * from V$SQL_CS_STATISTICS where sql_id in ('xxx','yyy') order by sql_id;


-- Current SQL MONITOR
SELECT dbms_sqltune.Report_sql_monitor(SQL_ID=>'&sql_id', TYPE=>'text',report_level=>'ALL')
FROM   dual;

-- historikus reszletes SQL MONITOR REPORT
select substr(key4,1,instr(key4,'#')-1) as elapsed, 
dbms_auto_report.Report_repository_detail(rid=>report_id,TYPE=>'TEXT') as z_report, 
rep.* 
from dba_hist_reports rep 
where key1='&sql_id' order by period_start_time desc;


--DIRECTIVE 
-- mi van neki? Owner szerint indulhatunk
select * from DBA_SQL_PLAN_DIR_objects where owner = 'IA_STAGE_AREA';

select directive_id,type,state,reason,notes,created,last_modified,last_used
from dba_sql_plan_directives where directive_id in(
select directive_id from dba_sql_plan_dir_objects where owner='IA_STAGE_AREA')
order by created;

-- a Notes-ban benne vannak az SQL ID-k
SELECT extract(notes, '/spd_note/spd_text') vau, 
  s.*
FROM   DBA_SQL_PLAN_DIRECTIVES s
WHERE  TYPE = 'DYNAMIC_SAMPLING_RESULT' and notes like '%4vq7kqfwmzu2w%';
-- and  directive_id in(
-- select directive_id from dba_sql_plan_dir_objects where owner='IA_STAGE_AREA');

-- Directive by id
select * from dba_sql_plan_directives where directive_id in (4726664693208918497,    8370416233033386243);
select * from dba_sql_plan_dir_objects where directive_id in (4726664693208918497,    8370416233033386243);

-- 12.2 dynamic sampling results are saved as directives
SELECT * FROM   DBA_SQL_PLAN_DIRECTIVES
WHERE  TYPE = 'DYNAMIC_SAMPLING_RESULT';

- GET DIRECTIVE ID WITH EXPLAIN PLAN USE +METRICS
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




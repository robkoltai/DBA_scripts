-- pending STATISTICS

-- parameters
ALTER SYSTEM SET OPTIMIZER_USE_PENDING_STATISTICS=TRUE;
select * from v$parameter where name like 'optim%feat%' or name like '%pendin%';


-- Here are the pending stats
select * from dba_TAB_PENDING_STATS;
select * from DBA_IND_PENDING_STATS;
select * from DBA_COL_PENDING_STATS;
select * from DBA_TAB_HISTGRM_PENDING_STATS;

-- Published stats
select t.last_analyzed, num_rows, sample_size, blocks, t.* 
  from dba_tables  t where table_name = 'APP_APPLICANT';
select i.last_analyzed, i.num_rows, i.distinct_keys, i.leaf_blocks, i.* 
  from dba_indexes i where index_name in ('IDX_APP_APPLICANT_APP_TYPE','IDX_APPL_NAMES_TYPE');
select c.last_analyzed, c.sample_size, c.* 								
  from dba_tab_columns c where table_name = 'APP_APPLICANT' and column_name = 'APP_TYPE';
select h.endpoint_actual_value, endpoint_actual_value_raw, endpoint_repeat_count, h.* 
  from dba_tab_histograms h where table_name ='APP_APPLICANT' and column_name = 'APP_TYPE'order by column_name;

-- STATS HISTORY
select * from dba_TAB_STATS_HISTORY;

-- Check the objects you care about
select * from dba_objects where object_name in ('APP_APPLICANT','IDX_APP_APPLICANT_APP_TYPE');
  
-- Check the stats history
select * from sys.WRI$_OPTSTAT_AUX_HISTORY;
select * from sys.WRI$_OPTSTAT_HISTGRM_HISTORY where obj# in (77320,76621) and INTCOL#=122 order by savtime desc;
select * from sys.WRI$_OPTSTAT_HISTHEAD_HISTORY where obj# in (77320,76621) and INTCOL#=122  order by savtime desc;
select * from sys.WRI$_OPTSTAT_IND_HISTORY where obj# = 77320 order by savtime desc;
select * from sys.WRI$_OPTSTAT_TAB_HISTORY where obj# = 76621 order by savtime desc; 

--select * from dba_objects where object_name like 'WRI%%STAT%HIST%' and object_type='TABLE';
  
  
-- Stat collection tasks
select * from DBA_OPTSTAT_OPERATIONS order by start_time desc;
select * from DBA_OPTSTAT_OPERATION_TASKS where target like 'PCS%' order by start_time desc;

-- COLUMN USAGE for histograms
select * from SYS.COL_USAGE$ where obj#=76620;


-- Longops
select time_remaining+elapsed_seconds as ossz, lo.* from v$session_longops lo where target like 'PCS%' order by start_time desc;


-- get param
select dbms_stats.get_param('estimate_percent') from dual;

-- table stat prefs
select * from DBA_TAB_STAT_PREFS where table_name = 'APP_APPLICANT';


-- COLLECT
BEGIN dbms_stats.Gather_table_stats('PCS', 'APP_APPLICANT', method_opt => 'FOR COLUMNS SIZE 254 APP_TYPE', estimate_percent=> 0.1); 
END; 
/

begin DBMS_STATS.GATHER_INDEX_STATS ('PCS', 'IDX_APP_APPLICANT_APP_TYPE', estimate_percent=> 0.1);
end;
/

begin DBMS_STATS.GATHER_INDEX_STATS ('PCS', 'IDX_APPL_NAMES_TYPE', estimate_percent=> 0.1);
end;
/

-- pending STATISTICS

-- parameters
ALTER SYSTEM SET OPTIMIZER_USE_PENDING_STATISTICS=TRUE;
select * from v$parameter where name like 'optim%feat%' or name like '%pendin%';


-- Here are the pending stats
select * from dba_TAB_PENDING_STATS;
select * from DBA_IND_PENDING_STATS;
select * from DBA_COL_PENDING_STATS;
select * from DBA_TAB_HISTGRM_PENDING_STATS;

-- Stat collection tasks
select * from DBA_OPTSTAT_OPERATIONS order by start_time desc;
select * from DBA_OPTSTAT_OPERATION_TASKS where target like 'PCS%' order by start_time desc;

-- Longops
select time_remaining+elapsed_seconds as ossz, lo.* from v$session_longops lo where target like 'PCS%' order by start_time desc;


-- get param
select dbms_stats.get_param('estimate_percent') from dual;


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

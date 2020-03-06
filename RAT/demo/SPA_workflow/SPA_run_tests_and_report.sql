-- Sql tuning set format (first we need to load an STS, then analyze it)


variable sts_task  VARCHAR2(64);
 
-- Ami a usert legjobban erdekli az elapsed_time
EXEC :sts_task := DBMS_SQLPA.CREATE_ANALYSIS_TASK( -
  sqlset_name    =>   'THE_FOUR_COMMANDS_SQLSET', -
  order_by       =>   'elapsed_time', -
  description    =>   '4 statements by elapsed time'); 

print  :sts_task
EXEC :sts_task := 'TASK_28675';
  
-- Before change
-- We want the updates, deletes executed
EXEC DBMS_SQLPA.SET_ANALYSIS_TASK_PARAMETER( :sts_task,'EXECUTE_FULLDML', 'true');   
-- This is not taken into account   
EXEC DBMS_SQLPA.SET_ANALYSIS_TASK_PARAMETER( :sts_task,'EXECUTE_COUNT', '27');          

-- PRE SETTINGS   
@/home/oracle/RAT/config/config_pre_change_init_parameters.sql

begin
  DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(
    task_name       => :sts_task, 
    execution_type  => 'test execute', 
    execution_name  => 'before_change');  
end;
/	

-- CHANGE
@/home/oracle/RAT/config/config_the_change_init_parameters.sql

begin
  DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(
   task_name          => :sts_task, 
   execution_type     => 'test execute',
   execution_name     => 'after_change');
end;
/ 

 
-- COMPARISON_METRIC: specify an expression of execution statistics to use in performance comparison (Example: buffer_gets, cpu_time + buffer_gets * 10)
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQLPA.html#GUID-CFE070C1-80F3-4A20-96B0-3B38139338D8

begin
 DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(
   task_name        => :sts_task, 
   execution_type   => 'compare performance', 
   execution_name   => 'compare_the_runs',
   execution_params => dbms_advisor.arglist(
      'execution_name1', 'before_change', 
      'execution_name2', 'after_change',
	  'workload_impact_threshold', 0,
	  'sql_impact_threshold', 0,
      'comparison_metric', 
      'elapsed_time'));
end;
/

/*
begin
   DBMS_SQLPA.SET_ANALYSIS_TASK_PARAMETER(task_name =>  'TASK_28517',
       parameter => 'COMPARE_RESULTSET', 
       value => 'TRUE');
end;
/
*/

/*
SELECT DBMS_SQLPA.REPORT_ANALYSIS_TASK(:sts_task, 'TEXT', 'ALL', 'SUMMARY', execution_name=>'compare_the_runs')
FROM DUAL;
*/
 
	
variable rep CLOB;
begin
  :rep := 
 DBMS_SQLPA.REPORT_ANALYSIS_TASK(
   task_name=>:sts_task, 
   type=>'HTML', 
   level=>'ALL', 
   section=>'ALL', 
   execution_name=>'compare_the_runs');
end;
/

SET LONG 1000000
set LONGCHUNKSIZE 1000000
set LINESIZE 200
set head off
set feedback off
set echo off
spool SPA_report.html
PRINT :rep
spool off
set head on	
 
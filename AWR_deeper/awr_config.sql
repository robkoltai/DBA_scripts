-- CAPTURE
DBMS_WORKLOAD_REPOSITORY.ADD_COLORED_SQL(sql_id=>'<sql_id>'); 
This procedure adds a colored SQL ID. If an SQL ID is colored, it will be captured in every snapshot, independent of its level of activities (so that it does not have to be a TOP SQL). 
Capture occurs if the SQL is found in the cursor cache at snapshot time. To uncolor the SQL, invoke the REMOVE_COLORED_SQL Procedure. 

--CAPTURE 300 SQLS
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (null,null,300,null);

-- REPORTING
You can also use this procedure to configure specified report thresholds, including the number of rows in the report: 

Syntax 

DBMS_WORKLOAD_REPOSITORY.AWR_SET_REPORT_THRESHOLDS( 
top_n_events IN NUMBER DEFAULT NULL, 
top_n_files IN NUMBER DEFAULT NULL, 
top_n_segments IN NUMBER DEFAULT NULL, 
top_n_services IN NUMBER DEFAULT NULL, 
top_n_sql IN NUMBER DEFAULT NULL, 
top_n_sql_max IN NUMBER DEFAULT NULL, 
top_sql_pct IN NUMBER DEFAULT NULL, 
shmem_threshold IN NUMBER DEFAULT NULL, 
versions_threshold IN NUMBER DEFAULT NULL); 



exec dbms_workload_repository.awr_set_report_thresholds(top_n_segments =>100, top_n_sql=>300,top_n_sql_max=>300, top_sql_pct=>0.1);

https://docs.oracle.com/database/121/ARPLS/d_workload_repos.htm#ARPLS69124
Settings are effective only in the context of the session that executes the AWR_SET_REPORT_THRESHOLDS procedure.



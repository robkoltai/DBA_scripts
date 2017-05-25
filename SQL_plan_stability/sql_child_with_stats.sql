select distinct sql_id, child_number from v$sql_plan_statistics_all where sql_id = '&sql_id' order by 1,2
/

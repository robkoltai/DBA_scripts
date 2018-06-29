-- https://carlos-sierra.net/tag/plan-hash-value/

----------------------------------------------------------------------------------------
--
-- File name:   one_sql_time_series.sql
--
-- Purpose:     Performance History for one SQL
--
-- Author:      Carlos Sierra
--
-- Version:     2014/10/31
--
-- Usage:       Script sql_performance_changed.sql lists SQL Statements with performance
--              improvement or regressed over some History.
--              This script one_sql_time_series.sql lists the Performance Time Series for
--              one SQL.
--
-- Parameters:  SQL_ID
--
-- Example:     @one_sql_time_series.sql
--
-- Notes:       Developed and tested on 11.2.0.3.
--
--              Requires an Oracle Diagnostics Pack License since AWR data is accessed.
--
--              To further investigate poorly performing SQL use sqltxplain.sql or sqlhc 
--              (or planx.sql or sqlmon.sql or sqlash.sql).
--             
---------------------------------------------------------------------------------------
--




------------

-- Szerintem szar mert deltakkal kene szamoljon !!!!

------------



SPO one_sql_time_series.txt;
SET lin 200 ver OFF;
 
COL instance_number FOR 9999 HEA 'Inst';
COL end_time HEA 'End Time';
COL plan_hash_value HEA 'Plan|Hash Value';
COL executions_total FOR 999,999 HEA 'Execs|Total';
COL rows_per_exec HEA 'Rows Per Exec';
COL et_secs_per_exec HEA 'Elap Secs|Per Exec';
COL cpu_secs_per_exec HEA 'CPU Secs|Per Exec';
COL io_secs_per_exec HEA 'IO Secs|Per Exec';
COL cl_secs_per_exec HEA 'Clus Secs|Per Exec';
COL ap_secs_per_exec HEA 'App Secs|Per Exec';
COL cc_secs_per_exec HEA 'Conc Secs|Per Exec';
COL pl_secs_per_exec HEA 'PLSQL Secs|Per Exec';
COL ja_secs_per_exec HEA 'Java Secs|Per Exec';
 
SELECT h.instance_number,
       TO_CHAR(CAST(s.end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_time,
       h.plan_hash_value, 
       h.executions_total,
       TO_CHAR(ROUND(h.rows_processed_total / h.executions_total), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time_total / h.executions_total / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time_total / h.executions_total / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.iowait_total / h.executions_total / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.clwait_total / h.executions_total / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.apwait_total / h.executions_total / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.ccwait_total / h.executions_total / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.plsexec_time_total / h.executions_total / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.javexec_time_total / h.executions_total / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM dba_hist_sqlstat h, 
       dba_hist_snapshot s
 WHERE h.sql_id = '&sql_id.'
   AND h.executions_total > 0 
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY
       h.sql_id,
       h.instance_number,
       s.end_interval_time,
       h.plan_hash_value
/
 
SPO OFF;


/*

-- Per snap
-- each stat is shown per exec

1	2018-06-14 23:30	3282220586	2623	               0	       0.646	       0.380	       0.000	       0.000	       0.000	       0.000	       0.072	       0.000
1	2018-06-15 00:00	3282220586	3773	               0	       0.927	       0.546	       0.000	       0.000	       0.000	       0.000	       0.104	       0.000
1	2018-06-15 00:30	3282220586	4511	               0	       1.163	       0.662	       0.000	       0.000	       0.000	       0.000	       0.130	       0.000
1	2018-06-15 01:00	3282220586	5202	               0	       1.355	       0.767	       0.000	       0.000	       0.000	       0.000	       0.151	       0.000
1	2018-06-15 01:30	3282220586	5851	               0	       1.513	       0.862	       0.000	       0.000	       0.000	       0.000	       0.170	       0.000
1	2018-06-15 02:00	3282220586	6430	               0	       1.658	       0.945	       0.000	       0.000	       0.000	       0.000	       0.186	       0.000

*/
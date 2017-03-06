-- Ucso 30 napra megadja az AWR-ben található top 15 sql-ek listáját
-- order by elapsed time

set pages 500
set lines 1111
column elapsed format 999,999,990.90;
column cpu format 999,999,990.90;
column iowait format 999,999,990.90;
column application_wait format 999,999,990.90;
column concurrency_wait format 999,999,990.90;
column plsql_exec format 999,999,990.90;
column java_exec format 999,999,990.90;
column min_date format a10
column max_date format a10
variable newl varchar2(64);

begin
  :newl := '
';
end;
/

select * from (
select stat.sql_id as sql_id,
     sum(elapsed_time_delta) / 1000000 as elapsed,
     sum(cpu_time_delta) / 1000000 as cpu,
     sum(iowait_delta) / 1000000 as iowait,
     sum(APWAIT_DELTA) / 1000000 as application_wait,
     sum(CCWAIT_DELTA) / 1000000 as concurrency_wait,
     sum(PLSEXEC_TIME_DELTA) / 1000000 as plsql_exec,
     sum(JAVEXEC_TIME_DELTA) / 1000000 as java_exec,
     sum(executions_delta) as executions,
     sum(parse_calls_delta) as parse_calls,
     min(sn.snap_id) as minsnap,
     max(sn.snap_id) as maxsnap,
     to_char(min(BEGIN_INTERVAL_TIME),'YYYYMMDD') as min_date,
     to_char(max(BEGIN_INTERVAL_TIME),'YYYYMMDD') as max_date,
     (select to_char(substr(replace(st.sql_text,:newl,' '),1,85))
        from dba_hist_sqltext st
        where st.dbid = stat.dbid and st.sql_id = stat.sql_id) as sql_text_fragment
from dba_hist_sqlstat stat, dba_hist_sqltext text, dba_hist_snapshot sn
where stat.sql_id = text.sql_id and
       stat.dbid   = text.dbid and
       sn.dbid= stat.dbid and 
       sn.snap_id = stat.snap_id and
       BEGIN_INTERVAL_TIME > sysdate-30       
group by stat.dbid, stat.sql_id
order by elapsed desc
) where ROWNUM <= 15;


/*

SQL_ID                ELAPSED             CPU          IOWAIT APPLICATION_WAIT CONCURRENCY_WAIT      PLSQL_EXEC       JAVA_EXEC EXECUTIONS PARSE_CALLS    MINSNAP    MAXSNAP MIN_DATE   MAX_DATE   SQL_TEXT_FRAGMENT
------------- --------------- --------------- --------------- ---------------- ---------------- --------------- --------------- ---------- ----------- ---------- ---------- ---------- ---------- -------------------------------------------------------------------------------------
97h0wkz0c17s3    9,650,986.72    2,572,945.21    3,369,988.52        12,363.97        29,530.40      692,130.67        8,481.33       3438        3497      25176      48077 20120104   20140918   call PROCESS_MANAGER.CONSUMER ( :0 )
cxvn4dr3j0zf3    5,977,856.94    1,601,972.17    2,196,097.01        11,327.31        33,392.65      578,916.07           16.25      13500        7482      25176      48077 20120104   20140918   begin ETL2.DWH_RUNNER.RUN_PROCEDURE(:action_id); end;
0mpp5f5a766pv    2,801,080.57      751,113.58      856,428.91           909.21           179.77      191,947.76            0.08      10013        4212      25176      48077 20120104   20140918   begin ETL2.DWH_LOADER.LOAD_TABLE(:action_id); end;
ca6h9bjuakz86    1,075,180.62       43,082.23      991,815.63            21.57           252.50            0.00            0.00        975        5839      40580      48034 20131101   20140916   select /*+  parallel(t,5) parallel_index(t,5) dbms_stats cursor_sharing_exact use_wea
7crn5g07h57jk      978,024.73      293,817.95      445,764.22           217.54           130.09       14,932.53        7,653.92       2065        1072      25180      48077 20120105   20140918   begin ETL.DWH_RUNNER.RUN_PROCEDURE(:action_id); end;
aqxyk52kn1ukb      967,094.45      268,684.74      386,990.20           775.27         1,087.19       40,622.67            0.07       9213        1036      25180      48077 20120105   20140918   begin ETL.DWH_LOADER.LOAD_TABLE(:action_id); end;
7vawym3x8t0yk      726,161.09      155,776.01       13,802.30           405.99           723.63          204.58          251.45      24779         764      25176      48070 20120104   20140918   begin ETL2.DWH_CLONER.CLONE_TABLE(:action_id); end;
0ncz4mps27zb3      564,683.86      132,773.31      105,762.33            66.70            36.45       69,392.98            0.19         45          46      40589      48058 20131101   20140917   begin COSMOSS.LOAD_S_CUSTV_FINAL; end;
b1dzc2cprp8jy      483,905.76      193,148.29      124,315.41             0.00            12.53            0.79            0.00       1075        1076      25176      48077 20120104   20140918   begin ETL2.LOAD_PTIC_ADATKOZLO.ADATKOZLO_HEAD; end;
3xbjr574rtn8d      404,308.69      113,667.80      210,015.37            21.96            38.30           41.10            0.03         47          48      25181      48074 20120105   20140918   begin ETL.SLS_DATAMART_LOADER.LOAD_MANAGER; end;
351r0kq6z9h04      397,109.81       33,934.07      348,818.92             0.00             0.29           18.04            0.12         83          81      40585      48073 20131101   20140918   begin ETL2.DWH_HISTORIZER.HISTORIZE_TABLE(:action_id); end;
0ym4js7r8vsvf      369,390.21       59,980.01      257,799.40           161.71             0.26           29.59            0.00         14          14      47110      47549 20140809   20140827   SELECT "A1"."SERV_POID","A1"."CUSTOMER_ID","A1"."CUSTOMER_NAME","A1"."SALES_CHANNEL_D
b2h4ggrk8svmj      343,256.58       78,255.58      208,237.64           131.95             7.83       65,893.90            0.00         45          45      47114      48077 20140809   20140918   begin COSMOSS.PARTY.MANAGE; end;
dycxad6n5uacr      280,462.98       46,284.51      188,515.53            27.63             0.74           40.66            0.00         12          12      47567      47882 20140828   20140910    (SELECT "A3"."SERV_POID","A3"."CUSTOMER_ID","A3"."CUSTOMER_NAME","A3"."SALES_CHANNEL
4grhfyyawhjuu      272,690.28        3,562.87      267,827.02             4.60             1.36           13.33            0.00         38          37      40589      48077 20131101   20140918   SELECT "A1"."SERV_POID","A1"."MASTER_CUSTOMER_ID","A1"."MASTER_CUSTOMER_NAME","A1"."C

15 rows selected.
*/
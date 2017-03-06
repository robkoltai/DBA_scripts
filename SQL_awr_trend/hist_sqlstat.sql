col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
set lines 500
-- counts
col execs for 999,999,999
col avg_rows for 999,999,999
col AVG_FETCH for 999,999,999
col AVG_EOFFETCH for 999,999,999
col AVG_SORT for 999,999,999
col AVG_PX for 999,999,999
col AVG_LOAD for 999,999,999
col AVG_IVALID for 999,999,999
col AVG_PARSECALL for 999,999,999
col AVG_PX for 999,999,999
col phy_r_req for 999,999,999
col phy_r_byte for 999,999,999
col disk_read for 999,999,999
col phy_w_req for 999,999,999
col phy_w_byte for 999,999,999
-- times
col etime for 999,999,999.999
col cpu for 999,999,999.999
col avg_etime for 999,999.999
col avg_iowait for   999,999.999
col avg_clwait for   999,999.999
col avg_apwait for   999,999.999
col avg_ccwait for   999,999.999
col avg_plsql for   999,999.999
col avg_java for   999,999.999

select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
-- MAIN
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(CPU_TIME_DELTA/decode(nvl(CPU_TIME_delta,0),0,1,executions_delta)) /1000000 avg_cpu,
  elapsed_time_delta/1000000 etime,
  CPU_TIME_DELTA/1000000 cpu,
(ROWS_PROCESSED_DELTA/decode(nvl(ROWS_PROCESSED_DELTA,0),0,1,executions_delta)) avg_rows,
-- IO
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio,
(PHYSICAL_READ_REQUESTS_DELTA/decode(nvl(PHYSICAL_READ_REQUESTS_DELTA,0),0,1,executions_delta)) phy_r_req,
(PHYSICAL_READ_BYTES_DELTA/decode(nvl(PHYSICAL_READ_BYTES_DELTA,0),0,1,executions_delta)) phy_r_byte,
(DISK_READS_DELTA/decode(nvl(DISK_READS_DELTA,0),0,1,executions_delta)) disk_read,
(PHYSICAL_WRITE_REQUESTS_DELTA/decode(nvl(PHYSICAL_WRITE_REQUESTS_DELTA,0),0,1,executions_delta)) phy_w_req,
(PHYSICAL_WRITE_BYTES_DELTA/decode(nvl(PHYSICAL_WRITE_BYTES_DELTA,0),0,1,executions_delta)) phy_w_byte,
-- WAIT
(IOWAIT_DELTA/decode(nvl(IOWAIT_DELTA,0),0,1,executions_delta)) avg_iowait,
(CLWAIT_DELTA/decode(nvl(CLWAIT_DELTA,0),0,1,executions_delta)) avg_clwait,
(APWAIT_DELTA/decode(nvl(APWAIT_DELTA,0),0,1,executions_delta)) avg_apwait,
(CCWAIT_DELTA/decode(nvl(CCWAIT_DELTA,0),0,1,executions_delta)) avg_ccwait,
-- FETCH
(FETCHES_DELTA/decode(nvl(FETCHES_DELTA,0),0,1,executions_delta)) AVG_FETCH,
(END_OF_FETCH_COUNT_DELTA/decode(nvl(END_OF_FETCH_COUNT_DELTA,0),0,1,executions_delta)) AVG_EOFFETCH,
-- sort
(SORTS_DELTA/decode(nvl(SORTS_DELTA,0),0,1,executions_delta)) AVG_SORT,
-- plsql/java
(PLSEXEC_TIME_DELTA/decode(nvl(PLSEXEC_TIME_DELTA,0),0,1,executions_delta)) AVG_PLSQL,
(JAVEXEC_TIME_DELTA/decode(nvl(JAVEXEC_TIME_DELTA,0),0,1,executions_delta)) AVG_JAVA,
--px 
(PX_SERVERS_EXECS_DELTA/decode(nvl(PX_SERVERS_EXECS_DELTA,0),0,1,executions_delta)) AVG_PX,
-- Parse
(LOADS_DELTA/decode(nvl(LOADS_DELTA,0),0,1,executions_delta)) AVG_LOAD,
(INVALIDATIONS_DELTA/decode(nvl(INVALIDATIONS_DELTA,0),0,1,executions_delta)) AVG_IVALID,
(PARSE_CALLS_DELTA/decode(nvl(PARSE_CALLS_DELTA,0),0,1,executions_delta)) AVG_PARSECALL
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = '&sql_id'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3;

/*
   SNAP_ID   NODE BEGIN_INTERVAL_TIME            SQL_ID        PLAN_HASH_VALUE        EXECS    AVG_ETIME      AVG_CPU            ETIME              CPU     AVG_ROWS        AVG_LIO    PHY_R_REQ   PHY_R_BYTE    DISK_READ    PHY_W_REQ   PHY_W_BYTE   AVG_IOWAIT   AVG_CLWAIT   AVG_APWAIT   AVG_CCWAIT    AVG_FETCH AVG_EOFFETCH     AVG_SORT    AVG_PLSQL     AVG_JAVA       AVG_PX     AVG_LOAD   AVG_IVALID AVG_PARSECALL
---------- ------ ------------------------------ ------------- --------------- ------------ ------------ ------------ ---------------- ---------------- ------------ -------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ -------------
       177      1 26-OCT-16 05.00.02.502 PM      7u49y06aqxg1s      3312420081        1,420         .000         .000             .481             .086           16            3.3            0          231            0            0            0      287.429         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       178      1 26-OCT-16 08.24.32.294 PM      7u49y06aqxg1s                        1,837         .000         .000             .117             .112           16            3.3            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       179      1 26-OCT-16 09.00.38.322 PM      7u49y06aqxg1s                        1,839         .000         .000             .189             .083           16            3.4            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       180      1 26-OCT-16 10.00.46.076 PM      7u49y06aqxg1s                        1,805         .000         .000             .113             .071           16            3.3            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       181      1 26-OCT-16 11.00.56.428 PM      7u49y06aqxg1s                        1,575         .000         .000             .114             .085           16            3.3            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       182      1 27-OCT-16 07.20.34.258 AM      7u49y06aqxg1s                        1,420         .000         .000             .079             .066           15            3.3            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       183      1 27-OCT-16 08.46.36.964 AM      7u49y06aqxg1s                        2,592         .000         .000             .390             .145           15            3.3            0           51            0            0            0       92.424         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       184      1 27-OCT-16 09.00.39.078 AM      7u49y06aqxg1s                        2,199         .000         .000             .162             .139           16            3.4            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       185      1 27-OCT-16 10.00.51.296 AM      7u49y06aqxg1s                        8,468         .000         .000            1.097             .461           16            3.4            0           62            0            0            0       62.441         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       186      1 27-OCT-16 11.00.01.767 AM      7u49y06aqxg1s                        2,680         .000         .000             .141             .120           16            3.4            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0
       187      1 27-OCT-16 12.00.09.321 PM      7u49y06aqxg1s                        1,518         .000         .000             .087             .070           15            3.3            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0

   SNAP_ID   NODE BEGIN_INTERVAL_TIME            SQL_ID        PLAN_HASH_VALUE        EXECS    AVG_ETIME      AVG_CPU            ETIME              CPU     AVG_ROWS        AVG_LIO    PHY_R_REQ   PHY_R_BYTE    DISK_READ    PHY_W_REQ   PHY_W_BYTE   AVG_IOWAIT   AVG_CLWAIT   AVG_APWAIT   AVG_CCWAIT    AVG_FETCH AVG_EOFFETCH     AVG_SORT    AVG_PLSQL     AVG_JAVA       AVG_PX     AVG_LOAD   AVG_IVALID AVG_PARSECALL
---------- ------ ------------------------------ ------------- --------------- ------------ ------------ ------------ ---------------- ---------------- ------------ -------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ -------------
       188      1 27-OCT-16 01.00.14.048 PM      7u49y06aqxg1s      3312420081        1,598         .000         .000             .083             .070           16            3.4            0            0            0            0            0         .000         .000         .000         .000            1            0            1         .000         .000            0            0            0             0

*/
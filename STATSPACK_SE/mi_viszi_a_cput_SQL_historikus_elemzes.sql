-- Base select
select snap.startup_time, snap.snap_id, 
  snap.snap_time,        86400*(snap.snap_time  -lag(snap.snap_time,1  )        over (partition by sql_id order by snap.snap_id)) as snap_time_d_secs,
  sql.sql_id,
  fetches,               fetches                -lag(fetches,1,0)               over (partition by sql_id order by snap.snap_id) as fetches_d,
  end_of_fetch_count,    end_of_fetch_count     -lag(end_of_fetch_count,1,0)    over (partition by sql_id order by snap.snap_id) as end_of_fetch_count_d,
  executions,            executions             -lag(executions,1,0)            over (partition by sql_id order by snap.snap_id) as executions_d,
  rows_processed,        rows_processed         -lag(rows_processed,1,0)        over (partition by sql_id order by snap.snap_id) as rows_processed_d,
  parse_calls,           parse_calls            -lag(parse_calls,1,0)           over (partition by sql_id order by snap.snap_id) as parse_calls_d,
  disk_reads,            disk_reads             -lag(disk_reads,1,0)            over (partition by sql_id order by snap.snap_id) as disk_reads_d,
  buffer_gets,           buffer_gets            -lag(buffer_gets,1,0)           over (partition by sql_id order by snap.snap_id) as buffer_gets_d,
  user_io_wait_time,     user_io_wait_time      -lag(user_io_wait_time,1,0)     over (partition by sql_id order by snap.snap_id) as user_io_wait_time_d,
  concurrency_wait_time, concurrency_wait_time  -lag(concurrency_wait_time,1,0) over (partition by sql_id order by snap.snap_id) as concurrency_wait_time_d,
  cpu_time,              cpu_time               -lag(cpu_time,1,0)              over (partition by sql_id order by snap.snap_id) as cpu_time_d,
  elapsed_time  elapsed_time,  elapsed_time     -lag(elapsed_time,1,0)          over (partition by sql_id order by snap.snap_id) as elapsed_time_d
   from  STATS$SNAPSHOT snap, STATS$SQL_SUMMARY sql
  where snap.snap_id= sql.snap_id
  --and sql_id in ('xxx' ,'zzzz','xxx')
  order by snap_id desc;
  

-- MI viszi a CPU-t napra lebontva
select 
  to_char(snap_time,'YYYYMMDD') D, sql_id, 
    round(sum(user_io_wait_time_d)/3600/24/1e6,3) iowait, 
    round(sum(elapsed_time_d)/3600/24/1e6,3) ela, 
    round(sum(cpu_time_d)/3600/24/1e6,3) cpu,
    sum(executions_d) execs,
    round(sum(executions_d)/3600/24,3) execs_per_sec,
    sum(rows_processed_d) rowss,      
    sum(buffer_gets) gets 
    -- round(sum(rows_processed_d/executions_d+1),2) rows_per_exec,
    -- round(sum(buffer_gets_d/executions_d+1),2) gets_per_exec 
from
(select snap.startup_time, snap.snap_id, 
  snap.snap_time,        86400*(snap.snap_time  -lag(snap.snap_time,1  )        over (partition by sql_id order by snap.snap_id)) as snap_time_d_secs,
  sql.sql_id,
  fetches,               fetches                -lag(fetches,1,0)               over (partition by sql_id order by snap.snap_id) as fetches_d,
  end_of_fetch_count,    end_of_fetch_count     -lag(end_of_fetch_count,1,0)    over (partition by sql_id order by snap.snap_id) as end_of_fetch_count_d,
  executions,            executions             -lag(executions,1,0)            over (partition by sql_id order by snap.snap_id) as executions_d,
  rows_processed,        rows_processed         -lag(rows_processed,1,0)        over (partition by sql_id order by snap.snap_id) as rows_processed_d,
  parse_calls,           parse_calls            -lag(parse_calls,1,0)           over (partition by sql_id order by snap.snap_id) as parse_calls_d,
  disk_reads,            disk_reads             -lag(disk_reads,1,0)            over (partition by sql_id order by snap.snap_id) as disk_reads_d,
  buffer_gets,           buffer_gets            -lag(buffer_gets,1,0)           over (partition by sql_id order by snap.snap_id) as buffer_gets_d,
  user_io_wait_time,     user_io_wait_time      -lag(user_io_wait_time,1,0)     over (partition by sql_id order by snap.snap_id) as user_io_wait_time_d,
  concurrency_wait_time, concurrency_wait_time  -lag(concurrency_wait_time,1,0) over (partition by sql_id order by snap.snap_id) as concurrency_wait_time_d,
  cpu_time,              cpu_time               -lag(cpu_time,1,0)              over (partition by sql_id order by snap.snap_id) as cpu_time_d,
  elapsed_time  elapsed_time,  elapsed_time     -lag(elapsed_time,1,0)          over (partition by sql_id order by snap.snap_id) as elapsed_time_d
   from  STATS$SNAPSHOT snap, STATS$SQL_SUMMARY sql
  where snap.snap_id= sql.snap_id
  --and sql_id in ('xxx' ,'zzzz','xxx')
)
group by to_char(snap_time,'YYYYMMDD'), sql_id
order by 5 desc;


-- MI viszi a CPU-t órára lebontva
select 
  to_char(snap_time,'YYYYMMDD HH24') h, sql_id, 
    round(sum(user_io_wait_time_d)/3600/1e6,3) avg_iowait, 
    round(sum(elapsed_time_d)/3600/1e6,3) avg_ela, 
    round(sum(cpu_time_d)/3600/1e6,3) avg_cpu,
    sum(executions_d) execs,
    round(sum(executions_d)/3600,3) execs_per_sec,
    sum(rows_processed_d) rows_processed,      
    sum(buffer_gets_d) gets, 
    round(sum(cpu_time_d/1e6)  /(sum(nvl(executions_d,0))+1.1),2) cpu_sec_per_exec,
    round(sum(rows_processed_d)/(sum(nvl(executions_d,0))+1.1),2) rows_per_exec,
    round(sum(buffer_gets_d)   /(sum(nvl(executions_d,0))+1.1))   gets_per_exec 
from
(select snap.startup_time, snap.snap_id, 
  snap.snap_time,        86400*(snap.snap_time  -lag(snap.snap_time,1  )        over (partition by sql_id order by snap.snap_id)) as snap_time_d_secs,
  sql.sql_id,
  fetches,               fetches                -lag(fetches,1,0)               over (partition by sql_id order by snap.snap_id) as fetches_d,
  end_of_fetch_count,    end_of_fetch_count     -lag(end_of_fetch_count,1,0)    over (partition by sql_id order by snap.snap_id) as end_of_fetch_count_d,
  executions,            executions             -lag(executions,1,0)            over (partition by sql_id order by snap.snap_id) as executions_d,
  rows_processed,        rows_processed         -lag(rows_processed,1,0)        over (partition by sql_id order by snap.snap_id) as rows_processed_d,
  parse_calls,           parse_calls            -lag(parse_calls,1,0)           over (partition by sql_id order by snap.snap_id) as parse_calls_d,
  disk_reads,            disk_reads             -lag(disk_reads,1,0)            over (partition by sql_id order by snap.snap_id) as disk_reads_d,
  buffer_gets,           buffer_gets            -lag(buffer_gets,1,0)           over (partition by sql_id order by snap.snap_id) as buffer_gets_d,
  user_io_wait_time,     user_io_wait_time      -lag(user_io_wait_time,1,0)     over (partition by sql_id order by snap.snap_id) as user_io_wait_time_d,
  concurrency_wait_time, concurrency_wait_time  -lag(concurrency_wait_time,1,0) over (partition by sql_id order by snap.snap_id) as concurrency_wait_time_d,
  cpu_time,              cpu_time               -lag(cpu_time,1,0)              over (partition by sql_id order by snap.snap_id) as cpu_time_d,
  elapsed_time  elapsed_time,  elapsed_time     -lag(elapsed_time,1,0)          over (partition by sql_id order by snap.snap_id) as elapsed_time_d
   from  STATS$SNAPSHOT snap, STATS$SQL_SUMMARY sql
  where snap.snap_id= sql.snap_id
  --and sql_id in ('xxx' ,'zzzz','xxx')
)
group by to_char(snap_time,'YYYYMMDD HH24'), sql_id
order by 5 desc;
/*
H               SQL_ID          IOWAIT  ELA     CPU     EXECS   EXECS_PER_SEC   ROWSS   GETS
20171126 14     3ncyrcy03fb3q   0,001   2,021   2,012   25500   7,083           323631  15202042536
20171126 16     3ncyrcy03fb3q   0,002   1,901   1,895   15775   4,382           268564  8828331590
20171125 14     c6x5ah4nnrs82   0,003   1,627   1,618   18659   5,183           239392  11266258599
20171119 14     9615p6s69m258   0,004   1,622   1,615   19461   5,406           19451   4828725906
20171125 13     c6x5ah4nnrs82   -0,002  1,592   1,588   23428   6,508           294891  9506028357
20171125 15     c6x5ah4nnrs82   0,006   1,436   1,426   14282   3,967           229750  11461222843
20171125 16     c6x5ah4nnrs82   0,006   1,304   1,293   11451   3,181           219656  5490835706
20171124 16     3ncyrcy03fb3q   0,014   1,289   1,271   16669   4,63            199802  9756825099
20171126 17     3ncyrcy03fb3q   0       1,142   1,14    9756    2,71            188392  7935459602
20171119 16     3ncyrcy03fb3q   0,001   1,101   1,098   11241   3,123           160543  17395876083
*/
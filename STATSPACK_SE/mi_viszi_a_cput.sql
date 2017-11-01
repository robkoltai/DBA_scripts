-- MI viszi a CPU-t napra lebontva
select to_char(snap_time,'YYYYMMDD') d, sql_id, 
sum(user_io_wait_time) iowait, sum(buffer_gets) gets , sum(elapsed_time) ela, sum(cpu_time) cpu
from(
  select snap.*, sql.*
  from  STATS$SNAPSHOT snap, STATS$SQL_SUMMARY sql
  where snap.snap_id= sql.snap_id)
group by to_char(snap_time,'YYYYMMDD'), sql_id
order by 6 desc;

-- MI viszi a CPU-t órára lebontva
select to_char(snap_time,'YYYYMMDD HH24') h, sql_id, 
sum(user_io_wait_time) iowait, sum(buffer_gets) gets , sum(elapsed_time) ela, sum(cpu_time) cpu
from(
  select snap.*, sql.*
  from  STATS$SNAPSHOT snap, STATS$SQL_SUMMARY sql
  where snap.snap_id= sql.snap_id)
group by to_char(snap_time,'YYYYMMDD HH24'), sql_id
order by 6 desc;


/*
1       20170314        36jp5u1xwvzdu   86149805        19926856617     654143309145    653352359375
2       20170313        36jp5u1xwvzdu   80661773        17615132943     577237075656    576496046875
3       20170312        36jp5u1xwvzdu   77336856        15162342321     496576591414    495896578125
4       20170311        36jp5u1xwvzdu   76464449        12505735716     409917374759    409291968750
5       20170315        36jp5u1xwvzdu   47494443        11332916806     372072252750    371635703125
6       20170319        36jp5u1xwvzdu   33878615        8777569351      290716331443    290459687500
*/
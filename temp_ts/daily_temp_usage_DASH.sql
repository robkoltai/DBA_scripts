alter session set workarea_size_policy= manual;
alter session set sort_area_size=1000000000;


select to_char(sample_time,'YYYYMMDD') d, max(c) c, max(pgaGB) pgaGB, max (tmpGB) tmpGB
from (
  select sample_time, count(1) c, 
    round(sum(pga_allocated)/1024/1024/1024,2) pgaGB, 
    round(sum(TEMP_SPACE_ALLOCATED)/1024/1024/1024,2) tmpGB 
  from dba_hist_active_sess_history
  group by sample_time
)
group by to_char(sample_time,'YYYYMMDD')
order by 4 desc;


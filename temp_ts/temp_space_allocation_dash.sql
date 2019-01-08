select  temp_space_allocated/1024/1024/1024 gb, dash.*
from DBA_HIST_active_sess_history dash
where to_date('2018.11.23 14:00','YYYY.MM.DD hh24:MI')<sample_time and 
      to_date('2018.11.23 18:00','YYYY.MM.DD hh24:MI')>sample_time 
      -- and program not like '%ARC%' and program not like 'LGWR'
      --and 
      --  ((session_id = 2023 and session_serial#=20673) or program like '%(W004)%'or session_id in (541,361,433,469,577))
and temp_space_allocated is not null 
order by 1 desc;

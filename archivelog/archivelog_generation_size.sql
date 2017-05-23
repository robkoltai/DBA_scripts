     select round(sum(blocks*block_size/1024/1024)) mb,
     trunc(completion_time, 'hh') + floor(to_char(completion_time, 'mi')/15)*15/1440 nearest_15_min
     from v$archived_log
     group by trunc(completion_time, 'hh') + floor(to_char(completion_time, 'mi')/15)*15/1440
     order by 2;


/*
        MB NEAREST_15_MIN
---------- -----------------
        16 20170311 18:00:00
        14 20170311 19:00:00
        15 20170311 20:00:00
        16 20170311 21:00:00
         4 20170311 21:15:00
         3 20170311 21:30:00
       200 20170312 06:00:00
       184 20170312 09:00:00
        15 20170312 10:00:00
        15 20170312 11:00:00
        15 20170312 12:00:00
        15 20170312 13:00:00
        15 20170312 14:00:00
        15 20170312 15:00:00
*/
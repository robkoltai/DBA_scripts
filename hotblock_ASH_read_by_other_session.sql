SELECT count(*) co, 
	to_char(min(sample_time),'HH24:MI:SS') first_time,
	to_char(max(sample_time),'HH24:MI:SS') last_time,
	 SQL_PLAN_HASH_VALUE,
	 FORCE_MATCHING_SIGNATURE     ,
     p1 file_id ,  
     --p2  block_id ,
     o.object_name obj,
       o.object_type otype,
       ash.SQL_ID,
       w.CLASS, event
FROM v$active_session_history ash,
     ( SELECT ROWNUM CLASS#, CLASS FROM v$waitstat ) w,
      all_objects o
WHERE event='read by other session'
   AND w.CLASS#(+)=ash.p3
   AND o.object_id (+)= ash.CURRENT_OBJ#
      AND ash.sample_time > SYSDATE - &MIN/(60*24)
  group by 
		 SQL_PLAN_HASH_VALUE,
	 FORCE_MATCHING_SIGNATURE     ,
	   p1 ,        
       o.object_name ,
         o.object_type ,
         ash.SQL_ID,
       w.CLASS,event
ORDER BY 1 asc;

/*
    COUNT  FIRST_TI LAST_TIM    FILE_ID OBJ                            OTYPE               SQL_ID        CLASS              EVENT
---------- -------- -------- ---------- ------------------------------ ------------------- ------------- ------------------ ----------------------------------------------------------------
      1935 04:47:50 06:28:58        195 DFKKOP~REM                     INDEX               9bzn89vkh7cfb data block         read by other session
      1940 04:47:00 06:28:12        153 DFKKOP~REM                     INDEX               9bzn89vkh7cfb data block         read by other session
      1953 04:47:15 06:28:26        163 DFKKOP~REM                     INDEX               9bzn89vkh7cfb data block         read by other session
      1953 04:43:28 06:23:40         66 DFKKOP~REM                     INDEX               9bzn89vkh7cfb data block         read by other session
      1954 04:46:39 06:27:53        142 DFKKOP~REM                     INDEX               9bzn89vkh7cfb data block         read by other session
*/
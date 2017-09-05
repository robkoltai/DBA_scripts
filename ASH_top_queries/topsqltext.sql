set lines 1111   
   SELECT sql_id, DBtime_secs,  sql_text FROM
   (SELECT NVL(h.SQL_ID,'NULL') as SQL_ID,
   SUM(1) as DBtime_secs,
   substr(sql_text,1,320) sql_text
   FROM V$ACTIVE_SESSION_HISTORY h, v$sqlarea a
   WHERE a.sql_id = h.sql_id 
     and sample_time > SYSDATE - 10/24/60
   GROUP BY h.SQL_ID,substr(a.sql_text,1,320)
   ORDER BY 2 DESC
  )
   WHERE rownum < 10
/

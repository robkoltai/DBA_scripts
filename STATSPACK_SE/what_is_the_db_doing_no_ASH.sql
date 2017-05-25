select event, state, count(*) from v$session_wait group by event, state order by 3 desc;


EVENT                                                            STATE                 COUNT(*)
---------------------------------------------------------------- ------------------- ----------
rdbms ipc message                                                WAITING                      9
SQL*Net message from client                                      WAITING                      8
log file sync                                                    WAITING                      6
gcs remote message                                               WAITING                      2
PL/SQL lock timer                                                WAITING                      2
PL/SQL lock timer                                                WAITED KNOWN TIME            2



select
     count(*),
     CASE WHEN state != 'WAITING' THEN 'WORKING'
          ELSE 'WAITING'
     END AS state,
     CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
          ELSE event
     END AS sw_event
  FROM
     v$session_wait
  GROUP BY
     CASE WHEN state != 'WAITING' THEN 'WORKING'
          ELSE 'WAITING'
     END,
     CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
          ELSE event
     END
  ORDER BY
     1 DESC, 2 DESC
  /

  COUNT(*) STATE   EVENT
---------- ------- ----------------------------------------
        11 WAITING log file sync
         9 WAITING rdbms ipc message
         4 WAITING SQL*Net message from client
         3 WAITING PL/SQL lock timer
         2 WORKING On CPU / runqueue
         2 WAITING gcs remote message
         
         
  select sql_hash_value, count(*) from v$session
  where status = 'ACTIVE' group by sql_hash_value order by 2 desc;
	 
	 SQL_HASH_VALUE   COUNT(*)
	 -------------- ----------
	              0         20
	      966758382          8
	     2346103937          2
	     
	    
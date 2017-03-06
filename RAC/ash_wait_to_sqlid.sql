WITH ash_gc AS
(SELECT /*+ materialize */ inst_id, event, sql_id, COUNT(*) cnt
FROM gv$active_session_history
WHERE 1=1
  --event like lower('%&event%')
  and sample_time > sysdate - 5/(60*24)
GROUP BY inst_id, event, sql_id
HAVING COUNT (*) > &threshold )
SELECT inst_id, sql_id, cnt, event FROM ash_gc
ORDER BY cnt DESC
/
Enter value for event: gc current block 2-way
Enter value for threshold: 100
INST_ID SQL_ID CNT
---------- ------------- ----------
3 26shktr5f1bqk 2717
3 4rfpqz63y34rk 2332
2 4rfpqz63y34rk 2294
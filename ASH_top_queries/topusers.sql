sELECT * FROM
(select user_id,
SUM(1) as DBtime_secs
FROM V$ACTIVE_SESSION_HISTORY
WHERE sample_time > SYSDATE - 10/24/60
GROUP BY user_id
ORDER BY 1 DESC
)
WHERE rownum < 10
/

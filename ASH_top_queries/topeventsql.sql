SELECT * FROM (
	select 	event, u.username, sql_id,
		SUM(1) as DBtime_secs
	FROM V$ACTIVE_SESSION_HISTORY ash,
	     dba_users u
	WHERE sample_time > SYSDATE - 10/24/60
	      and u.user_id = ash.user_id
	GROUP BY event, u.username, sql_id
	ORDER BY sum(1) DESC
)
WHERE rownum < 10
/

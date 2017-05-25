SELECT * FROM (
	select 	event, u.username, sql_id,
		SUM(DELTA_READ_IO_REQUESTS) as io_req
	FROM V$ACTIVE_SESSION_HISTORY ash,
	     dba_users u
	WHERE sample_time > SYSDATE - 30/24/60
	      and u.user_id = ash.user_id
	GROUP BY event, u.username, sql_id
	ORDER BY sum(DELTA_READ_IO_REQUESTS) DESC
)
WHERE rownum < 10
/

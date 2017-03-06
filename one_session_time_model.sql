WITH
db_time AS (SELECT sid, value
 	FROM v$sess_time_model
 	WHERE sid = 137
 	AND stat_name = 'DB time')
SELECT ses.stat_name AS statistic,
 round(ses.value / 1E6, 3) AS seconds,
 round(ses.value / nullif(tot.value, 0) * 1E2, 1) AS "%"
FROM v$sess_time_model ses, db_time tot
WHERE ses.sid = tot.sid
  AND ses.stat_name <> 'DB time'
  AND ses.value > 0
ORDER BY ses.value DESC;



STATISTIC 				SECONDS 	%
--------------------------------------- ---------- ----------
DB CPU 					18.204 		99.3
parse time elapsed 			10.749 		58.6
hard parse elapsed time 		8.048 		43.9
sql execute elapsed time 		1.968 		10.7
connection management call elapsed time .021 .1
PL/SQL execution elapsed time .009 .1
repeated bind elapsed time 0 0
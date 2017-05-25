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


/*
STATISTIC                                                           SECONDS          %
---------------------------------------------------------------- ---------- ----------
DB CPU                                                                 ,712       97,7
sql execute elapsed time                                               ,658       90,3
inbound PL/SQL rpc elapsed time                                        ,639       87,7
parse time elapsed                                                     ,033        4,6
hard parse elapsed time                                                ,016        2,1
hard parse (bind mismatch) elapsed time                                ,013        1,7
hard parse (sharing criteria) elapsed time                             ,013        1,7
PL/SQL execution elapsed time                                          ,007          1
connection management call elapsed time                                ,003         ,5
repeated bind elapsed time                                                0          0
*/
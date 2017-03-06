SELECT
    to_char(TRUNC(sample_time,'MI'),'YYYYMMDD HH24:MI') minute
  , sql_plan_hash_value
  , COUNT(*)/60 avg_act_ses
FROM
    v$active_session_history
  -- dba_hist_active_sess_history
WHERE
    sql_id = '&1'
GROUP BY
    to_char(TRUNC(sample_time,'MI'),'YYYYMMDD HH24:MI')
  , sql_plan_hash_value
ORDER BY
    minute, sql_plan_hash_value
/

/*
MINUTE         SQL_PLAN_HASH_VALUE AVG_ACT_SES
-------------- ------------------- -----------
20160411 11:19          4177104827         .65
20160411 11:20          4177104827           1
20160411 11:21          4177104827           1
20160411 11:22          4177104827           1
20160411 11:23          4177104827  .983333333
20160411 11:24          4177104827           1
20160411 11:25          4177104827           1
*/
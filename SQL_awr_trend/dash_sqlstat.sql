col event for a40
col module for a20
col program for a20
col sql_plan_line_id heading "Plan|Line" for 99999
col plsql_entry_object_id heading "PLSQL|ent.oid" for 99999999
col plsql_object_id heading "PLSQL|oid" for 99999999
col blocking_session heading "Block|sessid" for 999999
col user_id heading "User|id" for 99999
col sql_plan_hash_value heading "plan|hash"
set lines 200
col pars heading "P|a|r|s|e"
col plsql heading "P|L|S|Q|L"
col SQL heading "S|Q|L"

SELECT
    to_char(TRUNC(sample_time,'HH24'),'YYYYMMDD HH24') hour
    --to_char(TRUNC(sample_time,'MI'),'YYYYMMDD HH24:MI') minute
  , COUNT(*)
  , session_id
  , user_id
  , sql_plan_hash_value
  , sql_plan_line_id
  , plsql_entry_object_id
  , plsql_object_id
  , event
  , blocking_session
  , current_obj#
  , in_parse                    pars
  , in_plsql_execution          plsql
  , in_sql_execution            sql
  , program
  , module
  FROM
    --v$active_session_history
    dba_hist_active_sess_history
WHERE
    sql_id = '&1'
GROUP BY
    to_char(TRUNC(sample_time,'HH24'),'YYYYMMDD HH24') 
    --to_char(TRUNC(sample_time,'MI'),'YYYYMMDD HH24:MI')
        , session_id
          , user_id
          , sql_plan_hash_value
          , sql_plan_line_id
          , plsql_entry_object_id
          , plsql_object_id
          , event
          , blocking_session
          , current_obj#
          , in_parse
          , in_plsql_execution
          , in_sql_execution
          , program
          , module
ORDER BY
    hour
    --minute 
    , count(*)
  ;

--select sql_id, count(1) from dba_hist_active_sess_history group by sql_id order by 2;
/*
                                                                                                                                             P P
                                                                                                                                             a L
                                                                                                                                             r S S
                                    User       plan   Plan     PLSQL     PLSQL                                            Block              s Q Q
HOUR          COUNT(*) SESSION_ID     id       hash   Line   ent.oid       oid EVENT                                     sessid CURRENT_OBJ# e L L PROGRAM              MODULE
----------- ---------- ---------- ------ ---------- ------ --------- --------- ---------------------------------------- ------- ------------ - - - -------------------- --------------------
20161014 15        211         49      0 1252476278      1     16903           enq: TX - row lock contention                 72           -1 N N N oracle@buda (M001)   MMON_SLAVE
20161014 16        149         49      0 1252476278      1     16903           enq: TX - row lock contention                 72           -1 N N N oracle@buda (M001)   MMON_SLAVE
20161019 20          1         58      0 1252476278      1     16903                                                                    8106 N N N oracle@buda (M001)   MMON_SLAVE

*/
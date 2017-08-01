select * from gv$active_session_history WHERE sample_time > SYSDATE - 5/60/24/60 order by sample_id desc , INSt_id;

-- TOP SQL
sELECT * FROM (
        select  max(sample_time)-       min(sample_time), event, u.username, sql_id, inst_id,
                SUM(1) as DBtime_secs
        FROM gV$ACTIVE_SESSION_HISTORY ash,
             dba_users u
        WHERE sample_time > SYSDATE - 50/24/60 -- Minutes
              and u.user_id = ash.user_id 
          --and username is not null and username <> 'SYS'
        GROUP BY event, u.username, sql_id, inst_id
        ORDER BY sum(1) DESC
)
WHERE rownum < 10
/

-- TOP EVENT
sELECT * FROM (
        select  max(sample_time)-       min(sample_time), event,  inst_id, user_id, sql_id,
                SUM(1) as DBtime_secs
        FROM gV$ACTIVE_SESSION_HISTORY ash           
        WHERE sample_time > SYSDATE - 90/24/60 -- Minutes
        GROUP BY event, inst_id, user_id, sql_id
        ORDER BY sum(1) DESC
)
WHERE rownum < 50
/


-- TOP SQL - event
sELECT * FROM (
        select  max(sample_time)-       min(sample_time), count(distinct sql_exec_id) runcount, 
  u.username, sql_id, inst_id,
                SUM(1) as DBtime_secs
        FROM gV$ACTIVE_SESSION_HISTORY ash,
             dba_users u
        WHERE sample_time > SYSDATE - 10/24/60 -- Minutes
              and u.user_id = ash.user_id and username is not null and username <> 'SYS'
        GROUP BY u.username, sql_id, inst_id
        ORDER BY sum(1) DESC
)
WHERE rownum < 10
;

-- DBTIME SQL with text
   SELECT * FROM
   (SELECT a.inst_id, NVL(h.SQL_ID,'NULL') as SQL_ID, 
   SUM(1) as DBtime_secs,
   substr(sql_text,1,120) sql_text
   FROM gV$ACTIVE_SESSION_HISTORY h, gv$sqlarea a
   WHERE a.sql_id = h.sql_id 
     and h.inst_id=a.inst_id
     and sample_time > SYSDATE - 20/24/60
   GROUP BY h.SQL_ID,substr(a.sql_text,1,120), a.inst_id
   ORDER BY 3 DESC
  )
   WHERE rownum < 10;

-- SQL BY PLAN HASH VALUE
select count(1),
     inst_id,sql_id, 
     sql_opname,
     --top_level_sql_id, 
     sql_plan_hash_value
from gv$active_session_history 
where sample_time > sysdate - 10/(60*24)
group by 
     inst_id, sql_id, 
     sql_opname,
     --top_level_sql_id, 
     sql_plan_hash_value
order by count(1) desc;


-- 1 SQL PLAN LINE ID
select count(1),
     inst_id,
        max(sample_time)-       min(sample_time), sql_id, sql_plan_line_id,
     sql_opname,
     --top_level_sql_id, 
     sql_plan_hash_value
from gv$active_session_history 
where sample_time > sysdate - 10/(60*24)
      and sql_id = '&sql_id'
group by 
     inst_id, sql_id, sql_plan_line_id,
     sql_opname,
     --top_level_sql_id, 
     sql_plan_hash_value
order by count(1) desc;

-- FORCE MATCHING SIGNATURE
select max(sample_time)-        min(sample_time), count(1),
     event,
     inst_id, count (distinct sql_id), max(sql_id), FORCE_MATCHING_SIGNATURE, 
     sql_plan_hash_value
from gv$active_session_history 
where sample_time > sysdate - 60/(60*24)
group by 
     inst_id, FORCE_MATCHING_SIGNATURE, 
     sql_plan_hash_value,
     event     
order by count(1) desc;

SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ALLSTATS LAST -PROJECTION'))
/

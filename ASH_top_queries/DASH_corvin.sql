
-- HOURLY CPU, WAIT, AAS
select to_char((sample_time),'YYYY-MM-DD HH24') ora,
       sum(10) osszes_aktiv_session_minta,
       round(sum(10) /60/60,2) atlagos_aktiv_session,
       round(sum(case when session_state = 'ON CPU' then 10 else 0 end)/60/60,2) atlagos_cpu,
       round(sum(case when session_state = 'WAITING' then 10 else 0 end)/60/60,2) atlagos_varakozas
from dba_hist_active_sess_history
group by to_char((sample_time),'YYYY-MM-DD HH24')
order by 1 desc;


-- Last few minutes most avtive user
select u.user_id, u.username, 
       sum(10) minta, 
       round(sum(10)/&perc/60 ,2) atlagos_aktivitas,
       round(sum(case when session_state = 'ON CPU' then 10 else 0 end)/&perc/60,2) atlagos_cpu,
       round(sum(case when session_state = 'WAITING' then 10 else 0 end)/&perc/60,2) atlagos_varakozas
from  dba_hist_active_sess_history ash, 
     dba_users u
where u.user_id = ash.user_id --and ash.dbid=u.dbid
      and sample_time > sysdate - &perc/24/60 
group by u.user_id, u.username
order by sum(10) desc;


-- Most active SQL in last n minutes
select ash.sql_id, ash.sql_plan_hash_value, 
       sum(10) minta, 
       round(sum(10)/&perc/60 ,2) atlagos_aktivitas,
       round(sum(case when session_state = 'ON CPU' then 10 else 0 end)/&perc/60,2) atlagos_cpu,
       round(sum(case when session_state = 'WAITING' then 10 else 0 end)/&perc/60,2) atlagos_varakozas,
       dbms_lob.substr(s.sql_text,500,1) as sql_500
from dba_hist_active_sess_history ash, 
     dba_hist_sqltext s
where     ash.sql_id = s.sql_id (+)
      and sample_time > sysdate - &perc/24/60 
group by ash.sql_id, ash.sql_plan_hash_value, dbms_lob.substr(s.sql_text,500,1) 
order by sum(10) desc;

/* Kimenet példa*/
"SQL_ID"	"SQL_PLAN_HASH_VALUE"	"MINTA"	"ATLAGOS_AKTIVITAS"	"ATLAGOS_CPU"	"ATLAGOS_VARAKOZAS"	"SQL_TEXT"
"1128h8u63ayys"	18535071			44	0,15			0,15		0			"SELECT szurttabla.* FROM ..."
"0td387vx9dv1b"	1326135624		9	0,03			0,03		0			"select C_EN..."
"7yzm0nqugt7un"	2527640415		6	0,02			0,02		0			"select /*+ Student_305_..."
"9f6m3zknngf6u"	3111569004		2	0,01			0,01		0			"SELECT COUNT(:""SYS_B_00"")..."

-- Check one SQL
select ash.sql_id, ash.sql_plan_hash_value, --ash.current_obj#,
       o.owner, o.object_name, ash.event, ash.sql_plan_line_id,
       sum(10) minta, 
       round(sum(10)/&perc/60 ,2) atlagos_aktivitas,
       round(sum(case when session_state = 'ON CPU' then 10 else 0 end)/&perc/60,2) atlagos_cpu,
       round(sum(case when session_state = 'WAITING' then 10 else 0 end)/&perc/60,2) atlagos_varakozas,
       dbms_lob.substr(s.sql_text,500,1) as sql
from dba_hist_active_sess_history ash, 
     dba_hist_sqltext s,
     dba_objects o
where     ash.sql_id = s.sql_id (+)
      and ash.dbid   = s.dbid   (+)
      and sample_time > sysdate - &perc/24/60 
      and ash.sql_id = '&sql_id'
      and ash.current_obj# = o.object_id (+)
group by ash.sql_id, ash.sql_plan_hash_value, o.owner, o.object_name,
         --ash.current_obj#, 
         ash.event, ash.sql_plan_line_id, dbms_lob.substr(s.sql_text,500,1) 
order by sum(10) desc; 

-- Most significant WAIT event
select event,
       sum(10) osszes_aktiv_session_minta,
       round(sum(10) /&perc/60,2) atlagos_aktiv_session,
       round(sum(case when session_state = 'ON CPU' then 10 else 0 end)/&perc/60,2) atlagos_cpu,
       round(sum(case when session_state = 'WAITING' then 10 else 0 end)/&perc/60,2) atlagos_varakozas
from dba_hist_active_sess_history ash
where sample_time > sysdate - &perc/24/60 
group by event
order by 2 desc;

-- Most significant CLIENT, module, action
select program, module, action,
       sum(10) minta,
       round(sum(10) /&perc/60,2) atlagos_aktiv_session,
       round(sum(case when session_state = 'ON CPU' then 10 else 0 end)/&perc/60,2) atlagos_cpu,
       round(sum(case when session_state = 'WAITING' then 10 else 0 end)/&perc/60,2) atlagos_varakozas
from dba_hist_active_sess_history ash
where sample_time > sysdate - &perc/24/60 
group by program, module, action
order by count(10) desc;

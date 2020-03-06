
-- SPA relevant
select * from DBA_ADVISOR_DEF_PARAMETERS ;
select * from DBA_ADVISOR_EXECUTIONS where task_id = '28517';
select * from DBA_ADVISOR_EXECUTION_TYPES;
select * from DBA_ADVISOR_EXEC_PARAMETERS where task_id = '28517';

select * from DBA_ADVISOR_FINDINGS where task_id = '28517'; -- itt vannak a finding-ok miaz object id???
select * from DBA_ADVISOR_OBJECTS where task_id = '28517';
select * from DBA_ADVISOR_SQLPLANS where task_id = '28517';
select * from DBA_ADVISOR_SQLSTATS where task_id = '28517';

-- object ids do not match.
/*
select obj.task_id, obj.object_id, obj.type, obj.execution_name exec_name, obj.attr1 obj_sql_id, obj.attr10 execs, obj.attr17, obj.adv_sql_id,
find.type, find.impact, find.message,
stat.sql_id stat_sql_id, executions, end_of_fetch_count, parse_time, elapsed_time, cpu_time, user_io_time, buffer_gets
from 
DBA_ADVISOR_FINDINGS find, DBA_ADVISOR_OBJECTS obj, DBA_ADVISOR_SQLSTATS stat
where find.task_id = '28599' 
  and obj.task_id = find.task_id and obj.execution_name = find.execution_name and obj.object_id = find.object_id
  and stat.task_id = obj.task_id and stat.execution_name = obj.execution_name and stat.object_id = obj.object_id
  ;
*/

-- OBJ FINDINGS SQLS. Obj es findings
select obj.task_id, obj.object_id, obj.type, obj.execution_name exec_name, obj.attr1 obj_sql_id, obj.attr10 execs, obj.attr17, obj.adv_sql_id,
find.type, find.impact, find.message, s.sql_text
--stat.sql_id stat_sql_id, executions, end_of_fetch_count, parse_time, elapsed_time, cpu_time, user_io_time, buffer_gets
from DBA_ADVISOR_FINDINGS find, DBA_ADVISOR_OBJECTS obj, dba_hist_sqltext s
where find.task_id = '28599' 
  and obj.task_id = find.task_id and obj.execution_name = find.execution_name and obj.object_id = find.object_id
  and s.sql_id = obj.attr1
  and obj.attr1 in ('6620b9r10c7sp','b1q74qvx9k37j','bj4vdvmm3xh28','dq80ypampmfb6')
order by 5,8  ;

-- obj stats SQLS
select obj.task_id, obj.object_id, obj.type, obj.execution_name exec_name, obj.attr1 obj_sql_id, obj.attr10 execs, obj.attr17, obj.adv_sql_id,
--find.type, find.impact, find.message, 
s.sql_text,
stat.sql_id stat_sql_id, executions, end_of_fetch_count, parse_time, elapsed_time, cpu_time, user_io_time, buffer_gets
from  DBA_ADVISOR_SQLSTATS stat, DBA_ADVISOR_OBJECTS obj, dba_hist_sqltext s
where obj.task_id = '28599' 
  and stat.task_id = obj.task_id and stat.execution_name = obj.execution_name and stat.object_id = obj.object_id
  and s.sql_id = obj.attr1
  and executions is not null
  and obj.attr1 in ('6620b9r10c7sp','b1q74qvx9k37j','bj4vdvmm3xh28','dq80ypampmfb6')
order by 5,4 desc;



-- THE REST
select * from DBA_ADVISOR_JOURNAL where task_id = '28517';
select * from DBA_ADVISOR_LOG where task_id = '28517';


select * from DBA_ADVISOR_ACTIONS where task_id = '28517';
select * from DBA_ADVISOR_COMMANDS;
select * from DBA_ADVISOR_DEFINITIONS;
select * from DBA_ADVISOR_DEF_PARAMETERS ;
select * from DBA_ADVISOR_DIR_DEFINITIONS where task_id = '28517';
select * from DBA_ADVISOR_DIR_INSTANCES where task_id = '28517';
select * from DBA_ADVISOR_DIR_TASK_INST where task_id = '28517';
select * from DBA_ADVISOR_EXECUTIONS where task_id = '28517';
select * from DBA_ADVISOR_EXECUTION_TYPES;
select * from DBA_ADVISOR_EXEC_PARAMETERS where task_id = '28517';
select * from DBA_ADVISOR_FDG_BREAKDOWN where task_id = '28517';
select * from DBA_ADVISOR_FINDINGS where task_id = '28517';
select * from DBA_ADVISOR_FINDING_NAMES ;
select * from DBA_ADVISOR_JOURNAL where task_id = '28517';
select * from DBA_ADVISOR_LOG where task_id = '28517';
select * from DBA_ADVISOR_OBJECTS where task_id = '28517';
select * from DBA_ADVISOR_OBJECT_TYPES where task_id = '28517';
select * from DBA_ADVISOR_PARAMETERS where task_id = '28517';
select * from DBA_ADVISOR_PARAMETERS_PROJ where task_id = '28517';
select * from DBA_ADVISOR_RATIONALE where task_id = '28517';
select * from DBA_ADVISOR_RECOMMENDATIONS where task_id = '28517';
select * from DBA_ADVISOR_SQLA_COLVOL where task_id = '28517';
select * from DBA_ADVISOR_SQLA_REC_SUM where task_id = '28517';
select * from DBA_ADVISOR_SQLA_TABLES where task_id = '28517';
select * from DBA_ADVISOR_SQLA_TABVOL where task_id = '28517';
select * from DBA_ADVISOR_SQLA_WK_MAP where task_id = '28517';
select * from DBA_ADVISOR_SQLA_WK_STMTS where task_id = '28517';
select * from DBA_ADVISOR_SQLA_WK_SUM where task_id = '28517';
select * from DBA_ADVISOR_SQLPLANS where task_id = '28517';
select * from DBA_ADVISOR_SQLSTATS where task_id = '28517';
select * from DBA_ADVISOR_SQLW_COLVOL where task_id = '28517';
select * from DBA_ADVISOR_SQLW_JOURNAL where task_id = '28517';
select * from DBA_ADVISOR_SQLW_PARAMETERS where task_id = '28517';
select * from DBA_ADVISOR_SQLW_STMTS where task_id = '28517';
select * from DBA_ADVISOR_SQLW_SUM where task_id = '28517';
select * from DBA_ADVISOR_SQLW_TABLES where task_id = '28517';
select * from DBA_ADVISOR_SQLW_TABVOL where task_id = '28517';
select * from DBA_ADVISOR_SQLW_TEMPLATES where task_id = '28517';
select * from DBA_ADVISOR_TASKS where task_id = '28517';
select * from DBA_ADVISOR_TEMPLATES where task_id = '28517';
select * from DBA_ADVISOR_USAGE where task_id = '28517';

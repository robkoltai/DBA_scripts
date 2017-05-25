--_cursor_plan_unparse_enabled=TRUE is the database default.
-- Du to several bugs in the current RDBMs, it might be set
-- otherwise on your box. Change it to TRUE to make valuable
-- predicate information visible.
ALTER SESSION SET "_cursor_plan_unparse_enabled"=TRUE;

define OHV=<your OHV from STATSPACK report>
undefine CHILD_NUMBER

select SQL_ID from v$SQLAREA where old_hash_value=&&OHV;

select inst_id, child_number, plan_hash_value
  from gv$sql_plan 
  where SQL_ID=(select SQL_ID from v$SQLAREA where old_hash_value=&&OHV)
  group by inst_id, child_number, plan_hash_value
  order by inst_id, child_number
  ;

select * from gv$sqlarea where sql_id=(select SQL_ID from v$SQLAREA where old_hash_value=&&OHV);

select 'exec sys.dbms_shared_pool.purge ('''||address||','||hash_value||''', ''C'');' from gv$sql where sql_id=(select SQL_ID from v$SQLAREA where old_hash_value=&&OHV);

select inst_id, plan_hash_value, executions, buffer_gets, round(buffer_gets/nvl(executions,0),0) as BG_average from gv$sql 
where sql_id=(select SQL_ID from v$SQLAREA 
  where old_hash_value=&&OHV) order by inst_id,plan_hash_value;


SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR
  ((select SQL_ID from v$SQLAREA 
  where old_hash_value=&&OHV),&&CHILD_NUMBER,'COST,IOSTATS,LAST'));
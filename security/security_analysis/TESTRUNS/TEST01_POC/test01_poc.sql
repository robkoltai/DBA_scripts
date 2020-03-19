REPLAY01
/*
-- REPLAY inditasa elott
-- Konfigure PRIVILEGE CAPTURE and AUDIT features
*/
-- PRIVILEGE CAPTURE
begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'RATREPLAY01_PRIV',
   type            => dbms_privilege_capture.g_context,
   condition       => 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''GOFFRI'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''INF_CSISZAR_L'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''xx'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''xx'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''SCHEMA'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''xx'' OR SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''xx''');

end;
/

begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'RATREPLAY01_PRIV',
  'RUN1');
end;
/

--- START UNIFIED AUDIT FOR DBA ROLE
create audit policy audit_dba_role roles dba;
audit policy audit_dba_role;


-- TRADITIONAL AUDIT SYNONYM-okra
-- statement audit kikapcsolasa a mar meglevo auditokra
select 'noaudit ' || audit_option || ';' from DBA_STMT_AUDIT_OPTS order by 1;
-- truncate table sys.aud$;
truncate table sys.aud$;

-- szinonymak auditalasa
-- generate audit, noaudit scripts

column the_command format a60
set lines 180
set pages 200
column warrning format a22
column target format a60
set echo off
set feedback off
spool aud.sql

select rpad('&no_or_null' || 'audit all on ' || synonym_name || ';',50)  as the_command ,
 ' --' || table_owner || '.' || table_name as target,
 case when synonym_name <> table_name then 'MAS A NEV !!!!' end as warrning
from dba_synonyms
where owner='PUBLIC' and table_owner in (
  select username 
  from dba_users
  where oracle_maintained = 'N')
order by table_owner, table_name;
spool off


/*
*/


-- extended audit bekapcsolva
XML, EXTENDED



-------------------------------------
-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'RATREPLAY01_PRIV');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'RATREPLAY01_PRIV',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/




--------------------------------------


-- REPLAY ESZREVETELEK
------------------------------------------------------
-- PGA_AGGREGATE_LIMIT reached
	JUT:
	pga_aggregate_limit                  3600M
	pga_aggregate_target                 500M

-- RESOURCE BUSY sok helyen PREPARE_REPLAY-t SCN-ezni kene
	Trace file C:\app\diag\clients\user_localuser\host_2299682446_107\trace\wrc_r02934_7916.trc
	2019-09-19 00:12:49.304 :keclro.c@5438: Cursor 140376465211816 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:13:01.008 :keclro.c@5438: Cursor 140376465445248 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:13:06.889 :keclro.c@5438: Cursor 140376467316160 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:14:07.235 :keclro.c@5438: Cursor 140376467190280 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:14:36.597 :keclro.c@5438: Cursor 140376464263912 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:14:39.704 :keclro.c@5438: Cursor 140376465377248 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:14:53.169 :keclro.c@5438: Cursor 140376464169040 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:14:58.878 :keclro.c@5438: Cursor 140376465484576 (oct=26) got ORA-00054. Skip its execution.
	2019-09-19 00:15:04.023 :keclro.c@5438: Cursor 140376462962632 (oct=26) got ORA-00054. Skip its execution.
-- SYSAUX tablespace
	ORA-1688: unable to extend table AUDSYS.AUD$UNIFIED partition SYS_P2415 by 8192 in tablespace SYSAUX
	Unified Audit record write to audit trail table failed due to ORA-1688. Writing the record to OS spillover file.
	2019-09-18T21:02:16.607926+02:00
	ORA-1692: unable to extend lobsegment AUDSYS.SYS_LOB0001555744C00030$$ partition SYS_LOB_P2416 by 1024 in tablespace SYSAUX (ospid 30940)
	ORA-1692: unable to extend lobsegment AUDSYS.SYS_LOB0001555744C00030$$ partition SYS_LOB_P2416 by 1024 in tablespace SYSAUX (ospid 30940)
	Unified Audit record write to audit trail table failed due to ORA-1692. Writing the record to OS spillover file.
	2019-09-18T21:02:16.646861+02:00
-- PRIVILEGE ANALYSIS NEM VETTE FEL AMIT AKARTUNK
	legyen terminal = GB61797 or host = GARANCIA\GB61797

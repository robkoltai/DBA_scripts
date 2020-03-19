-- newer REMOVE CAPTURE FILES from disk
-- Postprocess again!!!
-- copy paste again!!!

-- ******************************
-- GENERAL DB CLEANUP STEPS
-- ******************************
-- job_queue_processes
alter system set job_queue_processes=0;

-- alter user dbsnmp
alter user dbsnmp account lock;

-- STOP CAPTURE ha meg fut
select * from dba_workload_captures;
exec DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE (30,'Mar epp eleg volt');

-- ******************************
-- DBA ROLE - UNIFIED AUDIT -- CLEANUP
-- ******************************
--- START UNIFIED AUDIT FOR DBA ROLE, but before that creanup the unified audit trail
-- This delete was not done in REPLAY02, but should be done in future
exec dbms_audit_mgmt.clean_audit_trail (audit_trail_type=>dbms_audit_mgmt.audit_trail_unified, use_last_arch_timestamp=>FALSE);

-- avagy
exec dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type=>dbms_audit_mgmt.audit_trail_unified
,last_archive_time=>to_date('20190926 11:00','YYYYMMDD HH24:MI'));
exec dbms_audit_mgmt.clean_audit_trail(audit_trail_type=>dbms_audit_mgmt.audit_trail_unified
,use_last_arch_timestamp=>TRUE);

-- ******************************
-- TRADITIONAL AUDIT SYNONYM-okra -- CECK and CLEANUP
-- ******************************
-- CHECK
-- extended audit bekapcsolva?
alter system set audit_trail=XML, EXTENDED  scope=spfile;
--XML, EXTENDED


-- CLEANUP I
-- statement audit kikapcsolasa a mar meglevo auditokra
set pages 200
select 'noaudit ' || audit_option || ';' from DBA_STMT_AUDIT_OPTS order by 1;

-- check minden ures kell legyen
select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_PRIV_AUDIT_OPTS;
select * from DBA_OBJ_AUDIT_OPTS;
truncate table sys.aud$;


-- CLEANUP II
-- CLEAN XML AUDIT TRAIL
-- Check parameter audit_file_dest /var/opt/oracle/audlog/db_xml/
shutdown immediate;
cd /var/opt/oracle/audlog/db_xml/PFSJUT
--rm *
startup;

select count(*) from v$xml_audit_trail;



-- ****************************************************************************
-- REPLAY inditasa elott CONFIGURE
-- ****************************************************************************
-- ******************************
-- PRIVILEGE CAPTURE
-- ******************************

-- NON SYS user gets stupid error
--ORA-47951: invalid input value or length for parameter 'condition'
--ORA-06512: at "SYS.DBMS_PRIVILEGE_CAPTURE", line 3
--ORA-06512: at line 2
conn / as sysdba
begin
  DBMS_PRIVILEGE_CAPTURE.DROP_CAPTURE (
  'RATREPLAY05_PRIV');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'RATREPLAY05_PRIV',
   type            => dbms_privilege_capture.g_context,
   condition       => 'SYS_CONTEXT(''USERENV'', ''TERMINAL'') = ''GB61797''');
end;
/

-- INDITHATJUK AKAR MOST IS, mert a terminalrol ugysem jo mas
begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'RATREPLAY05_PRIV',
  'RUN1');
end;
/



-----------------------*************************
-----------------------    DO ALL THE SQLs

-- DROP PUBLIC SYNONYMS THAT were identified previously
-- SAJNOS ez CAP01_REP03-ban kimaradt, ezert van sok audit rekord...

-- hibak ignoralhatoak
--ORA-00955: name is already used by an existing object
@out/trad_aud_01_create_synonym_instead_of_public.sql


@out/trad_aud_02_drop_public_synonym.sql
-- OPCIONALISAN, ha batrak vagyunk. Ezeket nem hasznalta senki
@out/trad_aud_03_drop_unused_public_synonym.sql



-- TYPE okat is revokolja
@out/priv_ana_01_public_level1_revoke.sql

@out/priv_ana_03_obj_revoke.sql
@out/priv_ana_08_revoke_unused_multilevel.sql -- 2 hiba ignoralható, mert elvettuk elobb toluk
@out/priv_ana_09_revoke_level1_sysprivs.sql
@out/priv_ana_05_sys_revoke.sql		-- Ez itt tok fals, mar mindent visszavontunk
@out/priv_ana_07_revoke_unused_level1_direct.sql

@out/manual_01_error_correction_grants.sql
@out/priv_ana_10_grant_level1_sysprivs.sql
@out/priv_ana_02_public_level1_grant.sql
@out/priv_ana_04_obj_grant.sql
@out/priv_ana_06_sys_grant.sql

@out/priv_ana_10_grant_level1_sysprivs.sql
@out/priv_ana_02_public_level1_compile.sql


-----------------------*************************



-- ******************************
-- DBA ROLE - UNIFIED AUDIT -- CONFIGURE
-- ******************************
create audit policy audit_dba_role roles dba;
audit policy audit_dba_role;

-- ******************************
-- TRADITIONAL AUDIT SYNONYM-okra -- CONFIGURE
-- ******************************


-- SZINONYMAK AUDITALASA - nyilvan csak a maradekot
-- generate audit, noaudit scripts
column the_command format a60
set lines 180
set pages 200
column warrning format a22
column target format a60
set echo off
set feedback off
spool aud.sql

select rpad('&no_or_null' || 'audit all on ' || synonym_name || ';',50)  as the_command
 -- , ' --' || table_owner || '.' || table_name as target,
 -- case when synonym_name <> table_name then 'MAS A NEV !!!!' end as warrning
from dba_synonyms
where owner='PUBLIC' and table_owner in (
  select username 
  from dba_users
  where oracle_maintained = 'N')
order by table_owner, table_name;

spool off


-- ******************************
-- PUBLIC GRANTS-ok is vannak am
-- ******************************

select * from dba_tab_privs 
where grantee='PUBLIC' and owner in (select username from dba_users where oracle_maintained='N')
order by 1,2,3;







--------------------------------------
--POST PROCESS
-------------------------------------
-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'RATREPLAY05_PRIV');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'RATREPLAY05_PRIV',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/



--------------------------------------


-- REPLAY ESZREVETELEK
------------------------------------------------------
--****************
-- REPLAY01 POC
--****************
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

--****************
-- REPLAY02 POC
--****************
-- DROP public synonym-ot meg kene gondolni
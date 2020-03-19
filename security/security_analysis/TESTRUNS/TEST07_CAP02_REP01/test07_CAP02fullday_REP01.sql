-- **********************************************************************************
-- DO THE 
--  RAT CAPTURE
--  RAT PREPROCESSING 
--  AND THEN RUN THESE STEPS BEFORE RUNNING THE REPLAY
-- **********************************************************************************
-- **********************************************************************************


-- ******************************
-- GENERAL DB CLEANUP STEPS
-- ******************************
-- job_queue_processes
alter system set job_queue_processes=0;

-- alter user dbsnmp
alter user dbsnmp account lock;

-- STOP CAPTURE ha meg fut
-- Ez csak akkor fontos, ha a RAC CAPTURE KLONOZAS ELOTT VOLT INDITVA
-- EKKOR a KLONOZOTT adatbazis is minden frantot fel akar venni
select * from dba_workload_captures;
exec DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE (2,'Mar epp eleg volt');

-- ******************************
-- setup flashback database ha akarjuk
-- ******************************
shutdown immediate;
startup mount;
alter database archivelog;
alter database flashback on;
alter database open;

create restore point before_revokes_grants guarantee flashback database;

-- ******************************
-- Mentsuk el az invalid objektumok listajat
-- ******************************

-- Hozzuk letre a PA felhasznalot !!
@PA_setup_preprocess.sql

conn pa/pa

create table rk_invalid_objects_pre_test 
tablespace rk_priv_ana as
select * from dba_objects where status = 'INVALID';

-- as sys
@$ORACLE_HOME/rdbms/admin/utlrp.sql

conn pa/pa
create table rk_invalid_objects_pre_test_comped
tablespace rk_priv_ana as
select * from dba_objects where status = 'INVALID';

-- Ezeket tudtuk leforditani
select * from rk_invalid_objects_pre_test_comped minus select * from rk_invalid_objects_pre_test


--*********************************************************************
--   DO ALL THE SQLs
--*********************************************************************
-- itt valtoztatjuk meg a security-t
-- az elozo felmereseink alapjan
conn / as sysdba

@out/RUNALL.sql


alter system set job_queue_processes=10;
@$ORACLE_HOME/rdbms/admin/utlrp.sql
alter system set job_queue_processes=0;



-- ******************************
-- ha mar nem kell a flashback database
-- ******************************
drop restore point  BEFORE_REVOKES_GRANTS;

shutdown immediate;
startup mount;

alter database flashback off;
alter database noarchivelog;

alter database open;
-- ******************************
-- DBA ROLE - UNIFIED AUDIT -- CLEANUP
-- ******************************
--- START UNIFIED AUDIT FOR DBA ROLE, but before that creanup the unified audit trail
-- This delete was not done in REPLAY02, but should be done in future

conn / as sysdba
exec dbms_audit_mgmt.clean_audit_trail (audit_trail_type=>dbms_audit_mgmt.audit_trail_unified, use_last_arch_timestamp=>FALSE);

-- avagy
exec dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type=>dbms_audit_mgmt.audit_trail_unified
,last_archive_time=>to_date('20190926 11:00','YYYYMMDD HH24:MI'));
exec dbms_audit_mgmt.clean_audit_trail(audit_trail_type=>dbms_audit_mgmt.audit_trail_unified
,use_last_arch_timestamp=>TRUE);

-- ******************************
-- TRADITIONAL AUDIT SYNONYM-okra -- CHECK and CLEANUP
-- ******************************
-- CHECK
-- extended audit bekapcsolva?
alter system set audit_trail=XML, EXTENDED  scope=spfile;
--XML, EXTENDED


-- CLEANUP I
-- statement audit kikapcsolasa a mar meglevo auditokra
set pages 200
select 'noaudit ' || audit_option || ';' from DBA_STMT_AUDIT_OPTS order by 1;

/*
noaudit ALTER ANY PROCEDURE;
noaudit ALTER ANY TABLE;
noaudit ALTER DATABASE;
noaudit ALTER PROFILE;
noaudit ALTER SYSTEM;
noaudit ALTER USER;
noaudit BECOME USER;
noaudit CLUSTER;
noaudit CONTEXT;
noaudit CREATE ANY JOB;
noaudit CREATE ANY LIBRARY;
noaudit CREATE ANY PROCEDURE;
noaudit CREATE ANY TABLE;
noaudit CREATE EXTERNAL JOB;
noaudit CREATE PUBLIC DATABASE LINK;
noaudit CREATE SESSION;
noaudit CREATE USER;
noaudit DATABASE LINK;
noaudit DIMENSION;
noaudit DIRECTORY;
noaudit DROP ANY PROCEDURE;
noaudit DROP ANY TABLE;
noaudit DROP PROFILE;
noaudit DROP USER;
noaudit EXEMPT ACCESS POLICY;
noaudit GRANT ANY OBJECT PRIVILEGE;
noaudit GRANT ANY PRIVILEGE;
noaudit GRANT ANY ROLE;
noaudit INDEX;
noaudit NOT EXISTS;
noaudit PLUGGABLE DATABASE;
noaudit PROCEDURE;
noaudit PROFILE;
noaudit PUBLIC DATABASE LINK;
noaudit PUBLIC SYNONYM;
noaudit ROLE;
noaudit ROLLBACK SEGMENT;
noaudit SEQUENCE;
noaudit SYNONYM;
noaudit SYSTEM AUDIT;
noaudit SYSTEM GRANT;
noaudit TABLE;
noaudit TABLESPACE;
noaudit TRIGGER;
noaudit TYPE;
noaudit USER;
noaudit VIEW;
*/

-- check minden ures kell legyen
select * from DBA_STMT_AUDIT_OPTS;
select * from DBA_PRIV_AUDIT_OPTS;
select * from DBA_OBJ_AUDIT_OPTS;
truncate table sys.aud$;


-- CLEANUP II
-- CLEAN XML AUDIT TRAIL
-- Check parameter audit_file_dest /var/opt/oracle/audlog/db_xml/

crontab -e 
comment out: /home/oracle/oramaint/scripts/audit/combine_xmlaud.py

shutdown immediate;
cd /var/opt/oracle/audlog/db_xml/PFSJUT
pwd
ls -altr
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
  'CAP02_REP01_FULLDAY');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'CAP02_REP01_FULLDAY',
   type            => dbms_privilege_capture.g_context,
   condition       => 'SYS_CONTEXT(''USERENV'', ''TERMINAL'') = ''GB61797''');
end;
/

-- INDITHATJUK AKAR MOST IS, mert a terminalrol ugysem jo mas
begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'CAP02_REP01_FULLDAY',
  'RUN1');
end;
/




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
-- MINDEN DML HIBA AUDITALASA, ha akarunk ilyet
-- Akkor akarunk ilyet, ha visszavontuk mar a magas jogokat es azt vizsgaljuk, hogy
-- mi kell meg. Ami hibara fut, ahhoz kellhet grant
-- ******************************
create audit policy DML_errs actions select, insert, delete, update, merge, truncate table; 
audit policy DML_errs whenever not successful;

-- ******************************
-- PUBLIC GRANTS-ok is vannak am
-- ******************************
-- Ez erdekes, de mit keres itt(:
select * from dba_tab_privs 
where grantee='PUBLIC' and owner in (select username from dba_users where oracle_maintained='N')
order by 1,2,3;







--------------------------------------
--POST PROCESS
-------------------------------------
-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'CAP02_REP01_FULLDAY');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'CAP02_REP01_FULLDAY',
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

--****************
-- REPLAY05 
--****************


-- alert.log tele van parsing errorral 1031-es. Hoppa ezt ellenorizni kene.
-- 06575 04063 00942 01031
/*[oracle@sodb5 PFSJUT 0]$ oerr ORA 4063
04063, 00000, "%s has errors"
// *Cause:  Attempt to execute a stored procedure or use a view that has
//          errors.  For stored procedures, the problem could be syntax errors
//          or references to other, non-existent procedures.  For views,
//          the problem could be a reference in the view's defining query to
//          a non-existent table.
//          Can also be a table which has references to non-existent or
//          inaccessible types.
// *Action: Fix the errors and/or create referenced objects as necessary.
[oracle@sodb5 PFSJUT 0]$ oerr ORA 6575
06575, 00000, "Package or function %s is in an invalid state"
// *Cause:  A SQL statement references a PL/SQL function that is in an
//          invalid state. Oracle attempted to compile the function, but
//          detected errors.
// *Action: Check the SQL statement and the PL/SQL function for syntax
//          errors or incorrectly assigned, or missing, privileges for a
//          referenced object.
*/
-- RAT ellenorzes parsing hiba 
-- privilege analysis parsing hiba ellenorzes lehetseges egyaltalan?
-- 

alert.log 

[oracle@sodb5 PFSJUT 0]$ grep "PARSE ERR" /ora0/app/oracle/diag/rdbms/pfsjut/PFSJUT/trace/alert_PFSJUT.log | cut -f4 -d" " | sort -u
error=1031
error=12154
error=4063
error=6550
error=6575
error=904
error=942

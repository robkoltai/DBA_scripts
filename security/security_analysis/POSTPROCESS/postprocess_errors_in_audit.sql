-- TOP hiba uzik a RAT FUTAS UTAN
select count(1) cnt,  return_code 
from unified_audit_trail
where unified_audit_policies = 'DML_ERRS'
group by return_code
order by 1 desc;

/*
1010 full day elso replay-adatai>
       CNT RETURN_CODE
---------- -----------
     31524        2004
     21233        1950
      7418         904
      2831       24381
       255       10980
       179           1
       140         942
        80        4063 has errors. OK. Ez db linkes lesz.
        73        3135 connection lost. OK.
        16        2003 SQL developer en lehettem
        11       20500 Ezek mar mennek
SQL> update szemely set sms_contry =12 where 1=2;
SQL> insert into szemely (select * from szemely fetch first 1 rows only);

        10       20100 megy mar
         8        1400 Letoj
         6       12154 Letoj
         4       15569 Timeout
         3         604 Megy
         2        6502
         2        3113 ignore
         1          54 ignore
         1       20101 megy
         1          60 ignore
         1        2291 ignore


 oerr ORA    2004
 oerr ORA    1950
 oerr ORA     904
 oerr ORA   24381
 oerr ORA   10980
 oerr ORA       1
 oerr ORA     942
 oerr ORA    4063
 oerr ORA    3135
 oerr ORA    2003
 oerr ORA   20500
 oerr ORA   20100
 oerr ORA    1400
 oerr ORA   12154
 oerr ORA   15569
 oerr ORA     604
 oerr ORA    6502
 oerr ORA    3113
 oerr ORA      54
 oerr ORA   20101		 
 oerr ORA      60
 oerr ORA    2291

 02004, 00000, "security violation"
// *Cause:  This error code is never returned to a user.   It is used
//          as a value for column, audit_trail.returncode, to signal that a
//          security violation occurred.
// *Action:  None.

01950, 00000, "no privileges on tablespace '%s'"
// *Cause:  User does not have privileges to allocate an extent in the
//          specified tablespace.
// *Action: Grant the user the appropriate system privileges or grant the user
//          space resource on the tablespace.

00904, 00000, "%s: invalid identifier"
// *Cause:
// *Action:

24381, 00000, "error(s) in array DML"
// *Cause:  One or more rows failed in the DML.
// *Action: Refer to the error stack in the error handle.


10980, 00000, "prevent sharing of parsed query during Materialized View query generation"
// *Document: NO
// *Cause:   N/A.
// *Action:  Set this event only under the supervision of Oracle development.
// *Comment: Not for general purpose use.


00001, 00000, "unique constraint (%s.%s) violated"
// *Cause: An UPDATE or INSERT statement attempted to insert a duplicate key.
//         For Trusted Oracle configured in DBMS MAC mode, you may see
//         this message if a duplicate entry exists at a different level.
// *Action: Either remove the unique restriction or do not insert the key.



00942, 00000, "table or view does not exist"
// *Cause:
// *Action:

04063, 00000, "%s has errors"
// *Cause:  Attempt to execute a stored procedure or use a view that has
//          errors.  For stored procedures, the problem could be syntax errors
//          or references to other, non-existent procedures.  For views,
//          the problem could be a reference in the view's defining query to
//          a non-existent table.
//          Can also be a table which has references to non-existent or
//          inaccessible types.
// *Action: Fix the errors and/or create referenced objects as necessary.

03135, 00000, "connection lost contact"
// *Cause:  1) Server unexpectedly terminated or was forced to terminate.
//          2) Server timed out the connection.
// *Action: 1) Check if the server session was terminated.
//          2) Check if the timeout parameters are set properly in sqlnet.ora.

02003, 00000, "invalid USERENV parameter"
// *Cause:
// *Action:


01400, 00000, "cannot insert NULL into (%s)"
// *Cause: An attempt was made to insert NULL into previously listed objects.
// *Action: These objects cannot accept NULL values.

12154, 00000, "TNS:could not resolve the connect identifier specified"
// *Cause:  A connection to a database or other service was requested using
// a connect identifier, and the connect identifier specified could not
// be resolved into a connect descriptor using one of the naming methods
// configured. For example, if the type of connect identifier used was a
// net service name then the net service name could not be found in a
// naming method repository, or the repository could not be
// located or reached.
// *Action:
//   - If you are using local naming (TNSNAMES.ORA file):
//      - Make sure that "TNSNAMES" is listed as one of the values of the
//        NAMES.DIRECTORY_PATH parameter in the Oracle Net profile
//        (SQLNET.ORA)
//      - Verify that a TNSNAMES.ORA file exists and is in the proper
//        directory and is accessible.
//      - Check that the net service name used as the connect identifier
//        exists in the TNSNAMES.ORA file.
//      - Make sure there are no syntax errors anywhere in the TNSNAMES.ORA
//        file.  Look for unmatched parentheses or stray characters. Errors
//        in a TNSNAMES.ORA file may make it unusable.
//   - If you are using directory naming:
//      - Verify that "LDAP" is listed as one of the values of the
//        NAMES.DIRETORY_PATH parameter in the Oracle Net profile
//        (SQLNET.ORA).
//      - Verify that the LDAP directory server is up and that it is
//        accessible.
//      - Verify that the net service name or database name used as the
//        connect identifier is configured in the directory.
//      - Verify that the default context being used is correct by
//        specifying a fully qualified net service name or a full LDAP DN
//        as the connect identifier
//   - If you are using easy connect naming:
//      - Verify that "EZCONNECT" is listed as one of the values of the
//        NAMES.DIRETORY_PATH parameter in the Oracle Net profile
//        (SQLNET.ORA).
//      - Make sure the host, port and service name specified
//        are correct.
//      - Try enclosing the connect identifier in quote marks.
//
//   See the Oracle Net Services Administrators Guide or the Oracle
//   operating system specific guide for more information on naming.



15569, 00000, "timeout encountered during the replay of a recorded user call"
// *Cause:  The replay of a recorded user call was terminated since it was
//          significantly slower than the workload capture.
// *Action: Find the root cause for the performance issue. Or, use
//          DBMS_WORKLOAD_REPLAY API to disable the timeout check if the
//          replay is expected to be slower.
//

00604, 00000, "error occurred at recursive SQL level %s"
// *Cause:  An error occurred while processing a recursive SQL statement
//         (a statement applying to internal dictionary tables).
// *Action: If the situation described in the next error on the stack
//         can be corrected, do so; otherwise contact Oracle Support.


06502, 00000, "PL/SQL: numeric or value error%s"
// *Cause: An arithmetic, numeric, string, conversion, or constraint error
//         occurred. For example, this error occurs if an attempt is made to
//         assign the value NULL to a variable declared NOT NULL, or if an
//         attempt is made to assign an integer larger than 99 to a variable
//         declared NUMBER(2).
// *Action: Change the data, how it is manipulated, or how it is declared so
//          that values do not violate constraints.

03113, 00000, "end-of-file on communication channel"
// *Cause: The connection between Client and Server process was broken.
// *Action: There was a communication error that requires further investigation.
//          First, check for network problems and review the SQL*Net setup.
//          Also, look in the alert.log file for any errors. Finally, test to
//          see whether the server process is dead and whether a trace file
//          was generated at failure time.

00054, 00000, "resource busy and acquire with NOWAIT specified or timeout expired"
// *Cause:  Interested resource is busy.
// *Action: Retry if necessary or increase timeout.

00060, 00000, "deadlock detected while waiting for resource"
// *Cause:  Transactions deadlocked one another while waiting for resources.
// *Action: Look at the trace file to see the transactions and resources
//          involved. Retry if necessary.
[oracle@sodb5 PFSJUT 0]$  oerr ORA    2291

02291, 00000,"integrity constraint (%s.%s) violated - parent key not found"
// *Cause: A foreign key value has no matching primary key value.
// *Action: Delete the foreign key or add a matching primary key.
[oracle@sodb5 PFSJUT 0]$

 
*/

-- DETAIL TABLE
drop table RK_ERR_ANA_DETAILS purge;
create table RK_ERR_ANA_DETAILS tablespace rk_priv_ana  as    
select event_timestamp, system_privilege_used, unified_audit_policies, object_schema, object_name, 
  return_code, sys.compute_sql_id(sql_text) sql_id,  sql_text, sql_binds,
  sessionid, os_username, dbusername, current_user, target_user, role,
  client_program_name, entry_id, statement_id, 
  action_name, os_process, scn, execution_id
from unified_audit_trail
where os_username = 'localuser' 
    and current_user <> 'DBSNMP'
	and return_code <>0;


create index RK_ERR_ANA_DETAILS_obj on RK_ERR_ANA_DETAILS (object_schema, object_name)
tablespace rk_priv_ana;

create index RK_ERR_ANA_DETAILS_sql on RK_ERR_ANA_DETAILS (sql_id)
tablespace rk_priv_ana;

create index RK_ERR_ANA_DETAILS_rk on RK_ERR_ANA_DETAILS (return_code)
tablespace rk_priv_ana;


-- *******************************
-- ORA-1950: 01950, 00000, "no privileges on tablespace '%s'"
-- *******************************

-- elofelteltel
@create_compute_sql_id_as_sys.sql

drop table RK_ERR_ANA_1950_WITH_OBJS purge;
create table RK_ERR_ANA_1950_WITH_OBJS tablespace rk_priv_ana as    
select count(1) cnt, action_name, system_privilege_used, object_schema, object_name,
  current_user, unified_audit_policies, sys.compute_sql_id(sql_text) sql_id,
  min(event_timestamp) mints, max(event_timestamp) maxts
from 
    (select ut.* from unified_audit_trail ut
    where os_username = 'localuser' 
    and current_user <> 'DBSNMP'
    and return_code <> '0'
    and return_code =1950
    )
group by action_name, system_privilege_used, object_schema, object_name, current_user, unified_audit_policies, 
  sys.compute_sql_id(sql_text)
order by 2,3,4
;

create index RK_ERR_ANA_1950_SQLID on RK_ERR_ANA_1950_WITH_OBJS (sql_id)
tablespace rk_priv_ana;

create index RK_ERR_ANA_1950_obj on RK_ERR_ANA_1950_WITH_OBJS (object_schema, object_name)
tablespace rk_priv_ana;


-- 1950 tablespace-el
select  distinct 
        sql_id,
object_schema, object_name, current_user, action_name,  s.tablespace_name
from RK_ERR_ANA_1950_WITH_OBJS t, dba_segments s
where return_code <> '0'
  and return_code =1950
  and s.owner (+)= t.object_schema
  and s.segment_name(+) = t.object_name
;

--@err_ana_01_quota_on_tablespaces.sql
-- ALTER USERS
select 'ALTER USER ' || CURRENT_USER || ' quota unlimited on ' || tablespace_name ||';' the_sql 
from (
select  distinct 
        --sql_text,
object_schema, object_name, current_user, action_name,  s.tablespace_name
from RK_ERR_ANA_1950_WITH_OBJS t, dba_segments s
where 1=1
  and s.owner (+)= t.object_schema
  and s.segment_name(+) = t.object_name
  and action_name <>'SELECT'
)
order by 1;

-- Marad meg 1950??
select * 
from unified_audit_trail t
where return_code <> '0'
  and return_code =1950
  and event_timestamp > to_date('20191022 1535','YYYYMMDD HH24MI');
  
-- *******************************
-- ORA-2004:  02004, 00000, "security violation"
-- ORA- 942:  00942, 00000, "table or view does not exist"
-- *******************************

  
-- Brute force grant
drop table RK_ERR_ANA_2004_942_OBJS purge;


create table RK_ERR_ANA_2004_942_OBJS tablespace rk_priv_ana as    
select count(1) cnt, action_name, system_privilege_used, object_schema, object_name,
  current_user, unified_audit_policies, sql_id,
  min(event_timestamp) mints, max(event_timestamp) maxts
from 
    (select ut.* from RK_ERR_ANA_DETAILS ut
    where os_username = 'localuser' 
    and current_user <> 'DBSNMP'
    and return_code <> '0'
    and return_code in (2004,942)
    )
group by action_name, system_privilege_used, object_schema, object_name, current_user, unified_audit_policies, 
  sql_id
order by 2,3,4
;

alter table  RK_ERR_ANA_2004_942_OBJS add (sql_text clob);

set time on
set timi on
update RK_ERR_ANA_2004_942_OBJS o
  set sql_text = (select sql_text from RK_ERR_ANA_DETAILS i
                  where i.sql_id = o.sql_id
				  fetch first 1 rows only);
				  

         
select * from       RK_ERR_ANA_2004_942_OBJS;  

--@err_ana_02_missing_grant.sql
-- NEM SYS JOGOKRA
select distinct the_sql, object_schema, object_name, object_type, current_user, action_name
from (
select  
     'grant '  || action_name ||
        '          ON ' || r.object_schema||'.' ||r.object_name || ' TO ' || current_user || ';' as the_sql, 
        r.object_schema, r.object_name, o.object_type, current_user, action_name
from RK_ERR_ANA_2004_942_OBJS r,
    dba_objects o
where o.object_name = r.object_name and o.owner=r.object_schema 
  and o.object_type <> 'SYNONYM' 
  and o.object_type not like  '%PARTI%'
  and r.object_schema <> current_user
  and object_schema <>'SYS'
 order by r.object_schema, r.object_name
)
order by 2,3;

-- Ezeket adjuk hozza kezzel err_ana_02_missing_grant.sql -hez
select * from RK_ERR_ANA_2004_942_OBJS where object_schema = 'SYS';

-- *******************************
-- ORA- 904: 00904, 00000, "%s: invalid identifier"
-- *******************************

select * from RK_ERR_ANA_DETAILS
where return_code = 904;

-- QM f82ry6qkx25z5
Select  nvl(( SELECT LANG_CODE FROM QM.iq_system s where s.url like '%XXX%'   ),'666') from dual ;

SQL> Select  nvl(( SELECT LANG_CODE FROM QM.iq_system s where s.url like '%XXX%'   ),'666') from dual ;
Select  nvl(( SELECT LANG_CODE FROM QM.iq_system s where s.url like '%XXX%'   ),'666') from dual
                     *
ERROR at line 1:
ORA-00904: "LANG_CODE": invalid identifier


SQL> desc iq_system;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID                                        NOT NULL NUMBER(10)
 NAME                                      NOT NULL VARCHAR2(100)
 URL                                                VARCHAR2(2000)
 OWNER                                              VARCHAR2(100)

-- 0gm70zcjxqt9q	select contact_id from karszam where grid = RTE886 and sys_vege_date > sysdate and contact_id is not null

select * from RK_ERR_ANA_DETAILS
where return_code = 904;

select count(1) from RK_ERR_ANA_DETAILS
where return_code = 904;

select count(1) from RK_ERR_ANA_DETAILS
where return_code = 904
and sql_id <> 'f82ry6qkx25z5' 
order by sql_id;

select * from RK_ERR_ANA_DETAILS
where return_code = 904
and sql_id <> 'f82ry6qkx25z5' 
order by to_char(substr(sql_text, 1,50));


-- *******************************
-- ORA- 24381: 24381, 00000, "error(s) in array DML"
-- *******************************
-- Ezt egyenlore ignoralom. Nem igen tudok mit kezdeni vele.

INSERT INTO T_WS_ERROR_MESSAGES ( ERR_MSG_CODE, ERR_MSG_DESCRIPTION, LANGUAGE_CODE, ERR_MSG_REFVALUE, SEVERITY, WS_API, SUPPRESSION, DOCUMENTED, FIRST_OCCURENCE ) VALUES ( :B1 , :B2 , NVL(:B5 , 'H'), NULL, :B3 , :B4 , NULL, 'N', SYSDATE )
 #1(7):-910108 #2(14):Technikai hiba #3(1):H #4(5):ERROR #5(33):osb_person.GetUgyfelAlapadataiV01

-- *******************************
-- ORA- 10980 10980, 00000, "prevent sharing of parsed query during Materialized View query generation"
-- *******************************
-- Ezt egyenlore ignoralom. Mind a  Kosec Robi csinálta... heheh.
 
 select * from RK_ERR_ANA_DETAILS
where return_code = 10980;


-- 20100
port:
INSERT INTO S_JOVAHAGYASOK (UNID, SZERZODES_GRID, M_ELLENORZESEK_GRID, UZENET, SZEMELY_GRID, JOVA_DATUM, VALASZ, SYS_KEZD_DATE, SYS_VEGE_DATE, GRID, SZEREP_GRID, EN_UGYEM, ALLAPOT, NAPLO_SOR_UNID, ADATKOZLO_GRID, FUNCTION_RESULT) VALUES (S_JOVAHAGYASOK_SEQ.NEXTVAL, :B6 , :B5 , :B4 , NULL, NULL, NULL, SYSDATE, SYSDATE, S_JOVAHAGYASOK_SEQ.NEXTVAL, -1, -1, 0, :B3 , :B2 , :B1 )

-- Megy
INSERT INTO S_JOVAHAGYASOK (UNID, SZERZODES_GRID, M_ELLENORZESEK_GRID, UZENET, SZEMELY_GRID, JOVA_DATUM, VALASZ, SYS_KEZD_DATE, SYS_VEGE_DATE, GRID, SZEREP_GRID, EN_UGYEM, ALLAPOT, NAPLO_SOR_UNID, ADATKOZLO_GRID, FUNCTION_RESULT) VALUES (S_JOVAHAGYASOK_SEQ.NEXTVAL, 11 , 12 , 'u' , NULL, NULL, NULL, SYSDATE, SYSDATE, S_JOVAHAGYASOK_SEQ.NEXTVAL, -1, -1, 0, 11 , 11 , 1 );

-- 604 megy
SELECT LISTAGG( X.NYOMT_SZAM, ', ') WITHIN GROUP (ORDER BY X.NYOMT_SZAM) AGG_NY_SZAM FROM ( SELECT DISTINCT NT.NY_SZAM NYOMT_SZAM FROM NYA_TIPUS NT WHERE NT.NY_SORSZAM IN ( SELECT NYA.NY_SORSZAM FROM NYA_SZERZODES NYA WHERE 1=2 ) AND 1=2 ) X;
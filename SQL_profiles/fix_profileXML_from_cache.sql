REM https://hourim.wordpress.com/2016/10/01/sql-profile-or-when-the-hint-exceeds-500-bytes/

rem
rem Script: FixProfileXmlFromCache.sql
rem Author: Original taken somewhere (Kerry Osborne or Carlos Sierra Or Aziz
Cherrabi)
rem and updated by Mohamed Houri to consider hints > 500 bytes
rem and avoid ORA-06502
rem Dated: September 2016
rem Purpose: Transfer an execution plan of (hinted_sql_id) to a packaged query
rem
rem
rem Last tested
rem 12.1.0.2
rem
rem Usage:
rem SQL> @fixProfilefromCache
rem Enter value for sql_id_from: 2w9a295mxcjgx
rem Enter value for child_no_from: 0
rem Enter value for sql_id_to: addzft9frsckw
rem Enter value for sql_id_to: addzft9frsckw
rem Enter value for sql_id_to: addzft9frsckw
rem Notes : any feedback will be highly appreciated
rem
declare
 ar_profile_xml clob;
 cl_sql_text clob;
begin
-- get sql_id_from information
--
 select
 regexp_replace(other_xml,'.*(<outline_data>.*</outline_data>).*','\1')
 into ar_profile_xml
 from
 gv$sql_plan
 where
 sql_id = '&sql_id_from'
 and child_number = &child_no_from
 and other_xml is not null
and rownum =1;
-- get information of sql_id_to
-- use gv$sql instead of g$sqlstats
-- to avoid query text being truncated when it is very big
 begin
 select
 sql_fulltext into cl_sql_text
 from
 gv$sql
 where
 sql_id = '&sql_id_to';
exception
 when NO_DATA_FOUND then
 select
 sql_text into cl_sql_text
 from
 dba_hist_sqltext
 where
 sql_id = '&sql_id_to'
 and dbid = (select dbid from v$database);
end;
-- fix Profile
 dbms_sqltune.import_sql_profile(
 sql_text => cl_sql_text ,
 profile_xml => ar_profile_xml ,
 name => 'profile_'||'&&sql_id_to'||'_attach' ,
 category => 'DEFAULT' ,
 replace => true ,
 force_match => TRUE
 );
 end;
/
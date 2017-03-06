set lines 150
column file# format 99999
column error format a10
column status format a8
column CREATION_CHANGE# heading "CREATION|CHANGE#" format 9999999999
column RESETLOGS_CHANGE# heading "RESETLOGS|CHANGE#" format 9999999999
column CHECKPOINT_CHANGE# heading "CHECKPOINT|CHANGE#" format 9999999999
column tablespace_name heading "TABLESPACE|NAME" format a12

alter session set nls_date_format='MM/DD HH24:MI:SS';

select
 FILE#  ,       
 STATUS ,       
 ERROR  ,       
 FUZZY  ,       
 CREATION_CHANGE#,
 CREATION_TIME  ,
 TABLESPACE_NAME,
 RESETLOGS_CHANGE#,
 RESETLOGS_TIME ,
 CHECKPOINT_CHANGE#,
 checkpoint_time
 from v$datafile_header;
 
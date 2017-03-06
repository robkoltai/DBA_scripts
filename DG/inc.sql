alter session set nls_date_format='MM/DD HH24:MI:SS';
column RESETLOGS_CHANGE# heading "RESETLOGS|CHANGE#" format 9999999999
column PRIOR_RESETLOGS_CHANGE# heading "PRIOR|RESETLOGS|CHANGE#" format 9999999999
column incarnation# heading inc# format 9999
column PRIOR_INCARNATION# heading "prev|inc#" format 9999
column FLASHBACK_DATABASE_ALLOWED heading "flash|allow" format a5
select incarnation# ,
  RESETLOGS_CHANGE# ,            
  RESETLOGS_TIME    ,            
  PRIOR_RESETLOGS_CHANGE#,       
  --PRIOR_RESETLOGS_TIME          ,
  STATUS ,                       
  RESETLOGS_ID,                  
  PRIOR_INCARNATION#,            
  FLASHBACK_DATABASE_ALLOWED
 from v$database_incarnation;
 

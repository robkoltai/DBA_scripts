-- create stattab
begin
DBMS_STATS.CREATE_STAT_TABLE (
   ownname    =>         'SYSTEM', 
   stattab    =>         'UPG_CBO_STATS'
  );
end;
/


-- FIXED STATS
BEGIN
   DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
END;
/

begin  
 DBMS_STATS.EXPORT_FIXED_OBJECTS_STATS (
   stattab => 'UPG_CBO_STATS', 
   statid  => 'FIXED_OBJ_STATS',
   statown => 'SYSTEM');
end;
/
   
-- DICTONARY STATS

BEGIN
   DBMS_STATS.GATHER_DICTIONARY_STATS;
END;
/

   
begin
DBMS_STATS.EXPORT_DICTIONARY_STATS (
   stattab   =>      'UPG_CBO_STATS', 
   statid    =>      'DICTIONARY_STATS',
   statown   =>      'SYSTEM'
   ); 
end;
/
   
   
-- SYSTEM WORKLOAD STATS
exec dbms_stats.gather_system_stats(gathering_mode => 'start');
exec dbms_stats.gather_system_stats(gathering_mode => 'stop');

set lines 150
column pval2 format a33
select * from sys.aux_stats$;

   
begin
DBMS_STATS.EXPORT_SYSTEM_STATS (
   stattab   =>      'UPG_CBO_STATS', 
   statid    =>      'SYSTEM_WORKLOAD',
   statown   =>      'SYSTEM'
   ); 
end;
/
 

set pages 50
-- DEFAULT
SNAME                          PNAME                               PVAL1 PVAL2
------------------------------ ------------------------------ ---------- ---------------------------------
SYSSTATS_INFO                  FLAGS                                   1
SYSSTATS_MAIN                  CPUSPEEDNW                           3456
SYSSTATS_MAIN                  IOSEEKTIM                              10
SYSSTATS_MAIN                  IOTFRSPEED                           4096
SYSSTATS_MAIN                  SREADTIM                             
SYSSTATS_MAIN                  MREADTIM                            
SYSSTATS_MAIN                  CPUSPEED                             
SYSSTATS_MAIN                  MBRC                                  
SYSSTATS_MAIN                  MAXTHR                            
SYSSTATS_MAIN                  SLAVETHR


-- SZINTETIKUS NOWORKLOAD
SNAME                          PNAME                               PVAL1 PVAL2
------------------------------ ------------------------------ ---------- ---------------------------------
SYSSTATS_INFO                  FLAGS                                   1
SYSSTATS_MAIN                  CPUSPEEDNW                           3610
SYSSTATS_MAIN                  IOSEEKTIM                               5
SYSSTATS_MAIN                  IOTFRSPEED                          20216
SYSSTATS_MAIN                  SREADTIM                             
SYSSTATS_MAIN                  MREADTIM                            
SYSSTATS_MAIN                  CPUSPEED                             
SYSSTATS_MAIN                  MBRC                                  128 -- parameter ertekbol vette
SYSSTATS_MAIN                  MAXTHR                            
SYSSTATS_MAIN                  SLAVETHR


-- REPLAY soran a pfclone-on felvett fel oras capture lejatszasakor workload statisztika
SNAME                          PNAME                               PVAL1 PVAL2
------------------------------ ------------------------------ ---------- ---------------------------------
SYSSTATS_INFO                  STATUS                                    COMPLETED
SYSSTATS_INFO                  DSTART                                    04-11-2019 11:34
SYSSTATS_INFO                  DSTOP                                     04-11-2019 11:41
SYSSTATS_INFO                  FLAGS                                   1
SYSSTATS_MAIN                  CPUSPEEDNW                           3610
SYSSTATS_MAIN                  IOSEEKTIM                               5
SYSSTATS_MAIN                  IOTFRSPEED                          21338
SYSSTATS_MAIN                  SREADTIM                             .918
SYSSTATS_MAIN                  MREADTIM                            3.309
SYSSTATS_MAIN                  CPUSPEED                             3552
SYSSTATS_MAIN                  MBRC                                  122
SYSSTATS_MAIN                  MAXTHR                            7421952
SYSSTATS_MAIN                  SLAVETHR



BEGIN
  dbms_stats.delete_system_stats();
  dbms_stats.set_system_stats(pname => 'CPUSPEED', pvalue => 3600);
  dbms_stats.set_system_stats(pname => 'IOSEEKTIM', pvalue => 5);
  dbms_stats.set_system_stats(pname => 'IOTFRSPEED', pvalue => 21000);
  dbms_stats.set_system_stats(pname => 'SREADTIM', pvalue => .9);
  dbms_stats.set_system_stats(pname => 'MREADTIM', pvalue => 3.3);
  dbms_stats.set_system_stats(pname => 'MBRC',     pvalue => 122);
  dbms_stats.set_system_stats(pname => 'MAXTHR',   pvalue => 7421952);
  dbms_stats.set_system_stats(pname => 'SLAVETHR', pvalue => ???);
END;

-- RAT napi lejatszas 
-- SNAME                          PNAME                               PVAL1 PVAL2
------------------------------ ------------------------------ ---------- ---------------------------------
SYSSTATS_INFO                  STATUS                                    COMPLETED
SYSSTATS_INFO                  DSTART                                    05-08-2019 16:35
SYSSTATS_INFO                  DSTOP                                     05-08-2019 16:37
SYSSTATS_INFO                  FLAGS                                   1
SYSSTATS_MAIN                  CPUSPEEDNW                     3463.48733
SYSSTATS_MAIN                  IOSEEKTIM                              10
SYSSTATS_MAIN                  IOTFRSPEED                           4096
SYSSTATS_MAIN                  SREADTIM                              4.1
SYSSTATS_MAIN                  MREADTIM                            12.89
SYSSTATS_MAIN                  CPUSPEED                             3652
SYSSTATS_MAIN                  MBRC                                   19
SYSSTATS_MAIN                  MAXTHR                          365475840
SYSSTATS_MAIN                  SLAVETHR                         50278400

SNAME                          PNAME                               PVAL1 PVAL2
------------------------------ ------------------------------ ---------- ---------------------------------
SYSSTATS_INFO                  STATUS                                    COMPLETED
SYSSTATS_INFO                  DSTART                                    05-08-2019 16:39
SYSSTATS_INFO                  DSTOP                                     05-08-2019 16:43
SYSSTATS_INFO                  FLAGS                                   1
SYSSTATS_MAIN                  CPUSPEEDNW                     3463.48733
SYSSTATS_MAIN                  IOSEEKTIM                              10
SYSSTATS_MAIN                  IOTFRSPEED                           4096
SYSSTATS_MAIN                  SREADTIM                            2.939
SYSSTATS_MAIN                  MREADTIM                            8.794
SYSSTATS_MAIN                  CPUSPEED                             3652
SYSSTATS_MAIN                  MBRC                                   21
SYSSTATS_MAIN                  MAXTHR                          510301184
SYSSTATS_MAIN                  SLAVETHR                         75040768





---------- TRANSPORT
expdp system DIRECTORY=GRB_PF_LIVE_RAT_WORK DUMPFILE=CBO_statistics_for18c.dmp logfile=CBO_statistics_for18c.elog TABLES=UPG_CBO_STATS

impdp ...

begin  
 DBMS_STATS.IMPORT_FIXED_OBJECTS_STATS (
   stattab => 'UPG_CBO_STATS', 
   statid  => 'FIXED_OBJ_STATS',
   statown => 'SYSTEM');
end;
/

begin
DBMS_STATS.IMPORT_DICTIONARY_STATS (
   stattab   =>      'UPG_CBO_STATS', 
   statid    =>      'DICTIONARY_STATS',
   statown   =>      'SYSTEM'
   ); 
end;
/

begin
DBMS_STATS.IMPORT_SYSTEM_STATS (
   stattab   =>      'UPG_CBO_STATS', 
   statid    =>      'SYSTEM_WORKLOAD',
   statown   =>      'SYSTEM'
   ); 
end;
/
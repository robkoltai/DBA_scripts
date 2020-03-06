
-- Hozzuk létre a capture directory-t, ha még nem létezik
create directory capdir as '/oradata/RAT_CAPDIR';

-- HA capture directory már létezik
-- töröljük a tartalmát
-- rm -Rf /oradata/RAT_CAPDIR/* capture directoryban

-- Előzetes készülés
-- TOPNSQL paraméter 100-ra felvétele. Többi paramétert nem változtatjuk.
https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_workload_repos.htm#ARPLS69142
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (null,null,100,null);
select dbid, topnsql from dba_hist_wr_control;
exec dbms_workload_repository.create_snapshot;


-- RESTART of the database. Not necessary. Ongoing transactions will not be replayed.
-- consider restarting the database in restricted mode using STARTUP RESTRICT before starting the workload capture. 
-- Once the workload capture begins, the database will automatically switch to unrestricted mode and normal operations can continue while the workload is being captured.
https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ratug/capturing-a-database-workload.html#GUID-C85885FA-715D-48AB-80F1-9C546988E667
  -- auto_unrestrict   IN  BOOLEAN  DEFAULT TRUE
-- IF you restart then use:
-- Capture will switch to unrestricted mode automatically
-- shutdown immediate;
-- startup restrict;

-- Filter out ha akarunk
-- Most nem akarunk
/*
BEGIN
  DBMS_WORKLOAD_CAPTURE.ADD_FILTER (
                           fname => 'HR_FILTER',
                           fattribute => 'USER',   -- PROGRAM, MODULE, ACTION, SERVICE, INSTANCE_NUMBER, and USER.
                           fvalue => 'HR');     -- May use %
END;
/
*/

-- Appears in alert.log
BEGIN
  DBMS_WORKLOAD_CAPTURE.START_CAPTURE (
                           name => 'RAT_DEMO', 
                           dir  => 'CAPDIR',
                           --duration => 43200,            -- in seconds. If null then manual stop is needed
						   default_action => 'INCLUDE');   -- Filters will be interpreted as contrary INCLUDE<->EXCLUDE
/*
						   capture_sts => TRUE,
						   sts_cap_interval => 300,       -- In seconds. capture STS from the cursor cache
						   plsql_mode => 'TOP_LEVEL'      -- Extended nem hiszem, hogy kell
						   );
*/
END;
/


-- CHECK and MONITOR SQLDEVELOPER is recommended
SELECT DBMS_WORKLOAD_CAPTURE.get_capture_info('CAPDIR')
FROM   dual;
select * from dba_workload_captures;

select * from DBA_WORKLOAD_CAPTURES;
select * from DBA_WORKLOAD_FILTERS;

-- ====================
-- RUN THE WORKLOAD
-- ====================

 ./runit_now_CAPTURE.sh




-- Finish capture
Begin
  DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE (
    timeout     => 180,                               -- seconds for clients to flush capture buffers
    reason      => 'It is end of day now');
end;
/

-- create AWR
exec dbms_workload_repository.create_snapshot;

-- cap/wcr_ca.log az exportja
-- Ez fontos, mert kulonben tudunk majd reportalini
exec DBMS_WORKLOAD_CAPTURE.EXPORT_AWR (&capture_id); 


-- Legyen read joga mindenkinek minden file-t olvasni
-- chmod -R a+r




-- capture directory már létezik
-- töröljük a tartalmát
-- rm -Rf * capture directoryban
-- Szabad hely ellenőrzése. 50 GB hely lehet szükséges 12 óra felvételéhez.
-- du -h .

-- Előzetes készülés
-- TOPNSQL paraméter 100-ra felvétele. Többi paramétert nem változtatjuk.
https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_workload_repos.htm#ARPLS69142
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (null,null,300,null);
select dbid, topnsql from dba_hist_wr_control;
exec dbms_workload_repository.create_snapshot();

-- startup restrict
-- shutdown immeidate;
-- startup restrict;


-- CAPTURE 7-19 óra között.
-- 12 óra 12x60=720
BEGIN
  DBMS_WORKLOAD_CAPTURE.START_CAPTURE (
                           name => 'PF_LIVE_DAY0430', 
                           dir  => 'CAPDIR',
                           duration => 720
						   );
END;
/


-- CHECK
SELECT DBMS_WORKLOAD_CAPTURE.get_capture_info('CAPDIR')
FROM   dual;
select * from dba_workload_capture;


-- By default, once the workload capture begins, any database instance that are in 
-- RESTRICTED mode will automatically switch to UNRESTRICTED mode, 
-- and normal operations can continue while the workload is being captured
https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_workload_capture.htm
  -- auto_unrestrict   IN  BOOLEAN  DEFAULT TRUE


-- cap/wcr_ca.log az exportja
-- Ez fontos, mert kulonben
exec DBMS_WORKLOAD_CAPTURE.EXPORT_AWR (xxx);  -- capture id


-- Legyen read joga mindenkinek minden file-t olvasni
-- chmod -R a+r


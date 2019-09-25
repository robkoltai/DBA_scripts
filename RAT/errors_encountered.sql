-- Eszrevetelek
/*
-- https://blogs.oracle.com/oraclemagazine/playing-nice-together
-- Csak az uj session oket meri??? 01 teszt alapjan igen
-- Nezd meg a logfile-t
-- Missing cap konyvtar??? files
		SQL> BEGIN
		  DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir => 'CAPDIR',
									 plsql_mode => 'TOP_LEVEL');
		END;
		/
		  2    3    4    5  BEGIN
		*
		ERROR at line 1:
		ORA-20222: Workload capture in "CAPDIR" is missing required .wmd files.
		ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 3227
		
		!!! Legyen az oracle usernek read es write jogosultsaga. Szar a hibauzenet.
		DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE Fails With ORA-20222 Workload capture in "<DIR>" is missing required .wmd files (Doc ID 1988822.1)
02 teszt: nem volt reboot, uj loginok voltak, directory-kat nem hoztam letre ujra
	ORA-20222: Workload capture in "CAPDIR" is missing required .wmd files
	en voltam a barom...
03 teszt processing 
	Error: oracle/jdbc/OracleDriver ojdbc8 kellett a 8 as javahoz
04 cannot import AWR. A baj az volt, hogy nem kellett volna pp12.2 konyvtarat is megadnom.
	Importing AWR data from directory '/home/oracle/groupama/RAT/captest01/pp12.2.0.1.0'
	Cannot import AWR data for this capture. Skipping AWR and ASH analysis!
05
	ORA-15555: workload replay client encountered unexpected error: "The diagnosability context cannot be initialized."
	lokalis sqlnet.log-ot kell megnezni, mert nem tudott faljba irni
06  check diag trace directory for logfiles. pl. /tmp/sqlnettrcRob/oradiag_oracle/diag/clients/user_oracle/host_1351112715_107/trace
07 Filterek minden egyes capture-hez ujra kell csinalni
08 capture directory legyen ures
09 start wcr_cap_000000n.start eltunik ha vege van a capture-nek
10 sanity check problema
	Starting a Workload Replay Client (WRC) While the Replay Status is in INITIALIZED STATUS Returns an Incorrect and Mis-leading Error Message (ORA-15567) (Doc ID 2261136.1)
	WRC fails with "ORA-15567: Replay User System Encountered An Error During A Sanity Check" (Doc ID 2110258.1)
11 DBMS_WORKLOAD_CAPTURE/DBMS_WORKLOAD_REPLAY: Could not export sql tuning set SYS.REP02_r_254608 to wcr_ra_sts44135402.dmp in WRR_TMP632118823 !
12 (wrc_main_6104.trc) ORA-15551: workload replay client cannot connect to database server
   (wrc_main_6104.trc) ORA-15561: workload replay client cannot connect to the remapped connection with conn_id : 1
   PS C:\PFUP> wrc system/system@pfs mode=replay replaydir=c:\PFUP\grb_clone_capture_mine connection_override=true
13 PROCESS_CAPTURE alatt alert.log. Ez normalis, ha nem várunk be minden tranzakciót
	2019-04-29T12:49:32.565627+02:00
	DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE: WARNING: Preprocessing hit an error. File is INCOMPLETE: /opt/oradump/pfup/grb_pf_live_capture0425_replay0429/capfiles/inst1/aa/wcr_c3fanh00000ux.rec; call counter 3502.
	2019-04-29T12:49:33.837732+02:00
	DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE: WARNING: Preprocessing hit an error. File is INCOMPLETE: /opt/oradump/pfup/grb_pf_live_capture0425_replay0429/capfiles/inst1/aa/wcr_c3dkch000002y.rec; call counter 1206.
14 PROCESS_CAPTURE nem akar elindulni, mert még fut a CAPTURE?....
	BEGIN
	  DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir => 'GRB_PF_LIVE_RAT_WORK',
								 plsql_mode => 'TOP_LEVEL');
	END;
	/
	SQL> 10:59:32 SQL> 10:59:32   2  10:59:32   3  10:59:32   4  10:59:32   5  BEGIN
	*
	ERROR at line 1:
	ORA-20223: Error: Capture is in progress, stop capture before process capture
	ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 3212
	ORA-06512: at line 2
	Na ez vicces, mert a teszt adatbázis úgy lett restore-olva, hogy OTT futott tovább a capture.
	Honnan jöttem ra? Jé itt nem az éles PF_LIVE-hoz, hanem a JUT-hoz konnektálunk
		strings wcr_83yvqh00002jz.rec |less

		(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(PORT=xxxx)(HOST=xxxx.xxxx))(CONNECT_DATA=(CID=(PROGRAM=JDBC Thin Client)(HOST=__jdbc__)(USER=oracle))(SID=xxx)))

	A klónozáskor már futott a capture.

15  SYSAUX-ban nem volt elég hely...
    Process capture nem ment.
	set time on
	BEGIN
	  DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir => 'GRB_PF_LIVE_RAT_WORK',
								 plsql_mode => 'TOP_LEVEL');
	END;
	/SQL> 13:28:17 SQL> 13:28:17   2  13:28:17   3  13:28:17   4  13:28:17   5
	BEGIN
	*
	ERROR at line 1:
	ORA-15516: parallel preprocessing worker hit error ORA-1688
	ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 3227
	ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 2422
	ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 2907
	ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 3192
	ORA-06512: at line 2


	Elapsed: 00:02:13.06
	13:30:31 SQL> !oerr ORA 1688
	01688, 00000, "unable to extend table %s.%s partition %s by %s in tablespace %s"
	// *Cause:  Failed to allocate an extent of the required number of blocks for
	//          table segment in the tablespace indicated.
	// *Action: Use ALTER TABLESPACE ADD DATAFILE statement to add one or more
	//          files to the tablespace indicated.

16
	Wait for the replay to start (16:03:57)
	Replay client 2 started (16:05:07)
	(wrc_r00222_10084.trc) ORA-15558: replay thread encountered unexpected error
	(wrc_r00007_10084.trc) ORA-15558: replay thread encountered unexpected error
	Errors in file :
	OCI-21503: program terminated by fatal error
	OCI-04030: out of process memory when trying to allocate 131112 bytes (Alloc statemen,prev row buffer)
	ORA-24550: signal received: Unhandled exception: Code=c00000fd Flags=0



   */

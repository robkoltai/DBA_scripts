
@set_module MEASURING

declare
  V_ID RK_RUNSTAT_CONTROL.ID%TYPE;
  V_TS RK_RUNSTAT_CONTROL.TS%TYPE;
  V_LASTID RK_RUNSTAT_CONTROL.ID%TYPE :=0;
  V_EXPECTED_THREADNUM RK_RUNSTAT_CONTROL.EXPECTED_THREADNUM%TYPE;
  V_WE_GOT_NEW_TESTPHASE NUMBER:=0;
  V_CURRENT_THREADNUM NUMBER;
  V_LOOP_ID NUMBER :=0;
   
  procedure log(p varchar2) as
  begin
    insert into rk_log values (p,systimestamp);
    commit;
  end log;
  procedure save_stats_to_temp (p_snap_id number, p_loop_id number) as
  begin

    delete rk_runstat_events_tmp;
    delete rk_runstats_tmp;
    delete rk_runstat_workarea_act_tmp;
 
    insert into rk_runstat_events_tmp (
    select
      p_snap_id,
      NVL(s.username, '(oracle)') ,
      s.sid,
      s.serial#,
      'TEST DURATION',
      1,
      0,
      to_number((SYSDATE - TO_DATE('06-08-2018 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60 * 1000000),
      to_number(to_char(systimestamp,'FF6') +
           (SYSDATE - TO_DATE('06-08-2018 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60 * 1000000),
      systimestamp
      from v$session s
      --where s.sid = (select distinct sid from v$mystat));
      where s.module = 'RK_RUNSTAT' and s.action <> 'MEASURING' and program not like  '%(P%)%'
    );


    insert into rk_runstat_events_tmp (  
    select
       p_snap_id as snapid,
       NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited,
       --se.average_wait,
       --se.max_wait,
       se.time_waited_micro,
       systimestamp
    FROM   v$session_event se,
       v$session s
    WHERE  s.sid = se.sid
    --AND    s.sid in ((select distinct sid from v$mystat) 
    --                union
    --                 (select sid from v$px_session where qcsid = (select distinct sid from v$mystat)))
      AND s.module = 'RK_RUNSTAT' and s.action <> 'MEASURING'  
    );

    insert into RK_RUNSTAT_WORKAREA_ACT_TMP 
      select
        p_snap_id as snapid,
        sql_id,
        sid,
        qcinst_id,
        qcsid,
        active_time, 
        work_area_size,
        expected_size,
        actual_mem_used,
        max_mem_used,
        number_passes,
        tempseg_size,
        swa.tablespace,
        systimestamp
    from v$sql_workarea_active swa
    where swa.sid in (select s.sid from v$session s where s.module = 'RK_RUNSTAT' and s.action <> 'MEASURING');

    insert into RK_RUNSTAT_WORKAREA_ACT_ALL
      select p_loop_id, tmp.* from RK_RUNSTAT_WORKAREA_ACT_TMP tmp;


    insert into rk_runstats_tmp (
    select
      p_snap_id as snapid,
      b.sid,
      name,
      value,
      systimestamp
    from v$statname a, v$sesstat b
    where a.statistic# = b.statistic#
    and 1=1
    and b.sid in (select sid from v$session s where s.module = 'RK_RUNSTAT' and s.action <> 'MEASURING'  
                 )
    );

    commit;
  end save_stats_to_temp;

begin
  LOOP

    v_loop_id := v_loop_id +1;

    SELECT ID, TS, EXPECTED_THREADNUM
    INTO V_ID, V_TS, V_EXPECTED_THREADNUM
    FROM RK_RUNSTAT_CONTROL
    where id =(select max(id) from rk_runstat_control);
    log ('Current id and expected_threadnum:' || v_id || ' ' || V_EXPECTED_THREADNUM);

    IF V_ID>V_LASTID THEN
      V_WE_GOT_NEW_TESTPHASE:=1;
      log ('New testphase DETECTED NOW' || v_id);
      V_LASTID:=V_ID;
    END IF;


    -- we need to save infos if V_WE_GOT_NEW_TESTPHASE=1
    if V_WE_GOT_NEW_TESTPHASE=1 then
      log('New testpahse situation. Do we need to save?');
      select count(1)
      into v_current_threadnum
      from v$session s 
      where s.module = 'RK_RUNSTAT' and s.action <> 'MEASURING' 
      ; 
     
      log ('v_current_threadnum, V_EXPECTED_THREADNUM :' || v_current_threadnum ||', ' || V_EXPECTED_THREADNUM);
      if v_id=2 or v_id=4 then
        log ('Inserting tmp_records because test1 or test2 has just finished'); 
        -- We put snapid+1 because the data belongs to the new phase, but it was saved using the old snapid
        insert into rk_runstat_events (select SNAPID+1, USERNAME, SID, SERIAL#, EVENT, TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED, TIME_WAITED_MICRO, ts from rk_runstat_events_tmp);
        insert into rk_runstat_workarea_act (select snapid+1, sql_id, sid, qcinst_id, qcsid, active_time, work_area_size, expected_size, actual_mem_used, max_mem_used, number_passes, tempseg_size, tablespace, ts from rk_runstat_workarea_act_tmp);
        insert into rk_runstats (select SNAPID+1, SID, NAME, VALUE, ts from rk_runstats_tmp);
        V_WE_GOT_NEW_TESTPHASE:=0;
      end if;

      if (v_id=1 or v_id=3) and v_current_threadnum>=V_EXPECTED_THREADNUM then
      log ('Saving and Inserting tmp_records because test1 or test2 has started and expected threadnum has been reached');
        SAVE_STATS_TO_TEMP (V_ID, V_LOOP_ID);
        insert into rk_runstats (select * from rk_runstats_tmp);
        insert into rk_runstat_workarea_act (select * from rk_runstat_workarea_act_tmp);
        insert into rk_runstat_events (select * from rk_runstat_events_tmp);
        V_WE_GOT_NEW_TESTPHASE:=0;
      end if;
 
    end if; -- NEW TESTPHASE  

     -- save stats to temp table in each iteration
     SAVE_STATS_TO_TEMP (V_ID, V_LOOP_ID);
     log('Stats saved to temp');

     log('Before seleep');
     DBMS_LOCK.SLEEP(2);
     log('After sleep');

    -- after last phase and after we saved the infos we can exit
    IF V_LASTID=4 and V_WE_GOT_NEW_TESTPHASE =0 THEN
      EXIT;
    END IF;
 

  END LOOP; 


exception
  WHEN OTHERS THEN RAISE;
end;
/

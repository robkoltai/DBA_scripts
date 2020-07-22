DECLARE
  l_task     VARCHAR2(30) := 'stats_import_task';
  l_sql_stmt VARCHAR2(32767);
--  l_try      NUMBER;
--  l_status   NUMBER;
BEGIN
  DBMS_PARALLEL_EXECUTE.create_task (task_name => l_task);

  DBMS_PARALLEL_EXECUTE.create_chunks_by_number_col(task_name    => l_task,
                                                    table_owner  => 'DWMS',
                                                    table_name   => 'WRK_GDW_STATS_CTRL',
                                                    table_column => 'ID',
                                                    chunk_size   => 1);

  l_sql_stmt := 
  q'[
    DECLARE
        v_owner      varchar2(128);
        v_table_name varchar2(128);
        v_start_id   number  := :start_id;
        v_end_id     number  := :end_id;
    BEGIN 
        select owner, table_name 
        into v_owner, v_table_name
        from dwms.wrk_gdw_stats_ctrl
        where id = v_start_id;
        
        DBMS_STATS.IMPORT_TABLE_STATS (
            statown        => 'DWMS',
            stattab        => 'GDW_STATISTICS',
            statid         => 'GDW_20200701_DB',
            stat_category  => 'OBJECT_STATS, SYNOPSES',
            ownname        => v_owner,
            tabname        => v_table_name
        );
        
        update dwms.wrk_gdw_stats_ctrl
        set IMPORTED = 'Y'
        where id = :start_id;
        commit;
    END;
  ]';

  DBMS_PARALLEL_EXECUTE.run_task(task_name      => l_task,
                                 sql_stmt       => l_sql_stmt,
                                 language_flag  => DBMS_SQL.NATIVE,
                                 parallel_level => 10);

--  -- If there is error, RESUME it for at most 2 times.
--  l_try := 0;
--  l_status := DBMS_PARALLEL_EXECUTE.task_status(l_task);
--  WHILE(l_try < 2 and l_status != DBMS_PARALLEL_EXECUTE.FINISHED) 
--  Loop
--    l_try := l_try + 1;
--    DBMS_PARALLEL_EXECUTE.resume_task(l_task);
--    l_status := DBMS_PARALLEL_EXECUTE.task_status(l_task);
--  END LOOP;
--
--  DBMS_PARALLEL_EXECUTE.drop_task(l_task);
END;
/


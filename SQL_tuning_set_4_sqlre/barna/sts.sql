DECLARE

  CURSOR cSQLArea
  IS

    SELECT address, hash_value
    FROM v$sqlarea
    WHERE sql_id IN ('fvvcbyxf4fqz5', '3xhn5khnk08pg', 'arb5m8p14x37r', '8hav43vx0uh7c') ;

  rSQLArea cSQLArea%ROWTYPE;
  sts  VARCHAR2 (30) ;
  rsts VARCHAR2 (30) ;
  bf   VARCHAR2 (2000) ;
  cnt  NUMBER;
BEGIN

  FOR rSQLArea IN cSQLArea
  LOOP
    sys.dbms_shared_pool.PURGE (rSQLArea.address || ',' || rSQLArea.hash_value, 'c', 65) ;

  END LOOP;

  SELECT upper (instance_name)
  INTO sts
  FROM v$instance;

  sts := 'U30_' || sts;

  SELECT COUNT ( *)
  INTO cnt
  FROM DBA_SQLSET
  WHERE NAME = sts;

  IF cnt = 0 THEN
    rsts := dbms_sqltune.create_sqlset (sqlset_name=>sts, sqlset_owner=>'EPERJESI') ;
  ELSE
    rsts := sts;
  END IF;

  IF (sts = rsts) THEN
    bf := q'#SQL_ID IN ('fvvcbyxf4fqz5', '3xhn5khnk08pg', 'arb5m8p14x37r', '8hav43vx0uh7c') #';
    Dbms_Sqltune.Capture_Cursor_Cache_Sqlset (Sqlset_Name=>rsts, time_limit=>86400, Repeat_Interval=>'30', basic_filter
    =>bf, sqlset_owner=>'EPERJESI', capture_mode=>Dbms_Sqltune.MODE_ACCUMULATE_STATS, capture_option=>'MERGE') ;

  END IF;

END;
/

DECLARE
TYPE SqlArrTyp
IS
  TABLE OF NUMBER INDEX BY VARCHAR2 (30) ;
  SqlArr SqlArrTyp;

  CURSOR cSql
  IS

    SELECT sql_id, child_number
    FROM v$sql
    WHERE sql_id IN ('fvvcbyxf4fqz5', '3xhn5khnk08pg', 'arb5m8p14x37r', '8hav43vx0uh7c')
    AND executions > 0;

  rSql cSql%ROWTYPE;
  idx VARCHAR2 (30) ;
  i   NUMBER;
BEGIN

  WHILE true
  LOOP

    FOR rSql IN cSql
    LOOP
      idx := rSql.sql_id || '_' || TO_CHAR (rSql.child_number) ;

      IF NOT SqlArr.EXISTS (idx) THEN
        SqlArr (idx) := 1;
        dbms_sqldiag.dump_trace (p_sql_id=>rSql.sql_id, p_child_number=>rSql.child_number, p_component=>'Compiler',
        p_file_id=>'U30_' || idx) ;

      END IF;

    END LOOP;
    dbms_lock.sleep (30) ;

  END LOOP;

END;
/

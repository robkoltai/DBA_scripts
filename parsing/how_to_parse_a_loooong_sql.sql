
-- Problem is that there is no explain plan in PLSQL

-- We get the SQL text from AWR repo
-- We parse it, but don't execute it.



DECLARE
    cursor_name INTEGER;
    v_sqltext clob;
    rows_processed INTEGER;
    v_sql_id varchar2(30);
BEGIN
    v_sql_id := '7yk8xa71z79rr';
    
    select sql_text 
    into v_sqltext
    from dba_hist_sqltext 
    where sql_id = v_sql_id;
    
    cursor_name := dbms_sql.open_cursor;
    DBMS_SQL.PARSE(cursor_name, v_sqltext, DBMS_SQL.NATIVE);
    --DBMS_SQL.BIND_VARIABLE(cursor_name, ':x', salary);
    --rows_processed := DBMS_SQL.EXECUTE(cursor_name);
    DBMS_SQL.CLOSE_CURSOR(cursor_name);
EXCEPTION
WHEN OTHERS THEN
    DBMS_SQL.CLOSE_CURSOR(cursor_name);
END;
/


-- child 
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('7yk8xa71z79rr', null, 'ADVANCED ALLSTATS LAST -PROJECTION +ADAPTIVE'))
/

------------------------------------ ALTERNATIVELY
VARIABLE T CLOB
BEGIN
  SELECT sql_text INTO :T FROM v$sql;
END;
/
...


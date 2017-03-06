-- Ez megadja a bindokat is!!
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'advanced'))
/

select * from table(dbms_xplan.display_cursor('&sql', 0, 'basic +PEEKED_BINDS'))
/


select dbms_sqltune.extract_binds(bind_data) bind from v$sql where sql_text like '%my sql text%'
/

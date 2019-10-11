-- Generate the SQL ID !!!
select DBMS_SQL_TRANSLATOR.sql_id(sql_text) from dual;

/*
SQL> select dbms_sql_translator.sql_id('select 1717 from dual') from dual;

DBMS_SQL_TRANSLATOR.SQL_ID('SELECT1717FROMDUAL')
--------------------------------------------------------------------------------
8rd2n0v8vvph7
*/
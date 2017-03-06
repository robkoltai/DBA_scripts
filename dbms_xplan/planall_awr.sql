select * from table(dbms_xplan.display_awr('&v_sql_id', null, null,  'all'))
/

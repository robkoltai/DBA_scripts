-- create


select d.name
FROM wri$_sqlset_definitions d, wri$_sqlset_references r
WHERE d.name = 'THE_FOUR_COMMANDS_SQLSET'
AND r.sqlset_id = d.id;    
   
delete from wri$_sqlset_references
where sqlset_id in (select id
                  from wri$_sqlset_definitions
                  where name ='THE_FOUR_COMMANDS_SQLSET'
                  );   
commit;
				  
exec DBMS_SQLSET.DROP_SQLSET ('THE_FOUR_COMMANDS_SQLSET'); 

   
BEGIN
  DBMS_SQLSET.CREATE_SQLSET (
    sqlset_name  => 'THE_FOUR_COMMANDS_SQLSET' 
,   description  => 'This sqlset contains the 4 commands and the calling packages' 
);
END;
/

set lines 180
COLUMN NAME FORMAT a30
COLUMN COUNT FORMAT 99999
COLUMN DESCRIPTION FORMAT a65

SELECT NAME, STATEMENT_COUNT AS "SQLCNT", DESCRIPTION
FROM   USER_SQLSET;


-- populate
DECLARE
  c_sqlarea_cursor DBMS_SQLSET.SQLSET_CURSOR;
BEGIN
 OPEN c_sqlarea_cursor FOR
   SELECT VALUE(p)
   FROM   TABLE( 
            DBMS_SQLSET.SELECT_CURSOR_CACHE(
              basic_filter => ' parsing_schema_name = ''RAT'' ',
			  attribute_list => 'all'
			)
          ) p;
-- load the tuning set
  DBMS_SQLSET.LOAD_SQLSET (  
    sqlset_name     => 'THE_FOUR_COMMANDS_SQLSET'
,   populate_cursor =>  c_sqlarea_cursor 
);
END;
/

-- check population
set pages 300
set lines 180
COLUMN SQL_TEXT FORMAT a90 
COLUMN SCH FORMAT a3
COLUMN ELAPSED FORMAT 999999999

-- We filter out irrelevant stuff
SELECT SQL_ID, PARSING_SCHEMA_NAME AS "SCH", SQL_TEXT, 
       ELAPSED_TIME AS "ELAPSED", BUFFER_GETS,
	   executions
FROM   TABLE( DBMS_SQLTUNE.SELECT_SQLSET( 'THE_FOUR_COMMANDS_SQLSET' ) )
where buffer_gets>1000
order by elapsed_time desc;

-- **************************************
-- So we have an SQL tuning set which 
-- contains the SQLs and  the workload
-- **************************************

-- Check all details from SQLdeveloper if you wish
-- skip this
SELECT *
FROM table(DBMS_SQLSET.select_cursor_cache('parsing_schema_name = ''RAT'''))
ORDER BY sql_id, plan_hash_value;



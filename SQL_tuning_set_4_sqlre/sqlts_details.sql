-- What sqlsets do we have
select * from dba_sqlset;

-- What is the content
SELECT *
FROM   TABLE( DBMS_SQLTUNE.SELECT_SQLSET( 'SQLSET_4SQL' ) );
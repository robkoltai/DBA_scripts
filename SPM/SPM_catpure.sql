--18c
exec dbms_spm.configure('AUTO_CAPTURE_PARSING_SCHEMA_NAME','SCOTT');
exec dbms_spm.configure('AUTO_CAPTURE_MODULE','DATALOAD');
exec dbms_spm.configure('AUTO_CAPTURE_ACTION','ACTION_23');

SELECT * FROM dba_sql_management_config;
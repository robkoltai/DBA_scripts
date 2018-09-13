set lines 150
set pages 100
column name format a25
column value format a107
select name, value from v$parameter where name in ( 
        'log_archive_dest_1',
        'log_archive_dest_2',
        'log_archive_config',
		'db_unique_name',
        'fal_server',
		'standby_file_management',
		'db_file_name_convert',
		'log_file_name_convert',
		'dg_broker_config_file1',
		'dg_broker_config_file2',
		'service_names',
		'archive_lag_target'
)
order by name;


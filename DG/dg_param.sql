set lines 150
set pages 25
column name format a25
column value format a99
select name, value from v$parameter where name in ( 
        'log_archive_dest_1',
        'log_archive_dest_2',
		'log_archive_dest_state_1',
		'log_archive_dest_state_2',
        'log_archive_config',
        'fal_server',
		'dg_broker_config_file1',
		'dg_broker_config_file2',
		'dg_broker_start',
		'standby_file_management',
		'db_file_name_convert',
		'redo_transport_user',
		-- x seconds after one sync destination acknowledged, 
		-- primary can disconnect any subsequent sync destinations
		'data_guard_sync_latency' 
)
order by name;


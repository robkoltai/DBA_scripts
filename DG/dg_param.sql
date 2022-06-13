set lines 150
set pages 30
column name format a28
column value format a99
select name, value from v$parameter where name in ( 
        'log_archive_dest_1',
        'log_archive_dest_2',
		'log_archive_dest_state_1',
		'log_archive_dest_state_2',
        'log_archive_config',
        'fal_server',
		'db_unique_name',
		'dg_broker_config_file1',
		'dg_broker_config_file2',
		'dg_broker_start',
		'standby_file_management',
		'db_file_name_convert',
		'log_file_name_convert',
		'redo_transport_user',
		-- x seconds after one sync destination acknowledged, 
		-- primary can disconnect any subsequent sync destinations
		'data_guard_sync_latency',
        'temp_undo_enabled',
		'adg_redirect_dml',
		'standby_db_preserve_states',
		'db_lost_write_protect',
		'log_archive_max_processes',
		'local_listener'
)
order by name;


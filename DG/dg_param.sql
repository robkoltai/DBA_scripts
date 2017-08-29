set lines 150
column name format a25
column value format a120
select name, value from v$parameter where name in ( 
        'log_archive_dest_1',
        'log_archive_dest_2',
        'log_archive_config',
        'fal_server',
		'db_unique_name',
		'standby_file_management'
)
order by name;


set lines 150
column name format a20
column value format a70
select name, value from v$parameter where name in ( 
        'log_archive_dest_1',
        'log_archive_dest_2',
        'log_archive_config',
        'fal_server'
)
order by name;


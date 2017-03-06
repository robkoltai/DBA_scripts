set lines 300
column network_name format a23
column name format a20
select service_id, name, network_name, creation_date from v$services;

















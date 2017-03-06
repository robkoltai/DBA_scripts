set lines 120
column tablespace_name format a18
column file_name format a40
select tablespace_name, file_name, 
  bytes/1024/1024 "Size MB",
  maxbytes/1024/1024 "MaxSize MB", 
  autoextensible 
from dba_temp_files;
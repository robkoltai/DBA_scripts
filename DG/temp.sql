set lines 120
column tablespace_name format a18
column file_name format a40
column name format a40

select tablespace_name, status, contents 
from dba_tablespaces;

select tablespace_name, file_name, 
  bytes/1024/1024 "Size MB",
  maxbytes/1024/1024 "MaxSize MB", 
  autoextensible 
from dba_temp_files;

prompt from v$tempfile that is available also in mount mode
select name, status, ENABLED, bytes/1024/1024 "Size MB", BLOCK_SIZE
from v$tempfile;

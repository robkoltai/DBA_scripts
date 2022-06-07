set lines 150
column member format a66
column group# format 999999
select a.group#, a.status, a.bytes/1024/1024 SizeMB, b.member 
from v$log a, v$logfile b 
where a.group#=b.group# order by group#;

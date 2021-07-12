-- from 12.2 on this view is valuable
/*
https://martincarstenbach.wordpress.com/2017/12/13/little-things-worth-knowing-redo-transport-in-data-guard-12-2-part-1/
https://martincarstenbach.wordpress.com/2017/12/20/little-things-worth-knowing-redo-transport-in-data-guard-12-2-part-2/
*/


set lines 150
column name format a15
column pid format a15
select name, pid, role, action, client_pid, client_role, sequence#, block#, dest_id
from v$dataguard_process order by action;
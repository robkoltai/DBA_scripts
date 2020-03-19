column the_command format a100
set lines 180
set pages 200
select rpad('&no_or_null' || 'audit all on ' || synonym_name || ';',50) 
 ||   ' --' || table_owner || '.' || table_name 
  as the_command 
from dba_synonyms
where owner='PUBLIC' and table_owner in (
  select username 
  from dba_users
  where oracle_maintained = 'N')
order by table_owner, table_name;

-- Crontab disable XML audit feldolgozo script.

/*
-- KIINDULASI LISTA

THE_COMMAND
----------------------------------------------------------------------------------------------------
audit all on KRTCNTRCTRDATAREQBYUID_ID_SEQ;        --SCHEMA1.KRTCNTRCTRDATAREQBYUID_ID_SEQ
audit all on KRTCONTRACTORDATAREQUESTBYUID;        --SCHEMA1.KRTCONTRACTORDATAREQUESTBYUID
audit all on KRTCONTRACTORDATARESPONSE;            --SCHEMA1.KRTCONTRACTORDATARESPONSE

105 rows selected.


*/
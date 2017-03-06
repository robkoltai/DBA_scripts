DBMS_SHARED_POOL.PURGE Is Not Working On 10.2.0.4 (Doc ID 751876.1) 

event="5614566 trace name context forever"
alter session set events '5614566 trace name context forever';

set pages 0
select 'exec dbms_shared_pool.purge(''' || address || ', ' || hash_value||''',''C'');' 
from v$sqlarea
where users_opening =0
and sharable_mem>300000
order by sharable_mem 
/

-- 11.2.0.3 kiprobaltam es nem kell az event. Siman kiszedte.





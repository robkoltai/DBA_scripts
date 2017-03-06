-- Nincs bind hasznalat es tele van vele a shared pool
select count(1) c, inst_id, 
force_matching_signature, 
parsing_schema_name
from gv$sql
where parsing_schema_name= 'TU3U001'
group by inst_id, 
force_matching_signature, 
parsing_schema_name
having count (1)>3000
order by 1 desc;

select a.ksppinm name, b.ksppstvl value 
from x$ksppi a, x$ksppcv b 
where a.indx = b.indx 
and a.ksppinm like '%rowso%';

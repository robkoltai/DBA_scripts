/*
set lines 150
set pages 0
select 'exec dbms_stats.gather_table_stats(''' || owner || 
       ''', '''|| table_name || ''', method_opt=>''for all columns size repeat'');'
from (
select --c.*
      -- distinct to generate only one row per table if more than one CHAR row exist
      distinct c.owner, c.table_name
from dba_tab_histograms h,
     dba_tab_cols c
where c.owner      = h.owner and
      c.table_name = h.table_name and
      c.column_name = h.column_name and
      -- choose individual users, or exclude Oracle schemas
      --c.owner in ('PORT')
      --c.owner not in ('SYS','SYSTEM','SYSMAN','CTXSYS','DBSNMP','MDDATA',
	  --                'MDSYS','DMSYS','OLAPSYS','ORDPLUGINS','ORDSYS,OUTLN','SI_INFORMTN_SCHEMA')
	  c.owner not in (select username from dba_users where ORACLE_MAINTAINED='Y')
      -- to have one line for each column
      and endpoint_number=0 and
      c.data_type like 'CHAR%')
order by 1;
*/	  


set time on 
set timi on

spool char_histograms_collection
select to_char(sysdate,'YYYYMMDD HH24:MI') startt from dual;
<copy generated lines here>
select to_char(sysdate,'YYYYMMDD HH24:MI') endd from dual;
spool off;
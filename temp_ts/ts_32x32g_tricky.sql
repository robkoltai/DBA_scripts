-- 32 temp tablespace x 8 datafile x 4 gb each

/*
-- drop current ones
select 'drop tablespace ' || tablespace_name || ' including contents and datafiles;'
from dba_tablespaces 
where 1=1 --contents = 'TEMPORARY'
  and tablespace_name like '%RK%'
order by 1;

*/

/*
--target file names
alter tablespace RK_temp_nvme_grouped_t1 add tempfile '/nvmedisk/RK_temp_nvme_group_1_002.dbf' size 4g autoextend off                                                                
alter tablespace RK_temp_orig_grouped_t1 add tempfile '/data/disk13/RK_temp_orig_group_1_002.dbf' size 4g autoextend off                                                             
alter tablespace RK_temp_nvme_grouped_t11 add tempfile '/nvmedisk/RK_temp_nvme_group_11_004.dbf' size 4g autoextend off                                                              
alter tablespace RK_temp_orig_grouped_t11 add tempfile '/data/disk13/RK_temp_orig_group_11_004.dbf' size 4g autoextend off                                                          

*/



spool ts_32x8x4g_create_tricky
set lines 200
set pages 5000
set serveroutput on;



prompt --------------------------------------------------
prompt let us create the RK_ONLY_FOR_TRICK tablespace
prompt --------------------------------------------------
-- This is not important. Only to make loops easier
create  tablespace RK_ONLY_FOR_TRICK datafile   '/nvmedisk/trick_dummy.dbf' size 120m autoextend off extent management local uniform size 100m;


declare i number;
        j number;
        vsql varchar2(999);
begin
 
  for i in 1 .. 32 loop
	
	for j in 1 .. 8 loop
	  vsql:='alter tablespace RK_ONLY_FOR_TRICK add datafile ''/nvmedisk/RK_temp_nvme_group_' || i  || '_' 
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g autoextend off';
	  dbms_output.put_line (vsql);	
	  --execute immediate (vsql);
	  
	  end loop;
	
  end loop;
  
end;
/


prompt --------------------------------------------------
prompt Now we drop table tablespace but not the datafiles
prompt --------------------------------------------------
drop tablespace RK_ONLY_FOR_TRICK;


prompt --------------------------------------------------
prompt Reuse the datafiles as tempfiles
prompt --------------------------------------------------


create temporary tablespace RK_temp_nvme_grouped_t1 tempfile '/nvmedisk/RK_temp_nvme_group_1_001.dbf' size 4g reuse autoextend off extent management local uniform size 100m;
ALTER TABLESPACE  RK_temp_nvme_grouped_t1 TABLESPACE GROUP temp_ts_nvme_group;


declare i number;
        j number;
        vsql varchar2(999);
begin
    -- finish group 1
	for j in 2 .. 8 loop
	  vsql:='alter tablespace RK_temp_nvme_grouped_t' || 1 ||  ' add tempfile ''/nvmedisk/RK_temp_nvme_group_' || 1  || '_' 
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g reuse autoextend off';
	  dbms_output.put_line (vsql);	
	  --execute immediate (vsql);
    end loop;

  -- DO ALL THE OTHER GROUPS
  
  for i in 2 .. 32 loop
    vsql:= 'create temporary tablespace RK_temp_nvme_grouped_t' || i || ' tempfile ''/nvmedisk/RK_temp_nvme_group_' || i || '_001.dbf'' size 4g reuse autoextend off tablespace group temp_ts_nvme_group extent management local uniform size 100m';
    dbms_output.put_line (vsql);
	--execute immediate (vsql);

	for j in 2 .. 8 loop
	  vsql:='alter tablespace RK_temp_nvme_grouped_t' || i ||  ' add tempfile ''/nvmedisk/RK_temp_nvme_group_' || i  || '_' 
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g reuse autoextend off';
	  dbms_output.put_line (vsql);	
	  --execute immediate (vsql);

  
	  end loop;
	
  end loop;
  
end;
/


spool off;
/*


select 'drop tablespace ' || tablespace_name || ' including contents and datafiles;'
from dba_tablespaces 
where 1=1 --contents = 'TEMPORARY'
  and tablespace_name like '%RK%'
order by 1;

*/

spool ts_4x128_create
set lines 11111
set pages 5000
set serveroutput on;


declare i number;
        vsql varchar2(999);
begin
  for i in 1 .. 32 loop
    vsql:= 'drop tablespace RK_temp_nvme_grouped_t' || i || ' including contents and datafiles';
    dbms_output.put_line (vsql);
	execute immediate (vsql);

    vsql:= 'drop tablespace RK_temp_orig_grouped_t' || i || ' including contents and datafiles';
    dbms_output.put_line (vsql);
    execute immediate (vsql);
  end loop;
end;
/



create temporary tablespace RK_temp_nvme_grouped_t1 tempfile '/nvmedisk/RK_temp_nvme_group_1_001.dbf' size 4g autoextend off extent management local uniform size 100m;
ALTER TABLESPACE  RK_temp_nvme_grouped_t1 TABLESPACE GROUP temp_ts_nvme_group;

create temporary tablespace RK_temp_orig_grouped_t1 tempfile '/data/disk13/RK_temp_orig_group_1_001.dbf' size 4g autoextend off extent management local uniform size 100m;
ALTER TABLESPACE  RK_temp_orig_grouped_t1 TABLESPACE GROUP temp_ts_orig_group;


declare i number;
        j number;
        vsql varchar2(999);
begin
    -- finish group 1
	for j in 2 .. 8 loop
	  vsql:='alter tablespace RK_temp_nvme_grouped_t' || 1 ||  ' add tempfile ''/nvmedisk/RK_temp_nvme_group_' || 1  || '_' 
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g autoextend off';
	  dbms_output.put_line (vsql);	
	  execute immediate (vsql);

	  vsql:='alter tablespace RK_temp_orig_grouped_t' || 1 ||  ' add tempfile ''/data/disk13/RK_temp_orig_group_' || 1  || '_'
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g autoextend off';
	  dbms_output.put_line (vsql);	
	  execute immediate (vsql);
	  
	  end loop;

  -- DO ALL THE OTHER GROUPS
  
  for i in 2 .. 32 loop
    vsql:= 'create temporary tablespace RK_temp_nvme_grouped_t' || i || ' tempfile ''/nvmedisk/RK_temp_nvme_group_' || i || '_001.dbf'' size 4g autoextend off tablespace group temp_ts_nvme_group extent management local uniform size 100m';
    dbms_output.put_line (vsql);
	execute immediate (vsql);
	
    vsql:= 'create temporary tablespace RK_temp_orig_grouped_t' || i || ' tempfile ''/data/disk13/RK_temp_orig_group_' || i || '_001.dbf'' size 4g autoextend off tablespace group temp_ts_orig_group extent management local uniform size 100m';
    dbms_output.put_line (vsql);
	execute immediate (vsql);
	
	for j in 2 .. 8 loop
	  vsql:='alter tablespace RK_temp_nvme_grouped_t' || i ||  ' add tempfile ''/nvmedisk/RK_temp_nvme_group_' || i  || '_' 
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g autoextend off';
	  dbms_output.put_line (vsql);	
	  execute immediate (vsql);

	  vsql:='alter tablespace RK_temp_orig_grouped_t' || i ||  ' add tempfile ''/data/disk13/RK_temp_orig_group_' || i  || '_'
	    || substr(to_char(j,'009'),2,3) 
        || '.dbf'' size 4g autoextend off';
	  dbms_output.put_line (vsql);	
	  execute immediate (vsql);
	  
	  end loop;
	
  end loop;
  
end;
/


spool off;
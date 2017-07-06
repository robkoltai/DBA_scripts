 -- tablespace free by gavinsoma
 set linesize 150
        column tablespace_name format a20 heading 'Tablespace'
     column sumb format 999,999,999
     column extents format 9999
     column bytes format 999,999,999,999
     column largest format 999,999,999,999
     column Tot_Size format 999,999 Heading 'Total| Size(Mb)'
     column Tot_Free format 999,999,999 heading 'Total Free(MB)'
     column Pct_Free format 999.99 heading '% Free'
     column Chunks_Free format 9999 heading 'No Of Ext.'
     column Max_Free format 999,999,999 heading 'Max Free(Kb)'
     set echo off
     PROMPT  FREE SPACE AVAILABLE IN TABLESPACES
     select a.tablespace_name,sum(a.tots/1048576) Tot_Size,
     sum(a.sumb/1048576) Tot_Free,
     sum(a.sumb)*100/sum(a.tots) Pct_Free,
     sum(a.largest/1024) Max_Free,sum(a.chunks) Chunks_Free
     from
     (
     select tablespace_name,0 tots,sum(bytes) sumb,
     max(bytes) largest,count(*) chunks
     from dba_free_space a
     group by tablespace_name
     union
     select tablespace_name,sum(bytes) tots,0,0,0 from
      dba_data_files
     group by tablespace_name) a
     group by a.tablespace_name
order by pct_free;

-- Monitoring
SELECT * FROM ( 
select '| Tablespace ->',t.tablespace_name ktablespace, 
       '| Type->',substr(t.contents, 1, 1) tipo, 
       '| Used(MB)->',trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) ktbs_em_uso, 
       '| ActualSize(MB)->',trunc(d.tbs_size/1024/1024) ktbs_size, 
       '| MaxSize(MB)->',trunc(d.tbs_maxsize/1024/1024) ktbs_maxsize, 
       '| FreeSpace(MB)->',trunc(nvl(s.free_space, 0)/1024/1024) kfree_space, 
       '| Space->',trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) kspace, 
       '| Perc->',decode(d.tbs_maxsize, 0, 0, trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize)) kperc 
from 
  ( select SUM(bytes) tbs_size, 
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize, tablespace_name tablespace 
    from ( select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name 
    from dba_data_files 
    union all 
    select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name 
    from dba_temp_files 
    ) 
    group by tablespace_name 
    ) d, 
    ( select SUM(bytes) free_space, 
    tablespace_name tablespace 
    from dba_free_space 
    group by tablespace_name 
    ) s, 
    dba_tablespaces t 
    where t.tablespace_name = d.tablespace(+) and 
    t.tablespace_name = s.tablespace(+) 
    order by 8) 
    where 1=1 --and kperc > 90 
    and tipo <>'T' 
    and tipo <>'U'
	;


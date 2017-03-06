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

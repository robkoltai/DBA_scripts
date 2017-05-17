-- 10g
alter session set workarea_size_policy=manual;
alter session set sort_area_size=500000000;

set lines 200
set pages 100
set time on
set timing on


with
objects as (
  select 'INDEX'  as segment_type, owner, index_name as segment_name, '1x1' as partition_name,
    compression, 'N/A' as compress_for, 'N/A' as deduplication from dba_indexes
  union all
  select 'INDEX PARTITION'  as segment_type, index_owner, index_name as segment_name, partition_name,
    compression, 'N/A' as compress_for, 'N/A' as deduplication from dba_ind_partitions
  union all
  select 'INDEX SUBPARTITION'  as segment_type, index_owner, index_name as segment_name, SUBPARTITION_NAME as partition_name,
    'N/A' compression, 'N/A' as compress_for, 'N/A' as deduplication from dba_ind_subpartitions
  union all
  select 'TABLE' as segment_type, owner, table_name as segment_name, '1x1' as partition_name,
    compression, 'N/A' compress_for, 'N/A' as deduplication from dba_tables
  union all
  select 'TABLE PARTITION' as segment_type, table_owner, table_name as segment_name, partition_name,
    compression, 'N/A' compress_for, 'N/A' as deduplication from dba_tab_partitions
  union all
  select 'TABLE SUBPARTITION' as segment_type, table_owner, table_name as segment_name, SUBPARTITION_NAME as partition_name,
    compression, 'N/A' compress_for, 'N/A' as deduplication from dba_tab_subpartitions
  union all
  select 'LOBSEGMENT' as segment_type, owner, segment_name as segment_name, '1x1' as partition_name,
    'N/A' compression, 'N/A' as compress_for, 'N/A' deduplication from dba_lobs
  union all
  select 'LOB PARTITION' as segment_type, table_owner, lob_name as segment_name, partition_name,
    'N/A' compression, 'N/A' as compress_for, 'N/A' deduplication from dba_lob_partitions
      union all
  select 'LOB SUBPARTITION' as segment_type, table_owner, lob_name as segment_name, SUBPARTITION_NAME as partition_name,
    'N/A' compression, 'N/A' as compress_for, 'N/A' deduplication from dba_lob_subpartitions),
ts_segments as (
  select /*+ MATERIALIZE */
         tab.tablespace_name,
         tab.status,
         seg.segment_type, owner, segment_name, nvl(partition_name,'1x1') as partition_name,
         seg.bytes/1024/1024/1024 GiB,
         tab.def_tab_compression ts_compression, 'N/A' ts_compress_for
         --,tab.*, seg.*
  from dba_segments seg,
       dba_tablespaces tab
  where seg.tablespace_name = tab.tablespace_name
)
select
       (select name from v$database) db_name,
       ts_segments.status as ts_status,
       ts_segments.segment_type,
       --ts_segments.owner,
       --ts_segments.tablespace_name,
       ts_compression,
       ts_compress_for,
       objects.compression obj_compression,
       objects.compress_for obj_compress_for,
       objects.deduplication obj_deduplication,
       count(1) count,
       round(sum(ts_segments.GiB),2) GiB
from ts_segments,
     objects
where ts_segments.segment_type = objects.segment_type and
      ts_segments.segment_name = objects.segment_name and
      ts_segments.partition_name = objects.partition_name and
      ts_segments.owner = objects.owner
group by
       ts_segments.segment_type,
       ts_segments.status,
       --ts_segments.owner,
       --ts_segments.tablespace_name,
       ts_compression,
       ts_compress_for,
       objects.compression,
       objects.compress_for,
       objects.deduplication
order by segment_type, obj_compression;


"DB_NAME","TS_STATUS","SEGMENT_TYPE","TS_COMPRESSION","TS_COMPRESS_FOR","OBJ_COMPRESSION","OBJ_COMPRESS_FOR","OBJ_DEDUPLICATION","COUNT","GIB"
"LICDEMO","ONLINE","INDEX","DISABLED","","DISABLED","N/A","N/A",1810,0,69
"LICDEMO","ONLINE","INDEX","DISABLED","","ENABLED","N/A","N/A",3,0
"LICDEMO","ONLINE","INDEX PARTITION","DISABLED","","DISABLED","N/A","N/A",254,0,03
"LICDEMO","ONLINE","LOBSEGMENT","DISABLED","","NONE","N/A","NONE",928,0,1
"LICDEMO","ONLINE","TABLE","DISABLED","","DISABLED","","N/A",1580,2,99
"LICDEMO","ONLINE","TABLE PARTITION","DISABLED","","DISABLED","","N/A",229,0,12
"LICDEMO","ONLINE","TABLE SUBPARTITION","DISABLED","","DISABLED","","N/A",32,0

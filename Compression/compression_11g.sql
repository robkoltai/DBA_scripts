/*

Találtam hibát a scriptem, jelenleg az utolsó lekérdezés join-ja kiszűri az összes partícionált lobot, mivel a LOB_PARTITIONS nézetben a lobok partíció neve LOB_<azonosító> formátumúak, míg a DBA_SEGMENTS-ben tárolt partíciónevek LOB_SYS_<azonosító> formátumúak. Ráadásul ezek az azonosítók sem egyeznek. Felteszem object_id alapján tudja összerendelni, de ennek nem mentem utána.

Úgy bukott ki a dolog, hogy azért lekérdezgettem a DBA_FEATURE_USAGE_STATISTICS nézetet is, és egyszer csak ott  mutatott secure_file_compression használatot, míg a scriptben nem volt ilyen, és utánamentem, hogy mi lehet a gond.



*/


--11g
alter session set workarea_size_policy=manual;
alter session set sort_area_size=500000000;

set lines 200
set pages 100
set time on
set timing on
column ts_encrypt format a12

with 
objects as (
  select 'INDEX'  as segment_type, owner, index_name as segment_name, '1x1' as partition_name, 
    compression, 'N/A' as compress_for, 'N/A' as deduplication from dba_indexes
  union all
  select 'INDEX PARTITION'  as segment_type, index_owner, index_name as segment_name, partition_name,
    compression, 'N/A' as compress_for, 'N/A' as deduplication from dba_ind_partitions
  union all
  select 'INDEX SUBPARTITION'  as segment_type, index_owner, index_name as segment_name, SUBPARTITION_NAME as partition_name,
    compression, 'N/A' as compress_for, 'N/A' as deduplication from dba_ind_subpartitions
  union all
  select 'TABLE' as segment_type, owner, table_name as segment_name, '1x1' as partition_name,
    compression, compress_for, 'N/A' as deduplication from dba_tables
  union all
  select 'TABLE PARTITION' as segment_type, table_owner, table_name as segment_name, partition_name, 
    compression, compress_for, 'N/A' as deduplication from dba_tab_partitions
  union all
  select 'TABLE SUBPARTITION' as segment_type, table_owner, table_name as segment_name, SUBPARTITION_NAME as partition_name, 
    compression, compress_for, 'N/A' as deduplication from dba_tab_subpartitions
  union all
  select 'LOBSEGMENT' as segment_type, owner, segment_name as segment_name, '1x1' as partition_name,
    compression, 'N/A' as compress_for, deduplication from dba_lobs
  union all
  select 'LOB PARTITION' as segment_type, table_owner, lob_name as segment_name, partition_name,
    compression, 'N/A' as compress_for, deduplication from dba_lob_partitions
      union all
  select 'LOB SUBPARTITION' as segment_type, table_owner, lob_name as segment_name, SUBPARTITION_NAME as partition_name,
    compression, 'N/A' as compress_for, deduplication from dba_lob_subpartitions),
ts_segments as (
  select /*+ MATERIALIZE */
         tab.tablespace_name,
         tab.status,
         tab.def_tab_compression ts_compression, 
		 tab.compress_for ts_compress_for,
         seg.segment_type, owner, segment_name, nvl(partition_name,'1x1') as partition_name, 
         seg.bytes/1024/1024/1024 GiB, 
		 tab.encrypted ts_encrypt
         --,tab.*, seg.*
  from dba_segments seg,
       dba_tablespaces tab
  where seg.tablespace_name = tab.tablespace_name
)
select 
       (select name from v$database) db_name,
       ts_segments.status 			as ts_status,
	   ts_segments.ts_encrypt		as ts_encrypt,
       ts_segments.ts_compression 	as ts_comp,
       ts_segments.ts_compress_for 	as ts_comp4,
       ts_segments.segment_type,
       --ts_segments.owner,
       --ts_segments.tablespace_name, 
       objects.compression as obj_comp,
       objects.compress_for as obj_comp4,
       objects.deduplication obj_dedup,
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
	   ts_encrypt,
       ts_compression,
       ts_compress_for,
       objects.compression,
       objects.compress_for,
       objects.deduplication
order by segment_type, obj_comp;

/*
DB_NAME   TS_STATUS TS_ENCRYPT   TS_COMP  TS_COMP4     SEGMENT_TYPE       OBJ_COMP OBJ_COMP4    OBJ_DEDUP            COUNT        GIB
--------- --------- ------------ -------- ------------ ------------------ -------- ------------ --------------- ---------- ----------
TMSDB     ONLINE    NO           DISABLED              INDEX              DISABLED N/A          N/A                   2376        .43
TMSDB     ONLINE    NO           DISABLED              INDEX              ENABLED  N/A          N/A                     59        .01
TMSDB     ONLINE    NO           DISABLED              INDEX PARTITION    DISABLED N/A          N/A                    286        .04
TMSDB     ONLINE    NO           DISABLED              LOBSEGMENT         NO       N/A          NO                      59         .1
TMSDB     ONLINE    NO           DISABLED              LOBSEGMENT         NONE     N/A          NONE                   799      32.01
TMSDB     ONLINE    NO           DISABLED              TABLE              DISABLED              N/A                   1640        .76
TMSDB     ONLINE    NO           DISABLED              TABLE              ENABLED  OLTP         N/A                      2          0
TMSDB     ONLINE    NO           DISABLED              TABLE PARTITION    DISABLED              N/A                    256        .04
TMSDB     ONLINE    NO           DISABLED              TABLE SUBPARTITION DISABLED              N/A                     32          0

*/

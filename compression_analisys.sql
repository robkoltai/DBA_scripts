-- tablaterek kompresszaltsaga
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
         seg.segment_type, owner, segment_name, nvl(partition_name,'1x1') as partition_name, 
         seg.bytes/1024/1024/1024 gbytes, 
         tab.def_tab_compression ts_compression, tab.compress_for ts_compress_for
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
       round(sum(ts_segments.gbytes),2) gbytes
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

/*
DB_NAME   TS_STATUS SEGMENT_TYPE       TS_COMPR TS_COMPRESS_FOR                OBJ_COMPRESSI OBJ_COMPRESS_FOR               OBJ_DEDUPLICATI      COUNT     GBYTES
--------- --------- ------------------ -------- ------------------------------ ------------- ------------------------------ --------------- ---------- ----------
DWHSBPR   ONLINE    INDEX              DISABLED                                DISABLED      N/A                            N/A                   2559      33.52
DWHSBPR   ONLINE    INDEX              DISABLED                                ENABLED       N/A                            N/A                     57        .02
DWHSBPR   ONLINE    INDEX PARTITION    DISABLED                                DISABLED      N/A                            N/A                   4390       1.64
DWHSBPR   ONLINE    LOB PARTITION      DISABLED                                NO            N/A                            NO                    1172        .99
DWHSBPR   ONLINE    LOBSEGMENT         DISABLED                                NO            N/A                            NO                     532        .81
DWHSBPR   ONLINE    LOBSEGMENT         DISABLED                                NONE          N/A                            NONE                   135        .15
DWHSBPR   ONLINE    TABLE              DISABLED                                DISABLED                                     N/A                   1871     345.23
DWHSBPR   ONLINE    TABLE              DISABLED                                ENABLED       BASIC                          N/A                     74      54.96
DWHSBPR   ONLINE    TABLE PARTITION    DISABLED                                DISABLED                                     N/A                  15832     234.07
DWHSBPR   ONLINE    TABLE PARTITION    DISABLED                                ENABLED       BASIC                          N/A                   1102    3279.19

10 rows selected.

Elapsed: 00:00:03.23
*/



SQL> select sum(bytes/1024/1024/1024) gb from dba_data_files;

        GB
----------
 7368.1709

column owner format a20
column table_name format a30
column table_owner format a30
column partition_name format a30
column subpartition_name format a30
column segment_name format a30


select owner, table_name, PARTITIONED
from dba_tables
where rownum<3
and owner not like '%SYS%'
and PARTITIONED='YES';


OWNER                TABLE_NAME           PAR
-------------------- -------------------- ---
EALS                 EALS_MULTI_LOG       YES
DWEXT                EDS_SAP_COPA_DETAIL  YES

select table_owner, table_name, partition_name
from dba_tab_partitions
where table_owner in ('EALS','DWEXT') and table_name in ('EALS_MULTI_LOG','EDS_SAP_COPA_DETAIL');


TABLE_OWNER          TABLE_NAME           PARTITION_NAME
-------------------- -------------------- --------------------
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_6775975888
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_4945679478
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_4576010162
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_2125855157
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_2125718996
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_2120949111
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_2082224638
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_2076598292
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_1373080425
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_1344925043
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_123

TABLE_OWNER          TABLE_NAME           PARTITION_NAME
-------------------- -------------------- --------------------
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_1207980497
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_1112192641
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_1091961008
DWEXT                EDS_SAP_COPA_DETAIL  ODSACODE_1034079031
EALS                 EALS_MULTI_LOG       PI_2017_2
EALS                 EALS_MULTI_LOG       PI_2017_1
EALS                 EALS_MULTI_LOG       PI_2016_2
EALS                 EALS_MULTI_LOG       PI_2016_1
EALS                 EALS_MULTI_LOG       PI_2015_2
EALS                 EALS_MULTI_LOG       PI_2015_1

select 
owner, segment_name, partition_name, segment_type, bytes/1024/1024/1024 GB
from dba_segments
where segment_name in ('EDS_SAP_COPA_DETAIL','ODSACODE_6775975888','ODSACODE_4945679478','EALS_MULTI_LOG','PI_2016_1','PI_2016_2');

select
 TABLE_OWNER    , 
 TABLE_NAME     , 
 PARTITION_NAME , 
 SUBPARTITION_NAME
from dba_tab_subpartitions;

TABLE_OWNER                    TABLE_NAME                     PARTITION_NAME                 SUBPARTITION_NAME
------------------------------ ------------------------------ ------------------------------ ------------------------------
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP112
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP111
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP110
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP109
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP108
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP107
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP106
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP105
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP104
SYS                            WRI$_OPTSTAT_SYNOPSIS$         P0                             SYS_SUBP103

select
owner, segment_name, partition_name, segment_type, bytes/1024/1024/1024 GB
from dba_segments
where segment_name in ('WRI$_OPTSTAT_SYNOPSIS$');

select
owner, segment_name, partition_name, segment_type, bytes/1024/1024/1024 GB
from dba_segments
where segment_TYPE like ('%SUB%');

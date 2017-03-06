/**********************************************************************
 * File:        cbo_stats.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        29aug04
 *
 * Description:
 *	SQL*Plus script to display statistics used by the cost-
 *	based optimizer, at the global table- and index-level, as well
 *	as the partition and sub-partition levels, if they exist.
 *
 * Modifications:
 *********************************************************************/
undef owner
undef table_name
clear breaks computes
set echo off feedback off timing off verify off
set pagesize 100 linesize 130 trimout on trimspool on pause off arraysize 100
col avg_row_len heading "Avg|Row|Len" format 990
col num_rows heading "Nbr|Rows" format 999,999,999,990
col blocks heading "Used|Blocks" format 999,999,999,990
col sample_size heading "Sample|Size" format 999,999,999,990
col last_analyzed heading "Last|Analyz" format a6 truncate
col index_name heading "Index Name" format a30
col partition_name heading "Partition Name" format a30
col subpartition_name heading "Subpartition Name" format a30
col blevel heading "Br|Lvl" format 90
col leaf_blocks heading "Leaf|Blocks" format 999,990
col distinct_keys heading "Distinct|Keys" format 99,999,990
col avg_leaf_blocks_per_key heading "Avg|Leaf|Blocks|Per|Key" format 999,990
col avg_data_blocks_per_key heading "Avg|Data|Blocks|Per|Key" format 999,990
col clustering_factor heading "Cluster|Factor" format 99,999,990
col column_name heading "Column Name" format a30
col num_distinct heading "Distinct|Values" format 99,999,990
col num_nulls heading "Nulls" format 99,999,990
col null_buckets heading "Buckets" format 99,999,990
col avg_col_len heading "Avg|Col|Len" format 990

spool cbo_stats_&&owner._&&table_name
ttitle left 'Global-level table statistics for "&&owner..&&table_name"' skip 1 line
select	avg_row_len,
	num_rows,
	blocks,
	sample_size,
	to_char(last_analyzed, 'DD-MON')
from	dba_tables
where	owner = upper('&&owner')
and	table_name = upper('&&table_name');
ttitle left 'Partition-level table statistics for "&&owner..&&table_name"' skip 1 line
select	partition_name,
	avg_row_len,
	num_rows,
	blocks,
	sample_size,
	to_char(last_analyzed, 'DD-MON') last_analyzed
from	dba_tab_partitions
where	table_owner = upper('&&owner')
and	table_name = upper('&&table_name')
order by partition_position;
ttitle left 'Subpartition-level table statistics for "&&owner..&&table_name"' skip 1 line
select	subpartition_name,
	avg_row_len,
	num_rows,
	blocks,
	sample_size,
	to_char(last_analyzed, 'DD-MON') last_analyzed
from	dba_tab_subpartitions
where	table_owner = upper('&&owner')
and	table_name = upper('&&table_name')
order by subpartition_position;
ttitle left 'Global-level index CBO statistics for "&&owner..&&table_name"' skip 1 line
select	index_name,
	blevel,
	leaf_blocks,
	distinct_keys,
	avg_leaf_blocks_per_key,
	avg_data_blocks_per_key,
	clustering_factor,
	num_rows,
	sample_size,
	to_char(last_analyzed, 'DD-MON') last_analyzed
from	dba_indexes
where	table_owner = upper('&&owner')
and	table_name = upper('&&table_name')
order by index_name;
break on index_name
ttitle left 'Partition-level index CBO statistics for "&&owner..&&table_name"' skip 1 line
select	p.index_name,
	p.partition_name,
	p.blevel,
	p.leaf_blocks,
	p.distinct_keys,
	p.avg_leaf_blocks_per_key,
	p.avg_data_blocks_per_key,
	p.clustering_factor,
	p.num_rows,
	p.sample_size,
	to_char(p.last_analyzed, 'DD-MON') last_analyzed
from	dba_ind_partitions	p,
	dba_indexes		i
where	i.table_owner = upper('&&owner')
and	i.table_name = upper('&&table_name')
and	p.index_owner = i.owner
and	p.index_name = i.index_name
order by p.index_name, p.partition_position;
ttitle left 'Subpartition-level index CBO statistics for "&&owner..&&table_name"' skip 1 line
select	sp.index_name,
	sp.subpartition_name,
	sp.blevel,
	sp.leaf_blocks,
	sp.distinct_keys,
	sp.avg_leaf_blocks_per_key,
	sp.avg_data_blocks_per_key,
	sp.clustering_factor,
	sp.num_rows,
	sp.sample_size,
	to_char(sp.last_analyzed, 'DD-MON') last_analyzed
from	dba_ind_subpartitions	sp,
	dba_indexes		i
where	i.table_owner = upper('&&owner')
and	i.table_name = upper('&&table_name')
and	sp.index_owner = i.owner
and	sp.index_name = i.index_name
order by sp.index_name, sp.subpartition_position;
ttitle left 'Column-level CBO statistics for "&&owner..&&table_name"' skip 1 line
select	column_name,
	num_distinct,
	num_nulls,
	num_buckets,
	avg_col_len,
	sample_size,
	to_char(last_analyzed, 'DD-MON') last_analyzed
from	dba_tab_columns
where	owner = upper('&&owner')
and	table_name = upper('&&table_name')
order by column_id;
spool off
ttitle off
clear breaks computes
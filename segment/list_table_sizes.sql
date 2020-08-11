

-- This SQL lists the big tables taking into account the index, lob, lobindex sizes
-- and works for partitioned objects as well
/*

"OWNER"	"TABLE_NAME"			"ALL_GB"	"PERCENT"	"TABLE_GB"	"TABLE_PART_GB"	"TABLE_SUBPART_GB"	"INDEX_GB"	"INDEX_PART_GB"	"INDEX_SUBPART_GB"	"LOB_GB"	"LOB_PART_GB"	"LOB_INDEX_GB"
"DM"	"AG_DAILY_IRM_BASE"		3039.37		15			0			3039.37			0					0	0	0	0	0	0
"DM"	"AG_MONTH_END_DEAL"		2969.75		15			0			0				2863.14				0	0	106.61	0	0	0
"DM"	"AG_DEAL_BALANCE"		687.65		3			0			687.65			0					0	0	0	0	0	0
"DM"	"AG_MONTH_END_PARTY"	652.59		3			0			0				628.81				0	0	23.78	0	0	0

*/

SELECT
   owner, 
   table_name, 
   round(sum(table_bytes+table_part_bytes+table_subpart_bytes  +  index_bytes+index_part_bytes+index_subpart_bytes  +  lob_bytes+lob_part_bytes+lob_index_bytes)/1024/1024/1024,2) all_GB,
   ROUND( ratio_to_report( sum(table_bytes+table_part_bytes+table_subpart_bytes  +  index_bytes+index_part_bytes+index_subpart_bytes  +  lob_bytes+lob_part_bytes+lob_index_bytes) ) over () * 100) Percent,
   round(sum(table_bytes)/1024/1024/1024,2) table_GB,
   round(sum(table_part_bytes)/1024/1024/1024,2) table_part_GB,
   round(sum(table_subpart_bytes)/1024/1024/1024,2) table_subpart_GB,
   round(sum(index_bytes)/1024/1024/1024,2) index_GB,
   round(sum(index_part_bytes)/1024/1024/1024,2) index_part_GB,
   round(sum(index_subpart_bytes)/1024/1024/1024,2) index_subpart_GB,
   round(sum(lob_bytes)/1024/1024/1024,2) lob_GB,
   round(sum(lob_part_bytes)/1024/1024/1024,2) lob_part_GB,
   round(sum(lob_index_bytes)/1024/1024/1024,2) lob_index_GB
FROM
(
 SELECT segment_name table_name, owner, 
    decode (segment_type,'TABLE', bytes,0) table_bytes,
    decode (segment_type,'TABLE PARTITION', bytes,0) table_part_bytes,
    decode (segment_type,'TABLE SUBPARTITION', bytes,0) table_subpart_bytes,
    0 index_bytes,
    0 index_part_bytes,
    0 index_subpart_bytes,
    0 lob_bytes,
    0 lob_part_bytes,
    0 lob_index_bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 --
 UNION ALL
 SELECT i.table_name, i.owner, 
   0,0,0,
   decode (segment_type,'INDEX', bytes,0) INDEX_bytes,
   decode (segment_type,'INDEX PARTITION', bytes,0) INDEX_part_bytes,
   decode (segment_type,'INDEX SUBPARTITION', bytes,0) INDEX_subpart_bytes,
   0,
   0,
   0
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
   AND   s.owner = i.owner
   AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 --
 UNION ALL
 SELECT l.table_name, l.owner, 
   0,0,0,0,0,0,
   decode (segment_type,'LOBSEGMENT', bytes,0) lob_bytes,
   decode (segment_type,'LOB PARTITION', bytes,0) lob_part_bytes,
   0
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
   AND   s.owner = l.owner
   AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 -- LOB INDEX
 UNION ALL
 SELECT l.table_name, l.owner,
   0,0,0,0,0,0,0,0,
   decode (segment_type,'LOBINDEX', bytes,0) lob_index_bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
   AND   s.owner = l.owner
   AND   s.segment_type = 'LOBINDEX')
GROUP BY table_name, owner
HAVING round(sum(table_bytes+table_part_bytes+table_subpart_bytes  +  index_bytes+index_part_bytes+index_subpart_bytes  +  lob_bytes+lob_part_bytes+lob_index_bytes)/1024/1024/1024,2) > 1  /* Ignore really small tables */
ORDER BY 3 desc;

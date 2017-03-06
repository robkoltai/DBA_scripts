set pages 999
set lines 131
ttitle 'Contents of Data Buffers'
column owner  heading "Owner" format a10
column objname heading "Object|Name" format a25
column subobjname heading "Subobject|Name" format a25
column objtype heading "Object|Type" format a10
column bufferblocks heading "Blocks in|Buffer" format 999,999,999
column totalblocks heading "Total|Blocks" format 999,999,999
column bufferpercent heading "Percentage|in Buffer" format 999.99
column memkb heading "Memory|in KB" format 999,999,999
column blockkb heading "Block|Size|KB" format 99
select
 s.owner owner,
 object_name objname,
 subobject_name subobjname,
 substr(object_type,1,10) objtype,
 ts.block_size / 1024 blockkb,
 buffer.blocks blocks,
 s.blocks totalblocks,
 (buffer.blocks * ts.block_size / 1024) memkb,
 (buffer.blocks/decode(s.blocks, 0, .001, s.blocks))*100 bufferpercent
from
 (select o.owner, o.object_name, o.subobject_name,
         o.object_type object_type, count(*) blocks
  from dba_objects o, v$bh bh
  where o.object_id = bh.objd and o.owner not in ('SYS','SYSTEM')
  group by o.owner, o.object_name, o.subobject_name, o.object_type) buffer,
  dba_segments s,
 dba_tablespaces ts
where s.tablespace_name = ts.tablespace_name
  and s.owner = buffer.owner
  and s.segment_name = buffer.object_name
  and s.SEGMENT_TYPE = buffer.object_type
  and (s.PARTITION_NAME = buffer.subobject_name or buffer.subobject_name is null)
order by bufferpercent asc;
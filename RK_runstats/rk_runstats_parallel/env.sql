alter session set statistics_level=all;
set serveroutput on
set lines 200
set pages 500
--set timi on

alter system set parallel_max_servers=0;
alter system set parallel_max_servers=200;

alter session set db_file_multiblock_read_count=512;

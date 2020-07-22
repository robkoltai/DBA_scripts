select * from dwms.gdw_statistics;
U22615.A2_LIST
;
select * from dwms.gdw_statistics where statid='GDW_20200701_DB' and type='T' and c5='U22615';

select c5 "OWNER", c1 "TABLE_NAME" from dwms.gdw_statistics where type = 'T';

select /*+ parallel(s,16) */ count(distinct c5||'.'||c1) from dwms.gdw_statistics s where type = 'T' ;

--drop sequence dwms.wrk_gdw_stats_seq;
--drop table    dwms.wrk_gdw_stats_ctrl purge;
--create index dwms.wrk_gdw_statistics_i1 on dwms.gdw_statistics (type,c5,c1) compress 2 parallel 16 tablespace sysaux;

Create sequence dwms.wrk_gdw_stats_seq start with 1 increment by 1 nocycle cache 1000;
create table dwms.wrk_gdw_stats_ctrl  (
    id number default dwms.wrk_gdw_stats_seq.nextval primary key,
    OWNER       VARCHAR2(128),
    TABLE_NAME  VARCHAR2(128), 
    CNT         number, 
    IMPORTED    char(1)
) 
tablespace sysaux;
insert into dwms.wrk_gdw_stats_ctrl (OWNER, TABLE_NAME, CNT, IMPORTED) 
select  /*+ parallel(s,16) */ c5 "OWNER", c1 "TABLE_NAME", count(*) "CNT", 'N' "IMPORTED"  
from dwms.gdw_statistics s 
where statid='GDW_20200701_DB' 
and type = 'T' 
-- and c5='U22615'
group by c5, c1 
order by count(*) desc;
commit;

select count(*) from dwms.wrk_gdw_stats_ctrl order by 1 ;

select * from dwms.wrk_gdw_stats_ctrl order by 1 ;

select * from dwms.gdw_statistics s where c1='AB_BANKCARD' and type = 'T';

 select owner, table_name 
    --into v_owner, v_table_name
    from dwms.wrk_gdw_stats_ctrl
    where id = :start_id;


select count(*) from dba_tab_statistics where owner='DM' and last_analyzed is not null;
--GDW:  128414
--PDW2: 128414

select * from DBA_PARALLEL_EXECUTE_TASKS;
select * from DBA_PARALLEL_EXECUTE_CHUNKS;

--exec DBMS_PARALLEL_EXECUTE.drop_task('stats_import_task');

select count(*), min(start_ts), max(end_ts), max(end_ts)-min(start_ts) elapsed,  max(end_ts-start_ts) max_len from DBA_PARALLEL_EXECUTE_CHUNKS where status = 'PROCESSED';
select end_ts-start_ts len, c.* from DBA_PARALLEL_EXECUTE_CHUNKS c where status = 'PROCESSED' and (end_ts-start_ts) > NUMTODSINTERVAL (1, 'MINUTE') order by 1 desc;
create table dwms.wrk_PARALLEL_EXECUTE_CHUNKS as select * from DBA_PARALLEL_EXECUTE_CHUNKS;

select * from DBA_PARALLEL_EXECUTE_CHUNKS where status <> 'PROCESSED';

select * from dwms.wrk_gdw_stats_ctrl where imported <> 'Y' order by 1 ;

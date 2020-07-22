Hali!
             Mondtad, hogy érdekel, mennyire lehet gyorsítani a statisztika importot párhuzamosítással.
             Eléggé… Eredeti: 4.5h, parallel: 35’

             Ráadásul valószínűleg ennél gyorsabbak is lettünk volna, ha nem 2 VCPU-val indult volna a folyamat, miközben 32-es parallelizmust adtam meg néki – aminek következtében fél perc után már csak buffer busy waitet láttam, a CPU (az a 16 szál) meg kb. kockára ki volt ütve.
             Közben kértem bővítést (online), és így ezek kölcsönhatásaképpen jött ki a fenti gyorsulás.

             A lényeg: csinál az ember egy táblicskut, aminek a sorainak a feldolgozását fel tudja osztani processek közt az dbms_parallel_execute csomaggal. Igazából használhatnék létező táblát is, de így külön fel tudtam jegyezni, hogy melyik tábla statisztikája lett beimportálva.
             További gyorsítás lehetne valószínűleg, ha partíciónként importálom a statisztikát, de akkor ki kellett volna találnom, hogy hogyan lehet importálni a tábla szintű infókat.
Olyan egyszerű, hogy nem is értem, miért nem használom ezt kb. mindenre…

             Csatoltam a két scriptet, amit használtam, de a lényeget ide is kiemelem. 
             Az egy lényeges dolog, hogy a futtatandó SQL-ben (ami lehet PL/SQL is), szerepelnie kell mindkét bind változónak (:start_id, :end_id), ha valamelyik hiányzik, hibát kapsz futtatáskor. Mivel én a felosztást 1 rekordra adtam meg, amikor ezek értéke úgyis azonos, én ebbe szépen beleszaladtam.

             Tábla létrehozás:
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

             Futtatás:
DECLARE
  l_task     VARCHAR2(30) := 'stats_import_task';
  l_sql_stmt VARCHAR2(32767);
BEGIN
  DBMS_PARALLEL_EXECUTE.create_task (task_name => l_task);

  DBMS_PARALLEL_EXECUTE.create_chunks_by_number_col(task_name    => l_task,
                                                    table_owner  => 'DWMS',
                                                    table_name   => 'WRK_GDW_STATS_CTRL',
                                                    table_column => 'ID',
                                                    chunk_size   => 1);

  l_sql_stmt := 
  q'[
    DECLARE
        v_owner      varchar2(128);
        v_table_name varchar2(128);
        v_start_id   number  := :start_id;
        v_end_id     number  := :end_id;
    BEGIN 
        select owner, table_name 
        into v_owner, v_table_name
        from dwms.wrk_gdw_stats_ctrl
        where id = v_start_id;
        
        DBMS_STATS.IMPORT_TABLE_STATS (
            statown        => 'DWMS',
            stattab        => 'GDW_STATISTICS',
            statid         => 'GDW_20200701_DB',
            stat_category  => 'OBJECT_STATS, SYNOPSES',
            ownname        => v_owner,
            tabname        => v_table_name
        );
        
        update dwms.wrk_gdw_stats_ctrl
        set IMPORTED = 'Y'
        where id = :start_id;
        commit;
    END;
  ]';

  DBMS_PARALLEL_EXECUTE.run_task(task_name      => l_task,
                                 sql_stmt       => l_sql_stmt,
                                 language_flag  => DBMS_SQL.NATIVE,
                                 parallel_level => 32);
END;
/

             Ellenőrzés:
select * from DBA_PARALLEL_EXECUTE_TASKS;
select * from DBA_PARALLEL_EXECUTE_CHUNKS;

             Tisztogatás a frameworkből:
exec DBMS_PARALLEL_EXECUTE.drop_task('stats_import_task');

create user inc identified by inc;
grant dba to inc;

conn inc/inc;

drop table inc.t_interval purge;
drop table inc.t_range purge;

CREATE TABLE inc.t_interval
    ( time_id        DATE,
	  n number    ) 
  PARTITION BY RANGE (time_id) 
  INTERVAL(numtodsinterval(1, 'DAY'))
    ( PARTITION p15 VALUES LESS THAN (TO_DATE('16-02-2022', 'DD-MM-YYYY')),
      PARTITION p16 VALUES LESS THAN (TO_DATE('17-02-2022', 'DD-MM-YYYY')),
      PARTITION p17 VALUES LESS THAN (TO_DATE('18-02-2022', 'DD-MM-YYYY')),
      PARTITION p18 VALUES LESS THAN (TO_DATE('19-02-2022', 'DD-MM-YYYY')) );

insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),17);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),22);

	  
create TABLE inc.t_range
    ( time_id        DATE,
	  n number    ) 
  PARTITION BY RANGE (time_id) 
    ( PARTITION p15 VALUES LESS THAN (TO_DATE('16-02-2022', 'DD-MM-YYYY')),
      PARTITION p16 VALUES LESS THAN (TO_DATE('17-02-2022', 'DD-MM-YYYY')),
      PARTITION p17 VALUES LESS THAN (TO_DATE('18-02-2022', 'DD-MM-YYYY')),
      PARTITION p18 VALUES LESS THAN (TO_DATE('19-02-2022', 'DD-MM-YYYY')) );
	  
-- masodik sor error, de nem baj
insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),17);
insert into inc.t_range values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),22);

commit;




---- GYUJTES POSTA MODRA
 create or replace
    PROCEDURE inc.analyze_schema (i_owner VARCHAR2, i_percent NUMBER DEFAULT DBMS_STATS.auto_sample_size)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        EXECUTE IMMEDIATE 'alter session force parallel query parallel 4';

        DBMS_STATS.GATHER_SCHEMA_STATS (ownname            => i_owner,
                                        estimate_percent   => i_percent,
                                        --method_opt       => 'FOR ALL COLUMNS SIZE AUTO',
                                        DEGREE             => DBMS_STATS.AUTO_DEGREE,
                                        granularity        => 'PARTITION',
                                        CASCADE            => DBMS_STATS.AUTO_CASCADE,
                                        options            => 'GATHER STALE');

        EXECUTE IMMEDIATE 'alter session enable parallel query';
    END;
/


-- El?ször csak a 3 particio van benne a táblában, ahol volt insert !!! 
-- AHOL nem volt insert arra nincs rekord
select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;

-- particiok megvannak, Nincsenek analizalva
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tab_partitions t where table_owner = 'INC';
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tables t where owner = 'INC';

-- Mik a PREFERENCIAK??
select dbms_stats.get_prefs('STALE_PERCENT', null, null) from dual;
select dbms_stats.get_prefs('INCREMENTAL', null, null) from dual;
select dbms_stats.get_prefs('INCREMENTAL_STALENESS', null, null) from dual;	

select dbms_stats.get_prefs('STALE_PERCENT', 'INC', null) from dual;
select dbms_stats.get_prefs('INCREMENTAL', 'INC', null) from dual;
select dbms_stats.get_prefs('INCREMENTAL_STALENESS', 'INC', null) from dual;	


select dbms_stats.get_prefs('STALE_PERCENT', 'INC', 'T_INTERVAL') from dual;
select dbms_stats.get_prefs('INCREMENTAL', 'INC', 'T_INTERVAL') from dual;
select dbms_stats.get_prefs('INCREMENTAL_STALENESS', 'INC', 'T_INTERVAL') from dual;	


-- stat GYUJTES AUTO
-- Szimulalom az ejszakai automatikus statisztika gyujtest
-- Hatterben fut jobkent!!!
exec DBMS_AUTO_TASK_IMMEDIATE.GATHER_OPTIMIZER_STATS;
-- Ha lefutott akkor ez nem ad vissza sort
select job_name,state from dba_scheduler_jobs where program_name='GATHER_STATS_PROG';

-- AUTO Stat gyújtés után NEHA, NEHA NEM megjelennek a táblák is.
-- 
select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;

-- Sajat stat gyujtes
exec inc.analyze_schema('INC');

-- A tablak es az erintett particiok statisztikazva lettek
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tab_partitions t where table_owner = 'INC';
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tables t where owner = 'INC';

---------------
-- DE NEM INKREMENTALIS A STATISZTIKA, MERT NINCS SYNOPSYS ADAT !!!!
---------------
select o.owner, o.object_name, h.*
from  WRI$_OPTSTAT_SYNOPSIS_HEAD$ h, dba_objects o
where h.bo#=o.object_id and owner not like 'SYS%';
select * from  WRI$_OPTSTAT_SYNOPSIS$;

-- Sajat stat gyujtes utan minden megmarad. 3 particio 2 tabla
select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;

-- Allitsuk be az inkrementalisat
exec dbms_stats.set_table_prefs( 'INC', 'T_INTERVAL','STALE_PERCENT',5);
exec dbms_stats.set_table_prefs( 'INC', 'T_INTERVAL','INCREMENTAL','TRUE');
exec dbms_stats.set_table_prefs( 'INC', 'T_INTERVAL','INCREMENTAL_STALENESS','ALLOW_MIXED_FORMAT');

-- NIncs synonpsis??
-- NINCS. Nyilvan nem vartunk ettol.
select o.owner, o.object_name, h.*
from  WRI$_OPTSTAT_SYNOPSIS_HEAD$ h, dba_objects o
where h.bo#=o.object_id and owner not like 'SYS%';
select * from  WRI$_OPTSTAT_SYNOPSIS$;

-- Sajat stat gyujtes
exec inc.analyze_schema('INC');

-- Sajat stat gyujtes utan minden megmarad. 3 particio 2 tabla!!!!
select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;

-- NIncs synonpsis??
-- Meg most sincs, mert nem jott uj adat.
select o.owner, o.object_name, h.*
from  WRI$_OPTSTAT_SYNOPSIS_HEAD$ h, dba_objects o
where h.bo#=o.object_id and owner not like 'SYS%';
select * from  WRI$_OPTSTAT_SYNOPSIS$;


-- INSERTEK
insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),1);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),2);
insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),3);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),4);
insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),5);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),6);

insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),1);
insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),2);
insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),3);
commit;

-- Sajat stat gyujtes utan minden megmarad. 3 particio 2 tabla!!!!
select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;

-- Sajat stat gyujtes
exec inc.analyze_schema('INC');

-- MEGJELENTEK A SYNOPSYS-ok
select o.owner, o.object_name, h.*
from  WRI$_OPTSTAT_SYNOPSIS_HEAD$ h, dba_objects o
where h.bo#=o.object_id and owner not like 'SYS%';
select * from  WRI$_OPTSTAT_SYNOPSIS$;

-- ES TABLA ANAL REGEN VOLT
-- PARTICIO ANAL FRISS
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tab_partitions t where table_owner = 'INC';
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tables t where owner = 'INC';


-- SIMA STATISZTIKA GYUJTES DEFAULT
exec dbms_stats.gather_table_stats ('INC','T_INTERVAL');

-- NIncs synonpsis??
-- VAN SYNONPSIS!!!!
select o.owner, o.object_name, h.*
from  WRI$_OPTSTAT_SYNOPSIS_HEAD$ h, dba_objects o
where h.bo#=o.object_id and owner not like 'SYS%';
select * from  WRI$_OPTSTAT_SYNOPSIS$;

-- Sajat stat gyujtes utan minden megmarad. 
-- ELTUNTEK AZ INTERVAL TABLA ADATAI!!!
select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;

select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tab_partitions t where table_owner = 'INC';
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tables t where owner = 'INC';

-- SIMA STATISZTIKA GYUJTES DEFAULT
exec dbms_stats.gather_table_stats ('INC','T_INTERVAL');

-- INCREMENTAL STATS MEGTORTENT! TABLAT FRISSITETTE PARTICIOT NEM!!!!!
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tab_partitions t where table_owner = 'INC';
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tables t where owner = 'INC';


-- INSERTEK megint
insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),1);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),2);
insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),3);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),4);
insert into inc.t_interval values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),5);
insert into inc.t_interval values (TO_DATE('22-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),6);

insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),1);
insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),2);
insert into inc.t_range values (TO_DATE('17-02-2022 15:45', 'DD-MM-YYYY HH24:MI'),3);
commit;

select * from dba_tab_modifications where table_owner = 'INC' order by 2,3;


-- stat GYUJTES AUTO
-- Szimulalom az ejszakai automatikus statisztika gyujtest
-- Hatterben fut jobkent!!!
exec DBMS_AUTO_TASK_IMMEDIATE.GATHER_OPTIMIZER_STATS;
-- Ha lefutott akkor ez nem ad vissza sort
select job_name,state from dba_scheduler_jobs where program_name='GATHER_STATS_PROG';


-- Ez NEM inkrementalis!!!
-- DB Szintu gyujtest ki kell iktatni!!!
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tab_partitions t where table_owner = 'INC';
select to_char(t.last_analyzed,'YYYYMMDD HH24:MI:SS') last_ana, t.* from dba_tables t where owner = 'INC';



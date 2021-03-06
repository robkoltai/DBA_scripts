drop tablespace RK_perm_tab including contents and datafiles;

create tablespace RK_perm_tab datafile    '/data/disk10/RK_perm_tab_01.dbf' size 8g autoextend off blocksize 4k;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_02.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_03.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_04.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_05.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_06.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_07.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_08.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_09.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_10.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_11.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_12.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_13.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_14.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_15.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_16.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_17.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_18.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_19.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_20.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_21.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_22.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_23.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_24.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_25.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_26.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_27.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_28.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_29.dbf' size 8g autoextend off  ;
alter tablespace RK_perm_tab add datafile '/data/disk10/RK_perm_tab_30.dbf' size 8g autoextend off  ;

alter user nvme default tablespace RK_perm_tab;

conn rat/rat
/*
SQL> desc kirk  -- 10000 records
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 LEV_PK                                    NOT NULL NUMBER
 DAT                                                DATE
 NAME                                               CHAR(4)

SQL> desc mike -- 1m records
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 LEV_FK                                             NUMBER
 NAME                                               CHAR(4)
 
Each Kirk has 100 Mikes
    LEV_FK   COUNT(1)
---------- ----------
...
      9209        100
      9210        100
      9212        100
      9215        100
      9235        100
      9251        100
      9253        100
      9263        100
      9285        100
      9291        100
      9295        100
...

Kirk has a PK
Mike has a foreign key constraint on the FK column

*/

drop table mike purge;
drop table kirk purge;

-- Father
create table kirk as select
 level as lev_pk,
 sysdate dat,
 'kirk' name
from dual 
connect by level<=1e4;

alter table kirk add constraint kirk_pk_c primary key (lev_pk);


-- Child
create table mike as 
with data as (
  select
    'mike' name
  from dual 
  connect by level<=1e3)
select  mod(rownum,1e4)+1 as lev_fk,
        d1.name
from data d1, data d2
where rownum<=1e6
;

alter table mike add foreign key (lev_fk) references kirk (lev_pk) on delete cascade;


exec dbms_stats.gather_table_stats('RAT','KIRK') ;
exec dbms_stats.gather_table_stats('RAT','MIKE') ;

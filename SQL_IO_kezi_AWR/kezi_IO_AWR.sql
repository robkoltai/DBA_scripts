
-- Csinalunk egy temp tablat
-- Egy kis ido mulva nezhetjuk is az IO hasznalokat

--drop table rktemp purge;

create table rktemp
  as 
select PHYSICAL_READ_REQUESTS, PHYSICAL_READ_BYTES, sql_id , sysdate d
from v$sqlarea order by 2;
  
select sum (kb_persec) from ( 
select a.PHYSICAL_READ_REQUESTS - t.PHYSICAL_READ_REQUESTS reads, 
       round ((a.PHYSICAL_READ_REQUESTS - t.PHYSICAL_READ_REQUESTS) / ((sysdate - t.d) *24*60*60 )) as read_persec,
       round ((a.PHYSICAL_READ_BYTES -t.PHYSICAL_READ_BYTES)/1024/1024) as mbytes, 
       (sysdate - t.d) * 24* 60*60 as sec,
       --sysdate - t.d as diff,
       round(((a.PHYSICAL_READ_BYTES -t.PHYSICAL_READ_BYTES)/1024)/ ((sysdate - t.d)*24*60*60)) as kb_persec,
       -- a +1 azert kell, hogy ne legyen nullaval valo osztas
       round((a.PHYSICAL_READ_BYTES -t.PHYSICAL_READ_BYTES)/(a.PHYSICAL_READ_REQUESTS - t.PHYSICAL_READ_REQUESTS + 1),2) bytes_per_read,
       a.sql_id
from v$sqlarea a, rktemp t
where a.sql_id = t.sql_id
order by 3 asc
);

/*

     READS READ_PERSEC     MBYTES        SEC  KB_PERSEC BYTES_PER_READ SQL_ID
---------- ----------- ---------- ---------- ---------- -------------- -------------
      1522           0         12       8290          1        8186.62 1z4qd0ftd15rm
      1640           0         13       8290          2        8187.01 3c9xwzkcrc6a8
       929           0         14       8290          2       15318.16 d7ph9byky2ywr
      3207           0         25       8290          3        8189.45 g6fytzmbzvcsy
      3944           0         31       8290          4        8189.92 4qy51h4cvvxy6
      5157           1         50       8290          6       10245.56 1abw3kg18x6vu
       972           0         52       8290          6        55601.2 103gzzaas9pxw
      7668           1         60       8290          7        8250.75 5yrcr6pkusawu
     29551           4        231       8290         29        8191.72 13gaaq10c3w3n
     41113           5        321       8290         40         8191.8 fb27zrmwt9gh1
      1024           0       1005       8290        124     1028371.73 7jzs97npty83d
     40676           5       1190       8290        147       30687.42 d16g5hzuhf6mt
      4736           1       4649       8290        574     1029158.69 8d84d2tt51gmg
      4736           1       4649       8290        574     1029158.69 10p6jz819tj0u
      4736           1       4649       8290        574     1029158.69 4cwrr7ujtctc1
    716665          86       5599       8290        692        8191.99 9wbgyyu4bm0q3
     35386           4      34682       8290       4284     1027676.18 9kqufa3uuhc66
   5630230         679      43986       8290       5433           8192 azknmjq07p6cq
     84508          10      62707       8290       7746      778061.06 3xp6nu8bu91y7
    222957          27     205329       8290      25363      965666.64 4fwft07mc76mr
    429433          52     417547       8290      51576     1019551.51 8hb6wtbhck4yd
   1111073         134    1105646       8290     136572     1043453.76 8j28tsjm5k64t



*/
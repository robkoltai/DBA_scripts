SQL> select user frrom dual;
select user frrom dual
                  *
ERROR at line 1:
ORA-00923: FROM keyword not found where expected
 
SQL> select kglhdpar, kglhdadr, kglobt03, kglnaobj from x$kglob where kglnaobj like '%frrom%' and kglnaobj not like '%kgl%';
 
KGLHDPAR         KGLHDADR         KGLOBT03      KGLNAOBJ
---------------- ---------------- ------------- --------------------------------------------------------------------------------
00000000D1EE3880 00000000AEF43F40 bshhvh0ypcz6x select user frrom du
00000000D1EE3880 00000000D1EE3880 bshhvh0ypcz6x select user frrom du
 
2 rows selected.
 
SQL> 

https://jonathanlewis.wordpress.com/2017/10/03/parsing/
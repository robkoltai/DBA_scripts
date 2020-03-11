conn rat/rat


/* 

We have a table update_t

SQL> desc update_t;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID                                                 NUMBER
 TEXT                                               VARCHAR2(100)					---> Indexed column


SQL> select count(1) from update_t;
  COUNT(1)
----------
     73480
*/

drop table update_t purge;
create table update_t (id number, text varchar2(100));

insert into update_t 
        select rownum, substr(object_type||owner||object_name,1,100) text 
        from dba_objects;
commit;
       
create index update_i_text on update_t(text) ;


exec dbms_stats.gather_table_stats('RAT','UPDATE_T', cascade=>true) ;


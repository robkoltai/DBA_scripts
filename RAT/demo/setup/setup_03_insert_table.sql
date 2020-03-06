conn rat/rat

/*
SQL> desc insert_t
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID                                                 NUMBER
 NAME                                               CHAR(22)


Insert_t has only 1 record.
It has an index on ID column
And we have a nocache SEQUENCE we will use for the inserts

*/

drop table insert_t purge;
drop sequence insert_t_seq;

create table insert_t as select 0 as id, 	'This is an insert test' as name from dual;
create sequence insert_t_seq nocache order;
create index ind_insert_t_id on insert_t (id);

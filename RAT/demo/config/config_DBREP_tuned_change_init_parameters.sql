alter system set cursor_sharing=FORCE;
alter system set optimizer_index_cost_adj=100;
alter system set statistics_level=all;

conn rat/rat
create index ind_mike_fk on mike (lev_fk);


drop sequence insert_t_seq;
create sequence insert_t_seq cache 20 order;

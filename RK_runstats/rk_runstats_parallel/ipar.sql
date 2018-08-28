drop index i;
create index i on t1 (v)
parallel &1;


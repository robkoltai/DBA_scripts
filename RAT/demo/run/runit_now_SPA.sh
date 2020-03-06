#!/bin/bash

sqlplus / as sysdba <<__HERE >/dev/null

--alter system flush shared_pool;
--alter system flush buffer_cache;
exec dbms_workload_repository.create_snapshot;

__HERE





# Ez lesz a WORKLOAD
# 1 perc 20 secs 
. ./the_runner.sh run_01_update.sh 4 20000 # kb 1 perc.
. ./the_runner.sh run_02_delete.sh 12 3000  # kb fel perc. Nagy parhuzamossag nem baj.
. ./the_runner.sh run_03_insert.sh 12 5000 # kb 20 masodperc
. ./the_runner.sh run_04_select.sh 4 1500  # kb 20 masodperc



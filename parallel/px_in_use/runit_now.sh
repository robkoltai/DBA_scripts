#!/bin/bash


# PX TEST

# what; concurrent, num exec, DOP
#. ./the_concurrent_runner.sh run_px_select.sh 100 1000 4 
#sleep 10s

. ./the_concurrent_runner.sh run_new.sh 1 1000
. ./the_concurrent_runner.sh run_old.sh 1 1000




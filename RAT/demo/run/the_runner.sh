#!/bin/bash

. ~/uni.env
export CONN_STRING=rat/rat


export COMMAND=$1
export PARALLEL_COUNT=$2
export RUN_COUNT=$3

# Starting each thread in parallel
#   and in background
for  ((i=1; i<=$PARALLEL_COUNT; i++))
do
  echo "Starting $1. Thread $i out of $3"
    . ./$COMMAND & 
done;


#echo
#echo "Starting last thread if $3"
#date
# . ./$COMMAND 
#date
 

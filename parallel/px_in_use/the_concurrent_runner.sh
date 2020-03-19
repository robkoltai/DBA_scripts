#!/bin/bash

. ~/uni.env
export CONN_STRING=px/px


export COMMAND=$1
export CONCURRENT_COUNT=$2
export RUN_COUNT=$3
export DOP=$4

# Starting each thread in parallel
#   and in background
for  ((i=1; i<=$CONCURRENT_COUNT; i++))
do
  echo "Starting $1. Thread $i out of $3"
    . ./$COMMAND & 
done;



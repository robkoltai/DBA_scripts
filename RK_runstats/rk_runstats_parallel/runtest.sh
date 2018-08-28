#!/bin/bash
# $1 test.sql
# $2 <TEST_TAG>

date

export RELATIVE_TESTDIR=realtable_tests
. ~/env_wfmsmig.profile
export SQLPATH=/export/home/oracle/KR/nvme/sqls:/export/home/oracle/KR/nvme/sqls/$RELATIVE_TESTDIR


USER=nvme
PASS=nvme


# Cleanup and preparation
sqlplus $USER/$PASS @cleanup.sql $2

# Start the measurement
sqlplus $USER/$PASS @measure.sql $2 &

# start iostat
# Havi type collection 
#iostat -IrxnzTd 
iostat -IrxnzTd 1 99999  > ${RELATIVE_TESTDIR}/iostat_${2}.out &
IOSTATPID=$!

# RUN THE TEST
sqlplus $USER/$PASS @$1 $2

# Postprocess data 
sqlplus $USER/$PASS @postprocess.sql

#kill iostat
echo I will kill this process $IOSTATPID

echo iostat processes before kill
ps -eaf |grep 9999

kill -6 $IOSTATPID
echo iostat processes after kill
ps -eaf |grep 9999

# hibak
echo
echo
echo -- ERRORS in SQL script --
grep ORA *${2}.lst

date


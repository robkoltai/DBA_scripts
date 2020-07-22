#!/bin/bash


# This script will generate
# for the past n days
# m records of audit
# if auditing is properly set up in the database for "select on a.a_uni table by b"
# Needs to be run on linux with root privileges. The system date will be changed n times.
# At the end it will be changed back to the value of the hwclock

# Example
# unix_fixed_date.sh 17 10 +
# unix_fixed_date.sh 12 10 -


export number_of_days=$1
export record_count_per_day=$2
export sign=$3

. /home/oracle/envSANDBOX

for (( i=1; i <= $number_of_days; i++ ))
do

sqlplus -s b/b <<EOF
declare
  n number;
  i number;
  x number :=${record_count_per_day};
begin
  for i in 1..x loop
    select count(1)
    into n
    from a.a_uni;
  null;
  end loop;
  commit;
end;
/

EOF


  THE_DAY=`date -d "${sign}1 day" "+%Y%m%d"`
  echo "The day $THE_DAY"
  date +%Y%m%d -s "$THE_DAY"

done;

# Back to hw clock
hwclock --hctosys

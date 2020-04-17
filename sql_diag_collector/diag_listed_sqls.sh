#!/bin/ksh
#sqlplus -s ${V_USR_PSWD} <<EOS

file="/home/oracle/RK/sql_id_list.lst"
# while loop
while IFS= read -r line
do
        # display line or do somthing on $line
	echo "$line"

sqlplus -s / as sysdba <<EOF

@def_multi.sql $line
@ss.sql

exit;
EOF

done <"$file"

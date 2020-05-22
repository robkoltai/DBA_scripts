#!/bin/ksh
file="./sql_id_list.lst"

# while loop
while IFS= read -r line
do
        # display line or do somthing on $line
	echo "$line"

sqlplus -s / as sysdba <<EOF

@define_params $line
@diag_one_sql.sql

exit;
EOF

done <"$file"

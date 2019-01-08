#/bin/ksh

# . /home/oracle/a11106_ee_c_f.env

workdir=$2

sqlplus -s ${RMD_LISTENER_REPOSITORY_USER}/${RMD_LISTENER_REPOSITORY_PWD} <<SQLEND > $workdir/create_partition.out 
set heading off
set feedback off
set pages 0
set trimspool on
set serveroutput on

declare
  nextpartitionname varchar2(1000);
  sqlstmt varchar2(2000);
begin
  select 'p'||ltrim(to_char(to_number(substr(max(partition_name),2,3))+1,'099'))
  into nextpartitionname
  from user_tab_partitions
  where table_name = 'LISTENER_LOGS';
  sqlstmt := 'alter table listener_logs add partition '||nextpartitionname||' values (''$1'') tablespace data';
  execute immediate sqlstmt;

-- success
dbms_output.put_line('0');

exception
  when others then
    dbms_output.put_line(sqlcode);
    if (sqlcode = -14312) then raise; -- later development
    else raise;
    end if;
end;
/
quit
SQLEND

RETVAL=`head -1 $workdir/create_partition.out`
exit $RETVAL


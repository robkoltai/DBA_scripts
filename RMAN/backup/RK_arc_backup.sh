#!/bin/bash

# Csak TAPE-es mentest inditunk
# Archivelog torles ha standby-ra elment es 1x mentve van tape-re
# Tape retention policy 31 days


[ -f /u02/backup/stop ] && exit
exec >/dev/null
export ORAENV_ASK="NO"
export ORACLE_SID=xflower
export DATABASE_DIR=XFLOWER

. oraenv
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"

##########################
## Crosscheck
##########################
echo CROSS START

LOG_FILE="/u02/backup/${DATABASE_DIR}/log/crosscheck.log"

echo `date "+%Y:%m:%d %H:%M"` "################# Starting crosscheck ##############" >> $LOG_FILE

(rman target / log $LOG_FILE append <<EOF
connect catalog rman/ischler@catdb
@/u02/backup/${DATABASE_DIR}/script/RK_crosscheck.rcv
EOF
) || echo "$ORACLE_SID RMAN crosscheck problema (Log file: $LOG_FILE)!" >&2

echo `date "+%Y:%m:%d %H:%M"` "################# Finished crosscheck ##############" >> $LOG_FILE
##########################
## DISK
##########################
#LOG_FILE="/u02/backup/${DATABASE_DIR}/log/backup_to_DISK.log"
#echo `date "+%Y:%m:%d %H:%M"` "################# Starting BACKUP ##############" >> $LOG_FILE

#(rman target / log $LOG_FILE append <<EOF
#connect catalog rman/ischler@catdb 
#@/u02/backup/${DATABASE_DIR}/script/RK_arc_DISK.rcv $DATABASE_DIR
#EOF
#) || echo "$ORACLE_SID RMAN archivelog DISK mentes problema (Log file: $LOG_FILE)!" >&2
#echo `date "+%Y:%m:%d %H:%M"` "################# Finished BACKUP ##############" >> $LOG_FILE

##########################
## TAPE
##########################
LOG_FILE="/u02/backup/${DATABASE_DIR}/log/backup_to_TAPE.log"
echo `date "+%Y:%m:%d %H:%M"` "################# Starting BACKKUP ##############" >> $LOG_FILE

(rman target / log $LOG_FILE append <<EOF
connect catalog rman/ischler@catdb
@/u02/backup/${DATABASE_DIR}/script/RK_arc_TAPE.rcv $DATABASE_DIR
EOF
) || echo "$ORACLE_SID RMAN archivelog TAPE mentes problema (Log file: $LOG_FILE)!" >&2
echo `date "+%Y:%m:%d %H:%M"` "################# Finished BACKUP ##############" >> $LOG_FILE


unset DATABASE_DIR


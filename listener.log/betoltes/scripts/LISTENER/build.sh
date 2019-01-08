#/bin/ksh

# USAGE ./build.sh PF_LIVE__livehost__1999__listener.log

apos="'"
quot='"'

errors=0
method=LISTENER

filestring=$(echo $1 | cut -d"." -f1)
partition=$(echo $filestring | perl -pe 's/(.*?)__.*/$1/')
instance=$(echo $filestring | perl -pe 's/.*?__(.*?)__.*/$1/')
port=$(echo $filestring | perl -pe 's/.*?__.*?__(.*)__.*/$1/')
datestring=$(date "+%Y%m%d_%H%M")

basedir=/teszt/groupama/betoltes
sourcedir=$basedir/data/$method/to_load
workdir=$basedir/data/$method/loaded/${partition}_${datestring}
faildir=$basedir/data/$method/failed/${partition}_${datestring}
scriptdir=$basedir/scripts/$method
envfile=/home/oracle/a11106_ee_c_f.env
export RMD_LISTENER_REPOSITORY_USER=listener_gr
export RMD_LISTENER_REPOSITORY_PWD=$(cat $basedir/pwd/LISTENER_REPOSITORY.pwd)


# sourcing logger
. $basedir/scripts/LOG/logger $basedir/log/LISTENER_${partition}_build.log 15 v

# logger variables
senderfile=build.sh
sendermodul=MAIN
senderline=state00

putlog "Listener Loader started at $(date)" i 0
putlog "Found and setted parameters:" i 5
putlog "basedir: $basedir" i 10
putlog "sourcedir: $sourcedir" i 10
putlog "workdir: $workdir" i 10
putlog "partition: $partition" i 10
putlog "envfile: $envfile" i 10

if [ ! -f $sourcedir/$1 ]
then putlog "File $sourcedir/$1 does not exists." e 15
     putlog "Can not continue, exiting..." i 0
     putlog "================================================================================" i 0
     exit 1
fi

if [ -d $workdir ]
then putlog "Work Directory $workdir Exists" i 15
else mkdir -p $workdir
     if [ $? -ne 0 ]
     then errors=$(($errors+1))
     else putlog "Created Work Directory $workdir" i 15
     fi
fi

# invoke parse.pl script to get and prepare relevant listener log lines
senderline=state10
putlog "Parsing Listener Log file, please wait..." i 10

cd $sourcedir
$scriptdir/parse.pl $1
mv $sourcedir/$1.dat $workdir/loader_$filestring.dat
mv $sourcedir/$1.not $workdir/loader_$filestring.not
mv $sourcedir/$1 $workdir/LOADED__$1

putlog "Parse finished." i 15

# set up ora env and build sqlldr control file:
putlog "Set up ORA env and build sqlldr control file" i 10
. ${envfile}
if [ "$2" != "" ]
then dateformat="$2"
     export NLS_LANG=Hungarian_Hungary.ee8iso8859p2
     putlog "FORCED DATEFORMAT: $2" i 15
     putlog "SET HUNGARIAN NLS_LANG" i 15
elif [ "x$(tail -1 $workdir/loader_$filestring.dat | perl -pe 's/(.*?\|){3}[^\|]*(\.\s*-)(.*)/$2/')" = "x.-" ]
then dateformat='DD-MON.-YYYY HH24:MI:SS'
     export NLS_LANG=Hungarian_Hungary.ee8iso8859p2
     putlog "HUNGARIAN DATE FORMAT FOUND" i 15
elif [ "x$(tail -1 $workdir/loader_$filestring.dat | perl -pe 's/(.*?\|){3}[^\|]*(\.\s*-)(.*)/$2/')" = "x. -" -o "x$(tail -1 $workdir/loader_$filestring.dat | perl -pe 's/(.*?\|){3}[^\|]*(\.\s*-)(.*)/$2/')" = "x.  -" ]
then dateformat='DD-MON.  -YYYY HH24:MI:SS'
     export NLS_LANG=Hungarian_Hungary.ee8iso8859p2
     putlog "HUNGARIAN DATE FORMAT FOUND WITH EXTRA WHITE SPACES" i 15
else dateformat='DD-MON-YYYY HH24:MI:SS'
     export NLS_LANG=AMERICAN_AMERICA.UTF8
     putlog "AMERICAN DATE FORMAT FOUND" i 15
fi

# create new partition
senderline=state20
putlog "Creating new partition in LISTENER_LOGS table..." i 10

$scriptdir/create_listener_logs_new_partition.sh $partition $workdir
     if [ $? -ne 0 ]
        then errors=$(($errors+1))
             putlog "Failed creating the required partition: $partition. Exiting" e 15
             exit
        else putlog "Succeeded." i 15
     fi

senderline=state30
putlog "Creating loader control file." i 10

echo "options (direct=true)
unrecoverable
load data
infile ${apos}${workdir}/loader_${filestring}.dat${apos}
badfile ${apos}${workdir}/loader_${filestring}.err${apos}
append
into table listener_logs
fields terminated by ${quot}|${quot}
(
  instancename,
  hostname,
  port,
  autonum,
  logdate date ${quot}${dateformat}${quot},
  cd_sid,
  cd_cid_program, 
  cd_cid_host,
  client_host_short,
  cd_cid_user,
  cd_server,
  cd_service_name,
  cd_command,
  cd_srv_protocol,
  cd_srv_host,
  cd_srv_port,
  cd_fm_type,
  cd_fm_method,
  cd_fm_retries,
  cd_fm_delay,
  pi_protocol,
  pi_host,
  pi_port,
  action,
  service_name,
  return_code
)" > ${workdir}/loader_${filestring}.ctl

# load into database:
senderline=state40
putlog "Starting SQL*Loader session" i 10
sqlldr ${RMD_LISTENER_REPOSITORY_USER}/${RMD_LISTENER_REPOSITORY_PWD} control=${workdir}/loader_${filestring}.ctl log=${workdir}/loader_${filestring}.log silent=all
     if [ $? -ne 0 ]
        then errors=$(($errors+1))
             putlog "Failed." e 15
        else putlog "Succeeded." i 15
     fi
putlog "SQL*Loader session finished" i 10

if [ $errors -gt 0 ]
then mkdir -p $faildir
     mv $workdir/* $faildir/
     putlog "Error occured, files moved to $faildir." e 5
     putlog "Logfile can be found in $basedir/log directory." i 10
else putlog "Success, output files are in $workdir." i 5     
fi
putlog "Script finishded at $(date)" i 0
putlog "================================================================================" i 0


#!/usr/bin/bash

#2016.09.29 Processzor lekerdezes javitasa x86-ra
#2016.10.05 belekerult a script verzioja
SCRIPTVERSION=10

SEPARATOR=";"
SEPARATOR2=","
TMPDIR='/tmp/datacollect'
DEBUG=true
NONESTRING=NONE

LDOM=false
PRIMARY=false
GLOBALZONE=false
POOL=false
LDM=false
SOLARIS_VERSION=`uname -a|cut -d " " -f3`
CONTROL=false


	if [ -e "/usr/sbin/virtinfo" ];then
		LDOM=true
		
fi 


if [ `zonename` = "global" ]; then
	GLOBALZONE=true
fi
/usr/sbin/virtinfo -a 2>/dev/null| grep "Domain name: primary" 2>/dev/null 1>&2

if [ $? -eq 0 ];then
	PRIMARY=true
fi

poolstat 2>/dev/null 1>&2
if [ $? -ne '0' ]; then
	ENABLEPOOL=0
	POOL=false
else
	ENABLEPOOL=1
	POOL=true
fi

if [ -e "$1" ];then
	TARGETDIR="$1"
else	
	TARGETDIR="."
fi
HOSTID=`hostid`
HOSTNAME=`hostname`

/usr/sbin/virtinfo -a 2>/dev/null| grep "Domain role:"|grep "control" 2>/dev/null 1>&2
if [ $? -eq 0 ];then
	if [ -e "/usr/sbin/ldm" ] && $PRIMARY ;then
		CONTROL=true
	fi
fi



pkginfo |grep SUNWsneep 2>/dev/null 1>&2
RET=$?
if [ $RET -eq "0" ]; then
	SERIAL=`sneep`
	if [ "${SERIAL}" = "" ];then
		if [ $LDOM ];then
			SERIAL=`/usr/sbin/virtinfo -a 2>/dev/null|grep "Chassis serial"|cut -d " " -f 3`
		else
			SERIAL="$NONESTRING"
		fi
	fi
else
	if [ $LDOM ];then
		SERIAL=`/usr/sbin/virtinfo -a 2>/dev/null|grep "Chassis serial"|cut -d " " -f 3`
	else
		SERIAL="$NONESTRING"
	fi
fi

CPUSPEED=`(/usr/bin/kstat -m cpu_info | grep clock_MHz | awk '{ print $2 }' | sort -u)`
#CPU=`/usr/bin/kstat -m cpu_info|grep implementation|head -n 1|tr "\t" " "|sed 's/  */ /g'|sed 's/^ //g'|cut -d ' ' -f 2`
CPU=`/usr/bin/kstat cpu_info  |grep brand | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' | sort | uniq`
DATE=`date +%Y%m%d_%H%M`
DATE2=`date +%Y%m%d\ %H:%M:%S`
FILENAME="${HOSTNAME}_${HOSTID}__${DATE}__SOLARIS_data.out"

rm -f ${TARGETDIR}/${HOSTNAME}_${HOSTID}__*__SOLARIS_data.out



if [ -e $TMPDIR ]; then 
	rm -rf $TMPDIR
fi
mkdir ${TMPDIR}



/usr/bin/kstat -m cpu_info | egrep "chip_id|core_id|module: cpu_info" > ${TMPDIR}/cpu_info.log

nproc=`(grep chip_id ${TMPDIR}/cpu_info.log | awk '{ print $2 }' | sort -u | wc -l | tr -d ' ')`
ncore=`(grep core_id ${TMPDIR}/cpu_info.log | awk '{ print $2 }' | sort -u | wc -l | tr -d ' ')`
vproc=`(grep 'module: cpu_info' ${TMPDIR}/cpu_info.log | awk '{ print $4 }' | sort -u | wc -l | tr -d ' ')`

threadpercore=$(($vproc/$ncore))
coresperproc=$(($ncore/$nproc))

ZONENUM=`zoneadm list|wc -l`


HEADER="HOSTNAME${SEPARATOR}HOSTID${SEPARATOR}SERIAL${SEPARATOR}CPU${SEPARATOR}CPUSPEED${SEPARATOR}THREADPERCORE${SEPARATOR}ZONENAME${SEPARATOR}ZONEHOSTNAME${SEPARATOR}PSETNAME${SEPARATOR}VCPU${SEPARATOR}CORENUMS${SEPARATOR}CORES${SEPARATOR}DATETIME${SEPARATOR}VERSION${SEPARATOR}"
if  $DEBUG ;then 
	echo "SOLARIS VERSION =${SOLARIS_VERSION}"
	echo "LDOM            =${LDOM}"
	echo "GLOBAL ZONE     =${GLOBALZONE}"
	echo "PRIMARY         =${PRIMARY}"
	echo "CONTROL DOMAIN  =${CONTROL}"
	echo "ENABLED POOL    =${POOL}"
	echo "TARGET DIR      =${TARGETDIR}"
	echo "DATE            =${DATE}"
	echo "FILENAME        =${FILENAME}"
	echo "HOSTNAME        =${HOSTNAME}"
	echo "HOSTID          =${HOSTID}"
	echo "SERIAL          =${SERIAL}"
	echo "CPU             =${CPU}"
	echo "CPU SPEED       =${CPUSPEED}"
	echo "CORE/PROC       =${coresperproc}"
	echo "THREAD/CORE     =${threadpercore}"
	echo "NUM OF VCPUS    =${vproc}"
	echo "NUM OF CPUS     =${nproc}"
	echo "HEADER          =$HEADER"
	
fi




	if [ $ENABLEPOOL -eq 1 ]; then
		poolstat -r pset -o rid,rset,size|sed "1 d"|sed -e 's/^[\ ]*//'|sed -e 's/  */ /g'>${TMPDIR}/res_info.log
	else
		globalvcpu=`psrinfo |wc -l|tr "\t" " "|sed -e 's/  *//g'`
		echo "-1 pset_default ${globalvcpu}">${TMPDIR}/res_info.log
	fi

	kstat cpu_info | egrep "cpu_info |core_id" | awk 'BEGIN { printf "%4s %4s", "VCPU", "core" } /module/ { printf "\n%s ", $4 }  /core_id/ { printf "%s", $2} END { printf "\n" }'>${TMPDIR}/vcpu-core.txt
	#kstat cpu_info | egrep "cpu_info |core_id" | awk 'BEGIN { printf "%4s %4s", "VCPU", "core" } /module/ { printf "\n%4s", $4 }  /core_id/ { printf "%4s", $2} END { printf "\n" }'>${TMPDIR}/vcpu-core.txt





	#echo "HOSTNAME${SEPARATOR}HOSTID${SEPARATOR}SERIAL${SEPARATOR}CPU${SEPARATOR}CPU SPEED${SEPARATOR}thread/CORE${SEPARATOR}ZONE name${SEPARATOR}PSET${SEPARATOR}VCPU${SEPARATOR}CORENUM${SEPARATOR}CORES${SEPARATOR}" >${TARGETDIR}/${FILENAME}
	IFSO=$IFS
	IFS=$'\n'
	for i in `/bin/ps -eo zone,pset,comm | grep ' [z]*sched'|sed -e 's/^[\ ]*//'|sed -e 's/  */ /g'|cut  -d' ' -f 1-2`
	do 
		echo -n "${HOSTNAME}${SEPARATOR}${HOSTID}${SEPARATOR}${SERIAL}${SEPARATOR}${CPU}${SEPARATOR}${CPUSPEED}${SEPARATOR}${threadpercore}${SEPARATOR}">>${TARGETDIR}/${FILENAME}
		ZONENAME=`echo $i|cut -d' ' -f1`
		PSET=`echo $i|cut -d' ' -f2`
		PSETNAME=`grep "^$PSET" ${TMPDIR}/res_info.log|cut -d' ' -f2|head -1`	
		if [ $ZONENAME != 'global' ]; then	
			VCPU=`zlogin $ZONENAME psrinfo |wc -l`
			ZONEHOSTNAME=`zlogin $ZONENAME hostname`
			zlogin $ZONENAME psrinfo>/${TMPDIR}/psrinfo.txt
		else
			VCPU=`psrinfo|wc -l`
			ZONEHOSTNAME=`hostname`
			psrinfo >${TMPDIR}/psrinfo.txt
		fi
		VCPU=`grep "^$PSET" ${TMPDIR}/res_info.log|cut -d' ' -f3|head -1`
		
		echo -n "${ZONENAME}${SEPARATOR}${ZONEHOSTNAME}${SEPARATOR}${PSETNAME}${SEPARATOR}${VCPU}${SEPARATOR}"	>>${TARGETDIR}/${FILENAME}

		if [ $ENABLEPOOL -eq 1 ]; then
		#vcpu id-k soronként 1
		VCPUS=`pooladm |grep -v "pset\."|grep -v "pool\."|grep -v "system\."|egrep "pset|int"|awk 'BEGIN{ found=0} /pset / {found=0} /pset '${PSETNAME}'/{found=1}  {if (found) print }'|grep -v "pset "|tr '\t' ' '|sed 's/^ *//g'|cut -d ' ' -f3`
		else
		#az osszes vcpu, mert nincsnek poolok
		VCPUS=`psrinfo|tr "\t" " "|cut -d " " -f 1`
		fi
	#echo "---- $VCPUS ----"
	#for i in `cat ${TMPDIR}/psrinfo.txt |cut -d$'\t' -f1`;do 
	for i in $VCPUS ;do 
		grep "^$i " ${TMPDIR}/vcpu-core.txt|cut -d' ' -f2 >>${TMPDIR}/core_res.txt;
	done;

	CORENUMS=`cat ${TMPDIR}/core_res.txt|sort|uniq|wc -l| sed -e 's/^ *//'`
	CORES=`cat ${TMPDIR}/core_res.txt|sort|uniq|tr '\n' "${SEPARATOR2}"`
	#echo "cat ${TMPDIR}/core_res.txt|sort|uniq|tr '\n' '${SEPARATOR2}'|sed 's/.$//g'"
	rm ${TMPDIR}/core_res.txt
	#${x%?}
		echo -n "${CORENUMS}${SEPARATOR}${CORES:0:${#CORES}-1}${SEPARATOR}${DATE2}${SEPARATOR}${SCRIPTVERSION}${SEPARATOR}">>${TARGETDIR}/${FILENAME}
		echo>>${TARGETDIR}/${FILENAME}
		
	done 
	IFS=$IFSO

if  $CONTROL ; then 
#LDOM controll domain
	LDOMS=`ldm ls|sed  "1 d"|grep "active"|sed "s/  */ /g"|cut -d " " -f1`
	for i in $LDOMS ;do
		echo -n "${HOSTNAME}${SEPARATOR}${HOSTID}${SEPARATOR}${SERIAL}${SEPARATOR}${CPU}${SEPARATOR}${CPUSPEED}${SEPARATOR}${threadpercore}${SEPARATOR}">>${TARGETDIR}/${FILENAME}
		LDOMNAME=$i
		LDOMVCPU=`ldm ls|sed  "1 d"|grep "$i"|sed "s/  */ /g"|cut -d " " -f5`
		echo -n "LDOM:${LDOMNAME}${SEPARATOR}${NONESTRING}${SEPARATOR}${NONESTRING}${SEPARATOR}${LDOMVCPU}${SEPARATOR}"	>>${TARGETDIR}/${FILENAME}
		CORENUM=`ldm list -l -p -o core $i|grep "cid"|wc -l|sed -e 's/^ *//'`
		CORES=`ldm list -l -p -o core $i|grep "cid"|cut -d "|" -f2|cut -d "=" -f2|tr "\n" "${SEPARATOR2}"`
		echo -n "${CORENUM}${SEPARATOR}">>${TARGETDIR}/${FILENAME}
		if [ ${CORES} != 0 ];then
			echo -n "${CORES:0:${#CORES}-1}">>${TARGETDIR}/${FILENAME}
		else 
			echo -n "">>${TARGETDIR}/${FILENAME}
		fi
		echo -n "${SEPARATOR}${DATE2}${SEPARATOR}${SCRIPTVERSION}${SEPARATOR}">>${TARGETDIR}/${FILENAME}
		
		echo >>${TARGETDIR}/${FILENAME}
	done
	
	
fi

#rm -rf ${TMPDIR}


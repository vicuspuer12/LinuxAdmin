#!/bin/bash

# this script will make a:
# - 0 = weekly    - Sunday: full backup
# - 1 = daily     - changes since last weekly backup
# - 2 = interday  - changes since the last daily backup 

# to be called from the cron:
# -- the big backups are taken overnight -- each hour will backup an 8th of the databases
# -- the interdays will backup a 4th of the databases each hour, giving us 6 extra copies to work with


LEVEL=$1
if [ "${LEVEL}" == "" ]; then
 echo "missing level - check usage"
 exit
fi

BASE="/mnt/data/shared" # -- The base directory for the Backup
source ${BASE}/hosts.config

SRC="/src/data" # -- The source directory to be backedup
DST="/mnt/data/backup" # -- The Destination Directory to backup
LOG="/var/log/backup.log-${LEVEL}.$(date +%a)" # -- Create logs for each backup
slaves=(${SLAVES//:/ })
SUFFIX="${LEVEL}-$(date +'%a.%H')"
data=()

##-- ENABLED DEBUGGING
#echo "++ DEBUG MODE"
#LOG="/dev/stdout"

# check that we are running on the master
hostname=$(uname -n)
if [ "$hostname" != "$MASTER" ]; then
   echo "$(date) ++ I am NOT the master: me=$hostname, master=$MASTER" > ${LOG}
   exit
fi

# check that we have a destination directory
if [ ! -d "${DST}" ]; then
 mkdir -p ${DST}
fi

# check if we were supplied a data to copy, or all of them
if [ "$2" != "" ]; then
   data+=($2)
   echo "$(date): including just $data - level = ${LEVEL}" >> ${LOG}
else
   # we will be called from the CRON
   # - based on our level, determine the MOD divisor and target to backup this databases
   case ${LEVEL} in
      0) # weekly
         echo "$(date) ++ FULL backup" > ${LOG}
         period=9       # will take the full backup over 9 hour period
      ;;

      1) # daily
         echo "$(date) ++ daily incremental" > ${LOG}
         period=4       # will take daily backups over 4 hour period
      ;;

      *) # hourly
         echo "$(date) ++ hourly incremental" > ${LOG}
         period=2       # will take hourly backups every 2 hrs   
      ;;
   esac

   target=$(($(date +'%_H') % ${period}))
   cd ${SRC} && for i in `find ./ -name '*.gdb' -ctime -1 2> /dev/null`; do

      # check if this database numerically matches our target
      # if it is blank, make it 1 -- this will be the controller database etc..
      dt_number=${i//[^0-9]/} 
      if [ "${dt_number}" == "" ]; then dt_number=1; fi;

      if [ $(( ${dt_number} % ${period} )) == ${target} ]; then
         data+=(${i:2})        # skip the leading ./
         echo "$(date): including data $i -- (data_num=${dt_number}, target=${target}, period=${period}), # entries: ${#data[@]}" >> ${LOG}
      fi
   done
fi


# cycle through all the datasbases that we are going to copy over
for d in "${data[@]}"; do

   # extract the name of the file -- excluding the .gdb suffix
   name=(${d//./ })
   dt="${name[0]}.gdb"
        backup="${name[0]}_${SUFFIX}.xz"

   echo -e " -- processing data $dt - $(date)" >> ${LOG}

   # take the backup
   ionice nbackup -BACKUP $LEVEL ${SRC}/$dt stdout | xz --compress --stdout > ${DST}/${backup} 

done
echo "$(date): done" >> ${LOG}

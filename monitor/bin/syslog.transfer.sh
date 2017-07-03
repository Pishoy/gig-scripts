#!/bin/bash

# this script is created to transfer the syslog to a remote machine
# should put your public key on the remote machine 
# created by Bishoy @July 2017

script_usage () {
echo "Usage: $0 "
echo " This Script for transfer the syslog to a remote machine, PLease give the script the two input varaibles of remote SSH machine IP and port"
echo " For example:"
echo " $0 IP_OF_REMOTE_MACHINE PORT"
}
if [ $# -eq 0 ]
then
        echo "No Input arguments supplied"
        script_usage
        exit
fi

# Delcaring variables
YEST=$( date --date="yesterday" +"%Y-%m-%d" )
BASEDIR="/opt/monitor/log";
OUTPUT="`hostname`";
OUTFILENAME="syslog_${YEST}.log"
OUTFILE="${BASEDIR}/${OUTPUT}/${OUTFILENAME}"

HOST="$1"
PORT=$2
#### check the remote directory existing 

if ( ssh root@$HOST -p $PORT "[ -d "${BASEDIR}/${OUTPUT}" ] " ); then

         echo " remote directory is already exist" > /dev/null
else

         # remote directoy does not exists, create a new one
         ssh root@$HOST -p $PORT " mkdir -p "${BASEDIR}/${OUTPUT}" "

fi

# find the yesterday file then transfer it to remote machine then remove it
find /var/log/ -type f -mtime 1 -name "syslog*" -exec rsync -azv -e "ssh -p $PORT" {} root@$HOST:"$OUTFILE" \; -exec rm {} \;

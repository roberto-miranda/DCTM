#!/bin/bash

while getopts s:d:e: ARG; do
  case "$ARG" in
    s) SOURCE=$OPTARG;;
    e) EXECUTE=$OPTARG;;
  esac
done

echo "Monitoring $SOURCE for changes ....................."

### Set initial time of file
LTIME=`stat -c %Z $SOURCE`

while true
do
   ATIME=`stat -c %Z $SOURCE`

   if [[ "$ATIME" != "$LTIME" ]]
   then
       if [ ! $EXECUTE = "" ]; then
           LTIME=$ATIME
           echo "$(date +"%m-%d-%Y %r") Done updating $SOURCE ................"
           eval $EXECUTE 
           LTIME=$ATIME
 
       fi;
   fi
   sleep 5
done

#!/bin/bash

#configuration
GPUMINERPROCNAME="wildrig-multi"
TEMPCRIT=60
printf "Critical GPU temperature was set to <$TEMPCRIT> Celsius\n"
TEMPCRITMAXTIME=4
printf "Critical GPU temperature maximum time was set to <$TEMPCRITMAXTIME> seconds\n"
MEASUREINTERVAL=3
printf "Critical GPU temperature measurement interval was set to <$MEASUREINTERVAL> seconds\n"
TEMPCRITCOOLDOWNTIME=10
printf "Critical GPU temperature cooldown time was set to <$TEMPCRITCOOLDOWNTIME> seconds\n"

#variables
TEMPPREV=0

#main process
printf "Actual temperature measurement: "

while true
do

TEMPNOW=`sensors | grep hyst | tr --delete \ +° | cut -d ":" -f2 | cut -d "C" -f1 | cut -d "." -f1`

if [ "$TEMPNOW" -ge "$TEMPCRIT" ];then

  printf "\nCritical temp $TEMPNOW timer waiting $TEMPCRITMAXTIME\n"
  sleep $TEMPCRITMAXTIME
  
  TEMPNOW=`sensors | grep hyst | tr --delete \ +° | cut -d ":" -f2 | cut -d "C" -f1 | cut -d "." -f1`
  printf "GPU temp now is $TEMPNOW vs critical $TEMPCRIT\n"
  
  if [ "$TEMPNOW" -ge "$TEMPCRIT" ];then
     printf "process stop\n"
     pkill -19 $GPUMINERPROCNAME

     printf "waiting $TEMPCRITCOOLDOWNTIME to GPU cooldown\n"
     sleep $TEMPCRITCOOLDOWNTIME
     
     printf "process continue\n"
     pkill -18 $GPUMINERPROCNAME
  fi
fi

if [ "$TEMPNOW" -ne "$TEMPPREV" ];then
   printf ".$TEMPNOW"
else
   printf "."
fi
TEMPPREV=$TEMPNOW

sleep $MEASUREINTERVAL
done


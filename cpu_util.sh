#!/bin/bash

#USED=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
NUMCPUS=`grep ^proc /proc/cpuinfo | wc -l`;
FIRST=`cat /proc/stat | awk '/^cpu /{print $5}'`;
sleep 1;
SECOND=`cat /proc/stat | awk '/^cpu / {print $5}'`;
USED=`echo 2 k 100 $SECOND $FIRST - $NUMCPUS / - p | dc`;
#USED=100 
for ((i=0; i<${USED%.*}/10; i++)); do
	echo -n ""
done
echo " ${USED}%"


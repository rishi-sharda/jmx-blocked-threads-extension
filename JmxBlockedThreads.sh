#!/bin/bash
# $1 - Path of directory where jmxterm jar file & AllThreadIds.txt is kept
# $2 - PID of JVM
# $3 - Hostname of the server
#
PID=$1
PWD=`pwd`
HOSTNAME=`hostname`
CMD=$(java -jar $PWD/jmxterm-1.0.0-uber.jar -l $PID -v silent -n -i $PWD/AllThreadIds.txt | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /:/g')
#echo $CMD
IFS=':' read -r -a array <<< "$CMD"
CONCATED=""
#echo "${array[0]}"
for key in "${!array[@]}";
	do 
		EXE="echo run -b java.lang:type=Threading getThreadInfo ${array[$key]}"
		#echo $EXE
		CMD2=`$EXE | java -jar $PWD/jmxterm-1.0.0-uber.jar -l $PID -v silent -n | grep threadState`
		CONCATED+="$CMD2"
		#echo $CONCATED
		CMD2=""
	done
RUNNABLE=`echo $CONCATED | tr ';' '\n' | grep -c '\<RUNNABLE\>'`
WAITING=`echo $CONCATED | tr ';' '\n' | grep -c '\<WAITING\>'`
BLOCKED=`echo $CONCATED | tr ';' '\n' | grep -c '\<BLOCKED\>'`

echo "name=Custom Metrics|$HOSTNAME|JVM|$PID|Threads|Blocked,value=$BLOCKED"
echo "name=Custom Metrics|$HOSTNAME|JVM|$PID|Threads|Waiting,value=$WAITING"
echo "name=Custom Metrics|$HOSTNAME|JVM|$PID|Threads|Runnable,value=$RUNNABLE"

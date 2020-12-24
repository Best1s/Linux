#!/bin/bash
ps -aux | grep $1 |grep -v "grep"|grep -v "defunct"| grep -v "listenProcess"
if [ "$?" == 0 ];then
    echo 0
else
	echo 1
	exit 1
fi

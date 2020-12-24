#!/bin/bash
while true
do
	ps -aux |grep "filebeat" |grep -v "grep"|grep -v "defunct"|grep -v "start.sh"
	if [ "$?" == 1 ];then
    echo "filebeat start time is: $(date)" >> /tmp/sensorfilebeat.log
	/usr/local/filebeat-7.9.2-linux-x86_64/filebeat -e -c /usr/local/filebeat-7.9.2-linux-x86_64/filebeat.yml >> /tmp/sensorfilebeat.log 2>&1 &
	fi
        sleep 30
done

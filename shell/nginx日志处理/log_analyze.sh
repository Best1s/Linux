#/usr/bin/sh
date=$(date -d yesterday +"%Y%m%d")
log_path=/logs/xxxx.com.log
day_pv=`wc -l $log_path`
day_pv=$(echo $day_pv |awk '{print $1}')
day_ip=`awk '{print $1}' $log_path|sort | uniq -c |wc -l`
avg_ip=`expr $day_pv / $day_ip`
echo "$date $day_pv $day_ip $avg_ip" >> xxxx_count.log
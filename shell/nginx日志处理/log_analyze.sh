#/usr/bin/sh
date=$(date -d yesterday +"%Y%m%d")
log_path=/logs/xxxx.com.log
day_pv=`wc -l $log_path`
day_pv=$(echo $day_pv |awk '{print $1}')
day_ip=`awk '{print $1}' $log_path|sort | uniq -c |wc -l`
avg_ip=`expr $day_pv / $day_ip`
echo "$date $day_pv $day_ip $avg_ip" >> xxxx_count.log

yesterday=$(date -d yesterday +"%Y%m%d")
date=$(date -d yesterday +"%d/%b/%Y")
#date=18/Sep/2019
echo "--------------------------$date------------------------" >> ./every_hour_pv.log
echo "--------------------------$date------------------------" >> ./$yesterday-max_everysec_pv.log
for i in $(seq 0 23)
do

        if [ $i -lt 10 ];then
                everyhour_pv=`cat $logpath | grep "$date:0$i" |wc -l`
                echo "Count PV on 0$i-hour is  $everyhour_pv" >> ./every_hour_pv.log
        else
                everyhour_pv=`cat $logpath |grep "$date:$i" |wc -l`
                echo "Count PV on $i-hour is  $everyhour_pv" >> ./every_hour_pv.log
        fi

done
awk -F '[' '{print $2}' $logpath | awk '{print $1}' | sort | uniq -c |sort -k1,1nr |head -n 300 >> ./$yesterday-max_
everysec_pv.log
#!/bin/bash
echo "根据访问IP统计UV"

echo `awk '{print $1}'  access.log|sort | uniq -c |wc -l`

echo `统计访问URL统计PV`

echo `awk '{print $7}' access.log|wc -l`

echo "查询访问最频繁的URL"

echo `awk '{print $7}' access.log|sort | uniq -c |sort -n -k 1 -r|more`

echo "查询访问最频繁的IP"

echo `awk '{print $1}' access.log|sort | uniq -c |sort -n -k 1 -r|more`

echo "根据时间段统计查看日志"

echo `cat  access_log| sed -n '/8\/Mar\/2017:21/,/10\/Mar\/2017:22/p'|more|wc -l`

echo "统计访问量前10的ip"

echo `awk '{a[$1]++}END{for (j in a) print a[j],j}' /var/log/nginx/access.log|sort -nr|head -10`
sed -n '/12\/Jul\/2019:08/,/12\/Jul\/2019:08:43/p' test.log |wc
1.根据访问IP统计UV
awk '{print $1}' access_iqueendress.com.log|sort | uniq -c |wc -l
awk '{print $1}' access_m.iqueendress.com.log|sort | uniq -c |wc -l
awk '{print $1}' access*.log|sort | uniq -c |wc -l

1.根据访问IP统计UV
awk '{print $1}' access.log|sort | uniq -c |wc -l

2.统计访问URL统计PV
awk '{print $7}' access.log|wc -l

3.查询访问最频繁的URL
awk '{print $7}' access.log|sort | uniq -c |sort -n -k 1 -r|more

4.查询访问最频繁的IP
awk '{print $1}' access.log|sort | uniq -c |sort -n -k 1 -r|more

5.根据时间段统计查看日志
cat access.log| sed -n '/14\/Mar\/2015:21/,/14\/Mar\/2015:22/p'|more

查看并发数
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
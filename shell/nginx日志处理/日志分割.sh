#/usr/bin/sh
date=$(date -d yesterday +"%Y%m%d")
logpath=/www/wwwlogs
nginx_pid=/run/nginx.pid
nginx=/usr/local/nginx/sbin/nginx
if [ -f $nginx_pid ];then
	$nginx -t > /dev/null 2>&1 
	if [ $? == 0 ]; then
		mv $logpath/xxx.com.log  $logpath/$date-xxx.com.log
		kill -USR1 `cat $nginx_pid`
	fi
fi
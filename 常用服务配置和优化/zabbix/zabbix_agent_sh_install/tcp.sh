#!/bin/bash
tcp_conn_status(){
   TCP_STAT=$1
   ss -ant |awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}' > /tmp/tcp_conns.txt
   TCP_NUM=$(grep "$TCP_STAT" /tmp/tcp_conns.txt | cut -d ' ' -f2)
   if [ -z $TCP_NUM ];then
      TCP_NUM=0
   fi
   echo $TCP_NUM
}

main(){
    case $1 in
    tcp_status)
    tcp_conn_status $2;
    ;;
esac
}

main $1 $2

**单机版redis清理方法** 

```bash
#使用scan方法清理redis的key
#注意：redis的key一般都是模糊的，需要在最后面加上'*'
 
#!/bin/bash 
host='xxx' 
pw='xxx'   
redis_key='xxx'  #需要删除的redis key，需要在key后面加个*
 
#--------------------------------start----------------------------------------
count=`redis-cli -h $host -a $pw scan 0  match $redis_key count 10000|head -n 1`
num=`redis-cli -h $host -a $pw scan 0 match $redis_key count 10000|wc -l`
a=1
key_count=$((num -a))
redis-cli -h  $host -a $pw scan 0 match $redis_key count 10000|tail -n $key_count|xargs redis-cli -h  $host -a $pw del
 
b=0
while i<1000
do
    b=b+1
    count=`redis-cli -h $host -a $pw scan $count match $redis_key count 10000|head -n1`
    echo $count
    num=`redis-cli -h $host -a $pw scan $count match $redis_key count 10000|wc -l`
    a=1
    key_count=$((num -a))
    #redis-cli -h  $host -a $pw scan $count match $redis_key count 10000
    redis-cli -h  $host -a $pw scan $count match $redis_key count 10000|tail -n $key_count|xargs redis-cli -h  $host -a $pw del
    if [ $count == 0 ];then
        echo "$count  退出脚本"
        break
    fi
done
 
#-----------------------end----------------------------------------------
```

**集群版redis清理方法** 

```bash

#使用scan方法清理redis的key
#注意：redis的key一般都是模糊的，需要在最后面加上'*',集群版redis需要加上node节点参数
 
#!/bin/bash
 
host='xxx' 
pw='xxx'  
redis_key='xxx'  #需要删除的redis key，需要在key后面加个*
node="node1 node2 node3"
count='10'  #每次scan的数量
echo $pw
#--------------------------------start----------------------------------------
for i in $node
do
    count=`redis-cli -h $host -a $pw scan 0  match $redis_key count $count $i|head -n 1`
    num=`redis-cli -h $host -a $pw scan 0 match $redis_key count $count $i|wc -l`
    a=1
    key_count=$((num -a))
    redis-cli -h  $host -a $pw scan 0 match $redis_key count $count $i|tail -n $key_count|xargs redis-cli -h  $host -a $pw del
     
    for ((b=1; b<=1000; b++))
    do
        count=`redis-cli -h $host -a $pw scan $count match $redis_key count $count $i|head -n1`
        echo $count
        num=`redis-cli -h $host -a $pw scan $count match $redis_key count $count $i|wc -l`
        a=1
        key_count=$((num -a))
        #redis-cli -h  $host -a $pw scan $count match $redis_key count $count
        redis-cli -h  $host -a $pw scan $count match $redis_key count $count $i|tail -n $key_count|xargs redis-cli -h  $host -a $pw del
        if [  $count == 0  ];
            then
            echo "$count  退出脚本"
            break
        fi
    done
done

```
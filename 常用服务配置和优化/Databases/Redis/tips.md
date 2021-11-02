redis

```shell
#1、导出 key 到另一台 redis

redis-cli -h x.x.x.x -p 6379 -a "password" -n 0 --raw dump $key | head -c-1 | redis-cli -h x.x.x.x -p 6379 -a password -n 1 -x restore $key 0

#2、将 key dump 下来
dump:
redis-cli -h x.x.x.x -p 6379 -a "password" -n 0 --raw dump $key > key

#restore key:
perl -pe 'chomp if eof' key |redis-cli -h x.x.x.x -n 10   -x restore key 0
#or:
head -c-1 key | redis-cli -h x.x.x.x -n 10   -x restore key 0
```


Document： https://github.com/apache/rocketmq

部署文档：https://github.com/apache/rocketmq/blob/master/docs/cn/dledger/deploy_guide.md
日志位置：~/logs/rocketmqlogs/

配置文件位置： /usr/local/rocketmq-all-4.7.1-bin-release/conf/dledger/bronker-n0.conf  
user-config /tmp/rocketmq-console/data/users.properties

相关端口：  9876 30909 30911 40911
启动命令 
```
# staret rocketMq server
/usr/local/rocketmq-all-4.7.1-bin-release/bin/mqnamesrv  > /usr/local/rocketmq-all-4.7.1-bin-release/start_mqnamesrv.log 2>&1 &
# staret rocketMq broker
/usr/local/rocketmq-all-4.7.1-bin-release/bin/mqbroker -c  /usr/local/rocketmq-all-4.7.1-bin-release/conf/dledger/broker-n0.conf  > /usr/local/rocketmq-all-4.7.1-bin-release/start_mqbroker.log 2>&1 &

```

rocketMQ console 启动命令
```
#start pro rocketmq console
cd /usr/local/rocketmq-console &&  nohup java -jar -Drocketmq.config.loginRequired=true -Drocketmq.config.namesrvAddr="xxx:9876;xxx:9876;xxx:9876" rocketmq-console-ng-2.0.0.jar 2>&1 > start_rocketmq-console.log &   #指定集群IP
```

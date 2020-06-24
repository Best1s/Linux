https://kafka.apache.org/quickstart

启动Zookeeper

Kafka作为分布式系统依赖zk保存状态数据，kafka自带了zookeeper
```
cd kafka_2.12-2.5.0
nohup ./bin/zookeeper-server-start.sh config/zookeeper.properties &> /dev/null &
```
启动单个Kafka
```
cd kafka_2.12-2.5.0
nohup ./bin/kafka-server-start.sh config/server.properties &> /dev/null &
```

启动Kafka集群

Kafka集群是通过ZK构建的，所以启动集群即启动多个Kafka实例，这些实例的配置中zk地址相同。

```
cd kafka_2.12-2.5.0
cp config/server.properties config/server-1.properties
cp config/server.properties config/server-2.properties
```
```
vim config/server-1.properties
	broker.id=1
	listeners=PLAINTEXT://:9093
	log.dirs=/tmp/kafka-logs-1
	
vim config/server-2.properties
	broker.id=2
	listeners=PLAINTEXT://:9094
	log.dirs=/tmp/kafka-logs-2
```
** broker.id保证在集群中唯一，log.dirs为消息数据存储路径 *

控制台客户端
- 列出集群中所有的topic

```
./bin/kafka-topics.sh --list --bootstrap-server localhost:9092

```
- 创建一个topic

```
./bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 --topic test

```
- 查看topic详情

```
./bin/kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic test
Topic: test1	PartitionCount: 1	ReplicationFactor: 1	Configs: segment.bytes=1073741824
	Topic: test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
```

Topic详情中第一行是Topic总体信息：Topic，partition数量，副本数量，segment.bytes: commit-log的单文件最大存储量

第二行是每一个partition的详情：Topic，Partition编号，当前Leader-Partition编号，所有副本partition编号，保持同步状态的副本partition数量(ISR: in-sync)